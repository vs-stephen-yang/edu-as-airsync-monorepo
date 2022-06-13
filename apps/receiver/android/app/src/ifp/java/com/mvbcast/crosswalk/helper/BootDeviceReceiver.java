package com.mvbcast.crosswalk.helper;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.util.Log;

import com.mvbcast.crosswalk.MainActivity;

/**
 * https://www.digi.com/resources/documentation/digidocs/90001546/task/android/t_faq_autostart_custom_android_applications.htm
 **/
public class BootDeviceReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        if (Intent.ACTION_BOOT_COMPLETED.equals(intent.getAction())) {
            if (Build.MODEL.equals("VBS100")) {
                Intent activityIntent = new Intent(context, MainActivity.class);
                activityIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                context.startActivity(activityIntent);
            }

            MainActivity.setAlarmOTA(context);
        }
    }
}
