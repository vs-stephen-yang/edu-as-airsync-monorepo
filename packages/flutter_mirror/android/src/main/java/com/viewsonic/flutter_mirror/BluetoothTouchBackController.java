package com.viewsonic.flutter_mirror;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.plugin.common.PluginRegistry;

public class BluetoothTouchBackController
  implements IBluetoothTouchBackController, BluetoothTouchBackStateMachine.StateCallback  {

  private static final String TAG = "BTTouchBackController";
  private static final String SUPPORTED_MIRROR_TYPE = "airplay";

  private final BluetoothTouchBackStateMachine sm;
  private String activeMirrorId = null;
  private Context context;
  private Toast toast;

  public BluetoothTouchBackController(Context context, Activity activity, boolean debug) {
    this.context = context;
    this.sm = BluetoothTouchBackStateMachine.createStateMachine(context, activity, this, debug);
  }

  @Override
  public boolean onMirrorStart(String mirrorId, String deviceName, String mirrorType) {
    if (!SUPPORTED_MIRROR_TYPE.equals(mirrorType)) {
      logDebug("Unsupported mirror type: " + mirrorType);
      return false;
    }

    if (activeMirrorId != null) {
      logWarning("Another mirror is already active: " + activeMirrorId);
      return false;
    }

    activeMirrorId = mirrorId;
    sm.onMirrorStart(deviceName);
    logDebug("Mirror started: " + mirrorId);
    return true;
  }

  @Override
  public boolean onMirrorStop(String mirrorId) {
    if (activeMirrorId == null || !activeMirrorId.equals(mirrorId)) {
      return false;
    }

    activeMirrorId = null;
    sm.onMirrorStop();
    logDebug("Mirror stopped: " + mirrorId);
    return true;
  }

  @Override
  public boolean onMirrorTouch(String mirrorId, int touchId, boolean touch, double x, double y) {
     if (activeMirrorId != null && activeMirrorId.equals(mirrorId)) {
       sm.onMirrorTouch(touchId, touch, x, y);
       return true;
     }
     return false;
  }

  @Override
  public PluginRegistry.ActivityResultListener getActivityResultListener() {
    return new ActivityResultListenerImpl(sm);
  }

  @Override
  public PluginRegistry.RequestPermissionsResultListener getRequestPermissionsResultListener() {
    return new RequestPermissionsResultListenerImpl(sm);
  }

  @Override
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
  public void onStatus(BluetoothTouchBackStateMachine.Status status, boolean userActionRequired) {
    String message;
    switch (status) {
      case TOUCHBACK_INITIALIZING:
        message = "TouchBack initializing...";
        break;
      case BLUETOOTH_ADAPTER_ENABLING:
        message = "Enabling Bluetooth adapter...";
        break;
      case BLUETOOTH_ADAPTER_ENABLE_SUCCESS:
        message = "Bluetooth adapter enabled.";
        break;
      case BLUETOOTH_ADAPTER_ENABLE_FAILED:
        message = "Enable Bluetooth adapter failed.";
        break;
      case BLUETOOTH_ADAPTER_UNSUPPORTED:
        message = "Bluetooth adapter unavailable. Please insert Bluetooth Adapter. Then ";
        break;
      case BLUETOOTH_DEVICE_FINDING:
        message = "Finding Bluetooth device...";
        break;
      case BLUETOOTH_DEVICE_FOUND_SUCCESS:
        message = "Bluetooth device found successfully.";
        break;
      case BLUETOOTH_DEVICE_FOUND_FAILED:
        message = "Device found failed. Please make sure your device's Bluetooth is on. Then";
        break;
      case BLUETOOTH_DEVICE_PAIRING:
        message = "Pairing Bluetooth device...";
        break;
      case BLUETOOTH_DEVICE_PAIRED_SUCCESS:
        message = "Bluetooth device paired successfully.";
        break;
      case BLUETOOTH_DEVICE_PAIRED_FAILED:
        message = "Bluetooth Device pairing failed.";
        break;
      case BLUETOOTH_DEVICE_UNPAIRED:
        message = "Bluetooth Device unpaired.";
        break;
      case BLUETOOTH_HID_CONNECTING:
        message = "Connecting Bluetooth HID...";
        break;
      case BLUETOOTH_HID_CONNECTED:
        message = "Bluetooth HID connected.";
        break;
      case BLUETOOTH_HID_DISCONNECTING:
        message = "Disconnecting Bluetooth HID...";
        break;
      case BLUETOOTH_HID_DISCONNECTED:
        message = "Bluetooth HID disconnected.";
        break;
      case BLUETOOTH_HID_PROFILE_SERVICE_STARTING:
        message = "Starting Bluetooth HID profile service...";
        break;
      case TOUCHBACK_INITIALIZED:
        message = "TouchBack initialized. You can now use TouchBack feature.";
        break;
      default:
        message = "Unknown status";
        break;
    }
    if (userActionRequired) {
      message += " Touch screen to enable TouchBack feature.";
    }

    if (toast != null) {
      toast.cancel();
    }
    toast = Toast.makeText(context, message, Toast.LENGTH_LONG);
    toast.show();
  }

  @Override
  public void onError(BluetoothTouchBackStateMachine.Error error) {
    String message;
    switch (error) {
      case DEVICE_NAME_NULL_OR_EMPTY:
        message = "Device name is null or empty.";
        break;
      case UNABLE_TO_START_FINDING_DEVICE:
        message = "Unable to start finding device.";
        break;
      default:
        message = "Unknown error";
        break;
    }
    if (toast != null) {
      toast.cancel();
    }
    toast = Toast.makeText(context, message, Toast.LENGTH_LONG);
    toast.show();
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
