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

  /// `myViewBoard Display Update`
  String get update_title {
    return Intl.message(
      'myViewBoard Display Update',
      name: 'update_title',
      desc: '',
      args: [],
    );
  }

  /// `A new version of Display is available`
  String get update_message {
    return Intl.message(
      'A new version of Display is available',
      name: 'update_message',
      desc: '',
      args: [],
    );
  }

  /// `INSTALL NOW`
  String get update_install_now {
    return Intl.message(
      'INSTALL NOW',
      name: 'update_install_now',
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

  /// `%02d min : %02d sec`
  String get main_status_remaining_time {
    return Intl.message(
      '%02d min : %02d sec',
      name: 'main_status_remaining_time',
      desc: '',
      args: [],
    );
  }

  /// `Display app is running in the background.`
  String get main_status_go_background {
    return Intl.message(
      'Display app is running in the background.',
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

  /// `Failed to refresh password.\nPlease wait for 30 seconds before retrying.`
  String get main_content_one_time_password_get_fail {
    return Intl.message(
      'Failed to refresh password.\nPlease wait for 30 seconds before retrying.',
      name: 'main_content_one_time_password_get_fail',
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

  /// `Waiting for presenter to share screen...`
  String get main_wait_title {
    return Intl.message(
      'Waiting for presenter to share screen...',
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

  /// `Update End User License Agreement.`
  String get main_whats_new_content {
    return Intl.message(
      'Update End User License Agreement.',
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

  /// `Split screen enabled. Waiting for presenter to share screen...`
  String get main_split_screen_waiting {
    return Intl.message(
      'Split screen enabled. Waiting for presenter to share screen...',
      name: 'main_split_screen_waiting',
      desc: '',
      args: [],
    );
  }

  /// `Click the above toggle for Split Screen Mode. Up to 4 participants can present at once.`
  String get main_split_screen_question {
    return Intl.message(
      'Click the above toggle for Split Screen Mode. Up to 4 participants can present at once.',
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

  /// `Failed to get display code. Wait for network connectivity to resume, or restart the app.`
  String get main_get_display_code_failure {
    return Intl.message(
      'Failed to get display code. Wait for network connectivity to resume, or restart the app.',
      name: 'main_get_display_code_failure',
      desc: '',
      args: [],
    );
  }

  /// `Failure to get Display Code and One Time Password. This may be due to a network or server issue. Please try again later when connection is restored.`
  String get main_register_display_code_failure {
    return Intl.message(
      'Failure to get Display Code and One Time Password. This may be due to a network or server issue. Please try again later when connection is restored.',
      name: 'main_register_display_code_failure',
      desc: '',
      args: [],
    );
  }

  /// `Launch Display on startup`
  String get main_auto_startup {
    return Intl.message(
      'Launch Display on startup',
      name: 'main_auto_startup',
      desc: '',
      args: [],
    );
  }

  /// `Presenters`
  String get moderator_presentersList {
    return Intl.message(
      'Presenters',
      name: 'moderator_presentersList',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong. Please try again.`
  String get moderator_verifyCode_fail {
    return Intl.message(
      'Something went wrong. Please try again.',
      name: 'moderator_verifyCode_fail',
      desc: '',
      args: [],
    );
  }

  /// `Click the above toggle for Moderator Mode. Up to 6 presenters can join.`
  String get moderator_presentersLimit {
    return Intl.message(
      'Click the above toggle for Moderator Mode. Up to 6 presenters can join.',
      name: 'moderator_presentersLimit',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to end this moderator session? All presenters will be removed.`
  String get moderator_exit_dialog {
    return Intl.message(
      'Are you sure you want to end this moderator session? All presenters will be removed.',
      name: 'moderator_exit_dialog',
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

  /// `EXIT`
  String get moderator_exit {
    return Intl.message(
      'EXIT',
      name: 'moderator_exit',
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

  /// `Click the above toggle for Split Screen Mode. Up to 4 participants can present at once.`
  String get moderator_activate_split_screen {
    return Intl.message(
      'Click the above toggle for Split Screen Mode. Up to 4 participants can present at once.',
      name: 'moderator_activate_split_screen',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to end this split screen session? All screens currently shared will be terminated.`
  String get moderator_deactivate_split_screen {
    return Intl.message(
      'Are you sure you want to end this split screen session? All screens currently shared will be terminated.',
      name: 'moderator_deactivate_split_screen',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get moderator_confirm {
    return Intl.message(
      'Confirm',
      name: 'moderator_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Cast Settings`
  String get main_cast_settings_title {
    return Intl.message(
      'Cast Settings',
      name: 'main_cast_settings_title',
      desc: '',
      args: [],
    );
  }

  /// `Device Name:`
  String get main_cast_settings_device_name {
    return Intl.message(
      'Device Name:',
      name: 'main_cast_settings_device_name',
      desc: '',
      args: [],
    );
  }

  /// `AirPlay`
  String get main_cast_settings_airplay {
    return Intl.message(
      'AirPlay',
      name: 'main_cast_settings_airplay',
      desc: '',
      args: [],
    );
  }

  /// `Chromecast`
  String get main_cast_settings_google_cast {
    return Intl.message(
      'Chromecast',
      name: 'main_cast_settings_google_cast',
      desc: '',
      args: [],
    );
  }

  /// `Miracast`
  String get main_cast_settings_miracast {
    return Intl.message(
      'Miracast',
      name: 'main_cast_settings_miracast',
      desc: '',
      args: [],
    );
  }

  /// `AirPlay Code`
  String get main_airplay_pin_code {
    return Intl.message(
      'AirPlay Code',
      name: 'main_airplay_pin_code',
      desc: '',
      args: [],
    );
  }

  /// `%s would like to share their screen.`
  String get main_mirror_from_client {
    return Intl.message(
      '%s would like to share their screen.',
      name: 'main_mirror_from_client',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get main_mirror_prompt_cancel {
    return Intl.message(
      'Cancel',
      name: 'main_mirror_prompt_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Accept`
  String get main_mirror_prompt_accept {
    return Intl.message(
      'Accept',
      name: 'main_mirror_prompt_accept',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get main_settings_title {
    return Intl.message(
      'Settings',
      name: 'main_settings_title',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get main_settings_language {
    return Intl.message(
      'Language',
      name: 'main_settings_language',
      desc: '',
      args: [],
    );
  }

  /// `What's New?`
  String get main_settings_whats_new {
    return Intl.message(
      'What\'s New?',
      name: 'main_settings_whats_new',
      desc: '',
      args: [],
    );
  }

  /// `Share to sender`
  String get main_settings_share_to_sender {
    return Intl.message(
      'Share to sender',
      name: 'main_settings_share_to_sender',
      desc: '',
      args: [],
    );
  }

  /// `Up to 10 receivers can join.`
  String get main_settings_share_to_sender_limit_desc {
    return Intl.message(
      'Up to 10 receivers can join.',
      name: 'main_settings_share_to_sender_limit_desc',
      desc: '',
      args: [],
    );
  }

  /// `You’re currently offline`
  String get main_status_no_network {
    return Intl.message(
      'You’re currently offline',
      name: 'main_status_no_network',
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
