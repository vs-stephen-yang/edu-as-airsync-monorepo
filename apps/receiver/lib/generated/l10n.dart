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
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
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
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
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

  /// `AirSync Update`
  String get update_title {
    return Intl.message(
      'AirSync Update',
      name: 'update_title',
      desc: '',
      args: [],
    );
  }

  /// `A new version of software is available`
  String get update_message {
    return Intl.message(
      'A new version of software is available',
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

  /// `AirSync EULA`
  String get eula_title {
    return Intl.message('AirSync EULA', name: 'eula_title', desc: '', args: []);
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
    return Intl.message('I Agree', name: 'eula_agree', desc: '', args: []);
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

  /// `AirSync app is running in the background.`
  String get main_status_go_background {
    return Intl.message(
      'AirSync app is running in the background.',
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

  /// `Thank you for using AirSync.`
  String get main_thanks_content {
    return Intl.message(
      'Thank you for using AirSync.',
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

  /// `What’s New on AirSync?`
  String get main_whats_new_title {
    return Intl.message(
      'What’s New on AirSync?',
      name: 'main_whats_new_title',
      desc: '',
      args: [],
    );
  }

  /// `[Improvement]\n\n1. All numeric display code for better experience.\n\n2. Improve connection stability.\n\n3. Bugs fixed.\n`
  String get main_whats_new_content {
    return Intl.message(
      '[Improvement]\n\n1. All numeric display code for better experience.\n\n2. Improve connection stability.\n\n3. Bugs fixed.\n',
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

  /// `Launch AirSync on startup`
  String get main_auto_startup {
    return Intl.message(
      'Launch AirSync on startup',
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
    return Intl.message('CANCEL', name: 'moderator_cancel', desc: '', args: []);
  }

  /// `EXIT`
  String get moderator_exit {
    return Intl.message('EXIT', name: 'moderator_exit', desc: '', args: []);
  }

  /// `REMOVE`
  String get moderator_remove {
    return Intl.message('REMOVE', name: 'moderator_remove', desc: '', args: []);
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

  /// `Name`
  String get main_cast_settings_device_name {
    return Intl.message(
      'Name',
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

  /// `Google Cast`
  String get main_cast_settings_google_cast {
    return Intl.message(
      'Google Cast',
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

  /// `Share screen to device`
  String get main_settings_share_to_sender {
    return Intl.message(
      'Share screen to device',
      name: 'main_settings_share_to_sender',
      desc: '',
      args: [],
    );
  }

  /// `Share screen up to 10 senders.`
  String get main_settings_share_to_sender_limit_desc {
    return Intl.message(
      'Share screen up to 10 senders.',
      name: 'main_settings_share_to_sender_limit_desc',
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

  /// `Name`
  String get main_settings_device_name {
    return Intl.message(
      'Name',
      name: 'main_settings_device_name',
      desc: '',
      args: [],
    );
  }

  /// `Rename device`
  String get main_settings_device_name_title {
    return Intl.message(
      'Rename device',
      name: 'main_settings_device_name_title',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get main_settings_device_name_hint {
    return Intl.message(
      'Name',
      name: 'main_settings_device_name_hint',
      desc: '',
      args: [],
    );
  }

  /// `CANCEL`
  String get main_settings_device_name_cancel {
    return Intl.message(
      'CANCEL',
      name: 'main_settings_device_name_cancel',
      desc: '',
      args: [],
    );
  }

  /// `SAVE`
  String get main_settings_device_name_save {
    return Intl.message(
      'SAVE',
      name: 'main_settings_device_name_save',
      desc: '',
      args: [],
    );
  }

  /// `Connect information`
  String get main_settings_pin_visible {
    return Intl.message(
      'Connect information',
      name: 'main_settings_pin_visible',
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

  /// `Quick Connect Password`
  String get main_settings_device_list {
    return Intl.message(
      'Quick Connect Password',
      name: 'main_settings_device_list',
      desc: '',
      args: [],
    );
  }

  /// `Mirror confirmation`
  String get main_settings_mirror_confirmation {
    return Intl.message(
      'Mirror confirmation',
      name: 'main_settings_mirror_confirmation',
      desc: '',
      args: [],
    );
  }

  /// `AirPlay code`
  String get main_settings_airplay_code {
    return Intl.message(
      'AirPlay code',
      name: 'main_settings_airplay_code',
      desc: '',
      args: [],
    );
  }

  /// `Network (WebRTC) reconnecting`
  String get main_webrtc_reconnecting_toast {
    return Intl.message(
      'Network (WebRTC) reconnecting',
      name: 'main_webrtc_reconnecting_toast',
      desc: '',
      args: [],
    );
  }

  /// `Network (WebRTC) reconnect fail`
  String get main_webrtc_reconnect_fail_toast {
    return Intl.message(
      'Network (WebRTC) reconnect fail',
      name: 'main_webrtc_reconnect_fail_toast',
      desc: '',
      args: [],
    );
  }

  /// `Network (WebRTC) reconnect success`
  String get main_webrtc_reconnect_success_toast {
    return Intl.message(
      'Network (WebRTC) reconnect success',
      name: 'main_webrtc_reconnect_success_toast',
      desc: '',
      args: [],
    );
  }

  /// `Network (Control) reconnecting`
  String get main_feature_reconnecting_toast {
    return Intl.message(
      'Network (Control) reconnecting',
      name: 'main_feature_reconnecting_toast',
      desc: '',
      args: [],
    );
  }

  /// `Network (Control) reconnect fail`
  String get main_feature_reconnect_fail_toast {
    return Intl.message(
      'Network (Control) reconnect fail',
      name: 'main_feature_reconnect_fail_toast',
      desc: '',
      args: [],
    );
  }

  /// `Network (Control) reconnect success`
  String get main_feature_reconnect_success_toast {
    return Intl.message(
      'Network (Control) reconnect success',
      name: 'main_feature_reconnect_success_toast',
      desc: '',
      args: [],
    );
  }

  /// `Only LAN connection`
  String get main_content_lan_only {
    return Intl.message(
      'Only LAN connection',
      name: 'main_content_lan_only',
      desc: '',
      args: [],
    );
  }

  /// `Control connection is disconnected. Please reconnect`
  String get main_feature_no_network_warning {
    return Intl.message(
      'Control connection is disconnected. Please reconnect',
      name: 'main_feature_no_network_warning',
      desc: '',
      args: [],
    );
  }

  /// `Share Your Screens`
  String get v3_instruction_share_screen {
    return Intl.message(
      'Share Your Screens',
      name: 'v3_instruction_share_screen',
      desc: '',
      args: [],
    );
  }

  /// `Visit airsync.net or open the sender app`
  String get v3_instruction1a {
    return Intl.message(
      'Visit airsync.net or open the sender app',
      name: 'v3_instruction1a',
      desc: '',
      args: [],
    );
  }

  /// `Open the sender app`
  String get v3_instruction1b {
    return Intl.message(
      'Open the sender app',
      name: 'v3_instruction1b',
      desc: '',
      args: [],
    );
  }

  /// `Enter display code`
  String get v3_instruction2 {
    return Intl.message(
      'Enter display code',
      name: 'v3_instruction2',
      desc: '',
      args: [],
    );
  }

  /// `Enter one-time password`
  String get v3_instruction3 {
    return Intl.message(
      'Enter one-time password',
      name: 'v3_instruction3',
      desc: '',
      args: [],
    );
  }

  /// `Supports sharing via AirPlay, Google Cast or Miracast`
  String get v3_instruction_support {
    return Intl.message(
      'Supports sharing via AirPlay, Google Cast or Miracast',
      name: 'v3_instruction_support',
      desc: '',
      args: [],
    );
  }

  /// `Quick Connect`
  String get v3_qrcode_quick_connect {
    return Intl.message(
      'Quick Connect',
      name: 'v3_qrcode_quick_connect',
      desc: '',
      args: [],
    );
  }

  /// `Display Code`
  String get v3_quick_connect_menu_display_code {
    return Intl.message(
      'Display Code',
      name: 'v3_quick_connect_menu_display_code',
      desc: '',
      args: [],
    );
  }

  /// `QR Code`
  String get v3_quick_connect_menu_qrcode {
    return Intl.message(
      'QR Code',
      name: 'v3_quick_connect_menu_qrcode',
      desc: '',
      args: [],
    );
  }

  /// `Shortcuts`
  String get v3_shortcuts_menu_title {
    return Intl.message(
      'Shortcuts',
      name: 'v3_shortcuts_menu_title',
      desc: '',
      args: [],
    );
  }

  /// `Cast to devices`
  String get v3_shortcuts_cast_device {
    return Intl.message(
      'Cast to devices',
      name: 'v3_shortcuts_cast_device',
      desc: '',
      args: [],
    );
  }

  /// `Cast this screen to multiple devices, including laptops, tablets and mobile devices simultaneously.`
  String get v3_shortcuts_cast_device_desc {
    return Intl.message(
      'Cast this screen to multiple devices, including laptops, tablets and mobile devices simultaneously.',
      name: 'v3_shortcuts_cast_device_desc',
      desc: '',
      args: [],
    );
  }

  /// `Mirroring`
  String get v3_shortcuts_mirroring {
    return Intl.message(
      'Mirroring',
      name: 'v3_shortcuts_mirroring',
      desc: '',
      args: [],
    );
  }

  /// `AirPlay`
  String get v3_shortcuts_airplay {
    return Intl.message(
      'AirPlay',
      name: 'v3_shortcuts_airplay',
      desc: '',
      args: [],
    );
  }

  /// `Google Cast`
  String get v3_shortcuts_google_cast {
    return Intl.message(
      'Google Cast',
      name: 'v3_shortcuts_google_cast',
      desc: '',
      args: [],
    );
  }

  /// `Miracast`
  String get v3_shortcuts_miracast {
    return Intl.message(
      'Miracast',
      name: 'v3_shortcuts_miracast',
      desc: '',
      args: [],
    );
  }

  /// `Up next`
  String get v3_waiting_up_next {
    return Intl.message(
      'Up next',
      name: 'v3_waiting_up_next',
      desc: '',
      args: [],
    );
  }

  /// `Waiting for this participant to share their screen`
  String get v3_waiting_desc {
    return Intl.message(
      'Waiting for this participant to share their screen',
      name: 'v3_waiting_desc',
      desc: '',
      args: [],
    );
  }

  /// `Waiting for others to join`
  String get v3_waiting_join {
    return Intl.message(
      'Waiting for others to join',
      name: 'v3_waiting_join',
      desc: '',
      args: [],
    );
  }

  /// `Moderator mode`
  String get v3_moderator_mode {
    return Intl.message(
      'Moderator mode',
      name: 'v3_moderator_mode',
      desc: '',
      args: [],
    );
  }

  /// `Exit Moderator Mode`
  String get v3_exit_moderator_mode_title {
    return Intl.message(
      'Exit Moderator Mode',
      name: 'v3_exit_moderator_mode_title',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure? This will disconnect all participants.`
  String get v3_exit_moderator_mode_desc {
    return Intl.message(
      'Are you sure? This will disconnect all participants.',
      name: 'v3_exit_moderator_mode_desc',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get v3_exit_moderator_mode_cancel {
    return Intl.message(
      'Cancel',
      name: 'v3_exit_moderator_mode_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Exit`
  String get v3_exit_moderator_mode_exit {
    return Intl.message(
      'Exit',
      name: 'v3_exit_moderator_mode_exit',
      desc: '',
      args: [],
    );
  }

  /// `Maximum up to 6 participants.`
  String get v3_participants_desc {
    return Intl.message(
      'Maximum up to 6 participants.',
      name: 'v3_participants_desc',
      desc: '',
      args: [],
    );
  }

  /// `Participants`
  String get v3_participants_title {
    return Intl.message(
      'Participants',
      name: 'v3_participants_title',
      desc: '',
      args: [],
    );
  }

  /// `Casting`
  String get v3_participant_item_casting {
    return Intl.message(
      'Casting',
      name: 'v3_participant_item_casting',
      desc: '',
      args: [],
    );
  }

  /// `Connected`
  String get v3_participant_item_connected {
    return Intl.message(
      'Connected',
      name: 'v3_participant_item_connected',
      desc: '',
      args: [],
    );
  }

  /// `Share`
  String get v3_participant_item_share {
    return Intl.message(
      'Share',
      name: 'v3_participant_item_share',
      desc: '',
      args: [],
    );
  }

  /// ` joined the session`
  String get v3_new_sharing_join_session {
    return Intl.message(
      ' joined the session',
      name: 'v3_new_sharing_join_session',
      desc: '',
      args: [],
    );
  }

  /// `Download Sender App`
  String get v3_download_app_entry {
    return Intl.message(
      'Download Sender App',
      name: 'v3_download_app_entry',
      desc: '',
      args: [],
    );
  }

  /// `Download Sender App`
  String get v3_download_app_title {
    return Intl.message(
      'Download Sender App',
      name: 'v3_download_app_title',
      desc: '',
      args: [],
    );
  }

  /// `Scan the QR code with your iOS or Android device to download`
  String get v3_download_app_desc {
    return Intl.message(
      'Scan the QR code with your iOS or Android device to download',
      name: 'v3_download_app_desc',
      desc: '',
      args: [],
    );
  }

  /// `Device setting`
  String get v3_settings_device_setting {
    return Intl.message(
      'Device setting',
      name: 'v3_settings_device_setting',
      desc: '',
      args: [],
    );
  }

  /// `Broadcast`
  String get v3_settings_broadcast {
    return Intl.message(
      'Broadcast',
      name: 'v3_settings_broadcast',
      desc: '',
      args: [],
    );
  }

  /// `Connectivity`
  String get v3_settings_connectivity {
    return Intl.message(
      'Connectivity',
      name: 'v3_settings_connectivity',
      desc: '',
      args: [],
    );
  }

  /// `What's new`
  String get v3_settings_whats_new {
    return Intl.message(
      'What\'s new',
      name: 'v3_settings_whats_new',
      desc: '',
      args: [],
    );
  }

  /// `Device Name`
  String get v3_settings_device_name {
    return Intl.message(
      'Device Name',
      name: 'v3_settings_device_name',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get v3_settings_device_name_save {
    return Intl.message(
      'Save',
      name: 'v3_settings_device_name_save',
      desc: '',
      args: [],
    );
  }

  /// `Show display code on top`
  String get v3_settings_device_show_display_code {
    return Intl.message(
      'Show display code on top',
      name: 'v3_settings_device_show_display_code',
      desc: '',
      args: [],
    );
  }

  /// `Keep the code visible at the top of the screen, even when switching to other apps and screen sharing is active.`
  String get v3_settings_device_show_display_code_desc {
    return Intl.message(
      'Keep the code visible at the top of the screen, even when switching to other apps and screen sharing is active.',
      name: 'v3_settings_device_show_display_code_desc',
      desc: '',
      args: [],
    );
  }

  /// `If invited to a display group`
  String get v3_settings_invite_group {
    return Intl.message(
      'If invited to a display group',
      name: 'v3_settings_invite_group',
      desc: '',
      args: [],
    );
  }

  /// `Notify me`
  String get v3_settings_invite_group_notify_me {
    return Intl.message(
      'Notify me',
      name: 'v3_settings_invite_group_notify_me',
      desc: '',
      args: [],
    );
  }

  /// `Auto Accept`
  String get v3_settings_invite_group_auto_accept {
    return Intl.message(
      'Auto Accept',
      name: 'v3_settings_invite_group_auto_accept',
      desc: '',
      args: [],
    );
  }

  /// `Ignore`
  String get v3_settings_invite_group_ignore {
    return Intl.message(
      'Ignore',
      name: 'v3_settings_invite_group_ignore',
      desc: '',
      args: [],
    );
  }

  /// `Auto-fill one-time password`
  String get v3_settings_device_auto_fill_otp {
    return Intl.message(
      'Auto-fill one-time password',
      name: 'v3_settings_device_auto_fill_otp',
      desc: '',
      args: [],
    );
  }

  /// `Enable one-touch connection when this device is selected from the Sender app's Quick Connect menu.`
  String get v3_settings_device_auto_fill_otp_desc {
    return Intl.message(
      'Enable one-touch connection when this device is selected from the Sender app\'s Quick Connect menu.',
      name: 'v3_settings_device_auto_fill_otp_desc',
      desc: '',
      args: [],
    );
  }

  /// `Require approval for all screen sharing requests.`
  String get v3_settings_device_authorize_mode {
    return Intl.message(
      'Require approval for all screen sharing requests.',
      name: 'v3_settings_device_authorize_mode',
      desc: '',
      args: [],
    );
  }

  /// `Cast to boards`
  String get v3_settings_broadcast_cast_boards {
    return Intl.message(
      'Cast to boards',
      name: 'v3_settings_broadcast_cast_boards',
      desc: '',
      args: [],
    );
  }

  /// `Share this screen to all Interactive Flat Panels (IFPs) in the network.`
  String get v3_settings_broadcast_cast_boards_desc {
    return Intl.message(
      'Share this screen to all Interactive Flat Panels (IFPs) in the network.',
      name: 'v3_settings_broadcast_cast_boards_desc',
      desc: '',
      args: [],
    );
  }

  /// `Require passcode`
  String get v3_settings_mirroring_require_passcode {
    return Intl.message(
      'Require passcode',
      name: 'v3_settings_mirroring_require_passcode',
      desc: '',
      args: [],
    );
  }

  /// `Auto Accept`
  String get v3_settings_mirroring_auto_accept {
    return Intl.message(
      'Auto Accept',
      name: 'v3_settings_mirroring_auto_accept',
      desc: '',
      args: [],
    );
  }

  /// `Instantly enable mirroring without requiring moderator approval.`
  String get v3_settings_mirroring_auto_accept_desc {
    return Intl.message(
      'Instantly enable mirroring without requiring moderator approval.',
      name: 'v3_settings_mirroring_auto_accept_desc',
      desc: '',
      args: [],
    );
  }

  /// `Both internet & local connection`
  String get v3_settings_connectivity_both {
    return Intl.message(
      'Both internet & local connection',
      name: 'v3_settings_connectivity_both',
      desc: '',
      args: [],
    );
  }

  /// `Local connection`
  String get v3_settings_connectivity_local {
    return Intl.message(
      'Local connection',
      name: 'v3_settings_connectivity_local',
      desc: '',
      args: [],
    );
  }

  /// `Local connections operate within a private network, offering more security and stability.`
  String get v3_settings_connectivity_local_desc {
    return Intl.message(
      'Local connections operate within a private network, offering more security and stability.',
      name: 'v3_settings_connectivity_local_desc',
      desc: '',
      args: [],
    );
  }

  /// `Internet connection`
  String get v3_settings_connectivity_internet {
    return Intl.message(
      'Internet connection',
      name: 'v3_settings_connectivity_internet',
      desc: '',
      args: [],
    );
  }

  /// `Internet connection requires a stable network.`
  String get v3_settings_connectivity_internet_desc {
    return Intl.message(
      'Internet connection requires a stable network.',
      name: 'v3_settings_connectivity_internet_desc',
      desc: '',
      args: [],
    );
  }

  /// `Join to Receive This Screen`
  String get v3_cast_to_device_menu_title {
    return Intl.message(
      'Join to Receive This Screen',
      name: 'v3_cast_to_device_menu_title',
      desc: '',
      args: [],
    );
  }

  /// `Or`
  String get v3_cast_to_device_menu_or {
    return Intl.message(
      'Or',
      name: 'v3_cast_to_device_menu_or',
      desc: '',
      args: [],
    );
  }

  /// `Quick Connect`
  String get v3_cast_to_device_menu_quick_connect1 {
    return Intl.message(
      'Quick Connect',
      name: 'v3_cast_to_device_menu_quick_connect1',
      desc: '',
      args: [],
    );
  }

  /// `by scan the QR code`
  String get v3_cast_to_device_menu_quick_connect2 {
    return Intl.message(
      'by scan the QR code',
      name: 'v3_cast_to_device_menu_quick_connect2',
      desc: '',
      args: [],
    );
  }

  /// `Device list`
  String get v3_cast_to_device_title {
    return Intl.message(
      'Device list',
      name: 'v3_cast_to_device_title',
      desc: '',
      args: [],
    );
  }

  /// `Touchback`
  String get v3_cast_to_device_touch_back {
    return Intl.message(
      'Touchback',
      name: 'v3_cast_to_device_touch_back',
      desc: '',
      args: [],
    );
  }

  /// `Disable`
  String get v3_cast_to_device_touch_back_disable {
    return Intl.message(
      'Disable',
      name: 'v3_cast_to_device_touch_back_disable',
      desc: '',
      args: [],
    );
  }

  /// `Receiving`
  String get v3_cast_to_device_Receiving {
    return Intl.message(
      'Receiving',
      name: 'v3_cast_to_device_Receiving',
      desc: '',
      args: [],
    );
  }

  /// `Touchback`
  String get v3_cast_to_device_touch_enabled {
    return Intl.message(
      'Touchback',
      name: 'v3_cast_to_device_touch_enabled',
      desc: '',
      args: [],
    );
  }

  /// `You’ve reached the maximum limit.`
  String get v3_cast_to_device_reached_maximum {
    return Intl.message(
      'You’ve reached the maximum limit.',
      name: 'v3_cast_to_device_reached_maximum',
      desc: '',
      args: [],
    );
  }

  /// `Broadcast to the display group`
  String get v3_settings_broadcast_to_display_group {
    return Intl.message(
      'Broadcast to the display group',
      name: 'v3_settings_broadcast_to_display_group',
      desc: '',
      args: [],
    );
  }

  /// `Only when casting`
  String get v3_settings_display_group_only_casting {
    return Intl.message(
      'Only when casting',
      name: 'v3_settings_display_group_only_casting',
      desc: '',
      args: [],
    );
  }

  /// `All the time`
  String get v3_settings_display_group_all_the_time {
    return Intl.message(
      'All the time',
      name: 'v3_settings_display_group_all_the_time',
      desc: '',
      args: [],
    );
  }

  /// `Display Group`
  String get v3_settings_display_group {
    return Intl.message(
      'Display Group',
      name: 'v3_settings_display_group',
      desc: '',
      args: [],
    );
  }

  /// `Broadcast`
  String get v3_settings_display_group_cast {
    return Intl.message(
      'Broadcast',
      name: 'v3_settings_display_group_cast',
      desc: '',
      args: [],
    );
  }

  /// `Passcode`
  String get v3_mirror_request_passcode {
    return Intl.message(
      'Passcode',
      name: 'v3_mirror_request_passcode',
      desc: '',
      args: [],
    );
  }

  /// `ON`
  String get v3_broadcast_indicator {
    return Intl.message(
      'ON',
      name: 'v3_broadcast_indicator',
      desc: '',
      args: [],
    );
  }

  /// `Launch AirSync on startup`
  String get v3_settings_device_launch_on_startup {
    return Intl.message(
      'Launch AirSync on startup',
      name: 'v3_settings_device_launch_on_startup',
      desc: '',
      args: [],
    );
  }

  /// `Broadcast Request from %s`
  String get v3_group_dialog_title {
    return Intl.message(
      'Broadcast Request from %s',
      name: 'v3_group_dialog_title',
      desc: '',
      args: [],
    );
  }

  /// `%s has sent a broadcast request to your device. This action will synchronize and display the current content, do you want to accept this request?`
  String get v3_group_dialog_message {
    return Intl.message(
      '%s has sent a broadcast request to your device. This action will synchronize and display the current content, do you want to accept this request?',
      name: 'v3_group_dialog_message',
      desc: '',
      args: [],
    );
  }

  /// `Accept`
  String get v3_group_dialog_accept {
    return Intl.message(
      'Accept',
      name: 'v3_group_dialog_accept',
      desc: '',
      args: [],
    );
  }

  /// `Decline`
  String get v3_group_dialog_decline {
    return Intl.message(
      'Decline',
      name: 'v3_group_dialog_decline',
      desc: '',
      args: [],
    );
  }

  /// `AirSync %s\n\nAirSync is a proprietary wireless screen-sharing solution from ViewSonic. When utilized with the AirSync sender, it allows users to seamlessly share their screens with ViewSonic interactive displays.\n\nThis release includes the following new features:\n\n1. Support for ViewBoard split screen view.\n\n2. Support high quality screen sharing (up to 4K) through web sender.\n\n3. Mute device audio output when sharing through Windows sender.\n\n4. Enhanced stability.\n\n5. Fixed various bugs.\n`
  String get v3_settings_whats_new_content {
    return Intl.message(
      'AirSync %s\n\nAirSync is a proprietary wireless screen-sharing solution from ViewSonic. When utilized with the AirSync sender, it allows users to seamlessly share their screens with ViewSonic interactive displays.\n\nThis release includes the following new features:\n\n1. Support for ViewBoard split screen view.\n\n2. Support high quality screen sharing (up to 4K) through web sender.\n\n3. Mute device audio output when sharing through Windows sender.\n\n4. Enhanced stability.\n\n5. Fixed various bugs.\n',
      name: 'v3_settings_whats_new_content',
      desc: '',
      args: [],
    );
  }

  /// `End-User License Agreement`
  String get v3_eula_title {
    return Intl.message(
      'End-User License Agreement',
      name: 'v3_eula_title',
      desc: '',
      args: [],
    );
  }

  /// `Agree`
  String get v3_eula_agree {
    return Intl.message('Agree', name: 'v3_eula_agree', desc: '', args: []);
  }

  /// `Disagree`
  String get v3_eula_disagree {
    return Intl.message(
      'Disagree',
      name: 'v3_eula_disagree',
      desc: '',
      args: [],
    );
  }

  /// `Unable to detect an internet connection. Please connect to a Wi-Fi or intranet network, and try again.`
  String get v3_main_status_no_network {
    return Intl.message(
      'Unable to detect an internet connection. Please connect to a Wi-Fi or intranet network, and try again.',
      name: 'v3_main_status_no_network',
      desc: '',
      args: [],
    );
  }

  /// `Unavailable`
  String get v3_settings_device_unavailable {
    return Intl.message(
      'Unavailable',
      name: 'v3_settings_device_unavailable',
      desc: '',
      args: [],
    );
  }

  /// `Broadcasting from`
  String get v3_group_receive_view_status_from {
    return Intl.message(
      'Broadcasting from',
      name: 'v3_group_receive_view_status_from',
      desc: '',
      args: [],
    );
  }

  /// `Stop`
  String get v3_group_receive_view_status_stop {
    return Intl.message(
      'Stop',
      name: 'v3_group_receive_view_status_stop',
      desc: '',
      args: [],
    );
  }

  /// `Receiving`
  String get v3_participant_item_receiving {
    return Intl.message(
      'Receiving',
      name: 'v3_participant_item_receiving',
      desc: '',
      args: [],
    );
  }

  /// `Receiving + Touchback`
  String get v3_participant_item_controlling {
    return Intl.message(
      'Receiving + Touchback',
      name: 'v3_participant_item_controlling',
      desc: '',
      args: [],
    );
  }

  /// `Legal & Policy`
  String get v3_settings_legal_policy {
    return Intl.message(
      'Legal & Policy',
      name: 'v3_settings_legal_policy',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get v3_settings_privacy_policy {
    return Intl.message(
      'Privacy Policy',
      name: 'v3_settings_privacy_policy',
      desc: '',
      args: [],
    );
  }

  /// `ViewSonic is committed to protecting your privacy and treats the handling of personal data seriously. The Privacy Policy below details how ViewSonic will treat your personal data after it has been collected by ViewSonic through your use of the Website. ViewSonic maintains the privacy of your information using security technologies and adhere to policies that prevent unauthorized use of your personal information. By using this Website, you consent to the collection and use of your information.\n\nWebsites you link to from ViewSonic.com may have their own privacy policy that may differ from ViewSonic’s. Please review those websites’ privacy policies for detailed information on how they may use information gathered while you are visiting them.\n\nPlease click the following links to learn more about our Privacy Policy.`
  String get v3_settings_privacy_policy_description {
    return Intl.message(
      'ViewSonic is committed to protecting your privacy and treats the handling of personal data seriously. The Privacy Policy below details how ViewSonic will treat your personal data after it has been collected by ViewSonic through your use of the Website. ViewSonic maintains the privacy of your information using security technologies and adhere to policies that prevent unauthorized use of your personal information. By using this Website, you consent to the collection and use of your information.\n\nWebsites you link to from ViewSonic.com may have their own privacy policy that may differ from ViewSonic’s. Please review those websites’ privacy policies for detailed information on how they may use information gathered while you are visiting them.\n\nPlease click the following links to learn more about our Privacy Policy.',
      name: 'v3_settings_privacy_policy_description',
      desc: '',
      args: [],
    );
  }

  /// `Open Source Licenses`
  String get v3_settings_open_source_license {
    return Intl.message(
      'Open Source Licenses',
      name: 'v3_settings_open_source_license',
      desc: '',
      args: [],
    );
  }

  /// `Decline`
  String get v3_authorize_prompt_decline {
    return Intl.message(
      'Decline',
      name: 'v3_authorize_prompt_decline',
      desc: '',
      args: [],
    );
  }

  /// `Accept`
  String get v3_authorize_prompt_accept {
    return Intl.message(
      'Accept',
      name: 'v3_authorize_prompt_accept',
      desc: '',
      args: [],
    );
  }

  /// `declined your broadcast request, please check the Broads setting.`
  String get v3_group_reject_invited {
    return Intl.message(
      'declined your broadcast request, please check the Broads setting.',
      name: 'v3_group_reject_invited',
      desc: '',
      args: [],
    );
  }

  /// `For Desktop`
  String get v3_download_app_for_desktop {
    return Intl.message(
      'For Desktop',
      name: 'v3_download_app_for_desktop',
      desc: '',
      args: [],
    );
  }

  /// `For iOS & Android`
  String get v3_download_app_for_mobile {
    return Intl.message(
      'For iOS & Android',
      name: 'v3_download_app_for_mobile',
      desc: '',
      args: [],
    );
  }

  /// `Enter the following URL to download.`
  String get v3_download_app_for_desktop_desc {
    return Intl.message(
      'Enter the following URL to download.',
      name: 'v3_download_app_for_desktop_desc',
      desc: '',
      args: [],
    );
  }

  /// `Scan the QR code for instant access.`
  String get v3_download_app_for_mobile_desc {
    return Intl.message(
      'Scan the QR code for instant access.',
      name: 'v3_download_app_for_mobile_desc',
      desc: '',
      args: [],
    );
  }

  /// `OR`
  String get v3_download_app_or {
    return Intl.message('OR', name: 'v3_download_app_or', desc: '', args: []);
  }

  /// `Disable Mirroring for Moderator Mode`
  String get v3_moderator_disable_mirror_title {
    return Intl.message(
      'Disable Mirroring for Moderator Mode',
      name: 'v3_moderator_disable_mirror_title',
      desc: '',
      args: [],
    );
  }

  /// `Mirroring will be disabled in moderator mode`
  String get v3_moderator_disable_mirror_desc {
    return Intl.message(
      'Mirroring will be disabled in moderator mode',
      name: 'v3_moderator_disable_mirror_desc',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get v3_moderator_disable_mirror_ok {
    return Intl.message(
      'OK',
      name: 'v3_moderator_disable_mirror_ok',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get v3_moderator_disable_mirror_cancel {
    return Intl.message(
      'Cancel',
      name: 'v3_moderator_disable_mirror_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Turn off moderator mode first.`
  String get v3_settings_mirroring_blocked {
    return Intl.message(
      'Turn off moderator mode first.',
      name: 'v3_settings_mirroring_blocked',
      desc: '',
      args: [],
    );
  }

  /// `Broadcast to`
  String get v3_settings_broadcast_cast_to {
    return Intl.message(
      'Broadcast to',
      name: 'v3_settings_broadcast_cast_to',
      desc: '',
      args: [],
    );
  }

  /// `Sender devices`
  String get v3_settings_broadcast_devices {
    return Intl.message(
      'Sender devices',
      name: 'v3_settings_broadcast_devices',
      desc: '',
      args: [],
    );
  }

  /// `Other AirSync devices`
  String get v3_settings_broadcast_boards {
    return Intl.message(
      'Other AirSync devices',
      name: 'v3_settings_broadcast_boards',
      desc: '',
      args: [],
    );
  }

  /// `Local connection only`
  String get v3_settings_local_connection_only {
    return Intl.message(
      'Local connection only',
      name: 'v3_settings_local_connection_only',
      desc: '',
      args: [],
    );
  }

  /// `No device selected.`
  String get v3_group_dialog_no_device_message {
    return Intl.message(
      'No device selected.',
      name: 'v3_group_dialog_no_device_message',
      desc: '',
      args: [],
    );
  }

  /// `Waiting...`
  String get v3_participant_item_waiting {
    return Intl.message(
      'Waiting...',
      name: 'v3_participant_item_waiting',
      desc: '',
      args: [],
    );
  }

  /// `Broadcast the source IFP screen only when it is receiving a shared screen.`
  String get v3_settings_only_when_casting_info {
    return Intl.message(
      'Broadcast the source IFP screen only when it is receiving a shared screen.',
      name: 'v3_settings_only_when_casting_info',
      desc: '',
      args: [],
    );
  }

  /// `Broadcast source IFP screen all the time.`
  String get v3_settings_all_the_time_info {
    return Intl.message(
      'Broadcast source IFP screen all the time.',
      name: 'v3_settings_all_the_time_info',
      desc: '',
      args: [],
    );
  }

  /// `Locked by ViewSonic Manager.`
  String get v3_settings_feature_locked {
    return Intl.message(
      'Locked by ViewSonic Manager.',
      name: 'v3_settings_feature_locked',
      desc: '',
      args: [],
    );
  }

  /// `Maximum up to 10 devices.`
  String get v3_cast_to_device_list_msg {
    return Intl.message(
      'Maximum up to 10 devices.',
      name: 'v3_cast_to_device_list_msg',
      desc: '',
      args: [],
    );
  }

  /// `Split-screen activates if two or more users share screens.`
  String get v3_quick_connect_menu_bottom_msg {
    return Intl.message(
      'Split-screen activates if two or more users share screens.',
      name: 'v3_quick_connect_menu_bottom_msg',
      desc: '',
      args: [],
    );
  }

  /// `AirSync ©{year}. version {version}`
  String v3_settings_version(Object year, Object version) {
    return Intl.message(
      'AirSync ©$year. version $version',
      name: 'v3_settings_version',
      desc: '',
      args: [year, version],
    );
  }

  /// `Please turn off energy saving to avoid unexpected interruption during broadcasting.`
  String get v3_settings_broadcast_screen_energy_saving {
    return Intl.message(
      'Please turn off energy saving to avoid unexpected interruption during broadcasting.',
      name: 'v3_settings_broadcast_screen_energy_saving',
      desc: '',
      args: [],
    );
  }

  /// `Maximum up to 9 participants.`
  String get v3_participants_desc_maximum_9 {
    return Intl.message(
      'Maximum up to 9 participants.',
      name: 'v3_participants_desc_maximum_9',
      desc: '',
      args: [],
    );
  }

  /// `Smart scaling`
  String get v3_settings_device_smart_scaling {
    return Intl.message(
      'Smart scaling',
      name: 'v3_settings_device_smart_scaling',
      desc: '',
      args: [],
    );
  }

  /// `Automatically adjust the screen size to maximize the use of screen space. The image may be slightly distorted.`
  String get v3_settings_device_smart_scaling_desc {
    return Intl.message(
      'Automatically adjust the screen size to maximize the use of screen space. The image may be slightly distorted.',
      name: 'v3_settings_device_smart_scaling_desc',
      desc: '',
      args: [],
    );
  }

  /// `Screen sharing is about to end. Would you like to extend it by 3 hours? You can extend up to {value} times. `
  String v3_casting_time_countdown(Object value) {
    return Intl.message(
      'Screen sharing is about to end. Would you like to extend it by 3 hours? You can extend up to $value times. ',
      name: 'v3_casting_time_countdown',
      desc: '',
      args: [value],
    );
  }

  /// `Screen sharing is about to end. Please restart the screen sharing if necessary.`
  String get v3_last_casting_time_countdown {
    return Intl.message(
      'Screen sharing is about to end. Please restart the screen sharing if necessary.',
      name: 'v3_last_casting_time_countdown',
      desc: '',
      args: [],
    );
  }

  /// `Extended for 3 hours.`
  String get v3_casting_time_extend_success_toast {
    return Intl.message(
      'Extended for 3 hours.',
      name: 'v3_casting_time_extend_success_toast',
      desc: '',
      args: [],
    );
  }

  /// `Screen sharing has ended.`
  String get v3_casting_ended_toast {
    return Intl.message(
      'Screen sharing has ended.',
      name: 'v3_casting_ended_toast',
      desc: '',
      args: [],
    );
  }

  /// `Do not extend`
  String get v3_casting_time_do_not_extend {
    return Intl.message(
      'Do not extend',
      name: 'v3_casting_time_do_not_extend',
      desc: '',
      args: [],
    );
  }

  /// `Extend`
  String get v3_casting_time_extend {
    return Intl.message(
      'Extend',
      name: 'v3_casting_time_extend',
      desc: '',
      args: [],
    );
  }

  /// `For Best User Experience!`
  String get v3_download_app_desktop {
    return Intl.message(
      'For Best User Experience!',
      name: 'v3_download_app_desktop',
      desc: '',
      args: [],
    );
  }

  /// `*Manual Installer`
  String get v3_download_app_desktop_hint {
    return Intl.message(
      '*Manual Installer',
      name: 'v3_download_app_desktop_hint',
      desc: '',
      args: [],
    );
  }

  /// `Install MacOS via App Store`
  String get v3_download_app_desktop_store {
    return Intl.message(
      'Install MacOS via App Store',
      name: 'v3_download_app_desktop_store',
      desc: '',
      args: [],
    );
  }

  /// `*Only For MacOS`
  String get v3_download_app_desktop_store_hint {
    return Intl.message(
      '*Only For MacOS',
      name: 'v3_download_app_desktop_store_hint',
      desc: '',
      args: [],
    );
  }

  /// `Desktop`
  String get v3_download_app_desktop_title {
    return Intl.message(
      'Desktop',
      name: 'v3_download_app_desktop_title',
      desc: '',
      args: [],
    );
  }

  /// `Mobile`
  String get v3_download_app_mobile_title {
    return Intl.message(
      'Mobile',
      name: 'v3_download_app_mobile_title',
      desc: '',
      args: [],
    );
  }

  /// `Enter passcode to unlock Settings`
  String get v3_setting_passcode_title {
    return Intl.message(
      'Enter passcode to unlock Settings',
      name: 'v3_setting_passcode_title',
      desc: '',
      args: [],
    );
  }

  /// `Invalid password, please try again.`
  String get v3_setting_passcode_error_description {
    return Intl.message(
      'Invalid password, please try again.',
      name: 'v3_setting_passcode_error_description',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get v3_setting_passcode_cancel {
    return Intl.message(
      'Cancel',
      name: 'v3_setting_passcode_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Clear`
  String get v3_setting_passcode_clear {
    return Intl.message(
      'Clear',
      name: 'v3_setting_passcode_clear',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get v3_setting_passcode_confirm {
    return Intl.message(
      'Confirm',
      name: 'v3_setting_passcode_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Internet connection only。`
  String get v3_main_internet_connection_only {
    return Intl.message(
      'Internet connection only。',
      name: 'v3_main_internet_connection_only',
      desc: '',
      args: [],
    );
  }

  /// `Connectivity error，please check device network setting。`
  String get v3_main_internet_connection_only_error {
    return Intl.message(
      'Connectivity error，please check device network setting。',
      name: 'v3_main_internet_connection_only_error',
      desc: '',
      args: [],
    );
  }

  /// `LAN connection only，please check device network setting。`
  String get v3_main_local_connection_only_dialog_desc {
    return Intl.message(
      'LAN connection only，please check device network setting。',
      name: 'v3_main_local_connection_only_dialog_desc',
      desc: '',
      args: [],
    );
  }

  /// `Connectivity error，please check device network setting。`
  String get v3_main_internet_connection_only_error_dialog_desc {
    return Intl.message(
      'Connectivity error，please check device network setting。',
      name: 'v3_main_internet_connection_only_error_dialog_desc',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get v3_main_connection_dialog_close {
    return Intl.message(
      'Close',
      name: 'v3_main_connection_dialog_close',
      desc: '',
      args: [],
    );
  }

  /// `Accept All`
  String get v3_authorize_prompt_accept_all {
    return Intl.message(
      'Accept All',
      name: 'v3_authorize_prompt_accept_all',
      desc: '',
      args: [],
    );
  }

  /// `Disagree with EULA`
  String get v3_lbl_eula_disagree {
    return Intl.message(
      'Disagree with EULA',
      name: 'v3_lbl_eula_disagree',
      desc: '',
      args: [],
    );
  }

  /// `Agree with EULA`
  String get v3_lbl_eula_agree {
    return Intl.message(
      'Agree with EULA',
      name: 'v3_lbl_eula_agree',
      desc: '',
      args: [],
    );
  }

  /// `Setting Menu is locked`
  String get v3_lbl_settings_menu_locked {
    return Intl.message(
      'Setting Menu is locked',
      name: 'v3_lbl_settings_menu_locked',
      desc: '',
      args: [],
    );
  }

  /// `Open Setting Menu`
  String get v3_lbl_open_menu_settings {
    return Intl.message(
      'Open Setting Menu',
      name: 'v3_lbl_open_menu_settings',
      desc: '',
      args: [],
    );
  }

  /// `Open download sender app menu`
  String get v3_lbl_open_download_app_menu {
    return Intl.message(
      'Open download sender app menu',
      name: 'v3_lbl_open_download_app_menu',
      desc: '',
      args: [],
    );
  }

  /// `Close download sender app menu`
  String get v3_lbl_close_download_app_menu {
    return Intl.message(
      'Close download sender app menu',
      name: 'v3_lbl_close_download_app_menu',
      desc: '',
      args: [],
    );
  }

  /// `Toggle moderator mode`
  String get v3_lbl_moderator_toggle {
    return Intl.message(
      'Toggle moderator mode',
      name: 'v3_lbl_moderator_toggle',
      desc: '',
      args: [],
    );
  }

  /// `Cancel exiting moderator mode`
  String get v3_lbl_exit_moderator_cancel {
    return Intl.message(
      'Cancel exiting moderator mode',
      name: 'v3_lbl_exit_moderator_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Confirm exiting moderator mode`
  String get v3_lbl_exit_moderator_exit {
    return Intl.message(
      'Confirm exiting moderator mode',
      name: 'v3_lbl_exit_moderator_exit',
      desc: '',
      args: [],
    );
  }

  /// `Local connection only`
  String get v3_lbl_internet_connection_warning {
    return Intl.message(
      'Local connection only',
      name: 'v3_lbl_internet_connection_warning',
      desc: '',
      args: [],
    );
  }

  /// `Connectivity error，please check device network setting`
  String get v3_lbl_internet_connection_only_error {
    return Intl.message(
      'Connectivity error，please check device network setting',
      name: 'v3_lbl_internet_connection_only_error',
      desc: '',
      args: [],
    );
  }

  /// `Close connection status dialog`
  String get v3_lbl_connection_dialog_close {
    return Intl.message(
      'Close connection status dialog',
      name: 'v3_lbl_connection_dialog_close',
      desc: '',
      args: [],
    );
  }

  /// `Decline request`
  String get v3_lbl_authorize_prompt_decline {
    return Intl.message(
      'Decline request',
      name: 'v3_lbl_authorize_prompt_decline',
      desc: '',
      args: [],
    );
  }

  /// `Accept request`
  String get v3_lbl_authorize_prompt_accept {
    return Intl.message(
      'Accept request',
      name: 'v3_lbl_authorize_prompt_accept',
      desc: '',
      args: [],
    );
  }

  /// `Accept all requests`
  String get v3_lbl_authorize_prompt_accept_all {
    return Intl.message(
      'Accept all requests',
      name: 'v3_lbl_authorize_prompt_accept_all',
      desc: '',
      args: [],
    );
  }

  /// `Collapse streaming function`
  String get v3_lbl_streaming_view_function_minimize {
    return Intl.message(
      'Collapse streaming function',
      name: 'v3_lbl_streaming_view_function_minimize',
      desc: '',
      args: [],
    );
  }

  /// `Expand streaming function`
  String get v3_lbl_streaming_view_function_expand {
    return Intl.message(
      'Expand streaming function',
      name: 'v3_lbl_streaming_view_function_expand',
      desc: '',
      args: [],
    );
  }

  /// `Collapse streaming view`
  String get v3_lbl_streaming_view_minimize {
    return Intl.message(
      'Collapse streaming view',
      name: 'v3_lbl_streaming_view_minimize',
      desc: '',
      args: [],
    );
  }

  /// `Expand streaming view`
  String get v3_lbl_streaming_view_expand {
    return Intl.message(
      'Expand streaming view',
      name: 'v3_lbl_streaming_view_expand',
      desc: '',
      args: [],
    );
  }

  /// `Mute audio`
  String get v3_lbl_streaming_view_mute {
    return Intl.message(
      'Mute audio',
      name: 'v3_lbl_streaming_view_mute',
      desc: '',
      args: [],
    );
  }

  /// `Unmute audio`
  String get v3_lbl_streaming_view_unmute {
    return Intl.message(
      'Unmute audio',
      name: 'v3_lbl_streaming_view_unmute',
      desc: '',
      args: [],
    );
  }

  /// `Stop streaming`
  String get v3_lbl_streaming_view_stop {
    return Intl.message(
      'Stop streaming',
      name: 'v3_lbl_streaming_view_stop',
      desc: '',
      args: [],
    );
  }

  /// `Collapse streaming features`
  String get v3_lbl_streaming_shortcut_minimize {
    return Intl.message(
      'Collapse streaming features',
      name: 'v3_lbl_streaming_shortcut_minimize',
      desc: '',
      args: [],
    );
  }

  /// `Expand streaming features`
  String get v3_lbl_streaming_shortcut_expand {
    return Intl.message(
      'Expand streaming features',
      name: 'v3_lbl_streaming_shortcut_expand',
      desc: '',
      args: [],
    );
  }

  /// `Streaming Shortcut Menu is locked`
  String get v3_lbl_streaming_shortcut_menu_locked {
    return Intl.message(
      'Streaming Shortcut Menu is locked',
      name: 'v3_lbl_streaming_shortcut_menu_locked',
      desc: '',
      args: [],
    );
  }

  /// `Open Streaming Shortcut Menu`
  String get v3_lbl_open_streaming_shortcut_menu {
    return Intl.message(
      'Open Streaming Shortcut Menu',
      name: 'v3_lbl_open_streaming_shortcut_menu',
      desc: '',
      args: [],
    );
  }

  /// `Close Streaming Shortcut menu`
  String get v3_lbl_close_streaming_shortcut_menu {
    return Intl.message(
      'Close Streaming Shortcut menu',
      name: 'v3_lbl_close_streaming_shortcut_menu',
      desc: '',
      args: [],
    );
  }

  /// `Cast to devices toggle`
  String get v3_lbl_streaming_shortcut_cast_device_toggle {
    return Intl.message(
      'Cast to devices toggle',
      name: 'v3_lbl_streaming_shortcut_cast_device_toggle',
      desc: '',
      args: [],
    );
  }

  /// `AirPlay toggle`
  String get v3_lbl_streaming_shortcut_airplay_toggle {
    return Intl.message(
      'AirPlay toggle',
      name: 'v3_lbl_streaming_shortcut_airplay_toggle',
      desc: '',
      args: [],
    );
  }

  /// `Google Cast toggle`
  String get v3_lbl_streaming_shortcut_google_cast_toggle {
    return Intl.message(
      'Google Cast toggle',
      name: 'v3_lbl_streaming_shortcut_google_cast_toggle',
      desc: '',
      args: [],
    );
  }

  /// `Miracast toggle`
  String get v3_lbl_streaming_shortcut_miracast_toggle {
    return Intl.message(
      'Miracast toggle',
      name: 'v3_lbl_streaming_shortcut_miracast_toggle',
      desc: '',
      args: [],
    );
  }

  /// `Open Streaming QR Code Menu`
  String get v3_lbl_open_streaming_qrcode_menu {
    return Intl.message(
      'Open Streaming QR Code Menu',
      name: 'v3_lbl_open_streaming_qrcode_menu',
      desc: '',
      args: [],
    );
  }

  /// `Minimize Streaming QR Code menu`
  String get v3_lbl_minimal_streaming_qrcode_menu {
    return Intl.message(
      'Minimize Streaming QR Code menu',
      name: 'v3_lbl_minimal_streaming_qrcode_menu',
      desc: '',
      args: [],
    );
  }

  /// `Open moderator list`
  String get v3_lbl_open_feature_set_moderator {
    return Intl.message(
      'Open moderator list',
      name: 'v3_lbl_open_feature_set_moderator',
      desc: '',
      args: [],
    );
  }

  /// `Close moderator list`
  String get v3_lbl_close_feature_set_moderator {
    return Intl.message(
      'Close moderator list',
      name: 'v3_lbl_close_feature_set_moderator',
      desc: '',
      args: [],
    );
  }

  /// `Share to this participant's screen`
  String get v3_lbl_participant_share {
    return Intl.message(
      'Share to this participant\'s screen',
      name: 'v3_lbl_participant_share',
      desc: '',
      args: [],
    );
  }

  /// `Cast device to this participant`
  String get v3_lbl_participant_cast_device {
    return Intl.message(
      'Cast device to this participant',
      name: 'v3_lbl_participant_cast_device',
      desc: '',
      args: [],
    );
  }

  /// `Close participant connection`
  String get v3_lbl_participant_close {
    return Intl.message(
      'Close participant connection',
      name: 'v3_lbl_participant_close',
      desc: '',
      args: [],
    );
  }

  /// `Stop participant's streaming`
  String get v3_lbl_participant_stop {
    return Intl.message(
      'Stop participant\'s streaming',
      name: 'v3_lbl_participant_stop',
      desc: '',
      args: [],
    );
  }

  /// `Enable touchback for this participant`
  String get v3_lbl_participant_touch_back {
    return Intl.message(
      'Enable touchback for this participant',
      name: 'v3_lbl_participant_touch_back',
      desc: '',
      args: [],
    );
  }

  /// `Disable touchback for this participant`
  String get v3_lbl_participant_touch_back_disable {
    return Intl.message(
      'Disable touchback for this participant',
      name: 'v3_lbl_participant_touch_back_disable',
      desc: '',
      args: [],
    );
  }

  /// `Disconnect this participant`
  String get v3_lbl_participant_disconnect {
    return Intl.message(
      'Disconnect this participant',
      name: 'v3_lbl_participant_disconnect',
      desc: '',
      args: [],
    );
  }

  /// `Share to this participant's mirror`
  String get v3_lbl_participant_mirror_share {
    return Intl.message(
      'Share to this participant\'s mirror',
      name: 'v3_lbl_participant_mirror_share',
      desc: '',
      args: [],
    );
  }

  /// `Close mirror participant connection`
  String get v3_lbl_participant_mirror_close {
    return Intl.message(
      'Close mirror participant connection',
      name: 'v3_lbl_participant_mirror_close',
      desc: '',
      args: [],
    );
  }

  /// `Stop mirror participant's streaming`
  String get v3_lbl_participant_mirror_stop {
    return Intl.message(
      'Stop mirror participant\'s streaming',
      name: 'v3_lbl_participant_mirror_stop',
      desc: '',
      args: [],
    );
  }

  /// `Open cast device list`
  String get v3_lbl_open_feature_set_cast_device {
    return Intl.message(
      'Open cast device list',
      name: 'v3_lbl_open_feature_set_cast_device',
      desc: '',
      args: [],
    );
  }

  /// `Close cast device list`
  String get v3_lbl_close_feature_set_cast_device {
    return Intl.message(
      'Close cast device list',
      name: 'v3_lbl_close_feature_set_cast_device',
      desc: '',
      args: [],
    );
  }

  /// `Enable touchback for cast device`
  String get v3_lbl_cast_device_touchback_enable {
    return Intl.message(
      'Enable touchback for cast device',
      name: 'v3_lbl_cast_device_touchback_enable',
      desc: '',
      args: [],
    );
  }

  /// `Disable touchback for cast device`
  String get v3_lbl_cast_device_touchback_disable {
    return Intl.message(
      'Disable touchback for cast device',
      name: 'v3_lbl_cast_device_touchback_disable',
      desc: '',
      args: [],
    );
  }

  /// `Close cast device connection`
  String get v3_lbl_cast_device_close {
    return Intl.message(
      'Close cast device connection',
      name: 'v3_lbl_cast_device_close',
      desc: '',
      args: [],
    );
  }

  /// `Cancel dialog`
  String get v3_lbl_message_dialog_cancel {
    return Intl.message(
      'Cancel dialog',
      name: 'v3_lbl_message_dialog_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Confirm dialog`
  String get v3_lbl_message_dialog_confirm {
    return Intl.message(
      'Confirm dialog',
      name: 'v3_lbl_message_dialog_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Close group reject notification`
  String get v3_lbl_group_reject_close {
    return Intl.message(
      'Close group reject notification',
      name: 'v3_lbl_group_reject_close',
      desc: '',
      args: [],
    );
  }

  /// `Do not extend casting time`
  String get v3_lbl_extend_casting_do_not_extend {
    return Intl.message(
      'Do not extend casting time',
      name: 'v3_lbl_extend_casting_do_not_extend',
      desc: '',
      args: [],
    );
  }

  /// `Extend casting time`
  String get v3_lbl_extend_casting_extend {
    return Intl.message(
      'Extend casting time',
      name: 'v3_lbl_extend_casting_extend',
      desc: '',
      args: [],
    );
  }

  /// `Mute presentation`
  String get v3_lbl_resizable_mute {
    return Intl.message(
      'Mute presentation',
      name: 'v3_lbl_resizable_mute',
      desc: '',
      args: [],
    );
  }

  /// `Stop presentation`
  String get v3_lbl_resizable_stop {
    return Intl.message(
      'Stop presentation',
      name: 'v3_lbl_resizable_stop',
      desc: '',
      args: [],
    );
  }

  /// `Minimize presentation control`
  String get v3_lbl_resizable_minimize {
    return Intl.message(
      'Minimize presentation control',
      name: 'v3_lbl_resizable_minimize',
      desc: '',
      args: [],
    );
  }

  /// `Expand presentation control`
  String get v3_lbl_resizable_expand {
    return Intl.message(
      'Expand presentation control',
      name: 'v3_lbl_resizable_expand',
      desc: '',
      args: [],
    );
  }

  /// `Minimize quick connect menu`
  String get v3_lbl_minimal_quick_connect_menu {
    return Intl.message(
      'Minimize quick connect menu',
      name: 'v3_lbl_minimal_quick_connect_menu',
      desc: '',
      args: [],
    );
  }

  /// `Open device setting menu`
  String get v3_lbl_settings_device_setting {
    return Intl.message(
      'Open device setting menu',
      name: 'v3_lbl_settings_device_setting',
      desc: '',
      args: [],
    );
  }

  /// `Open broadcast setting menu`
  String get v3_lbl_settings_broadcast {
    return Intl.message(
      'Open broadcast setting menu',
      name: 'v3_lbl_settings_broadcast',
      desc: '',
      args: [],
    );
  }

  /// `Open mirroring setting menu`
  String get v3_lbl_shortcuts_mirroring {
    return Intl.message(
      'Open mirroring setting menu',
      name: 'v3_lbl_shortcuts_mirroring',
      desc: '',
      args: [],
    );
  }

  /// `Open connectivity setting menu`
  String get v3_lbl_settings_connectivity {
    return Intl.message(
      'Open connectivity setting menu',
      name: 'v3_lbl_settings_connectivity',
      desc: '',
      args: [],
    );
  }

  /// `Open what's new setting menu`
  String get v3_lbl_settings_whats_new {
    return Intl.message(
      'Open what\'s new setting menu',
      name: 'v3_lbl_settings_whats_new',
      desc: '',
      args: [],
    );
  }

  /// `Open legal policy setting menu`
  String get v3_lbl_settings_legal_policy {
    return Intl.message(
      'Open legal policy setting menu',
      name: 'v3_lbl_settings_legal_policy',
      desc: '',
      args: [],
    );
  }

  /// `Modify device name`
  String get v3_lbl_settings_device_name {
    return Intl.message(
      'Modify device name',
      name: 'v3_lbl_settings_device_name',
      desc: '',
      args: [],
    );
  }

  /// `Enter device name`
  String get v3_lbl_settings_enter_device_name {
    return Intl.message(
      'Enter device name',
      name: 'v3_lbl_settings_enter_device_name',
      desc: '',
      args: [],
    );
  }

  /// `Close device name setting`
  String get v3_lbl_settings_device_name_close {
    return Intl.message(
      'Close device name setting',
      name: 'v3_lbl_settings_device_name_close',
      desc: '',
      args: [],
    );
  }

  /// `Save device name`
  String get v3_lbl_settings_device_name_save {
    return Intl.message(
      'Save device name',
      name: 'v3_lbl_settings_device_name_save',
      desc: '',
      args: [],
    );
  }

  /// `Select language`
  String get v3_lbl_main_language_title {
    return Intl.message(
      'Select language',
      name: 'v3_lbl_main_language_title',
      desc: '',
      args: [],
    );
  }

  /// `Select %s`
  String get v3_lbl_main_language_title_item {
    return Intl.message(
      'Select %s',
      name: 'v3_lbl_main_language_title_item',
      desc: '',
      args: [],
    );
  }

  /// `Turn on/off display code toggle`
  String get v3_lbl_settings_show_display_code {
    return Intl.message(
      'Turn on/off display code toggle',
      name: 'v3_lbl_settings_show_display_code',
      desc: '',
      args: [],
    );
  }

  /// `Turn on/off smart scaling toggle`
  String get v3_lbl_settings_device_smart_scaling {
    return Intl.message(
      'Turn on/off smart scaling toggle',
      name: 'v3_lbl_settings_device_smart_scaling',
      desc: '',
      args: [],
    );
  }

  /// `Open screen broadcasting dropdown menu`
  String get v3_lbl_settings_invite_group {
    return Intl.message(
      'Open screen broadcasting dropdown menu',
      name: 'v3_lbl_settings_invite_group',
      desc: '',
      args: [],
    );
  }

  /// `Select %s`
  String get v3_lbl_settings_invite_group_item {
    return Intl.message(
      'Select %s',
      name: 'v3_lbl_settings_invite_group_item',
      desc: '',
      args: [],
    );
  }

  /// `Turn on/off authorization mode`
  String get v3_lbl_settings_device_authorize_mode {
    return Intl.message(
      'Turn on/off authorization mode',
      name: 'v3_lbl_settings_device_authorize_mode',
      desc: '',
      args: [],
    );
  }

  /// `Turn on/off auto startup mode`
  String get v3_lbl_settings_device_launch_on_startup {
    return Intl.message(
      'Turn on/off auto startup mode',
      name: 'v3_lbl_settings_device_launch_on_startup',
      desc: '',
      args: [],
    );
  }

  /// `Turn on/off auto fill OTP mode`
  String get v3_lbl_settings_device_auto_fill_otp {
    return Intl.message(
      'Turn on/off auto fill OTP mode',
      name: 'v3_lbl_settings_device_auto_fill_otp',
      desc: '',
      args: [],
    );
  }

  /// `Open broadcast devices menu`
  String get v3_lbl_settings_broadcast_devices {
    return Intl.message(
      'Open broadcast devices menu',
      name: 'v3_lbl_settings_broadcast_devices',
      desc: '',
      args: [],
    );
  }

  /// `Open broadcast boards menu`
  String get v3_lbl_settings_broadcast_boards {
    return Intl.message(
      'Open broadcast boards menu',
      name: 'v3_lbl_settings_broadcast_boards',
      desc: '',
      args: [],
    );
  }

  /// `Open broadcast to display group menu`
  String get v3_lbl_settings_broadcast_to_display_group {
    return Intl.message(
      'Open broadcast to display group menu',
      name: 'v3_lbl_settings_broadcast_to_display_group',
      desc: '',
      args: [],
    );
  }

  /// `Select %s`
  String get v3_lbl_settings_broadcast_to_display_group_item {
    return Intl.message(
      'Select %s',
      name: 'v3_lbl_settings_broadcast_to_display_group_item',
      desc: '',
      args: [],
    );
  }

  /// `More information about broadcast to display group`
  String get v3_lbl_settings_only_when_casting_info {
    return Intl.message(
      'More information about broadcast to display group',
      name: 'v3_lbl_settings_only_when_casting_info',
      desc: '',
      args: [],
    );
  }

  /// `Turn on/off AirPlay`
  String get v3_lbl_shortcuts_airplay {
    return Intl.message(
      'Turn on/off AirPlay',
      name: 'v3_lbl_shortcuts_airplay',
      desc: '',
      args: [],
    );
  }

  /// `Turn on/off Google Cast`
  String get v3_lbl_shortcuts_google_cast {
    return Intl.message(
      'Turn on/off Google Cast',
      name: 'v3_lbl_shortcuts_google_cast',
      desc: '',
      args: [],
    );
  }

  /// `Turn on/off Miracast`
  String get v3_lbl_shortcuts_miracast {
    return Intl.message(
      'Turn on/off Miracast',
      name: 'v3_lbl_shortcuts_miracast',
      desc: '',
      args: [],
    );
  }

  /// `Turn on/off require passcode`
  String get v3_lbl_settings_mirroring_require_passcode {
    return Intl.message(
      'Turn on/off require passcode',
      name: 'v3_lbl_settings_mirroring_require_passcode',
      desc: '',
      args: [],
    );
  }

  /// `Turn on/off auto accept`
  String get v3_lbl_settings_mirroring_auto_accept {
    return Intl.message(
      'Turn on/off auto accept',
      name: 'v3_lbl_settings_mirroring_auto_accept',
      desc: '',
      args: [],
    );
  }

  /// `Select %s`
  String get v3_lbl_settings_connectivity_item {
    return Intl.message(
      'Select %s',
      name: 'v3_lbl_settings_connectivity_item',
      desc: '',
      args: [],
    );
  }

  /// `what's new icon`
  String get v3_lbl_settings_whats_new_icon {
    return Intl.message(
      'what\'s new icon',
      name: 'v3_lbl_settings_whats_new_icon',
      desc: '',
      args: [],
    );
  }

  /// `Select %s`
  String get v3_lbl_settings_open_source_license {
    return Intl.message(
      'Select %s',
      name: 'v3_lbl_settings_open_source_license',
      desc: '',
      args: [],
    );
  }

  /// `Back to previous page`
  String get v3_lbl_settings_back_icon {
    return Intl.message(
      'Back to previous page',
      name: 'v3_lbl_settings_back_icon',
      desc: '',
      args: [],
    );
  }

  /// `Close settings menu`
  String get v3_lbl_settings_close_icon {
    return Intl.message(
      'Close settings menu',
      name: 'v3_lbl_settings_close_icon',
      desc: '',
      args: [],
    );
  }

  /// `Miracast unavailable now. Current Wi-Fi channel does not support screen casting.`
  String get v3_miracast_not_support {
    return Intl.message(
      'Miracast unavailable now. Current Wi-Fi channel does not support screen casting.',
      name: 'v3_miracast_not_support',
      desc: '',
      args: [],
    );
  }

  /// `Airplay touchback`
  String get v3_lbl_streaming_airplay_touchback {
    return Intl.message(
      'Airplay touchback',
      name: 'v3_lbl_streaming_airplay_touchback',
      desc: '',
      args: [],
    );
  }

  /// `Confirm dialog`
  String get v3_lbl_touchback_one_device_confirm {
    return Intl.message(
      'Confirm dialog',
      name: 'v3_lbl_touchback_one_device_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Cancel dialog`
  String get v3_lbl_touchback_one_device_cancel {
    return Intl.message(
      'Cancel dialog',
      name: 'v3_lbl_touchback_one_device_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Touchback to %s？`
  String get v3_touchback_alert_title {
    return Intl.message(
      'Touchback to %s？',
      name: 'v3_touchback_alert_title',
      desc: '',
      args: [],
    );
  }

  /// `You can only touchback one device at one time.`
  String get v3_touchback_alert_message {
    return Intl.message(
      'You can only touchback one device at one time.',
      name: 'v3_touchback_alert_message',
      desc: '',
      args: [],
    );
  }

  /// `Pairing failed. TouchBack is not activated. Please try again`
  String get v3_touchback_fail_message {
    return Intl.message(
      'Pairing failed. TouchBack is not activated. Please try again',
      name: 'v3_touchback_fail_message',
      desc: '',
      args: [],
    );
  }

  /// `You can now control %s remotely from the IFP.`
  String get v3_touchback_success_message {
    return Intl.message(
      'You can now control %s remotely from the IFP.',
      name: 'v3_touchback_success_message',
      desc: '',
      args: [],
    );
  }

  /// `TouchBack is disabled.`
  String get v3_touchback_disable_message {
    return Intl.message(
      'TouchBack is disabled.',
      name: 'v3_touchback_disable_message',
      desc: '',
      args: [],
    );
  }

  /// `Initializing`
  String get v3_touchback_state_initializing_message {
    return Intl.message(
      'Initializing',
      name: 'v3_touchback_state_initializing_message',
      desc: '',
      args: [],
    );
  }

  /// `Hid Profile Service Starting`
  String get v3_touchback_state_hidProfileServiceStarting_message {
    return Intl.message(
      'Hid Profile Service Starting',
      name: 'v3_touchback_state_hidProfileServiceStarting_message',
      desc: '',
      args: [],
    );
  }

  /// `Hid Profile Service Started Success`
  String get v3_touchback_state_hidProfileServiceStartedSuccess_message {
    return Intl.message(
      'Hid Profile Service Started Success',
      name: 'v3_touchback_state_hidProfileServiceStartedSuccess_message',
      desc: '',
      args: [],
    );
  }

  /// `Device Finding`
  String get v3_touchback_state_deviceFinding_message {
    return Intl.message(
      'Device Finding',
      name: 'v3_touchback_state_deviceFinding_message',
      desc: '',
      args: [],
    );
  }

  /// `Device Found Success`
  String get v3_touchback_state_deviceFoundSuccess_message {
    return Intl.message(
      'Device Found Success',
      name: 'v3_touchback_state_deviceFoundSuccess_message',
      desc: '',
      args: [],
    );
  }

  /// `Device Pairing`
  String get v3_touchback_state_devicePairing_message {
    return Intl.message(
      'Device Pairing',
      name: 'v3_touchback_state_devicePairing_message',
      desc: '',
      args: [],
    );
  }

  /// `Device Paired Success`
  String get v3_touchback_state_devicePairedSuccess_message {
    return Intl.message(
      'Device Paired Success',
      name: 'v3_touchback_state_devicePairedSuccess_message',
      desc: '',
      args: [],
    );
  }

  /// `Hid Connecting`
  String get v3_touchback_state_hidConnecting_message {
    return Intl.message(
      'Hid Connecting',
      name: 'v3_touchback_state_hidConnecting_message',
      desc: '',
      args: [],
    );
  }

  /// `Hid Connected`
  String get v3_touchback_state_hidConnected_message {
    return Intl.message(
      'Hid Connected',
      name: 'v3_touchback_state_hidConnected_message',
      desc: '',
      args: [],
    );
  }

  /// `Initialized`
  String get v3_touchback_state_initialized_message {
    return Intl.message(
      'Initialized',
      name: 'v3_touchback_state_initialized_message',
      desc: '',
      args: [],
    );
  }

  /// `Device name cannot be empty`
  String get v3_settings_device_name_empty_error {
    return Intl.message(
      'Device name cannot be empty',
      name: 'v3_settings_device_name_empty_error',
      desc: '',
      args: [],
    );
  }

  /// `Normal`
  String get v3_settings_resize_text_size_normal {
    return Intl.message(
      'Normal',
      name: 'v3_settings_resize_text_size_normal',
      desc: '',
      args: [],
    );
  }

  /// `Large`
  String get v3_settings_resize_text_size_large {
    return Intl.message(
      'Large',
      name: 'v3_settings_resize_text_size_large',
      desc: '',
      args: [],
    );
  }

  /// `XLarge`
  String get v3_settings_resize_text_size_extra_large {
    return Intl.message(
      'XLarge',
      name: 'v3_settings_resize_text_size_extra_large',
      desc: '',
      args: [],
    );
  }

  /// `Accessibility`
  String get v3_settings_accessibility {
    return Intl.message(
      'Accessibility',
      name: 'v3_settings_accessibility',
      desc: '',
      args: [],
    );
  }

  /// `Resize text size`
  String get v3_settings_resize_text_size {
    return Intl.message(
      'Resize text size',
      name: 'v3_settings_resize_text_size',
      desc: '',
      args: [],
    );
  }

  /// `Accessibility`
  String get v3_lbl_settings_accessibility {
    return Intl.message(
      'Accessibility',
      name: 'v3_lbl_settings_accessibility',
      desc: '',
      args: [],
    );
  }

  /// `Operation timeout. Please turn off and restart the Bluetooth function on the large screen, then restart the touchback.`
  String get v3_touchback_restart_bluetooth_message {
    return Intl.message(
      'Operation timeout. Please turn off and restart the Bluetooth function on the large screen, then restart the touchback.',
      name: 'v3_touchback_restart_bluetooth_message',
      desc: '',
      args: [],
    );
  }

  /// `Operation timed out, please restart Bluetooth`
  String get v3_touchback_restart_bluetooth_title {
    return Intl.message(
      'Operation timed out, please restart Bluetooth',
      name: 'v3_touchback_restart_bluetooth_title',
      desc: '',
      args: [],
    );
  }

  /// `Restart`
  String get v3_touchback_restart_bluetooth_btn_restart {
    return Intl.message(
      'Restart',
      name: 'v3_touchback_restart_bluetooth_btn_restart',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get v3_lbl_touchback_restart_bluetooth_btn_cancel {
    return Intl.message(
      'Cancel',
      name: 'v3_lbl_touchback_restart_bluetooth_btn_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Restart`
  String get v3_lbl_touchback_restart_bluetooth_btn_restart {
    return Intl.message(
      'Restart',
      name: 'v3_lbl_touchback_restart_bluetooth_btn_restart',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get v3_touchback_restart_bluetooth_btn_cancel {
    return Intl.message(
      'Cancel',
      name: 'v3_touchback_restart_bluetooth_btn_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Floating connection information tab`
  String get v3_lbl_overlay_bring_app_to_top {
    return Intl.message(
      'Floating connection information tab',
      name: 'v3_lbl_overlay_bring_app_to_top',
      desc: '',
      args: [],
    );
  }

  /// `Expand overlay menu`
  String get v3_lbl_overlay_menu_expand {
    return Intl.message(
      'Expand overlay menu',
      name: 'v3_lbl_overlay_menu_expand',
      desc: '',
      args: [],
    );
  }

  /// `Minimize overlay menu`
  String get v3_lbl_overlay_menu_minimize {
    return Intl.message(
      'Minimize overlay menu',
      name: 'v3_lbl_overlay_menu_minimize',
      desc: '',
      args: [],
    );
  }

  /// `Select %s`
  String get v3_lbl_settings_broadcast_to_display_group_type {
    return Intl.message(
      'Select %s',
      name: 'v3_lbl_settings_broadcast_to_display_group_type',
      desc: '',
      args: [],
    );
  }

  /// `Select %s`
  String get v3_lbl_settings_broadcast_to_display_group_checkbox {
    return Intl.message(
      'Select %s',
      name: 'v3_lbl_settings_broadcast_to_display_group_checkbox',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get v3_lbl_settings_broadcast_to_display_group_save {
    return Intl.message(
      'Save',
      name: 'v3_lbl_settings_broadcast_to_display_group_save',
      desc: '',
      args: [],
    );
  }

  /// `Broadcast`
  String get v3_lbl_settings_broadcast_to_display_group_cast {
    return Intl.message(
      'Broadcast',
      name: 'v3_lbl_settings_broadcast_to_display_group_cast',
      desc: '',
      args: [],
    );
  }

  /// `Confirm no device selected.`
  String get v3_lbl_settings_broadcast_to_display_group_confirm {
    return Intl.message(
      'Confirm no device selected.',
      name: 'v3_lbl_settings_broadcast_to_display_group_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Invite to share`
  String get v3_help_center_share_title {
    return Intl.message(
      'Invite to share',
      name: 'v3_help_center_share_title',
      desc: '',
      args: [],
    );
  }

  /// `Devices sharing its screen to IFP.`
  String get v3_help_center_share_title_sub {
    return Intl.message(
      'Devices sharing its screen to IFP.',
      name: 'v3_help_center_share_title_sub',
      desc: '',
      args: [],
    );
  }

  /// `Cast to device`
  String get v3_help_center_cast_device_title {
    return Intl.message(
      'Cast to device',
      name: 'v3_help_center_cast_device_title',
      desc: '',
      args: [],
    );
  }

  /// `IFP casting its screen to devices.`
  String get v3_help_center_cast_device_title_sub {
    return Intl.message(
      'IFP casting its screen to devices.',
      name: 'v3_help_center_cast_device_title_sub',
      desc: '',
      args: [],
    );
  }

  /// `Touchback`
  String get v3_help_center_touchback_title {
    return Intl.message(
      'Touchback',
      name: 'v3_help_center_touchback_title',
      desc: '',
      args: [],
    );
  }

  /// `Allowing user remote control.`
  String get v3_help_center_touchback_title_sub {
    return Intl.message(
      'Allowing user remote control.',
      name: 'v3_help_center_touchback_title_sub',
      desc: '',
      args: [],
    );
  }

  /// `Untouchback`
  String get v3_help_center_untouchback_title {
    return Intl.message(
      'Untouchback',
      name: 'v3_help_center_untouchback_title',
      desc: '',
      args: [],
    );
  }

  /// `Detach touchback mode.`
  String get v3_help_center_untouchback_title_sub {
    return Intl.message(
      'Detach touchback mode.',
      name: 'v3_help_center_untouchback_title_sub',
      desc: '',
      args: [],
    );
  }

  /// `Fullscreen`
  String get v3_help_center_fullscreen_title {
    return Intl.message(
      'Fullscreen',
      name: 'v3_help_center_fullscreen_title',
      desc: '',
      args: [],
    );
  }

  /// `Mute user`
  String get v3_help_center_mute_user_title {
    return Intl.message(
      'Mute user',
      name: 'v3_help_center_mute_user_title',
      desc: '',
      args: [],
    );
  }

  /// `Remove user`
  String get v3_help_center_remove_user_title {
    return Intl.message(
      'Remove user',
      name: 'v3_help_center_remove_user_title',
      desc: '',
      args: [],
    );
  }

  /// `Stop sharing`
  String get v3_help_center_stop_share_title {
    return Intl.message(
      'Stop sharing',
      name: 'v3_help_center_stop_share_title',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get v3_help_center_close {
    return Intl.message(
      'Close',
      name: 'v3_help_center_close',
      desc: '',
      args: [],
    );
  }

  /// `Help Center`
  String get v3_help_center_title {
    return Intl.message(
      'Help Center',
      name: 'v3_help_center_title',
      desc: '',
      args: [],
    );
  }

  /// `Open Help center menu`
  String get v3_lbl_open_help_center {
    return Intl.message(
      'Open Help center menu',
      name: 'v3_lbl_open_help_center',
      desc: '',
      args: [],
    );
  }

  /// `Close help center`
  String get v3_lbl_close_help_center {
    return Intl.message(
      'Close help center',
      name: 'v3_lbl_close_help_center',
      desc: '',
      args: [],
    );
  }

  /// `Knowledge Base`
  String get v3_settings_knowledge_base {
    return Intl.message(
      'Knowledge Base',
      name: 'v3_settings_knowledge_base',
      desc: '',
      args: [],
    );
  }

  /// `Knowledge Base`
  String get v3_lbl_settings_knowledge_base {
    return Intl.message(
      'Knowledge Base',
      name: 'v3_lbl_settings_knowledge_base',
      desc: '',
      args: [],
    );
  }

  /// `High image quality`
  String get v3_settings_device_high_image_quality {
    return Intl.message(
      'High image quality',
      name: 'v3_settings_device_high_image_quality',
      desc: '',
      args: [],
    );
  }

  /// `High image quality`
  String get v3_lbl_settings_device_high_image_quality {
    return Intl.message(
      'High image quality',
      name: 'v3_lbl_settings_device_high_image_quality',
      desc: '',
      args: [],
    );
  }

  /// `next page`
  String get v3_lbl_streaming_page_control {
    return Intl.message(
      'next page',
      name: 'v3_lbl_streaming_page_control',
      desc: '',
      args: [],
    );
  }

  /// `Display code`
  String get v3_instruction2_onethird {
    return Intl.message(
      'Display code',
      name: 'v3_instruction2_onethird',
      desc: '',
      args: [],
    );
  }

  /// `One-time password`
  String get v3_instruction3_onethird {
    return Intl.message(
      'One-time password',
      name: 'v3_instruction3_onethird',
      desc: '',
      args: [],
    );
  }

  /// `This source does not support Miracast touchback`
  String get v3_miracast_uibc_not_supported_message {
    return Intl.message(
      'This source does not support Miracast touchback',
      name: 'v3_miracast_uibc_not_supported_message',
      desc: '',
      args: [],
    );
  }

  /// `next page`
  String get v3_lbl_cast_device_next {
    return Intl.message(
      'next page',
      name: 'v3_lbl_cast_device_next',
      desc: '',
      args: [],
    );
  }

  /// `previous page`
  String get v3_lbl_cast_device_previous {
    return Intl.message(
      'previous page',
      name: 'v3_lbl_cast_device_previous',
      desc: '',
      args: [],
    );
  }

  /// `sort asc`
  String get v3_lbl_cast_device_sort_asc {
    return Intl.message(
      'sort asc',
      name: 'v3_lbl_cast_device_sort_asc',
      desc: '',
      args: [],
    );
  }

  /// `sort desc`
  String get v3_lbl_cast_device_sort_desc {
    return Intl.message(
      'sort desc',
      name: 'v3_lbl_cast_device_sort_desc',
      desc: '',
      args: [],
    );
  }

  /// `Device version is not supported`
  String get v3_settings_device_not_supported {
    return Intl.message(
      'Device version is not supported',
      name: 'v3_settings_device_not_supported',
      desc: '',
      args: [],
    );
  }

  /// `Cast to 10-100 Devices`
  String get v3_broadcast_multicast_checkbox {
    return Intl.message(
      'Cast to 10-100 Devices',
      name: 'v3_broadcast_multicast_checkbox',
      desc: '',
      args: [],
    );
  }

  /// `The number of receiving devices cannot be changed when the projection starts.`
  String get v3_broadcast_multicast_desc {
    return Intl.message(
      'The number of receiving devices cannot be changed when the projection starts.',
      name: 'v3_broadcast_multicast_desc',
      desc: '',
      args: [],
    );
  }

  /// `Interrupt all projection to edit.`
  String get v3_broadcast_multicast_warn {
    return Intl.message(
      'Interrupt all projection to edit.',
      name: 'v3_broadcast_multicast_warn',
      desc: '',
      args: [],
    );
  }

  /// `Casting in progress`
  String get v3_broadcast_cast_device_on {
    return Intl.message(
      'Casting in progress',
      name: 'v3_broadcast_cast_device_on',
      desc: '',
      args: [],
    );
  }

  /// `Casting in progress`
  String get v3_broadcast_cast_board_on {
    return Intl.message(
      'Casting in progress',
      name: 'v3_broadcast_cast_board_on',
      desc: '',
      args: [],
    );
  }

  /// `Cast to 10-100 Devices`
  String get v3_lbl_broadcast_multicast_checkbox {
    return Intl.message(
      'Cast to 10-100 Devices',
      name: 'v3_lbl_broadcast_multicast_checkbox',
      desc: '',
      args: [],
    );
  }

  /// `Maximum UHD (4K) screen sharing from web sender and 3K+ from Windows and macOS sender depending on the sender screen resolution. Requires a high quality network.`
  String get v3_settings_device_high_image_quality_on_desc {
    return Intl.message(
      'Maximum UHD (4K) screen sharing from web sender and 3K+ from Windows and macOS sender depending on the sender screen resolution. Requires a high quality network.',
      name: 'v3_settings_device_high_image_quality_on_desc',
      desc: '',
      args: [],
    );
  }

  /// `Maximum QHD (2K) screen sharing depending on the sender screen resolution.`
  String get v3_settings_device_high_image_quality_off_desc {
    return Intl.message(
      'Maximum QHD (2K) screen sharing depending on the sender screen resolution.',
      name: 'v3_settings_device_high_image_quality_off_desc',
      desc: '',
      args: [],
    );
  }

  /// `Launch`
  String get v3_lbl_eula_launch {
    return Intl.message(
      'Launch',
      name: 'v3_lbl_eula_launch',
      desc: '',
      args: [],
    );
  }

  /// `Launch`
  String get v3_eula_launch {
    return Intl.message('Launch', name: 'v3_eula_launch', desc: '', args: []);
  }

  /// `Participants would like to share their screen`
  String get v3_authorize_prompt_title_launcher {
    return Intl.message(
      'Participants would like to share their screen',
      name: 'v3_authorize_prompt_title_launcher',
      desc: '',
      args: [],
    );
  }

  /// `Moderator mode`
  String get v3_settings_moderator_mode {
    return Intl.message(
      'Moderator mode',
      name: 'v3_settings_moderator_mode',
      desc: '',
      args: [],
    );
  }

  /// `Turn on/off moderator mode`
  String get v3_lbl_settings_moderator_mode {
    return Intl.message(
      'Turn on/off moderator mode',
      name: 'v3_lbl_settings_moderator_mode',
      desc: '',
      args: [],
    );
  }

  /// `Uncheck “Require approval” in the Settings menu to accept all casting requests.`
  String get v3_authorize_prompt_notification_cast {
    return Intl.message(
      'Uncheck “Require approval” in the Settings menu to accept all casting requests.',
      name: 'v3_authorize_prompt_notification_cast',
      desc: '',
      args: [],
    );
  }

  /// `Check “Auto Accept” in the Settings menu to accept all mirror requests.`
  String get v3_authorize_prompt_notification_mirror {
    return Intl.message(
      'Check “Auto Accept” in the Settings menu to accept all mirror requests.',
      name: 'v3_authorize_prompt_notification_mirror',
      desc: '',
      args: [],
    );
  }

  /// `Permission required`
  String get v3_permission_title {
    return Intl.message(
      'Permission required',
      name: 'v3_permission_title',
      desc: '',
      args: [],
    );
  }

  /// `Please go to device "Setting" then "App" menu to grant the permission.`
  String get v3_permission_description {
    return Intl.message(
      'Please go to device "Setting" then "App" menu to grant the permission.',
      name: 'v3_permission_description',
      desc: '',
      args: [],
    );
  }

  /// `Exit`
  String get v3_lbl_permission_exit {
    return Intl.message(
      'Exit',
      name: 'v3_lbl_permission_exit',
      desc: '',
      args: [],
    );
  }

  /// `Exit`
  String get v3_permission_exit {
    return Intl.message('Exit', name: 'v3_permission_exit', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'da'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'es'),
      Locale.fromSubtags(languageCode: 'et'),
      Locale.fromSubtags(languageCode: 'fi'),
      Locale.fromSubtags(languageCode: 'fr'),
      Locale.fromSubtags(languageCode: 'ja'),
      Locale.fromSubtags(languageCode: 'lt'),
      Locale.fromSubtags(languageCode: 'lv'),
      Locale.fromSubtags(languageCode: 'no'),
      Locale.fromSubtags(languageCode: 'pl'),
      Locale.fromSubtags(languageCode: 'sv'),
      Locale.fromSubtags(languageCode: 'tr'),
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
