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

  /// `Downloading system updates`
  String get vbs_ota_progress_msg {
    return Intl.message(
      'Downloading system updates',
      name: 'vbs_ota_progress_msg',
      desc: '',
      args: [],
    );
  }

  /// `myViewBoard Display EULA`
  String get eula_title {
    return Intl.message(
      'myViewBoard Display EULA',
      name: 'eula_title',
      desc: '',
      args: [],
    );
  }

  /// `I Disagree`
  String get eula_disagree {
    return Intl.message(
      'I Disagree',
      name: 'eula_disagree',
      desc: '',
      args: [],
    );
  }

  /// `I Agree`
  String get eula_agree {
    return Intl.message(
      'I Agree',
      name: 'eula_agree',
      desc: '',
      args: [],
    );
  }

  /// `Poor network connection detected.\nPlease check your connectivity.`
  String get main_status_no_network {
    return Intl.message(
      'Poor network connection detected.\nPlease check your connectivity.',
      name: 'main_status_no_network',
      desc: '',
      args: [],
    );
  }

  /// `%02d min : %02d sec`
  String get main_status_remaining_time {
    return Intl.message(
      '%02d min : %02d sec',
      name: 'main_status_remaining_time',
      desc: '',
      args: [],
    );
  }

  /// `Display App goes to the background.`
  String get main_status_go_background {
    return Intl.message(
      'Display App goes to the background.',
      name: 'main_status_go_background',
      desc: '',
      args: [],
    );
  }

  /// `Display Code`
  String get main_content_display_code {
    return Intl.message(
      'Display Code',
      name: 'main_content_display_code',
      desc: '',
      args: [],
    );
  }

  /// `One Time Password`
  String get main_content_one_time_password {
    return Intl.message(
      'One Time Password',
      name: 'main_content_one_time_password',
      desc: '',
      args: [],
    );
  }

  /// `Failed to get new password.\nPlease wait for 30 seconds before retrying.`
  String get main_content_one_time_password_get_fail {
    return Intl.message(
      'Failed to get new password.\nPlease wait for 30 seconds before retrying.',
      name: 'main_content_one_time_password_get_fail',
      desc: '',
      args: [],
    );
  }

  /// `or`
  String get main_content_scan_or {
    return Intl.message(
      'or',
      name: 'main_content_scan_or',
      desc: '',
      args: [],
    );
  }

  /// `Scan to enroll`
  String get main_content_scan_to_enroll {
    return Intl.message(
      'Scan to enroll',
      name: 'main_content_scan_to_enroll',
      desc: '',
      args: [],
    );
  }

  /// `UP NEXT`
  String get main_wait_up_next {
    return Intl.message(
      'UP NEXT',
      name: 'main_wait_up_next',
      desc: '',
      args: [],
    );
  }

  /// `Waiting for a sender to share a screen...`
  String get main_wait_title {
    return Intl.message(
      'Waiting for a sender to share a screen...',
      name: 'main_wait_title',
      desc: '',
      args: [],
    );
  }

  /// `Thank you for using myViewBoard Display.`
  String get main_thanks_content {
    return Intl.message(
      'Thank you for using myViewBoard Display.',
      name: 'main_thanks_content',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get main_language_title {
    return Intl.message(
      'Language',
      name: 'main_language_title',
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

  /// `What’s New on Display?`
  String get main_whats_new_title {
    return Intl.message(
      'What’s New on Display?',
      name: 'main_whats_new_title',
      desc: '',
      args: [],
    );
  }

  /// `[Improvements]\n- 1\n- 2\n- 3\n- 4\n- 5\n- 6\n- 7\n- 8\n- 9\n\n[Modifications]\n- 1\n- 2\n- 3\n- 4\n- 5\n- 6\n\n`
  String get main_whats_new_content {
    return Intl.message(
      '[Improvements]\n- 1\n- 2\n- 3\n- 4\n- 5\n- 6\n- 7\n- 8\n- 9\n\n[Modifications]\n- 1\n- 2\n- 3\n- 4\n- 5\n- 6\n\n',
      name: 'main_whats_new_content',
      desc: '',
      args: [],
    );
  }

  /// `Split Screen`
  String get main_split_screen_title {
    return Intl.message(
      'Split Screen',
      name: 'main_split_screen_title',
      desc: '',
      args: [],
    );
  }

  /// `“Waiting for a sender a screen...”`
  String get main_split_screen_waiting {
    return Intl.message(
      '“Waiting for a sender a screen...”',
      name: 'main_split_screen_waiting',
      desc: '',
      args: [],
    );
  }

  /// `Would you like to turn on the split screen feature?`
  String get main_split_screen_question {
    return Intl.message(
      'Would you like to turn on the split screen feature?',
      name: 'main_split_screen_question',
      desc: '',
      args: [],
    );
  }

  /// `5 minutes left`
  String get main_limit_time_message {
    return Intl.message(
      '5 minutes left',
      name: 'main_limit_time_message',
      desc: '',
      args: [],
    );
  }

  /// `Get display code failure.`
  String get main_get_display_code_failure {
    return Intl.message(
      'Get display code failure.',
      name: 'main_get_display_code_failure',
      desc: '',
      args: [],
    );
  }

  /// `Register display code failure.`
  String get main_register_display_code_failure {
    return Intl.message(
      'Register display code failure.',
      name: 'main_register_display_code_failure',
      desc: '',
      args: [],
    );
  }

  /// `Insufficient privilege for Display Advanced. Please contact your IT administrator.`
  String get main_privilege_message {
    return Intl.message(
      'Insufficient privilege for Display Advanced. Please contact your IT administrator.',
      name: 'main_privilege_message',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get main_privilege_close {
    return Intl.message(
      'Close',
      name: 'main_privilege_close',
      desc: '',
      args: [],
    );
  }

  /// `Presenters' List`
  String get moderator_presentersList {
    return Intl.message(
      'Presenters\' List',
      name: 'moderator_presentersList',
      desc: '',
      args: [],
    );
  }

  /// `Activate`
  String get moderator_activate {
    return Intl.message(
      'Activate',
      name: 'moderator_activate',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong, please try again`
  String get moderator_verifyCode_fail {
    return Intl.message(
      'Something went wrong, please try again',
      name: 'moderator_verifyCode_fail',
      desc: '',
      args: [],
    );
  }

  /// `Maximum 6 people`
  String get moderator_presentersLimit {
    return Intl.message(
      'Maximum 6 people',
      name: 'moderator_presentersLimit',
      desc: '',
      args: [],
    );
  }

  /// `CANCEL`
  String get moderator_cancel {
    return Intl.message(
      'CANCEL',
      name: 'moderator_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to exit?`
  String get moderator_exit_dialog {
    return Intl.message(
      'Are you sure you want to exit?',
      name: 'moderator_exit_dialog',
      desc: '',
      args: [],
    );
  }

  /// `REMOVE`
  String get moderator_remove {
    return Intl.message(
      'REMOVE',
      name: 'moderator_remove',
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

  /// `Would you like to activate the split screen feature in the presenters’ list? (Total maximum 4 people)`
  String get moderator_activate_split_screen {
    return Intl.message(
      'Would you like to activate the split screen feature in the presenters’ list? (Total maximum 4 people)',
      name: 'moderator_activate_split_screen',
      desc: '',
      args: [],
    );
  }

  /// `Would you like to deactivate the split screen feature in the presenters’ list?`
  String get moderator_deactivate_split_screen {
    return Intl.message(
      'Would you like to deactivate the split screen feature in the presenters’ list?',
      name: 'moderator_deactivate_split_screen',
      desc: '',
      args: [],
    );
  }

  /// `CONFIRM`
  String get moderator_confirm {
    return Intl.message(
      'CONFIRM',
      name: 'moderator_confirm',
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
