package com.viewsonic.flutter_mirror;

// NOTE:
// We use index to determine the order of the status, so please do not change the order of the status.
//
// The order must be the same to the order of the status in dart code.
// in bluetooth_touch_back_status.dart
// enum BluetoothTouchbackStatus {
//  initializing,
//  initialized,
//  adapterEnabling,
//  adapterEnabledSuccess,
//  adapterEnabledFailed,
//  adapterUnsupported,
//  deviceFinding,
//  deviceFoundSuccess,
//  deviceFoundFailed,
//  devicePairing,
//  devicePairedSuccess,
//  devicePairedFailed,
//  deviceUnpaired,
//  hidConnecting,
//  hidConnected,
//  hidDisconnecting,
//  hidDisconnected,
//  hidProfileServiceStarting,
//  hidProfileServiceStartedSuccess,
//  hidProfileServiceStartedFailed,
// }
public enum BluetoothTouchBackStatus {
  TOUCHBACK_INITIALIZING,
  TOUCHBACK_INITIALIZED,
  BLUETOOTH_ADAPTER_ENABLING,
  BLUETOOTH_ADAPTER_ENABLED_SUCCESS,
  BLUETOOTH_ADAPTER_ENABLED_FAILED,
  BLUETOOTH_ADAPTER_UNSUPPORTED,
  BLUETOOTH_DEVICE_FINDING,
  BLUETOOTH_DEVICE_FOUND_SUCCESS,
  BLUETOOTH_DEVICE_FOUND_FAILED,
  BLUETOOTH_DEVICE_PAIRING,
  BLUETOOTH_DEVICE_PAIRED_SUCCESS,
  BLUETOOTH_DEVICE_PAIRED_FAILED,
  BLUETOOTH_DEVICE_UNPAIRED,
  BLUETOOTH_HID_CONNECTING,
  BLUETOOTH_HID_CONNECTED,
  BLUETOOTH_HID_DISCONNECTING,
  BLUETOOTH_HID_DISCONNECTED,
  BLUETOOTH_HID_PROFILE_SERVICE_STARTING,
  BLUETOOTH_HID_PROFILE_SERVICE_STARTED_SUCCESS,
  BLUETOOTH_HID_PROFILE_SERVICE_STARTED_FAILED,
}
