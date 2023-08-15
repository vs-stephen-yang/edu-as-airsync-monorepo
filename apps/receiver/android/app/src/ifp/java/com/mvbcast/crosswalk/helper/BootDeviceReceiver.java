package com.mvbcast.crosswalk.helper;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build;

import com.mvbcast.crosswalk.EulaActivity;

/**
 * https://www.digi.com/resources/documentation/digidocs/90001546/task/android/t_faq_autostart_custom_android_applications.htm
 **/
public class BootDeviceReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        boolean autoStartUp = context.getSharedPreferences("display", Context.MODE_PRIVATE)
                .getBoolean("autoStartup", true);
        if (Intent.ACTION_BOOT_COMPLETED.equals(intent.getAction()) && autoStartUp) {
            if (Build.MODEL.equals("VBS100") || Build.MODEL.contains("VBS200")) {
                Intent activityIntent = new Intent(context, EulaActivity.class);
                activityIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                context.startActivity(activityIntent);
            }

            EulaActivity.setAlarmOTA(context);
        }
    }
}
