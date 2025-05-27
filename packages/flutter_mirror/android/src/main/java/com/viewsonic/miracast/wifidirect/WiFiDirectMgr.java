package com.viewsonic.miracast.wifidirect;

import android.annotation.SuppressLint;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbManager;
import android.net.wifi.p2p.*;
import android.net.wifi.p2p.WifiP2pManager.Channel;
import android.net.wifi.p2p.WifiP2pManager.ActionListener;
import android.net.wifi.p2p.WifiP2pWfdInfo;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;

import com.viewsonic.miracast.utils.ARPUtil;

import java.lang.reflect.Constructor;
import java.lang.reflect.Method;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

public class WiFiDirectMgr {
  private static final String TAG = "MiraWiFiDirectMgr";
  private static final int DEFAULT_SOURCE_PORT = 7236;
  private static final int PRODUCT_ID_VB_WIFI_004 = 34817;

  private boolean isStart_ = false;
  private boolean isGroupFormed_ = false;
  private String p2pInterfaceName_ = "";

  private int sourcePort_ = DEFAULT_SOURCE_PORT;

  // see
  // https://cs.android.com/android/platform/superproject/main/+/main:packages/modules/Wifi/framework/java/android/net/wifi/p2p/WifiP2pManager.java?q=setMiracastMode%20WiFiP2PManager
  private static final int MIRACAST_DISABLED = 0;
  private static final int MIRACAST_SOURCE = 1;
  private static final int MIRACAST_SINK = 2;

  // Maximum number of IP lookup retries (10 attempts, up to ~1 s total wait)
  private static final int IP_LOOKUP_MAX_RETRIES = 10;

  private static final long IP_LOOKUP_RETRY_DELAY_MS = 100L;

  Set<String> peers_ = new HashSet<>();
  private final WiFiDirectListener listener_;

  Handler handler_;

  public WiFiDirectMgr(WiFiDirectListener listener) {
    listener_ = listener;

    handler_ = new Handler(Looper.getMainLooper());
  }

  private Context context_;
  private WifiP2pManager wifiP2pManager_;
  private Channel channel_;
  private String receiverName_;

  public void start(Context context, String receiverName) {
    if (isStart_) {
      return;
    }
    isStart_ = true;
    context_ = context;
    receiverName_ = receiverName;
    wifiP2pManager_ = (WifiP2pManager) context_.getSystemService(Context.WIFI_P2P_SERVICE);
    channel_ = wifiP2pManager_.initialize(context_, context_.getMainLooper(), null);
    final IntentFilter intentFilter_ = new IntentFilter();
    // Indicates a change in the Wi-Fi P2P status.
    intentFilter_.addAction(WifiP2pManager.WIFI_P2P_STATE_CHANGED_ACTION);
    // Indicates a change in the list of available peers.
    intentFilter_.addAction(WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION);
    // Indicates the state of Wi-Fi P2P connectivity has changed.
    intentFilter_.addAction(WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION);
    context_.registerReceiver(broadcastReceiver_, intentFilter_, null, null);

    Log.d(TAG, "setP2pDeviceName");
    setP2pDeviceName(wifiP2pManager_, channel_, getReceiverName(), new ActionListener() {
      @Override
      public void onSuccess() {
        Log.d(TAG, "Successfully set P2pDeviceName:" + getReceiverName());
      }

      @Override
      public void onFailure(int reason) {
        Log.e(TAG, "Failed to set P2pDeviceName with reason " + reason + ".");
      }
    });

    Log.d(TAG, "setEnableWFD");
    setEnableWFD(wifiP2pManager_, channel_, true, new ActionListener() {
      @Override
      public void onSuccess() {
        Log.d(TAG, "Successfully enabled WFD.");
        setMiracastMode(MIRACAST_SINK);
      }

      @Override
      public void onFailure(int reason) {
        Log.e(TAG, "Failed to enable WFD with reason " + reason + ".");
      }
    });

    if (needsDiscoverPeers()) {
      Log.d(TAG, "discoverPeers");
      wifiP2pManager_.discoverPeers(channel_, new ActionListener() {
        @Override
        public void onSuccess() {
          Log.d(TAG, "Successfully discoverPeers");
        }

        @Override
        public void onFailure(int reason) {
          Log.e(TAG, "Failed to discoverPeers with reason " + reason + ".");
        }
      });
    }

    if (checkGroupExist()) {
      removeGroupSync();
    }

    try {
      Log.d(TAG, "createGroup");
      wifiP2pManager_.createGroup(channel_, new ActionListener() {
        @Override
        public void onSuccess() {
          Log.d(TAG, "Successfully createGroup");
        }

        @Override
        public void onFailure(int reason) {
          Log.e(TAG, "Failed to createGroup with reason " + reason + ".");
          // listener_.onWifiDirectError("Failed to create P2P group");
        }
      });
    } catch (Exception e) {
      Log.e(TAG, "Failed to createGroup", e);
    }
  }

  public void stop() {
    if (isStart_) {
      Log.d(TAG, "stop WiFiDirectMgr");
      if (needsDiscoverPeers()) {
        Log.d(TAG, "stopPeerDiscovery");
        wifiP2pManager_.stopPeerDiscovery(channel_, new ActionListener() {
          @Override
          public void onSuccess() {
            Log.d(TAG, "Successfully stopPeerDiscovery");
          }

          @Override
          public void onFailure(int reason) {
            Log.e(TAG, "Failed to stopPeerDiscovery with reason " + reason + ".");
          }
        });
      }

      setMiracastMode(MIRACAST_DISABLED);
      wifiP2pManager_.removeGroup(channel_, null);
      context_.unregisterReceiver(broadcastReceiver_);
      isStart_ = false;
    }
  }

  private boolean checkGroupExist() {
    final Object lock = new Object();
    boolean[] havedGroup = { false };

    wifiP2pManager_.requestGroupInfo(channel_, group -> {
      havedGroup[0] = (group != null);
      synchronized (lock) {
        lock.notify();
      }
    });

    synchronized (lock) {
      try {
        lock.wait(1000);
      } catch (InterruptedException e) {
        Log.e(TAG, "lock wait", e);
      }
    }

    return havedGroup[0];
  }

  private void removeGroupSync() {
    final Object lock = new Object();
    wifiP2pManager_.removeGroup(channel_, new ActionListener() {
      @Override
      public void onSuccess() {
        Log.d(TAG, "Successfully remove original Group");
        synchronized (lock) {
          lock.notify();
        }
      }

      @Override
      public void onFailure(int reason) {
        Log.e(TAG, "Failed to remove original Group with reason " + reason + ".");
        synchronized (lock) {
          lock.notify();
        }
      }
    });

    synchronized (lock) {
      try {
        lock.wait(1000);
      } catch (InterruptedException e) {
        // Handle exception
        Log.e(TAG, "lock wait", e);
      }
    }
  }

  private void onDeviceConnected(WifiP2pDevice device) {
    if (device.deviceAddress == null) {
      Log.w(TAG, "The device address is null");
      return;
    }

    Log.d(TAG, "Device connected: " + device.deviceAddress);

    if (peers_.contains(device.deviceAddress)) {
      Log.w(TAG, "Device already connected");
      return;
    }

    new Thread(() -> {
      String sourceIp = getIpFromMacAddress(device.deviceAddress);

      handler_.post(() -> onDeviceConnectedWithIp(device, sourceIp));
    }).start();
  }

  private void onDeviceConnectedWithIp(WifiP2pDevice device, String sourceIp) {

    if (sourceIp == null) {
      listener_.onWifiDirectError("Failed to get source IP");
      return;
    }

    peers_.add(device.deviceAddress);

    listener_.onPeerConnected(device.deviceAddress, device.deviceName, sourceIp, sourcePort_);
  }

  private void onDeviceDisconnected(WifiP2pDevice device) {
    Log.d(TAG, "Device disconnected: " + device.deviceAddress);

    if (!peers_.contains(device.deviceAddress)) {
      Log.w(TAG, "Device is not previously connected: " + device.deviceAddress);
      return;
    }

    peers_.remove(device.deviceAddress);

    listener_.onPeerDisconnected(device.deviceAddress);
  }

  private void processPeerListChanged(final Collection<WifiP2pDevice> peerList) {
    Log.d(TAG, peerList.size() + " device(s) found");
    for (WifiP2pDevice peer : peerList) {
      Log.d(TAG, String.format("peer: %s - %s - status: %d",
          peer.deviceName,
          peer.deviceAddress,
          peer.status));

      if (peer.status == WifiP2pDevice.CONNECTED) {
        onDeviceConnected(peer);
      } else {
        onDeviceDisconnected(peer);

      }
    }
  }

  private void onGroupInfoAvailable(WifiP2pGroup group) {
    assert group != null : "group must not be null";
    p2pInterfaceName_ = group.getInterface();
    Log.d(TAG, "\n====== Group info: ======\n" + group);
  }

  public void onConnectionInfoAvailable(WifiP2pInfo info) {
    assert info != null : "info must not be null";

    Log.d(TAG, "Connection changed. " + info);
    isGroupFormed_ = info.groupFormed;
  }

  private String getIpFromMacAddress(String sourceMacAddr) {
    for (int attempt = 1; attempt <= IP_LOOKUP_MAX_RETRIES && isGroupFormed_ && isStart_; attempt++) {

      String sourceIp = ARPUtil.getIPFromMac(sourceMacAddr, p2pInterfaceName_);
      if (!TextUtils.isEmpty(sourceIp)) {
        Log.d(TAG, "ARPUtil.getIPFromMac ret:" + sourceIp);
        return sourceIp;
      }

      Log.d(TAG, "ARPUtil.getIPFromMac: " + sourceMacAddr + " ret is null");

      try {
        Thread.sleep(IP_LOOKUP_RETRY_DELAY_MS);
      } catch (InterruptedException e) {
        Log.e(TAG, "Sleep in getIpFromMacAddress", e);
      }
    }
    Log.w(TAG, "Failed to lookup IP after " + IP_LOOKUP_MAX_RETRIES + " attempts.");
    return null;
  }

  private final BroadcastReceiver broadcastReceiver_ = new BroadcastReceiver() {
    @Override
    public void onReceive(Context context, Intent intent) {
      String action = intent.getAction();
      if (WifiP2pManager.WIFI_P2P_STATE_CHANGED_ACTION.equals(action)) {
        // Determine if Wifi P2P mode is enabled or not, alert
        // the Activity.
        int state = intent.getIntExtra(WifiP2pManager.EXTRA_WIFI_STATE, -1);
        if (state == WifiP2pManager.WIFI_P2P_STATE_ENABLED) {
          Log.d(TAG, "onReceive: WIFI_P2P_STATE_ENABLED is true");
        } else {
          Log.d(TAG, "onReceive: WIFI_P2P_STATE_ENABLED is false");
        }
      } else if (WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION.equals(action)) {
        // The peer list has changed.
        Log.d(TAG, "onReceive: WIFI_P2P_PEERS_CHANGED_ACTION");
        WifiP2pDeviceList wifiP2pDeviceList = intent.getParcelableExtra(WifiP2pManager.EXTRA_P2P_DEVICE_LIST);
        if (wifiP2pDeviceList == null || wifiP2pDeviceList.getDeviceList() == null) {
          return;
        }
        processPeerListChanged(wifiP2pDeviceList.getDeviceList());
      } else if (WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION.equals(action)) {
        // Connection state changed! We should probably do something about that.
        WifiP2pGroup wifiP2pGroup = intent.getParcelableExtra(WifiP2pManager.EXTRA_WIFI_P2P_GROUP);
        WifiP2pInfo wifiP2pInfo = intent.getParcelableExtra(WifiP2pManager.EXTRA_WIFI_P2P_INFO);

        Log.d(TAG, "onReceive: WIFI_P2P_CONNECTION_CHANGED_ACTION");

        if (wifiP2pInfo != null) {
          onConnectionInfoAvailable(wifiP2pInfo);
        }

        if (wifiP2pGroup != null) {
          onGroupInfoAvailable(wifiP2pGroup);
        }
      }
    }
  };

  @SuppressLint("PrivateApi")
  private void setEnableWFD(WifiP2pManager wifiP2pManager, Channel channel, boolean enable, ActionListener listener) {
    try {
      Class<?> clsWifiP2pWfdInfo = Class.forName("android.net.wifi.p2p.WifiP2pWfdInfo");
      WifiP2pWfdInfo wifiP2pWfdInfo;
      String setWfdMethodName;
      if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
        Constructor<?> ctorWifiP2pWfdInfo = clsWifiP2pWfdInfo.getConstructor();
        wifiP2pWfdInfo = (WifiP2pWfdInfo) ctorWifiP2pWfdInfo.newInstance();

        // wifiP2pWfdInfo.setWfdEnabled(true);
        Method mtdSetWfdEnabled = clsWifiP2pWfdInfo.getMethod("setWfdEnabled", boolean.class);
        mtdSetWfdEnabled.invoke(wifiP2pWfdInfo, enable);

        // wifiP2pWfdInfo.setDeviceType(WifiP2pWfdInfo.PRIMARY_SINK);
        Method mtdSetDeviceTypes = clsWifiP2pWfdInfo.getMethod("setDeviceType", int.class);
        mtdSetDeviceTypes.invoke(wifiP2pWfdInfo, 1);

        // wifiP2pWfdInfo.setSessionAvailable(true);
        Method mtdSetSessionAvailable = clsWifiP2pWfdInfo.getMethod("setSessionAvailable", boolean.class);
        mtdSetSessionAvailable.invoke(wifiP2pWfdInfo, enable);

        // wifiP2pWfdInfo.setControlPort(DEFAULT_SOURCE_PORT);
        Method mtdSetControlPort = clsWifiP2pWfdInfo.getMethod("setControlPort", int.class);
        mtdSetControlPort.invoke(wifiP2pWfdInfo, DEFAULT_SOURCE_PORT);

        // wifiP2pWfdInfo.setMaxThroughput(MAX_THROUGHPUT);
        Method mtdSetMaxThroughput = clsWifiP2pWfdInfo.getMethod("setMaxThroughput", int.class);
        mtdSetMaxThroughput.invoke(wifiP2pWfdInfo, 20);

        setWfdMethodName = "setWFDInfo";
      } else {
        wifiP2pWfdInfo = new WifiP2pWfdInfo();
        wifiP2pWfdInfo.setEnabled(enable);
        wifiP2pWfdInfo.setDeviceType(WifiP2pWfdInfo.DEVICE_TYPE_PRIMARY_SINK);
        wifiP2pWfdInfo.setSessionAvailable(enable);
        wifiP2pWfdInfo.setControlPort(DEFAULT_SOURCE_PORT);
        wifiP2pWfdInfo.setMaxThroughput(20);
        setWfdMethodName = "setWfdInfo";
      }

      if (listener != null) {
        Class<?> clsWifiP2pManager = Class.forName("android.net.wifi.p2p.WifiP2pManager");
        Method methodSetWFDInfo = clsWifiP2pManager.getMethod(setWfdMethodName,
            Channel.class, clsWifiP2pWfdInfo, ActionListener.class);
        methodSetWFDInfo.invoke(wifiP2pManager, channel, wifiP2pWfdInfo, listener);
      }
    } catch (Exception e) {
      Log.e(TAG, "Failed to setEnableWFD", e);
    }
  }

  private void setMiracastMode(int mode) {
    try {
      Log.d(TAG, "Setting Miracast mode to " + mode);
      WifiP2pManager.class.getMethod("setMiracastMode", Integer.TYPE)
          .invoke(wifiP2pManager_, mode);
      Log.d(TAG, "Successfully set Miracast mode: " + mode);
    } catch (Throwable e) {
      Log.e(TAG, "Throwable in setting Miracast mode: " + e.getMessage());
    }
  }

  private void setP2pDeviceName(WifiP2pManager wifiP2pManager, Channel channel, String deviceName,
      ActionListener listener) {
    try {
      Method m = wifiP2pManager.getClass().getMethod(
          "setDeviceName", Channel.class, String.class, ActionListener.class);
      m.invoke(wifiP2pManager, channel, deviceName, listener);
    } catch (Exception e) {
      Log.e(TAG, "Failed to setP2pDeviceName:" + e.getLocalizedMessage());
    }
  }

  public String getDeviceName() {
    String model = android.os.Build.MODEL;
    return capitalize(model);
  }

  private String capitalize(String s) {
    if (s == null || s.isEmpty()) {
      return "";
    }
    char first = s.charAt(0);
    if (Character.isUpperCase(first)) {
      return s;
    } else {
      return Character.toUpperCase(first) + s.substring(1);
    }
  }

  private String getReceiverName() {
    return receiverName_;
  }

  private boolean needsDiscoverPeers() {
    // traverse usb device list to find specific product id
    UsbManager usbManager = (UsbManager) context_.getSystemService(Context.USB_SERVICE);
    HashMap<String, UsbDevice> deviceList = usbManager.getDeviceList();
    Iterator<UsbDevice> deviceIterator = deviceList.values().iterator();
    Log.d(TAG, "Usb device list:");
    while (deviceIterator.hasNext()) {
      UsbDevice device = deviceIterator.next();
      Log.d(TAG, "vendorId: " + device.getVendorId() + " productId: " + device.getProductId() + " deviceName: "
          + device.getDeviceName());
      if (device.getProductId() == PRODUCT_ID_VB_WIFI_004) {
        return true;
      }
    }
    return false;
  }
}
