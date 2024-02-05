import 'package:flutter/foundation.dart';

class WebOnHiddenHelper {
  static WebOnHiddenHelper? _instance;
  int _onHiddenTimestamp = 0;
  bool _onHidden = false;

  int getOnHiddenTimestamp() {
    if (kIsWeb && _onHidden) {
      return _onHiddenTimestamp;
    } else {
      return 0;
    }
  }

  setOnHiddenTimestamp(int value) {
    _onHidden = true;
    _onHiddenTimestamp = value;
  }

  WebOnHiddenHelper._internal();

  static WebOnHiddenHelper getInstance() {
    _instance ??= WebOnHiddenHelper._internal();
    return _instance!;
  }

  resetHiddenTime() {
    _onHiddenTimestamp = 0;
    _onHidden = false;
  }
}
