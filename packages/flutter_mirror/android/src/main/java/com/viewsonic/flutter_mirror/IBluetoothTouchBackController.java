package com.viewsonic.flutter_mirror;

import android.app.Application;

import androidx.lifecycle.LifecycleObserver;

import io.flutter.plugin.common.PluginRegistry;

public interface IBluetoothTouchBackController {
  boolean onMirrorStart(String mirrorId, String deviceName, String mirrorType);
  boolean onMirrorStop(String mirrorId);
  boolean onMirrorTouch(String mirrorId, int touchId, boolean touch, double x, double y);
  PluginRegistry.ActivityResultListener getActivityResultListener();
  PluginRegistry.RequestPermissionsResultListener getRequestPermissionsResultListener();
  Application.ActivityLifecycleCallbacks getActivityLifecycleCallbacks();
}
