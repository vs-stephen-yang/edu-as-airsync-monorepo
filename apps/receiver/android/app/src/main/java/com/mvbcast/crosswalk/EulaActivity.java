package com.mvbcast.crosswalk;


import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import androidx.annotation.NonNull;

import com.mvbcast.crosswalk.helper.OTAHelper;
import com.mvbcast.crosswalk.helper.WebRTCHelper;
import com.mvbcast.crosswalk.vbsota.SystemImageOTAHelper;
import com.mvbcast.crosswalk.view.WebRTCNativeViewFactory;

import java.util.Calendar;
import java.util.concurrent.TimeUnit;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;

public class EulaActivity extends FlutterActivity {
    private static final String TAG = EulaActivity.class.getSimpleName();
    private MethodChannel mVbsOTA;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        BinaryMessenger binaryMessenger = flutterEngine.getDartExecutor().getBinaryMessenger();

        flutterEngine
                .getPlatformViewsController()
                .getRegistry()
                .registerViewFactory("com.mvbcast.crosswalk/webrtc_native_view",
                        new WebRTCNativeViewFactory(this, binaryMessenger));

        MethodChannel mAndroidRetain = new MethodChannel(binaryMessenger, "com.mvbcast.crosswalk/android_app_retain");
        mAndroidRetain.setMethodCallHandler((call, result) -> {
            if (call.method.equals("sendToBackground")) {
                moveTaskToBack(true);
            }
        });

        mVbsOTA = new MethodChannel(binaryMessenger, "com.mvbcast.crosswalk/vbs_ota");
        SystemImageOTAHelper.getInstance().registerBroadcastReceiver(EulaActivity.this);

        OTAHelper.getInstance().checkLatestVersion(EulaActivity.this, () -> {
            // TODO:
        });
        OTAHelper.getInstance().clearForceCheckVersion();

        WebRTCHelper.getInstance().initWebRTCContext(this);

        WebRTCHelper.getInstance().getAndSetConfigOfIceServers();

        MethodChannel debugInfo = new MethodChannel(binaryMessenger, "com.mvbcast.crosswalk/debug_switch");
        debugInfo.setMethodCallHandler(((call, result) -> {
            if (call.method.equals("toggleDebugInfoVisible")) {
                Boolean value = WebRTCHelper.getInstance().getDebugInfoVisible().getValue();
                WebRTCHelper.getInstance().setDebugInfoVisible(value != null && !value);
            }
        }));
    }

    @Override
    protected void onStart() {
        super.onStart();

        OTAHelper.getInstance().checkLatestVersion(EulaActivity.this, () -> {
            // TODO:
        });
    }

    @Override
    protected void onDestroy() {
        WebRTCHelper.getInstance().onActivityDestroy();

        OTAHelper.getInstance().removeDownloadProcess(EulaActivity.this);

        SystemImageOTAHelper.getInstance().unregisterBroadcastReceiver(EulaActivity.this);

        super.onDestroy();
        System.exit(0);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (OTAHelper.getInstance().onActivityResult(EulaActivity.this, requestCode, resultCode, data)) {
            return;
        }
        super.onActivityResult(requestCode, resultCode, data);
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
        PendingIntent pendingIntent =
                PendingIntent.getBroadcast(context, 0, new Intent(context, AppAlarmOTA.class), 0);

        // noinspection ConstantConditions
        if (BuildConfig.BUILD_TYPE.equals("debug")) {
            am.setInexactRepeating(AlarmManager.RTC_WAKEUP,
                    System.currentTimeMillis() + TimeUnit.MINUTES.toMillis(1),
                    TimeUnit.MINUTES.toMillis(1),
                    pendingIntent);
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
            OTAHelper.getInstance().checkLatestVersion();
        }
    }
    // endregion

}
