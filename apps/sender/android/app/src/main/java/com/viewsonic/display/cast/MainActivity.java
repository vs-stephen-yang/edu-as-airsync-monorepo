package com.viewsonic.display.cast;

import android.content.Intent;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.LifecycleOwner;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import qiuxiang.android_window.WindowService;

public class MainActivity extends FlutterActivity implements DefaultLifecycleObserver {
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        BinaryMessenger binaryMessenger = flutterEngine.getDartExecutor().getBinaryMessenger();

        new MethodChannel(binaryMessenger, "com.viewsonic.display.cast/android_app_retain")
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("sendToBackground")) {
                        moveTaskToBack(true);
                        result.success(null);
                    } else {
                        result.notImplemented();
                    }
                });

        new MethodChannel(binaryMessenger, "com.viewsonic.display.cast/window_manager")
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("minimizeWindow")) {
                        moveTaskToBack(true);
                        result.success(null);
                    } else {
                        result.notImplemented();
                    }
                });

        new MethodChannel(binaryMessenger, "com.viewsonic.display.cast/system_ui_insets")
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("getNavigationBarLeftInset")) {
                        double inset = getNavigationBarLeftInset();
                        result.success(inset);
                    } else {
                        result.notImplemented();
                    }
                });

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

    private double getNavigationBarLeftInset() {
        View decorView = getWindow().getDecorView();
        WindowInsetsCompat insets = ViewCompat.getRootWindowInsets(decorView);
        if (insets == null) return 0;

        Insets navInsets = insets.getInsets(WindowInsetsCompat.Type.navigationBars());
        return navInsets.left;
    }
}
