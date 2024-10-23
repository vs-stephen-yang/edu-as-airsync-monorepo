package com.viewsonic.display.cast;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        BinaryMessenger binaryMessenger = flutterEngine.getDartExecutor().getBinaryMessenger();
        MethodChannel androidRetain = new MethodChannel(binaryMessenger, "com.viewsonic.display.cast/android_app_retain");
        androidRetain.setMethodCallHandler((call, result) -> {
            if (call.method.equals("sendToBackground")) {
                moveTaskToBack(true);
                result.success(null);
            } else {
                result.notImplemented();
            }
        });
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "com.viewsonic.display.cast/window_manager")
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("minimizeWindow")) {
                                moveTaskToBack(true);
                                result.success(null);
                            } else {
                                result.notImplemented();
                            }
                        }
                );
    }
}
