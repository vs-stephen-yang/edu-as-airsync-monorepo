package com.mvbcast.crosswalk.helper;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import com.mvbcast.crosswalk.EulaActivity;

public class MyPackageReplaceReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        if (Intent.ACTION_MY_PACKAGE_REPLACED.equals(intent.getAction())) {
            Intent activityIntent = new Intent(context, EulaActivity.class);
            activityIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(activityIntent);
        }
    }
}
