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

  static String m1(year) =>
      "Copyright © ViewSonic Corporation ${year}. All rights reserved.";

  static String m2(year, version) => "AirSync ©${year}. 版本 ${version}";

  static String m3(year, version) => "AirSync ©${year}. 版本 ${version} (Ind.)";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "device_list_enter_pin": MessageLookupByLibrary.simpleMessage("一次性密碼"),
    "device_list_enter_pin_ok": MessageLookupByLibrary.simpleMessage("OK"),
    "main_connect_network_error": MessageLookupByLibrary.simpleMessage(
      "網路連線異常，請檢查網路連線",
    ),
    "main_connect_rate_limited": MessageLookupByLibrary.simpleMessage(
      "服務忙碌中，請稍後再試",
    ),
    "main_connect_unknown_error": MessageLookupByLibrary.simpleMessage("未知的錯誤"),
    "main_connection_mode_unsupported": MessageLookupByLibrary.simpleMessage(
      "AirSync無網際網路連線",
    ),
    "main_device_list": MessageLookupByLibrary.simpleMessage("快速連線"),
    "main_display_code": MessageLookupByLibrary.simpleMessage("投影辨識碼"),
    "main_display_code_description": MessageLookupByLibrary.simpleMessage(
      "請輸入投影辨識碼 (不含空格)",
    ),
    "main_display_code_error": MessageLookupByLibrary.simpleMessage("僅允許輸入英數字"),
    "main_display_code_exceed": MessageLookupByLibrary.simpleMessage(
      "已達到參與人員上限",
    ),
    "main_display_code_exceed_split_screen":
        MessageLookupByLibrary.simpleMessage("已達到分割螢幕數量上限"),
    "main_display_code_invalid": MessageLookupByLibrary.simpleMessage(
      "無效的投影辨識碼",
    ),
    "main_feature_reconnect_fail_toast": MessageLookupByLibrary.simpleMessage(
      "網路(控制)重連失敗",
    ),
    "main_feature_reconnect_success_toast":
        MessageLookupByLibrary.simpleMessage("網路(控制)重連成功"),
    "main_feature_reconnecting_toast": MessageLookupByLibrary.simpleMessage(
      "網路(控制)重連中",
    ),
    "main_instance_not_found_or_offline": MessageLookupByLibrary.simpleMessage(
      "找不到投影辨識碼或是服務未啟動",
    ),
    "main_language": MessageLookupByLibrary.simpleMessage("語言"),
    "main_language_name": MessageLookupByLibrary.simpleMessage("繁體中文"),
    "main_notice_not_support_description": MessageLookupByLibrary.simpleMessage(
      "行動設備端不支援透過瀏覽器分享畫面。請下載並使用AirSync傳送端app以分享畫面。",
    ),
    "main_notice_positive_button": MessageLookupByLibrary.simpleMessage(
      "下載AirSync傳送端app",
    ),
    "main_notice_title": MessageLookupByLibrary.simpleMessage("請注意"),
    "main_otp_error": MessageLookupByLibrary.simpleMessage("僅允許輸入數字"),
    "main_password": MessageLookupByLibrary.simpleMessage("一次性密碼"),
    "main_password_description": MessageLookupByLibrary.simpleMessage(
      "請輸入一次性密碼",
    ),
    "main_password_invalid": MessageLookupByLibrary.simpleMessage("密碼錯誤"),
    "main_present": MessageLookupByLibrary.simpleMessage("下一步"),
    "main_setting": MessageLookupByLibrary.simpleMessage("設定"),
    "main_touch_back": MessageLookupByLibrary.simpleMessage("觸控反饋"),
    "main_update_deny_button": MessageLookupByLibrary.simpleMessage("現在不要"),
    "main_update_description_android": MessageLookupByLibrary.simpleMessage(
      "請按下\"更新\"以安裝新的版本。",
    ),
    "main_update_description_apple": MessageLookupByLibrary.simpleMessage(
      "請按下\"更新\"以安裝新的版本。",
    ),
    "main_update_description_windows": MessageLookupByLibrary.simpleMessage(
      "請按下\"更新\"以安裝新的版本。",
    ),
    "main_update_error_detail": MessageLookupByLibrary.simpleMessage("描述: "),
    "main_update_error_title": MessageLookupByLibrary.simpleMessage("版本更新失敗"),
    "main_update_error_type": MessageLookupByLibrary.simpleMessage("失敗原因: "),
    "main_update_positive_button": MessageLookupByLibrary.simpleMessage("更新"),
    "main_update_title": MessageLookupByLibrary.simpleMessage("有新的更新"),
    "main_webrtc_reconnect_fail_toast": MessageLookupByLibrary.simpleMessage(
      "網路(影像)重連失敗",
    ),
    "main_webrtc_reconnect_success_toast": MessageLookupByLibrary.simpleMessage(
      "網路(影像)重連成功",
    ),
    "main_webrtc_reconnecting_toast": MessageLookupByLibrary.simpleMessage(
      "網路(影像)重連中",
    ),
    "moderator": MessageLookupByLibrary.simpleMessage("請輸入姓名"),
    "moderator_back": MessageLookupByLibrary.simpleMessage("返回"),
    "moderator_exit": MessageLookupByLibrary.simpleMessage("結束"),
    "moderator_fill_out": MessageLookupByLibrary.simpleMessage("必填欄位"),
    "moderator_name": MessageLookupByLibrary.simpleMessage("姓名"),
    "moderator_wait": MessageLookupByLibrary.simpleMessage("請等待主持人指定分享人員"),
    "present_role_cast_screen": MessageLookupByLibrary.simpleMessage("分享螢幕"),
    "present_role_receive": MessageLookupByLibrary.simpleMessage("接收螢幕"),
    "present_select_screen_cancel": MessageLookupByLibrary.simpleMessage(
      "取消分享",
    ),
    "present_select_screen_description": MessageLookupByLibrary.simpleMessage(
      "選擇要分享的螢幕",
    ),
    "present_select_screen_entire": MessageLookupByLibrary.simpleMessage(
      "分享整個螢幕",
    ),
    "present_select_screen_ios_restart": MessageLookupByLibrary.simpleMessage(
      "開始直播",
    ),
    "present_select_screen_ios_restart_description":
        MessageLookupByLibrary.simpleMessage(
          "請在連線逾時前點擊\"開始直播\"以分享畫面，或點擊\"返回\"回到初始畫面。",
        ),
    "present_select_screen_share": MessageLookupByLibrary.simpleMessage("分享"),
    "present_select_screen_share_audio": MessageLookupByLibrary.simpleMessage(
      "分享音訊",
    ),
    "present_select_screen_window": MessageLookupByLibrary.simpleMessage(
      "分享應用程式視窗",
    ),
    "present_state_high_quality_description":
        MessageLookupByLibrary.simpleMessage("僅適用於良好的網路環境"),
    "present_state_high_quality_title": MessageLookupByLibrary.simpleMessage(
      "高畫質",
    ),
    "present_state_pause": MessageLookupByLibrary.simpleMessage("暫停分享"),
    "present_state_resume": MessageLookupByLibrary.simpleMessage("恢復分享"),
    "present_state_stop": MessageLookupByLibrary.simpleMessage("停止分享"),
    "present_time": MessageLookupByLibrary.simpleMessage("經過時間"),
    "present_time_unit_hour": MessageLookupByLibrary.simpleMessage("小時"),
    "present_time_unit_min": MessageLookupByLibrary.simpleMessage("分鐘"),
    "present_time_unit_sec": MessageLookupByLibrary.simpleMessage("秒"),
    "present_wait": m0,
    "remote_screen_connect_error": MessageLookupByLibrary.simpleMessage(
      "遠端連線中斷",
    ),
    "remote_screen_wait": MessageLookupByLibrary.simpleMessage("分享畫面處理中，請稍後"),
    "settings_audio_configuration": MessageLookupByLibrary.simpleMessage(
      "音訊設定說明",
    ),
    "settings_knowledge_base": MessageLookupByLibrary.simpleMessage("知識庫"),
    "toast_enable_remote_screen": MessageLookupByLibrary.simpleMessage(
      "請在AirSync開啟分享畫面到設備端功能",
    ),
    "toast_install_audio_driver": MessageLookupByLibrary.simpleMessage(
      "請安裝虛擬音效驅動程式",
    ),
    "toast_maximum_moderated": MessageLookupByLibrary.simpleMessage(
      "主持人模式已達到最大連線人數",
    ),
    "toast_maximum_remote_screen": MessageLookupByLibrary.simpleMessage(
      "已達到分享畫面上限",
    ),
    "toast_maximum_split_screen": MessageLookupByLibrary.simpleMessage(
      "已達到投影人員上限",
    ),
    "v3_device_list_button_device_list": MessageLookupByLibrary.simpleMessage(
      "設備清單",
    ),
    "v3_device_list_button_text": MessageLookupByLibrary.simpleMessage(
      "透過設備清單快速連線",
    ),
    "v3_device_list_dialog_connect": MessageLookupByLibrary.simpleMessage("連線"),
    "v3_device_list_dialog_invalid_otp": MessageLookupByLibrary.simpleMessage(
      "一次性密碼錯誤",
    ),
    "v3_device_list_dialog_title": MessageLookupByLibrary.simpleMessage("快速連線"),
    "v3_device_list_next": MessageLookupByLibrary.simpleMessage("下一步"),
    "v3_eula_agree": MessageLookupByLibrary.simpleMessage("同意"),
    "v3_eula_disagree": MessageLookupByLibrary.simpleMessage("不同意"),
    "v3_eula_title": MessageLookupByLibrary.simpleMessage("最終用戶許可協議"),
    "v3_exit_action_cancel": MessageLookupByLibrary.simpleMessage("取消"),
    "v3_exit_action_exit": MessageLookupByLibrary.simpleMessage("離開"),
    "v3_exit_title": MessageLookupByLibrary.simpleMessage("確定離開？"),
    "v3_lbl_change_language": MessageLookupByLibrary.simpleMessage("更改語言"),
    "v3_lbl_device_list_button_device_list":
        MessageLookupByLibrary.simpleMessage("設備清單"),
    "v3_lbl_device_list_close": MessageLookupByLibrary.simpleMessage("關閉設備清單"),
    "v3_lbl_device_list_next": MessageLookupByLibrary.simpleMessage("下一步"),
    "v3_lbl_download_independent_version": MessageLookupByLibrary.simpleMessage(
      "取得mac OS獨立發行版本",
    ),
    "v3_lbl_download_menu_minimal": MessageLookupByLibrary.simpleMessage(
      "選單最小化",
    ),
    "v3_lbl_exit_action_cancel": MessageLookupByLibrary.simpleMessage("取消"),
    "v3_lbl_exit_action_exit": MessageLookupByLibrary.simpleMessage("離開"),
    "v3_lbl_main_display_code": MessageLookupByLibrary.simpleMessage("輸入投影辨識碼"),
    "v3_lbl_main_display_code_remove": MessageLookupByLibrary.simpleMessage(
      "清除投影辨識碼",
    ),
    "v3_lbl_main_download": MessageLookupByLibrary.simpleMessage("下載傳送端App"),
    "v3_lbl_main_download_mac_store": MessageLookupByLibrary.simpleMessage(
      "取得mac OS線上商店版本",
    ),
    "v3_lbl_main_download_mobile": MessageLookupByLibrary.simpleMessage(
      "取得移動裝置端版本",
    ),
    "v3_lbl_main_download_windows": MessageLookupByLibrary.simpleMessage(
      "取得Windows版本",
    ),
    "v3_lbl_main_feedback": MessageLookupByLibrary.simpleMessage("意見回饋"),
    "v3_lbl_main_knowledge_base": MessageLookupByLibrary.simpleMessage("知識庫"),
    "v3_lbl_main_moderator_action": MessageLookupByLibrary.simpleMessage("分享"),
    "v3_lbl_main_moderator_input_hint": MessageLookupByLibrary.simpleMessage(
      "輸入您的名稱",
    ),
    "v3_lbl_main_password": MessageLookupByLibrary.simpleMessage("輸入一次性密碼"),
    "v3_lbl_main_present_action": MessageLookupByLibrary.simpleMessage("下一步"),
    "v3_lbl_main_privacy": MessageLookupByLibrary.simpleMessage("隱私權政策"),
    "v3_lbl_main_receive_app_action": MessageLookupByLibrary.simpleMessage(
      "連線",
    ),
    "v3_lbl_moderator_back": MessageLookupByLibrary.simpleMessage("返回"),
    "v3_lbl_moderator_disconnect": MessageLookupByLibrary.simpleMessage("中斷連線"),
    "v3_lbl_present_idle_audio_driver_warning_close":
        MessageLookupByLibrary.simpleMessage("關閉音訊驅動程式提示"),
    "v3_lbl_present_idle_audio_driver_warning_download":
        MessageLookupByLibrary.simpleMessage("下載音訊驅動程式"),
    "v3_lbl_qr_close": MessageLookupByLibrary.simpleMessage("關閉QR code"),
    "v3_lbl_qr_code": MessageLookupByLibrary.simpleMessage("顯示QR code"),
    "v3_lbl_select_language": MessageLookupByLibrary.simpleMessage("選擇 %s"),
    "v3_lbl_select_role_receive": MessageLookupByLibrary.simpleMessage("接收螢幕"),
    "v3_lbl_select_role_share": MessageLookupByLibrary.simpleMessage("分享螢幕"),
    "v3_lbl_select_screen_audio": MessageLookupByLibrary.simpleMessage("分享音訊"),
    "v3_lbl_select_screen_cancel": MessageLookupByLibrary.simpleMessage("取消分享"),
    "v3_lbl_select_screen_close": MessageLookupByLibrary.simpleMessage(
      "關閉分享畫面來源視窗",
    ),
    "v3_lbl_select_screen_ios_back": MessageLookupByLibrary.simpleMessage("返回"),
    "v3_lbl_select_screen_ios_start_sharing":
        MessageLookupByLibrary.simpleMessage("開始分享"),
    "v3_lbl_select_screen_share": MessageLookupByLibrary.simpleMessage("分享螢幕"),
    "v3_lbl_select_screen_source_name": MessageLookupByLibrary.simpleMessage(
      "分享畫面來源: %s",
    ),
    "v3_lbl_setting": MessageLookupByLibrary.simpleMessage("設定"),
    "v3_lbl_setting_language_select": MessageLookupByLibrary.simpleMessage(
      "選擇語言: %s",
    ),
    "v3_lbl_setting_legal_policy": MessageLookupByLibrary.simpleMessage(
      "檢視法律政策: %s",
    ),
    "v3_lbl_setting_menu_back": MessageLookupByLibrary.simpleMessage("回上一層選單"),
    "v3_lbl_setting_menu_close": MessageLookupByLibrary.simpleMessage("關閉設定選單"),
    "v3_lbl_setting_privacy_policy": MessageLookupByLibrary.simpleMessage(
      "隱私權政策",
    ),
    "v3_lbl_setting_select": MessageLookupByLibrary.simpleMessage("選擇 %s"),
    "v3_lbl_setting_software_update_deny_action":
        MessageLookupByLibrary.simpleMessage("稍後更新"),
    "v3_lbl_setting_software_update_fail_close":
        MessageLookupByLibrary.simpleMessage("關閉更新失敗對話窗"),
    "v3_lbl_setting_software_update_fail_ok":
        MessageLookupByLibrary.simpleMessage("確定"),
    "v3_lbl_setting_software_update_no_available":
        MessageLookupByLibrary.simpleMessage("無可用的更新"),
    "v3_lbl_setting_software_update_no_available_action":
        MessageLookupByLibrary.simpleMessage("確定"),
    "v3_lbl_setting_software_update_now_action":
        MessageLookupByLibrary.simpleMessage("立即更新"),
    "v3_lbl_setting_software_update_positive_action":
        MessageLookupByLibrary.simpleMessage("立即更新"),
    "v3_lbl_setting_update_close": MessageLookupByLibrary.simpleMessage(
      "關閉更新選單",
    ),
        "v3_lbl_sharing_annotation_start": MessageLookupByLibrary.simpleMessage(
          "開始註解",
        ),
        "v3_lbl_sharing_annotation_stop": MessageLookupByLibrary.simpleMessage(
          "停止註解",
        ),
        "v3_lbl_sharing_pause_off": MessageLookupByLibrary.simpleMessage("結束暫停"),
    "v3_lbl_sharing_pause_on": MessageLookupByLibrary.simpleMessage("暫停"),
    "v3_lbl_sharing_stop": MessageLookupByLibrary.simpleMessage("停止分享"),
    "v3_lbl_streaming_expand_button": MessageLookupByLibrary.simpleMessage(
      "打開投影控制列",
    ),
    "v3_lbl_streaming_minimize_button": MessageLookupByLibrary.simpleMessage(
      "隱藏投影控制列",
    ),
    "v3_lbl_streaming_stop_button": MessageLookupByLibrary.simpleMessage(
      "結束分享",
    ),
    "v3_lbl_touch_back_off": MessageLookupByLibrary.simpleMessage("停用反控"),
    "v3_lbl_touch_back_on": MessageLookupByLibrary.simpleMessage("啟用反控"),
    "v3_lbl_v3_exit_close": MessageLookupByLibrary.simpleMessage("關閉"),
    "v3_main_accessibility": MessageLookupByLibrary.simpleMessage("可訪問性"),
    "v3_main_authorize_wait": MessageLookupByLibrary.simpleMessage(
      "接收端同意後即可開始分享畫面",
    ),
    "v3_main_connect_network_error": MessageLookupByLibrary.simpleMessage(
      "網路連線錯誤",
    ),
    "v3_main_connect_rate_limited": MessageLookupByLibrary.simpleMessage(
      "已超過最大請求數量，請稍後再試",
    ),
    "v3_main_connect_unknown_error": MessageLookupByLibrary.simpleMessage(
      "未知的錯誤",
    ),
    "v3_main_connection_mode_unsupported": MessageLookupByLibrary.simpleMessage(
      "接收端暫時不支援Internet分享畫面",
    ),
    "v3_main_copy_rights": m1,
    "v3_main_display_code": MessageLookupByLibrary.simpleMessage("投影辨識碼"),
    "v3_main_display_code_error": MessageLookupByLibrary.simpleMessage(
      "投影辨識碼錯誤",
    ),
    "v3_main_display_code_invalid": MessageLookupByLibrary.simpleMessage(
      "無效的投影辨識碼",
    ),
    "v3_main_download": MessageLookupByLibrary.simpleMessage("下載傳送端軟體"),
    "v3_main_download_action_download": MessageLookupByLibrary.simpleMessage(
      "下載",
    ),
    "v3_main_download_action_get": MessageLookupByLibrary.simpleMessage("取得"),
    "v3_main_download_app_dialog_desc": MessageLookupByLibrary.simpleMessage(
      "使用iOS或Android設備掃描QR code並下載",
    ),
    "v3_main_download_app_dialog_title": MessageLookupByLibrary.simpleMessage(
      "下載AirSync傳送端軟體",
    ),
    "v3_main_download_app_subtitle": MessageLookupByLibrary.simpleMessage(
      "iOS及Android裝置",
    ),
    "v3_main_download_app_title": MessageLookupByLibrary.simpleMessage("行動裝置"),
    "v3_main_download_desc": MessageLookupByLibrary.simpleMessage("快速分享您的設備畫面"),
    "v3_main_download_mac_pkg_label": MessageLookupByLibrary.simpleMessage(
      "取得最佳化體驗版本!",
    ),
    "v3_main_download_mac_store": MessageLookupByLibrary.simpleMessage(
      "App Store",
    ),
    "v3_main_download_mac_store_label": MessageLookupByLibrary.simpleMessage(
      "或安裝商店版本",
    ),
    "v3_main_download_mac_subtitle": MessageLookupByLibrary.simpleMessage(
      "macOS版本10.15以上",
    ),
    "v3_main_download_mac_title": MessageLookupByLibrary.simpleMessage("Mac裝置"),
    "v3_main_download_title": MessageLookupByLibrary.simpleMessage(
      "取得AirSync傳送端軟體",
    ),
    "v3_main_download_win_subtitle": MessageLookupByLibrary.simpleMessage(
      "Windows 10 (版本1709)以上",
    ),
    "v3_main_download_win_title": MessageLookupByLibrary.simpleMessage(
      "Windows裝置",
    ),
    "v3_main_feedback": MessageLookupByLibrary.simpleMessage("意見回饋"),
    "v3_main_instance_not_found_or_offline":
        MessageLookupByLibrary.simpleMessage("找不到接收端或不在線上"),
    "v3_main_knowledge_base": MessageLookupByLibrary.simpleMessage("知識庫"),
    "v3_main_moderator_action": MessageLookupByLibrary.simpleMessage("分享"),
    "v3_main_moderator_app_subtitle": MessageLookupByLibrary.simpleMessage(
      "分享前請輸入名稱",
    ),
    "v3_main_moderator_app_title": MessageLookupByLibrary.simpleMessage("分享畫面"),
    "v3_main_moderator_disconnect": MessageLookupByLibrary.simpleMessage(
      "中斷連線",
    ),
    "v3_main_moderator_input_hint": MessageLookupByLibrary.simpleMessage(
      "請輸入名稱",
    ),
    "v3_main_moderator_input_limit": MessageLookupByLibrary.simpleMessage(
      "最長不超過20個字",
    ),
    "v3_main_moderator_subtitle": MessageLookupByLibrary.simpleMessage(
      "分享前請輸入名稱",
    ),
    "v3_main_moderator_title": MessageLookupByLibrary.simpleMessage("分享您的畫面"),
    "v3_main_moderator_wait": MessageLookupByLibrary.simpleMessage(
      "請等候主持人邀請分享",
    ),
    "v3_main_otp_error": MessageLookupByLibrary.simpleMessage("僅接受數字"),
    "v3_main_password": MessageLookupByLibrary.simpleMessage("一次性密碼"),
    "v3_main_password_invalid": MessageLookupByLibrary.simpleMessage("密碼錯誤"),
    "v3_main_present_action": MessageLookupByLibrary.simpleMessage("請選擇分享方式"),
    "v3_main_present_or": MessageLookupByLibrary.simpleMessage("或"),
    "v3_main_present_subtitle": MessageLookupByLibrary.simpleMessage(
      "只需幾個步驟即可快速分享",
    ),
    "v3_main_present_title": MessageLookupByLibrary.simpleMessage("無線分享您的畫面"),
    "v3_main_presenting_message": MessageLookupByLibrary.simpleMessage("畫面分享中"),
    "v3_main_privacy": MessageLookupByLibrary.simpleMessage("隱私政策"),
    "v3_main_receive_app_action": MessageLookupByLibrary.simpleMessage("接收"),
    "v3_main_receive_app_receive_from": MessageLookupByLibrary.simpleMessage(
      "畫面接收自 %s",
    ),
    "v3_main_receive_app_stop": MessageLookupByLibrary.simpleMessage("停止"),
    "v3_main_receive_app_subtitle": MessageLookupByLibrary.simpleMessage(
      "接收畫面到我的裝置",
    ),
    "v3_main_receive_app_title": MessageLookupByLibrary.simpleMessage("接收畫面"),
    "v3_main_select_role_receive": MessageLookupByLibrary.simpleMessage("接收畫面"),
    "v3_main_select_role_share": MessageLookupByLibrary.simpleMessage("分享畫面"),
    "v3_main_select_role_title": MessageLookupByLibrary.simpleMessage(
      "選擇分享或接收畫面",
    ),
    "v3_main_terms": MessageLookupByLibrary.simpleMessage("使用條款"),
    "v3_main_web_nonsupport": MessageLookupByLibrary.simpleMessage(
      "目前的瀏覽器不支援AirSync，請使用Chrome或Edge瀏覽器。",
    ),
    "v3_main_web_nonsupport_confirm": MessageLookupByLibrary.simpleMessage(
      "確定",
    ),
    "v3_present_end_information": MessageLookupByLibrary.simpleMessage(
      "已停止分享，共計使用 %s 分鐘",
    ),
    "v3_present_idle_download_virtual_audio_device":
        MessageLookupByLibrary.simpleMessage("安裝"),
    "v3_present_joined_before_moderator_on":
        MessageLookupByLibrary.simpleMessage("已開啟主持人模式"),
    "v3_present_joined_before_moderator_on_action":
        MessageLookupByLibrary.simpleMessage("確定"),
    "v3_present_joined_before_moderator_on_description":
        MessageLookupByLibrary.simpleMessage("已開啟主持人模式，請重新連線"),
    "v3_present_moderator_exited": MessageLookupByLibrary.simpleMessage(
      "結束主持人模式",
    ),
    "v3_present_moderator_exited_action": MessageLookupByLibrary.simpleMessage(
      "確定",
    ),
    "v3_present_moderator_exited_description":
        MessageLookupByLibrary.simpleMessage("主持人模式已結束，請重新連線"),
    "v3_present_options_menu_he_subtitle": MessageLookupByLibrary.simpleMessage(
      "使用影像處理單元進行編碼",
    ),
    "v3_present_options_menu_he_title": MessageLookupByLibrary.simpleMessage(
      "硬體編碼",
    ),
    "v3_present_options_menu_hq_subtitle": MessageLookupByLibrary.simpleMessage(
      "使用較高的位元率處理影像，需要較好的網路品質",
    ),
    "v3_present_options_menu_hq_title": MessageLookupByLibrary.simpleMessage(
      "高畫質模式",
    ),
    "v3_present_screen_full": MessageLookupByLibrary.simpleMessage("連線數已滿"),
    "v3_present_screen_full_action": MessageLookupByLibrary.simpleMessage("好"),
    "v3_present_screen_full_description": MessageLookupByLibrary.simpleMessage(
      "已達到最大分享畫面數量，請稍後再試",
    ),
    "v3_present_select_screen_extension": MessageLookupByLibrary.simpleMessage(
      "延伸螢幕",
    ),
    "v3_present_select_screen_extension_desc":
        MessageLookupByLibrary.simpleMessage("擴展您的顯示範圍"),
    "v3_present_select_screen_extension_desc2":
        MessageLookupByLibrary.simpleMessage("將要分享的應用程式從電腦顯示器拖拉至外部顯示器"),
    "v3_present_select_screen_mac_audio_driver":
        MessageLookupByLibrary.simpleMessage(
          "尚未安裝音訊驅動程式，聲音將無法透過 IFP 播放，請點擊安裝。",
        ),
    "v3_present_select_screen_share_audio":
        MessageLookupByLibrary.simpleMessage("勾選以分享音訊"),
    "v3_present_select_screen_subtitle": MessageLookupByLibrary.simpleMessage(
      "請選擇螢幕分享的方式",
    ),
    "v3_present_session_full": MessageLookupByLibrary.simpleMessage("連線數已滿"),
    "v3_present_session_full_action": MessageLookupByLibrary.simpleMessage("好"),
    "v3_present_session_full_description": MessageLookupByLibrary.simpleMessage(
      "已達到最大分享畫面數量，請稍後再試",
    ),
    "v3_present_touch_back_allow": MessageLookupByLibrary.simpleMessage(
      "允許反控設備端",
    ),
    "v3_present_touch_back_dialog_allow": MessageLookupByLibrary.simpleMessage(
      "允許",
    ),
    "v3_present_touch_back_dialog_description":
        MessageLookupByLibrary.simpleMessage(
          "當您分享螢幕時，AirSync 將擷取您的螢幕內容並將其傳輸到選定的顯示器（例如 IFP）。若要啟用反控設備端功能，AirSync 需要被賦予輔助功能服務權限，才能允許從顯示器進行遠端控制。AirSync 不會收集您的個人數據或監控您的操作行為。此權限僅用於啟用反控功能。",
        ),
    "v3_present_touch_back_dialog_not_now":
        MessageLookupByLibrary.simpleMessage("現在不要"),
    "v3_present_touch_back_dialog_title": MessageLookupByLibrary.simpleMessage(
      "允許反控您的設備",
    ),
    "v3_receiver_remote_screen_busy_action":
        MessageLookupByLibrary.simpleMessage("好"),
    "v3_receiver_remote_screen_busy_description":
        MessageLookupByLibrary.simpleMessage("該螢幕正在廣播中，請稍後再試"),
    "v3_receiver_remote_screen_busy_title":
        MessageLookupByLibrary.simpleMessage("螢幕廣播中"),
    "v3_scan_qr_reminder": MessageLookupByLibrary.simpleMessage(
      "掃描QR code快速連線",
    ),
    "v3_select_screen_ios_countdown": MessageLookupByLibrary.simpleMessage(
      "請在連線逾時前點擊開始分享。剩餘時間:",
    ),
    "v3_select_screen_ios_start_sharing": MessageLookupByLibrary.simpleMessage(
      "開始分享",
    ),
    "v3_setting_accessibility": MessageLookupByLibrary.simpleMessage("無障礙協助"),
    "v3_setting_accessibility_size_large": MessageLookupByLibrary.simpleMessage(
      "大",
    ),
    "v3_setting_accessibility_size_normal":
        MessageLookupByLibrary.simpleMessage("正常"),
    "v3_setting_accessibility_size_xlarge":
        MessageLookupByLibrary.simpleMessage("特大"),
    "v3_setting_accessibility_text_size": MessageLookupByLibrary.simpleMessage(
      "字體大小",
    ),
    "v3_setting_app_version": m2,
    "v3_setting_app_version_independent": m3,
    "v3_setting_check_update": MessageLookupByLibrary.simpleMessage("檢查更新"),
    "v3_setting_knowledge_base": MessageLookupByLibrary.simpleMessage("知識庫"),
    "v3_setting_language": MessageLookupByLibrary.simpleMessage("語言"),
    "v3_setting_legal_policy": MessageLookupByLibrary.simpleMessage("法律政策"),
    "v3_setting_open_source_license": MessageLookupByLibrary.simpleMessage(
      "開源許可證",
    ),
    "v3_setting_privacy_policy": MessageLookupByLibrary.simpleMessage("隱私政策"),
        "v3_setting_privacy_policy_description":
            MessageLookupByLibrary.simpleMessage(
          "ViewSonic致力於保護您的個人隱私。以下隱私權政策將帶您了解ViewSonic會如何於您瀏覽本網站時蒐集並處理您的資料。\nViewSonic透過加密技術並嚴格遵守法規來保護您的資料，確保不被不明人士存取。\n若您使用本網站，則代表您了解並同意ViewSonic蒐集並處理您的資料。\n您在ViewSonic.com綁定或連結的其他網站可能擁有與ViewSonic不同的隱私權政策，請參照該網站的隱私權來了解這些網站如何蒐集並處理您的資料。\n您可以點擊以下連結來了解更多關於ViewSonic的隱私權政策：",
        ),
        "v3_setting_software_update": MessageLookupByLibrary.simpleMessage("軟體更新"),
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
        MessageLookupByLibrary.simpleMessage("立即更新"),
    "v3_setting_title": MessageLookupByLibrary.simpleMessage("設定"),
  };
}
