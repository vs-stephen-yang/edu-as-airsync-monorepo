import 'dart:io';

import 'package:flutter/material.dart';
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
  String _moderatorId = '';
  String _language = 'English';

  bool get showEULA => _showEULA;
  String get moderatorId => _moderatorId;
  String get language => _language.isNotEmpty ? _language : _getDefaultSupportedLanguage();
  Locale? get locale => localeMap[language];

  set language(String value) {
    set(language: value);
  }

  set({bool? showEULA,
    String? moderatorId,
    String? language,}) {
    if (showEULA != null) {
      _showEULA = showEULA;
    }
    if (moderatorId != null) {
      this._moderatorId = moderatorId;
    }
    if (language != null) {
      this._language = language;
    }
    _save();
  }

  _save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('app_showEULA', _showEULA);
    prefs.setString('app_moderatorId', _moderatorId);
    prefs.setString('app_language', _language);
  }

  _load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _showEULA = prefs.getBool('app_showEULA') ?? true;
    _moderatorId = prefs.getString('app_moderatorId') ?? '';
    _language = prefs.getString('app_language') ?? '';
  }

  static Map<String, Locale> localeMap = {
    'English': Locale('en', ''),
    '繁體中文': Locale.fromSubtags(
        languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW'),
  };

  String _getDefaultSupportedLanguage() {
    //System locale
    String currentSystemLanguageCode = Platform.localeName.split('_')[0];

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
