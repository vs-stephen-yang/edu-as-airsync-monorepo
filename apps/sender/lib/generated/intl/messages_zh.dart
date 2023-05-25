// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
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
  String get localeName => 'zh';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "main_language_title": MessageLookupByLibrary.simpleMessage("語言"),
        "present_display_code": MessageLookupByLibrary.simpleMessage("投影辨識碼 *"),
        "present_display_code_description":
            MessageLookupByLibrary.simpleMessage("*9到10碼投影辨識碼"),
        "present_fill_out": MessageLookupByLibrary.simpleMessage("請填寫此字段。"),
        "present_name": MessageLookupByLibrary.simpleMessage("投影人員姓名 *"),
        "present_otp_code": MessageLookupByLibrary.simpleMessage("一次性密碼 *"),
        "present_otp_code_description":
            MessageLookupByLibrary.simpleMessage("*4碼一次性密碼"),
        "present_start": MessageLookupByLibrary.simpleMessage("投影")
      };
}
