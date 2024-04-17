import 'dart:math';
import 'package:flutter/cupertino.dart';

class InstanceInfoProvider extends ChangeNotifier {
  String _instanceName = '';
  String _displayCode = '';

  String _deviceName = '';

  String get deviceName => _deviceName;

  String get displayCode => _displayCode;

  String get displayCodeWithDash => _formatDisplayCodeWithDash(_displayCode);

  set displayCode(String displayCode) {
    _displayCode = displayCode;

    _updateDeviceName();
    notifyListeners();
  }

  set instanceName(String instanceName) {
    _instanceName = instanceName;

    _updateDeviceName();
    notifyListeners();
  }

  String _formatDeviceName() {
    final suffix = _displayCode.substring(max(_displayCode.length - 5, 0));

    return '$_instanceName-$suffix';
  }

  _updateDeviceName() {
    _deviceName = _formatDeviceName();
  }

  _formatDisplayCodeWithDash(String displayCode) {
    String result = '';

    for (int i = 0; i < displayCode.length; i++) {
      if (i % 3 == 0 && result.isNotEmpty) {
        result += '-';
      }
      result += displayCode.substring(i, i + 1);
    }
    return result;
  }
}
