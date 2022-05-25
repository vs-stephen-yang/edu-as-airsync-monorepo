package com.mvbcast.crosswalk;


import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import androidx.annotation.NonNull;

import com.mvbcast.crosswalk.helper.OTAHelper;
import com.mvbcast.crosswalk.vbsota.SystemImageOTAHelper;
import com.mvbcast.crosswalk.view.WebRTCNativeViewFactory;

import java.util.Calendar;
import java.util.concurrent.TimeUnit;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
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

        mVbsOTA = new MethodChannel(binaryMessenger, "com.mvbcast.crosswalk/vbs_ota");
        SystemImageOTAHelper.getInstance().registerBroadcastReceiver(MainActivity.this);

        OTAHelper.getInstance().checkLatestVersion(MainActivity.this, () -> {
            // TODO:
        });
        OTAHelper.getInstance().clearForceCheckVersion();
    }

    @Override
    protected void onStart() {
        super.onStart();

        OTAHelper.getInstance().checkLatestVersion(MainActivity.this, () -> {
            // TODO:
        });
    }

    @Override
    protected void onDestroy() {
        OTAHelper.getInstance().removeDownloadProcess(MainActivity.this);

        SystemImageOTAHelper.getInstance().unregisterBroadcastReceiver(MainActivity.this);

        super.onDestroy();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (OTAHelper.getInstance().onActivityResult(MainActivity.this, requestCode, resultCode, data)) {
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
        Log.e("_TAG_", "setAlarmOTA !!!!!");

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
            Log.e("_TAG_", "AppAlarmOTA onReceive");
            OTAHelper.getInstance().checkLatestVersion();
        }
    }
    // endregion

}
