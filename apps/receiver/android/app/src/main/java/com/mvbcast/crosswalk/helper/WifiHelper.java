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
import android.provider.Settings;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;

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
     * @noinspection FieldCanBeLocal
     */
    private final int VB005_VENDOR_ID = 0x0BDA;
    /**
     * @noinspection FieldCanBeLocal
     */
    private final int VB005_PRODUCT_ID = 0xA85B;

    private final List<Integer> mDFSChannel = Arrays.asList(
            52, 56, 60, 64, 100, 104, 108, 112,
            116, 120, 124, 128, 132, 136, 140, 144
    );

    private BroadcastReceiver usbReceiver;
    private EventChannel.EventSink mWiFiHelperEventSink;
    private boolean mIsMonitorUSB = false;
    private boolean mIsVB005Found = false;
    private boolean mIsVB005AndDFSChannel = false;
    private Boolean mLastIsVB005AndDFSChannel;

    public void initVB005DFSChannelMonitor(Activity activity, BinaryMessenger binaryMessenger) {
        new EventChannel(binaryMessenger, "com.mvbcast.crosswalk/wifi_helper_vb005_dfs_channel")
                .setStreamHandler(new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object arguments, EventChannel.EventSink events) {
                        mWiFiHelperEventSink = events;
                        mLastIsVB005AndDFSChannel = null;
                    }

                    @Override
                    public void onCancel(Object arguments) {
                        mWiFiHelperEventSink = null;
                        mLastIsVB005AndDFSChannel = null;
                    }
                });

        checkConnectedUsbDevices(activity);

        monitorWifiChannelChange(activity);

        mIsMonitorUSB = true;
    }

    public void registerUsbReceiver(Activity activity) {
        usbReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                String action = intent.getAction();
                if (UsbManager.ACTION_USB_DEVICE_ATTACHED.equals(action) ||
                        UsbManager.ACTION_USB_DEVICE_DETACHED.equals(action)) {
                    if (mIsMonitorUSB) {
                        checkConnectedUsbDevices(activity);
                    }
                }
            }
        };
        IntentFilter filter = new IntentFilter();
        filter.addAction(UsbManager.ACTION_USB_DEVICE_ATTACHED);
        filter.addAction(UsbManager.ACTION_USB_DEVICE_DETACHED);
        activity.registerReceiver(usbReceiver, filter);
    }

    public void unregisterUsbReceiver(Activity activity) {
        activity.unregisterReceiver(usbReceiver);
    }

    /**
     * @noinspection unused
     */
    public boolean onRequestPermissionsResult(@NonNull Activity activity, int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        if (requestCode == LOCATION_PERMISSION_REQUEST_CODE) {
            if (!(grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED)) {
                Toast.makeText(activity, "Location permission is required!", Toast.LENGTH_LONG).show();
            }
            return true;
        }
        return false;
    }

    private void checkConnectedUsbDevices(Activity activity) {
        UsbManager usbManager = (UsbManager) activity.getApplicationContext().getSystemService(Context.USB_SERVICE);
        if (usbManager != null) {
            boolean foundVB005 = false;
            HashMap<String, UsbDevice> deviceList = usbManager.getDeviceList();
            if (!deviceList.isEmpty()) {
                for (UsbDevice device : deviceList.values()) {
                    int vendorId = device.getVendorId();
                    int productId = device.getProductId();
                    if (vendorId == VB005_VENDOR_ID && productId == VB005_PRODUCT_ID) {
                        foundVB005 = true;
                        break;
                    }
                }
            }
            mIsVB005Found = foundVB005;
        }
    }

    private void monitorWifiChannelChange(Activity activity) {
        Handler handler = new Handler();
        Runnable runnable = new Runnable() {
            @Override
            public void run() {
                refreshWifiStatus(activity);
                handler.postDelayed(this, 5000);
            }
        };
        handler.postDelayed(runnable, 5000);
    }

    private void refreshWifiStatus(Activity activity) {
        if (checkAndRequestLocationPermissions(activity)) {
            return;
        }

        if (!isLocationEnabled(activity)) {
            Toast.makeText(activity, "Location service is OFF. Please enable it.", Toast.LENGTH_LONG).show();
            activity.startActivity(new Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS));
        } else {
            checkWifiConnectionInfo(activity);
        }
        // invoke method to update UI when status changes
        if (mWiFiHelperEventSink != null) {
            if (mLastIsVB005AndDFSChannel == null ||
                    mLastIsVB005AndDFSChannel != mIsVB005AndDFSChannel) {
                mLastIsVB005AndDFSChannel = mIsVB005AndDFSChannel;
                mWiFiHelperEventSink.success(mIsVB005AndDFSChannel);
            }
        }
    }

    private void checkWifiConnectionInfo(Activity activity) {
        WifiManager wifiManager = (WifiManager) activity.getApplicationContext().getSystemService(Context.WIFI_SERVICE);
        WifiInfo wifiInfo = wifiManager.getConnectionInfo();
        // check if VB-005 is connected and get channel from WifiInfo
        if (mIsVB005Found && wifiInfo != null && wifiInfo.getNetworkId() != -1) {
            // get frequency from WifiInfo
            int frequency = wifiInfo.getFrequency();
            // get channel from frequency
            int channel = convertFrequencyToChannel(frequency);
            // check if channel is in DFS channel list
            mIsVB005AndDFSChannel = mDFSChannel.contains(channel);
        } else {
            mIsVB005AndDFSChannel = false;
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

    private boolean checkAndRequestLocationPermissions(Activity activity) {
        if (ActivityCompat.checkSelfPermission(activity, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(activity, new String[]{Manifest.permission.ACCESS_FINE_LOCATION}, LOCATION_PERMISSION_REQUEST_CODE);
            return true;
        }
        return false;
    }
}
