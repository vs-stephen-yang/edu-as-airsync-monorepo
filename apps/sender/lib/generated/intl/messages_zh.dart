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

  static String m0(value) => "請在${value}秒內選擇要分享的螢幕";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "main_display_code": MessageLookupByLibrary.simpleMessage("投影辨識碼"),
        "main_display_code_description":
            MessageLookupByLibrary.simpleMessage("請輸入投影辨識碼"),
        "main_display_code_exceed":
            MessageLookupByLibrary.simpleMessage("已達到參與人員上限"),
        "main_display_code_exceed_split_screen":
            MessageLookupByLibrary.simpleMessage("已達到分割螢幕數量上限"),
        "main_language": MessageLookupByLibrary.simpleMessage("語言"),
        "main_language_name": MessageLookupByLibrary.simpleMessage("繁體中文"),
        "main_password": MessageLookupByLibrary.simpleMessage("一次性密碼"),
        "main_password_description":
            MessageLookupByLibrary.simpleMessage("請輸入一次性密碼"),
        "main_password_invalid": MessageLookupByLibrary.simpleMessage("密碼錯誤"),
        "main_present": MessageLookupByLibrary.simpleMessage("投影"),
        "main_setting": MessageLookupByLibrary.simpleMessage("設定"),
        "main_touch_back": MessageLookupByLibrary.simpleMessage("觸控反饋"),
        "moderator": MessageLookupByLibrary.simpleMessage("主持人"),
        "moderator_exit": MessageLookupByLibrary.simpleMessage("結束"),
        "moderator_fill_out": MessageLookupByLibrary.simpleMessage("必填欄位"),
        "moderator_name": MessageLookupByLibrary.simpleMessage("姓名"),
        "moderator_wait": MessageLookupByLibrary.simpleMessage("請等待主持人指定分享人員"),
        "present_select_screen_cancel":
            MessageLookupByLibrary.simpleMessage("取消分享"),
        "present_select_screen_description":
            MessageLookupByLibrary.simpleMessage("選擇要分享的螢幕"),
        "present_select_screen_entire":
            MessageLookupByLibrary.simpleMessage("分享整個螢幕"),
        "present_select_screen_share":
            MessageLookupByLibrary.simpleMessage("分享"),
        "present_select_screen_share_audio":
            MessageLookupByLibrary.simpleMessage("分享音訊"),
        "present_select_screen_window":
            MessageLookupByLibrary.simpleMessage("分享應用程式視窗"),
        "present_state_pause": MessageLookupByLibrary.simpleMessage("暫停分享"),
        "present_state_resume": MessageLookupByLibrary.simpleMessage("恢復分享"),
        "present_state_stop": MessageLookupByLibrary.simpleMessage("停止分享"),
        "present_time": MessageLookupByLibrary.simpleMessage("經過時間"),
        "present_time_unit_hour": MessageLookupByLibrary.simpleMessage("小時"),
        "present_time_unit_min": MessageLookupByLibrary.simpleMessage("分鐘"),
        "present_time_unit_sec": MessageLookupByLibrary.simpleMessage("秒"),
        "present_wait": m0,
        "settings_knowledge_base": MessageLookupByLibrary.simpleMessage("知識庫")
      };
}
