import 'package:flutter/cupertino.dart';

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
  privacyPolicy,
}

class SettingsProvider with ChangeNotifier {
  SettingsProvider();

  SettingPageState _currentPage = SettingPageState.deviceSetting;

  SettingPageState get currentPage => _currentPage;

  static SettingPageState _currentTittlePage = SettingPageState.deviceSetting;

  static SettingPageState get currentTittlePage => _currentTittlePage;

  setPage(SettingPageState state) {
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
    notifyListeners();
  }
}
