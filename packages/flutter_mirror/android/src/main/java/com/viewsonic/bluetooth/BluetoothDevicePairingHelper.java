package com.viewsonic.bluetooth;

import android.bluetooth.BluetoothDevice;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.util.Log;

public class BluetoothDevicePairingHelper {

  private static final String TAG = "BluetoothPairingHelper";

  private final Context context;
  private final BluetoothDevice device;
  private PairingCallback callback;

  private final BroadcastReceiver receiver = new BroadcastReceiver() {
    @Override
    public void onReceive(Context context, Intent intent) {
      String action = intent.getAction();
      if (BluetoothDevice.ACTION_BOND_STATE_CHANGED.equals(action)) {
        BluetoothDevice pairedDevice = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
        if (pairedDevice != null && pairedDevice.equals(device)) {
          int bondState = intent.getIntExtra(BluetoothDevice.EXTRA_BOND_STATE, BluetoothDevice.BOND_NONE);
          if (bondState == BluetoothDevice.BOND_BONDED) {
            callback.onPairingSuccess(false);
            unregisterReceiver(receiver);
          } else if (bondState == BluetoothDevice.BOND_NONE) {
            callback.onPairingFailed();
            unregisterReceiver(receiver);
          }
        }
      }
    }
  };

  public interface PairingCallback {
    void onPairingSuccess(boolean alreadyPaired);
    void onPairingFailed();
  }

  public BluetoothDevicePairingHelper(Context context, BluetoothDevice device) {
    this.context = context;
    this.device = device;
  }

  public void startPairing(PairingCallback callback) {
    this.callback = callback;
    Log.d(TAG, "BluetoothDevicePairingHelper started");

    if (device == null) {
      Log.e(TAG, "BluetoothDevice is null");
      this.callback.onPairingFailed();
      return;
    }

    registerReceiver(receiver);

    try {
      int bondState = device.getBondState();
      if (bondState == BluetoothDevice.BOND_BONDED) {
        Log.d(TAG, "Device is already paired");
        this.callback.onPairingSuccess(true);
        unregisterReceiver(receiver);
        return;
      }
      boolean success = device.createBond(); // the result is returned in the broadcast receiver
      if (!success) {
        Log.e(TAG, "createBond() returned false");
        this.callback.onPairingFailed();
        unregisterReceiver(receiver);
      }
    } catch (Exception e) {
      Log.e(TAG, "Error while pairing", e);
      this.callback.onPairingFailed();
      unregisterReceiver(receiver);
    }
  }

  public void stop() {
    unregisterReceiver(receiver);
    Log.d(TAG, "BluetoothDevicePairingHelper stopped");
  }

  private void registerReceiver(BroadcastReceiver receiver) {
    context.registerReceiver(receiver, new IntentFilter(BluetoothDevice.ACTION_BOND_STATE_CHANGED));
  }

  private void unregisterReceiver(BroadcastReceiver receiver) {
    try {
      context.unregisterReceiver(receiver);
    } catch (IllegalArgumentException e) {
      Log.w(TAG, "Receiver not registered or already unregistered");
    }
  }
}
