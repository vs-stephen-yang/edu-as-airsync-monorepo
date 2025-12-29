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
      "Screen sharing is about to end. Would you like to extend it by 3 hours? You can extend up to ${value} times. ";

  static String m1(year, version) => "AirSync ©${year}. version ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "eula_agree": MessageLookupByLibrary.simpleMessage("I Agree"),
    "eula_disagree": MessageLookupByLibrary.simpleMessage("I Disagree"),
    "eula_title": MessageLookupByLibrary.simpleMessage("AirSync EULA"),
    "main_airplay_pin_code": MessageLookupByLibrary.simpleMessage(
      "AirPlay Code",
    ),
    "main_auto_startup": MessageLookupByLibrary.simpleMessage(
      "Launch AirSync on startup",
    ),
    "main_cast_settings_airplay": MessageLookupByLibrary.simpleMessage(
      "AirPlay",
    ),
    "main_cast_settings_device_name": MessageLookupByLibrary.simpleMessage(
      "Name",
    ),
    "main_cast_settings_google_cast": MessageLookupByLibrary.simpleMessage(
      "Google Cast",
    ),
    "main_cast_settings_miracast": MessageLookupByLibrary.simpleMessage(
      "Miracast",
    ),
    "main_cast_settings_title": MessageLookupByLibrary.simpleMessage(
      "Cast Settings",
    ),
    "main_content_display_code": MessageLookupByLibrary.simpleMessage(
      "Display Code",
    ),
    "main_content_lan_only": MessageLookupByLibrary.simpleMessage(
      "Only LAN connection",
    ),
    "main_content_one_time_password": MessageLookupByLibrary.simpleMessage(
      "One Time Password",
    ),
    "main_content_one_time_password_get_fail": MessageLookupByLibrary.simpleMessage(
      "Failed to refresh password.\nPlease wait for 30 seconds before retrying.",
    ),
    "main_feature_no_network_warning": MessageLookupByLibrary.simpleMessage(
      "Control connection is disconnected. Please reconnect",
    ),
    "main_feature_reconnect_fail_toast": MessageLookupByLibrary.simpleMessage(
      "Network (Control) reconnect fail",
    ),
    "main_feature_reconnect_success_toast":
        MessageLookupByLibrary.simpleMessage(
          "Network (Control) reconnect success",
        ),
    "main_feature_reconnecting_toast": MessageLookupByLibrary.simpleMessage(
      "Network (Control) reconnecting",
    ),
    "main_get_display_code_failure": MessageLookupByLibrary.simpleMessage(
      "Failed to get display code. Wait for network connectivity to resume, or restart the app.",
    ),
    "main_language_name": MessageLookupByLibrary.simpleMessage("English"),
    "main_language_title": MessageLookupByLibrary.simpleMessage("Language"),
    "main_limit_time_message": MessageLookupByLibrary.simpleMessage(
      "5 minutes left",
    ),
    "main_mirror_from_client": MessageLookupByLibrary.simpleMessage(
      "%s would like to share their screen.",
    ),
    "main_mirror_prompt_accept": MessageLookupByLibrary.simpleMessage("Accept"),
    "main_mirror_prompt_cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "main_register_display_code_failure": MessageLookupByLibrary.simpleMessage(
      "Failure to get Display Code and One Time Password. This may be due to a network or server issue. Please try again later when connection is restored.",
    ),
    "main_settings_airplay_code": MessageLookupByLibrary.simpleMessage(
      "AirPlay code",
    ),
    "main_settings_device_list": MessageLookupByLibrary.simpleMessage(
      "Quick Connect Password",
    ),
    "main_settings_device_name": MessageLookupByLibrary.simpleMessage("Name"),
    "main_settings_device_name_cancel": MessageLookupByLibrary.simpleMessage(
      "CANCEL",
    ),
    "main_settings_device_name_hint": MessageLookupByLibrary.simpleMessage(
      "Name",
    ),
    "main_settings_device_name_save": MessageLookupByLibrary.simpleMessage(
      "SAVE",
    ),
    "main_settings_device_name_title": MessageLookupByLibrary.simpleMessage(
      "Rename device",
    ),
    "main_settings_language": MessageLookupByLibrary.simpleMessage("Language"),
    "main_settings_mirror_confirmation": MessageLookupByLibrary.simpleMessage(
      "Mirror confirmation",
    ),
    "main_settings_pin_visible": MessageLookupByLibrary.simpleMessage(
      "Connect information",
    ),
    "main_settings_share_to_sender": MessageLookupByLibrary.simpleMessage(
      "Share screen to device",
    ),
    "main_settings_share_to_sender_limit_desc":
        MessageLookupByLibrary.simpleMessage("Share screen up to 10 senders."),
    "main_settings_title": MessageLookupByLibrary.simpleMessage("Settings"),
    "main_settings_whats_new": MessageLookupByLibrary.simpleMessage(
      "What\'s New?",
    ),
    "main_split_screen_question": MessageLookupByLibrary.simpleMessage(
      "Click the above toggle for Split Screen Mode. Up to 4 participants can present at once.",
    ),
    "main_split_screen_title": MessageLookupByLibrary.simpleMessage(
      "Split Screen",
    ),
    "main_split_screen_waiting": MessageLookupByLibrary.simpleMessage(
      "Split screen enabled. Waiting for presenter to share screen...",
    ),
    "main_status_go_background": MessageLookupByLibrary.simpleMessage(
      "AirSync app is running in the background.",
    ),
    "main_status_no_network": MessageLookupByLibrary.simpleMessage(
      "Poor network connection detected.\nPlease check your connectivity.",
    ),
    "main_status_remaining_time": MessageLookupByLibrary.simpleMessage(
      "%02d min : %02d sec",
    ),
    "main_thanks_content": MessageLookupByLibrary.simpleMessage(
      "Thank you for using AirSync.",
    ),
    "main_wait_title": MessageLookupByLibrary.simpleMessage(
      "Waiting for presenter to share screen...",
    ),
    "main_wait_up_next": MessageLookupByLibrary.simpleMessage("UP NEXT"),
    "main_webrtc_reconnect_fail_toast": MessageLookupByLibrary.simpleMessage(
      "Network (WebRTC) reconnect fail",
    ),
    "main_webrtc_reconnect_success_toast": MessageLookupByLibrary.simpleMessage(
      "Network (WebRTC) reconnect success",
    ),
    "main_webrtc_reconnecting_toast": MessageLookupByLibrary.simpleMessage(
      "Network (WebRTC) reconnecting",
    ),
    "main_whats_new_content": MessageLookupByLibrary.simpleMessage(
      "[Improvement]\n\n1. All numeric display code for better experience.\n\n2. Improve connection stability.\n\n3. Bugs fixed.\n",
    ),
    "main_whats_new_title": MessageLookupByLibrary.simpleMessage(
      "What’s New on AirSync?",
    ),
    "moderator_activate_split_screen": MessageLookupByLibrary.simpleMessage(
      "Click the above toggle for Split Screen Mode. Up to 4 participants can present at once.",
    ),
    "moderator_cancel": MessageLookupByLibrary.simpleMessage("CANCEL"),
    "moderator_confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "moderator_deactivate_split_screen": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to end this split screen session? All screens currently shared will be terminated.",
    ),
    "moderator_exit": MessageLookupByLibrary.simpleMessage("EXIT"),
    "moderator_exit_dialog": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to end this moderator session? All presenters will be removed.",
    ),
    "moderator_presentersLimit": MessageLookupByLibrary.simpleMessage(
      "Click the above toggle for Moderator Mode. Up to 6 presenters can join.",
    ),
    "moderator_presentersList": MessageLookupByLibrary.simpleMessage(
      "Presenters",
    ),
    "moderator_remove": MessageLookupByLibrary.simpleMessage("REMOVE"),
    "moderator_verifyCode_fail": MessageLookupByLibrary.simpleMessage(
      "Something went wrong. Please try again.",
    ),
    "toast_maximum_split_screen": MessageLookupByLibrary.simpleMessage(
      "Has reached maximum split screen amount.",
    ),
    "update_install_now": MessageLookupByLibrary.simpleMessage("INSTALL NOW"),
    "update_message": MessageLookupByLibrary.simpleMessage(
      "A new version of software is available",
    ),
    "update_title": MessageLookupByLibrary.simpleMessage("AirSync Update"),
    "v3_authorize_prompt_accept": MessageLookupByLibrary.simpleMessage(
      "Accept",
    ),
    "v3_authorize_prompt_accept_all": MessageLookupByLibrary.simpleMessage(
      "Accept All",
    ),
    "v3_authorize_prompt_decline": MessageLookupByLibrary.simpleMessage(
      "Decline",
    ),
    "v3_authorize_prompt_notification_cast": MessageLookupByLibrary.simpleMessage(
      "Uncheck “Require approval” in the Settings menu to accept all casting requests.",
    ),
    "v3_authorize_prompt_notification_mirror": MessageLookupByLibrary.simpleMessage(
      "Check “Auto Accept” in the Settings menu to accept all mirror requests.",
    ),
    "v3_authorize_prompt_title_launcher": MessageLookupByLibrary.simpleMessage(
      "Participants would like to share their screen",
    ),
    "v3_broadcast_cast_board_on": MessageLookupByLibrary.simpleMessage(
      "Casting in progress",
    ),
    "v3_broadcast_cast_device_on": MessageLookupByLibrary.simpleMessage(
      "Casting in progress",
    ),
    "v3_broadcast_indicator": MessageLookupByLibrary.simpleMessage("ON"),
    "v3_broadcast_multicast_checkbox": MessageLookupByLibrary.simpleMessage(
      "Cast to 10-100 Devices",
    ),
    "v3_broadcast_multicast_desc": MessageLookupByLibrary.simpleMessage(
      "The number of receiving devices cannot be changed when the projection starts.",
    ),
    "v3_broadcast_multicast_warn": MessageLookupByLibrary.simpleMessage(
      "Interrupt all projection to edit.",
    ),
    "v3_cast_to_device_Receiving": MessageLookupByLibrary.simpleMessage(
      "Receiving",
    ),
    "v3_cast_to_device_list_msg": MessageLookupByLibrary.simpleMessage(
      "Maximum up to 10 devices.",
    ),
    "v3_cast_to_device_menu_or": MessageLookupByLibrary.simpleMessage("Or"),
    "v3_cast_to_device_menu_quick_connect1":
        MessageLookupByLibrary.simpleMessage("Quick Connect"),
    "v3_cast_to_device_menu_quick_connect2":
        MessageLookupByLibrary.simpleMessage("by scan the QR code"),
    "v3_cast_to_device_menu_title": MessageLookupByLibrary.simpleMessage(
      "Join to Receive This Screen",
    ),
    "v3_cast_to_device_reached_maximum": MessageLookupByLibrary.simpleMessage(
      "You’ve reached the maximum limit.",
    ),
    "v3_cast_to_device_title": MessageLookupByLibrary.simpleMessage(
      "Device list",
    ),
    "v3_cast_to_device_touch_back": MessageLookupByLibrary.simpleMessage(
      "Touchback",
    ),
    "v3_cast_to_device_touch_back_disable":
        MessageLookupByLibrary.simpleMessage("Disable"),
    "v3_cast_to_device_touch_enabled": MessageLookupByLibrary.simpleMessage(
      "Touchback",
    ),
    "v3_casting_ended_toast": MessageLookupByLibrary.simpleMessage(
      "Screen sharing has ended.",
    ),
    "v3_casting_time_countdown": m0,
    "v3_casting_time_do_not_extend": MessageLookupByLibrary.simpleMessage(
      "Do not extend",
    ),
    "v3_casting_time_extend": MessageLookupByLibrary.simpleMessage("Extend"),
    "v3_casting_time_extend_success_toast":
        MessageLookupByLibrary.simpleMessage("Extended for 3 hours."),
    "v3_download_app_desc": MessageLookupByLibrary.simpleMessage(
      "Scan the QR code with your iOS or Android device to download",
    ),
    "v3_download_app_desktop": MessageLookupByLibrary.simpleMessage(
      "For Best User Experience!",
    ),
    "v3_download_app_desktop_hint": MessageLookupByLibrary.simpleMessage(
      "*Manual Installer",
    ),
    "v3_download_app_desktop_store": MessageLookupByLibrary.simpleMessage(
      "Install MacOS via App Store",
    ),
    "v3_download_app_desktop_store_hint": MessageLookupByLibrary.simpleMessage(
      "*Only For MacOS",
    ),
    "v3_download_app_desktop_title": MessageLookupByLibrary.simpleMessage(
      "Desktop",
    ),
    "v3_download_app_entry": MessageLookupByLibrary.simpleMessage(
      "Download Sender App",
    ),
    "v3_download_app_for_desktop": MessageLookupByLibrary.simpleMessage(
      "For Desktop",
    ),
    "v3_download_app_for_desktop_desc": MessageLookupByLibrary.simpleMessage(
      "Enter the following URL to download.",
    ),
    "v3_download_app_for_mobile": MessageLookupByLibrary.simpleMessage(
      "For iOS & Android",
    ),
    "v3_download_app_for_mobile_desc": MessageLookupByLibrary.simpleMessage(
      "Scan the QR code for instant access.",
    ),
    "v3_download_app_mobile_title": MessageLookupByLibrary.simpleMessage(
      "Mobile",
    ),
    "v3_download_app_or": MessageLookupByLibrary.simpleMessage("OR"),
    "v3_download_app_title": MessageLookupByLibrary.simpleMessage(
      "Download Sender App",
    ),
    "v3_eula_agree": MessageLookupByLibrary.simpleMessage("Agree"),
    "v3_eula_disagree": MessageLookupByLibrary.simpleMessage("Disagree"),
    "v3_eula_launch": MessageLookupByLibrary.simpleMessage("Launch"),
    "v3_eula_title": MessageLookupByLibrary.simpleMessage(
      "End-User License Agreement",
    ),
    "v3_exit_moderator_mode_cancel": MessageLookupByLibrary.simpleMessage(
      "Cancel",
    ),
    "v3_exit_moderator_mode_desc": MessageLookupByLibrary.simpleMessage(
      "Are you sure? This will disconnect all participants.",
    ),
    "v3_exit_moderator_mode_exit": MessageLookupByLibrary.simpleMessage("Exit"),
    "v3_exit_moderator_mode_title": MessageLookupByLibrary.simpleMessage(
      "Exit Moderator Mode",
    ),
    "v3_group_dialog_accept": MessageLookupByLibrary.simpleMessage("Accept"),
    "v3_group_dialog_decline": MessageLookupByLibrary.simpleMessage("Decline"),
    "v3_group_dialog_message": MessageLookupByLibrary.simpleMessage(
      "%s has sent a broadcast request to your device. This action will synchronize and display the current content, do you want to accept this request?",
    ),
    "v3_group_dialog_no_device_message": MessageLookupByLibrary.simpleMessage(
      "No device selected.",
    ),
    "v3_group_dialog_title": MessageLookupByLibrary.simpleMessage(
      "Broadcast Request from %s",
    ),
    "v3_group_receive_view_status_from": MessageLookupByLibrary.simpleMessage(
      "Broadcasting from",
    ),
    "v3_group_receive_view_status_stop": MessageLookupByLibrary.simpleMessage(
      "Stop",
    ),
    "v3_group_reject_invited": MessageLookupByLibrary.simpleMessage(
      "declined your broadcast request, please check the Broads setting.",
    ),
    "v3_help_center_cast_device_title": MessageLookupByLibrary.simpleMessage(
      "Cast to device",
    ),
    "v3_help_center_cast_device_title_sub":
        MessageLookupByLibrary.simpleMessage(
          "IFP casting its screen to devices.",
        ),
    "v3_help_center_close": MessageLookupByLibrary.simpleMessage("Close"),
    "v3_help_center_fullscreen_title": MessageLookupByLibrary.simpleMessage(
      "Fullscreen",
    ),
    "v3_help_center_mute_user_title": MessageLookupByLibrary.simpleMessage(
      "Mute user",
    ),
    "v3_help_center_remove_user_title": MessageLookupByLibrary.simpleMessage(
      "Remove user",
    ),
    "v3_help_center_share_title": MessageLookupByLibrary.simpleMessage(
      "Invite to share",
    ),
    "v3_help_center_share_title_sub": MessageLookupByLibrary.simpleMessage(
      "Devices sharing its screen to IFP.",
    ),
    "v3_help_center_stop_share_title": MessageLookupByLibrary.simpleMessage(
      "Stop sharing",
    ),
    "v3_help_center_title": MessageLookupByLibrary.simpleMessage("Help Center"),
    "v3_help_center_touchback_title": MessageLookupByLibrary.simpleMessage(
      "Touchback",
    ),
    "v3_help_center_touchback_title_sub": MessageLookupByLibrary.simpleMessage(
      "Allowing user remote control.",
    ),
    "v3_help_center_untouchback_title": MessageLookupByLibrary.simpleMessage(
      "Untouchback",
    ),
    "v3_help_center_untouchback_title_sub":
        MessageLookupByLibrary.simpleMessage("Detach touchback mode."),
    "v3_instruction1a": MessageLookupByLibrary.simpleMessage(
      "Visit airsync.net or open the sender app",
    ),
    "v3_instruction1b": MessageLookupByLibrary.simpleMessage(
      "Open the sender app",
    ),
    "v3_instruction2": MessageLookupByLibrary.simpleMessage(
      "Enter display code",
    ),
    "v3_instruction2_onethird": MessageLookupByLibrary.simpleMessage(
      "Display code",
    ),
    "v3_instruction3": MessageLookupByLibrary.simpleMessage(
      "Enter one-time password",
    ),
    "v3_instruction3_onethird": MessageLookupByLibrary.simpleMessage(
      "One-time password",
    ),
    "v3_instruction_share_screen": MessageLookupByLibrary.simpleMessage(
      "Share Your Screens",
    ),
    "v3_instruction_support": MessageLookupByLibrary.simpleMessage(
      "Supports sharing via AirPlay, Google Cast or Miracast",
    ),
    "v3_last_casting_time_countdown": MessageLookupByLibrary.simpleMessage(
      "Screen sharing is about to end. Please restart the screen sharing if necessary.",
    ),
    "v3_lbl_authorize_prompt_accept": MessageLookupByLibrary.simpleMessage(
      "Accept request",
    ),
    "v3_lbl_authorize_prompt_accept_all": MessageLookupByLibrary.simpleMessage(
      "Accept all requests",
    ),
    "v3_lbl_authorize_prompt_decline": MessageLookupByLibrary.simpleMessage(
      "Decline request",
    ),
    "v3_lbl_broadcast_multicast_checkbox": MessageLookupByLibrary.simpleMessage(
      "Cast to 10-100 Devices",
    ),
    "v3_lbl_cast_device_close": MessageLookupByLibrary.simpleMessage(
      "Close cast device connection",
    ),
    "v3_lbl_cast_device_next": MessageLookupByLibrary.simpleMessage(
      "next page",
    ),
    "v3_lbl_cast_device_previous": MessageLookupByLibrary.simpleMessage(
      "previous page",
    ),
    "v3_lbl_cast_device_sort_asc": MessageLookupByLibrary.simpleMessage(
      "sort asc",
    ),
    "v3_lbl_cast_device_sort_desc": MessageLookupByLibrary.simpleMessage(
      "sort desc",
    ),
    "v3_lbl_cast_device_touchback_disable":
        MessageLookupByLibrary.simpleMessage(
          "Disable touchback for cast device",
        ),
    "v3_lbl_cast_device_touchback_enable": MessageLookupByLibrary.simpleMessage(
      "Enable touchback for cast device",
    ),
    "v3_lbl_close_download_app_menu": MessageLookupByLibrary.simpleMessage(
      "Close download sender app menu",
    ),
    "v3_lbl_close_feature_set_cast_device":
        MessageLookupByLibrary.simpleMessage("Close cast device list"),
    "v3_lbl_close_feature_set_moderator": MessageLookupByLibrary.simpleMessage(
      "Close moderator list",
    ),
    "v3_lbl_close_help_center": MessageLookupByLibrary.simpleMessage(
      "Close help center",
    ),
    "v3_lbl_close_streaming_shortcut_menu":
        MessageLookupByLibrary.simpleMessage("Close Streaming Shortcut menu"),
    "v3_lbl_connection_dialog_close": MessageLookupByLibrary.simpleMessage(
      "Close connection status dialog",
    ),
    "v3_lbl_eula_agree": MessageLookupByLibrary.simpleMessage(
      "Agree with EULA",
    ),
    "v3_lbl_eula_disagree": MessageLookupByLibrary.simpleMessage(
      "Disagree with EULA",
    ),
    "v3_lbl_eula_launch": MessageLookupByLibrary.simpleMessage("Launch"),
    "v3_lbl_exit_moderator_cancel": MessageLookupByLibrary.simpleMessage(
      "Cancel exiting moderator mode",
    ),
    "v3_lbl_exit_moderator_exit": MessageLookupByLibrary.simpleMessage(
      "Confirm exiting moderator mode",
    ),
    "v3_lbl_extend_casting_do_not_extend": MessageLookupByLibrary.simpleMessage(
      "Do not extend casting time",
    ),
    "v3_lbl_extend_casting_extend": MessageLookupByLibrary.simpleMessage(
      "Extend casting time",
    ),
    "v3_lbl_group_reject_close": MessageLookupByLibrary.simpleMessage(
      "Close group reject notification",
    ),
    "v3_lbl_internet_connection_only_error":
        MessageLookupByLibrary.simpleMessage(
          "Connectivity error，please check device network setting",
        ),
    "v3_lbl_internet_connection_warning": MessageLookupByLibrary.simpleMessage(
      "Local connection only",
    ),
    "v3_lbl_main_language_title": MessageLookupByLibrary.simpleMessage(
      "Select language",
    ),
    "v3_lbl_main_language_title_item": MessageLookupByLibrary.simpleMessage(
      "Select %s",
    ),
    "v3_lbl_message_dialog_cancel": MessageLookupByLibrary.simpleMessage(
      "Cancel dialog",
    ),
    "v3_lbl_message_dialog_confirm": MessageLookupByLibrary.simpleMessage(
      "Confirm dialog",
    ),
    "v3_lbl_minimal_quick_connect_menu": MessageLookupByLibrary.simpleMessage(
      "Minimize quick connect menu",
    ),
    "v3_lbl_minimal_streaming_qrcode_menu":
        MessageLookupByLibrary.simpleMessage("Minimize Streaming QR Code menu"),
    "v3_lbl_moderator_toggle": MessageLookupByLibrary.simpleMessage(
      "Toggle moderator mode",
    ),
    "v3_lbl_open_download_app_menu": MessageLookupByLibrary.simpleMessage(
      "Open download sender app menu",
    ),
    "v3_lbl_open_feature_set_cast_device": MessageLookupByLibrary.simpleMessage(
      "Open cast device list",
    ),
    "v3_lbl_open_feature_set_moderator": MessageLookupByLibrary.simpleMessage(
      "Open moderator list",
    ),
    "v3_lbl_open_help_center": MessageLookupByLibrary.simpleMessage(
      "Open Help center menu",
    ),
    "v3_lbl_open_menu_settings": MessageLookupByLibrary.simpleMessage(
      "Open Setting Menu",
    ),
    "v3_lbl_open_streaming_qrcode_menu": MessageLookupByLibrary.simpleMessage(
      "Open Streaming QR Code Menu",
    ),
    "v3_lbl_open_streaming_shortcut_menu": MessageLookupByLibrary.simpleMessage(
      "Open Streaming Shortcut Menu",
    ),
    "v3_lbl_overlay_bring_app_to_top": MessageLookupByLibrary.simpleMessage(
      "Floating connection information tab",
    ),
    "v3_lbl_overlay_menu_expand": MessageLookupByLibrary.simpleMessage(
      "Expand overlay menu",
    ),
    "v3_lbl_overlay_menu_minimize": MessageLookupByLibrary.simpleMessage(
      "Minimize overlay menu",
    ),
    "v3_lbl_participant_cast_device": MessageLookupByLibrary.simpleMessage(
      "Cast device to this participant",
    ),
    "v3_lbl_participant_close": MessageLookupByLibrary.simpleMessage(
      "Close participant connection",
    ),
    "v3_lbl_participant_disconnect": MessageLookupByLibrary.simpleMessage(
      "Disconnect this participant",
    ),
    "v3_lbl_participant_mirror_close": MessageLookupByLibrary.simpleMessage(
      "Close mirror participant connection",
    ),
    "v3_lbl_participant_mirror_share": MessageLookupByLibrary.simpleMessage(
      "Share to this participant\'s mirror",
    ),
    "v3_lbl_participant_mirror_stop": MessageLookupByLibrary.simpleMessage(
      "Stop mirror participant\'s streaming",
    ),
    "v3_lbl_participant_share": MessageLookupByLibrary.simpleMessage(
      "Share to this participant\'s screen",
    ),
    "v3_lbl_participant_stop": MessageLookupByLibrary.simpleMessage(
      "Stop participant\'s streaming",
    ),
    "v3_lbl_participant_touch_back": MessageLookupByLibrary.simpleMessage(
      "Enable touchback for this participant",
    ),
    "v3_lbl_participant_touch_back_disable":
        MessageLookupByLibrary.simpleMessage(
          "Disable touchback for this participant",
        ),
    "v3_lbl_permission_exit": MessageLookupByLibrary.simpleMessage("Exit"),
    "v3_lbl_resizable_expand": MessageLookupByLibrary.simpleMessage(
      "Expand presentation control",
    ),
    "v3_lbl_resizable_minimize": MessageLookupByLibrary.simpleMessage(
      "Minimize presentation control",
    ),
    "v3_lbl_resizable_mute": MessageLookupByLibrary.simpleMessage(
      "Mute presentation",
    ),
    "v3_lbl_resizable_stop": MessageLookupByLibrary.simpleMessage(
      "Stop presentation",
    ),
    "v3_lbl_settings_accessibility": MessageLookupByLibrary.simpleMessage(
      "Accessibility",
    ),
    "v3_lbl_settings_back_icon": MessageLookupByLibrary.simpleMessage(
      "Back to previous page",
    ),
    "v3_lbl_settings_broadcast": MessageLookupByLibrary.simpleMessage(
      "Open broadcast setting menu",
    ),
    "v3_lbl_settings_broadcast_boards": MessageLookupByLibrary.simpleMessage(
      "Open broadcast boards menu",
    ),
    "v3_lbl_settings_broadcast_connect": MessageLookupByLibrary.simpleMessage(
      "Connect",
    ),
    "v3_lbl_settings_broadcast_connecting":
        MessageLookupByLibrary.simpleMessage("Connecting"),
    "v3_lbl_settings_broadcast_device_favorite":
        MessageLookupByLibrary.simpleMessage("favorite"),
    "v3_lbl_settings_broadcast_device_remove":
        MessageLookupByLibrary.simpleMessage("remove device"),
    "v3_lbl_settings_broadcast_devices": MessageLookupByLibrary.simpleMessage(
      "Open broadcast devices menu",
    ),
    "v3_lbl_settings_broadcast_ip_hint": MessageLookupByLibrary.simpleMessage(
      "Find Boards via IP",
    ),
    "v3_lbl_settings_broadcast_to_display_group":
        MessageLookupByLibrary.simpleMessage(
          "Open broadcast to display group menu",
        ),
    "v3_lbl_settings_broadcast_to_display_group_cast":
        MessageLookupByLibrary.simpleMessage("Broadcast"),
    "v3_lbl_settings_broadcast_to_display_group_checkbox":
        MessageLookupByLibrary.simpleMessage("Select %s"),
    "v3_lbl_settings_broadcast_to_display_group_confirm":
        MessageLookupByLibrary.simpleMessage("Confirm no device selected."),
    "v3_lbl_settings_broadcast_to_display_group_item":
        MessageLookupByLibrary.simpleMessage("Select %s"),
    "v3_lbl_settings_broadcast_to_display_group_save":
        MessageLookupByLibrary.simpleMessage("Save"),
    "v3_lbl_settings_broadcast_to_display_group_type":
        MessageLookupByLibrary.simpleMessage("Select %s"),
    "v3_lbl_settings_close_icon": MessageLookupByLibrary.simpleMessage(
      "Close settings menu",
    ),
    "v3_lbl_settings_connectivity": MessageLookupByLibrary.simpleMessage(
      "Open connectivity setting menu",
    ),
    "v3_lbl_settings_connectivity_item": MessageLookupByLibrary.simpleMessage(
      "Select %s",
    ),
    "v3_lbl_settings_device_authorize_mode":
        MessageLookupByLibrary.simpleMessage("Turn on/off authorization mode"),
    "v3_lbl_settings_device_auto_fill_otp":
        MessageLookupByLibrary.simpleMessage("Turn on/off auto fill OTP mode"),
    "v3_lbl_settings_device_high_image_quality":
        MessageLookupByLibrary.simpleMessage("High image quality"),
    "v3_lbl_settings_device_launch_on_startup":
        MessageLookupByLibrary.simpleMessage("Turn on/off auto startup mode"),
    "v3_lbl_settings_device_name": MessageLookupByLibrary.simpleMessage(
      "Modify device name",
    ),
    "v3_lbl_settings_device_name_close": MessageLookupByLibrary.simpleMessage(
      "Close device name setting",
    ),
    "v3_lbl_settings_device_name_save": MessageLookupByLibrary.simpleMessage(
      "Save device name",
    ),
    "v3_lbl_settings_device_setting": MessageLookupByLibrary.simpleMessage(
      "Open device setting menu",
    ),
    "v3_lbl_settings_device_smart_scaling":
        MessageLookupByLibrary.simpleMessage(
          "Turn on/off smart scaling toggle",
        ),
    "v3_lbl_settings_enter_device_name": MessageLookupByLibrary.simpleMessage(
      "Enter device name",
    ),
    "v3_lbl_settings_invite_group": MessageLookupByLibrary.simpleMessage(
      "Open screen broadcasting dropdown menu",
    ),
    "v3_lbl_settings_invite_group_item": MessageLookupByLibrary.simpleMessage(
      "Select %s",
    ),
    "v3_lbl_settings_ip_add": MessageLookupByLibrary.simpleMessage("add ip"),
    "v3_lbl_settings_ip_clear": MessageLookupByLibrary.simpleMessage("clear"),
    "v3_lbl_settings_knowledge_base": MessageLookupByLibrary.simpleMessage(
      "Knowledge Base",
    ),
    "v3_lbl_settings_legal_policy": MessageLookupByLibrary.simpleMessage(
      "Open legal policy setting menu",
    ),
    "v3_lbl_settings_menu_locked": MessageLookupByLibrary.simpleMessage(
      "Setting Menu is locked",
    ),
    "v3_lbl_settings_mirroring_auto_accept":
        MessageLookupByLibrary.simpleMessage("Turn on/off auto accept"),
    "v3_lbl_settings_mirroring_require_passcode":
        MessageLookupByLibrary.simpleMessage("Turn on/off require passcode"),
    "v3_lbl_settings_moderator_mode": MessageLookupByLibrary.simpleMessage(
      "Turn on/off moderator mode",
    ),
    "v3_lbl_settings_only_when_casting_info":
        MessageLookupByLibrary.simpleMessage(
          "More information about broadcast to display group",
        ),
    "v3_lbl_settings_open_source_license": MessageLookupByLibrary.simpleMessage(
      "Select %s",
    ),
    "v3_lbl_settings_show_display_code": MessageLookupByLibrary.simpleMessage(
      "Turn on/off display code toggle",
    ),
    "v3_lbl_settings_whats_new": MessageLookupByLibrary.simpleMessage(
      "Open what\'s new setting menu",
    ),
    "v3_lbl_settings_whats_new_icon": MessageLookupByLibrary.simpleMessage(
      "what\'s new icon",
    ),
    "v3_lbl_shortcuts_airplay": MessageLookupByLibrary.simpleMessage(
      "Turn on/off AirPlay",
    ),
    "v3_lbl_shortcuts_google_cast": MessageLookupByLibrary.simpleMessage(
      "Turn on/off Google Cast",
    ),
    "v3_lbl_shortcuts_miracast": MessageLookupByLibrary.simpleMessage(
      "Turn on/off Miracast",
    ),
    "v3_lbl_shortcuts_mirroring": MessageLookupByLibrary.simpleMessage(
      "Open mirroring setting menu",
    ),
    "v3_lbl_streaming_airplay_touchback": MessageLookupByLibrary.simpleMessage(
      "Airplay touchback",
    ),
    "v3_lbl_streaming_page_control": MessageLookupByLibrary.simpleMessage(
      "next page",
    ),
    "v3_lbl_streaming_shortcut_airplay_toggle":
        MessageLookupByLibrary.simpleMessage("AirPlay toggle"),
    "v3_lbl_streaming_shortcut_cast_device_toggle":
        MessageLookupByLibrary.simpleMessage("Cast to devices toggle"),
    "v3_lbl_streaming_shortcut_expand": MessageLookupByLibrary.simpleMessage(
      "Expand streaming features",
    ),
    "v3_lbl_streaming_shortcut_google_cast_toggle":
        MessageLookupByLibrary.simpleMessage("Google Cast toggle"),
    "v3_lbl_streaming_shortcut_menu_locked":
        MessageLookupByLibrary.simpleMessage(
          "Streaming Shortcut Menu is locked",
        ),
    "v3_lbl_streaming_shortcut_minimize": MessageLookupByLibrary.simpleMessage(
      "Collapse streaming features",
    ),
    "v3_lbl_streaming_shortcut_miracast_toggle":
        MessageLookupByLibrary.simpleMessage("Miracast toggle"),
    "v3_lbl_streaming_view_expand": MessageLookupByLibrary.simpleMessage(
      "Expand streaming view",
    ),
    "v3_lbl_streaming_view_function_expand":
        MessageLookupByLibrary.simpleMessage("Expand streaming function"),
    "v3_lbl_streaming_view_function_minimize":
        MessageLookupByLibrary.simpleMessage("Collapse streaming function"),
    "v3_lbl_streaming_view_minimize": MessageLookupByLibrary.simpleMessage(
      "Collapse streaming view",
    ),
    "v3_lbl_streaming_view_mute": MessageLookupByLibrary.simpleMessage(
      "Mute audio",
    ),
    "v3_lbl_streaming_view_stop": MessageLookupByLibrary.simpleMessage(
      "Stop streaming",
    ),
    "v3_lbl_streaming_view_unmute": MessageLookupByLibrary.simpleMessage(
      "Unmute audio",
    ),
    "v3_lbl_touchback_one_device_cancel": MessageLookupByLibrary.simpleMessage(
      "Cancel dialog",
    ),
    "v3_lbl_touchback_one_device_confirm": MessageLookupByLibrary.simpleMessage(
      "Confirm dialog",
    ),
    "v3_lbl_touchback_restart_bluetooth_btn_cancel":
        MessageLookupByLibrary.simpleMessage("Cancel"),
    "v3_lbl_touchback_restart_bluetooth_btn_restart":
        MessageLookupByLibrary.simpleMessage("Restart"),
    "v3_main_connection_dialog_close": MessageLookupByLibrary.simpleMessage(
      "Close",
    ),
    "v3_main_internet_connection_only": MessageLookupByLibrary.simpleMessage(
      "Internet connection only。",
    ),
    "v3_main_internet_connection_only_error":
        MessageLookupByLibrary.simpleMessage(
          "Connectivity error，please check device network setting。",
        ),
    "v3_main_internet_connection_only_error_dialog_desc":
        MessageLookupByLibrary.simpleMessage(
          "Connectivity error，please check device network setting。",
        ),
    "v3_main_local_connection_only_dialog_desc":
        MessageLookupByLibrary.simpleMessage(
          "LAN connection only，please check device network setting。",
        ),
    "v3_main_status_no_network": MessageLookupByLibrary.simpleMessage(
      "Unable to detect an internet connection. Please connect to a Wi-Fi or intranet network, and try again.",
    ),
    "v3_miracast_not_support": MessageLookupByLibrary.simpleMessage(
      "Miracast unavailable now. Current Wi-Fi channel does not support screen casting.",
    ),
    "v3_miracast_uibc_not_supported_message":
        MessageLookupByLibrary.simpleMessage(
          "This source does not support Miracast touchback",
        ),
    "v3_mirror_request_passcode": MessageLookupByLibrary.simpleMessage(
      "Passcode",
    ),
    "v3_moderator_disable_mirror_cancel": MessageLookupByLibrary.simpleMessage(
      "Cancel",
    ),
    "v3_moderator_disable_mirror_desc": MessageLookupByLibrary.simpleMessage(
      "Mirroring will be disabled in moderator mode",
    ),
    "v3_moderator_disable_mirror_ok": MessageLookupByLibrary.simpleMessage(
      "OK",
    ),
    "v3_moderator_disable_mirror_title": MessageLookupByLibrary.simpleMessage(
      "Disable Mirroring for Moderator Mode",
    ),
    "v3_moderator_mode": MessageLookupByLibrary.simpleMessage("Moderator mode"),
    "v3_new_sharing_join_session": MessageLookupByLibrary.simpleMessage(
      " joined the session",
    ),
    "v3_overlay_retry_dialog_end": MessageLookupByLibrary.simpleMessage("End"),
    "v3_overlay_retry_dialog_retry": MessageLookupByLibrary.simpleMessage(
      "Retry",
    ),
    "v3_overlay_retry_dialog_stop_broadcast":
        MessageLookupByLibrary.simpleMessage("Stop Broadcast"),
    "v3_overlay_retry_dialog_title": MessageLookupByLibrary.simpleMessage(
      "Casting interrupted. Please reacquire casting permission.",
    ),
    "v3_participant_item_casting": MessageLookupByLibrary.simpleMessage(
      "Casting",
    ),
    "v3_participant_item_connected": MessageLookupByLibrary.simpleMessage(
      "Connected",
    ),
    "v3_participant_item_controlling": MessageLookupByLibrary.simpleMessage(
      "Receiving + Touchback",
    ),
    "v3_participant_item_receiving": MessageLookupByLibrary.simpleMessage(
      "Receiving",
    ),
    "v3_participant_item_share": MessageLookupByLibrary.simpleMessage("Share"),
    "v3_participant_item_waiting": MessageLookupByLibrary.simpleMessage(
      "Waiting...",
    ),
    "v3_participants_desc": MessageLookupByLibrary.simpleMessage(
      "Maximum up to 6 participants.",
    ),
    "v3_participants_desc_maximum_9": MessageLookupByLibrary.simpleMessage(
      "Maximum up to 9 participants.",
    ),
    "v3_participants_title": MessageLookupByLibrary.simpleMessage(
      "Participants",
    ),
    "v3_permission_description": MessageLookupByLibrary.simpleMessage(
      "Please go to \"Settings\" then \"Apps\" and select \"AirSync\" to grant the \"Location\" and \"Nearby devices\" permission.",
    ),
    "v3_permission_exit": MessageLookupByLibrary.simpleMessage("Exit"),
    "v3_permission_title": MessageLookupByLibrary.simpleMessage(
      "Permission required",
    ),
    "v3_qrcode_quick_connect": MessageLookupByLibrary.simpleMessage(
      "Quick Connect",
    ),
    "v3_quick_connect_menu_bottom_msg": MessageLookupByLibrary.simpleMessage(
      "Split-screen activates if two or more users share screens.",
    ),
    "v3_quick_connect_menu_display_code": MessageLookupByLibrary.simpleMessage(
      "Display Code",
    ),
    "v3_quick_connect_menu_qrcode": MessageLookupByLibrary.simpleMessage(
      "QR Code",
    ),
    "v3_recording_stopped_dialog_msg": MessageLookupByLibrary.simpleMessage(
      "Please restart the broadcast session if needed.",
    ),
    "v3_recording_stopped_dialog_title": MessageLookupByLibrary.simpleMessage(
      "Screen recording is stopped",
    ),
    "v3_setting_passcode_cancel": MessageLookupByLibrary.simpleMessage(
      "Cancel",
    ),
    "v3_setting_passcode_clear": MessageLookupByLibrary.simpleMessage("Clear"),
    "v3_setting_passcode_confirm": MessageLookupByLibrary.simpleMessage(
      "Confirm",
    ),
    "v3_setting_passcode_error_description":
        MessageLookupByLibrary.simpleMessage(
          "Invalid password, please try again.",
        ),
    "v3_setting_passcode_title": MessageLookupByLibrary.simpleMessage(
      "Enter passcode to unlock Settings",
    ),
    "v3_settings_accessibility": MessageLookupByLibrary.simpleMessage(
      "Accessibility",
    ),
    "v3_settings_all_the_time_info": MessageLookupByLibrary.simpleMessage(
      "Broadcast source IFP screen all the time.",
    ),
    "v3_settings_broadcast": MessageLookupByLibrary.simpleMessage("Broadcast"),
    "v3_settings_broadcast_boards": MessageLookupByLibrary.simpleMessage(
      "Other AirSync devices",
    ),
    "v3_settings_broadcast_cast_boards": MessageLookupByLibrary.simpleMessage(
      "Cast to boards",
    ),
    "v3_settings_broadcast_cast_boards_desc": MessageLookupByLibrary.simpleMessage(
      "Share this screen to all Interactive Flat Panels (IFPs) in the network.",
    ),
    "v3_settings_broadcast_cast_to": MessageLookupByLibrary.simpleMessage(
      "Broadcast to",
    ),
    "v3_settings_broadcast_devices": MessageLookupByLibrary.simpleMessage(
      "Sender devices",
    ),
    "v3_settings_broadcast_ip": MessageLookupByLibrary.simpleMessage(
      "Find Boards via IP",
    ),
    "v3_settings_broadcast_ip_hint": MessageLookupByLibrary.simpleMessage(
      "Enter IP Address",
    ),
    "v3_settings_broadcast_not_find": MessageLookupByLibrary.simpleMessage(
      "not find",
    ),
    "v3_settings_broadcast_screen_energy_saving":
        MessageLookupByLibrary.simpleMessage(
          "Please turn off energy saving to avoid unexpected interruption during broadcasting.",
        ),
    "v3_settings_broadcast_to_display_group":
        MessageLookupByLibrary.simpleMessage("Broadcast to the display group"),
    "v3_settings_connectivity": MessageLookupByLibrary.simpleMessage(
      "Connectivity",
    ),
    "v3_settings_connectivity_both": MessageLookupByLibrary.simpleMessage(
      "Both internet & local connection",
    ),
    "v3_settings_connectivity_internet": MessageLookupByLibrary.simpleMessage(
      "Internet connection",
    ),
    "v3_settings_connectivity_internet_desc":
        MessageLookupByLibrary.simpleMessage(
          "Internet connection requires a stable network.",
        ),
    "v3_settings_connectivity_local": MessageLookupByLibrary.simpleMessage(
      "Local connection",
    ),
    "v3_settings_connectivity_local_desc": MessageLookupByLibrary.simpleMessage(
      "Local connections operate within a private network, offering more security and stability.",
    ),
    "v3_settings_device_authorize_mode": MessageLookupByLibrary.simpleMessage(
      "Require approval for all screen sharing requests.",
    ),
    "v3_settings_device_auto_fill_otp": MessageLookupByLibrary.simpleMessage(
      "Auto-fill one-time password",
    ),
    "v3_settings_device_auto_fill_otp_desc": MessageLookupByLibrary.simpleMessage(
      "Enable one-touch connection when this device is selected from the Sender app\'s Quick Connect menu.",
    ),
    "v3_settings_device_high_image_quality":
        MessageLookupByLibrary.simpleMessage("High image quality"),
    "v3_settings_device_high_image_quality_off_desc":
        MessageLookupByLibrary.simpleMessage(
          "Maximum QHD (2K) screen sharing depending on the sender screen resolution.",
        ),
    "v3_settings_device_high_image_quality_on_desc":
        MessageLookupByLibrary.simpleMessage(
          "Maximum UHD (4K) screen sharing from web sender and 3K+ from Windows and macOS sender depending on the sender screen resolution. Requires a high quality network.",
        ),
    "v3_settings_device_launch_on_startup":
        MessageLookupByLibrary.simpleMessage("Launch AirSync on startup"),
    "v3_settings_device_name": MessageLookupByLibrary.simpleMessage(
      "Device Name",
    ),
    "v3_settings_device_name_empty_error": MessageLookupByLibrary.simpleMessage(
      "Device name cannot be empty",
    ),
    "v3_settings_device_name_save": MessageLookupByLibrary.simpleMessage(
      "Save",
    ),
    "v3_settings_device_not_supported": MessageLookupByLibrary.simpleMessage(
      "Device version is not supported",
    ),
    "v3_settings_device_setting": MessageLookupByLibrary.simpleMessage(
      "Device setting",
    ),
    "v3_settings_device_show_display_code":
        MessageLookupByLibrary.simpleMessage("Show display code on top"),
    "v3_settings_device_show_display_code_desc":
        MessageLookupByLibrary.simpleMessage(
          "Keep the code visible at the top of the screen, even when switching to other apps and screen sharing is active.",
        ),
    "v3_settings_device_smart_scaling": MessageLookupByLibrary.simpleMessage(
      "Smart scaling",
    ),
    "v3_settings_device_smart_scaling_desc": MessageLookupByLibrary.simpleMessage(
      "Automatically adjust the screen size to maximize the use of screen space. The image may be slightly distorted.",
    ),
    "v3_settings_device_unavailable": MessageLookupByLibrary.simpleMessage(
      "Unavailable",
    ),
    "v3_settings_display_group": MessageLookupByLibrary.simpleMessage(
      "Display Group",
    ),
    "v3_settings_display_group_all_the_time":
        MessageLookupByLibrary.simpleMessage("All the time"),
    "v3_settings_display_group_cast": MessageLookupByLibrary.simpleMessage(
      "Broadcast",
    ),
    "v3_settings_display_group_only_casting":
        MessageLookupByLibrary.simpleMessage("Only when casting"),
    "v3_settings_feature_locked": MessageLookupByLibrary.simpleMessage(
      "Locked by ViewSonic Manager.",
    ),
    "v3_settings_invite_group": MessageLookupByLibrary.simpleMessage(
      "If invited to a display group",
    ),
    "v3_settings_invite_group_auto_accept":
        MessageLookupByLibrary.simpleMessage("Auto Accept"),
    "v3_settings_invite_group_ignore": MessageLookupByLibrary.simpleMessage(
      "Ignore",
    ),
    "v3_settings_invite_group_notify_me": MessageLookupByLibrary.simpleMessage(
      "Notify me",
    ),
    "v3_settings_knowledge_base": MessageLookupByLibrary.simpleMessage(
      "Knowledge Base",
    ),
    "v3_settings_legal_policy": MessageLookupByLibrary.simpleMessage(
      "Legal & Policy",
    ),
    "v3_settings_local_connection_only": MessageLookupByLibrary.simpleMessage(
      "Local connection only",
    ),
    "v3_settings_mirroring_auto_accept": MessageLookupByLibrary.simpleMessage(
      "Auto Accept",
    ),
    "v3_settings_mirroring_auto_accept_desc":
        MessageLookupByLibrary.simpleMessage(
          "Instantly enable mirroring without requiring moderator approval.",
        ),
    "v3_settings_mirroring_blocked": MessageLookupByLibrary.simpleMessage(
      "Turn off moderator mode first.",
    ),
    "v3_settings_mirroring_require_passcode":
        MessageLookupByLibrary.simpleMessage("Require passcode"),
    "v3_settings_moderator_mode": MessageLookupByLibrary.simpleMessage(
      "Moderator mode",
    ),
    "v3_settings_only_when_casting_info": MessageLookupByLibrary.simpleMessage(
      "Broadcast the source IFP screen only when it is receiving a shared screen.",
    ),
    "v3_settings_open_source_license": MessageLookupByLibrary.simpleMessage(
      "Open Source Licenses",
    ),
    "v3_settings_privacy_policy": MessageLookupByLibrary.simpleMessage(
      "Privacy Policy",
    ),
    "v3_settings_privacy_policy_description": MessageLookupByLibrary.simpleMessage(
      "ViewSonic is committed to protecting your privacy and treats the handling of personal data seriously. The Privacy Policy below details how ViewSonic will treat your personal data after it has been collected by ViewSonic through your use of the Website. ViewSonic maintains the privacy of your information using security technologies and adhere to policies that prevent unauthorized use of your personal information. By using this Website, you consent to the collection and use of your information.\n\nWebsites you link to from ViewSonic.com may have their own privacy policy that may differ from ViewSonic’s. Please review those websites’ privacy policies for detailed information on how they may use information gathered while you are visiting them.\n\nPlease click the following links to learn more about our Privacy Policy.",
    ),
    "v3_settings_resize_text_size": MessageLookupByLibrary.simpleMessage(
      "Resize text size",
    ),
    "v3_settings_resize_text_size_extra_large":
        MessageLookupByLibrary.simpleMessage("XLarge"),
    "v3_settings_resize_text_size_large": MessageLookupByLibrary.simpleMessage(
      "Large",
    ),
    "v3_settings_resize_text_size_normal": MessageLookupByLibrary.simpleMessage(
      "Normal",
    ),
    "v3_settings_version": m1,
    "v3_settings_whats_new": MessageLookupByLibrary.simpleMessage(
      "What\'s new",
    ),
    "v3_settings_whats_new_content": MessageLookupByLibrary.simpleMessage(
      "AirSync %s\n\nAirSync is a proprietary wireless screen-sharing solution from ViewSonic. When utilized with the AirSync sender, it allows users to seamlessly share their screens with ViewSonic interactive displays.\n\nThis release includes the following new features:\n\n1. Support for ViewBoard split screen view.\n\n2. Support high quality screen sharing (up to 4K) through web sender.\n\n3. Mute device audio output when sharing through Windows sender.\n\n4. Enhanced stability.\n\n5. Fixed various bugs.\n",
    ),
    "v3_shortcuts_airplay": MessageLookupByLibrary.simpleMessage("AirPlay"),
    "v3_shortcuts_cast_device": MessageLookupByLibrary.simpleMessage(
      "Cast to devices",
    ),
    "v3_shortcuts_cast_device_desc": MessageLookupByLibrary.simpleMessage(
      "Cast this screen to multiple devices, including laptops, tablets and mobile devices simultaneously.",
    ),
    "v3_shortcuts_google_cast": MessageLookupByLibrary.simpleMessage(
      "Google Cast",
    ),
    "v3_shortcuts_menu_title": MessageLookupByLibrary.simpleMessage(
      "Shortcuts",
    ),
    "v3_shortcuts_miracast": MessageLookupByLibrary.simpleMessage("Miracast"),
    "v3_shortcuts_mirroring": MessageLookupByLibrary.simpleMessage("Mirroring"),
    "v3_touchback_alert_message": MessageLookupByLibrary.simpleMessage(
      "You can only touchback one device at one time.",
    ),
    "v3_touchback_alert_title": MessageLookupByLibrary.simpleMessage(
      "Touchback to %s？",
    ),
    "v3_touchback_disable_message": MessageLookupByLibrary.simpleMessage(
      "TouchBack is disabled.",
    ),
    "v3_touchback_fail_message": MessageLookupByLibrary.simpleMessage(
      "Pairing failed. TouchBack is not activated. Please try again",
    ),
    "v3_touchback_restart_bluetooth_btn_cancel":
        MessageLookupByLibrary.simpleMessage("Cancel"),
    "v3_touchback_restart_bluetooth_btn_restart":
        MessageLookupByLibrary.simpleMessage("Restart"),
    "v3_touchback_restart_bluetooth_message": MessageLookupByLibrary.simpleMessage(
      "Operation timeout. Please turn off and restart the Bluetooth function on the large screen, then restart the touchback.",
    ),
    "v3_touchback_restart_bluetooth_title":
        MessageLookupByLibrary.simpleMessage(
          "Operation timed out, please restart Bluetooth",
        ),
    "v3_touchback_state_deviceFinding_message":
        MessageLookupByLibrary.simpleMessage("Device Finding"),
    "v3_touchback_state_deviceFoundSuccess_message":
        MessageLookupByLibrary.simpleMessage("Device Found Success"),
    "v3_touchback_state_devicePairedSuccess_message":
        MessageLookupByLibrary.simpleMessage("Device Paired Success"),
    "v3_touchback_state_devicePairing_message":
        MessageLookupByLibrary.simpleMessage("Device Pairing"),
    "v3_touchback_state_hidConnected_message":
        MessageLookupByLibrary.simpleMessage("Hid Connected"),
    "v3_touchback_state_hidConnecting_message":
        MessageLookupByLibrary.simpleMessage("Hid Connecting"),
    "v3_touchback_state_hidProfileServiceStartedSuccess_message":
        MessageLookupByLibrary.simpleMessage(
          "Hid Profile Service Started Success",
        ),
    "v3_touchback_state_hidProfileServiceStarting_message":
        MessageLookupByLibrary.simpleMessage("Hid Profile Service Starting"),
    "v3_touchback_state_initialized_message":
        MessageLookupByLibrary.simpleMessage("Initialized"),
    "v3_touchback_state_initializing_message":
        MessageLookupByLibrary.simpleMessage("Initializing"),
    "v3_touchback_success_message": MessageLookupByLibrary.simpleMessage(
      "You can now control %s remotely from the IFP.",
    ),
    "v3_waiting_desc": MessageLookupByLibrary.simpleMessage(
      "Waiting for this participant to share their screen",
    ),
    "v3_waiting_join": MessageLookupByLibrary.simpleMessage(
      "Waiting for others to join",
    ),
    "v3_waiting_up_next": MessageLookupByLibrary.simpleMessage("Up next"),
    "v3_zero_fps_capture_failed_message": MessageLookupByLibrary.simpleMessage(
      "Currently unable to retrieve a screenshot from the source app. A capture error may have occurred. Please return to the source app to take a new screenshot and try again.",
    ),
    "v3_zero_fps_capture_failed_title": MessageLookupByLibrary.simpleMessage(
      "Screenshot Capture Failed",
    ),
    "v3_zero_fps_capture_failed_wait": MessageLookupByLibrary.simpleMessage(
      "Keep Waiting",
    ),
    "v3_zero_fps_close": MessageLookupByLibrary.simpleMessage("Close"),
    "v3_zero_fps_failed_to_repair_message":
        MessageLookupByLibrary.simpleMessage(
          "Unable to restart the screenshot mechanism in the source app.",
        ),
    "v3_zero_fps_failed_to_repair_title": MessageLookupByLibrary.simpleMessage(
      "Failed to Repair Screenshot Feature",
    ),
    "v3_zero_fps_prompt_message": MessageLookupByLibrary.simpleMessage(
      "Unable to capture the screen and send it to the projection app. Would you like to restart the screenshot feature and try again, or stop the projection?",
    ),
    "v3_zero_fps_prompt_title": MessageLookupByLibrary.simpleMessage(
      "Restarted successfully",
    ),
    "v3_zero_fps_repairing_message": MessageLookupByLibrary.simpleMessage(
      "Restarting the screenshot mechanism in the source app. This may take a few seconds. Please wait.",
    ),
    "v3_zero_fps_repairing_title": MessageLookupByLibrary.simpleMessage(
      "Repairing Screenshot Feature",
    ),
    "v3_zero_fps_restart_failed": MessageLookupByLibrary.simpleMessage(
      "Restart failed",
    ),
    "v3_zero_fps_restarted_Successfully": MessageLookupByLibrary.simpleMessage(
      "Restarted successfully",
    ),
    "v3_zero_fps_restarting_content": MessageLookupByLibrary.simpleMessage(
      "Please wait.",
    ),
    "v3_zero_fps_restarting_title": MessageLookupByLibrary.simpleMessage(
      "Restarting",
    ),
    "vbs_ota_progress_msg": MessageLookupByLibrary.simpleMessage(
      "Downloading system updates",
    ),
  };
}
