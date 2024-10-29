// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(value) =>
      "Please select a screen to share within ${value} seconds...";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "device_list_enter_pin":
            MessageLookupByLibrary.simpleMessage("One-Time Password"),
        "device_list_enter_pin_ok": MessageLookupByLibrary.simpleMessage("OK"),
        "main_connect_network_error": MessageLookupByLibrary.simpleMessage(
            "Network error. Please check network connectivity and try again."),
        "main_connect_rate_limited": MessageLookupByLibrary.simpleMessage(
            "AirSync instance is busy. Please try it later."),
        "main_connect_unknown_error":
            MessageLookupByLibrary.simpleMessage("Unknown error."),
        "main_connection_mode_unsupported":
            MessageLookupByLibrary.simpleMessage(
                "AirSync does not connect to Internet."),
        "main_device_list":
            MessageLookupByLibrary.simpleMessage("Quick Connect"),
        "main_display_code":
            MessageLookupByLibrary.simpleMessage("Display code"),
        "main_display_code_description":
            MessageLookupByLibrary.simpleMessage("Please input display code"),
        "main_display_code_error": MessageLookupByLibrary.simpleMessage(
            "Only accept letters and numbers."),
        "main_display_code_exceed": MessageLookupByLibrary.simpleMessage(
            "Maximum participants (6) reached."),
        "main_display_code_exceed_split_screen":
            MessageLookupByLibrary.simpleMessage(
                "Maximum presenters (4) reached."),
        "main_display_code_invalid":
            MessageLookupByLibrary.simpleMessage("Invalid Display code"),
        "main_feature_reconnect_fail_toast":
            MessageLookupByLibrary.simpleMessage(
                "Network (Control) reconnect fail"),
        "main_feature_reconnect_success_toast":
            MessageLookupByLibrary.simpleMessage(
                "Network (Control) reconnect success"),
        "main_feature_reconnecting_toast": MessageLookupByLibrary.simpleMessage(
            "Network (Control) reconnecting"),
        "main_instance_not_found_or_offline":
            MessageLookupByLibrary.simpleMessage(
                "Display code not found or instance is offline."),
        "main_language": MessageLookupByLibrary.simpleMessage("Language"),
        "main_language_name": MessageLookupByLibrary.simpleMessage("English"),
        "main_notice_not_support_description": MessageLookupByLibrary.simpleMessage(
            "Sharing through browser is not supported on mobile device. Please download and use AirSync sender app for better experience."),
        "main_notice_positive_button": MessageLookupByLibrary.simpleMessage(
            "Download AirSync sender app."),
        "main_notice_title": MessageLookupByLibrary.simpleMessage("Notice"),
        "main_otp_error":
            MessageLookupByLibrary.simpleMessage("Only accept numbers."),
        "main_password": MessageLookupByLibrary.simpleMessage("Password"),
        "main_password_description": MessageLookupByLibrary.simpleMessage(
            "Please enter one-time password"),
        "main_password_invalid":
            MessageLookupByLibrary.simpleMessage("Password invalid."),
        "main_present": MessageLookupByLibrary.simpleMessage("Next"),
        "main_setting": MessageLookupByLibrary.simpleMessage("Settings"),
        "main_touch_back": MessageLookupByLibrary.simpleMessage("Touchback"),
        "main_update_deny_button":
            MessageLookupByLibrary.simpleMessage("Not now"),
        "main_update_description_android": MessageLookupByLibrary.simpleMessage(
            "Please click \"Update\" to install the new version."),
        "main_update_description_apple": MessageLookupByLibrary.simpleMessage(
            "Please click \"Update\" to install the new version."),
        "main_update_description_windows": MessageLookupByLibrary.simpleMessage(
            "Please click \"Update\" to install the new version."),
        "main_update_error_detail":
            MessageLookupByLibrary.simpleMessage("Description: "),
        "main_update_error_title":
            MessageLookupByLibrary.simpleMessage("Version update fail"),
        "main_update_error_type":
            MessageLookupByLibrary.simpleMessage("Fail reason: "),
        "main_update_positive_button":
            MessageLookupByLibrary.simpleMessage("Update"),
        "main_update_title":
            MessageLookupByLibrary.simpleMessage("New version available"),
        "main_webrtc_reconnect_fail_toast":
            MessageLookupByLibrary.simpleMessage(
                "Network (WebRTC) reconnect fail"),
        "main_webrtc_reconnect_success_toast":
            MessageLookupByLibrary.simpleMessage(
                "Network (WebRTC) reconnect success"),
        "main_webrtc_reconnecting_toast": MessageLookupByLibrary.simpleMessage(
            "Network (WebRTC) reconnecting"),
        "moderator":
            MessageLookupByLibrary.simpleMessage("Please input your name"),
        "moderator_back": MessageLookupByLibrary.simpleMessage("Back"),
        "moderator_exit": MessageLookupByLibrary.simpleMessage("EXIT"),
        "moderator_fill_out":
            MessageLookupByLibrary.simpleMessage("Field required"),
        "moderator_name": MessageLookupByLibrary.simpleMessage("Name"),
        "moderator_wait": MessageLookupByLibrary.simpleMessage(
            "Please wait while the moderator selects presenters..."),
        "present_role_cast_screen":
            MessageLookupByLibrary.simpleMessage("Share screen"),
        "present_role_receive":
            MessageLookupByLibrary.simpleMessage("Receive screen"),
        "present_select_screen_cancel":
            MessageLookupByLibrary.simpleMessage("Cancel"),
        "present_select_screen_description":
            MessageLookupByLibrary.simpleMessage(
                "Choose a view to share with the receiving screen."),
        "present_select_screen_entire":
            MessageLookupByLibrary.simpleMessage("Entire screen"),
        "present_select_screen_ios_restart":
            MessageLookupByLibrary.simpleMessage("Start broadcast"),
        "present_select_screen_ios_restart_description":
            MessageLookupByLibrary.simpleMessage(
                "Click \"Start broadcast\" to resume sharing before timeout or click \"Back\" to return to initial screen."),
        "present_select_screen_share":
            MessageLookupByLibrary.simpleMessage("Share"),
        "present_select_screen_share_audio":
            MessageLookupByLibrary.simpleMessage("Share screen audio"),
        "present_select_screen_window":
            MessageLookupByLibrary.simpleMessage("Window"),
        "present_state_high_quality_description":
            MessageLookupByLibrary.simpleMessage(
                "Enable High Quality in good network condition."),
        "present_state_high_quality_title":
            MessageLookupByLibrary.simpleMessage("High Quality"),
        "present_state_pause": MessageLookupByLibrary.simpleMessage("Pause"),
        "present_state_resume": MessageLookupByLibrary.simpleMessage("Resume"),
        "present_state_stop":
            MessageLookupByLibrary.simpleMessage("Stop presenting"),
        "present_time": MessageLookupByLibrary.simpleMessage("Time elapsed"),
        "present_time_unit_hour": MessageLookupByLibrary.simpleMessage("hr"),
        "present_time_unit_min": MessageLookupByLibrary.simpleMessage("mins"),
        "present_time_unit_sec": MessageLookupByLibrary.simpleMessage("secs"),
        "present_wait": m0,
        "remote_screen_connect_error": MessageLookupByLibrary.simpleMessage(
            "Remote screen connection error"),
        "remote_screen_wait": MessageLookupByLibrary.simpleMessage(
            "Sharing is in processing, please wait."),
        "settings_audio_configuration":
            MessageLookupByLibrary.simpleMessage("Audio configuration"),
        "settings_knowledge_base":
            MessageLookupByLibrary.simpleMessage("Knowledge Base"),
        "toast_enable_remote_screen": MessageLookupByLibrary.simpleMessage(
            "Please enable share screen to device in AirSync."),
        "toast_install_audio_driver": MessageLookupByLibrary.simpleMessage(
            "Please install virtual audio driver."),
        "toast_maximum_moderated": MessageLookupByLibrary.simpleMessage(
            "Has reached maximum moderated session amount."),
        "toast_maximum_remote_screen": MessageLookupByLibrary.simpleMessage(
            "Has reached maximum shared screen amount."),
        "toast_maximum_split_screen": MessageLookupByLibrary.simpleMessage(
            "Has reached maximum split screen amount."),
        "v3_device_list_button_device_list":
            MessageLookupByLibrary.simpleMessage("Device List"),
        "v3_device_list_button_text":
            MessageLookupByLibrary.simpleMessage("Quick connect by"),
        "v3_device_list_dialog_connect":
            MessageLookupByLibrary.simpleMessage("Connect"),
        "v3_device_list_dialog_invalid_otp":
            MessageLookupByLibrary.simpleMessage("Incorrect one-time password"),
        "v3_device_list_dialog_title":
            MessageLookupByLibrary.simpleMessage("Enter one-time password"),
        "v3_eula_agree": MessageLookupByLibrary.simpleMessage("Agree"),
        "v3_eula_disagree": MessageLookupByLibrary.simpleMessage("Disagree"),
        "v3_eula_title":
            MessageLookupByLibrary.simpleMessage("End-User License Agreement"),
        "v3_main_accessibility":
            MessageLookupByLibrary.simpleMessage("Accessibility"),
        "v3_main_authorize_wait": MessageLookupByLibrary.simpleMessage(
            "Please wait for the host to approve your request."),
        "v3_main_connect_network_error": MessageLookupByLibrary.simpleMessage(
            "Network error. Please check network connectivity and try again."),
        "v3_main_connect_rate_limited": MessageLookupByLibrary.simpleMessage(
            "AirSync instance is busy. Please try it later."),
        "v3_main_connect_unknown_error":
            MessageLookupByLibrary.simpleMessage("Unknown error."),
        "v3_main_connection_mode_unsupported":
            MessageLookupByLibrary.simpleMessage(
                "AirSync does not connect to Internet."),
        "v3_main_copy_rights": MessageLookupByLibrary.simpleMessage(
            "Copyright © ViewSonic Corporation 2024. All rights reserved."),
        "v3_main_display_code":
            MessageLookupByLibrary.simpleMessage("Display code"),
        "v3_main_display_code_error":
            MessageLookupByLibrary.simpleMessage("Only accept numbers."),
        "v3_main_display_code_invalid":
            MessageLookupByLibrary.simpleMessage("Invalid Display code"),
        "v3_main_download": MessageLookupByLibrary.simpleMessage("Download"),
        "v3_main_download_action_download":
            MessageLookupByLibrary.simpleMessage("Download"),
        "v3_main_download_action_get":
            MessageLookupByLibrary.simpleMessage("Get"),
        "v3_main_download_app_dialog_desc":
            MessageLookupByLibrary.simpleMessage(
                "Scan the QR code with your iOS or Android device to download"),
        "v3_main_download_app_dialog_title":
            MessageLookupByLibrary.simpleMessage("Download Sender App"),
        "v3_main_download_app_subtitle":
            MessageLookupByLibrary.simpleMessage("iOS and Android"),
        "v3_main_download_app_title":
            MessageLookupByLibrary.simpleMessage("AirSync App"),
        "v3_main_download_desc": MessageLookupByLibrary.simpleMessage(
            "Effortless screen sharing with one-click connect."),
        "v3_main_download_mac_subtitle":
            MessageLookupByLibrary.simpleMessage("macOS 10.15+"),
        "v3_main_download_mac_title":
            MessageLookupByLibrary.simpleMessage("Mac"),
        "v3_main_download_title":
            MessageLookupByLibrary.simpleMessage("Get your AirSync sender app"),
        "v3_main_download_win_subtitle":
            MessageLookupByLibrary.simpleMessage("Win 10 (1709+)/ Win 11"),
        "v3_main_download_win_title":
            MessageLookupByLibrary.simpleMessage("Windows"),
        "v3_main_instance_not_found_or_offline":
            MessageLookupByLibrary.simpleMessage(
                "Display code not found or instance is offline."),
        "v3_main_moderator_action":
            MessageLookupByLibrary.simpleMessage("Share"),
        "v3_main_moderator_app_subtitle": MessageLookupByLibrary.simpleMessage(
            "Enter your name before share your screen"),
        "v3_main_moderator_app_title":
            MessageLookupByLibrary.simpleMessage("Share"),
        "v3_main_moderator_disconnect":
            MessageLookupByLibrary.simpleMessage("Disconnect"),
        "v3_main_moderator_input_hint":
            MessageLookupByLibrary.simpleMessage("Type your name"),
        "v3_main_moderator_input_limit": MessageLookupByLibrary.simpleMessage(
            "Please limit the name to 20 characters."),
        "v3_main_moderator_subtitle": MessageLookupByLibrary.simpleMessage(
            "Enter your presentation title"),
        "v3_main_moderator_title":
            MessageLookupByLibrary.simpleMessage("Share your screen"),
        "v3_main_moderator_wait": MessageLookupByLibrary.simpleMessage(
            "Wait for moderator to invite you to share"),
        "v3_main_otp_error":
            MessageLookupByLibrary.simpleMessage("Only accept numbers."),
        "v3_main_password": MessageLookupByLibrary.simpleMessage("Password"),
        "v3_main_password_invalid":
            MessageLookupByLibrary.simpleMessage("Password invalid."),
        "v3_main_present_action": MessageLookupByLibrary.simpleMessage("Next"),
        "v3_main_present_subtitle": MessageLookupByLibrary.simpleMessage(
            "Follow the steps to get started."),
        "v3_main_present_title":
            MessageLookupByLibrary.simpleMessage("Share your screen"),
        "v3_main_presenting_message": MessageLookupByLibrary.simpleMessage(
            "airsync.net is sharing your screen."),
        "v3_main_privacy":
            MessageLookupByLibrary.simpleMessage("Privacy Policy"),
        "v3_main_receive_app_action":
            MessageLookupByLibrary.simpleMessage("Connect"),
        "v3_main_receive_app_receive_from":
            MessageLookupByLibrary.simpleMessage("Receive from %s"),
        "v3_main_receive_app_stop":
            MessageLookupByLibrary.simpleMessage("Stop"),
        "v3_main_receive_app_subtitle":
            MessageLookupByLibrary.simpleMessage("Share screen to my device"),
        "v3_main_receive_app_title":
            MessageLookupByLibrary.simpleMessage("Receive"),
        "v3_main_select_role_receive":
            MessageLookupByLibrary.simpleMessage("Receive"),
        "v3_main_select_role_share":
            MessageLookupByLibrary.simpleMessage("Share"),
        "v3_main_select_role_title": MessageLookupByLibrary.simpleMessage(
            "Choose your presentation mode"),
        "v3_main_terms": MessageLookupByLibrary.simpleMessage("Terms of use"),
        "v3_present_end_information": MessageLookupByLibrary.simpleMessage(
            "Screen sharing has stopped.\nTotal sharing time %s."),
        "v3_present_options_menu_he_subtitle":
            MessageLookupByLibrary.simpleMessage(
                "Suggest to use device graphic card to encode streaming."),
        "v3_present_options_menu_he_title":
            MessageLookupByLibrary.simpleMessage("Hardware Encoding"),
        "v3_present_options_menu_hq_subtitle":
            MessageLookupByLibrary.simpleMessage(
                "Use higher bitrate to transmit streaming."),
        "v3_present_options_menu_hq_title":
            MessageLookupByLibrary.simpleMessage("High Quality"),
        "v3_present_screen_full":
            MessageLookupByLibrary.simpleMessage("Screen Full"),
        "v3_present_screen_full_action":
            MessageLookupByLibrary.simpleMessage("OK"),
        "v3_present_screen_full_description":
            MessageLookupByLibrary.simpleMessage(
                "Has reached maximum split screen amount."),
        "v3_present_select_screen_extension":
            MessageLookupByLibrary.simpleMessage("Screen extension"),
        "v3_present_select_screen_extension_desc":
            MessageLookupByLibrary.simpleMessage("Expand Your Workspace"),
        "v3_present_select_screen_extension_desc2":
            MessageLookupByLibrary.simpleMessage(
                "This allows you to drag content between your personal device and the IFP, enhancing real-time interaction and control."),
        "v3_present_select_screen_share_audio":
            MessageLookupByLibrary.simpleMessage("Share computer audio."),
        "v3_present_select_screen_subtitle":
            MessageLookupByLibrary.simpleMessage(
                "%s wants to share your screen. Choose what to share."),
        "v3_present_session_full":
            MessageLookupByLibrary.simpleMessage("Session Full"),
        "v3_present_session_full_action":
            MessageLookupByLibrary.simpleMessage("OK"),
        "v3_present_session_full_description":
            MessageLookupByLibrary.simpleMessage(
                "Unable to join, The session is react to its maximum."),
        "v3_present_touch_back_allow":
            MessageLookupByLibrary.simpleMessage("Touchback allow"),
        "v3_scan_qr_reminder": MessageLookupByLibrary.simpleMessage(
            "Quick connect by scan the QR code"),
        "v3_select_screen_ios_countdown":
            MessageLookupByLibrary.simpleMessage("Time remain"),
        "v3_select_screen_ios_start_sharing":
            MessageLookupByLibrary.simpleMessage("Start sharing"),
        "v3_setting_app_version":
            MessageLookupByLibrary.simpleMessage("AirSync ©2024. version %s"),
        "v3_setting_check_update":
            MessageLookupByLibrary.simpleMessage("Check for Updates"),
        "v3_setting_knowledge_base":
            MessageLookupByLibrary.simpleMessage("Knowledge Base"),
        "v3_setting_language": MessageLookupByLibrary.simpleMessage("Language"),
        "v3_setting_legal_policy":
            MessageLookupByLibrary.simpleMessage("Legal and Privacy"),
        "v3_setting_open_source_license":
            MessageLookupByLibrary.simpleMessage("Open source licenses"),
        "v3_setting_privacy_policy":
            MessageLookupByLibrary.simpleMessage("Privacy policy"),
        "v3_setting_privacy_policy_description":
            MessageLookupByLibrary.simpleMessage(
                "ViewSonic is committed to protecting your privacy and treats the handling of personal data seriously. The Privacy Policy below details how ViewSonic will treat your personal data after it has been collected by ViewSonic through your use of the Website. ViewSonic maintains the privacy of your information using security technologies and adhere to policies that prevent unauthorized use of your personal information. By using this Website, you consent to the collection and use of your information.\\n\\nWebsites you link to from ViewSonic.com may have their own privacy policy that may differ from ViewSonic’s. Please review those websites’ privacy policies for detailed information on how they may use information gathered while you are visiting them.\n\nPlease click the following links to learn more about our Privacy Policy."),
        "v3_setting_software_update":
            MessageLookupByLibrary.simpleMessage("Software update"),
        "v3_setting_software_update_deny_action":
            MessageLookupByLibrary.simpleMessage("Later"),
        "v3_setting_software_update_description":
            MessageLookupByLibrary.simpleMessage(
                "A new version is now available, would you like to update now?"),
        "v3_setting_software_update_force_action":
            MessageLookupByLibrary.simpleMessage("Update Now"),
        "v3_setting_software_update_force_description":
            MessageLookupByLibrary.simpleMessage(
                "A new version is now available."),
        "v3_setting_software_update_no_available":
            MessageLookupByLibrary.simpleMessage("No Update Available"),
        "v3_setting_software_update_no_available_action":
            MessageLookupByLibrary.simpleMessage("Ok"),
        "v3_setting_software_update_no_available_description":
            MessageLookupByLibrary.simpleMessage(
                "AirSync is already up to date with the latest version."),
        "v3_setting_software_update_no_internet_description":
            MessageLookupByLibrary.simpleMessage(
                "Please check your internet connection and try again."),
        "v3_setting_software_update_no_internet_tittle":
            MessageLookupByLibrary.simpleMessage("No Internet Connection"),
        "v3_setting_software_update_positive_action":
            MessageLookupByLibrary.simpleMessage("Update"),
        "v3_setting_title": MessageLookupByLibrary.simpleMessage("Settings")
      };
}
