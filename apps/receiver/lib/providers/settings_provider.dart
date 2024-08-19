import 'package:flutter/cupertino.dart';

enum SettingTittleState {
  deviceSetting,
  broadcast,
  mirroring,
  connectivity,
  whatsNew
}

enum SettingPageState {
  deviceSetting,
  deviceName,
  deviceLanguage,
  broadcast,
  mirroring,
  connectivity,
  whatsNew
}

class SettingsProvider with ChangeNotifier {
  SettingsProvider();

  SettingPageState _currentPage = SettingPageState.deviceSetting;

  SettingPageState get currentPage => _currentPage;

  static SettingPageState _currentTittlePage = SettingPageState.deviceSetting;

  static SettingPageState get currentTittlePage => _currentTittlePage;

  setPage(SettingPageState state) {
    _currentPage = state;
    notifyListeners();
  }
}
