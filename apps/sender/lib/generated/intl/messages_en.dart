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
        "main_language_title": MessageLookupByLibrary.simpleMessage("Language"),
        "moderator_name": MessageLookupByLibrary.simpleMessage("Name *"),
        "moderator_wait": MessageLookupByLibrary.simpleMessage(
            "Please wait for your turn... Moderator will select presenters"),
        "present_display_code":
            MessageLookupByLibrary.simpleMessage("Display Code *"),
        "present_display_code_description":
            MessageLookupByLibrary.simpleMessage(
                "*Display Code contains 9-10 digits"),
        "present_fill_out":
            MessageLookupByLibrary.simpleMessage("Please fill out this field."),
        "present_otp_code":
            MessageLookupByLibrary.simpleMessage("One Time Password *"),
        "present_otp_code_description": MessageLookupByLibrary.simpleMessage(
            "*One Time Password contains 4 digits"),
        "present_start": MessageLookupByLibrary.simpleMessage("PRESENT"),
        "setting": MessageLookupByLibrary.simpleMessage("Settings"),
        "touchback": MessageLookupByLibrary.simpleMessage("Touchback")
      };
}
