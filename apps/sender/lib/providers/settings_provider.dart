import 'package:flutter/material.dart';

enum SettingPageState {
  language,
  legalPolicy,
  knowledgeBase,
  checkForUpdates,
}

class SettingsProvider with ChangeNotifier {
  SettingsProvider();

  SettingPageState _currentPage = SettingPageState.language;

  SettingPageState get currentPage => _currentPage;

  static SettingPageState _currentTittlePage = SettingPageState.language;

  static SettingPageState get currentTittlePage => _currentTittlePage;

  setPage(SettingPageState state) {
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
    notifyListeners();
  }
}
