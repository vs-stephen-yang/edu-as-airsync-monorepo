import 'package:display_flutter/widgets/v3_settings_legal_policy.dart';
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
  licenses,
}

class SettingsProvider with ChangeNotifier {
  SettingsProvider();

  SettingPageState _currentPage = SettingPageState.deviceSetting;

  SettingPageState get currentPage => _currentPage;

  static SettingPageState _currentTittlePage = SettingPageState.deviceSetting;

  static SettingPageState get currentTittlePage => _currentTittlePage;

  License? _license;

  License? get license => _license;

  setPage(SettingPageState state, {License? license}) {
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
    if (license != null) {
      _license = license;
    }
    notifyListeners();
  }
}
