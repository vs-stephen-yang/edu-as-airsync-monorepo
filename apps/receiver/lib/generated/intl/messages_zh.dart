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

  static String m0(value) => "螢幕分享即將結束，是否需要再延長一次(三小時)? 您可再延長${value}次。";

  static String m1(year, version) => "AirSync ©${year}. 版本 ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "eula_agree": MessageLookupByLibrary.simpleMessage("同意"),
    "eula_disagree": MessageLookupByLibrary.simpleMessage("不同意"),
    "eula_title": MessageLookupByLibrary.simpleMessage("AirSync 終端使用者授權合約"),
    "main_airplay_pin_code": MessageLookupByLibrary.simpleMessage("AirPlay密碼"),
    "main_auto_startup": MessageLookupByLibrary.simpleMessage(
      "開機後自動執行 AirSync",
    ),
    "main_cast_settings_airplay": MessageLookupByLibrary.simpleMessage(
      "AirPlay",
    ),
    "main_cast_settings_device_name": MessageLookupByLibrary.simpleMessage(
      "設備名稱",
    ),
    "main_cast_settings_google_cast": MessageLookupByLibrary.simpleMessage(
      "Google Cast",
    ),
    "main_cast_settings_miracast": MessageLookupByLibrary.simpleMessage(
      "Miracast",
    ),
    "main_cast_settings_title": MessageLookupByLibrary.simpleMessage("螢幕鏡射"),
    "main_content_display_code": MessageLookupByLibrary.simpleMessage("投影辨識碼"),
    "main_content_lan_only": MessageLookupByLibrary.simpleMessage("僅接受區域網路連線"),
    "main_content_one_time_password": MessageLookupByLibrary.simpleMessage(
      "一次性密碼",
    ),
    "main_content_one_time_password_get_fail":
        MessageLookupByLibrary.simpleMessage("無法取得一次性密碼\n30秒後將再次執行"),
    "main_feature_no_network_warning": MessageLookupByLibrary.simpleMessage(
      "控制連線異常，請重新連線",
    ),
    "main_feature_reconnect_fail_toast": MessageLookupByLibrary.simpleMessage(
      "網路(控制)重連失敗",
    ),
    "main_feature_reconnect_success_toast":
        MessageLookupByLibrary.simpleMessage("網路(控制)重連成功"),
    "main_feature_reconnecting_toast": MessageLookupByLibrary.simpleMessage(
      "網路(控制)重連中",
    ),
    "main_get_display_code_failure": MessageLookupByLibrary.simpleMessage(
      "取得投影辨識碼失敗",
    ),
    "main_language_name": MessageLookupByLibrary.simpleMessage("繁體中文"),
    "main_language_title": MessageLookupByLibrary.simpleMessage("語言"),
    "main_limit_time_message": MessageLookupByLibrary.simpleMessage("五分鐘後結束"),
    "main_mirror_from_client": MessageLookupByLibrary.simpleMessage(
      "%s 想要開始螢幕鏡射",
    ),
    "main_mirror_prompt_accept": MessageLookupByLibrary.simpleMessage("允許"),
    "main_mirror_prompt_cancel": MessageLookupByLibrary.simpleMessage("取消"),
    "main_register_display_code_failure": MessageLookupByLibrary.simpleMessage(
      "取得投影辨識碼失敗，請稍後再試",
    ),
    "main_settings_airplay_code": MessageLookupByLibrary.simpleMessage(
      "需輸入AirPlay code",
    ),
    "main_settings_device_list": MessageLookupByLibrary.simpleMessage("快速連線密碼"),
    "main_settings_device_name": MessageLookupByLibrary.simpleMessage("名稱"),
    "main_settings_device_name_cancel": MessageLookupByLibrary.simpleMessage(
      "取消",
    ),
    "main_settings_device_name_hint": MessageLookupByLibrary.simpleMessage(
      "名稱",
    ),
    "main_settings_device_name_save": MessageLookupByLibrary.simpleMessage(
      "儲存",
    ),
    "main_settings_device_name_title": MessageLookupByLibrary.simpleMessage(
      "設定名稱",
    ),
    "main_settings_language": MessageLookupByLibrary.simpleMessage("語言"),
    "main_settings_mirror_confirmation": MessageLookupByLibrary.simpleMessage(
      "需接受鏡射請求",
    ),
    "main_settings_pin_visible": MessageLookupByLibrary.simpleMessage("顯示連線資訊"),
    "main_settings_share_to_sender": MessageLookupByLibrary.simpleMessage(
      "分享畫面到設備端",
    ),
    "main_settings_share_to_sender_limit_desc":
        MessageLookupByLibrary.simpleMessage("最多可分享畫面到10個接收端"),
    "main_settings_title": MessageLookupByLibrary.simpleMessage("設定"),
    "main_settings_whats_new": MessageLookupByLibrary.simpleMessage("最新消息"),
    "main_split_screen_question": MessageLookupByLibrary.simpleMessage(
      "啟動分割畫面?",
    ),
    "main_split_screen_title": MessageLookupByLibrary.simpleMessage("分割畫面"),
    "main_split_screen_waiting": MessageLookupByLibrary.simpleMessage(
      "分割畫面已啟動",
    ),
    "main_status_go_background": MessageLookupByLibrary.simpleMessage(
      "AirSync 背景執行中",
    ),
    "main_status_no_network": MessageLookupByLibrary.simpleMessage(
      "網路品質不良\n請檢查網路連線",
    ),
    "main_status_remaining_time": MessageLookupByLibrary.simpleMessage(
      "%02d min : %02d sec",
    ),
    "main_thanks_content": MessageLookupByLibrary.simpleMessage(
      "感謝您使用 AirSync",
    ),
    "main_wait_title": MessageLookupByLibrary.simpleMessage("等待投影中..."),
    "main_wait_up_next": MessageLookupByLibrary.simpleMessage("下一位投影者"),
    "main_webrtc_reconnect_fail_toast": MessageLookupByLibrary.simpleMessage(
      "網路(影像)重連失敗",
    ),
    "main_webrtc_reconnect_success_toast": MessageLookupByLibrary.simpleMessage(
      "網路(影像)重連成功",
    ),
    "main_webrtc_reconnecting_toast": MessageLookupByLibrary.simpleMessage(
      "網路(影像)重連中",
    ),
    "main_whats_new_content": MessageLookupByLibrary.simpleMessage(
      "[功能改善]\n\n1. 全數字投影辨識碼，以改善使用者體驗\n\n2. 改善連線穩定度\n\n3. 問題修正",
    ),
    "main_whats_new_title": MessageLookupByLibrary.simpleMessage("最新消息"),
    "moderator_activate_split_screen": MessageLookupByLibrary.simpleMessage(
      "確定啟用分割畫面功能嗎?最多可四人同時投影。",
    ),
    "moderator_cancel": MessageLookupByLibrary.simpleMessage("取消"),
    "moderator_confirm": MessageLookupByLibrary.simpleMessage("確定"),
    "moderator_deactivate_split_screen": MessageLookupByLibrary.simpleMessage(
      "確定結束分割畫面功能嗎?",
    ),
    "moderator_exit": MessageLookupByLibrary.simpleMessage("退出"),
    "moderator_exit_dialog": MessageLookupByLibrary.simpleMessage("確定要退出嗎?"),
    "moderator_presentersLimit": MessageLookupByLibrary.simpleMessage("最多六人參加"),
    "moderator_presentersList": MessageLookupByLibrary.simpleMessage("人員列表"),
    "moderator_remove": MessageLookupByLibrary.simpleMessage("移除"),
    "moderator_verifyCode_fail": MessageLookupByLibrary.simpleMessage(
      "抱歉，出現問題，請稍後再試。",
    ),
    "toast_maximum_split_screen": MessageLookupByLibrary.simpleMessage(
      "已達到投影人員上限",
    ),
    "update_install_now": MessageLookupByLibrary.simpleMessage("立即安裝"),
    "update_message": MessageLookupByLibrary.simpleMessage("已有新版本可供安裝"),
    "update_title": MessageLookupByLibrary.simpleMessage("AirSync 更新"),
    "v3_authorize_prompt_accept": MessageLookupByLibrary.simpleMessage("接受"),
    "v3_authorize_prompt_accept_all": MessageLookupByLibrary.simpleMessage(
      "一律接受",
    ),
    "v3_authorize_prompt_decline": MessageLookupByLibrary.simpleMessage("拒絕"),
    "v3_broadcast_indicator": MessageLookupByLibrary.simpleMessage("ON"),
    "v3_cast_to_device_Receiving": MessageLookupByLibrary.simpleMessage(
      "接收畫面中",
    ),
    "v3_cast_to_device_list_msg": MessageLookupByLibrary.simpleMessage(
      "最多分享到10台裝置",
    ),
    "v3_cast_to_device_menu_or": MessageLookupByLibrary.simpleMessage("或"),
    "v3_cast_to_device_menu_quick_connect1":
        MessageLookupByLibrary.simpleMessage("快速連線"),
    "v3_cast_to_device_menu_quick_connect2":
        MessageLookupByLibrary.simpleMessage("請掃描QR code"),
    "v3_cast_to_device_menu_title": MessageLookupByLibrary.simpleMessage(
      "連線以分享顯示器畫面",
    ),
    "v3_cast_to_device_reached_maximum": MessageLookupByLibrary.simpleMessage(
      "已達數量上限",
    ),
    "v3_cast_to_device_title": MessageLookupByLibrary.simpleMessage("設備清單"),
    "v3_cast_to_device_touch_back": MessageLookupByLibrary.simpleMessage("反控"),
    "v3_cast_to_device_touch_back_disable":
        MessageLookupByLibrary.simpleMessage("停止反控"),
    "v3_cast_to_device_touch_enabled": MessageLookupByLibrary.simpleMessage(
      "反控中",
    ),
    "v3_casting_ended_toast": MessageLookupByLibrary.simpleMessage("螢幕分享已結束。"),
    "v3_casting_time_countdown": m0,
    "v3_casting_time_do_not_extend": MessageLookupByLibrary.simpleMessage(
      "不延長",
    ),
    "v3_casting_time_extend": MessageLookupByLibrary.simpleMessage("延長"),
    "v3_casting_time_extend_success_toast":
        MessageLookupByLibrary.simpleMessage("已延長三小時"),
    "v3_download_app_desc": MessageLookupByLibrary.simpleMessage(
      "以iOS或是Android設備掃描QR code後，即可下載傳送端App",
    ),
    "v3_download_app_desktop": MessageLookupByLibrary.simpleMessage(
      "取得最佳化體驗版本!",
    ),
    "v3_download_app_desktop_hint": MessageLookupByLibrary.simpleMessage(
      "自行安裝檔",
    ),
    "v3_download_app_desktop_store": MessageLookupByLibrary.simpleMessage(
      "下載商店版本",
    ),
    "v3_download_app_desktop_store_hint": MessageLookupByLibrary.simpleMessage(
      "MacOS專用版",
    ),
    "v3_download_app_desktop_title": MessageLookupByLibrary.simpleMessage(
      "一般裝置",
    ),
    "v3_download_app_entry": MessageLookupByLibrary.simpleMessage("下載傳送端App"),
    "v3_download_app_for_desktop": MessageLookupByLibrary.simpleMessage(
      "桌上型裝置",
    ),
    "v3_download_app_for_desktop_desc": MessageLookupByLibrary.simpleMessage(
      "請輸入下載網址",
    ),
    "v3_download_app_for_mobile": MessageLookupByLibrary.simpleMessage("移動式裝置"),
    "v3_download_app_for_mobile_desc": MessageLookupByLibrary.simpleMessage(
      "請掃描QR code",
    ),
    "v3_download_app_mobile_title": MessageLookupByLibrary.simpleMessage(
      "行動裝置",
    ),
    "v3_download_app_or": MessageLookupByLibrary.simpleMessage("或"),
    "v3_download_app_title": MessageLookupByLibrary.simpleMessage("下載傳送端App"),
    "v3_eula_agree": MessageLookupByLibrary.simpleMessage("同意"),
    "v3_eula_disagree": MessageLookupByLibrary.simpleMessage("不同意"),
    "v3_eula_title": MessageLookupByLibrary.simpleMessage("最終用戶許可協議"),
    "v3_exit_moderator_mode_cancel": MessageLookupByLibrary.simpleMessage("取消"),
    "v3_exit_moderator_mode_desc": MessageLookupByLibrary.simpleMessage(
      "確定結束主持人模式並中斷所有連線嗎? ",
    ),
    "v3_exit_moderator_mode_exit": MessageLookupByLibrary.simpleMessage("退出"),
    "v3_exit_moderator_mode_title": MessageLookupByLibrary.simpleMessage(
      "結束主持人模式",
    ),
    "v3_group_dialog_accept": MessageLookupByLibrary.simpleMessage("接受"),
    "v3_group_dialog_decline": MessageLookupByLibrary.simpleMessage("拒絕"),
    "v3_group_dialog_message": MessageLookupByLibrary.simpleMessage(
      "%s 已向您的設備發送了螢幕廣播請求。這將同步並顯示當前請求端的畫面內容，您想接受此請求嗎？",
    ),
    "v3_group_dialog_no_device_message": MessageLookupByLibrary.simpleMessage(
      "未選擇任何裝置",
    ),
    "v3_group_dialog_title": MessageLookupByLibrary.simpleMessage(
      "來自 %s 的螢幕廣播請求",
    ),
    "v3_group_receive_view_status_from": MessageLookupByLibrary.simpleMessage(
      "廣播來自於",
    ),
    "v3_group_receive_view_status_stop": MessageLookupByLibrary.simpleMessage(
      "停止",
    ),
    "v3_group_reject_invited": MessageLookupByLibrary.simpleMessage(
      "拒絕您的廣播請求，請檢查接收端設置",
    ),
    "v3_instruction1a": MessageLookupByLibrary.simpleMessage(
      "連線到 airsync.net ",
    ),
    "v3_instruction1b": MessageLookupByLibrary.simpleMessage(
      "或啟動AirSync傳送端app",
    ),
    "v3_instruction2": MessageLookupByLibrary.simpleMessage("輸入投影辨識碼"),
    "v3_instruction3": MessageLookupByLibrary.simpleMessage("輸入一次性密碼"),
    "v3_instruction_share_screen": MessageLookupByLibrary.simpleMessage(
      "分享您的螢幕",
    ),
    "v3_instruction_support": MessageLookupByLibrary.simpleMessage(
      "透過AirPlay, Google Cast或是Miracast分享螢幕",
    ),
    "v3_last_casting_time_countdown": MessageLookupByLibrary.simpleMessage(
      "螢幕分享即將結束。如需要，請重新開始分享螢幕。",
    ),
    "v3_lbl_authorize_prompt_accept": MessageLookupByLibrary.simpleMessage(
      "接受請求",
    ),
    "v3_lbl_authorize_prompt_accept_all": MessageLookupByLibrary.simpleMessage(
      "一律接受所有請求",
    ),
    "v3_lbl_authorize_prompt_decline": MessageLookupByLibrary.simpleMessage(
      "拒絕請求",
    ),
    "v3_lbl_cast_device_close": MessageLookupByLibrary.simpleMessage(
      "結束與設備端連線",
    ),
    "v3_lbl_cast_device_touchback_disable":
        MessageLookupByLibrary.simpleMessage("關閉反控"),
    "v3_lbl_cast_device_touchback_enable": MessageLookupByLibrary.simpleMessage(
      "啟動反控",
    ),
    "v3_lbl_close_download_app_menu": MessageLookupByLibrary.simpleMessage(
      "關閉下載sender app選單",
    ),
    "v3_lbl_close_feature_set_cast_device":
        MessageLookupByLibrary.simpleMessage("關閉設備清單"),
    "v3_lbl_close_feature_set_moderator": MessageLookupByLibrary.simpleMessage(
      "關閉主持人模式參與人員清單",
    ),
    "v3_lbl_close_streaming_shortcut_menu":
        MessageLookupByLibrary.simpleMessage("收合投影控制捷徑"),
    "v3_lbl_connection_dialog_close": MessageLookupByLibrary.simpleMessage(
      "關閉連線狀態對話框",
    ),
    "v3_lbl_eula_agree": MessageLookupByLibrary.simpleMessage("同意終端使用者授權合約"),
    "v3_lbl_eula_disagree": MessageLookupByLibrary.simpleMessage(
      "不同意終端使用者授權合約",
    ),
    "v3_lbl_exit_moderator_cancel": MessageLookupByLibrary.simpleMessage(
      "取消結束主持人模式",
    ),
    "v3_lbl_exit_moderator_exit": MessageLookupByLibrary.simpleMessage(
      "確定結束主持人模式",
    ),
    "v3_lbl_extend_casting_do_not_extend": MessageLookupByLibrary.simpleMessage(
      "不延長投影時間",
    ),
    "v3_lbl_extend_casting_extend": MessageLookupByLibrary.simpleMessage(
      "延長投影時間",
    ),
    "v3_lbl_group_reject_close": MessageLookupByLibrary.simpleMessage("關閉提示"),
    "v3_lbl_internet_connection_only_error":
        MessageLookupByLibrary.simpleMessage("連線錯誤，請檢查網路連線設定"),
    "v3_lbl_internet_connection_warning": MessageLookupByLibrary.simpleMessage(
      "僅限區域網路連線",
    ),
    "v3_lbl_main_language_title": MessageLookupByLibrary.simpleMessage("選擇語言"),
    "v3_lbl_main_language_title_item": MessageLookupByLibrary.simpleMessage(
      "選擇 %s",
    ),
    "v3_lbl_message_dialog_cancel": MessageLookupByLibrary.simpleMessage("取消"),
    "v3_lbl_message_dialog_confirm": MessageLookupByLibrary.simpleMessage("確認"),
    "v3_lbl_minimal_quick_connect_menu": MessageLookupByLibrary.simpleMessage(
      "縮小快速連線選單",
    ),
    "v3_lbl_minimal_streaming_qrcode_menu":
        MessageLookupByLibrary.simpleMessage("隱藏QR code視窗"),
    "v3_lbl_moderator_toggle": MessageLookupByLibrary.simpleMessage("主持人模式開關"),
    "v3_lbl_open_download_app_menu": MessageLookupByLibrary.simpleMessage(
      "開啟下載sender app選單",
    ),
    "v3_lbl_open_feature_set_cast_device": MessageLookupByLibrary.simpleMessage(
      "開啟設備清單",
    ),
    "v3_lbl_open_feature_set_moderator": MessageLookupByLibrary.simpleMessage(
      "開啟主持人模式參與人員清單",
    ),
    "v3_lbl_open_menu_settings": MessageLookupByLibrary.simpleMessage(
      "開啟設定功能選單",
    ),
    "v3_lbl_open_streaming_qrcode_menu": MessageLookupByLibrary.simpleMessage(
      "顯示QR code視窗",
    ),
    "v3_lbl_open_streaming_shortcut_menu": MessageLookupByLibrary.simpleMessage(
      "展開投影控制捷徑",
    ),
    "v3_lbl_overlay_bring_app_to_top": MessageLookupByLibrary.simpleMessage(
      "常駐連線資訊狀態列",
    ),
    "v3_lbl_overlay_menu_expand": MessageLookupByLibrary.simpleMessage(
      "展開常駐選單",
    ),
    "v3_lbl_overlay_menu_minimize": MessageLookupByLibrary.simpleMessage(
      "最小化常駐選單",
    ),
    "v3_lbl_participant_cast_device": MessageLookupByLibrary.simpleMessage(
      "分享畫面給參與者",
    ),
    "v3_lbl_participant_close": MessageLookupByLibrary.simpleMessage(
      "結束參與者的連線",
    ),
    "v3_lbl_participant_disconnect": MessageLookupByLibrary.simpleMessage(
      "結束參與者的連線",
    ),
    "v3_lbl_participant_mirror_close": MessageLookupByLibrary.simpleMessage(
      "中斷連線",
    ),
    "v3_lbl_participant_mirror_share": MessageLookupByLibrary.simpleMessage(
      "分享畫面",
    ),
    "v3_lbl_participant_mirror_stop": MessageLookupByLibrary.simpleMessage(
      "停止鏡射",
    ),
    "v3_lbl_participant_share": MessageLookupByLibrary.simpleMessage(
      "分享畫面到參與人員",
    ),
    "v3_lbl_participant_stop": MessageLookupByLibrary.simpleMessage("停止參與者的投影"),
    "v3_lbl_participant_touch_back": MessageLookupByLibrary.simpleMessage(
      "啟動參與者反控",
    ),
    "v3_lbl_participant_touch_back_disable":
        MessageLookupByLibrary.simpleMessage("取消"),
    "v3_lbl_resizable_expand": MessageLookupByLibrary.simpleMessage("展開投影控制列"),
    "v3_lbl_resizable_minimize": MessageLookupByLibrary.simpleMessage(
      "縮小投影控制列",
    ),
    "v3_lbl_resizable_mute": MessageLookupByLibrary.simpleMessage("靜音"),
    "v3_lbl_resizable_stop": MessageLookupByLibrary.simpleMessage("停止投影"),
    "v3_lbl_settings_accessibility": MessageLookupByLibrary.simpleMessage(
      "可訪問性",
    ),
    "v3_lbl_settings_back_icon": MessageLookupByLibrary.simpleMessage("回到上一頁"),
    "v3_lbl_settings_broadcast": MessageLookupByLibrary.simpleMessage(
      "展開螢幕廣播設定選單",
    ),
    "v3_lbl_settings_broadcast_boards": MessageLookupByLibrary.simpleMessage(
      "展開廣播到大屏選單",
    ),
    "v3_lbl_settings_broadcast_devices": MessageLookupByLibrary.simpleMessage(
      "展開螢幕廣播選單",
    ),
    "v3_lbl_settings_broadcast_to_display_group":
        MessageLookupByLibrary.simpleMessage("展開螢幕群組選單"),
    "v3_lbl_settings_broadcast_to_display_group_cast":
        MessageLookupByLibrary.simpleMessage("廣播"),
    "v3_lbl_settings_broadcast_to_display_group_checkbox":
        MessageLookupByLibrary.simpleMessage("選擇 %s"),
    "v3_lbl_settings_broadcast_to_display_group_confirm":
        MessageLookupByLibrary.simpleMessage("未選擇任何接收端"),
    "v3_lbl_settings_broadcast_to_display_group_item":
        MessageLookupByLibrary.simpleMessage("選擇 %s"),
    "v3_lbl_settings_broadcast_to_display_group_save":
        MessageLookupByLibrary.simpleMessage("儲存"),
    "v3_lbl_settings_broadcast_to_display_group_type":
        MessageLookupByLibrary.simpleMessage("選擇 %s"),
    "v3_lbl_settings_close_icon": MessageLookupByLibrary.simpleMessage(
      "關閉設定選單",
    ),
    "v3_lbl_settings_connectivity": MessageLookupByLibrary.simpleMessage(
      "展開連線模式設定選單",
    ),
    "v3_lbl_settings_connectivity_item": MessageLookupByLibrary.simpleMessage(
      "選擇 %s",
    ),
    "v3_lbl_settings_device_authorize_mode":
        MessageLookupByLibrary.simpleMessage("開啟或關閉授權後投影"),
    "v3_lbl_settings_device_auto_fill_otp":
        MessageLookupByLibrary.simpleMessage("開啟或關閉自動帶入一次性密碼"),
    "v3_lbl_settings_device_launch_on_startup":
        MessageLookupByLibrary.simpleMessage("開啟或關閉自動啟動"),
    "v3_lbl_settings_device_name": MessageLookupByLibrary.simpleMessage(
      "更改裝置名稱",
    ),
    "v3_lbl_settings_device_name_close": MessageLookupByLibrary.simpleMessage(
      "關閉裝置名稱設定",
    ),
    "v3_lbl_settings_device_name_save": MessageLookupByLibrary.simpleMessage(
      "儲存裝置名稱",
    ),
    "v3_lbl_settings_device_setting": MessageLookupByLibrary.simpleMessage(
      "展開裝置設定選單",
    ),
    "v3_lbl_settings_device_smart_scaling":
        MessageLookupByLibrary.simpleMessage("開啟或關閉智慧滿屏"),
    "v3_lbl_settings_enter_device_name": MessageLookupByLibrary.simpleMessage(
      "輸入裝置名稱",
    ),
    "v3_lbl_settings_invite_group": MessageLookupByLibrary.simpleMessage(
      "展開螢幕廣播邀請選單",
    ),
    "v3_lbl_settings_invite_group_item": MessageLookupByLibrary.simpleMessage(
      "選擇 %s",
    ),
    "v3_lbl_settings_legal_policy": MessageLookupByLibrary.simpleMessage(
      "展開法律和政策",
    ),
    "v3_lbl_settings_menu_locked": MessageLookupByLibrary.simpleMessage(
      "設定功能已鎖定",
    ),
    "v3_lbl_settings_mirroring_auto_accept":
        MessageLookupByLibrary.simpleMessage("開啟或關閉自動接受螢幕鏡射"),
    "v3_lbl_settings_mirroring_require_passcode":
        MessageLookupByLibrary.simpleMessage("開啟或關閉AirPlay驗證碼"),
    "v3_lbl_settings_only_when_casting_info":
        MessageLookupByLibrary.simpleMessage("更多螢幕廣播資訊"),
    "v3_lbl_settings_open_source_license": MessageLookupByLibrary.simpleMessage(
      "選擇 %s",
    ),
    "v3_lbl_settings_show_display_code": MessageLookupByLibrary.simpleMessage(
      "開啟或關閉投影辨識碼",
    ),
    "v3_lbl_settings_whats_new": MessageLookupByLibrary.simpleMessage(
      "展開what\'s new",
    ),
    "v3_lbl_settings_whats_new_icon": MessageLookupByLibrary.simpleMessage(
      "最新消息圖示",
    ),
    "v3_lbl_shortcuts_airplay": MessageLookupByLibrary.simpleMessage(
      "開啟或關閉AirPlay",
    ),
    "v3_lbl_shortcuts_google_cast": MessageLookupByLibrary.simpleMessage(
      "開啟或關閉Google Cast",
    ),
    "v3_lbl_shortcuts_miracast": MessageLookupByLibrary.simpleMessage(
      "開啟或關閉Miracast",
    ),
    "v3_lbl_shortcuts_mirroring": MessageLookupByLibrary.simpleMessage(
      "展開螢幕鏡射設定選單",
    ),
    "v3_lbl_streaming_airplay_touchback": MessageLookupByLibrary.simpleMessage(
      "AirPlay反控",
    ),
    "v3_lbl_streaming_shortcut_airplay_toggle":
        MessageLookupByLibrary.simpleMessage("AirPlay開關"),
    "v3_lbl_streaming_shortcut_cast_device_toggle":
        MessageLookupByLibrary.simpleMessage("分享畫面到設備端開關"),
    "v3_lbl_streaming_shortcut_expand": MessageLookupByLibrary.simpleMessage(
      "展開功能捷徑列",
    ),
    "v3_lbl_streaming_shortcut_google_cast_toggle":
        MessageLookupByLibrary.simpleMessage("Google Cast開關"),
    "v3_lbl_streaming_shortcut_menu_locked":
        MessageLookupByLibrary.simpleMessage("已鎖定功能捷徑列"),
    "v3_lbl_streaming_shortcut_minimize": MessageLookupByLibrary.simpleMessage(
      "收合功能捷徑列",
    ),
    "v3_lbl_streaming_shortcut_miracast_toggle":
        MessageLookupByLibrary.simpleMessage("Miracast開關"),
    "v3_lbl_streaming_view_expand": MessageLookupByLibrary.simpleMessage(
      "展開分享畫面",
    ),
    "v3_lbl_streaming_view_function_expand":
        MessageLookupByLibrary.simpleMessage("展開撥放控制功能"),
    "v3_lbl_streaming_view_function_minimize":
        MessageLookupByLibrary.simpleMessage("收合撥放控制功能"),
    "v3_lbl_streaming_view_minimize": MessageLookupByLibrary.simpleMessage(
      "收合分享畫面",
    ),
    "v3_lbl_streaming_view_mute": MessageLookupByLibrary.simpleMessage("靜音"),
    "v3_lbl_streaming_view_stop": MessageLookupByLibrary.simpleMessage(
      "結束分享畫面",
    ),
    "v3_lbl_streaming_view_unmute": MessageLookupByLibrary.simpleMessage(
      "取消靜音",
    ),
    "v3_lbl_touchback_one_device_cancel": MessageLookupByLibrary.simpleMessage(
      "取消",
    ),
    "v3_lbl_touchback_one_device_confirm": MessageLookupByLibrary.simpleMessage(
      "確定",
    ),
    "v3_lbl_touchback_restart_bluetooth_btn_cancel":
        MessageLookupByLibrary.simpleMessage("取消"),
    "v3_lbl_touchback_restart_bluetooth_btn_restart":
        MessageLookupByLibrary.simpleMessage("重新啟動"),
    "v3_main_connection_dialog_close": MessageLookupByLibrary.simpleMessage(
      "關閉",
    ),
    "v3_main_internet_connection_only": MessageLookupByLibrary.simpleMessage(
      "僅接受Internet連線分享，請檢查設備端的網路連線設定。",
    ),
    "v3_main_internet_connection_only_error":
        MessageLookupByLibrary.simpleMessage("網路連線能力錯誤，請檢查設備端的網路連線設定。"),
    "v3_main_internet_connection_only_error_dialog_desc":
        MessageLookupByLibrary.simpleMessage("網路連線能力錯誤，請檢查設備端的網路連線設定。"),
    "v3_main_local_connection_only_dialog_desc":
        MessageLookupByLibrary.simpleMessage("僅接受內部網路連線分享，請檢查設備端的網路連線設定。"),
    "v3_main_status_no_network": MessageLookupByLibrary.simpleMessage(
      "無網路連接。請連接到Wi-Fi或Intranet網絡，然後重試。",
    ),
    "v3_miracast_not_support": MessageLookupByLibrary.simpleMessage(
      "目前使用的Wi-Fi頻道不支援Miracast功能",
    ),
    "v3_mirror_request_passcode": MessageLookupByLibrary.simpleMessage("密碼"),
    "v3_moderator_disable_mirror_cancel": MessageLookupByLibrary.simpleMessage(
      "取消",
    ),
    "v3_moderator_disable_mirror_desc": MessageLookupByLibrary.simpleMessage(
      "主持人模式下將關閉螢幕鏡射",
    ),
    "v3_moderator_disable_mirror_ok": MessageLookupByLibrary.simpleMessage(
      "確定",
    ),
    "v3_moderator_disable_mirror_title": MessageLookupByLibrary.simpleMessage(
      "即將關閉螢幕鏡射",
    ),
    "v3_moderator_mode": MessageLookupByLibrary.simpleMessage("主持人模式"),
    "v3_new_sharing_join_session": MessageLookupByLibrary.simpleMessage("加入"),
    "v3_participant_item_casting": MessageLookupByLibrary.simpleMessage("投影中"),
    "v3_participant_item_connected": MessageLookupByLibrary.simpleMessage(
      "已連線",
    ),
    "v3_participant_item_controlling": MessageLookupByLibrary.simpleMessage(
      "接收畫面並控制中",
    ),
    "v3_participant_item_receiving": MessageLookupByLibrary.simpleMessage(
      "接收畫面中",
    ),
    "v3_participant_item_share": MessageLookupByLibrary.simpleMessage("分享畫面"),
    "v3_participant_item_waiting": MessageLookupByLibrary.simpleMessage("等待中"),
    "v3_participants_desc": MessageLookupByLibrary.simpleMessage("最多六位參加人員"),
    "v3_participants_desc_maximum_9": MessageLookupByLibrary.simpleMessage(
      "最多九位參加人員",
    ),
    "v3_participants_title": MessageLookupByLibrary.simpleMessage("參加人員"),
    "v3_qrcode_quick_connect": MessageLookupByLibrary.simpleMessage("快速連線"),
    "v3_quick_connect_menu_bottom_msg": MessageLookupByLibrary.simpleMessage(
      "多人分享時將自動分割畫面",
    ),
    "v3_quick_connect_menu_display_code": MessageLookupByLibrary.simpleMessage(
      "投影辨識碼",
    ),
    "v3_quick_connect_menu_qrcode": MessageLookupByLibrary.simpleMessage(
      "QR code",
    ),
    "v3_setting_passcode_cancel": MessageLookupByLibrary.simpleMessage("取消"),
    "v3_setting_passcode_clear": MessageLookupByLibrary.simpleMessage("清除"),
    "v3_setting_passcode_confirm": MessageLookupByLibrary.simpleMessage("確認"),
    "v3_setting_passcode_error_description":
        MessageLookupByLibrary.simpleMessage("密碼錯誤，請重新輸入"),
    "v3_setting_passcode_title": MessageLookupByLibrary.simpleMessage(
      "請輸入解鎖密碼",
    ),
    "v3_settings_accessibility": MessageLookupByLibrary.simpleMessage("無障礙協助"),
    "v3_settings_all_the_time_info": MessageLookupByLibrary.simpleMessage(
      "不論有無分享螢幕，一律接收廣播。",
    ),
    "v3_settings_broadcast": MessageLookupByLibrary.simpleMessage("螢幕廣播"),
    "v3_settings_broadcast_boards": MessageLookupByLibrary.simpleMessage(
      "其他AirSync裝置",
    ),
    "v3_settings_broadcast_cast_boards": MessageLookupByLibrary.simpleMessage(
      "螢幕廣播",
    ),
    "v3_settings_broadcast_cast_boards_desc":
        MessageLookupByLibrary.simpleMessage("將此大屏的畫面分享到同一網路內的其他大屏"),
    "v3_settings_broadcast_cast_to": MessageLookupByLibrary.simpleMessage(
      "廣播到",
    ),
    "v3_settings_broadcast_devices": MessageLookupByLibrary.simpleMessage(
      "傳送端裝置",
    ),
    "v3_settings_broadcast_screen_energy_saving":
        MessageLookupByLibrary.simpleMessage("建議關閉螢幕節能設定，避免螢幕廣播非預期中斷"),
    "v3_settings_broadcast_to_display_group":
        MessageLookupByLibrary.simpleMessage("螢幕群組廣播"),
    "v3_settings_connectivity": MessageLookupByLibrary.simpleMessage("連線方式"),
    "v3_settings_connectivity_both": MessageLookupByLibrary.simpleMessage(
      "接受網際網路與區域網路連線",
    ),
    "v3_settings_connectivity_internet": MessageLookupByLibrary.simpleMessage(
      "僅接受網際網路連線",
    ),
    "v3_settings_connectivity_internet_desc":
        MessageLookupByLibrary.simpleMessage("需要穩定的網路品質"),
    "v3_settings_connectivity_local": MessageLookupByLibrary.simpleMessage(
      "僅接受區域網路連線",
    ),
    "v3_settings_connectivity_local_desc": MessageLookupByLibrary.simpleMessage(
      "透過區域網路連線，可提供更多的安全性和穩定性",
    ),
    "v3_settings_device_authorize_mode": MessageLookupByLibrary.simpleMessage(
      "允許後才能分享螢幕",
    ),
    "v3_settings_device_auto_fill_otp": MessageLookupByLibrary.simpleMessage(
      "自動填入一次性密碼",
    ),
    "v3_settings_device_auto_fill_otp_desc":
        MessageLookupByLibrary.simpleMessage("從設備清單中連線時，自動填入一次性密碼"),
    "v3_settings_device_launch_on_startup":
        MessageLookupByLibrary.simpleMessage("開機後自動執行 AirSync"),
    "v3_settings_device_name": MessageLookupByLibrary.simpleMessage("裝置名稱"),
    "v3_settings_device_name_empty_error": MessageLookupByLibrary.simpleMessage(
      "設備名稱不可為空白",
    ),
    "v3_settings_device_name_save": MessageLookupByLibrary.simpleMessage("儲存"),
    "v3_settings_device_setting": MessageLookupByLibrary.simpleMessage("裝置設定"),
    "v3_settings_device_show_display_code":
        MessageLookupByLibrary.simpleMessage("永遠顯示投影辨識碼"),
    "v3_settings_device_show_display_code_desc":
        MessageLookupByLibrary.simpleMessage(
          "AirSync在背景執行時，仍能在螢幕上方顯示連線資訊，方便即時分享螢幕",
        ),
    "v3_settings_device_smart_scaling": MessageLookupByLibrary.simpleMessage(
      "智慧滿屏",
    ),
    "v3_settings_device_smart_scaling_desc":
        MessageLookupByLibrary.simpleMessage("自動調整畫面大小，最大利用螢幕空間．畫面可能會些許變形．"),
    "v3_settings_device_unavailable": MessageLookupByLibrary.simpleMessage(
      "無法接收廣播",
    ),
    "v3_settings_display_group": MessageLookupByLibrary.simpleMessage("螢幕群組"),
    "v3_settings_display_group_all_the_time":
        MessageLookupByLibrary.simpleMessage("一律廣播"),
    "v3_settings_display_group_cast": MessageLookupByLibrary.simpleMessage(
      "廣播",
    ),
    "v3_settings_display_group_only_casting":
        MessageLookupByLibrary.simpleMessage("僅在分享畫面來源時廣播"),
    "v3_settings_feature_locked": MessageLookupByLibrary.simpleMessage(
      "此功能模組透過ViewSonic Manager鎖定中。",
    ),
    "v3_settings_invite_group": MessageLookupByLibrary.simpleMessage(
      "當收到螢幕廣播請求時",
    ),
    "v3_settings_invite_group_auto_accept":
        MessageLookupByLibrary.simpleMessage("永遠接受"),
    "v3_settings_invite_group_ignore": MessageLookupByLibrary.simpleMessage(
      "永遠拒絕",
    ),
    "v3_settings_invite_group_notify_me": MessageLookupByLibrary.simpleMessage(
      "通知我接受或拒絕",
    ),
    "v3_settings_legal_policy": MessageLookupByLibrary.simpleMessage("法律和政策"),
    "v3_settings_local_connection_only": MessageLookupByLibrary.simpleMessage(
      "僅限區域網路連線",
    ),
    "v3_settings_mirroring_auto_accept": MessageLookupByLibrary.simpleMessage(
      "自動接受螢幕鏡射",
    ),
    "v3_settings_mirroring_auto_accept_desc":
        MessageLookupByLibrary.simpleMessage("不須同意，一律接受螢幕鏡射請求"),
    "v3_settings_mirroring_blocked": MessageLookupByLibrary.simpleMessage(
      "請先關閉主持人模式",
    ),
    "v3_settings_mirroring_require_passcode":
        MessageLookupByLibrary.simpleMessage("需輸入AirPlay密碼"),
    "v3_settings_only_when_casting_info": MessageLookupByLibrary.simpleMessage(
      "只有在分享螢幕時，才會接收廣播。",
    ),
    "v3_settings_open_source_license": MessageLookupByLibrary.simpleMessage(
      "開源許可證",
    ),
    "v3_settings_privacy_policy": MessageLookupByLibrary.simpleMessage("隱私權政策"),
    "v3_settings_resize_text_size": MessageLookupByLibrary.simpleMessage(
      "調整字體大小",
    ),
    "v3_settings_resize_text_size_extra_large":
        MessageLookupByLibrary.simpleMessage("特大"),
    "v3_settings_resize_text_size_large": MessageLookupByLibrary.simpleMessage(
      "大",
    ),
    "v3_settings_resize_text_size_normal": MessageLookupByLibrary.simpleMessage(
      "正常",
    ),
    "v3_settings_version": m1,
    "v3_settings_whats_new": MessageLookupByLibrary.simpleMessage(
      "What\'s New",
    ),
    "v3_settings_whats_new_content": MessageLookupByLibrary.simpleMessage(
      "AirSync %s 版本發行說明\n\nAirSync 是 ViewSonic 專有的無線螢幕分享產品。搭配AirSync sender一起使用時，您可以快速地從您的各種設備無線分享螢幕到 ViewSonic 大型互動式顯示器。\n\n此版本包含以下新功能：\n\n1. 支援 ViewSonic LED 顯示器。\n\n2. 支援在大屏上反控Android裝置的功能。\n\n3. 支援透過 AirPlay 共享時，在大屏上反控iPad的功能。\n\n4. 智慧滿屏。\n\n5. 可以調整設備端接收大屏畫面視窗的大小。\n\n6. 提升 Miracast 的穩定性。\n\n7. 修正錯誤。",
    ),
    "v3_shortcuts_airplay": MessageLookupByLibrary.simpleMessage("AirPlay"),
    "v3_shortcuts_cast_device": MessageLookupByLibrary.simpleMessage("分享到設備端"),
    "v3_shortcuts_cast_device_desc": MessageLookupByLibrary.simpleMessage(
      "將螢幕分享到多個設備端，包括筆記型電腦，平板電腦，及行動電話裝置",
    ),
    "v3_shortcuts_google_cast": MessageLookupByLibrary.simpleMessage(
      "Google Cast",
    ),
    "v3_shortcuts_menu_title": MessageLookupByLibrary.simpleMessage("快速功能區"),
    "v3_shortcuts_miracast": MessageLookupByLibrary.simpleMessage("Miracast"),
    "v3_shortcuts_mirroring": MessageLookupByLibrary.simpleMessage("螢幕鏡射"),
    "v3_touchback_alert_message": MessageLookupByLibrary.simpleMessage(
      "一次只能反控一台設備",
    ),
    "v3_touchback_alert_title": MessageLookupByLibrary.simpleMessage("啟用反控%s?"),
    "v3_touchback_disable_message": MessageLookupByLibrary.simpleMessage(
      "反控已關閉",
    ),
    "v3_touchback_fail_message": MessageLookupByLibrary.simpleMessage(
      "配對失敗，未啟用反控。請重新操作。",
    ),
    "v3_touchback_restart_bluetooth_btn_cancel":
        MessageLookupByLibrary.simpleMessage("取消"),
    "v3_touchback_restart_bluetooth_btn_restart":
        MessageLookupByLibrary.simpleMessage("重啟"),
    "v3_touchback_restart_bluetooth_message":
        MessageLookupByLibrary.simpleMessage("操作逾時，請關閉並重新啟動大屏端藍芽功能，然後重新啟動反控"),
    "v3_touchback_restart_bluetooth_title":
        MessageLookupByLibrary.simpleMessage("操作逾時，請重啟藍芽"),
    "v3_touchback_state_deviceFinding_message":
        MessageLookupByLibrary.simpleMessage("搜尋設備中"),
    "v3_touchback_state_deviceFoundSuccess_message":
        MessageLookupByLibrary.simpleMessage("成功發現設備"),
    "v3_touchback_state_devicePairedSuccess_message":
        MessageLookupByLibrary.simpleMessage("設備配對成功"),
    "v3_touchback_state_devicePairing_message":
        MessageLookupByLibrary.simpleMessage("設備配對中"),
    "v3_touchback_state_hidConnected_message":
        MessageLookupByLibrary.simpleMessage("HID設備已連線"),
    "v3_touchback_state_hidConnecting_message":
        MessageLookupByLibrary.simpleMessage("HID設備連線中"),
    "v3_touchback_state_hidProfileServiceStartedSuccess_message":
        MessageLookupByLibrary.simpleMessage("HID服務啟動成功"),
    "v3_touchback_state_hidProfileServiceStarting_message":
        MessageLookupByLibrary.simpleMessage("HID服務啟動中"),
    "v3_touchback_state_initialized_message":
        MessageLookupByLibrary.simpleMessage("初始化完成"),
    "v3_touchback_state_initializing_message":
        MessageLookupByLibrary.simpleMessage("正在初始化"),
    "v3_touchback_success_message": MessageLookupByLibrary.simpleMessage(
      "您可以開始從大屏反控設備端",
    ),
    "v3_waiting_desc": MessageLookupByLibrary.simpleMessage("等待螢幕分享中"),
    "v3_waiting_join": MessageLookupByLibrary.simpleMessage("等待其他人加入"),
    "v3_waiting_up_next": MessageLookupByLibrary.simpleMessage("下一位投影者"),
    "vbs_ota_progress_msg": MessageLookupByLibrary.simpleMessage("更新下載中"),
  };
}
