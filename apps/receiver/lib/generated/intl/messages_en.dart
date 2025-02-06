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

  static String m0(year, version) => "AirSync ©${year}. version ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "eula_agree": MessageLookupByLibrary.simpleMessage("I Agree"),
        "eula_disagree": MessageLookupByLibrary.simpleMessage("I Disagree"),
        "eula_title": MessageLookupByLibrary.simpleMessage("AirSync EULA"),
        "main_airplay_pin_code":
            MessageLookupByLibrary.simpleMessage("AirPlay Code"),
        "main_auto_startup":
            MessageLookupByLibrary.simpleMessage("Launch AirSync on startup"),
        "main_cast_settings_airplay":
            MessageLookupByLibrary.simpleMessage("AirPlay"),
        "main_cast_settings_device_name":
            MessageLookupByLibrary.simpleMessage("Name"),
        "main_cast_settings_google_cast":
            MessageLookupByLibrary.simpleMessage("Google Cast"),
        "main_cast_settings_miracast":
            MessageLookupByLibrary.simpleMessage("Miracast"),
        "main_cast_settings_title":
            MessageLookupByLibrary.simpleMessage("Cast Settings"),
        "main_content_display_code":
            MessageLookupByLibrary.simpleMessage("Display Code"),
        "main_content_lan_only":
            MessageLookupByLibrary.simpleMessage("Only LAN connection"),
        "main_content_one_time_password":
            MessageLookupByLibrary.simpleMessage("One Time Password"),
        "main_content_one_time_password_get_fail":
            MessageLookupByLibrary.simpleMessage(
                "Failed to refresh password.\nPlease wait for 30 seconds before retrying."),
        "main_feature_no_network_warning": MessageLookupByLibrary.simpleMessage(
            "Control connection is disconnected. Please reconnect"),
        "main_feature_reconnect_fail_toast":
            MessageLookupByLibrary.simpleMessage(
                "Network (Control) reconnect fail"),
        "main_feature_reconnect_success_toast":
            MessageLookupByLibrary.simpleMessage(
                "Network (Control) reconnect success"),
        "main_feature_reconnecting_toast": MessageLookupByLibrary.simpleMessage(
            "Network (Control) reconnecting"),
        "main_get_display_code_failure": MessageLookupByLibrary.simpleMessage(
            "Failed to get display code. Wait for network connectivity to resume, or restart the app."),
        "main_language_name": MessageLookupByLibrary.simpleMessage("English"),
        "main_language_title": MessageLookupByLibrary.simpleMessage("Language"),
        "main_limit_time_message":
            MessageLookupByLibrary.simpleMessage("5 minutes left"),
        "main_mirror_from_client": MessageLookupByLibrary.simpleMessage(
            "%s would like to share their screen."),
        "main_mirror_prompt_accept":
            MessageLookupByLibrary.simpleMessage("Accept"),
        "main_mirror_prompt_cancel":
            MessageLookupByLibrary.simpleMessage("Cancel"),
        "main_register_display_code_failure": MessageLookupByLibrary.simpleMessage(
            "Failure to get Display Code and One Time Password. This may be due to a network or server issue. Please try again later when connection is restored."),
        "main_settings_airplay_code":
            MessageLookupByLibrary.simpleMessage("AirPlay code"),
        "main_settings_device_list":
            MessageLookupByLibrary.simpleMessage("Quick Connect Password"),
        "main_settings_device_name":
            MessageLookupByLibrary.simpleMessage("Name"),
        "main_settings_device_name_cancel":
            MessageLookupByLibrary.simpleMessage("CANCEL"),
        "main_settings_device_name_hint":
            MessageLookupByLibrary.simpleMessage("Name"),
        "main_settings_device_name_save":
            MessageLookupByLibrary.simpleMessage("SAVE"),
        "main_settings_device_name_title":
            MessageLookupByLibrary.simpleMessage("Rename device"),
        "main_settings_language":
            MessageLookupByLibrary.simpleMessage("Language"),
        "main_settings_mirror_confirmation":
            MessageLookupByLibrary.simpleMessage("Mirror confirmation"),
        "main_settings_pin_visible":
            MessageLookupByLibrary.simpleMessage("Connect information"),
        "main_settings_share_to_sender":
            MessageLookupByLibrary.simpleMessage("Share screen to device"),
        "main_settings_share_to_sender_limit_desc":
            MessageLookupByLibrary.simpleMessage(
                "Share screen up to 10 senders."),
        "main_settings_title": MessageLookupByLibrary.simpleMessage("Settings"),
        "main_settings_whats_new":
            MessageLookupByLibrary.simpleMessage("What\'s New?"),
        "main_split_screen_question": MessageLookupByLibrary.simpleMessage(
            "Click the above toggle for Split Screen Mode. Up to 4 participants can present at once."),
        "main_split_screen_title":
            MessageLookupByLibrary.simpleMessage("Split Screen"),
        "main_split_screen_waiting": MessageLookupByLibrary.simpleMessage(
            "Split screen enabled. Waiting for presenter to share screen..."),
        "main_status_go_background": MessageLookupByLibrary.simpleMessage(
            "AirSync app is running in the background."),
        "main_status_no_network": MessageLookupByLibrary.simpleMessage(
            "Poor network connection detected.\nPlease check your connectivity."),
        "main_status_remaining_time":
            MessageLookupByLibrary.simpleMessage("%02d min : %02d sec"),
        "main_thanks_content": MessageLookupByLibrary.simpleMessage(
            "Thank you for using AirSync."),
        "main_wait_title": MessageLookupByLibrary.simpleMessage(
            "Waiting for presenter to share screen..."),
        "main_wait_up_next": MessageLookupByLibrary.simpleMessage("UP NEXT"),
        "main_webrtc_reconnect_fail_toast":
            MessageLookupByLibrary.simpleMessage(
                "Network (WebRTC) reconnect fail"),
        "main_webrtc_reconnect_success_toast":
            MessageLookupByLibrary.simpleMessage(
                "Network (WebRTC) reconnect success"),
        "main_webrtc_reconnecting_toast": MessageLookupByLibrary.simpleMessage(
            "Network (WebRTC) reconnecting"),
        "main_whats_new_content": MessageLookupByLibrary.simpleMessage(
            "[Improvement]\n\n1. All numeric display code for better experience.\n\n2. Improve connection stability.\n\n3. Bugs fixed.\n"),
        "main_whats_new_title":
            MessageLookupByLibrary.simpleMessage("What’s New on AirSync?"),
        "moderator_activate_split_screen": MessageLookupByLibrary.simpleMessage(
            "Click the above toggle for Split Screen Mode. Up to 4 participants can present at once."),
        "moderator_cancel": MessageLookupByLibrary.simpleMessage("CANCEL"),
        "moderator_confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
        "moderator_deactivate_split_screen": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to end this split screen session? All screens currently shared will be terminated."),
        "moderator_exit": MessageLookupByLibrary.simpleMessage("EXIT"),
        "moderator_exit_dialog": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to end this moderator session? All presenters will be removed."),
        "moderator_presentersLimit": MessageLookupByLibrary.simpleMessage(
            "Click the above toggle for Moderator Mode. Up to 6 presenters can join."),
        "moderator_presentersList":
            MessageLookupByLibrary.simpleMessage("Presenters"),
        "moderator_remove": MessageLookupByLibrary.simpleMessage("REMOVE"),
        "moderator_verifyCode_fail": MessageLookupByLibrary.simpleMessage(
            "Something went wrong. Please try again."),
        "toast_maximum_split_screen": MessageLookupByLibrary.simpleMessage(
            "Has reached maximum split screen amount."),
        "update_install_now":
            MessageLookupByLibrary.simpleMessage("INSTALL NOW"),
        "update_message": MessageLookupByLibrary.simpleMessage(
            "A new version of software is available"),
        "update_title": MessageLookupByLibrary.simpleMessage("AirSync Update"),
        "v3_authorize_prompt_accept":
            MessageLookupByLibrary.simpleMessage("Accept"),
        "v3_authorize_prompt_decline":
            MessageLookupByLibrary.simpleMessage("Decline"),
        "v3_broadcast_indicator": MessageLookupByLibrary.simpleMessage("ON"),
        "v3_cast_to_device_Receiving":
            MessageLookupByLibrary.simpleMessage("Receiving"),
        "v3_cast_to_device_list_msg":
            MessageLookupByLibrary.simpleMessage("Maximum up to 10 devices."),
        "v3_cast_to_device_menu_or": MessageLookupByLibrary.simpleMessage("Or"),
        "v3_cast_to_device_menu_quick_connect1":
            MessageLookupByLibrary.simpleMessage("Quick Connect"),
        "v3_cast_to_device_menu_quick_connect2":
            MessageLookupByLibrary.simpleMessage("by scan the QR code"),
        "v3_cast_to_device_menu_title":
            MessageLookupByLibrary.simpleMessage("Join to Receive This Screen"),
        "v3_cast_to_device_reached_maximum":
            MessageLookupByLibrary.simpleMessage(
                "You’ve reached the maximum limit."),
        "v3_cast_to_device_title":
            MessageLookupByLibrary.simpleMessage("Device list"),
        "v3_cast_to_device_touch_back":
            MessageLookupByLibrary.simpleMessage("Touchback"),
        "v3_cast_to_device_touch_back_disable":
            MessageLookupByLibrary.simpleMessage("Disable"),
        "v3_cast_to_device_touch_enabled":
            MessageLookupByLibrary.simpleMessage("Touchback"),
        "v3_download_app_desc": MessageLookupByLibrary.simpleMessage(
            "Scan the QR code with your iOS or Android device to download"),
        "v3_download_app_entry":
            MessageLookupByLibrary.simpleMessage("Download Sender App"),
        "v3_download_app_for_desktop":
            MessageLookupByLibrary.simpleMessage("For Desktop"),
        "v3_download_app_for_desktop_desc":
            MessageLookupByLibrary.simpleMessage(
                "Enter the following URL to download."),
        "v3_download_app_for_mobile":
            MessageLookupByLibrary.simpleMessage("For iOS & Android"),
        "v3_download_app_for_mobile_desc": MessageLookupByLibrary.simpleMessage(
            "Scan the QR code for instant access."),
        "v3_download_app_or": MessageLookupByLibrary.simpleMessage("OR"),
        "v3_download_app_title":
            MessageLookupByLibrary.simpleMessage("Download Sender App"),
        "v3_eula_agree": MessageLookupByLibrary.simpleMessage("Agree"),
        "v3_eula_disagree": MessageLookupByLibrary.simpleMessage("Disagree"),
        "v3_eula_title":
            MessageLookupByLibrary.simpleMessage("End-User License Agreement"),
        "v3_exit_moderator_mode_cancel":
            MessageLookupByLibrary.simpleMessage("Cancel"),
        "v3_exit_moderator_mode_desc": MessageLookupByLibrary.simpleMessage(
            "Are you sure? This will disconnect all participants."),
        "v3_exit_moderator_mode_exit":
            MessageLookupByLibrary.simpleMessage("Exit"),
        "v3_exit_moderator_mode_title":
            MessageLookupByLibrary.simpleMessage("Exit Moderator Mode"),
        "v3_group_dialog_accept":
            MessageLookupByLibrary.simpleMessage("Accept"),
        "v3_group_dialog_decline":
            MessageLookupByLibrary.simpleMessage("Decline"),
        "v3_group_dialog_message": MessageLookupByLibrary.simpleMessage(
            "%s has sent a broadcast request to your device. This action will synchronize and display the current content, do you want to accept this request?"),
        "v3_group_dialog_no_device_message":
            MessageLookupByLibrary.simpleMessage("No device selected."),
        "v3_group_dialog_title":
            MessageLookupByLibrary.simpleMessage("Broadcast Request from %s"),
        "v3_group_receive_view_status_from":
            MessageLookupByLibrary.simpleMessage("Broadcasting from"),
        "v3_group_receive_view_status_stop":
            MessageLookupByLibrary.simpleMessage("Stop"),
        "v3_group_reject_invited": MessageLookupByLibrary.simpleMessage(
            "declined your broadcast request, please check the Broads setting."),
        "v3_instruction1a": MessageLookupByLibrary.simpleMessage(
            "Visit airsync.net or open the sender app"),
        "v3_instruction1b":
            MessageLookupByLibrary.simpleMessage("Open the sender app"),
        "v3_instruction2":
            MessageLookupByLibrary.simpleMessage("Enter display code"),
        "v3_instruction3":
            MessageLookupByLibrary.simpleMessage("Enter one-time password"),
        "v3_instruction_share_screen":
            MessageLookupByLibrary.simpleMessage("Share Your Screens"),
        "v3_instruction_support": MessageLookupByLibrary.simpleMessage(
            "Supports sharing via AirPlay, Google Cast or Miracast"),
        "v3_main_status_no_network": MessageLookupByLibrary.simpleMessage(
            "Unable to detect an internet connection. Please connect to a Wi-Fi or intranet network, and try again."),
        "v3_mirror_request_passcode":
            MessageLookupByLibrary.simpleMessage("Passcode"),
        "v3_moderator_disable_mirror_cancel":
            MessageLookupByLibrary.simpleMessage("Cancel"),
        "v3_moderator_disable_mirror_desc":
            MessageLookupByLibrary.simpleMessage(
                "Mirroring will be disabled in moderator mode"),
        "v3_moderator_disable_mirror_ok":
            MessageLookupByLibrary.simpleMessage("OK"),
        "v3_moderator_disable_mirror_title":
            MessageLookupByLibrary.simpleMessage(
                "Disable Mirroring for Moderator Mode"),
        "v3_moderator_mode":
            MessageLookupByLibrary.simpleMessage("Moderator mode"),
        "v3_new_sharing_join_session":
            MessageLookupByLibrary.simpleMessage(" joined the session"),
        "v3_participant_item_casting":
            MessageLookupByLibrary.simpleMessage("Casting"),
        "v3_participant_item_connected":
            MessageLookupByLibrary.simpleMessage("Connected"),
        "v3_participant_item_controlling":
            MessageLookupByLibrary.simpleMessage("Receiving + Touchback"),
        "v3_participant_item_receiving":
            MessageLookupByLibrary.simpleMessage("Receiving"),
        "v3_participant_item_share":
            MessageLookupByLibrary.simpleMessage("Share"),
        "v3_participant_item_waiting":
            MessageLookupByLibrary.simpleMessage("Waiting..."),
        "v3_participants_desc": MessageLookupByLibrary.simpleMessage(
            "Maximum up to 6 participants."),
        "v3_participants_title":
            MessageLookupByLibrary.simpleMessage("Participants"),
        "v3_qrcode_quick_connect":
            MessageLookupByLibrary.simpleMessage("Quick Connect"),
        "v3_quick_connect_menu_bottom_msg":
            MessageLookupByLibrary.simpleMessage(
                "Split-screen activates if two or more users share screens."),
        "v3_quick_connect_menu_display_code":
            MessageLookupByLibrary.simpleMessage("Display Code"),
        "v3_quick_connect_menu_qrcode":
            MessageLookupByLibrary.simpleMessage("QR Code"),
        "v3_settings_all_the_time_info": MessageLookupByLibrary.simpleMessage(
            "Broadcast source IFP screen all the time."),
        "v3_settings_broadcast":
            MessageLookupByLibrary.simpleMessage("Broadcast"),
        "v3_settings_broadcast_boards":
            MessageLookupByLibrary.simpleMessage("Other AirSync devices"),
        "v3_settings_broadcast_cast_boards":
            MessageLookupByLibrary.simpleMessage("Cast to boards"),
        "v3_settings_broadcast_cast_boards_desc":
            MessageLookupByLibrary.simpleMessage(
                "Share this screen to all Interactive Flat Panels (IFPs) in the network."),
        "v3_settings_broadcast_cast_to":
            MessageLookupByLibrary.simpleMessage("Broadcast to"),
        "v3_settings_broadcast_devices":
            MessageLookupByLibrary.simpleMessage("Sender devices"),
        "v3_settings_broadcast_screen_energy_saving":
            MessageLookupByLibrary.simpleMessage(
                "Please turn off energy saving to avoid unexpected interruption during broadcasting."),
        "v3_settings_broadcast_to_display_group":
            MessageLookupByLibrary.simpleMessage(
                "Broadcast to the display group"),
        "v3_settings_connectivity":
            MessageLookupByLibrary.simpleMessage("Connectivity"),
        "v3_settings_connectivity_both": MessageLookupByLibrary.simpleMessage(
            "Both internet & local connection"),
        "v3_settings_connectivity_internet":
            MessageLookupByLibrary.simpleMessage("Internet connection"),
        "v3_settings_connectivity_internet_desc":
            MessageLookupByLibrary.simpleMessage(
                "Internet connection requires a stable network."),
        "v3_settings_connectivity_local":
            MessageLookupByLibrary.simpleMessage("Local connection"),
        "v3_settings_connectivity_local_desc": MessageLookupByLibrary.simpleMessage(
            "Local connections operate within a private network, offering more security and stability."),
        "v3_settings_device_authorize_mode":
            MessageLookupByLibrary.simpleMessage(
                "Require approval for all screen sharing requests."),
        "v3_settings_device_auto_fill_otp":
            MessageLookupByLibrary.simpleMessage("Auto-fill one-time password"),
        "v3_settings_device_auto_fill_otp_desc":
            MessageLookupByLibrary.simpleMessage(
                "Enable one-touch connection when this device is selected from the Sender app\'s Quick Connect menu."),
        "v3_settings_device_launch_on_startup":
            MessageLookupByLibrary.simpleMessage("Launch AirSync on startup"),
        "v3_settings_device_name":
            MessageLookupByLibrary.simpleMessage("Device Name"),
        "v3_settings_device_name_save":
            MessageLookupByLibrary.simpleMessage("Save"),
        "v3_settings_device_setting":
            MessageLookupByLibrary.simpleMessage("Device setting"),
        "v3_settings_device_show_display_code":
            MessageLookupByLibrary.simpleMessage("Show display code on top"),
        "v3_settings_device_show_display_code_desc":
            MessageLookupByLibrary.simpleMessage(
                "Keep the code visible at the top of the screen, even when switching to other apps and screen sharing is active."),
        "v3_settings_device_unavailable":
            MessageLookupByLibrary.simpleMessage("Unavailable"),
        "v3_settings_display_group":
            MessageLookupByLibrary.simpleMessage("Display Group"),
        "v3_settings_display_group_all_the_time":
            MessageLookupByLibrary.simpleMessage("All the time"),
        "v3_settings_display_group_cast":
            MessageLookupByLibrary.simpleMessage("Broadcast"),
        "v3_settings_display_group_only_casting":
            MessageLookupByLibrary.simpleMessage("Only when casting"),
        "v3_settings_feature_locked": MessageLookupByLibrary.simpleMessage(
            "Locked by ViewSonic Manager."),
        "v3_settings_invite_group": MessageLookupByLibrary.simpleMessage(
            "If invited to a display group"),
        "v3_settings_invite_group_auto_accept":
            MessageLookupByLibrary.simpleMessage("Auto Accept"),
        "v3_settings_invite_group_ignore":
            MessageLookupByLibrary.simpleMessage("Ignore"),
        "v3_settings_invite_group_notify_me":
            MessageLookupByLibrary.simpleMessage("Notify me"),
        "v3_settings_legal_policy":
            MessageLookupByLibrary.simpleMessage("Legal & Policy"),
        "v3_settings_local_connection_only":
            MessageLookupByLibrary.simpleMessage("Local connection only"),
        "v3_settings_mirroring_auto_accept":
            MessageLookupByLibrary.simpleMessage("Auto Accept"),
        "v3_settings_mirroring_auto_accept_desc":
            MessageLookupByLibrary.simpleMessage(
                "Instantly enable mirroring without requiring moderator approval."),
        "v3_settings_mirroring_blocked": MessageLookupByLibrary.simpleMessage(
            "Turn off moderator mode first."),
        "v3_settings_mirroring_require_passcode":
            MessageLookupByLibrary.simpleMessage("Require passcode"),
        "v3_settings_only_when_casting_info": MessageLookupByLibrary.simpleMessage(
            "Broadcast the source IFP screen only when it is receiving a shared screen."),
        "v3_settings_open_source_license":
            MessageLookupByLibrary.simpleMessage("Open Source Licenses"),
        "v3_settings_privacy_policy":
            MessageLookupByLibrary.simpleMessage("Privacy Policy"),
        "v3_settings_privacy_policy_description":
            MessageLookupByLibrary.simpleMessage(
                "ViewSonic is committed to protecting your privacy and treats the handling of personal data seriously. The Privacy Policy below details how ViewSonic will treat your personal data after it has been collected by ViewSonic through your use of the Website. ViewSonic maintains the privacy of your information using security technologies and adhere to policies that prevent unauthorized use of your personal information. By using this Website, you consent to the collection and use of your information.\n\nWebsites you link to from ViewSonic.com may have their own privacy policy that may differ from ViewSonic’s. Please review those websites’ privacy policies for detailed information on how they may use information gathered while you are visiting them.\n\nPlease click the following links to learn more about our Privacy Policy."),
        "v3_settings_version": m0,
        "v3_settings_whats_new":
            MessageLookupByLibrary.simpleMessage("What\'s new"),
        "v3_settings_whats_new_content": MessageLookupByLibrary.simpleMessage(
            "AirSync %s\n\nAirSync is a ViewSonic proprietary wireless screen-sharing solution. When used with the AirSync sender, it enables seamless screen sharing from a user\'s device to ViewSonic interactive displays.\n\nKey features: \n\n1. Wireless screensharing.\n\n2. Automatic split screens for multiple presenters.\n\n3. Moderator mode to enable more control during presentation.\n\n4. Screen mirror to support AirPlay, Google Cast and Miracast.\n\n5. Cast to device with remote control.\n\n6. Cast to board to broadcast screens to multiple large screens.\n\n7. Annotation.\n\n8. Interact with Windows, macOS, iOS, Android and web version AirSync sender.\n\n9. Touchback is supported in Windows and macOS sender.\n\n"),
        "v3_shortcuts_airplay": MessageLookupByLibrary.simpleMessage("AirPlay"),
        "v3_shortcuts_cast_device":
            MessageLookupByLibrary.simpleMessage("Cast to devices"),
        "v3_shortcuts_cast_device_desc": MessageLookupByLibrary.simpleMessage(
            "Cast this screen to multiple devices, including laptops, tablets and mobile devices simultaneously."),
        "v3_shortcuts_google_cast":
            MessageLookupByLibrary.simpleMessage("Google Cast"),
        "v3_shortcuts_menu_title":
            MessageLookupByLibrary.simpleMessage("Shortcuts"),
        "v3_shortcuts_miracast":
            MessageLookupByLibrary.simpleMessage("Miracast"),
        "v3_shortcuts_mirroring":
            MessageLookupByLibrary.simpleMessage("Mirroring"),
        "v3_waiting_desc": MessageLookupByLibrary.simpleMessage(
            "Waiting for this participant to share their screen"),
        "v3_waiting_join":
            MessageLookupByLibrary.simpleMessage("Waiting for others to join"),
        "v3_waiting_up_next": MessageLookupByLibrary.simpleMessage("Up next"),
        "vbs_ota_progress_msg":
            MessageLookupByLibrary.simpleMessage("Downloading system updates")
      };
}
