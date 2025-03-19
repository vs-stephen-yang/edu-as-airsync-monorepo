package com.viewsonic.display.cast;

import android.content.Intent;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.LifecycleOwner;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import qiuxiang.android_window.WindowService;

public class MainActivity extends FlutterActivity implements DefaultLifecycleObserver{
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
        getLifecycle().addObserver(this);
    }

    @Override
    public void onDestroy(@NonNull LifecycleOwner owner) {
        boolean windowServiceRunning = FlutterEngineCache.getInstance().get("flutter-android-window") != null;
        if (windowServiceRunning) {
            MainActivity.this.stopService(new Intent(MainActivity.this, WindowService.class));
        }
        DefaultLifecycleObserver.super.onDestroy(owner);
    }

    @Override
    protected void onDestroy() {
        getLifecycle().removeObserver(this);
        super.onDestroy();
    }
}
