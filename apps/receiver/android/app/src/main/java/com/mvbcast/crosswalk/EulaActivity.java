package com.mvbcast.crosswalk;

import static android.content.Intent.getIntent;

import android.annotation.SuppressLint;
import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.database.ContentObserver;
import android.graphics.Color;
import android.graphics.Point;
import android.graphics.Rect;
import android.net.ConnectivityManager;
import android.net.Network;
import android.net.NetworkCapabilities;
import android.net.Uri;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.provider.Settings;
import android.text.format.DateFormat;
import android.util.Log;
import android.util.Size;
import android.view.Display;
import android.view.View;
import android.view.WindowInsets;
import android.view.WindowInsetsController;
import android.view.WindowManager;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.mvbcast.crosswalk.helper.WifiHelper;
import com.mvbcast.crosswalk.vbsota.SystemImageOTAHelper;
import com.mvbcast.crosswalk.vsapi.VSApiHandler;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class EulaActivity extends FlutterActivity {
    private static final String TAG = EulaActivity.class.getSimpleName();
    private MethodChannel mVbsOTA;
    private static MethodChannel mAlarmOTA;
    private VSApiHandler vsApiHandler;
    private MethodChannel multiWindowChannel;

    private WifiManager.MulticastLock multicastLock;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        BinaryMessenger binaryMessenger = flutterEngine.getDartExecutor().getBinaryMessenger();

        // Use the same condition as in VSApi.createVSApiInstance() [vs_api.dart]
        if (BuildConfig.FLAVOR_channel == "ifp") {
            vsApiHandler = new VSApiHandler(this, binaryMessenger);
        }

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
        new EventChannel(binaryMessenger, "com.mvbcast.crosswalk/wifi_status_events")
                .setStreamHandler(new EventChannel.StreamHandler() {
                    private BroadcastReceiver wifiStateReceiver;
                    private Context applicationContext;

                    @Override
                    public void onListen(Object arguments, EventChannel.EventSink events) {
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

        multiWindowChannel = new MethodChannel(binaryMessenger, "com.mvbcast.crosswalk/multi_window_mode");
        multiWindowChannel.setMethodCallHandler((call, result) -> {
                    if (call.method.equals("getRealScreenResolution")) {
                        Size resolution = getRealScreenResolution(this);
                        Map<String, Integer> map = new HashMap<>();
                        map.put("width", resolution.getWidth());
                        map.put("height", resolution.getHeight());
                        result.success(map);
                    } else {
                        result.notImplemented();
                    }
                });

        // time event channel
        new EventChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(),
                "com.mvbcast.crosswalk/time_events"
        ).setStreamHandler(new EventChannel.StreamHandler() {
            private Context applicationContext;
            private ContentObserver timeFormatObserver;
            private BroadcastReceiver localeReceiver;

            @Override
            public void onListen(Object arguments, final EventChannel.EventSink events) {
                applicationContext = getApplicationContext();

                // 送出目前值
                push(events, applicationContext);

                // 監聽 12/24 時制設定變更（Settings.System.TIME_12_24）
                final Uri uri = Settings.System.getUriFor(Settings.System.TIME_12_24);
                timeFormatObserver = new ContentObserver(new Handler(Looper.getMainLooper())) {
                    @Override
                    public void onChange(boolean selfChange) {
                        push(events, applicationContext);
                    }

                    @Override
                    public void onChange(boolean selfChange, Uri changedUri) {
                        push(events, applicationContext);
                    }
                };
                applicationContext.getContentResolver().registerContentObserver(
                        uri,
                        false,
                        timeFormatObserver
                );

                // 監聽語系變更（可能影響預設 12/24）
                localeReceiver = new BroadcastReceiver() {
                    @Override
                    public void onReceive(Context context, Intent intent) {
                        push(events, applicationContext);
                    }
                };
                // 動態註冊，不需在 Manifest 宣告
                applicationContext.registerReceiver(localeReceiver, new IntentFilter(Intent.ACTION_LOCALE_CHANGED));
            }

            @Override
            public void onCancel(Object arguments) {
                // 取消監聽並清理資源
                if (timeFormatObserver != null) {
                    applicationContext.getContentResolver().unregisterContentObserver(timeFormatObserver);
                    timeFormatObserver = null;
                }
                if (localeReceiver != null && applicationContext != null) {
                    try {
                        applicationContext.unregisterReceiver(localeReceiver);
                    } catch (IllegalArgumentException ignored) {
                    }
                    localeReceiver = null;
                }
            }

            private void push(EventChannel.EventSink sink, Context ctx) {
                boolean is24 = DateFormat.is24HourFormat(ctx);
                // 回傳 boolean；Dart 端可直接當 bool 使用
                sink.success(is24);
            }
        });
    }

    private Size getRealScreenResolution(Context context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            WindowManager windowManager = context.getSystemService(WindowManager.class);
            Rect bounds = windowManager.getMaximumWindowMetrics().getBounds();
            return new Size(bounds.width(), bounds.height());
        } else {
            WindowManager windowManager = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
            Display display = windowManager.getDefaultDisplay();
            Point point = new Point();
            // getRealSize() → 取得螢幕物理解析度（包含 navigation bar、status bar 空間）
            // getSize() → 只會算可用空間（不含 navigation bar）
            display.getRealSize(point);
            return new Size(point.x, point.y);
        }
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Check CPU architecture
        if (BuildConfig.FLAVOR_channel != "open") { // ChromeOS may using x86_64 arch.
            String abi = System.getProperty("os.arch");
            if (abi != null && abi.contains("x86")) {
                Toast.makeText(this, "This device architecture is not supported", Toast.LENGTH_LONG).show();
                finish(); // Exit immediately
            }
        }

        String myString = getIntent().getStringExtra("RESTART_REASON");
        if ("TaskRemoved".equals(myString) ||
                "Rebooted".equals(myString) ||
                "Replaced".equals(myString)) {
            moveTaskToBack(true);
        }
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        WifiHelper.getInstance().registerUsbReceiver(EulaActivity.this);

        WifiManager wifiManager = (WifiManager) getApplicationContext().getSystemService(Context.WIFI_SERVICE);

        // 建立並 acquire MulticastLock
        if (wifiManager != null) {
            multicastLock = wifiManager.createMulticastLock("multicast_lock");
            multicastLock.setReferenceCounted(false);
            multicastLock.acquire();
        }
    }

    @Override
    public void onMultiWindowModeChanged(boolean isInMultiWindowMode) {
        super.onMultiWindowModeChanged(isInMultiWindowMode);
        // https://developer.android.com/develop/ui/views/layout/support-multi-window-mode?hl=zh-tw
        if (multiWindowChannel != null) {
            multiWindowChannel.invokeMethod("onMultiWindowChanged", isInMultiWindowMode);
        }
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
        if (multicastLock != null) {
            multicastLock.release();
        }
        mAlarmOTA = null;
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

        Intent intent = new Intent(context, AppAlarmOTA.class);
        intent.setAction("com.mvbcast.crosswalk.AppOTA"); // must add this!!
        intent.setPackage("com.mvbcast.crosswalk");
        int flag = (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) ? PendingIntent.FLAG_IMMUTABLE : 0;
        PendingIntent pendingIntent = PendingIntent.getBroadcast(context, 0, intent, flag);

        AlarmManager am = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
        // Remove previously scheduled alarm before setting a new one
        am.cancel(pendingIntent);

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
