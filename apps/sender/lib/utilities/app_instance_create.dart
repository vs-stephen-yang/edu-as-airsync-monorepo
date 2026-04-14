import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AppInstanceCreate {
  static final AppInstanceCreate _instance = AppInstanceCreate._internal();

  //private "Named constructors"
  AppInstanceCreate._internal();

  // passes the instantiation to the _instance object
  factory AppInstanceCreate() => _instance;

  static ensureInitialized() async {
    await _instance._createInstanceId();
  }

  // App instance id, for admin backend used (Application insight,...)
  String _instanceId = '';

  String get instanceId => _instanceId;

  _save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    unawaited(prefs.setString('app_instanceId', _instanceId));
  }

  _load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _instanceId = prefs.getString('app_instanceId') ?? '';
  }

  _createInstanceId() async {
    await _load();

    if (_instanceId.isEmpty) {
      _instanceId = const Uuid().v4();
      _save();
    }
  }
}
