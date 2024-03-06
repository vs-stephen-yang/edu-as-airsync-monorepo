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
            MessageLookupByLibrary.simpleMessage("Chromecast"),
        "main_cast_settings_miracast":
            MessageLookupByLibrary.simpleMessage("Miracast"),
        "main_cast_settings_title":
            MessageLookupByLibrary.simpleMessage("Cast Settings"),
        "main_content_display_code":
            MessageLookupByLibrary.simpleMessage("Display Code"),
        "main_content_one_time_password":
            MessageLookupByLibrary.simpleMessage("One Time Password"),
        "main_content_one_time_password_get_fail":
            MessageLookupByLibrary.simpleMessage(
                "Failed to refresh password.\nPlease wait for 30 seconds before retrying."),
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
        "main_settings_pin_visible":
            MessageLookupByLibrary.simpleMessage("PIN visible"),
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
        "main_whats_new_content": MessageLookupByLibrary.simpleMessage(
            "[New Feature]\n1. Screen mirror\n - Miracast.\n - AirPlay.\n - Chromecast.\n2. Support multiple AirSync sender application\n - Windows sender application.\n - macOS sender application.\n - Android sender application.\n - iOS sender application.\n - Web sender.\n3. Split screen\n - By defaut AirSync supports up to 4-split screens.\n4. Moderator mode\n - By default AirSync supports up to 6 participants waiting room.\n - Moderator can freely choose participants to present and control the presentation.\n5. Share to sender\n - When enabled, up to 10 sender application can receive AirSync screen."),
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
        "update_install_now":
            MessageLookupByLibrary.simpleMessage("INSTALL NOW"),
        "update_message": MessageLookupByLibrary.simpleMessage(
            "A new version of software is available"),
        "update_title": MessageLookupByLibrary.simpleMessage("AirSync Update"),
        "vbs_ota_progress_msg":
            MessageLookupByLibrary.simpleMessage("Downloading system updates")
      };
}
