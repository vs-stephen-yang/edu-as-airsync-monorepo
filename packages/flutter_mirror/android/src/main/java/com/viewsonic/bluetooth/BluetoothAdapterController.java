package com.viewsonic.bluetooth;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothManager;
import android.content.Context;
import android.content.Intent;
import android.app.Activity;

public class BluetoothAdapterController {
  private static final int REQUEST_ENABLE_BT = 1;

  public interface BluetoothAdapterEnableCallback {
    void onResult(boolean success);
  }

  private BluetoothAdapter bluetoothAdapter;
  private BluetoothAdapterEnableCallback callback;

  public BluetoothAdapterController() {
  }

  public BluetoothAdapter getBluetoothAdapter() {
    return bluetoothAdapter;
  }

  public boolean initialize(Context context) {
    BluetoothManager bluetoothManager = (BluetoothManager) context.getSystemService(Context.BLUETOOTH_SERVICE);
    bluetoothAdapter = bluetoothManager.getAdapter();
    return bluetoothAdapter != null;
  }

  public boolean checkEnabled() {
    if (bluetoothAdapter == null) {
      return false;
    }
    return bluetoothAdapter.isEnabled();
  }

  public boolean startRequestBluetoothAdapterEnable(Activity activity, BluetoothAdapterEnableCallback callback) {
    if (bluetoothAdapter == null) {
      return false;
    }
    this.callback = callback;
    Intent intent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
    activity.startActivityForResult(intent, REQUEST_ENABLE_BT);
    return true;
  }

  public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
    if (requestCode == REQUEST_ENABLE_BT) {
      boolean success = resultCode == Activity.RESULT_OK;
      if (this.callback != null) {
        this.callback.onResult(success);
      }
      return success;
    }
    return false;
  }
}
