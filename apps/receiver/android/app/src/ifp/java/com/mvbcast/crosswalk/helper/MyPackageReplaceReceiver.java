package com.mvbcast.crosswalk.helper;

import android.content.ActivityNotFoundException;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;

import com.mvbcast.crosswalk.EulaActivity;

import io.flutter.Log;

public class MyPackageReplaceReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        if (Intent.ACTION_MY_PACKAGE_REPLACED.equals(intent.getAction())) {
            if (isUpdatedSystemApp(context)) {
                try {
                    Intent activityIntent = new Intent(context, EulaActivity.class);
                    activityIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    context.startActivity(activityIntent);
                } catch (ActivityNotFoundException e) {
                    Log.d("BroadcastReceiver", "ActivityNotFoundException");
                }
            }
        }
    }

    private boolean isUpdatedSystemApp(Context context) {
        try {
            PackageManager pm = context.getPackageManager();
            ApplicationInfo ai = pm.getApplicationInfo(context.getPackageName(), 0);
            return (ai.flags & ApplicationInfo.FLAG_UPDATED_SYSTEM_APP) != 0;
        } catch (PackageManager.NameNotFoundException e) {
            return false;
        }
    }
}
