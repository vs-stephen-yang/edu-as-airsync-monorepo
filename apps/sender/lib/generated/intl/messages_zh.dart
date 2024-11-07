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
        "device_list_enter_pin": MessageLookupByLibrary.simpleMessage("一次性密碼"),
        "device_list_enter_pin_ok": MessageLookupByLibrary.simpleMessage("OK"),
        "main_connect_network_error":
            MessageLookupByLibrary.simpleMessage("網路連線異常，請檢查網路連線"),
        "main_connect_rate_limited":
            MessageLookupByLibrary.simpleMessage("服務忙碌中，請稍後再試"),
        "main_connect_unknown_error":
            MessageLookupByLibrary.simpleMessage("未知的錯誤"),
        "main_connection_mode_unsupported":
            MessageLookupByLibrary.simpleMessage("AirSync無網際網路連線"),
        "main_device_list": MessageLookupByLibrary.simpleMessage("快速連線"),
        "main_display_code": MessageLookupByLibrary.simpleMessage("投影辨識碼"),
        "main_display_code_description":
            MessageLookupByLibrary.simpleMessage("請輸入投影辨識碼 (不含空格)"),
        "main_display_code_error":
            MessageLookupByLibrary.simpleMessage("僅允許輸入英數字"),
        "main_display_code_exceed":
            MessageLookupByLibrary.simpleMessage("已達到參與人員上限"),
        "main_display_code_exceed_split_screen":
            MessageLookupByLibrary.simpleMessage("已達到分割螢幕數量上限"),
        "main_display_code_invalid":
            MessageLookupByLibrary.simpleMessage("無效的投影辨識碼"),
        "main_feature_reconnect_fail_toast":
            MessageLookupByLibrary.simpleMessage("網路(控制)重連失敗"),
        "main_feature_reconnect_success_toast":
            MessageLookupByLibrary.simpleMessage("網路(控制)重連成功"),
        "main_feature_reconnecting_toast":
            MessageLookupByLibrary.simpleMessage("網路(控制)重連中"),
        "main_instance_not_found_or_offline":
            MessageLookupByLibrary.simpleMessage("找不到投影辨識碼或是服務未啟動"),
        "main_language": MessageLookupByLibrary.simpleMessage("語言"),
        "main_language_name": MessageLookupByLibrary.simpleMessage("繁體中文"),
        "main_notice_not_support_description":
            MessageLookupByLibrary.simpleMessage(
                "行動設備端不支援透過瀏覽器分享畫面。請下載並使用AirSync傳送端app以分享畫面。"),
        "main_notice_positive_button":
            MessageLookupByLibrary.simpleMessage("下載AirSync傳送端app"),
        "main_notice_title": MessageLookupByLibrary.simpleMessage("請注意"),
        "main_otp_error": MessageLookupByLibrary.simpleMessage("僅允許輸入數字"),
        "main_password": MessageLookupByLibrary.simpleMessage("一次性密碼"),
        "main_password_description":
            MessageLookupByLibrary.simpleMessage("請輸入一次性密碼"),
        "main_password_invalid": MessageLookupByLibrary.simpleMessage("密碼錯誤"),
        "main_present": MessageLookupByLibrary.simpleMessage("下一步"),
        "main_setting": MessageLookupByLibrary.simpleMessage("設定"),
        "main_touch_back": MessageLookupByLibrary.simpleMessage("觸控反饋"),
        "main_update_deny_button": MessageLookupByLibrary.simpleMessage("現在不要"),
        "main_update_description_android":
            MessageLookupByLibrary.simpleMessage("請按下\"更新\"以安裝新的版本。"),
        "main_update_description_apple":
            MessageLookupByLibrary.simpleMessage("請按下\"更新\"以安裝新的版本。"),
        "main_update_description_windows":
            MessageLookupByLibrary.simpleMessage("請按下\"更新\"以安裝新的版本。"),
        "main_update_error_detail":
            MessageLookupByLibrary.simpleMessage("描述: "),
        "main_update_error_title":
            MessageLookupByLibrary.simpleMessage("版本更新失敗"),
        "main_update_error_type":
            MessageLookupByLibrary.simpleMessage("失敗原因: "),
        "main_update_positive_button":
            MessageLookupByLibrary.simpleMessage("更新"),
        "main_update_title": MessageLookupByLibrary.simpleMessage("有新的更新"),
        "main_webrtc_reconnect_fail_toast":
            MessageLookupByLibrary.simpleMessage("網路(影像)重連失敗"),
        "main_webrtc_reconnect_success_toast":
            MessageLookupByLibrary.simpleMessage("網路(影像)重連成功"),
        "main_webrtc_reconnecting_toast":
            MessageLookupByLibrary.simpleMessage("網路(影像)重連中"),
        "moderator": MessageLookupByLibrary.simpleMessage("請輸入姓名"),
        "moderator_back": MessageLookupByLibrary.simpleMessage("返回"),
        "moderator_exit": MessageLookupByLibrary.simpleMessage("結束"),
        "moderator_fill_out": MessageLookupByLibrary.simpleMessage("必填欄位"),
        "moderator_name": MessageLookupByLibrary.simpleMessage("姓名"),
        "moderator_wait": MessageLookupByLibrary.simpleMessage("請等待主持人指定分享人員"),
        "present_role_cast_screen":
            MessageLookupByLibrary.simpleMessage("分享螢幕"),
        "present_role_receive": MessageLookupByLibrary.simpleMessage("接收螢幕"),
        "present_select_screen_cancel":
            MessageLookupByLibrary.simpleMessage("取消分享"),
        "present_select_screen_description":
            MessageLookupByLibrary.simpleMessage("選擇要分享的螢幕"),
        "present_select_screen_entire":
            MessageLookupByLibrary.simpleMessage("分享整個螢幕"),
        "present_select_screen_ios_restart":
            MessageLookupByLibrary.simpleMessage("開始直播"),
        "present_select_screen_ios_restart_description":
            MessageLookupByLibrary.simpleMessage(
                "請在連線逾時前點擊\"開始直播\"以分享畫面，或點擊\"返回\"回到初始畫面。"),
        "present_select_screen_share":
            MessageLookupByLibrary.simpleMessage("分享"),
        "present_select_screen_share_audio":
            MessageLookupByLibrary.simpleMessage("分享音訊"),
        "present_select_screen_window":
            MessageLookupByLibrary.simpleMessage("分享應用程式視窗"),
        "present_state_high_quality_description":
            MessageLookupByLibrary.simpleMessage("僅適用於良好的網路環境"),
        "present_state_high_quality_title":
            MessageLookupByLibrary.simpleMessage("高畫質"),
        "present_state_pause": MessageLookupByLibrary.simpleMessage("暫停分享"),
        "present_state_resume": MessageLookupByLibrary.simpleMessage("恢復分享"),
        "present_state_stop": MessageLookupByLibrary.simpleMessage("停止分享"),
        "present_time": MessageLookupByLibrary.simpleMessage("經過時間"),
        "present_time_unit_hour": MessageLookupByLibrary.simpleMessage("小時"),
        "present_time_unit_min": MessageLookupByLibrary.simpleMessage("分鐘"),
        "present_time_unit_sec": MessageLookupByLibrary.simpleMessage("秒"),
        "present_wait": m0,
        "remote_screen_wait":
            MessageLookupByLibrary.simpleMessage("分享畫面處理中，請稍後"),
        "settings_audio_configuration":
            MessageLookupByLibrary.simpleMessage("音訊設定說明"),
        "settings_knowledge_base": MessageLookupByLibrary.simpleMessage("知識庫"),
        "toast_enable_remote_screen":
            MessageLookupByLibrary.simpleMessage("請在AirSync開啟分享畫面到設備端功能"),
        "toast_install_audio_driver":
            MessageLookupByLibrary.simpleMessage("請安裝虛擬音效驅動程式"),
        "toast_maximum_moderated":
            MessageLookupByLibrary.simpleMessage("主持人模式已達到最大連線人數"),
        "toast_maximum_remote_screen":
            MessageLookupByLibrary.simpleMessage("已達到分享畫面上限"),
        "toast_maximum_split_screen":
            MessageLookupByLibrary.simpleMessage("已達到投影人員上限"),
        "v3_device_list_button_device_list":
            MessageLookupByLibrary.simpleMessage("裝置清單"),
        "v3_main_download": MessageLookupByLibrary.simpleMessage("下載"),
        "v3_setting_check_update": MessageLookupByLibrary.simpleMessage("檢查更新"),
        "v3_setting_knowledge_base":
            MessageLookupByLibrary.simpleMessage("知識庫"),
        "v3_setting_language": MessageLookupByLibrary.simpleMessage("語言"),
        "v3_setting_legal_policy":
            MessageLookupByLibrary.simpleMessage("法律和隱私"),
        "v3_setting_open_source_license":
            MessageLookupByLibrary.simpleMessage("開源許可證"),
        "v3_setting_privacy_policy":
            MessageLookupByLibrary.simpleMessage("隱私政策"),
        "v3_setting_privacy_policy_description":
            MessageLookupByLibrary.simpleMessage(""),
        "v3_setting_software_update":
            MessageLookupByLibrary.simpleMessage("軟體更新"),
        "v3_setting_software_update_deny_action":
            MessageLookupByLibrary.simpleMessage("稍後更新"),
        "v3_setting_software_update_description":
            MessageLookupByLibrary.simpleMessage("有新版本軟體可供更新，請問現在更新嗎?"),
        "v3_setting_software_update_force_action":
            MessageLookupByLibrary.simpleMessage("立即更新"),
        "v3_setting_software_update_force_description":
            MessageLookupByLibrary.simpleMessage("有新版本軟體可供更新，請立即更新"),
        "v3_setting_software_update_no_available":
            MessageLookupByLibrary.simpleMessage("無可用的更新"),
        "v3_setting_software_update_no_available_action":
            MessageLookupByLibrary.simpleMessage("好"),
        "v3_setting_software_update_no_available_description":
            MessageLookupByLibrary.simpleMessage("目前已是最新版本"),
        "v3_setting_software_update_no_internet_description":
            MessageLookupByLibrary.simpleMessage("請確認網際網路連線恢復後再進行更新"),
        "v3_setting_software_update_no_internet_tittle":
            MessageLookupByLibrary.simpleMessage("無網際網路連線"),
        "v3_setting_software_update_positive_action":
            MessageLookupByLibrary.simpleMessage("立即更新")
      };
}
