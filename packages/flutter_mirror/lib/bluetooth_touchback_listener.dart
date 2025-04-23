
import 'package:flutter_mirror/bluetooth_touchback_status.dart';

abstract class BluetoothTouchbackListener {
  void onBluetoothTouchbackStatusChanged(BluetoothTouchbackStatus status);
}
