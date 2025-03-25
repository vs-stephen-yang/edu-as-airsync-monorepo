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

  /// `The max number of moderated sessions has been reached.`
  String get toast_maximum_moderated {
    return Intl.message(
      'The max number of moderated sessions has been reached.',
      name: 'toast_maximum_moderated',
      desc: '',
      args: [],
    );
  }

  /// `The max number of split screens has been reached.`
  String get toast_maximum_split_screen {
    return Intl.message(
      'The max number of split screens has been reached.',
      name: 'toast_maximum_split_screen',
      desc: '',
      args: [],
    );
  }

  /// `Sharing is being processed. Please wait.`
  String get remote_screen_wait {
    return Intl.message(
      'Sharing is being processed. Please wait.',
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

  /// `Please enable share screen to device in AirSync.`
  String get toast_enable_remote_screen {
    return Intl.message(
      'Please enable share screen to device in AirSync.',
      name: 'toast_enable_remote_screen',
      desc: '',
      args: [],
    );
  }

  /// `The max number of shared screens has been reached.`
  String get toast_maximum_remote_screen {
    return Intl.message(
      'The max number of shared screens has been reached.',
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

  /// `The AirSync instance is busy. Please try again later.`
  String get main_connect_rate_limited {
    return Intl.message(
      'The AirSync instance is busy. Please try again later.',
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

  /// `AirSync cannot connect to the Internet.`
  String get main_connection_mode_unsupported {
    return Intl.message(
      'AirSync cannot connect to the Internet.',
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

  /// `Accepts only letters and numbers.`
  String get main_display_code_error {
    return Intl.message(
      'Accepts only letters and numbers.',
      name: 'main_display_code_error',
      desc: '',
      args: [],
    );
  }

  /// `Accepts only numbers.`
  String get main_otp_error {
    return Intl.message(
      'Accepts only numbers.',
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

  /// `New version available`
  String get main_update_title {
    return Intl.message(
      'New version available',
      name: 'main_update_title',
      desc: '',
      args: [],
    );
  }

  /// `Please click "Update" to install the new version.`
  String get main_update_description_apple {
    return Intl.message(
      'Please click "Update" to install the new version.',
      name: 'main_update_description_apple',
      desc: '',
      args: [],
    );
  }

  /// `Please click "Update" to install the new version.`
  String get main_update_description_android {
    return Intl.message(
      'Please click "Update" to install the new version.',
      name: 'main_update_description_android',
      desc: '',
      args: [],
    );
  }

  /// `Please click "Update" to install the new version.`
  String get main_update_description_windows {
    return Intl.message(
      'Please click "Update" to install the new version.',
      name: 'main_update_description_windows',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get main_update_positive_button {
    return Intl.message(
      'Update',
      name: 'main_update_positive_button',
      desc: '',
      args: [],
    );
  }

  /// `Not now`
  String get main_update_deny_button {
    return Intl.message(
      'Not now',
      name: 'main_update_deny_button',
      desc: '',
      args: [],
    );
  }

  /// `Version update fail`
  String get main_update_error_title {
    return Intl.message(
      'Version update fail',
      name: 'main_update_error_title',
      desc: '',
      args: [],
    );
  }

  /// `Fail reason: `
  String get main_update_error_type {
    return Intl.message(
      'Fail reason: ',
      name: 'main_update_error_type',
      desc: '',
      args: [],
    );
  }

  /// `Description: `
  String get main_update_error_detail {
    return Intl.message(
      'Description: ',
      name: 'main_update_error_detail',
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

  /// `High Quality`
  String get present_state_high_quality_title {
    return Intl.message(
      'High Quality',
      name: 'present_state_high_quality_title',
      desc: '',
      args: [],
    );
  }

  /// `Enable High Quality in good network conditions.`
  String get present_state_high_quality_description {
    return Intl.message(
      'Enable High Quality in good network conditions.',
      name: 'present_state_high_quality_description',
      desc: '',
      args: [],
    );
  }

  /// `Notice`
  String get main_notice_title {
    return Intl.message(
      'Notice',
      name: 'main_notice_title',
      desc: '',
      args: [],
    );
  }

  /// `Sharing through the browser is not supported on mobile devices. Please download and use the AirSync sender app for a better experience.`
  String get main_notice_not_support_description {
    return Intl.message(
      'Sharing through the browser is not supported on mobile devices. Please download and use the AirSync sender app for a better experience.',
      name: 'main_notice_not_support_description',
      desc: '',
      args: [],
    );
  }

  /// `Download AirSync sender app.`
  String get main_notice_positive_button {
    return Intl.message(
      'Download AirSync sender app.',
      name: 'main_notice_positive_button',
      desc: '',
      args: [],
    );
  }

  /// `Click "Start broadcast" to resume sharing before timeout or click "Back" to return to initial screen.`
  String get present_select_screen_ios_restart_description {
    return Intl.message(
      'Click "Start broadcast" to resume sharing before timeout or click "Back" to return to initial screen.',
      name: 'present_select_screen_ios_restart_description',
      desc: '',
      args: [],
    );
  }

  /// `Start broadcast`
  String get present_select_screen_ios_restart {
    return Intl.message(
      'Start broadcast',
      name: 'present_select_screen_ios_restart',
      desc: '',
      args: [],
    );
  }

  /// `Remote screen connection error`
  String get remote_screen_connect_error {
    return Intl.message(
      'Remote screen connection error',
      name: 'remote_screen_connect_error',
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

  /// `Download Sender App`
  String get v3_main_download {
    return Intl.message(
      'Download Sender App',
      name: 'v3_main_download',
      desc: '',
      args: [],
    );
  }

  /// `Get your AirSync sender app`
  String get v3_main_download_title {
    return Intl.message(
      'Get your AirSync sender app',
      name: 'v3_main_download_title',
      desc: '',
      args: [],
    );
  }

  /// `Effortless screen sharing with one-click connect.`
  String get v3_main_download_desc {
    return Intl.message(
      'Effortless screen sharing with one-click connect.',
      name: 'v3_main_download_desc',
      desc: '',
      args: [],
    );
  }

  /// `Windows`
  String get v3_main_download_win_title {
    return Intl.message(
      'Windows',
      name: 'v3_main_download_win_title',
      desc: '',
      args: [],
    );
  }

  /// `Win 10 (1709+)/ Win 11`
  String get v3_main_download_win_subtitle {
    return Intl.message(
      'Win 10 (1709+)/ Win 11',
      name: 'v3_main_download_win_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Mac`
  String get v3_main_download_mac_title {
    return Intl.message(
      'Mac',
      name: 'v3_main_download_mac_title',
      desc: '',
      args: [],
    );
  }

  /// `macOS 10.15+`
  String get v3_main_download_mac_subtitle {
    return Intl.message(
      'macOS 10.15+',
      name: 'v3_main_download_mac_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `AirSync App`
  String get v3_main_download_app_title {
    return Intl.message(
      'AirSync App',
      name: 'v3_main_download_app_title',
      desc: '',
      args: [],
    );
  }

  /// `iOS and Android`
  String get v3_main_download_app_subtitle {
    return Intl.message(
      'iOS and Android',
      name: 'v3_main_download_app_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get v3_main_download_action_download {
    return Intl.message(
      'Download',
      name: 'v3_main_download_action_download',
      desc: '',
      args: [],
    );
  }

  /// `Get`
  String get v3_main_download_action_get {
    return Intl.message(
      'Get',
      name: 'v3_main_download_action_get',
      desc: '',
      args: [],
    );
  }

  /// `Download Sender App`
  String get v3_main_download_app_dialog_title {
    return Intl.message(
      'Download Sender App',
      name: 'v3_main_download_app_dialog_title',
      desc: '',
      args: [],
    );
  }

  /// `Scan the QR code with your iOS or Android device to download`
  String get v3_main_download_app_dialog_desc {
    return Intl.message(
      'Scan the QR code with your iOS or Android device to download',
      name: 'v3_main_download_app_dialog_desc',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get v3_main_privacy {
    return Intl.message(
      'Privacy Policy',
      name: 'v3_main_privacy',
      desc: '',
      args: [],
    );
  }

  /// `Terms of use`
  String get v3_main_terms {
    return Intl.message(
      'Terms of use',
      name: 'v3_main_terms',
      desc: '',
      args: [],
    );
  }

  /// `Accessibility`
  String get v3_main_accessibility {
    return Intl.message(
      'Accessibility',
      name: 'v3_main_accessibility',
      desc: '',
      args: [],
    );
  }

  /// `Copyright © ViewSonic Corporation {year}. All rights reserved.`
  String v3_main_copy_rights(Object year) {
    return Intl.message(
      'Copyright © ViewSonic Corporation $year. All rights reserved.',
      name: 'v3_main_copy_rights',
      desc: '',
      args: [year],
    );
  }

  /// `Share your screen`
  String get v3_main_present_title {
    return Intl.message(
      'Share your screen',
      name: 'v3_main_present_title',
      desc: '',
      args: [],
    );
  }

  /// `Follow the steps to get started.`
  String get v3_main_present_subtitle {
    return Intl.message(
      'Follow the steps to get started.',
      name: 'v3_main_present_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Display code`
  String get v3_main_display_code {
    return Intl.message(
      'Display code',
      name: 'v3_main_display_code',
      desc: '',
      args: [],
    );
  }

  /// `Only accept numbers.`
  String get v3_main_display_code_error {
    return Intl.message(
      'Only accept numbers.',
      name: 'v3_main_display_code_error',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get v3_main_password {
    return Intl.message(
      'Password',
      name: 'v3_main_password',
      desc: '',
      args: [],
    );
  }

  /// `Only accept numbers.`
  String get v3_main_otp_error {
    return Intl.message(
      'Only accept numbers.',
      name: 'v3_main_otp_error',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get v3_main_present_action {
    return Intl.message(
      'Next',
      name: 'v3_main_present_action',
      desc: '',
      args: [],
    );
  }

  /// `Display code not found or instance is offline.`
  String get v3_main_instance_not_found_or_offline {
    return Intl.message(
      'Display code not found or instance is offline.',
      name: 'v3_main_instance_not_found_or_offline',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Display code`
  String get v3_main_display_code_invalid {
    return Intl.message(
      'Invalid Display code',
      name: 'v3_main_display_code_invalid',
      desc: '',
      args: [],
    );
  }

  /// `Network connectivity error.`
  String get v3_main_connect_network_error {
    return Intl.message(
      'Network connectivity error.',
      name: 'v3_main_connect_network_error',
      desc: '',
      args: [],
    );
  }

  /// `Password invalid.`
  String get v3_main_password_invalid {
    return Intl.message(
      'Password invalid.',
      name: 'v3_main_password_invalid',
      desc: '',
      args: [],
    );
  }

  /// `AirSync instance is busy. Please try it later.`
  String get v3_main_connect_rate_limited {
    return Intl.message(
      'AirSync instance is busy. Please try it later.',
      name: 'v3_main_connect_rate_limited',
      desc: '',
      args: [],
    );
  }

  /// `Your receiver does not support Internet screen sharing temporarily.`
  String get v3_main_connection_mode_unsupported {
    return Intl.message(
      'Your receiver does not support Internet screen sharing temporarily.',
      name: 'v3_main_connection_mode_unsupported',
      desc: '',
      args: [],
    );
  }

  /// `Unknown error.`
  String get v3_main_connect_unknown_error {
    return Intl.message(
      'Unknown error.',
      name: 'v3_main_connect_unknown_error',
      desc: '',
      args: [],
    );
  }

  /// `Please wait for the host to approve your request.`
  String get v3_main_authorize_wait {
    return Intl.message(
      'Please wait for the host to approve your request.',
      name: 'v3_main_authorize_wait',
      desc: '',
      args: [],
    );
  }

  /// `Choose your presentation mode`
  String get v3_main_select_role_title {
    return Intl.message(
      'Choose your presentation mode',
      name: 'v3_main_select_role_title',
      desc: '',
      args: [],
    );
  }

  /// `Share`
  String get v3_main_select_role_share {
    return Intl.message(
      'Share',
      name: 'v3_main_select_role_share',
      desc: '',
      args: [],
    );
  }

  /// `Receive`
  String get v3_main_select_role_receive {
    return Intl.message(
      'Receive',
      name: 'v3_main_select_role_receive',
      desc: '',
      args: [],
    );
  }

  /// `Share your screen`
  String get v3_main_moderator_title {
    return Intl.message(
      'Share your screen',
      name: 'v3_main_moderator_title',
      desc: '',
      args: [],
    );
  }

  /// `Type your presentation title`
  String get v3_main_moderator_subtitle {
    return Intl.message(
      'Type your presentation title',
      name: 'v3_main_moderator_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Share`
  String get v3_main_moderator_app_title {
    return Intl.message(
      'Share',
      name: 'v3_main_moderator_app_title',
      desc: '',
      args: [],
    );
  }

  /// `Type your name before sharing your screen`
  String get v3_main_moderator_app_subtitle {
    return Intl.message(
      'Type your name before sharing your screen',
      name: 'v3_main_moderator_app_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Share`
  String get v3_main_moderator_action {
    return Intl.message(
      'Share',
      name: 'v3_main_moderator_action',
      desc: '',
      args: [],
    );
  }

  /// `Type your name`
  String get v3_main_moderator_input_hint {
    return Intl.message(
      'Type your name',
      name: 'v3_main_moderator_input_hint',
      desc: '',
      args: [],
    );
  }

  /// `Please limit the name to 20 characters.`
  String get v3_main_moderator_input_limit {
    return Intl.message(
      'Please limit the name to 20 characters.',
      name: 'v3_main_moderator_input_limit',
      desc: '',
      args: [],
    );
  }

  /// `Wait for moderator to invite you to share`
  String get v3_main_moderator_wait {
    return Intl.message(
      'Wait for moderator to invite you to share',
      name: 'v3_main_moderator_wait',
      desc: '',
      args: [],
    );
  }

  /// `Disconnect`
  String get v3_main_moderator_disconnect {
    return Intl.message(
      'Disconnect',
      name: 'v3_main_moderator_disconnect',
      desc: '',
      args: [],
    );
  }

  /// `Receive`
  String get v3_main_receive_app_title {
    return Intl.message(
      'Receive',
      name: 'v3_main_receive_app_title',
      desc: '',
      args: [],
    );
  }

  /// `Share screen to my device`
  String get v3_main_receive_app_subtitle {
    return Intl.message(
      'Share screen to my device',
      name: 'v3_main_receive_app_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Connect`
  String get v3_main_receive_app_action {
    return Intl.message(
      'Connect',
      name: 'v3_main_receive_app_action',
      desc: '',
      args: [],
    );
  }

  /// `Receive from %s`
  String get v3_main_receive_app_receive_from {
    return Intl.message(
      'Receive from %s',
      name: 'v3_main_receive_app_receive_from',
      desc: '',
      args: [],
    );
  }

  /// `Stop`
  String get v3_main_receive_app_stop {
    return Intl.message(
      'Stop',
      name: 'v3_main_receive_app_stop',
      desc: '',
      args: [],
    );
  }

  /// `airsync.net is sharing your screen.`
  String get v3_main_presenting_message {
    return Intl.message(
      'airsync.net is sharing your screen.',
      name: 'v3_main_presenting_message',
      desc: '',
      args: [],
    );
  }

  /// `Quick connect by scan the QR code`
  String get v3_scan_qr_reminder {
    return Intl.message(
      'Quick connect by scan the QR code',
      name: 'v3_scan_qr_reminder',
      desc: '',
      args: [],
    );
  }

  /// `Enter one-time password`
  String get v3_device_list_dialog_title {
    return Intl.message(
      'Enter one-time password',
      name: 'v3_device_list_dialog_title',
      desc: '',
      args: [],
    );
  }

  /// `Connect`
  String get v3_device_list_dialog_connect {
    return Intl.message(
      'Connect',
      name: 'v3_device_list_dialog_connect',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect one-time password`
  String get v3_device_list_dialog_invalid_otp {
    return Intl.message(
      'Incorrect one-time password',
      name: 'v3_device_list_dialog_invalid_otp',
      desc: '',
      args: [],
    );
  }

  /// `Quick connect by`
  String get v3_device_list_button_text {
    return Intl.message(
      'Quick connect by',
      name: 'v3_device_list_button_text',
      desc: '',
      args: [],
    );
  }

  /// `Device List`
  String get v3_device_list_button_device_list {
    return Intl.message(
      'Device List',
      name: 'v3_device_list_button_device_list',
      desc: '',
      args: [],
    );
  }

  /// `%s wants to share your screen. Choose what to share.`
  String get v3_present_select_screen_subtitle {
    return Intl.message(
      '%s wants to share your screen. Choose what to share.',
      name: 'v3_present_select_screen_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Share computer audio.`
  String get v3_present_select_screen_share_audio {
    return Intl.message(
      'Share computer audio.',
      name: 'v3_present_select_screen_share_audio',
      desc: '',
      args: [],
    );
  }

  /// `Screen extension`
  String get v3_present_select_screen_extension {
    return Intl.message(
      'Screen extension',
      name: 'v3_present_select_screen_extension',
      desc: '',
      args: [],
    );
  }

  /// `Expand Your Workspace`
  String get v3_present_select_screen_extension_desc {
    return Intl.message(
      'Expand Your Workspace',
      name: 'v3_present_select_screen_extension_desc',
      desc: '',
      args: [],
    );
  }

  /// `Drag content between your personal device and the IFP, enhancing real-time interaction and control.`
  String get v3_present_select_screen_extension_desc2 {
    return Intl.message(
      'Drag content between your personal device and the IFP, enhancing real-time interaction and control.',
      name: 'v3_present_select_screen_extension_desc2',
      desc: '',
      args: [],
    );
  }

  /// `Session Full`
  String get v3_present_session_full {
    return Intl.message(
      'Session Full',
      name: 'v3_present_session_full',
      desc: '',
      args: [],
    );
  }

  /// `Unable to join. The session has reached its max limit.`
  String get v3_present_session_full_description {
    return Intl.message(
      'Unable to join. The session has reached its max limit.',
      name: 'v3_present_session_full_description',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get v3_present_session_full_action {
    return Intl.message(
      'OK',
      name: 'v3_present_session_full_action',
      desc: '',
      args: [],
    );
  }

  /// `Screen Full`
  String get v3_present_screen_full {
    return Intl.message(
      'Screen Full',
      name: 'v3_present_screen_full',
      desc: '',
      args: [],
    );
  }

  /// `The max number of split screens  has been reached.`
  String get v3_present_screen_full_description {
    return Intl.message(
      'The max number of split screens  has been reached.',
      name: 'v3_present_screen_full_description',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get v3_present_screen_full_action {
    return Intl.message(
      'OK',
      name: 'v3_present_screen_full_action',
      desc: '',
      args: [],
    );
  }

  /// `High Quality`
  String get v3_present_options_menu_hq_title {
    return Intl.message(
      'High Quality',
      name: 'v3_present_options_menu_hq_title',
      desc: '',
      args: [],
    );
  }

  /// `Use a higher bitrate to transmit the stream.`
  String get v3_present_options_menu_hq_subtitle {
    return Intl.message(
      'Use a higher bitrate to transmit the stream.',
      name: 'v3_present_options_menu_hq_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Hardware Encoding`
  String get v3_present_options_menu_he_title {
    return Intl.message(
      'Hardware Encoding',
      name: 'v3_present_options_menu_he_title',
      desc: '',
      args: [],
    );
  }

  /// `Use device's graphic card to encode the stream.`
  String get v3_present_options_menu_he_subtitle {
    return Intl.message(
      'Use device\'s graphic card to encode the stream.',
      name: 'v3_present_options_menu_he_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Allow touchback`
  String get v3_present_touch_back_allow {
    return Intl.message(
      'Allow touchback',
      name: 'v3_present_touch_back_allow',
      desc: '',
      args: [],
    );
  }

  /// `Screen sharing has stopped.\nTotal sharing time %s.`
  String get v3_present_end_information {
    return Intl.message(
      'Screen sharing has stopped.\nTotal sharing time %s.',
      name: 'v3_present_end_information',
      desc: '',
      args: [],
    );
  }

  /// `Time remaining`
  String get v3_select_screen_ios_countdown {
    return Intl.message(
      'Time remaining',
      name: 'v3_select_screen_ios_countdown',
      desc: '',
      args: [],
    );
  }

  /// `Start sharing`
  String get v3_select_screen_ios_start_sharing {
    return Intl.message(
      'Start sharing',
      name: 'v3_select_screen_ios_start_sharing',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get v3_setting_title {
    return Intl.message(
      'Settings',
      name: 'v3_setting_title',
      desc: '',
      args: [],
    );
  }

  /// `AirSync ©{year}. version {version}`
  String v3_setting_app_version(Object year, Object version) {
    return Intl.message(
      'AirSync ©$year. version $version',
      name: 'v3_setting_app_version',
      desc: '',
      args: [year, version],
    );
  }

  /// `Language`
  String get v3_setting_language {
    return Intl.message(
      'Language',
      name: 'v3_setting_language',
      desc: '',
      args: [],
    );
  }

  /// `Legal and Privacy`
  String get v3_setting_legal_policy {
    return Intl.message(
      'Legal and Privacy',
      name: 'v3_setting_legal_policy',
      desc: '',
      args: [],
    );
  }

  /// `Knowledge Base`
  String get v3_setting_knowledge_base {
    return Intl.message(
      'Knowledge Base',
      name: 'v3_setting_knowledge_base',
      desc: '',
      args: [],
    );
  }

  /// `Check for Updates`
  String get v3_setting_check_update {
    return Intl.message(
      'Check for Updates',
      name: 'v3_setting_check_update',
      desc: '',
      args: [],
    );
  }

  /// `Privacy policy`
  String get v3_setting_privacy_policy {
    return Intl.message(
      'Privacy policy',
      name: 'v3_setting_privacy_policy',
      desc: '',
      args: [],
    );
  }

  /// `ViewSonic is committed to protecting your privacy and treats the handling of personal data seriously. The Privacy Policy below details how ViewSonic will treat your personal data after it has been collected by ViewSonic through your use of the Website. ViewSonic maintains the privacy of your information using security technologies and adhere to policies that prevent unauthorized use of your personal information. By using this Website, you consent to the collection and use of your information.\n\nWebsites you link to from ViewSonic.com may have their own privacy policy that may differ from ViewSonic’s. Please review those websites’ privacy policies for detailed information on how they may use information gathered while you are visiting them.\n\nPlease click the following links to learn more about our Privacy Policy.`
  String get v3_setting_privacy_policy_description {
    return Intl.message(
      'ViewSonic is committed to protecting your privacy and treats the handling of personal data seriously. The Privacy Policy below details how ViewSonic will treat your personal data after it has been collected by ViewSonic through your use of the Website. ViewSonic maintains the privacy of your information using security technologies and adhere to policies that prevent unauthorized use of your personal information. By using this Website, you consent to the collection and use of your information.\\n\\nWebsites you link to from ViewSonic.com may have their own privacy policy that may differ from ViewSonic’s. Please review those websites’ privacy policies for detailed information on how they may use information gathered while you are visiting them.\n\nPlease click the following links to learn more about our Privacy Policy.',
      name: 'v3_setting_privacy_policy_description',
      desc: '',
      args: [],
    );
  }

  /// `Open source licenses`
  String get v3_setting_open_source_license {
    return Intl.message(
      'Open source licenses',
      name: 'v3_setting_open_source_license',
      desc: '',
      args: [],
    );
  }

  /// `Software update`
  String get v3_setting_software_update {
    return Intl.message(
      'Software update',
      name: 'v3_setting_software_update',
      desc: '',
      args: [],
    );
  }

  /// `A new version is now available.`
  String get v3_setting_software_update_force_description {
    return Intl.message(
      'A new version is now available.',
      name: 'v3_setting_software_update_force_description',
      desc: '',
      args: [],
    );
  }

  /// `Update Now`
  String get v3_setting_software_update_force_action {
    return Intl.message(
      'Update Now',
      name: 'v3_setting_software_update_force_action',
      desc: '',
      args: [],
    );
  }

  /// `A new version is available. Would you like to update now?`
  String get v3_setting_software_update_description {
    return Intl.message(
      'A new version is available. Would you like to update now?',
      name: 'v3_setting_software_update_description',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get v3_setting_software_update_positive_action {
    return Intl.message(
      'Update',
      name: 'v3_setting_software_update_positive_action',
      desc: '',
      args: [],
    );
  }

  /// `Later`
  String get v3_setting_software_update_deny_action {
    return Intl.message(
      'Later',
      name: 'v3_setting_software_update_deny_action',
      desc: '',
      args: [],
    );
  }

  /// `No Update Available`
  String get v3_setting_software_update_no_available {
    return Intl.message(
      'No Update Available',
      name: 'v3_setting_software_update_no_available',
      desc: '',
      args: [],
    );
  }

  /// `AirSync is already up to date with the latest version.`
  String get v3_setting_software_update_no_available_description {
    return Intl.message(
      'AirSync is already up to date with the latest version.',
      name: 'v3_setting_software_update_no_available_description',
      desc: '',
      args: [],
    );
  }

  /// `Ok`
  String get v3_setting_software_update_no_available_action {
    return Intl.message(
      'Ok',
      name: 'v3_setting_software_update_no_available_action',
      desc: '',
      args: [],
    );
  }

  /// `No Internet Connection`
  String get v3_setting_software_update_no_internet_tittle {
    return Intl.message(
      'No Internet Connection',
      name: 'v3_setting_software_update_no_internet_tittle',
      desc: '',
      args: [],
    );
  }

  /// `Please check your internet connection and try again.`
  String get v3_setting_software_update_no_internet_description {
    return Intl.message(
      'Please check your internet connection and try again.',
      name: 'v3_setting_software_update_no_internet_description',
      desc: '',
      args: [],
    );
  }

  /// `Moderator has closed`
  String get v3_present_moderator_exited {
    return Intl.message(
      'Moderator has closed',
      name: 'v3_present_moderator_exited',
      desc: '',
      args: [],
    );
  }

  /// `Moderator has closed. Please reconnect.`
  String get v3_present_moderator_exited_description {
    return Intl.message(
      'Moderator has closed. Please reconnect.',
      name: 'v3_present_moderator_exited_description',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get v3_present_moderator_exited_action {
    return Intl.message(
      'OK',
      name: 'v3_present_moderator_exited_action',
      desc: '',
      args: [],
    );
  }

  /// `Currently, only Chrome and Edge browsers are supported.`
  String get v3_main_web_nonsupport {
    return Intl.message(
      'Currently, only Chrome and Edge browsers are supported.',
      name: 'v3_main_web_nonsupport',
      desc: '',
      args: [],
    );
  }

  /// `Got it!`
  String get v3_main_web_nonsupport_confirm {
    return Intl.message(
      'Got it!',
      name: 'v3_main_web_nonsupport_confirm',
      desc: '',
      args: [],
    );
  }

  /// `The screen is broadcasting`
  String get v3_receiver_remote_screen_busy_title {
    return Intl.message(
      'The screen is broadcasting',
      name: 'v3_receiver_remote_screen_busy_title',
      desc: '',
      args: [],
    );
  }

  /// `The screen is broadcasting to other screens. Please try again later.`
  String get v3_receiver_remote_screen_busy_description {
    return Intl.message(
      'The screen is broadcasting to other screens. Please try again later.',
      name: 'v3_receiver_remote_screen_busy_description',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get v3_receiver_remote_screen_busy_action {
    return Intl.message(
      'OK',
      name: 'v3_receiver_remote_screen_busy_action',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get v3_present_idle_download_virtual_audio_device {
    return Intl.message(
      'Download',
      name: 'v3_present_idle_download_virtual_audio_device',
      desc: '',
      args: [],
    );
  }

  /// `Unable to share audio. Please download and install audio driver.`
  String get v3_present_select_screen_mac_audio_driver {
    return Intl.message(
      'Unable to share audio. Please download and install audio driver.',
      name: 'v3_present_select_screen_mac_audio_driver',
      desc: '',
      args: [],
    );
  }

  /// `For Best User Experience!`
  String get v3_main_download_mac_pkg_label {
    return Intl.message(
      'For Best User Experience!',
      name: 'v3_main_download_mac_pkg_label',
      desc: '',
      args: [],
    );
  }

  /// `App Store`
  String get v3_main_download_mac_store {
    return Intl.message(
      'App Store',
      name: 'v3_main_download_mac_store',
      desc: '',
      args: [],
    );
  }

  /// `Or Install via`
  String get v3_main_download_mac_store_label {
    return Intl.message(
      'Or Install via',
      name: 'v3_main_download_mac_store_label',
      desc: '',
      args: [],
    );
  }

  /// `AirSync ©{year}. version {version} (Ind.)`
  String v3_setting_app_version_independent(Object year, Object version) {
    return Intl.message(
      'AirSync ©$year. version $version (Ind.)',
      name: 'v3_setting_app_version_independent',
      desc: '',
      args: [year, version],
    );
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
      Locale.fromSubtags(languageCode: 'lt'),
      Locale.fromSubtags(languageCode: 'lv'),
      Locale.fromSubtags(languageCode: 'no'),
      Locale.fromSubtags(languageCode: 'ru'),
      Locale.fromSubtags(languageCode: 'sv'),
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
