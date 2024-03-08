package com.mvbcast.crosswalk;


import android.annotation.SuppressLint;
import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.WindowManager;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.mvbcast.crosswalk.vbsota.SystemImageOTAHelper;

import java.util.Calendar;
import java.util.concurrent.TimeUnit;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class EulaActivity extends FlutterActivity {
    private static final String TAG = EulaActivity.class.getSimpleName();
    private MethodChannel mVbsOTA;
    private static MethodChannel mAlarmOTA;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        BinaryMessenger binaryMessenger = flutterEngine.getDartExecutor().getBinaryMessenger();

        MethodChannel mAndroidRetain = new MethodChannel(binaryMessenger, "com.mvbcast.crosswalk/android_app_retain");
        mAndroidRetain.setMethodCallHandler((call, result) -> {
            if (call.method.equals("sendToBackground")) {
                moveTaskToBack(true);
            }
        });

        mVbsOTA = new MethodChannel(binaryMessenger, "com.mvbcast.crosswalk/vbs_ota");
        SystemImageOTAHelper.getInstance().registerBroadcastReceiver(EulaActivity.this);

        MethodChannel otaMethodChannel = new MethodChannel(binaryMessenger, "com.mvbcast.crosswalk/app_update");
        otaMethodChannel.setMethodCallHandler((call, result) -> {
            if (call.method.equals("getFlavor")) {
                result.success(BuildConfig.FLAVOR_channel);
            } else {
                result.success("N/A");
            }
        });
        mAlarmOTA = new MethodChannel(binaryMessenger, "com.mvbcast.crosswalk/app_update_alarm");

        MethodChannel bootMethodChannel = new MethodChannel(binaryMessenger, "com.mvbcast.crosswalk/auto_startup");
        bootMethodChannel.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @SuppressLint("ApplySharedPref")
            @Override
            public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
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
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
    }

    @Override
    protected void onDestroy() {
        SystemImageOTAHelper.getInstance().unregisterBroadcastReceiver(EulaActivity.this);
        super.onDestroy();
//        System.exit(0);
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
            pendingIntent = PendingIntent.getBroadcast(context, 0, new Intent(context, AppAlarmOTA.class), PendingIntent.FLAG_IMMUTABLE);
        } else {
            pendingIntent = PendingIntent.getBroadcast(context, 0, new Intent(context, AppAlarmOTA.class), 0);
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
            mAlarmOTA.invokeMethod("AppAlarmOTA", null);
        }
    }
    // endregion

}
