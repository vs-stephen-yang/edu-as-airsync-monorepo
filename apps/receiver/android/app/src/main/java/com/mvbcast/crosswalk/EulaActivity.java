package com.mvbcast.crosswalk;

import android.annotation.SuppressLint;
import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Color;
import android.net.ConnectivityManager;
import android.net.Network;
import android.net.NetworkCapabilities;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import android.util.Log;
import android.view.View;
import android.view.WindowInsets;
import android.view.WindowInsetsController;
import android.view.WindowManager;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.mvbcast.crosswalk.helper.WifiHelper;
import com.mvbcast.crosswalk.vbsota.SystemImageOTAHelper;
import com.mvbcast.crosswalk.vsapi.VSApiHandler;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Calendar;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class EulaActivity extends FlutterActivity {
    private static final String TAG = EulaActivity.class.getSimpleName();
    private MethodChannel mVbsOTA;
    private static MethodChannel mAlarmOTA;
    private VSApiHandler vsApiHandler;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        BinaryMessenger binaryMessenger = flutterEngine.getDartExecutor().getBinaryMessenger();

        vsApiHandler = new VSApiHandler(this, binaryMessenger);

        MethodChannel mAndroidRetain = new MethodChannel(binaryMessenger, "com.mvbcast" +
                ".crosswalk/android_app_retain");
        mAndroidRetain.setMethodCallHandler((call, result) -> {
            if (call.method.equals("sendToBackground")) {
                moveTaskToBack(true);
            }
        });

        mVbsOTA = new MethodChannel(binaryMessenger, "com.mvbcast.crosswalk/vbs_ota");
        SystemImageOTAHelper.getInstance().registerBroadcastReceiver(EulaActivity.this);

        MethodChannel otaMethodChannel = new MethodChannel(binaryMessenger, "com.mvbcast" +
                ".crosswalk/app_update");
        otaMethodChannel.setMethodCallHandler((call, result) -> {
            if (call.method.equals("getFlavor")) {
                result.success(BuildConfig.FLAVOR_channel);
            } else {
                result.success("N/A");
            }
        });
        mAlarmOTA = new MethodChannel(binaryMessenger, "com.mvbcast.crosswalk/app_update_alarm");

        MethodChannel bootMethodChannel = new MethodChannel(binaryMessenger, "com.mvbcast" +
                ".crosswalk/auto_startup");
        bootMethodChannel.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @SuppressLint("ApplySharedPref")
            @Override
            public void onMethodCall(@NonNull MethodCall call,
                                     @NonNull MethodChannel.Result result) {
                if (call.method.equals("getAutoStartupValue")) {
                    boolean autoStartUp = getSharedPreferences("display", MODE_PRIVATE)
                            .getBoolean("autoStartup", true);
                    result.success(autoStartUp);
                } else if (call.method.equals("setAutoStartupValue")) {
                    boolean autoStartUp = Boolean.TRUE.equals(call.argument("startup"));
                    getSharedPreferences("display", MODE_PRIVATE)
                            .edit()
                            .putBoolean("autoStartup", autoStartUp)
                            .commit();
                    result.success(null);
                } else {
                    result.notImplemented();
                }
            }
        });

        MethodChannel strengthMethodChannel = new MethodChannel(binaryMessenger, "com.mvbcast" +
                ".crosswalk/wifi_signal_strength");
        strengthMethodChannel.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @SuppressWarnings("deprecation")
            @Override
            public void onMethodCall(@NonNull MethodCall call,
                                     @NonNull MethodChannel.Result result) {
                if (call.method.equals("getWifiSignalStrength")) {
                    WifiManager wifiManager =
                            (WifiManager) getApplicationContext().getSystemService(Context.WIFI_SERVICE);
                    ConnectivityManager connectivityManager =
                            (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
                    int signalStrength = 0;

                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                        Network network = connectivityManager.getActiveNetwork();
                        NetworkCapabilities networkCapabilities =
                                connectivityManager.getNetworkCapabilities(network);

                        if (networkCapabilities != null && networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)) {
                            int rssi = networkCapabilities.getSignalStrength();
                            signalStrength = WifiManager.calculateSignalLevel(rssi, 100);
                        }
                    } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        Network currentNetwork = connectivityManager.getActiveNetwork();
                        NetworkCapabilities caps =
                                connectivityManager.getNetworkCapabilities(currentNetwork);
                        if (caps != null && caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)) {
                            int rssi = wifiManager.getConnectionInfo().getRssi();
                            signalStrength = WifiManager.calculateSignalLevel(rssi, 100);
                        } else {
                            signalStrength = -1; // Not connected to WiFi
                        }
                    } else {
                        int rssi = wifiManager.getConnectionInfo().getRssi();
                        signalStrength = WifiManager.calculateSignalLevel(rssi, 100);
                    }
                    result.success(signalStrength);
                } else {
                    result.notImplemented();
                }
            }
        });

        new MethodChannel(binaryMessenger, "com.mvbcast.crosswalk/logcat")
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("readLog")) {
                        try {
                            String pid = String.valueOf(android.os.Process.myPid());
                            String buffers = call.argument("buffers");
                            String priority = call.argument("priority");
                            int lines = call.argument("lines");

                            String output = readLogFromLogcat(pid, buffers, priority, lines);
                            result.success(output);
                        } catch (Exception e) {
                            result.error("ERROR", "Failed to read logcat", e.getMessage());
                        }
                    } else {
                        result.notImplemented();
                    }
                });

        new MethodChannel(binaryMessenger, "com.mvbcast.crosswalk/wifi_helper")
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("getFlavor")) {
                        result.success(BuildConfig.FLAVOR_channel);
                    } else if (call.method.equals("startSpecifiedModuleDFSChannelMonitor")) {
                        WifiHelper.getInstance().initSpecifiedModuleDFSChannelMonitor(EulaActivity.this, binaryMessenger);
                        result.success("N/A");
                    } else {
                        result.success("N/A");
                    }
                });

        new MethodChannel(binaryMessenger, "com.mvbcast.crosswalk/wifi_status")
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("isWifiEnabled")) {
                        WifiManager wifiManager = (WifiManager) getApplicationContext().getSystemService(Context.WIFI_SERVICE);
                        boolean isEnabled = wifiManager.isWifiEnabled();
                        result.success(isEnabled);
                    } else {
                        result.success(false);
                    }
                });

        new MethodChannel(binaryMessenger, "com.mvbcast.crosswalk/settings")
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("openBluetoothSettings")) {
                        Intent intent = new Intent(Settings.ACTION_BLUETOOTH_SETTINGS);
                        startActivity(intent);
                        result.success(null);
                    } else {
                        result.notImplemented();
                    }
                });

        // 添加 WiFi 狀態變化的 EventChannel
        new io.flutter.plugin.common.EventChannel(binaryMessenger, "com.mvbcast.crosswalk/wifi_status_events")
                .setStreamHandler(new io.flutter.plugin.common.EventChannel.StreamHandler() {
                    private BroadcastReceiver wifiStateReceiver;
                    private Context applicationContext;

                    @Override
                    public void onListen(Object arguments, io.flutter.plugin.common.EventChannel.EventSink events) {
                        applicationContext = getApplicationContext();
                        wifiStateReceiver = new BroadcastReceiver() {
                            @Override
                            public void onReceive(Context context, Intent intent) {
                                if (WifiManager.WIFI_STATE_CHANGED_ACTION.equals(intent.getAction())) {
                                    int wifiState = intent.getIntExtra(WifiManager.EXTRA_WIFI_STATE, WifiManager.WIFI_STATE_UNKNOWN);
                                    switch (wifiState) {
                                        case WifiManager.WIFI_STATE_ENABLED:
                                            events.success(true);
                                            break;
                                        case WifiManager.WIFI_STATE_DISABLED:
                                            events.success(false);
                                            break;
                                    }
                                }
                            }
                        };
                        IntentFilter intentFilter = new IntentFilter(WifiManager.WIFI_STATE_CHANGED_ACTION);
                        applicationContext.registerReceiver(wifiStateReceiver, intentFilter);
                    }

                    @Override
                    public void onCancel(Object arguments) {
                        if (wifiStateReceiver != null && applicationContext != null) {
                            applicationContext.unregisterReceiver(wifiStateReceiver);
                            wifiStateReceiver = null;
                        }
                    }
                });
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        String myString = getIntent().getStringExtra("RESTART_REASON");
        if ("TaskRemoved".equals(myString) ||
                "Rebooted".equals(myString) ||
                "Replaced".equals(myString)) {
            moveTaskToBack(true);
        }
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        WifiHelper.getInstance().registerUsbReceiver(EulaActivity.this);
    }

    @Override
    protected void onResume() {
        super.onResume();
        enableFullscreenMode(this);
    }

    @Override
    protected void onDestroy() {
        if (vsApiHandler != null) {
            vsApiHandler.dispose();
        }
        SystemImageOTAHelper.getInstance().unregisterBroadcastReceiver(EulaActivity.this);
        WifiHelper.getInstance().unregisterUsbReceiver(EulaActivity.this);
        super.onDestroy();
//        System.exit(0);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        if (WifiHelper.getInstance().onRequestPermissionsResult(this, requestCode, permissions, grantResults)) {
            return;
        }
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }

    public void setSystemOTAEnableUI(boolean enableUI) {
        mVbsOTA.invokeMethod("setSystemOTAEnableUI", enableUI);
    }

    public void setDownloadProgress(int progress) {
        mVbsOTA.invokeMethod("setDownloadProgress", progress);
    }

    // region App Alarm OTA
    public static void setAlarmOTA(Context context) {
        Log.e(TAG, "setAlarmOTA !!!!!");

        AlarmManager am = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
        PendingIntent pendingIntent;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            pendingIntent = PendingIntent.getBroadcast(context, 0, new Intent(context,
                    AppAlarmOTA.class), PendingIntent.FLAG_IMMUTABLE);
        } else {
            pendingIntent = PendingIntent.getBroadcast(context, 0, new Intent(context,
                    AppAlarmOTA.class), 0);
        }

        // noinspection ConstantConditions
        if (BuildConfig.BUILD_TYPE.equals("debug")) {
//            am.setInexactRepeating(AlarmManager.RTC_WAKEUP,
//                    System.currentTimeMillis() + TimeUnit.MINUTES.toMillis(1),
//                    TimeUnit.MINUTES.toMillis(1),
//                    pendingIntent);
        } else {
            // Set the alarm to start at approximately 2:00 a.m.
            Calendar calendar = Calendar.getInstance();
            calendar.setTimeInMillis(System.currentTimeMillis());
            calendar.set(Calendar.HOUR_OF_DAY, 2);

            // With setInexactRepeating(), you have to use one of the AlarmManager interval
            // constants--in this case, AlarmManager.INTERVAL_DAY.
            am.setInexactRepeating(AlarmManager.RTC_WAKEUP,
                    calendar.getTimeInMillis(),
                    AlarmManager.INTERVAL_DAY,
                    pendingIntent);
        }
    }

    public static class AppAlarmOTA extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            Log.e(TAG, "AppAlarmOTA onReceive");
            if (mAlarmOTA != null) {
                mAlarmOTA.invokeMethod("AppAlarmOTA", null);
            }
        }
    }
    // endregion

    private static String readLogFromLogcat(String pid, String buffers, String priority, int lines) throws IOException {
        String command = String.format("logcat --pid=%s -d -b %s *:%s -t %d", pid, buffers, priority, lines);

        Log.i(TAG, "Reading system log with command: " + command);

        StringBuilder output = new StringBuilder();
        Process process = Runtime.getRuntime().exec(command);

        try (
            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
        ){
            String line;
            while ((line = reader.readLine()) != null) {
                output.append(line).append("\n");
            }
        } finally {
            process.destroy();
        }

        return output.toString();
    }

    private void enableFullscreenMode(FlutterActivity activity) {
        if (activity.getWindow() != null) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                // For Android 11 (API 30) and above
                WindowInsetsController windowInsetsController =
                        activity.getWindow().getInsetsController();
                if (windowInsetsController != null) {
                    windowInsetsController.hide(WindowInsets.Type.statusBars() |
                            WindowInsets.Type.navigationBars());
                    windowInsetsController.
                            setSystemBarsBehavior(WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE);
                }
                activity.getWindow().setNavigationBarColor(Color.TRANSPARENT);
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                // For Android 4.4 (API 19) to Android 10 (API 29)
                activity.getWindow().getDecorView().setSystemUiVisibility(
                        View.SYSTEM_UI_FLAG_LAYOUT_STABLE |
                                View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION |
                                View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN |
                                View.SYSTEM_UI_FLAG_HIDE_NAVIGATION |
                                View.SYSTEM_UI_FLAG_FULLSCREEN |
                                View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY);
                activity.getWindow().setNavigationBarColor(Color.TRANSPARENT);
            } else {
                // For Android versions below 4.4 (API 19)
                activity.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                        WindowManager.LayoutParams.FLAG_FULLSCREEN);
            }
        }
    }
}
