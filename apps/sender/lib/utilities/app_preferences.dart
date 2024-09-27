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

  bool get showOldUI => _showOldUI;
  bool _showOldUI = false;

  setShowOldUI(bool value) async {
    _showOldUI = value;
    await _save();
  }

  _save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('showOldUI', _showOldUI);
  }

  _load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _showOldUI = prefs.getBool('showOldUI') ?? false;
  }
}
