package com.mvbcast.crosswalk;


import androidx.annotation.NonNull;

import com.mvbcast.crosswalk.view.WebRTCNativeViewFactory;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.BinaryMessenger;

public class MainActivity extends FlutterActivity {
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        BinaryMessenger binaryMessenger = flutterEngine.getDartExecutor().getBinaryMessenger();

        flutterEngine
                .getPlatformViewsController()
                .getRegistry()
                .registerViewFactory("com.mvbcast.crosswalk/webrtc_native_view",
                        new WebRTCNativeViewFactory(this, binaryMessenger));
    }
}
