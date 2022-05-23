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
        "connection_connect_timeout":
            MessageLookupByLibrary.simpleMessage("connection timeout."),
        "eula_agree": MessageLookupByLibrary.simpleMessage("I Agree"),
        "eula_disagree": MessageLookupByLibrary.simpleMessage("I Disagree"),
        "eula_title":
            MessageLookupByLibrary.simpleMessage("myViewBoard Display EULA"),
        "get_code_failure":
            MessageLookupByLibrary.simpleMessage("get display code failure: "),
        "main_content_display_code":
            MessageLookupByLibrary.simpleMessage("Display Code"),
        "main_content_one_time_password":
            MessageLookupByLibrary.simpleMessage("One Time Password"),
        "main_content_one_time_password_get_fail":
            MessageLookupByLibrary.simpleMessage(
                "Failed to get new password. Please wait for 30 seconds before retrying."),
        "main_content_scan_or": MessageLookupByLibrary.simpleMessage("or"),
        "main_content_scan_to_enroll":
            MessageLookupByLibrary.simpleMessage("Scan to enroll"),
        "main_language_name": MessageLookupByLibrary.simpleMessage("English"),
        "main_language_title": MessageLookupByLibrary.simpleMessage("Language"),
        "main_status_no_network": MessageLookupByLibrary.simpleMessage(
            "Poor network connection detected.\nPlease check your connectivity."),
        "main_thanks_content": MessageLookupByLibrary.simpleMessage(
            "Thank you for using myViewBoard Display."),
        "main_wait_up_next": MessageLookupByLibrary.simpleMessage("UP NEXT"),
        "main_whats_new_content": MessageLookupByLibrary.simpleMessage(
            "[Improvements]\n- 1\n- 2\n- 3\n- 4\n- 5\n- 6\n- 7\n- 8\n- 9\n\n[Modifications]\n- 1\n- 2\n- 3\n- 4\n- 5\n- 6\n"),
        "main_whats_new_title":
            MessageLookupByLibrary.simpleMessage("What’s New on Display?"),
        "moderator_activate": MessageLookupByLibrary.simpleMessage("Activate"),
        "moderator_cancel": MessageLookupByLibrary.simpleMessage("CANCEL"),
        "moderator_exit": MessageLookupByLibrary.simpleMessage("EXIT"),
        "moderator_exit_dialog": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to exit?"),
        "moderator_presentersLimit":
            MessageLookupByLibrary.simpleMessage("Maximum 6 people"),
        "moderator_presentersList":
            MessageLookupByLibrary.simpleMessage("Presenters\' List"),
        "moderator_remove": MessageLookupByLibrary.simpleMessage("REMOVE"),
        "moderator_verifyCode_fail": MessageLookupByLibrary.simpleMessage(
            "Something went wrong, please try again")
      };
}
