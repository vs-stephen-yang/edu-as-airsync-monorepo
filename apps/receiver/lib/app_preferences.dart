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

  bool _showEULA = true;

  bool get showEULA => _showEULA;

  set({bool? showEULA}) {
    if (showEULA != null) {
      _showEULA = showEULA;
    }
    _save();
  }

  _save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('app_showEULA', _showEULA);
  }

  _load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _showEULA = prefs.getBool('app_showEULA') ?? true;
  }
}
