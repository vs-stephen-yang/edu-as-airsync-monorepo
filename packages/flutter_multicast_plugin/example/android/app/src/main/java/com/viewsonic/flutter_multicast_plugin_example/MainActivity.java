package com.viewsonic.flutter_multicast_plugin_example;

import io.flutter.embedding.android.FlutterActivity;
import android.content.Context;
import android.net.wifi.WifiManager;
import android.os.Bundle;

public class MainActivity extends FlutterActivity {
    private WifiManager.MulticastLock multicastLock;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // 取得 WifiManager
        WifiManager wifiManager = (WifiManager) getApplicationContext().getSystemService(Context.WIFI_SERVICE);

        // 建立並 acquire MulticastLock
        if (wifiManager != null) {
            multicastLock = wifiManager.createMulticastLock("multicast_lock");
            multicastLock.setReferenceCounted(false);
            multicastLock.acquire();
        }
    }

    @Override
    protected void onDestroy() {
        if (multicastLock != null) {
            multicastLock.release();
        }
        super.onDestroy();
    }
}
