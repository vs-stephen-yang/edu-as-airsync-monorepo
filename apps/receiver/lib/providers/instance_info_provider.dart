import 'package:flutter/cupertino.dart';

class InstanceInfoProvider extends ChangeNotifier {
  // singleton
  static final InstanceInfoProvider _instance =
      InstanceInfoProvider._internal();

  InstanceInfoProvider._internal();

  factory InstanceInfoProvider() => _instance;

  String _instanceName = '';
  String _displayCode = '';

  String _ipAddress = '';

  String get deviceName => _instanceName;

  String get displayCode => _displayCode;

  String get displayCodeWithDash => _formatDisplayCodeWithDash(_displayCode);

  String get ipAddress => _ipAddress;

  set displayCode(String displayCode) {
    _displayCode = displayCode;
    notifyListeners();
  }

  set instanceName(String instanceName) {
    _instanceName = instanceName;

    notifyListeners();
  }

  set ipAddress(String? ipAddress) {
    if (ipAddress != null) _ipAddress = ipAddress;
    notifyListeners();
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
