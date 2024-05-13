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

  /// `Display code`
  String get main_display_code {
    return Intl.message(
      'Display code',
      name: 'main_display_code',
      desc: '',
      args: [],
    );
  }

  /// `Please input display code`
  String get main_display_code_description {
    return Intl.message(
      'Please input display code',
      name: 'main_display_code_description',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get main_password {
    return Intl.message(
      'Password',
      name: 'main_password',
      desc: '',
      args: [],
    );
  }

  /// `Please enter one-time password`
  String get main_password_description {
    return Intl.message(
      'Please enter one-time password',
      name: 'main_password_description',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get main_present {
    return Intl.message(
      'Next',
      name: 'main_present',
      desc: '',
      args: [],
    );
  }

  /// `Touchback`
  String get main_touch_back {
    return Intl.message(
      'Touchback',
      name: 'main_touch_back',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get main_language {
    return Intl.message(
      'Language',
      name: 'main_language',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get main_setting {
    return Intl.message(
      'Settings',
      name: 'main_setting',
      desc: '',
      args: [],
    );
  }

  /// `Knowledge Base`
  String get settings_knowledge_base {
    return Intl.message(
      'Knowledge Base',
      name: 'settings_knowledge_base',
      desc: '',
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
      desc: '',
      args: [],
    );
  }

  /// `Entire screen`
  String get present_select_screen_entire {
    return Intl.message(
      'Entire screen',
      name: 'present_select_screen_entire',
      desc: '',
      args: [],
    );
  }

  /// `Window`
  String get present_select_screen_window {
    return Intl.message(
      'Window',
      name: 'present_select_screen_window',
      desc: '',
      args: [],
    );
  }

  /// `Share`
  String get present_select_screen_share {
    return Intl.message(
      'Share',
      name: 'present_select_screen_share',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get present_select_screen_cancel {
    return Intl.message(
      'Cancel',
      name: 'present_select_screen_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Time elapsed`
  String get present_time {
    return Intl.message(
      'Time elapsed',
      name: 'present_time',
      desc: '',
      args: [],
    );
  }

  /// `hr`
  String get present_time_unit_hour {
    return Intl.message(
      'hr',
      name: 'present_time_unit_hour',
      desc: '',
      args: [],
    );
  }

  /// `mins`
  String get present_time_unit_min {
    return Intl.message(
      'mins',
      name: 'present_time_unit_min',
      desc: '',
      args: [],
    );
  }

  /// `secs`
  String get present_time_unit_sec {
    return Intl.message(
      'secs',
      name: 'present_time_unit_sec',
      desc: '',
      args: [],
    );
  }

  /// `Resume`
  String get present_state_resume {
    return Intl.message(
      'Resume',
      name: 'present_state_resume',
      desc: '',
      args: [],
    );
  }

  /// `Pause`
  String get present_state_pause {
    return Intl.message(
      'Pause',
      name: 'present_state_pause',
      desc: '',
      args: [],
    );
  }

  /// `Stop presenting`
  String get present_state_stop {
    return Intl.message(
      'Stop presenting',
      name: 'present_state_stop',
      desc: '',
      args: [],
    );
  }

  /// `Please input your name`
  String get moderator {
    return Intl.message(
      'Please input your name',
      name: 'moderator',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get moderator_name {
    return Intl.message(
      'Name',
      name: 'moderator_name',
      desc: '',
      args: [],
    );
  }

  /// `Please wait while the moderator selects presenters...`
  String get moderator_wait {
    return Intl.message(
      'Please wait while the moderator selects presenters...',
      name: 'moderator_wait',
      desc: '',
      args: [],
    );
  }

  /// `EXIT`
  String get moderator_exit {
    return Intl.message(
      'EXIT',
      name: 'moderator_exit',
      desc: '',
      args: [],
    );
  }

  /// `Field required`
  String get moderator_fill_out {
    return Intl.message(
      'Field required',
      name: 'moderator_fill_out',
      desc: '',
      args: [],
    );
  }

  /// `Password invalid.`
  String get main_password_invalid {
    return Intl.message(
      'Password invalid.',
      name: 'main_password_invalid',
      desc: '',
      args: [],
    );
  }

  /// `Maximum participants (6) reached.`
  String get main_display_code_exceed {
    return Intl.message(
      'Maximum participants (6) reached.',
      name: 'main_display_code_exceed',
      desc: '',
      args: [],
    );
  }

  /// `Maximum presenters (4) reached.`
  String get main_display_code_exceed_split_screen {
    return Intl.message(
      'Maximum presenters (4) reached.',
      name: 'main_display_code_exceed_split_screen',
      desc: '',
      args: [],
    );
  }

  /// `Share screen audio`
  String get present_select_screen_share_audio {
    return Intl.message(
      'Share screen audio',
      name: 'present_select_screen_share_audio',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get main_language_name {
    return Intl.message(
      'English',
      name: 'main_language_name',
      desc: '',
      args: [],
    );
  }

  /// `Has reached maximum moderated session amount.`
  String get toast_maximum_moderated {
    return Intl.message(
      'Has reached maximum moderated session amount.',
      name: 'toast_maximum_moderated',
      desc: '',
      args: [],
    );
  }

  /// `Has reached maximum split screen amount.`
  String get toast_maximum_split_screen {
    return Intl.message(
      'Has reached maximum split screen amount.',
      name: 'toast_maximum_split_screen',
      desc: '',
      args: [],
    );
  }

  /// `Sharing is in processing, please wait.`
  String get remote_screen_wait {
    return Intl.message(
      'Sharing is in processing, please wait.',
      name: 'remote_screen_wait',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Display code`
  String get main_display_code_invalid {
    return Intl.message(
      'Invalid Display code',
      name: 'main_display_code_invalid',
      desc: '',
      args: [],
    );
  }

  /// `Please enable share to sender in AirSync.`
  String get toast_enable_remote_screen {
    return Intl.message(
      'Please enable share to sender in AirSync.',
      name: 'toast_enable_remote_screen',
      desc: '',
      args: [],
    );
  }

  /// `Has reached maximum shared screen amount.`
  String get toast_maximum_remote_screen {
    return Intl.message(
      'Has reached maximum shared screen amount.',
      name: 'toast_maximum_remote_screen',
      desc: '',
      args: [],
    );
  }

  /// `Please install virtual audio driver.`
  String get toast_install_audio_driver {
    return Intl.message(
      'Please install virtual audio driver.',
      name: 'toast_install_audio_driver',
      desc: '',
      args: [],
    );
  }

  /// `Audio configuration`
  String get settings_audio_configuration {
    return Intl.message(
      'Audio configuration',
      name: 'settings_audio_configuration',
      desc: '',
      args: [],
    );
  }

  /// `Receive screen`
  String get present_role_receive {
    return Intl.message(
      'Receive screen',
      name: 'present_role_receive',
      desc: '',
      args: [],
    );
  }

  /// `Share screen`
  String get present_role_cast_screen {
    return Intl.message(
      'Share screen',
      name: 'present_role_cast_screen',
      desc: '',
      args: [],
    );
  }

  /// `Display code not found or instance is offline.`
  String get main_instance_not_found_or_offline {
    return Intl.message(
      'Display code not found or instance is offline.',
      name: 'main_instance_not_found_or_offline',
      desc: '',
      args: [],
    );
  }

  /// `Network error. Please check network connectivity and try again.`
  String get main_connect_network_error {
    return Intl.message(
      'Network error. Please check network connectivity and try again.',
      name: 'main_connect_network_error',
      desc: '',
      args: [],
    );
  }

  /// `AirSync instance is busy. Please try it later.`
  String get main_connect_rate_limited {
    return Intl.message(
      'AirSync instance is busy. Please try it later.',
      name: 'main_connect_rate_limited',
      desc: '',
      args: [],
    );
  }

  /// `Unknown error.`
  String get main_connect_unknown_error {
    return Intl.message(
      'Unknown error.',
      name: 'main_connect_unknown_error',
      desc: '',
      args: [],
    );
  }

  /// `AirSync does not connect to Internet.`
  String get main_connection_mode_unsupported {
    return Intl.message(
      'AirSync does not connect to Internet.',
      name: 'main_connection_mode_unsupported',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get moderator_back {
    return Intl.message(
      'Back',
      name: 'moderator_back',
      desc: '',
      args: [],
    );
  }

  /// `Only accept letters and numbers.`
  String get main_display_code_error {
    return Intl.message(
      'Only accept letters and numbers.',
      name: 'main_display_code_error',
      desc: '',
      args: [],
    );
  }

  /// `Only accept numbers.`
  String get main_otp_error {
    return Intl.message(
      'Only accept numbers.',
      name: 'main_otp_error',
      desc: '',
      args: [],
    );
  }

  /// `Quick Connect`
  String get main_device_list {
    return Intl.message(
      'Quick Connect',
      name: 'main_device_list',
      desc: '',
      args: [],
    );
  }

  /// `One-Time Password`
  String get device_list_enter_pin {
    return Intl.message(
      'One-Time Password',
      name: 'device_list_enter_pin',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get device_list_enter_pin_ok {
    return Intl.message(
      'OK',
      name: 'device_list_enter_pin_ok',
      desc: '',
      args: [],
    );
  }

  /// `Update version`
  String get main_update_title {
    return Intl.message(
      'Update version',
      name: 'main_update_title',
      desc: '',
      args: [],
    );
  }

  /// `New Version is AVAILABLE NOW. Please update it from App Store.`
  String get main_update_description_apple {
    return Intl.message(
      'New Version is AVAILABLE NOW. Please update it from App Store.',
      name: 'main_update_description_apple',
      desc: '',
      args: [],
    );
  }

  /// `New Version is AVAILABLE NOW. Please update it from Google Play.`
  String get main_update_description_android {
    return Intl.message(
      'New Version is AVAILABLE NOW. Please update it from Google Play.',
      name: 'main_update_description_android',
      desc: '',
      args: [],
    );
  }

  /// `New Version is AVAILABLE NOW. Please install it.`
  String get main_update_description_windows {
    return Intl.message(
      'New Version is AVAILABLE NOW. Please install it.',
      name: 'main_update_description_windows',
      desc: '',
      args: [],
    );
  }

  /// `UPDATE`
  String get main_update_positive_button {
    return Intl.message(
      'UPDATE',
      name: 'main_update_positive_button',
      desc: '',
      args: [],
    );
  }

  /// `NO THANKS`
  String get main_update_deny_button {
    return Intl.message(
      'NO THANKS',
      name: 'main_update_deny_button',
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
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'ru'),
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
