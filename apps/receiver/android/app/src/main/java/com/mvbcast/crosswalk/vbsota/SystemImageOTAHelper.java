package com.mvbcast.crosswalk.vbsota;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.os.Build;
import android.os.Bundle;
import android.os.IBinder;
import android.util.Log;

import com.mvbcast.crosswalk.EulaActivity;

public class SystemImageOTAHelper {
    // region Singleton Implementation
    // https://android.jlelse.eu/how-to-make-the-perfect-singleton-de6b951dfdb0
    //-------------------------------------------------------------------------
    private static volatile SystemImageOTAHelper INSTANCE = null;

    // private constructor.
    private SystemImageOTAHelper() {
        // Prevent form the reflection api.
        if (INSTANCE != null) {
            throw new RuntimeException("Use getInstance() method to get the single instance of this class.");
        }
    }

    public static SystemImageOTAHelper getInstance() {
        // Double check locking pattern
        if (INSTANCE == null) {// Check for the first time
            synchronized (SystemImageOTAHelper.class) {// Check for the second time.
                // if there is no instance available... create new one
                if (INSTANCE == null) INSTANCE = new SystemImageOTAHelper();
            }
        }
        return INSTANCE;
    }
    //-------------------------------------------------------------------------
    // endregion Singleton Implementation

    // region public Implementation
    //-------------------------------------------------------------------------
    public void registerBroadcastReceiver(Activity activity) {
        if (Build.MODEL.equals("VBS100")) {
            if (mBroadCastReceiver == null) {
                mBroadCastReceiver = new BroadCastReceiver();
            }
            activity.getApplicationContext().registerReceiver(mBroadCastReceiver, new IntentFilter("com.mvbcast.download.progress"));

            if (mDownloadBinder == null) {
                Intent intent = new Intent(activity, UpgradeVersionService.class);
                activity.getApplicationContext().startService(intent);
                activity.getApplicationContext().bindService(intent, mConnection, Context.BIND_AUTO_CREATE);
                bindOTAConnection = true;
            }
        }
    }

    public void unregisterBroadcastReceiver(Activity activity) {
        if (Build.MODEL.equals("VBS100")) {
            if (mBroadCastReceiver != null) {
                try {
                    activity.getApplicationContext().unregisterReceiver(mBroadCastReceiver);
                } catch (Exception e) {
                    Log.w("SystemImageOTAHelper", "Receiver has already been unregistered.");
                }
                mBroadCastReceiver = null;
            }

            if (bindOTAConnection) {
                bindOTAConnection = false;
                try {
                    activity.getApplicationContext().unbindService(mConnection);
                } catch (Exception e) {
                    Log.w("SystemImageOTAHelper", "ServiceConnection has already been unbind.");
                }
            }
        }
    }

    public static class BroadCastReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            Bundle extras = intent.getExtras();
            if (extras != null) {
                if (extras.containsKey("type") && extras.containsKey("value")) {
                    Object typeObj = extras.get("type");
                    Object valueObj = extras.get("value");
                    if (context instanceof EulaActivity && typeObj instanceof String && valueObj instanceof String) {
                        EulaActivity activity = (EulaActivity) context;
                        String type = (String) typeObj;
                        String value = (String) valueObj;
                        if (type.equals("isUpdate")) {
                            if (!value.equals("uptodate")) {
                                activity.setSystemOTAEnableUI(true);
                            }
                        } else if (type.equals("onDownloadProgress")) {
                            int progress =
                                    Integer.parseInt(value.substring(value.indexOf(":") + 1, value.indexOf(",")));
                            activity.setDownloadProgress(progress);
                        }
                    }
                }
            }
        }
    }
    //-------------------------------------------------------------------------
    // endregion public Implementation

    // region private Implementation
    //-------------------------------------------------------------------------
    private BroadCastReceiver mBroadCastReceiver;

    private UpgradeVersionService.DownloadBinder mDownloadBinder;

    private boolean bindOTAConnection = false;

    private final ServiceConnection mConnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            if (service instanceof UpgradeVersionService.DownloadBinder) {
                mDownloadBinder = (UpgradeVersionService.DownloadBinder) service;
                mDownloadBinder.startDownload();
            }
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
            mDownloadBinder = null;
        }
    };
    //-------------------------------------------------------------------------
    // endregion private Implementation
}
