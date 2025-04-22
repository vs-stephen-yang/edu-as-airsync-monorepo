package com.viewsonic.flutter_mirror;

import android.app.Activity;
import android.bluetooth.BluetoothDevice;
import android.content.Intent;
import android.os.Message;
import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.viewsonic.bluetooth.BluetoothAdapterController;
import com.viewsonic.bluetooth.BluetoothDeviceBondStateMonitor;
import com.viewsonic.bluetooth.BluetoothDeviceFinder;
import com.viewsonic.bluetooth.BluetoothDevicePairingHelper;
import com.viewsonic.bluetooth.BluetoothHidDeviceController;
import com.viewsonic.bluetooth.TouchToMouseConverter;
import com.viewsonic.util.State;
import com.viewsonic.util.StateMachine;

public class BluetoothTouchBackStateMachine extends StateMachine {

  private static final String TAG = "BluetoothTouchBackSM";
  private static final String NAME = "BluetoothTouchBackSM";

  private static final int EVENT_ON_AIRPLAY_STREAMING_STARTED = 1;
  private static final int EVENT_ON_AIRPLAY_STREAMING_STOPPED = 2;
  private static final int EVENT_ON_USER_TOUCH_SCREEN = 3;
  private static final int EVENT_ON_BLUETOOTH_DEVICE_FOUND = 4;
  private static final int EVENT_ON_BLUETOOTH_DEVICE_NOT_FOUND = 5;
  private static final int EVENT_ON_BLUETOOTH_DEVICE_PAIRING_SUCCESS = 6;
  private static final int EVENT_ON_BLUETOOTH_DEVICE_PAIRING_FAILED = 7;
  private static final int EVENT_ON_BLUETOOTH_HID_PROFILE_REGISTERED = 10;
  private static final int EVENT_ON_BLUETOOTH_HID_PROFILE_UNREGISTERED = 11;
  private static final int EVENT_ON_BLUETOOTH_HID_DEVICE_CONNECTED = 12;
  private static final int EVENT_ON_BLUETOOTH_HID_DEVICE_CONNECTING = 13;
  private static final int EVENT_ON_BLUETOOTH_HID_DEVICE_DISCONNECTED = 14;
  private static final int EVENT_ON_BLUETOOTH_HID_DEVICE_DISCONNECTING = 15;
  private static final int EVENT_ON_BLUETOOTH_REMOTE_DEVICE_UNPAIRED = 16;
  private static final int EVENT_ON_BLUETOOTH_ADAPTER_ENABLED_SUCCESS = 18;
  private static final int EVENT_ON_BLUETOOTH_ADAPTER_ENABLED_FAILURE = 19;
  private static final int EVENT_ON_BLUETOOTH_ADAPTER_UNSUPPORTED = 20;
  private static final int EVENT_ON_BLUETOOTH_ADAPTER_ENABLING = 21;

  private TouchBackNotInitialized touchBackNotInitialized = new TouchBackNotInitialized();
  private TouchBackInitialized touchBackInitialized = new TouchBackInitialized();
  private BluetoothAdapterNotChecked adapterNotChecked = new BluetoothAdapterNotChecked();
  private BluetoothAdapterChecking adapterChecking = new BluetoothAdapterChecking();
  private BluetoothAdapterEnabling adapterEnabling = new BluetoothAdapterEnabling();
  private BluetoothAdapterUnsupported adapterUnsupported = new BluetoothAdapterUnsupported();
  private BluetoothRemoteDeviceFinding remoteDeviceFinding = new BluetoothRemoteDeviceFinding();
  private BluetoothRemoteDeviceNotDetected remoteDeviceNotDetected = new BluetoothRemoteDeviceNotDetected();
  private BluetoothRemoteDeviceUnpaired remoteDeviceUnpaired = new BluetoothRemoteDeviceUnpaired();
  private BluetoothRemoteDevicePairing remoteDevicePairing = new BluetoothRemoteDevicePairing();
  private BluetoothRemoteDevicePairingFailed remoteDevicePairingFailed = new BluetoothRemoteDevicePairingFailed();
  private BluetoothRemoteDevicePaired remoteDevicePaired = new BluetoothRemoteDevicePaired();
  private BluetoothHidProfileServiceStopped profileServiceStopped = new BluetoothHidProfileServiceStopped();
  private BluetoothHidProfileServiceStarting profileServiceStarting = new BluetoothHidProfileServiceStarting();

  private String device;
  private Context context;
  private Activity activity;

  private volatile boolean isTouchBackEnabled = false;
  private volatile boolean isAirplayStreaming = false;

  private BluetoothDevice remoteDevice;
  private BluetoothAdapterController adapterController;
  private BluetoothHidDeviceController hidDeviceController;
  private BluetoothDeviceBondStateMonitor deviceBondStateMonitor;

  private final TouchToMouseConverter.TouchToMouseConverterListener touchToMouseConverterListener =
    report -> {
    if (!hidDeviceController.sendReport(report)) {
      Log.e(TAG, "Failed to send HID report");
    }
  };
  private TouchToMouseConverter touchToMouseConverter = new TouchToMouseConverter(touchToMouseConverterListener);

  private BluetoothHidDeviceController.BluetoothHidDeviceControllerListener btHidDeviceControllerListener =
    new BluetoothHidDeviceController.BluetoothHidDeviceControllerListener() {
      @Override
      public void onBluetoothHidProfileAppRegisteredChanged(boolean registered) {
        if (registered) {
          sendMessage(EVENT_ON_BLUETOOTH_HID_PROFILE_REGISTERED);
        } else {
          sendMessage(EVENT_ON_BLUETOOTH_HID_PROFILE_UNREGISTERED);
        }
      }

      @Override
      public void onBluetoothHidDeviceConnected() {
        sendMessage(EVENT_ON_BLUETOOTH_HID_DEVICE_CONNECTED);
      }

      @Override
      public void onBluetoothHidDeviceConnecting() {
        sendMessage(EVENT_ON_BLUETOOTH_HID_DEVICE_CONNECTING);
      }

      @Override
      public void onBluetoothHidDeviceDisconnected() {
        sendMessage(EVENT_ON_BLUETOOTH_HID_DEVICE_DISCONNECTED);
      }

      @Override
      public void onBluetoothHidDeviceDisconnecting() {
        sendMessage(EVENT_ON_BLUETOOTH_HID_DEVICE_DISCONNECTING);
      }
  };

  public interface StateCallback {
    void onStatus(BluetoothTouchBackStatus status, boolean needUserAction);
    void onError(Error error);
  }

  public enum Error {
    DEVICE_NAME_NULL_OR_EMPTY,
    UNABLE_TO_START_FINDING_DEVICE,
  }

  private StateCallback statusCallback;

  BluetoothTouchBackStateMachine(String name, Context context, Activity activity, StateCallback callback, boolean debug) {
    super(name);

    this.context = context;
    this.activity = activity;
    this.statusCallback = callback;
    this.adapterController = new BluetoothAdapterController();

    addState(touchBackNotInitialized);
    addState(touchBackInitialized);
    addState(adapterNotChecked);
    addState(adapterChecking);
    addState(adapterEnabling);
    addState(adapterUnsupported);
    addState(profileServiceStarting);
    addState(profileServiceStopped);
    addState(remoteDeviceFinding);
    addState(remoteDeviceNotDetected);
    addState(remoteDeviceUnpaired);
    addState(remoteDevicePairing);
    addState(remoteDevicePairingFailed);
    addState(remoteDevicePaired);

    setInitialState(touchBackNotInitialized);

    setDbg(debug);
  }

  public static BluetoothTouchBackStateMachine createStateMachine(Context context, Activity activity, StateCallback callback, boolean debug) {
    BluetoothTouchBackStateMachine sm = new BluetoothTouchBackStateMachine(NAME, context, activity, callback, debug);
    sm.start();
    return sm;
  }

  public void onMirrorStart(String device){
    this.device = device;
    sendMessage(BluetoothTouchBackStateMachine.EVENT_ON_AIRPLAY_STREAMING_STARTED);
  }

  public void onMirrorStop() {
    sendMessage(BluetoothTouchBackStateMachine.EVENT_ON_AIRPLAY_STREAMING_STOPPED);
  }

  public void onMirrorTouch(int touchId, boolean touch, double x, double y) {
    if (!isTouchBackEnabled) {
      sendMessage(EVENT_ON_USER_TOUCH_SCREEN);
    } else {
      touchToMouseConverter.touch(touchId, touch, x, y);
    }
  }

  public boolean onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
    if (adapterController.onActivityResult(requestCode, resultCode, data)) {
      return true;
    }
    return false;
  }

  public boolean onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
    if (isState(remoteDeviceFinding)) {
      remoteDeviceFinding.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }
    return false;
  }

  public void onActivityResumed() {
  }

  private BluetoothDeviceBondStateMonitor.BondStateCallback bondStateCallback = new BluetoothDeviceBondStateMonitor.BondStateCallback() {
    @Override
    public void onUnpaired(BluetoothDevice device) {
      sendMessage(EVENT_ON_BLUETOOTH_REMOTE_DEVICE_UNPAIRED);
    }

    @Override
    public void onACLDisconnected(BluetoothDevice device) {
      // should we handle this event? looks like it is unreliable
      //sendMessage(EVENT_ON_BLUETOOTH_ACL_DISCONNECTED);
    }
  };

  private void startMonitoringBondState(BluetoothDevice device) {
    if (deviceBondStateMonitor == null) {
      deviceBondStateMonitor = new BluetoothDeviceBondStateMonitor(context, bondStateCallback);
      deviceBondStateMonitor.start(device);
    }
  }

  private void stopMonitoringBondState() {
    if (deviceBondStateMonitor != null) {
      deviceBondStateMonitor.stop();
      deviceBondStateMonitor = null;
    }
  }

  private abstract class TransientState extends State {
    @Override
    public boolean processMessage(Message msg) {
      if (msg.what == EVENT_ON_AIRPLAY_STREAMING_STOPPED) {
        isAirplayStreaming = false;
        return HANDLED;
      }
      return NOT_HANDLED;
    }
  }

  private abstract class StableState extends State {
    @Override
    public void enter() {
      if (!isState(touchBackNotInitialized) && !isAirplayStreaming) {
        transitionTo(touchBackNotInitialized);
      }
    }

    @Override
    public boolean processMessage(Message msg) {
      Log.d(TAG, "StableState: " + getCurrentState().getName() + " msg: " + msg.what);

      // GLOBAL EVENTS
      switch (msg.what) {
        case EVENT_ON_AIRPLAY_STREAMING_STOPPED:
          if (!isState(touchBackNotInitialized)) {
            transitionTo(touchBackNotInitialized);
          }
          return HANDLED;

        case EVENT_ON_BLUETOOTH_HID_PROFILE_UNREGISTERED:
          transitionTo(profileServiceStopped);
          return HANDLED;

        case EVENT_ON_BLUETOOTH_REMOTE_DEVICE_UNPAIRED:
          transitionTo(remoteDeviceUnpaired);
          return HANDLED;
      }
      return NOT_HANDLED;
    }
  }

  private class TouchBackNotInitialized extends StableState {
    @Override
    public void enter() {
      super.enter();
    }

    @Override
    public boolean processMessage(Message msg) {
      if (super.processMessage(msg) == HANDLED) {
        return true;
      }
      switch (msg.what) {
        case EVENT_ON_AIRPLAY_STREAMING_STARTED:
          if (device == null || device.isEmpty()) {
            statusCallback.onError(Error.DEVICE_NAME_NULL_OR_EMPTY);
            return NOT_HANDLED;
          }
          isAirplayStreaming = true;
          transitionTo(adapterNotChecked);
          return HANDLED;
      }
      return NOT_HANDLED;
    }
  }

  private class TouchBackInitialized extends StableState {

    @Override
    public void enter() {
      super.enter();
      setTouchBackEnabled(true);
      statusCallback.onStatus(BluetoothTouchBackStatus.TOUCHBACK_INITIALIZED, false);
    }

    @Override
    public void exit() {
      super.exit();

      setTouchBackEnabled(false);
      hidDeviceController.stop();
    }

    @Override
    public boolean processMessage(Message msg) {
      if (super.processMessage(msg) == HANDLED) {
        return true;
      }
      return NOT_HANDLED;
    }

    private void setTouchBackEnabled(boolean enabled) {
      isTouchBackEnabled = enabled;
    }
  }

  private class BluetoothAdapterNotChecked extends StableState {
    @Override
    public void enter() {
      super.enter();
      statusCallback.onStatus(BluetoothTouchBackStatus.TOUCHBACK_INITIALIZING, true);
    }

    @Override
    public boolean processMessage(Message msg) {
      if (super.processMessage(msg) == HANDLED) {
        return true;
      }
      switch (msg.what) {
        case EVENT_ON_USER_TOUCH_SCREEN:
          transitionTo(adapterChecking);
          return HANDLED;
      }
      return NOT_HANDLED;
    }
  }

  private class BluetoothAdapterChecking extends TransientState {
    @Override
    public void enter() {
      super.enter();
      if (!adapterController.initialize(context)) {
        sendMessage(EVENT_ON_BLUETOOTH_ADAPTER_UNSUPPORTED);
      } else if (!adapterController.checkEnabled()) {
        sendMessage(EVENT_ON_BLUETOOTH_ADAPTER_ENABLING);
      } else {
        sendMessage(EVENT_ON_BLUETOOTH_ADAPTER_ENABLED_SUCCESS);
      }
    }

    @Override
    public boolean processMessage(Message msg) {
      if (super.processMessage(msg) == HANDLED) {
        return true;
      }
      switch (msg.what) {
        case EVENT_ON_BLUETOOTH_ADAPTER_UNSUPPORTED:
          transitionTo(adapterUnsupported);
          return HANDLED;

        case EVENT_ON_BLUETOOTH_ADAPTER_ENABLING:
          transitionTo(adapterEnabling);
          return HANDLED;

        case EVENT_ON_BLUETOOTH_ADAPTER_ENABLED_SUCCESS:
          transitionTo(profileServiceStarting);
          return HANDLED;
      }
      return NOT_HANDLED;
    }
  }

  private class BluetoothAdapterEnabling extends TransientState {
    private BluetoothAdapterController.BluetoothAdapterEnableCallback callback =
      success -> {
        if (success) {
          sendMessage(EVENT_ON_BLUETOOTH_ADAPTER_ENABLED_SUCCESS);
        } else {
          sendMessage(EVENT_ON_BLUETOOTH_ADAPTER_ENABLED_FAILURE);
        }
      };

    @Override
    public void enter() {
      super.enter();

      statusCallback.onStatus(BluetoothTouchBackStatus.BLUETOOTH_ADAPTER_ENABLING, false);
      adapterController.startRequestBluetoothAdapterEnable(activity, callback);
    }

    @Override
    public boolean processMessage(Message msg) {
      if (super.processMessage(msg) == HANDLED) {
        return true;
      }
      switch (msg.what) {
        case EVENT_ON_BLUETOOTH_ADAPTER_ENABLED_SUCCESS:
          statusCallback.onStatus(BluetoothTouchBackStatus.BLUETOOTH_ADAPTER_ENABLED_SUCCESS, false);
          transitionTo(profileServiceStarting);
          return HANDLED;

        case EVENT_ON_BLUETOOTH_ADAPTER_ENABLED_FAILURE:
          statusCallback.onStatus(BluetoothTouchBackStatus.BLUETOOTH_ADAPTER_ENABLED_FAILED, true);
          transitionTo(adapterNotChecked);
          return HANDLED;
      }
      return NOT_HANDLED;
    }
  }

  private class BluetoothAdapterUnsupported extends StableState {
    @Override
    public void enter() {
      super.enter();
      statusCallback.onStatus(BluetoothTouchBackStatus.BLUETOOTH_ADAPTER_UNSUPPORTED, true);
    }

    @Override
    public boolean processMessage(Message msg) {
      if (super.processMessage(msg) == HANDLED) {
        return true;
      }
      switch (msg.what) {
        case EVENT_ON_USER_TOUCH_SCREEN:
          transitionTo(adapterChecking);
          return HANDLED;
      }
      return NOT_HANDLED;
    }
  }

  private class BluetoothAdapterEnabled extends StableState  {
    @Override
    public void enter() {
      super.enter();
    }

    @Override
    public boolean processMessage(Message msg) {
      if (super.processMessage(msg) == HANDLED) {
        return true;
      }
      switch (msg.what) {
        case EVENT_ON_AIRPLAY_STREAMING_STOPPED:
          transitionTo(touchBackNotInitialized);
          return HANDLED;

        case EVENT_ON_BLUETOOTH_HID_PROFILE_REGISTERED:
          transitionTo(remoteDeviceFinding);
          return HANDLED;

        case EVENT_ON_BLUETOOTH_HID_PROFILE_UNREGISTERED:
          return HANDLED;
      }
      return NOT_HANDLED;
    }
  }

  private class BluetoothHidProfileServiceStopped extends StableState {
    @Override
    public void enter() {
      super.enter();
    }

    @Override
    public boolean processMessage(Message msg) {
      if (super.processMessage(msg) == HANDLED) {
        return true;
      }
      switch (msg.what) {
        case EVENT_ON_USER_TOUCH_SCREEN:
          transitionTo(profileServiceStarting);
          return HANDLED;
      }
      return false;
    }
  }

  private class BluetoothHidProfileServiceStarting extends TransientState {
    @Override
    public void enter() {
      super.enter();
      if (hidDeviceController == null) {
        hidDeviceController = new BluetoothHidDeviceController(
          context, adapterController.getBluetoothAdapter(), btHidDeviceControllerListener);
      }
      statusCallback.onStatus(BluetoothTouchBackStatus.BLUETOOTH_HID_PROFILE_SERVICE_STARTING, false);
      hidDeviceController.stop();
      hidDeviceController.start();
    }

    @Override
    public boolean processMessage(Message msg) {
      if (super.processMessage(msg) == HANDLED) {
        return true;
      }
      switch (msg.what) {
        case EVENT_ON_BLUETOOTH_HID_PROFILE_REGISTERED:
          statusCallback.onStatus(BluetoothTouchBackStatus.BLUETOOTH_HID_PROFILE_SERVICE_STARTED_SUCCESS, false);
          transitionTo(remoteDeviceFinding);
          return HANDLED;

        case EVENT_ON_BLUETOOTH_HID_PROFILE_UNREGISTERED:
          statusCallback.onStatus(BluetoothTouchBackStatus.BLUETOOTH_HID_PROFILE_SERVICE_STARTED_FAILED, false);
          transitionTo(profileServiceStopped);
          return HANDLED;
      }
      return NOT_HANDLED;
    }
  }

  private class BluetoothRemoteDeviceFinding extends TransientState {
    private BluetoothDeviceFinder btDeviceFinder;

    private BluetoothDeviceFinder.BluetoothDeviceFinderListener listener =
      new BluetoothDeviceFinder.BluetoothDeviceFinderListener() {

        @Override
        public void onPermissionGranted() {
          startFindingDevice();
        }

        @Override
        public void onPermissionDenied() {
          transitionTo(profileServiceStarting);
        }

        @Override
        public void onBluetoothDeviceFound(BluetoothDevice device) {
          statusCallback.onStatus(BluetoothTouchBackStatus.BLUETOOTH_DEVICE_FOUND_SUCCESS, false);
          remoteDevice = device;
          sendMessage(EVENT_ON_BLUETOOTH_DEVICE_FOUND);
        }

        @Override
        public void onBluetoothDeviceNotFound() {
          sendMessage(EVENT_ON_BLUETOOTH_DEVICE_NOT_FOUND);
        }
      };

    @Override
    public void enter() {
      super.enter();

      stopMonitoringBondState();
      btDeviceFinder = new BluetoothDeviceFinder(context, activity, adapterController.getBluetoothAdapter(), listener);
      if (btDeviceFinder.checkPermissions()) {
        startFindingDevice();
      }
    }

    @Override
    public boolean processMessage(Message msg) {
      if (super.processMessage(msg) == HANDLED) {
        return true;
      }
      switch (msg.what) {
        case EVENT_ON_BLUETOOTH_DEVICE_FOUND:
          transitionTo(remoteDevicePairing);
          return HANDLED;

        case EVENT_ON_BLUETOOTH_DEVICE_NOT_FOUND:
          transitionTo(remoteDeviceNotDetected);
          return HANDLED;
      }
      return NOT_HANDLED;
    }

    private void startFindingDevice() {
      statusCallback.onStatus(BluetoothTouchBackStatus.BLUETOOTH_DEVICE_FINDING, false);
      if (!btDeviceFinder.startFindingDevice(device)) {
        statusCallback.onError(Error.UNABLE_TO_START_FINDING_DEVICE);
      }
    }

    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
      if (btDeviceFinder != null) {
        btDeviceFinder.onRequestPermissionsResult(requestCode, permissions, grantResults);
      }
    }
  }

  private class BluetoothRemoteDeviceNotDetected extends StableState {
    @Override
    public void enter() {
      super.enter();
      statusCallback.onStatus(BluetoothTouchBackStatus.BLUETOOTH_DEVICE_FOUND_FAILED, true);
    }

    @Override
    public boolean processMessage(Message msg) {
      if (super.processMessage(msg) == HANDLED) {
        return true;
      }
      switch (msg.what) {
        case EVENT_ON_USER_TOUCH_SCREEN:
          transitionTo(profileServiceStarting);
          return HANDLED;
      }
      return NOT_HANDLED;
    }
  }

  private class BluetoothRemoteDeviceUnpaired extends StableState {
    @Override
    public void enter() {
      super.enter();
      statusCallback.onStatus(BluetoothTouchBackStatus.BLUETOOTH_DEVICE_UNPAIRED, true);
    }

    @Override
    public boolean processMessage(Message msg) {
      if (super.processMessage(msg) == HANDLED) {
        return true;
      }
      switch (msg.what) {
        case EVENT_ON_USER_TOUCH_SCREEN:
          transitionTo(profileServiceStarting);
          return HANDLED;
      }
      return NOT_HANDLED;
    }
  }

  private class BluetoothRemoteDevicePairing extends TransientState {

    private BluetoothDevicePairingHelper btDevicePairingHelper;

    private BluetoothDevicePairingHelper.PairingCallback callback = new BluetoothDevicePairingHelper.PairingCallback() {
      @Override
      public void onPairingSuccess(boolean alreadyPaired) {
        sendMessage(EVENT_ON_BLUETOOTH_DEVICE_PAIRING_SUCCESS, alreadyPaired);
      }

      @Override
      public void onPairingFailed() {
        sendMessage(EVENT_ON_BLUETOOTH_DEVICE_PAIRING_FAILED);
      }
    };

    @Override
    public void enter() {
      super.enter();

      btDevicePairingHelper = new BluetoothDevicePairingHelper(context, remoteDevice);
      statusCallback.onStatus(BluetoothTouchBackStatus.BLUETOOTH_DEVICE_PAIRING, false);
      btDevicePairingHelper.startPairing(callback);
    }

    @Override
    public void exit() {
      super.exit();

      btDevicePairingHelper.stop();
    }

    @Override
    public boolean processMessage(Message msg) {
      if (super.processMessage(msg) == HANDLED) {
        return true;
      }
      switch (msg.what) {
        case EVENT_ON_BLUETOOTH_DEVICE_PAIRING_SUCCESS:
          hidDeviceController.setHostDevice(remoteDevice);
          transitionTo(remoteDevicePaired);
          return HANDLED;

        case EVENT_ON_BLUETOOTH_DEVICE_PAIRING_FAILED:
          transitionTo(remoteDevicePairingFailed);
          return HANDLED;
      }
      return NOT_HANDLED;
    }
  }

  private class BluetoothRemoteDevicePairingFailed extends StableState {
    @Override
    public void enter() {
      super.enter();
      statusCallback.onStatus(BluetoothTouchBackStatus.BLUETOOTH_DEVICE_PAIRED_FAILED, true);
    }

    @Override
    public boolean processMessage(Message msg) {
      if (super.processMessage(msg) == HANDLED) {
        return true;
      }
      switch (msg.what) {
        case EVENT_ON_USER_TOUCH_SCREEN:
          transitionTo(remoteDevicePairing);
          return HANDLED;
      }
      return NOT_HANDLED;
    }
  }

  private class BluetoothRemoteDevicePaired extends StableState {
    private boolean needReconnect = false;

    @Override
    public void enter() {
      super.enter();

      needReconnect = false;
      statusCallback.onStatus(BluetoothTouchBackStatus.BLUETOOTH_DEVICE_PAIRED_SUCCESS, false);
      hidDeviceController.connect();
    }

    @Override
    public boolean processMessage(Message msg) {
      if (super.processMessage(msg) == HANDLED) {
        return true;
      }
      switch (msg.what) {
        case EVENT_ON_USER_TOUCH_SCREEN:
          if (needReconnect) {
            needReconnect = false;
            hidDeviceController.connect();
            return HANDLED;
          }
          return NOT_HANDLED;

        case EVENT_ON_BLUETOOTH_HID_DEVICE_CONNECTING:
          // How long ??
          statusCallback.onStatus(BluetoothTouchBackStatus.BLUETOOTH_HID_CONNECTING, false);
          return HANDLED;

        case EVENT_ON_BLUETOOTH_HID_DEVICE_CONNECTED:
          statusCallback.onStatus(BluetoothTouchBackStatus.BLUETOOTH_HID_CONNECTED, false);
          startMonitoringBondState(remoteDevice); // monitor remote device bond state
          transitionTo(touchBackInitialized);
          return HANDLED;

        case EVENT_ON_BLUETOOTH_HID_DEVICE_DISCONNECTING:
          statusCallback.onStatus(BluetoothTouchBackStatus.BLUETOOTH_HID_DISCONNECTING, false);
          return HANDLED;

        case EVENT_ON_BLUETOOTH_HID_DEVICE_DISCONNECTED:
          statusCallback.onStatus(BluetoothTouchBackStatus.BLUETOOTH_HID_DISCONNECTED, true);
          needReconnect = true;
          return HANDLED;
      }
      return NOT_HANDLED;
    }
  }
}
