import 'package:display_cast_flutter/oss_licenses.dart';
import 'package:flutter/material.dart';

enum SettingPageState {
  // DO NOT change below order.
  // Due to selection highlight mechanism.
  // This enum sequence need match _addSettingsToList() sequence.
  language,
  legalPolicy,
  knowledgeBase,
  checkForUpdates,
  // add sub page below
  licenses,
}

class SettingsProvider with ChangeNotifier {
  SettingsProvider();

  SettingPageState _currentPage = SettingPageState.language;

  SettingPageState get currentPage => _currentPage;

  static SettingPageState _currentTittlePage = SettingPageState.language;

  static SettingPageState get currentTittlePage => _currentTittlePage;

  Package? _license;

  Package? get license => _license;

  setPage(SettingPageState state, {Package? license}) {
    switch (state) {
      case SettingPageState.language:
      case SettingPageState.legalPolicy:
      case SettingPageState.knowledgeBase:
      case SettingPageState.checkForUpdates:
        _currentTittlePage = state;
      default:
        break;
    }
    _currentPage = state;
    _license = license;
    notifyListeners();
  }
}
