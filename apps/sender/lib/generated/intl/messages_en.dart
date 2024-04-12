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
        "main_connect_network_error": MessageLookupByLibrary.simpleMessage(
            "Network error. Please check network connectivity and try again."),
        "main_connect_rate_limited": MessageLookupByLibrary.simpleMessage(
            "AirSync instance is busy. Please try it later."),
        "main_connect_unknown_error":
            MessageLookupByLibrary.simpleMessage("Unknown error."),
        "main_connection_mode_unsupported":
            MessageLookupByLibrary.simpleMessage(
                "AirSync does not connect to Internet."),
        "main_display_code":
            MessageLookupByLibrary.simpleMessage("Display code"),
        "main_display_code_description":
            MessageLookupByLibrary.simpleMessage("Please input display code"),
        "main_display_code_error": MessageLookupByLibrary.simpleMessage(
            "*Display Code contains 11 characters!"),
        "main_display_code_exceed": MessageLookupByLibrary.simpleMessage(
            "Maximum participants (6) reached."),
        "main_display_code_exceed_split_screen":
            MessageLookupByLibrary.simpleMessage(
                "Maximum presenters (4) reached."),
        "main_display_code_invalid":
            MessageLookupByLibrary.simpleMessage("Invalid Display code"),
        "main_instance_not_found_or_offline":
            MessageLookupByLibrary.simpleMessage(
                "Display code not found or instance is offline."),
        "main_language": MessageLookupByLibrary.simpleMessage("Language"),
        "main_language_name": MessageLookupByLibrary.simpleMessage("English"),
        "main_otp_error": MessageLookupByLibrary.simpleMessage(
            "*One Time Password contains 4 digits!"),
        "main_password": MessageLookupByLibrary.simpleMessage("Password"),
        "main_password_description": MessageLookupByLibrary.simpleMessage(
            "Please enter one-time password"),
        "main_password_invalid":
            MessageLookupByLibrary.simpleMessage("Password invalid."),
        "main_present": MessageLookupByLibrary.simpleMessage("Next"),
        "main_setting": MessageLookupByLibrary.simpleMessage("Settings"),
        "main_touch_back": MessageLookupByLibrary.simpleMessage("Touchback"),
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
        "present_select_screen_share":
            MessageLookupByLibrary.simpleMessage("Share"),
        "present_select_screen_share_audio":
            MessageLookupByLibrary.simpleMessage("Share screen audio"),
        "present_select_screen_window":
            MessageLookupByLibrary.simpleMessage("Window"),
        "present_state_pause": MessageLookupByLibrary.simpleMessage("Pause"),
        "present_state_resume": MessageLookupByLibrary.simpleMessage("Resume"),
        "present_state_stop":
            MessageLookupByLibrary.simpleMessage("Stop presenting"),
        "present_time": MessageLookupByLibrary.simpleMessage("Time elapsed"),
        "present_time_unit_hour": MessageLookupByLibrary.simpleMessage("hr"),
        "present_time_unit_min": MessageLookupByLibrary.simpleMessage("mins"),
        "present_time_unit_sec": MessageLookupByLibrary.simpleMessage("secs"),
        "present_wait": m0,
        "remote_screen_wait": MessageLookupByLibrary.simpleMessage(
            "Sharing is in processing, please wait."),
        "settings_audio_configuration":
            MessageLookupByLibrary.simpleMessage("Audio configuration"),
        "settings_knowledge_base":
            MessageLookupByLibrary.simpleMessage("Knowledge Base"),
        "toast_enable_remote_screen": MessageLookupByLibrary.simpleMessage(
            "Please enable share to sender in AirSync."),
        "toast_install_audio_driver": MessageLookupByLibrary.simpleMessage(
            "Please install virtual audio driver."),
        "toast_maximum_moderated": MessageLookupByLibrary.simpleMessage(
            "Has reached maximum moderated session amount."),
        "toast_maximum_remote_screen": MessageLookupByLibrary.simpleMessage(
            "Has reached maximum shared screen amount."),
        "toast_maximum_split_screen": MessageLookupByLibrary.simpleMessage(
            "Has reached maximum split screen amount.")
      };
}
