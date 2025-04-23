package com.viewsonic.bluetooth;

import android.bluetooth.BluetoothDevice;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.util.Log;

public class BluetoothDeviceBondStateMonitor {

  private final String TAG = "BTBondStateHelper";

  public interface BondStateCallback {
    void onUnpaired(BluetoothDevice device);
    void onACLDisconnected(BluetoothDevice device);
  }

  private Context context;
  private BondStateCallback callback;
  private BluetoothDevice targetDevice;

  private final BroadcastReceiver bluetoothBondReceiver = new BroadcastReceiver() {
    @Override
    public void onReceive(Context context, Intent intent) {
      String action = intent.getAction();
      if (BluetoothDevice.ACTION_BOND_STATE_CHANGED.equals(action)) {
        BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
        if (device.getAddress().equals(targetDevice.getAddress())) {
          int bondState = intent.getIntExtra(BluetoothDevice.EXTRA_BOND_STATE, BluetoothDevice.BOND_NONE);
          int previousBondState = intent.getIntExtra(BluetoothDevice.EXTRA_PREVIOUS_BOND_STATE, BluetoothDevice.BOND_BONDED);
          if (bondState == BluetoothDevice.BOND_NONE && previousBondState == BluetoothDevice.BOND_BONDED) {
            if (callback != null) {
              Log.d(TAG, "@@@ Unpaired: " + device.getName());
              callback.onUnpaired(device);
            }
          }
        }
      } else if (BluetoothDevice.ACTION_ACL_DISCONNECTED.equals(action)) {
        BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
        if (device.getAddress().equals(targetDevice.getAddress())) {
          if (callback != null) {
            //Log.d(TAG, "@@@ ACLDisconnected: " + device.getName());
            //callback.onACLDisconnected(device);
          }
        }
      }
    }
  };

  public BluetoothDeviceBondStateMonitor(Context context, BluetoothDeviceBondStateMonitor.BondStateCallback callback) {
    this.context = context;
    this.callback = callback;
  }

  public void start(BluetoothDevice targetDevice) {
    this.targetDevice = targetDevice;
    registerReceiver(bluetoothBondReceiver);
    Log.d(TAG, "BluetoothDeviceBondStateHelper started");
  }

  public void stop() {
    unregisterReceiver(bluetoothBondReceiver);
    Log.d(TAG, "BluetoothDeviceBondStateHelper stopped");
  }

  private void registerReceiver(BroadcastReceiver receiver) {
    context.registerReceiver(receiver, new IntentFilter(BluetoothDevice.ACTION_BOND_STATE_CHANGED));
    context.registerReceiver(receiver, new IntentFilter(BluetoothDevice.ACTION_ACL_DISCONNECTED));
  }

  private void unregisterReceiver(BroadcastReceiver receiver) {
    try {
      context.unregisterReceiver(receiver);
    } catch (IllegalArgumentException e) {
      Log.w(TAG, "Receiver not registered or already unregistered");
    }
  }
}
