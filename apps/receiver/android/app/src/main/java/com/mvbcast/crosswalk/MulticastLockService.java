package com.mvbcast.crosswalk;

import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.net.wifi.WifiManager;
import android.os.IBinder;

public class MulticastLockService extends Service {
    private WifiManager.MulticastLock multicastLock;

    @Override
    public void onCreate() {
        super.onCreate();
        ensureMulticastLock();
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        ensureMulticastLock();
        return START_STICKY;
    }

    @Override
    public void onDestroy() {
        if (multicastLock != null) {
            if (multicastLock.isHeld()) {
                multicastLock.release();
            }
            multicastLock = null;
        }
        super.onDestroy();
    }

    private void ensureMulticastLock() {
        try {
            WifiManager wifiManager =
                    (WifiManager) getApplicationContext().getSystemService(Context.WIFI_SERVICE);
            if (wifiManager == null) {
                return;
            }
            if (multicastLock == null) {
                // Keep multicast enabled for discovery traffic.
                multicastLock = wifiManager.createMulticastLock("multicast_lock");
                multicastLock.setReferenceCounted(false);
            }
            if (!multicastLock.isHeld()) {
                multicastLock.acquire();
            }
        } catch (SecurityException ignored) {
            // Ignore if permission is missing on specific builds.
        }
    }
}
