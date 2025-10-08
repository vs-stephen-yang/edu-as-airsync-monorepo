package com.mvbcast.crosswalk.helper;

import android.Manifest;
import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbManager;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Handler;
import android.os.Looper;
import android.provider.Settings;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;

public class WifiHelper {
    // region Singleton Implementation
    // https://android.jlelse.eu/how-to-make-the-perfect-singleton-de6b951dfdb0
    //-------------------------------------------------------------------------
    private static volatile WifiHelper INSTANCE = null;

    // private constructor.
    private WifiHelper() {
        // Prevent form the reflection api.
        if (INSTANCE != null) {
            throw new RuntimeException("Use getInstance() method to get the single instance of this class.");
        }
    }

    public static WifiHelper getInstance() {
        // Double check locking pattern
        if (INSTANCE == null) {// Check for the first time
            synchronized (WifiHelper.class) {// Check for the second time.
                // if there is no instance available... create new one
                if (INSTANCE == null) INSTANCE = new WifiHelper();
            }
        }
        return INSTANCE;
    }
    //-------------------------------------------------------------------------
    // endregion Singleton Implementation

    private final int LOCATION_PERMISSION_REQUEST_CODE = 1001;
    /**
     * 可擴充的 USB Wi-Fi 模組清單 (VendorId, ProductId)
     */
    private static final List<DeviceId> SPECIFIED_USB_MODULES = Arrays.asList(
            new DeviceId(0xA69C, 0x8801), // VB004
            new DeviceId(0x0BDA, 0xA85B)  // VB005
    );

    /**
     * Inner Class
     * 用於儲存 VendorId 與 ProductId 的結構
     */
    private static class DeviceId {
        final int vendorId;
        final int productId;

        DeviceId(int vendorId, int productId) {
            this.vendorId = vendorId;
            this.productId = productId;
        }

        boolean matches(UsbDevice device) {
            return device.getVendorId() == vendorId && device.getProductId() == productId;
        }
    }

    private final List<Integer> mDFSChannel = Arrays.asList(
            52, 56, 60, 64, 100, 104, 108, 112,
            116, 120, 124, 128, 132, 136, 140, 144
    );

    private BroadcastReceiver usbReceiver;
    private EventChannel.EventSink mWiFiHelperEventSink;
    private boolean mIsMonitorUSB = false;
    private boolean mIsSpecifiedWirelessModuleFound = false;
    private boolean mIsSpecifiedModuleAndDFSChannel = false;
    private Boolean mLastSpecifiedModuleAndDFSChannel;

    private Handler monitorHandler = null;
    private Runnable monitorRunnable = null;

    public void initSpecifiedModuleDFSChannelMonitor(Activity activity, BinaryMessenger binaryMessenger) {
        new EventChannel(binaryMessenger, "com.mvbcast.crosswalk/wifi_helper_specified_module_dfs_channel")
                .setStreamHandler(new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object arguments, EventChannel.EventSink events) {
                        mWiFiHelperEventSink = events;
                        mLastSpecifiedModuleAndDFSChannel = null;
                        // need wait sink ready.
                        startWifiMonitoringIfGrantPermission(activity);
                    }

                    @Override
                    public void onCancel(Object arguments) {
                        mWiFiHelperEventSink = null;
                        mLastSpecifiedModuleAndDFSChannel = null;
                    }
                });

        checkConnectedUsbDevices(activity);

        mIsMonitorUSB = true;
    }

    public void registerUsbReceiver(Activity activity) {
        if (usbReceiver == null) {
            usbReceiver = new BroadcastReceiver() {
                @Override
                public void onReceive(Context context, Intent intent) {
                    String action = intent.getAction();
                    if (UsbManager.ACTION_USB_DEVICE_ATTACHED.equals(action) || UsbManager.ACTION_USB_DEVICE_DETACHED.equals(action)) {
                        if (mIsMonitorUSB) {
                            checkConnectedUsbDevices(activity);
                        }
                    }
                }
            };
            IntentFilter filter = new IntentFilter();
            filter.addAction(UsbManager.ACTION_USB_DEVICE_ATTACHED);
            filter.addAction(UsbManager.ACTION_USB_DEVICE_DETACHED);
            activity.getApplicationContext().registerReceiver(usbReceiver, filter);
        }
    }

    public void unregisterUsbReceiver(Activity activity) {
        if (usbReceiver != null) {
            try {
                activity.getApplicationContext().unregisterReceiver(usbReceiver);
            } catch (IllegalArgumentException e) {
                Log.w("WifiHelper", "Receiver has already been unregistered.");
            }
        }
    }

    /**
     * @noinspection unused
     */
    public boolean onRequestPermissionsResult(@NonNull Activity activity, int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        if (requestCode == LOCATION_PERMISSION_REQUEST_CODE) {
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                sendPermissionStatusToFlutter("permission_granted");
                // 權限取得成功後開始 Wi-Fi 偵測
                startWifiMonitorLoop(activity);
            } else {
                sendPermissionStatusToFlutter("permission_denied_permanently");
                Toast.makeText(activity, "Location permission is required!", Toast.LENGTH_LONG).show();
            }
            return true;
        }
        return false;
    }

    private void checkConnectedUsbDevices(Activity activity) {
        UsbManager usbManager = (UsbManager) activity.getApplicationContext().getSystemService(Context.USB_SERVICE);
        if (usbManager != null) {
            boolean foundSpecifiedWirelessModule = false;
            HashMap<String, UsbDevice> deviceList = usbManager.getDeviceList();
            if (!deviceList.isEmpty()) {
                for (UsbDevice device : deviceList.values()) {
                    for (DeviceId specifiedModule : SPECIFIED_USB_MODULES) {
                        if (specifiedModule.matches(device)) {
                            foundSpecifiedWirelessModule = true;
                            break;
                        }
                    }
                }
            }
            mIsSpecifiedWirelessModuleFound = foundSpecifiedWirelessModule;
        }
    }

    // 檢查權限，並依狀態回傳給 Flutter
    private void startWifiMonitoringIfGrantPermission(Activity activity) {
        if (ContextCompat.checkSelfPermission(activity, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            sendPermissionStatusToFlutter("permission_denied");
            ActivityCompat.requestPermissions(activity, new String[]{Manifest.permission.ACCESS_FINE_LOCATION}, LOCATION_PERMISSION_REQUEST_CODE);
        } else {
            sendPermissionStatusToFlutter("permission_granted");
            startWifiMonitorLoop(activity);
        }
    }

    public void startWifiMonitorLoop(Activity activity) {
        if (!mIsSpecifiedWirelessModuleFound) return;
        if (monitorHandler != null) return;
        if (ContextCompat.checkSelfPermission(activity, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED)
            return;

        monitorHandler = new Handler(Looper.getMainLooper());
        monitorRunnable = new Runnable() {
            @Override
            public void run() {
                refreshWifiStatus(activity);
                if (monitorHandler != null) monitorHandler.postDelayed(this, 5000);
            }
        };
        monitorHandler.post(monitorRunnable);
    }

    public void stopWifiMonitorLoop() {
        if (monitorHandler != null && monitorRunnable != null) {
            monitorHandler.removeCallbacks(monitorRunnable);
        }
        monitorHandler = null;
        monitorRunnable = null;
    }

    private void refreshWifiStatus(Activity activity) {
        if (!isLocationEnabled(activity)) {
            Toast.makeText(activity, "Location service is OFF. Please enable it.", Toast.LENGTH_LONG).show();
            sendPermissionStatusToFlutter("location_service_off");
            activity.startActivity(new Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS));
        } else {
            checkWifiConnectionInfo(activity);
            // invoke method to update UI when status changes
            sendDFSStatusToFlutter();
        }
    }

    // 發送 DFS 狀態給 Flutter
    private void sendDFSStatusToFlutter() {
        if (mLastSpecifiedModuleAndDFSChannel == null || mLastSpecifiedModuleAndDFSChannel != mIsSpecifiedModuleAndDFSChannel) {
            mLastSpecifiedModuleAndDFSChannel = mIsSpecifiedModuleAndDFSChannel;
            if (mWiFiHelperEventSink != null) {
                mWiFiHelperEventSink.success(mIsSpecifiedModuleAndDFSChannel);
            }
        }
    }

    // 發送 Permission 狀態給 Flutter
    private void sendPermissionStatusToFlutter(String status) {
        if (mWiFiHelperEventSink != null) {
            mWiFiHelperEventSink.success(status);
        }
    }

    private void checkWifiConnectionInfo(Activity activity) {
        WifiManager wifiManager = (WifiManager) activity.getApplicationContext().getSystemService(Context.WIFI_SERVICE);
        WifiInfo wifiInfo = wifiManager.getConnectionInfo();
        // check if VB-005 is connected and get channel from WifiInfo
        if (mIsSpecifiedWirelessModuleFound && wifiInfo != null && wifiInfo.getNetworkId() != -1) {
            // get frequency from WifiInfo
            int frequency = wifiInfo.getFrequency();
            // get channel from frequency
            int channel = convertFrequencyToChannel(frequency);
            // check if channel is in DFS channel list
            mIsSpecifiedModuleAndDFSChannel = mDFSChannel.contains(channel);
        } else {
            mIsSpecifiedModuleAndDFSChannel = false;
        }
    }

    private int convertFrequencyToChannel(int freq) {
        if (freq >= 2412 && freq <= 2484) {
            return (freq - 2412) / 5 + 1;
        } else if (freq >= 5170 && freq <= 5825) {
            return (freq - 5170) / 5 + 34;
        } else {
            return -1;
        }
    }

    private boolean isLocationEnabled(Activity activity) {
        int locationMode = Settings.Secure.LOCATION_MODE_OFF;
        try {
            locationMode = Settings.Secure.getInt(activity.getContentResolver(), Settings.Secure.LOCATION_MODE);
        } catch (Settings.SettingNotFoundException e) {
            //noinspection CallToPrintStackTrace
            e.printStackTrace();
        }
        return locationMode != Settings.Secure.LOCATION_MODE_OFF;
    }
}
