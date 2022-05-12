package com.mvbcast.crosswalk;


import androidx.annotation.NonNull;

import com.mvbcast.crosswalk.vbsota.SystemImageOTAHelper;
import com.mvbcast.crosswalk.view.WebRTCNativeViewFactory;

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
    }

    @Override
    protected void onDestroy() {
        SystemImageOTAHelper.getInstance().unregisterBroadcastReceiver(MainActivity.this);

        super.onDestroy();
    }

    public void setSystemOTAEnableUI(boolean enableUI) {
        mVbsOTA.invokeMethod("setSystemOTAEnableUI", enableUI);
    }

    public void setDownloadProgress(int progress) {
        mVbsOTA.invokeMethod("setDownloadProgress", progress);
    }
}
