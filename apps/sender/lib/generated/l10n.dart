// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Display Code`
  String get main_display_code {
    return Intl.message(
      'Display Code',
      name: 'main_display_code',
      desc: 'Display Code',
      args: [],
    );
  }

  /// `9 or 10-digit display code`
  String get main_display_code_description {
    return Intl.message(
      '9 or 10-digit display code',
      name: 'main_display_code_description',
      desc: 'DisplayPresent Code has 9-10 digits',
      args: [],
    );
  }

  /// `Password`
  String get main_password {
    return Intl.message(
      'Password',
      name: 'main_password',
      desc: 'Password',
      args: [],
    );
  }

  /// `4-digit one-time password`
  String get main_password_description {
    return Intl.message(
      '4-digit one-time password',
      name: 'main_password_description',
      desc: 'Password has 4 digits',
      args: [],
    );
  }

  /// `PRESENT`
  String get main_present {
    return Intl.message(
      'PRESENT',
      name: 'main_present',
      desc: 'PRESENT',
      args: [],
    );
  }

  /// `Touchback`
  String get main_touch_back {
    return Intl.message(
      'Touchback',
      name: 'main_touch_back',
      desc: 'Touchback',
      args: [],
    );
  }

  /// `Language`
  String get main_language {
    return Intl.message(
      'Language',
      name: 'main_language',
      desc: 'Language',
      args: [],
    );
  }

  /// `Settings`
  String get main_setting {
    return Intl.message(
      'Settings',
      name: 'main_setting',
      desc: 'Settings',
      args: [],
    );
  }

  /// `Knowledge Base`
  String get settings_knowledge_base {
    return Intl.message(
      'Knowledge Base',
      name: 'settings_knowledge_base',
      desc: 'Knowledge base',
      args: [],
    );
  }

  /// `Please select a screen to share within {value} seconds...`
  String present_wait(Object value) {
    return Intl.message(
      'Please select a screen to share within $value seconds...',
      name: 'present_wait',
      desc: '',
      args: [value],
    );
  }

  /// `Choose a view to share with the receiving screen.`
  String get present_select_screen_description {
    return Intl.message(
      'Choose a view to share with the receiving screen.',
      name: 'present_select_screen_description',
      desc: 'Choose what to share with the remote screen',
      args: [],
    );
  }

  /// `Entire screen`
  String get present_select_screen_entire {
    return Intl.message(
      'Entire screen',
      name: 'present_select_screen_entire',
      desc: 'Entire Screen',
      args: [],
    );
  }

  /// `Window`
  String get present_select_screen_window {
    return Intl.message(
      'Window',
      name: 'present_select_screen_window',
      desc: 'Window',
      args: [],
    );
  }

  /// `Share`
  String get present_select_screen_share {
    return Intl.message(
      'Share',
      name: 'present_select_screen_share',
      desc: 'Share',
      args: [],
    );
  }

  /// `Cancel`
  String get present_select_screen_cancel {
    return Intl.message(
      'Cancel',
      name: 'present_select_screen_cancel',
      desc: 'Cancel',
      args: [],
    );
  }

  /// `Time elapsed`
  String get present_time {
    return Intl.message(
      'Time elapsed',
      name: 'present_time',
      desc: 'Presentation time',
      args: [],
    );
  }

  /// `hr`
  String get present_time_unit_hour {
    return Intl.message(
      'hr',
      name: 'present_time_unit_hour',
      desc: 'Hour',
      args: [],
    );
  }

  /// `min`
  String get present_time_unit_min {
    return Intl.message(
      'min',
      name: 'present_time_unit_min',
      desc: 'Min',
      args: [],
    );
  }

  /// `sec`
  String get present_time_unit_sec {
    return Intl.message(
      'sec',
      name: 'present_time_unit_sec',
      desc: 'Sec',
      args: [],
    );
  }

  /// `Resume`
  String get present_state_resume {
    return Intl.message(
      'Resume',
      name: 'present_state_resume',
      desc: 'Resume',
      args: [],
    );
  }

  /// `Pause`
  String get present_state_pause {
    return Intl.message(
      'Pause',
      name: 'present_state_pause',
      desc: 'Pause',
      args: [],
    );
  }

  /// `Stop presenting`
  String get present_state_stop {
    return Intl.message(
      'Stop presenting',
      name: 'present_state_stop',
      desc: 'Stop Presenting',
      args: [],
    );
  }

  /// `Full screen`
  String get present_state_full_screen {
    return Intl.message(
      'Full screen',
      name: 'present_state_full_screen',
      desc: 'Full screen',
      args: [],
    );
  }

  /// `Exit full screen`
  String get present_state_normal_screen {
    return Intl.message(
      'Exit full screen',
      name: 'present_state_normal_screen',
      desc: 'Exit Full screen',
      args: [],
    );
  }

  /// `Moderator`
  String get moderator {
    return Intl.message(
      'Moderator',
      name: 'moderator',
      desc: 'Moderator',
      args: [],
    );
  }

  /// `Name`
  String get moderator_name {
    return Intl.message(
      'Name',
      name: 'moderator_name',
      desc: 'Name',
      args: [],
    );
  }

  /// `Please wait while the moderator selects presenters...`
  String get moderator_wait {
    return Intl.message(
      'Please wait while the moderator selects presenters...',
      name: 'moderator_wait',
      desc: 'Please wait for your turn\nModerator will select presenters',
      args: [],
    );
  }

  /// `EXIT`
  String get moderator_exit {
    return Intl.message(
      'EXIT',
      name: 'moderator_exit',
      desc: 'EXIT',
      args: [],
    );
  }

  /// `Field required`
  String get moderator_fill_out {
    return Intl.message(
      'Field required',
      name: 'moderator_fill_out',
      desc: 'Please fill out this field.',
      args: [],
    );
  }

  /// `Invalid one time password`
  String get main_password_invalid {
    return Intl.message(
      'Invalid one time password',
      name: 'main_password_invalid',
      desc: '',
      args: [],
    );
  }

  /// `Reach maximum presenters`
  String get main_display_code_exceed {
    return Intl.message(
      'Reach maximum presenters',
      name: 'main_display_code_exceed',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
