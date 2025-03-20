package com.viewsonic.miracast.wifidirect;

import android.annotation.SuppressLint;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbManager;
import android.net.NetworkInfo;
import android.net.wifi.p2p.*;
import android.net.wifi.p2p.WifiP2pManager.Channel;
import android.net.wifi.p2p.WifiP2pManager.ActionListener;
import android.net.wifi.p2p.WifiP2pManager.ConnectionInfoListener;
import android.net.wifi.p2p.WifiP2pManager.GroupInfoListener;
import android.net.wifi.p2p.WifiP2pManager.PeerListListener;
import android.net.wifi.p2p.WifiP2pWfdInfo;
import android.os.Build;
import android.text.TextUtils;
import android.util.Log;

import com.viewsonic.miracast.utils.ARPUtil;

import java.lang.reflect.Constructor;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

public class WiFiDirectMgr {
  private static final String TAG = "MiraWiFiDirectMgr";
  private static final int DEFALUT_SOURCE_PORT = 7236;
  private static final int PRODUCT_ID_VB_WIFI_004 = 34817;

  private boolean isStart_ = false;
  private boolean isGroupFormed_ = false;
  private boolean isGroupOwner_ = false;
  private String p2pInterfaceName_ = "";
  private int groupClientNum_ = 0;
  private int sourcePort_ = DEFALUT_SOURCE_PORT;
  private String sourceIp_ = "";
  private String sourceMacAddr_ = "";
  private String sourceDeviceName_ = "";

  private static final Set<String> GROUP_OWNER_ADDRESS_KEYS = Set.of("groupOwnerAddress", "groupOwnerIpAddress");

  private class PeerInfo {
    public String deviceName_;
    public String ip_;
    public int port_;
    public String macAddr_;
  }

  private List<PeerInfo> peerInfos_ = new ArrayList<>();
  private WiFiDirectListener listener_;

  public WiFiDirectMgr(WiFiDirectListener listener) {
    listener_ = listener;
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
    wifiP2pManager_ = (WifiP2pManager) context_.getSystemService(context_.WIFI_P2P_SERVICE);
    channel_ = wifiP2pManager_.initialize(context_, context_.getMainLooper(), null);
    final IntentFilter intentFilter_ = new IntentFilter();
    // Indicates a change in the Wi-Fi P2P status.
    intentFilter_.addAction(WifiP2pManager.WIFI_P2P_STATE_CHANGED_ACTION);
    // Indicates a change in the list of available peers.
    intentFilter_.addAction(WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION);
    // Indicates the state of Wi-Fi P2P connectivity has changed.
    intentFilter_.addAction(WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION);
    context_.registerReceiver(broadcastReceiver_, intentFilter_, null, null);

    Log.d(TAG, "setEnableWFD");
    setEnableWFD(wifiP2pManager_, channel_, true, new ActionListener() {
      @Override
      public void onSuccess() {
        Log.d(TAG, "Successfully enabled WFD.");
      }

      @Override
      public void onFailure(int reason) {
        Log.e(TAG, "Failed to enable WFD with reason " + reason + ".");
      }
    });

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
        }
      });
    } catch (Exception e) {
      e.printStackTrace();
      Log.e(TAG, "Failed to createGroup:" + e.getLocalizedMessage());
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

      wifiP2pManager_.removeGroup(channel_, null);
      context_.unregisterReceiver(broadcastReceiver_);
      isStart_ = false;
    }
  }

  public String getSourceIp() {
    return sourceIp_;
  }

  public int getSourcePort() {
    return sourcePort_;
  }

  public String getSourceDeviceName() {
    return sourceDeviceName_;
  }

  private boolean checkGroupExist() {
    final Object lock = new Object();
    boolean[] havedGroup = { false };

    wifiP2pManager_.requestGroupInfo(channel_, new GroupInfoListener() {
      @Override
      public void onGroupInfoAvailable(WifiP2pGroup group) {
        havedGroup[0] = (group != null);
        synchronized (lock) {
          lock.notify();
        }
      }
    });

    synchronized (lock) {
      try {
        lock.wait(1000);
      } catch (InterruptedException e) {
        e.printStackTrace();
        Log.e(TAG, "lock wait: " + e.getLocalizedMessage());
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
        e.printStackTrace();
        Log.e(TAG, "lock wait: " + e.getLocalizedMessage());
      }
    }
  }

  private final PeerListListener peerListListener_ = new PeerListListener() {
    @Override
    public void onPeersAvailable(WifiP2pDeviceList peers) {
      List<WifiP2pDevice> peerList = new ArrayList<>(peers.getDeviceList());
      Log.d(TAG, peerList.size() + " device(s) found");
      for (WifiP2pDevice peer : peerList) {
        Log.d(TAG, String.format("peer: %s - %s - status: %d",
            peer.deviceName,
            peer.deviceAddress,
            peer.status));
      }
    }
  };

  private final GroupInfoListener groupInfoListener_ = new GroupInfoListener() {
    @Override
    public void onGroupInfoAvailable(WifiP2pGroup group) {
      if (group != null) {
        String groupInfoStr = group.toString();
        p2pInterfaceName_ = group.getInterface();
        int clientNum = group.getClientList().size();
        Log.d(TAG, "\n====== Group info: ======\n"
            + groupInfoStr + "\n================== Client num:" + clientNum);

        if (clientNum > groupClientNum_) {
          setGroupInfo(groupInfoStr);
          // get last client in getClientList
          WifiP2pDevice client = null;
          for (WifiP2pDevice device : group.getClientList()) {
            client = device;
          }

          if (client == null) {
            Log.e(TAG, "client is null");
            return;
          }

          sourceMacAddr_ = client.deviceAddress;
          sourceDeviceName_ = client.deviceName;

          Log.d(TAG, "sourceMacAddr:" + sourceMacAddr_ + ", sourceDeviceName:" + sourceDeviceName_);

          Log.d(TAG, "peer connected - " + sourceDeviceName_ + " - " + sourceMacAddr_);
          wifiP2pManager_.requestConnectionInfo(channel_, connectionInfoListener_);
        } else if (clientNum < groupClientNum_) {
          /*
           * compare peerInfo.macAddr_ in peerInfos and client.deviceAddress in
           * getClientList to find out which peer is disconnected
           */
          List<WifiP2pDevice> clientList = new ArrayList<>(group.getClientList());
          for (PeerInfo peerInfo : peerInfos_) {
            boolean isClientExist = false;
            for (WifiP2pDevice client : clientList) {
              if (peerInfo.macAddr_.equals(client.deviceAddress)) {
                isClientExist = true;
                break;
              }
            }

            if (!isClientExist) {
              Log.d(TAG, "peer disconnected - " + peerInfo.deviceName_ + " - " + peerInfo.macAddr_);
              listener_.onPeerDisconnected(peerInfo.ip_);
            }
          }
        }
        groupClientNum_ = clientNum;
      }
    }
  };

  private final ConnectionInfoListener connectionInfoListener_ = new ConnectionInfoListener() {
    @Override
    public void onConnectionInfoAvailable(WifiP2pInfo info) {
      String connectInfoStr = info.toString();
      Log.d(TAG, "\n====== Connection info: ======\n" + connectInfoStr + "\n==================");
      // TODO: Avoid relying on the content of WifiP2pInfo.toString().
      // It is an implementation detail that is not reliable and may change over time.
      setConnInfo(connectInfoStr);
    }
  };

  /**
   * set the source deviceAddress and WFD CtrlPort when the source in p2p
   * play a role as a group client
   *
   * @param groupInfo
   */
  /*
   * example
   * network: DIRECT-XB-Mi-Firefly-RK3399
   * isGO: true
   * GO: Device:
   * deviceAddress: d6:12:43:8b:d4:24
   * primary type: null
   * secondary type: null
   * wps: 0
   * grpcapab: 0
   * devcapab: 0
   * status: 4
   * wfdInfo: WFD enabled: falseWFD DeviceInfo: 0
   * WFD CtrlPort: 0
   * WFD MaxThroughput: 0
   * Client: Device: Harvey Lin
   * deviceAddress: 58:ce:2a:fc:4b:13
   * primary type: 1-0050F200-0
   * secondary type: null
   * wps: 4584
   * grpcapab: 4
   * devcapab: 37
   * status: 0
   * wfdInfo: WFD enabled: trueWFD DeviceInfo: 272
   * WFD CtrlPort: 7236
   * WFD MaxThroughput: 6
   * interface: p2p-wlan0-0
   * networkId: 0
   */
  private void setGroupInfo(String groupInfo) {
    sourcePort_ = DEFALUT_SOURCE_PORT;
    if (!TextUtils.isEmpty(groupInfo) && groupInfo.contains("WFD CtrlPort: ")
        && groupInfo.contains("WFD MaxThroughput")) {
      try {
        String sourcePortStr = groupInfo.substring(
            groupInfo.lastIndexOf("WFD CtrlPort: ") + 14, groupInfo.lastIndexOf("WFD MaxThroughput")).trim();
        if (!TextUtils.isEmpty(sourcePortStr)) {
          int tmp = Integer.parseInt(sourcePortStr);
          sourcePort_ = (tmp > 0) ? tmp : DEFALUT_SOURCE_PORT;
          Log.d(TAG, "sourcePort:" + sourcePort_);
        }
      } catch (RuntimeException e) {
        Log.e(TAG, "setGroupInfo exception: " + e.getMessage());
      }
    }
  }

  /**
   * set the groupFormed isGroupOwner groupOwnerAddress info
   *
   * @param connectInfo
   */
  private void setConnInfo(String connectInfo) {
    if (!TextUtils.isEmpty(connectInfo)) {
      String sourceIp = "";
      connectInfo = connectInfo.replace(":", "");
      String[] connectInfoArr = connectInfo.split(" ");
      for (int i = 0; i < connectInfoArr.length - 1; i += 2) {
        if ("groupFormed".equals(connectInfoArr[i])) {
          isGroupFormed_ = "true".equals(connectInfoArr[i + 1]);
        } else if ("isGroupOwner".equals(connectInfoArr[i])) {
          isGroupOwner_ = "true".equals(connectInfoArr[i + 1]);
        } else if (GROUP_OWNER_ADDRESS_KEYS.contains(connectInfoArr[i])) {
          if (isGroupOwner_) {
            String sourceIpStr;
            while (isGroupFormed_ && isStart_) {
              if (TextUtils.isEmpty(sourceMacAddr_)) {
                Log.d(TAG, "Have not gotten Mac Addr.");
                break;
              }

              sourceIpStr = ARPUtil.getIPFromMac(sourceMacAddr_, p2pInterfaceName_);
              if (!TextUtils.isEmpty(sourceIpStr)) {
                sourceIp = sourceIpStr;
                Log.d(TAG, "ARPUtil.getIPFromMac ret:" + sourceIp);
                break;
              } else {
                Log.d(TAG, "ARPUtil.getIPFromMac: " + sourceMacAddr_ + " ret is null");
              }
              try {
                Thread.sleep(500);
              } catch (InterruptedException e) {
                e.printStackTrace();
              }
            }
          } else {
            sourceIp = connectInfoArr[i + 1].substring(1);
          }
        }
      }
      Log.d(TAG, "setConnInfo isGroupFormed:" + isGroupFormed_
          + ", isGroupOwner:" + isGroupOwner_
          + ", SourceIp:" + sourceIp);
      sourceIp_ = sourceIp;
      PeerInfo peerInfo = new PeerInfo();
      peerInfo.ip_ = sourceIp_;
      peerInfo.port_ = sourcePort_;
      peerInfo.deviceName_ = sourceDeviceName_;
      peerInfo.macAddr_ = sourceMacAddr_;
      peerInfos_.add(peerInfo);
      listener_.onPeerConnected(sourceDeviceName_, sourceIp_, sourcePort_);
    }
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
        if (null != wifiP2pManager_) {
          wifiP2pManager_.requestPeers(channel_, peerListListener_);
        }
      } else if (WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION.equals(action)) {
        // Connection state changed! We should probably do something about that.
        NetworkInfo networkInfo = intent.getParcelableExtra(WifiP2pManager.EXTRA_NETWORK_INFO);
        Log.d(TAG, "onReceive: WIFI_P2P_CONNECTION_CHANGED_ACTION"
            + (networkInfo.isConnected() ? "->Connected" : "->Disconnected"));
        if (networkInfo.isConnected()) {
          wifiP2pManager_.requestGroupInfo(channel_, groupInfoListener_);
        }
      }
    }
  };

  @SuppressLint("PrivateApi")
  private void setEnableWFD(WifiP2pManager wifiP2pManager, Channel channel, boolean enable, ActionListener listener) {
    try {
      Class clsWifiP2pWfdInfo = Class.forName("android.net.wifi.p2p.WifiP2pWfdInfo");
      WifiP2pWfdInfo wifiP2pWfdInfo = null;
      String setWfdMethodName = null;
      if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
        Constructor ctorWifiP2pWfdInfo = clsWifiP2pWfdInfo.getConstructor();
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

        // wifiP2pWfdInfo.setMaxThroughput(MAX_THROUGHPUT);
        Method mtdSetMaxThroughput = clsWifiP2pWfdInfo.getMethod("setMaxThroughput", int.class);
        mtdSetMaxThroughput.invoke(wifiP2pWfdInfo, 20);

        setWfdMethodName = "setWFDInfo";
      } else {
        wifiP2pWfdInfo = new WifiP2pWfdInfo();
        wifiP2pWfdInfo.setEnabled(enable);
        wifiP2pWfdInfo.setDeviceType(WifiP2pWfdInfo.DEVICE_TYPE_PRIMARY_SINK);
        wifiP2pWfdInfo.setSessionAvailable(enable);
        wifiP2pWfdInfo.setMaxThroughput(20);
        setWfdMethodName = "setWfdInfo";
      }

      if (listener != null) {
        Class clsWifiP2pManager = Class.forName("android.net.wifi.p2p.WifiP2pManager");
        Method methodSetWFDInfo = clsWifiP2pManager.getMethod(setWfdMethodName,
            Channel.class, clsWifiP2pWfdInfo, ActionListener.class);
        methodSetWFDInfo.invoke(wifiP2pManager, channel, wifiP2pWfdInfo, listener);
      }
    } catch (Exception e) {
      e.printStackTrace();
      Log.e(TAG, "Failed to setEnableWFD: " + e.getLocalizedMessage());
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
    String manufacturer = android.os.Build.MANUFACTURER;
    String model = android.os.Build.MODEL;
    return capitalize(model);
  }

  private String capitalize(String s) {
    if (s == null || s.length() == 0) {
      return "";
    }
    char first = s.charAt(0);
    if (Character.isUpperCase(first)) {
      return s;
    } else {
      return Character.toUpperCase(first) + s.substring(1);
    }
  }

  private String getNickName() {
    return "Mi-" + getDeviceName();
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
