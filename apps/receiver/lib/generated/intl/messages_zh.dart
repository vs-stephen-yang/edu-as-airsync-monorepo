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
        "eula_agree": MessageLookupByLibrary.simpleMessage("同意"),
        "eula_disagree": MessageLookupByLibrary.simpleMessage("不同意"),
        "eula_title": MessageLookupByLibrary.simpleMessage(
            "myViewBoard Display 終端使用者授權合約"),
        "main_content_display_code":
            MessageLookupByLibrary.simpleMessage("投影辨識碼"),
        "main_content_one_time_password":
            MessageLookupByLibrary.simpleMessage("一次性密碼"),
        "main_content_one_time_password_get_fail":
            MessageLookupByLibrary.simpleMessage("無法取得一次性密碼\n30秒後將再次執行"),
        "main_content_scan_or": MessageLookupByLibrary.simpleMessage("或"),
        "main_content_scan_to_enroll":
            MessageLookupByLibrary.simpleMessage("使用Companion App掃描註冊"),
        "main_get_display_code_failure":
            MessageLookupByLibrary.simpleMessage("取得投影辨識碼失敗"),
        "main_language_name": MessageLookupByLibrary.simpleMessage("繁體中文"),
        "main_language_title": MessageLookupByLibrary.simpleMessage("語言"),
        "main_limit_time_message":
            MessageLookupByLibrary.simpleMessage("五分鐘後結束"),
        "main_privilege_close": MessageLookupByLibrary.simpleMessage("關閉"),
        "main_privilege_message":
            MessageLookupByLibrary.simpleMessage("權限不足，請聯繫IT管理員"),
        "main_register_display_code_failure":
            MessageLookupByLibrary.simpleMessage("註冊投影辨識碼失敗"),
        "main_split_screen_question":
            MessageLookupByLibrary.simpleMessage("啟動分割畫面?"),
        "main_split_screen_title": MessageLookupByLibrary.simpleMessage("分割畫面"),
        "main_split_screen_waiting":
            MessageLookupByLibrary.simpleMessage("分割畫面已啟動"),
        "main_status_go_background":
            MessageLookupByLibrary.simpleMessage("Display App 背景執行中"),
        "main_status_no_network":
            MessageLookupByLibrary.simpleMessage("網路品質不良\n請檢查網路連線"),
        "main_status_remaining_time":
            MessageLookupByLibrary.simpleMessage("%02d min : %02d sec"),
        "main_thanks_content":
            MessageLookupByLibrary.simpleMessage("感謝您使用 myViewBoard Display"),
        "main_wait_title": MessageLookupByLibrary.simpleMessage("等待投影中..."),
        "main_wait_up_next": MessageLookupByLibrary.simpleMessage("下一位投影者"),
        "main_whats_new_content": MessageLookupByLibrary.simpleMessage(
            "Display Advanced 新增功能\n1.\t將Display註冊到實體: \n    i.\tIT Admin可使用Companion App掃描QR code進行Display註冊\n    ii.\t完成註冊後，IT Admin可在Display管理介面(實體管理>Display)進行權限管理 \n2.\t主持人模式: \n    i.\t最多可容納6位人員\n    ii.\t主持人模式下，開啟分割畫面後，最多可同時指定4位人員同時投影\n    iii.\t主持人可隨時指定人員開始或是結束投影\n3.\t分割畫面模式: \n    i.\t最多可同時4位人員同時投影"),
        "main_whats_new_title": MessageLookupByLibrary.simpleMessage("最新消息"),
        "moderator_activate": MessageLookupByLibrary.simpleMessage("啟用"),
        "moderator_activate_split_screen":
            MessageLookupByLibrary.simpleMessage("確定啟用分割畫面功能嗎?最多可四人同時投影。"),
        "moderator_cancel": MessageLookupByLibrary.simpleMessage("取消"),
        "moderator_confirm": MessageLookupByLibrary.simpleMessage("確定"),
        "moderator_deactivate_split_screen":
            MessageLookupByLibrary.simpleMessage("確定結束分割畫面功能嗎?"),
        "moderator_exit": MessageLookupByLibrary.simpleMessage("退出"),
        "moderator_exit_dialog":
            MessageLookupByLibrary.simpleMessage("確定要退出嗎?"),
        "moderator_presentersLimit":
            MessageLookupByLibrary.simpleMessage("最多六人參加"),
        "moderator_presentersList":
            MessageLookupByLibrary.simpleMessage("人員列表"),
        "moderator_remove": MessageLookupByLibrary.simpleMessage("移除"),
        "moderator_verifyCode_fail":
            MessageLookupByLibrary.simpleMessage("抱歉，出現問題，請稍後再試。"),
        "vbs_ota_progress_msg": MessageLookupByLibrary.simpleMessage("更新下載中")
      };
}
