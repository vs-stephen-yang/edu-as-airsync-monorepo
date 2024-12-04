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
    return Intl.message(
      'AirSync EULA',
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

  /// `Cast your screen to multiple devices, including laptops, tablets and mobile devices simultaneously.`
  String get v3_shortcuts_cast_device_desc {
    return Intl.message(
      'Cast your screen to multiple devices, including laptops, tablets and mobile devices simultaneously.',
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

  /// `Enable one-touch connection when selecting a device from the device list.`
  String get v3_settings_device_auto_fill_otp_desc {
    return Intl.message(
      'Enable one-touch connection when selecting a device from the device list.',
      name: 'v3_settings_device_auto_fill_otp_desc',
      desc: '',
      args: [],
    );
  }

  /// `Allow screen sharing only with approval requests.`
  String get v3_settings_device_authorize_mode {
    return Intl.message(
      'Allow screen sharing only with approval requests.',
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

  /// `Share your screen to all Interactive Flat Panels (IFPs) in the network.`
  String get v3_settings_broadcast_cast_boards_desc {
    return Intl.message(
      'Share your screen to all Interactive Flat Panels (IFPs) in the network.',
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

  /// `AirSync %s\n\nAirSync is a ViewSonic proprietary wireless screen-sharing solution. When used with the AirSync sender, it enables seamless screen sharing from a user's device to ViewSonic interactive displays.\n\nKey features: \n\n1. Wireless screensharing.\n\n2. Automatic split screens for multiple presenters.\n\n3. Moderator mode to enable more control during presentation.\n\n4. Screen mirror to support AirPlay, Google Cast and Miracast.\n\n5. Cast to device with remote control.\n\n6. Cast to board to broadcast screens to multiple large screens.\n\n7. Annotation.\n\n8. Interact with Windows, macOS, iOS, Android and web version AirSync sender.\n\n9. Touchback is supported in Windows and macOS sender.\n\n`
  String get v3_settings_whats_new_content {
    return Intl.message(
      'AirSync %s\n\nAirSync is a ViewSonic proprietary wireless screen-sharing solution. When used with the AirSync sender, it enables seamless screen sharing from a user\'s device to ViewSonic interactive displays.\n\nKey features: \n\n1. Wireless screensharing.\n\n2. Automatic split screens for multiple presenters.\n\n3. Moderator mode to enable more control during presentation.\n\n4. Screen mirror to support AirPlay, Google Cast and Miracast.\n\n5. Cast to device with remote control.\n\n6. Cast to board to broadcast screens to multiple large screens.\n\n7. Annotation.\n\n8. Interact with Windows, macOS, iOS, Android and web version AirSync sender.\n\n9. Touchback is supported in Windows and macOS sender.\n\n',
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
    return Intl.message(
      'Agree',
      name: 'v3_eula_agree',
      desc: '',
      args: [],
    );
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

  /// `Cast to`
  String get v3_settings_broadcast_cast_to {
    return Intl.message(
      'Cast to',
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
    return Intl.message(
      'OR',
      name: 'v3_download_app_or',
      desc: '',
      args: [],
    );
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
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'pl'),
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
