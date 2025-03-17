package com.viewsonic.bluetooth;

import android.annotation.SuppressLint;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothHidDevice;
import android.bluetooth.BluetoothHidDeviceAppQosSettings;
import android.bluetooth.BluetoothHidDeviceAppSdpSettings;
import android.bluetooth.BluetoothProfile;
import android.content.Context;
import android.util.Log;

import com.viewsonic.bluetooth.hid.HidConfig;
import com.viewsonic.bluetooth.hid.HidReport;

import java.util.concurrent.Executors;

public class BluetoothHidDeviceController {

  private static final String TAG = "btHidDeviceController";

  private boolean isRegistered = false;
  private Context context;

  private BluetoothAdapter bluetoothAdapter;
  private BluetoothDevice bluetoothDevice;
  private BluetoothHidDevice bluetoothHidDevice;

  public enum Error {
    REGISTER_FAILED,
  }

  public interface BluetoothHidDeviceControllerListener {
    void onBluetoothHidProfileAppRegisteredChanged(boolean registered);
    void onBluetoothHidDeviceConnected();
    void onBluetoothHidDeviceConnecting();
    void onBluetoothHidDeviceDisconnected();
    void onBluetoothHidDeviceDisconnecting();
  }
  private BluetoothHidDeviceControllerListener listener;

  private BluetoothHidDevice.Callback getHidCallback() {
    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.P) {
      return new BluetoothHidDevice.Callback() {

        // The app will be automatically unregistered if it is not foreground.
        @Override
        public void onAppStatusChanged(BluetoothDevice pluggedDevice, boolean registered) {
          super.onAppStatusChanged(pluggedDevice, registered);

          Log.d(TAG, "@@@ onAppStatusChanged: " + registered);

          isRegistered = registered;
          listener.onBluetoothHidProfileAppRegisteredChanged(isRegistered);
        }

        @Override
        public void onConnectionStateChanged(BluetoothDevice device, int state) {
          super.onConnectionStateChanged(device, state);
          Log.d(TAG, "@@@ onConnectionStateChanged state: " + state);

          switch (state) {
            case BluetoothHidDevice.STATE_CONNECTING:
              listener.onBluetoothHidDeviceConnecting();
              break;
            case BluetoothHidDevice.STATE_CONNECTED:
              listener.onBluetoothHidDeviceConnected();
              break;
            case BluetoothHidDevice.STATE_DISCONNECTING:
              listener.onBluetoothHidDeviceDisconnecting();
              break;
            case BluetoothHidDevice.STATE_DISCONNECTED:
              listener.onBluetoothHidDeviceDisconnected();
              break;
          }
        }
      };
    } else {
      Log.d(TAG, "HID device not supported");
      return null;
    }
  }

  @SuppressLint("NewApi")
  private BluetoothProfile.ServiceListener profileListener = new BluetoothProfile.ServiceListener() {
    @Override
    public void onServiceConnected(int profile, BluetoothProfile bluetoothProfile) {
      if (profile == BluetoothProfile.HID_DEVICE) {
        Log.d(TAG, "@@@ HID Profile onServiceConnected");

        bluetoothHidDevice = (BluetoothHidDevice) bluetoothProfile;

        BluetoothHidDeviceAppSdpSettings sdp = new BluetoothHidDeviceAppSdpSettings(
          HidConfig.DEVICE_NAME, HidConfig.DESCRIPTION, HidConfig.PROVIDER,
          BluetoothHidDevice.SUBCLASS1_COMBO, HidConfig.HID_DESCRIPTOR);

        BluetoothHidDeviceAppQosSettings outQos = new BluetoothHidDeviceAppQosSettings(
          BluetoothHidDeviceAppQosSettings.SERVICE_BEST_EFFORT,
          800, 9, 0, 11250, 0);
        // The application should be tracked by handling callback from Callback#onAppStatusChanged,
        // so that is not related to the return value of registerApp().
        boolean result = bluetoothHidDevice.registerApp(sdp, null, outQos, Executors.newCachedThreadPool(), getHidCallback());
        Log.d(TAG, "@@@ call registerApp result: " + result);
      }
    }

    // When does onServiceDisconnected() occur?
    // - Bluetooth is turned off → All profiles, including HID, are disconnected.
    // - System reclaims the HID Profile → Android may disable unused profiles.
    // - App calls closeProfileProxy() → Manually closing the proxy triggers this.
    // - Bluetooth system crash/restart → All active profiles get disconnected.
    // - Last HID device disconnects → If no other HID devices are connected, the system may disable HID Profile.
    @Override
    public void onServiceDisconnected(int profile) {
      if (profile == BluetoothProfile.HID_DEVICE) {
        Log.d(TAG, "@@@ HID Profile onServiceDisconnected");
        // bluetoothHidDevice is no longer valid, so we don't need to disconnect() or unregisterApp().
        // Also, we don't need to call closeProfileProxy() because it's called by the system.
        bluetoothHidDevice = null;
        isRegistered = false;
        listener.onBluetoothHidProfileAppRegisteredChanged(false);
      }
    }
  };

  public BluetoothHidDeviceController(Context context, BluetoothAdapter bluetoothAdapter, BluetoothHidDeviceControllerListener listener) {
    this.context = context;
    this.bluetoothAdapter = bluetoothAdapter;
    this.listener = listener;
  }

  @SuppressLint("NewApi")
  public boolean start() {
    boolean success = bluetoothAdapter.getProfileProxy(context, profileListener, BluetoothProfile.HID_DEVICE);
    Log.d(TAG, "BluetoothHidDeviceController start " + (success ? "succeeded" : "failed"));
    return success;
  }

  @SuppressLint("NewApi")
  public void stop() {
    if (isRegistered && bluetoothHidDevice != null) {
      bluetoothHidDevice.unregisterApp(); // MUST BE CALLED, OTHERWISE registerApp will fail next time
      bluetoothAdapter.closeProfileProxy(BluetoothProfile.HID_DEVICE, (BluetoothProfile) bluetoothHidDevice);
    }
  }

  @SuppressLint("NewApi")
  public boolean sendReport(HidReport report) {
    if (bluetoothHidDevice == null) {
      return false;
    }
    return bluetoothHidDevice.sendReport(bluetoothDevice, report.getReportId(), report.getReportData());
  }

  public void setHostDevice(BluetoothDevice bluetoothDevice) {
    this.bluetoothDevice = bluetoothDevice;
  }

  public BluetoothDevice getHostDevice() {
    return bluetoothDevice;
  }

  public boolean registered() {
    return isRegistered;
  }

  @SuppressLint("NewApi")
  public boolean connect() {
    if (isRegistered && bluetoothHidDevice != null && bluetoothDevice != null) {
      return bluetoothHidDevice.connect(bluetoothDevice);
    }
    return false;
  }

  @SuppressLint("NewApi")
  public boolean disconnect() {
    if (isRegistered && bluetoothHidDevice != null && bluetoothDevice != null) {
      return bluetoothHidDevice.disconnect(bluetoothDevice);
    }
    return false;
  }
}
