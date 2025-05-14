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

/**
 * BluetoothTouchBackStateMachine - State machine to manage the Bluetooth TouchBack feature.
 * This state machine handles the entire Bluetooth touchback process, including:
 * - Detecting and enabling Bluetooth Adapter
 * - Registering the Bluetooth HID profile service
 * - Discovering the target Bluetooth device
 * - Pairing with the device
 * - Establishing the HID connection
 * - Enabling touch back functionality
 * <p>
 * State Flow: (Simplified)
 * ┌─────────────────────┐      ┌─────────────────┐      ┌─────────────────┐
 * │    Touch Back       │      │ Check Bluetooth │      │   HID Profile   │
 * │  Not Initialized    │─────>│     Adapter     │─────>│    Service      │
 * └─────────────────────┘      └─────────────────┘      └─────────────────┘
 *                                                                │
 *                                                                │
 *                                                                ▼
 *                                                       ┌─────────────────┐
 *                                                       │   Find Remote   │
 *                                                       │     Device      │
 *                                                       └─────────────────┘
 *                                                                │
 *                                                                │
 *                                                                ▼
 * ┌─────────────────────┐      ┌─────────────────┐      ┌─────────────────┐
 * │    Touch Back       │      │   Connect HID   │      │   Pair Remote   │
 * │    Initialized      │<─────│ to Remote Device│<─────│     Device      │
 * └─────────────────────┘      └─────────────────┘      └─────────────────┘
 * <p>
 * Global Events:
 * - Airplay streaming stopped: Return to initial state
 * - HID profile unregistered: Transition to ProfileServiceStopped
 * - Remote device unpaired: Transition to RemoteDeviceUnpaired
 */
public class BluetoothTouchBackStateMachine extends StateMachine {

  private static final String TAG = "BluetoothTouchBackSM";
  private static final String NAME = "BluetoothTouchBackSM";

  private static final int EVENT_GROUP_USER = 100;  // User events
  private static final int EVENT_GROUP_AIRPLAY = 200; // Airplay events
  private static final int EVENT_GROUP_BT_DEVICE = 300; // Bluetooth device events
  private static final int EVENT_GROUP_BT_HID = 400; // Bluetooth HID events
  private static final int EVENT_GROUP_BT_ADAPTER = 500; // Bluetooth adapter events

  // User events
  private static final int EVENT_ON_USER_ENABLE_TOUCH = EVENT_GROUP_USER + 1;
  private static final int EVENT_ON_USER_DISABLE_TOUCH = EVENT_GROUP_USER + 2;

  // Airplay events
  private static final int EVENT_ON_AIRPLAY_STREAMING_STARTED = EVENT_GROUP_AIRPLAY + 1;
  private static final int EVENT_ON_AIRPLAY_STREAMING_STOPPED = EVENT_GROUP_AIRPLAY + 2;

  // Bluetooth device events
  private static final int EVENT_ON_BLUETOOTH_DEVICE_FOUND = EVENT_GROUP_BT_DEVICE + 1;
  private static final int EVENT_ON_BLUETOOTH_DEVICE_NOT_FOUND = EVENT_GROUP_BT_DEVICE + 2;
  private static final int EVENT_ON_BLUETOOTH_DEVICE_PAIRING_SUCCESS = EVENT_GROUP_BT_DEVICE + 3;
  private static final int EVENT_ON_BLUETOOTH_DEVICE_PAIRING_FAILED = EVENT_GROUP_BT_DEVICE + 4;
  private static final int EVENT_ON_BLUETOOTH_REMOTE_DEVICE_UNPAIRED = EVENT_GROUP_BT_DEVICE + 5;

  // Bluetooth HID events
  private static final int EVENT_ON_BLUETOOTH_HID_PROFILE_REGISTERED = EVENT_GROUP_BT_HID + 1;
  private static final int EVENT_ON_BLUETOOTH_HID_PROFILE_UNREGISTERED = EVENT_GROUP_BT_HID + 2;
  private static final int EVENT_ON_BLUETOOTH_HID_DEVICE_CONNECTED = EVENT_GROUP_BT_HID + 3;
  private static final int EVENT_ON_BLUETOOTH_HID_DEVICE_CONNECTING = EVENT_GROUP_BT_HID + 4;
  private static final int EVENT_ON_BLUETOOTH_HID_DEVICE_DISCONNECTED = EVENT_GROUP_BT_HID + 5;
  private static final int EVENT_ON_BLUETOOTH_HID_DEVICE_DISCONNECTING = EVENT_GROUP_BT_HID + 6;

  // Bluetooth Adapter events
  private static final int EVENT_ON_BLUETOOTH_ADAPTER_ENABLED_SUCCESS = EVENT_GROUP_BT_ADAPTER + 1;
  private static final int EVENT_ON_BLUETOOTH_ADAPTER_ENABLED_FAILURE = EVENT_GROUP_BT_ADAPTER + 2;
  private static final int EVENT_ON_BLUETOOTH_ADAPTER_UNSUPPORTED = EVENT_GROUP_BT_ADAPTER + 3;
  private static final int EVENT_ON_BLUETOOTH_ADAPTER_ENABLING = EVENT_GROUP_BT_ADAPTER + 4;

  private final TouchBackNotInitialized touchBackNotInitialized = new TouchBackNotInitialized();
  private final TouchBackInitialized touchBackInitialized = new TouchBackInitialized();
  private final BluetoothAdapterNotChecked adapterNotChecked = new BluetoothAdapterNotChecked();
  private final BluetoothAdapterChecking adapterChecking = new BluetoothAdapterChecking();
  private final BluetoothAdapterEnabling adapterEnabling = new BluetoothAdapterEnabling();
  private final BluetoothAdapterUnsupported adapterUnsupported = new BluetoothAdapterUnsupported();
  private final BluetoothHidProfileServiceStopped profileServiceStopped = new BluetoothHidProfileServiceStopped();
  private final BluetoothHidProfileServiceStarting profileServiceStarting = new BluetoothHidProfileServiceStarting();
  private final BluetoothRemoteDeviceFinding remoteDeviceFinding = new BluetoothRemoteDeviceFinding();
  private final BluetoothRemoteDeviceNotDetected remoteDeviceNotDetected = new BluetoothRemoteDeviceNotDetected();
  private final BluetoothRemoteDeviceUnpaired remoteDeviceUnpaired = new BluetoothRemoteDeviceUnpaired();
  private final BluetoothRemoteDevicePairing remoteDevicePairing = new BluetoothRemoteDevicePairing();
  private final BluetoothRemoteDevicePairingFailed remoteDevicePairingFailed = new BluetoothRemoteDevicePairingFailed();
  private final BluetoothRemoteDevicePaired remoteDevicePaired = new BluetoothRemoteDevicePaired();

  private String device;
  private final Context context;
  private final Activity activity;

  private volatile boolean isTouchBackEnabled = false;
  private volatile boolean isAirplayStreaming = false;
  private volatile boolean userDisablingTouchback = false;

  private BluetoothDevice remoteDevice;
  private final BluetoothAdapterController adapterController;
  private BluetoothHidDeviceController hidDeviceController;
  private BluetoothDeviceBondStateMonitor deviceBondStateMonitor;

  private final TouchToMouseConverter.TouchToMouseConverterListener touchToMouseConverterListener =
    report -> {
    if (!hidDeviceController.sendReport(report)) {
      Log.e(TAG, "Failed to send HID report");
    }
  };
  private final TouchToMouseConverter touchToMouseConverter = new TouchToMouseConverter(touchToMouseConverterListener);

  private final BluetoothHidDeviceController.BluetoothHidDeviceControllerListener btHidDeviceControllerListener =
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

  private final StateCallback statusCallback;

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
    if (isTouchBackEnabled) {
      touchToMouseConverter.touch(touchId, touch, x, y);
    }
  }

  public void enableTouchback(boolean enable) {
    if (enable) {
      sendMessage(EVENT_ON_USER_ENABLE_TOUCH);
    } else {
      if (isState(remoteDeviceFinding)) {
        sendMessage(EVENT_ON_BLUETOOTH_DEVICE_NOT_FOUND);
      } else {
        sendMessage(EVENT_ON_USER_DISABLE_TOUCH);
      }
    }
  }

  public boolean onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
    return adapterController.onActivityResult(requestCode, resultCode, data);
  }

  public boolean onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
    if (isState(remoteDeviceFinding)) {
      remoteDeviceFinding.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }
    return false;
  }

  public void onActivityResumed() {
  }

  private final BluetoothDeviceBondStateMonitor.BondStateCallback bondStateCallback =
    new BluetoothDeviceBondStateMonitor.BondStateCallback() {

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

  /**
   * Base class for working states in the state machine.
   * <p>
   * A WorkingState is actively performing operations and will automatically transition to
   * another state when the operation completes or fails. These states represent ongoing
   * processes that are actively progressing toward a result.
   * <p>
   * WorkingState objects contain internal logic to determine the next appropriate
   * state and will self-transition without requiring user interaction.
   * They still respond to global events like Airplay streaming stopped, but
   * are designed to process their work and exit rather than persist.
   */
  private abstract class WorkingState extends State {
    @Override
    public boolean processMessage(Message msg) {
      if (msg.what == EVENT_ON_AIRPLAY_STREAMING_STOPPED) {
        isAirplayStreaming = false;
        return HANDLED;
      } else if (msg.what == EVENT_ON_USER_DISABLE_TOUCH) {
        userDisablingTouchback = true;
        return HANDLED;
      }
      return NOT_HANDLED;
    }
  }

  /**
   * Base class for idle states in the state machine.
   * <p>
   * An IdleState represents a condition where the system waits indefinitely for external events.
   * These states persist until:
   * 1. User interaction occurs (typically a touch event)
   * 2. Global events are received (e.g. Airplay streaming stopped)
   * <p>
   * Idle states represent waiting conditions, completed operations, or error states
   * that require external intervention to progress further in the workflow.
   * The system can remain in these states for extended periods with no ongoing
   * processing or state transitions.
   */
  private abstract class IdleState extends State {
    @Override
    public void enter() {
      if (!isState(touchBackNotInitialized) && !isAirplayStreaming) {
        transitionTo(touchBackNotInitialized);
      }
    }

    @Override
    public boolean processMessage(Message msg) {
      assert getCurrentState() != null;
      Log.d(TAG, "StableState: " + getCurrentState().getName() + " msg: " + msg.what);

      // GLOBAL EVENTS
      switch (msg.what) {
        case EVENT_ON_USER_DISABLE_TOUCH:
          userDisablingTouchback = false; // clear flag
          if (!isState(touchBackNotInitialized)) {
            statusCallback.onStatus(BluetoothTouchBackStatus.TOUCHBACK_CLOSED_BY_USER, false);
            transitionTo(touchBackNotInitialized);
          }
          //disable touch需執行stop()
          hidDeviceController.stop();
          return HANDLED;

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

  /**
   * Represents the state where Bluetooth touchback is not initialized.
   * <p>
   * Entry Events:
   * - System startup
   * - Receive EVENT_ON_AIRPLAY_STREAMING_STOPPED from any state
   * <p>
   * Handled Events:
   * - EVENT_ON_AIRPLAY_STREAMING_STARTED: Transition to AdapterNotChecked
   * <p>
   * Exit Transition:
   * - To AdapterNotChecked when Airplay streaming starts
   */
  private class TouchBackNotInitialized extends IdleState {
    @Override
    public void enter() {
      super.enter();
    }

    @Override
    public boolean processMessage(Message msg) {
      if (super.processMessage(msg) == HANDLED) {
        return true;
      }
      if (msg.what == EVENT_ON_AIRPLAY_STREAMING_STARTED) {
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

  /**
   * Final state where touch back functionality is fully initialized and running.
   * <p>
   * This idle state represents successful completion of the initialization sequence.
   * In this state, touch events are converted to mouse events and sent to the host device.
   * <p>
   * Entry:
   * - Sets touchback as enabled
   * - Notifies callback of successful initialization
   * <p>
   * Exit:
   * - Disables touchback
   * - Stops HID device controller
   */
  private class TouchBackInitialized extends IdleState {

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

  /**
   * State indicating that the Bluetooth adapter needs to be checked.
   * <p>
   * This idle state waits for user interaction before initiating Bluetooth operations.
   * The system remains in this state until the user touches the screen, providing
   * a natural entry point for the initialization sequence.
   * <p>
   * Handled Events:
   * - EVENT_ON_USER_ENABLE_TOUCH: Transitions to AdapterChecking to begin Bluetooth initialization
   * <p>
   * Notifications:
   * - TOUCHBACK_INITIALIZING: Indicates initialization process is waiting to start
   */
  private class BluetoothAdapterNotChecked extends IdleState {
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
      if (msg.what == EVENT_ON_USER_ENABLE_TOUCH) {
          transitionTo(adapterChecking);
          return HANDLED;
      }
      return NOT_HANDLED;
    }
  }

  /**
   * Working state that actively checks the Bluetooth adapter status.
   * <p>
   * This state performs operations to determine if Bluetooth is available and enabled.
   * It automatically evaluates the Bluetooth adapter and transitions to an appropriate
   * next state based on the results:
   * <p>
   * Automatic Transitions:
   * - To AdapterUnsupported: If Bluetooth is not supported on this device
   * - To AdapterEnabling: If Bluetooth needs to be enabled
   * - To ProfileServiceStarting: If Bluetooth is already enabled
   * <p>
   * Messages Generated Internally:
   * - EVENT_ON_BLUETOOTH_ADAPTER_UNSUPPORTED
   * - EVENT_ON_BLUETOOTH_ADAPTER_ENABLING
   * - EVENT_ON_BLUETOOTH_ADAPTER_ENABLED_SUCCESS
   */
  private class BluetoothAdapterChecking extends WorkingState {
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

  /**
   * Working state for enabling the Bluetooth adapter.
   * <p>
   * This state manages the process of requesting user permission to enable Bluetooth.
   * It initiates the system dialog for Bluetooth activation and processes the result.
   * <p>
   * Handled Events:
   * - EVENT_ON_BLUETOOTH_ADAPTER_ENABLED_SUCCESS: Transitions to ProfileServiceStarting
   * - EVENT_ON_BLUETOOTH_ADAPTER_ENABLED_FAILURE: Transitions back to AdapterNotChecked
   * <p>
   * Notifications:
   * - BLUETOOTH_ADAPTER_ENABLING: When starting to enable Bluetooth
   * - BLUETOOTH_ADAPTER_ENABLED_SUCCESS: When Bluetooth is successfully enabled
   * - BLUETOOTH_ADAPTER_ENABLED_FAILED: When Bluetooth enabling failed
   */
  private class BluetoothAdapterEnabling extends WorkingState {
    private final BluetoothAdapterController.BluetoothAdapterEnableCallback callback =
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

  /**
   * State indicating that the device's Bluetooth adapter does not support required functionality.
   * <p>
   * This idle error state indicates a hardware or system limitation and waits
   * for user intervention to retry or abort the operation.
   * <p>
   * Handled Events:
   * - EVENT_ON_USER_ENABLE_TOUCH: Transitions back to AdapterChecking to retry
   * <p>
   * Notifications:
   * - BLUETOOTH_ADAPTER_UNSUPPORTED: Informs user that Bluetooth is not supported
   */
  private class BluetoothAdapterUnsupported extends IdleState {
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
      if (msg.what == EVENT_ON_USER_ENABLE_TOUCH) {
          transitionTo(adapterChecking);
          return HANDLED;
      }
      return NOT_HANDLED;
    }
  }

  /**
   * State for when the Bluetooth HID profile service has stopped.
   * <p>
   * This idle state indicates that the HID service is not running, which may be
   * due to service crash, user action, or global events. The state waits for
   * user interaction to restart the service.
   * <p>
   * Handled Events:
   * - EVENT_ON_USER_ENABLE_TOUCH: Transitions to ProfileServiceStarting to restart the service
   */
  private class BluetoothHidProfileServiceStopped extends IdleState {
    @Override
    public void enter() {
      super.enter();
    }

    @Override
    public boolean processMessage(Message msg) {
      if (super.processMessage(msg) == HANDLED) {
        return true;
      }
      if (msg.what == EVENT_ON_USER_ENABLE_TOUCH) {
          transitionTo(profileServiceStarting);
          return HANDLED;
      }
      return false;
    }
  }

  /**
   * Working state for starting the Bluetooth HID profile service.
   * <p>
   * This state actively initializes the HID device controller and attempts to
   * register the HID profile with the system. It processes the registration result
   * and determines the next appropriate state.
   * <p>
   * Handled Events:
   * - EVENT_ON_BLUETOOTH_HID_PROFILE_REGISTERED: Transitions to RemoteDeviceFinding
   * - EVENT_ON_BLUETOOTH_HID_PROFILE_UNREGISTERED: Transitions to ProfileServiceStopped
   * <p>
   * Notifications:
   * - BLUETOOTH_HID_PROFILE_SERVICE_STARTING: When starting HID service
   * - BLUETOOTH_HID_PROFILE_SERVICE_STARTED_SUCCESS: When service started successfully
   * - BLUETOOTH_HID_PROFILE_SERVICE_STARTED_FAILED: When service failed to start
   */
  private class BluetoothHidProfileServiceStarting extends WorkingState {
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

  /**
   * Working state for searching for the target Bluetooth device.
   * <p>
   * This state actively uses BluetoothDeviceFinder to scan for and locate the device
   * with the specified name. It handles permission requests if needed, and
   * automatically transitions based on search results.
   * <p>
   * Handled Events:
   * - EVENT_ON_BLUETOOTH_DEVICE_FOUND: Transitions to RemoteDevicePairing
   * - EVENT_ON_BLUETOOTH_DEVICE_NOT_FOUND: Transitions to RemoteDeviceNotDetected
   * <p>
   * Notifications:
   * - BLUETOOTH_DEVICE_FINDING: When actively scanning for devices
   * - BLUETOOTH_DEVICE_FOUND_SUCCESS: When target device is found
   * <p>
   * Errors:
   * - UNABLE_TO_START_FINDING_DEVICE: When device discovery cannot be started
   */
  private class BluetoothRemoteDeviceFinding extends WorkingState {
    private BluetoothDeviceFinder btDeviceFinder;

    private final BluetoothDeviceFinder.BluetoothDeviceFinderListener listener =
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

  /**
   * State indicating that the target Bluetooth device was not found during scanning.
   * <p>
   * This idle error state informs the user that the specified device could not be located
   * and waits for user interaction to retry the discovery process.
   * <p>
   * Handled Events:
   * - EVENT_ON_USER_ENABLE_TOUCH: Transitions back to ProfileServiceStarting to restart the process
   * <p>
   * Notifications:
   * - BLUETOOTH_DEVICE_FOUND_FAILED: Informs user that device was not found
   */
  private class BluetoothRemoteDeviceNotDetected extends IdleState {
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
      if (msg.what == EVENT_ON_USER_ENABLE_TOUCH) {
          transitionTo(profileServiceStarting);
          return HANDLED;
      }
      return NOT_HANDLED;
    }
  }

  /**
   * State indicating that the previously paired remote device has been unpaired.
   * <p>
   * This idle state informs the user that the connection with the remote device
   * has been lost due to unpairing, and waits for user interaction to restart
   * the pairing process.
   * <p>
   * Handled Events:
   * - EVENT_ON_USER_ENABLE_TOUCH: Transitions to ProfileServiceStarting to restart pairing
   * <p>
   * Notifications:
   * - BLUETOOTH_DEVICE_UNPAIRED: Informs user that device is now unpaired
   */
  private class BluetoothRemoteDeviceUnpaired extends IdleState {
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
      if (msg.what == EVENT_ON_USER_ENABLE_TOUCH) {
          transitionTo(profileServiceStarting);
          return HANDLED;
      }
      return NOT_HANDLED;
    }
  }

  /**
   * Working state for pairing with the discovered Bluetooth device.
   * <p>
   * This state actively manages the pairing process using BluetoothDevicePairingHelper
   * to establish a bond with the target device. It handles the pairing sequence
   * and processes the result to determine the next state.
   * <p>
   * Handled Events:
   * - EVENT_ON_BLUETOOTH_DEVICE_PAIRING_SUCCESS: Transitions to RemoteDevicePaired
   * - EVENT_ON_BLUETOOTH_DEVICE_PAIRING_FAILED: Transitions to RemoteDevicePairingFailed
   * <p>
   * Notifications:
   * - BLUETOOTH_DEVICE_PAIRING: When pairing process starts
   */
  private class BluetoothRemoteDevicePairing extends WorkingState {

    private BluetoothDevicePairingHelper btDevicePairingHelper;

    private final BluetoothDevicePairingHelper.PairingCallback callback = new BluetoothDevicePairingHelper.PairingCallback() {
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

  /**
   * State indicating that pairing with the remote device has failed.
   * <p>
   * This idle error state informs the user that the pairing attempt was unsuccessful
   * and waits for user interaction to retry the pairing process.
   * <p>
   * Handled Events:
   * - EVENT_ON_USER_ENABLE_TOUCH: Transitions back to RemoteDevicePairing to retry
   * <p>
   * Notifications:
   * - BLUETOOTH_DEVICE_PAIRED_FAILED: Informs user that pairing failed
   */
  private class BluetoothRemoteDevicePairingFailed extends IdleState {
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
      if (msg.what == EVENT_ON_USER_ENABLE_TOUCH) {
          transitionTo(remoteDevicePairing);
          return HANDLED;
      }
      return NOT_HANDLED;
    }
  }

  /**
   * State representing successful pairing with the remote device, handling HID connection.
   * <p>
   * This idle state represents a successfully paired device that is ready for or
   * already in an HID connection. It manages connection, disconnection, and reconnection
   * of the HID profile with the paired device.
   * <p>
   * Handled Events:
   * - EVENT_ON_USER_ENABLE_TOUCH: Reconnects HID if needed
   * - EVENT_ON_BLUETOOTH_HID_DEVICE_CONNECTING: Updates status during connection process
   * - EVENT_ON_BLUETOOTH_HID_DEVICE_CONNECTED: Transitions to TouchBackInitialized
   * - EVENT_ON_BLUETOOTH_HID_DEVICE_DISCONNECTING: Updates status during disconnection
   * - EVENT_ON_BLUETOOTH_HID_DEVICE_DISCONNECTED: Updates status and sets reconnection flag
   * <p>
   * Notifications:
   * - BLUETOOTH_DEVICE_PAIRED_SUCCESS: When pairing is successful
   * - BLUETOOTH_HID_CONNECTING: When HID connection is being established
   * - BLUETOOTH_HID_CONNECTED: When HID connection is successful
   * - BLUETOOTH_HID_DISCONNECTING: When HID is disconnecting
   * - BLUETOOTH_HID_DISCONNECTED: When HID is disconnected
   */
  private class BluetoothRemoteDevicePaired extends IdleState {
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
        case EVENT_ON_USER_ENABLE_TOUCH:
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
