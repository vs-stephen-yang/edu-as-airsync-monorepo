package com.viewsonic.flutter_mirror;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.PluginRegistry;

public class BluetoothTouchBackController
  implements BluetoothTouchBackStateMachine.StateCallback  {

  private static final String TAG = "BTTouchBackController";
  private static final String SUPPORTED_MIRROR_TYPE = "airplay";

  private final BluetoothTouchBackStateMachine sm;
  private final Map<String, String> activeMirrors = new HashMap<>();
  private String currentTouchbackMirrorId = null;
  private BluetoothTouchBackListener listener;

  public BluetoothTouchBackController(
    Context context, Activity activity, BluetoothTouchBackListener listener, boolean debug) {
    this.sm = BluetoothTouchBackStateMachine.createStateMachine(context, activity, this, debug);
    this.listener = listener;
  }

  public boolean onMirrorStart(String mirrorId, String deviceName, String mirrorType) {
    if (!SUPPORTED_MIRROR_TYPE.equals(mirrorType)) {
      logDebug("Unsupported mirror type: " + mirrorType);
      return false;
    }

    if (activeMirrors.containsKey(mirrorId)) {
      logWarning("Mirror already started: " + mirrorId);
      return false;
    }

    activeMirrors.put(mirrorId, deviceName);
    logDebug("Mirror started: " + mirrorId);
    return true;
  }

  public boolean onMirrorStop(String mirrorId) {
    if (!activeMirrors.containsKey(mirrorId)) {
      return false;
    }

    if (mirrorId.equals(currentTouchbackMirrorId)) {
      sm.enableTouchback(false);
      currentTouchbackMirrorId = null;
      logDebug("Disabled touchback for: " + mirrorId);
    }

    activeMirrors.remove(mirrorId);
    logDebug("Mirror stopped: " + mirrorId);
    return true;
  }

  public boolean onMirrorTouch(String mirrorId, int touchId, boolean touch, double x, double y) {
    if (mirrorId.equals(currentTouchbackMirrorId)) {
      sm.onMirrorTouch(touchId, touch, x, y);
      return true;
    }
     return false;
  }

  public boolean enableTouchback(String mirrorId, boolean enable) {
    if (!activeMirrors.containsKey(mirrorId)) {
      logWarning("Mirror not active: " + mirrorId);
      return false;
    }

    if (enable) {
      if (currentTouchbackMirrorId != null) {
        logWarning("Touchback already enabled for: " + currentTouchbackMirrorId);
        return false;
      }
      if (currentTouchbackMirrorId == null) {
        currentTouchbackMirrorId = mirrorId;
        sm.onMirrorStart(activeMirrors.get(mirrorId));
        sm.enableTouchback(true);
        logDebug("Enabled touchback for: " + mirrorId);
        return true;
      }
    } else {
      if (currentTouchbackMirrorId != null && currentTouchbackMirrorId.equals(mirrorId)) {
        sm.enableTouchback(false);
        logDebug("Disabled touchback for: " + mirrorId);
        currentTouchbackMirrorId = null;
        return true;
      }
    }
    return false;
  }

  public PluginRegistry.ActivityResultListener getActivityResultListener() {
    return new ActivityResultListenerImpl(sm);
  }

  public PluginRegistry.RequestPermissionsResultListener getRequestPermissionsResultListener() {
    return new RequestPermissionsResultListenerImpl(sm);
  }

  public Application.ActivityLifecycleCallbacks getActivityLifecycleCallbacks() {
    return new ActivityLifecycleCallbacksImpl(sm);
  }

  private static void logDebug(String message) {
    Log.d(TAG, message);
  }

  private static void logWarning(String message) {
    Log.w(TAG, message);
  }

  @Override
  public void onStatus(BluetoothTouchBackStatus status, boolean userActionRequired) {
    Log.d(TAG, "Status: " + status + ", userActionRequired: " + userActionRequired);
    listener.onBluetoothTouchBackStatus(status);
  }

  @Override
  public void onError(BluetoothTouchBackStateMachine.Error error) {
    Log.e(TAG, "Error: " + error);
  }

  private static class ActivityResultListenerImpl implements PluginRegistry.ActivityResultListener {
    private final BluetoothTouchBackStateMachine sm;

    ActivityResultListenerImpl(BluetoothTouchBackStateMachine sm) {
      this.sm = sm;
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
      return sm.onActivityResult(requestCode, resultCode, data);
    }
  }

  private static class RequestPermissionsResultListenerImpl implements PluginRegistry.RequestPermissionsResultListener {
    private final BluetoothTouchBackStateMachine sm;

    RequestPermissionsResultListenerImpl(BluetoothTouchBackStateMachine sm) {
      this.sm = sm;
    }

    @Override
    public boolean onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
      return sm.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }
  }

  private static class ActivityLifecycleCallbacksImpl implements Application.ActivityLifecycleCallbacks {
    private final BluetoothTouchBackStateMachine sm;

    ActivityLifecycleCallbacksImpl(BluetoothTouchBackStateMachine sm) {
      this.sm = sm;
    }

    @Override
    public void onActivityCreated(@NonNull Activity activity, @Nullable Bundle bundle) {}

    @Override
    public void onActivityStarted(@NonNull Activity activity) {}

    @Override
    public void onActivityResumed(Activity activity) {
      sm.onActivityResumed();
    }

    @Override
    public void onActivityPaused(@NonNull Activity activity) {}

    @Override
    public void onActivityStopped(@NonNull Activity activity) {}

    @Override
    public void onActivitySaveInstanceState(@NonNull Activity activity, @NonNull Bundle bundle) {}

    @Override
    public void onActivityDestroyed(@NonNull Activity activity) {}
  }
}
