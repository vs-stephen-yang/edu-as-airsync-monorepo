package com.viewsonic.bluetooth;

import android.Manifest;
import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import androidx.core.app.ActivityCompat;

public class BluetoothDeviceFinder {
  private final String TAG = "BluetoothDeviceFinder";
  private static final int REQUEST_FINE_LOCATION_PERMISSION = 321;

  private Context context;
  private Activity activity;
  private BluetoothAdapter bluetoothAdapter;

  public interface BluetoothDeviceFinderListener {
    void onPermissionGranted();
    void onPermissionDenied();
    void onBluetoothDeviceFound(BluetoothDevice device);
    void onBluetoothDeviceNotFound();
  }

  private BluetoothDeviceFinderListener listener;
  private boolean deviceFound = false;

  public BluetoothDeviceFinder(Context context, Activity activity, BluetoothAdapter bluetoothAdapter, BluetoothDeviceFinderListener listener) {
    this.context = context;
    this.activity = activity;
    this.bluetoothAdapter = bluetoothAdapter;
    this.listener = listener;
  }

  public boolean startFindingDevice(String deviceName) {
    if (bluetoothAdapter.isDiscovering()) {
      return true;
    }

    deviceFound = false;
    BroadcastReceiver broadcastReceiver = new BroadcastReceiver() {
      @Override
      public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();
        if (BluetoothDevice.ACTION_FOUND.equals(action)) {
          BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
          if (device.getName() != null && device.getName().equals(deviceName)) {
            deviceFound = true;
            bluetoothAdapter.cancelDiscovery();
            listener.onBluetoothDeviceFound(device);
            context.unregisterReceiver(this);
          }
        } else if (BluetoothAdapter.ACTION_DISCOVERY_FINISHED.equals(action)) {
          if (!deviceFound) {
            listener.onBluetoothDeviceNotFound();
          }
          context.unregisterReceiver(this);
        }
      }
    };

    IntentFilter intentFilter = new IntentFilter();
    intentFilter.addAction(BluetoothDevice.ACTION_FOUND);
    intentFilter.addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED);
    context.registerReceiver(broadcastReceiver, intentFilter);

    return bluetoothAdapter.startDiscovery();
  }

  public boolean checkPermissions() {
    if (ActivityCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
      ActivityCompat.requestPermissions(activity, new String[]{Manifest.permission.ACCESS_FINE_LOCATION}, REQUEST_FINE_LOCATION_PERMISSION);
      return false;
    }
    return true;
  }

  public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
    if (requestCode == REQUEST_FINE_LOCATION_PERMISSION) {
      boolean granted = grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED;
      if (granted) {
        listener.onPermissionGranted();
      } else {
        listener.onPermissionDenied();
      }
    }
  }
}
