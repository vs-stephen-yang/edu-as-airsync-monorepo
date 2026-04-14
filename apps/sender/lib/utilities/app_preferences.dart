import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static final AppPreferences _instance = AppPreferences._internal();

  //private "Named constructors"
  AppPreferences._internal();

  // passes the instantiation to the _instance object
  factory AppPreferences() => _instance;

  static ensureInitialized() async {
    await _instance._load();
  }

  bool get showEULA => _showEULA;
  bool _showEULA = true;

  setShowEULA(bool value) async {
    _showEULA = value;
    await _save();
  }

  _save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    unawaited(prefs.setBool('app_showEULA', _showEULA));
  }

  _load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _showEULA = prefs.getBool('app_showEULA') ?? true;
  }
}
