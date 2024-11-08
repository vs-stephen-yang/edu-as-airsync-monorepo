import 'dart:io';

import 'package:display_cast_flutter/utilities/log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefLanguageProvider extends ChangeNotifier {
  PrefLanguageProvider() {
    log.info('PrefLanguageProvider: _load');
    _load();
  }

  String _language = '';

  String get language =>
      _language.isNotEmpty ? _language : _getDefaultSupportedLanguage();

  Locale? get locale => localeMap[language];

  Map<String, Locale> localeMap = {
    // 'Deutsch': const Locale('de', ''),
    'English': const Locale('en', ''),
    // 'Pусский': const Locale('ru', ''),
    '繁體中文': const Locale.fromSubtags(
        languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW'),
  };

  setLanguage(String language) {
    _language = language;
    _save();
    notifyListeners();
  }

  _save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('app_language', _language);
  }

  _load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _language = prefs.getString('app_language') ?? '';
    log.info('_language: $_language');
    notifyListeners();
  }

  String _getDefaultSupportedLanguage() {
    //System locale
    String currentSystemLanguageCode =
        (!kIsWeb) ? Platform.localeName.split('_')[0] : 'en';

    //default is English
    String name = 'English';
    localeMap.forEach((key, value) {
      if (value.languageCode == currentSystemLanguageCode) {
        name = key;
      }
    });
    return name;
  }
}
