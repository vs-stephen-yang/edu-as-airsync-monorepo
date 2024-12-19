import 'package:display_flutter/oss_licenses.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SettingPageState {
  deviceSetting,
  deviceName,
  deviceLanguage,
  broadcast,
  broadcastBoards,
  mirroring,
  connectivity,
  whatsNew,
  legalPolicy,
  licenses,
}

class SettingsProvider with ChangeNotifier {
  SettingsProvider() {
    _load();
  }

  SettingPageState _currentPage = SettingPageState.deviceSetting;

  SettingPageState get currentPage => _currentPage;

  static SettingPageState _currentTittlePage = SettingPageState.deviceSetting;

  static SettingPageState get currentTittlePage => _currentTittlePage;

  Package? _license;

  Package? get license => _license;

  static const defaultDeviceSettingLock = false;
  static const defaultBroadcastLock = false;
  static const defaultMirroringLock = false;
  static const defaultConnectivityLock = false;
  bool _isDeviceSettingLock = defaultDeviceSettingLock;
  bool _isBroadcastLock = defaultBroadcastLock;
  bool _isMirroringLock = defaultMirroringLock;
  bool _isConnectivityLock = defaultConnectivityLock;

  bool get isDeviceSettingLock => _isDeviceSettingLock;

  set isDeviceSettingLock(bool value) {
    _isDeviceSettingLock = value;
    _save();
  }

  bool get isBroadcastLock => _isBroadcastLock;

  set isBroadcastLock(bool value) {
    _isBroadcastLock = value;
    _save();
  }

  bool get isMirroringLock => _isMirroringLock;

  set isMirroringLock(bool value) {
    isMirroringLock = value;
    _save();
  }

  bool get isConnectivityLock => _isConnectivityLock;

  set isConnectivityLock(bool value) {
    isConnectivityLock = value;
    _save();
  }

  _save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('app_isDeviceSettingLock', _isDeviceSettingLock);
    await prefs.setBool('app_isBroadcastLock', _isBroadcastLock);
    await prefs.setBool('app_isMirroringLock', _isMirroringLock);
    await prefs.setBool('app_isConnectivityLock', _isConnectivityLock);
  }

  _load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDeviceSettingLock =
        prefs.getBool('app_isDeviceSettingLock') ?? defaultDeviceSettingLock;
    _isBroadcastLock =
        prefs.getBool('app_isBroadcastLock') ?? defaultBroadcastLock;
    _isMirroringLock =
        prefs.getBool('app_isMirroringLock') ?? defaultMirroringLock;
    _isConnectivityLock =
        prefs.getBool('app_isConnectivityLock') ?? defaultConnectivityLock;
  }

  Future<void> reloadPreferences() async {
    _load();
    notifyListeners();
  }

  setPage(SettingPageState state, {Package? license}) {
    switch (state) {
      case SettingPageState.deviceSetting:
      case SettingPageState.broadcast:
      case SettingPageState.mirroring:
      case SettingPageState.connectivity:
      case SettingPageState.whatsNew:
      case SettingPageState.legalPolicy:
        _currentTittlePage = state;
      default:
        break;
    }
    _currentPage = state;
    _license = license;
    notifyListeners();
  }
}
