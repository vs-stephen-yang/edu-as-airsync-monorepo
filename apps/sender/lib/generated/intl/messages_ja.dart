// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ja locale. All the
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
  String get localeName => 'ja';

  static String m0(value) => "${value} 秒以内に共有したい画面を選択してください";

  static String m1(year) =>
      "Copyright © ViewSonic Corporation ${year}. All rights reserved.";

  static String m2(year, version) => "AirSync ©${year}. version ${version}";

  static String m3(year, version) =>
      "AirSync ©${year}. バージョン ${version} (Ind.)";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "device_list_enter_pin": MessageLookupByLibrary.simpleMessage("ワンタイムパスワード"),
    "device_list_enter_pin_ok": MessageLookupByLibrary.simpleMessage("OK"),
    "main_connect_network_error": MessageLookupByLibrary.simpleMessage(
      "ネットワークエラーです。ネットワーク接続を確認し、再度お試しください。",
    ),
    "main_connect_rate_limited": MessageLookupByLibrary.simpleMessage(
      "AirSync インスタンスがビジー状態です。後で再試行してください。",
    ),
    "main_connect_unknown_error": MessageLookupByLibrary.simpleMessage(
      "不明なエラーが発生しました。再度お試しいただくか、カスタマサポートまでご連絡ください。",
    ),
    "main_connection_mode_unsupported": MessageLookupByLibrary.simpleMessage(
      "AirSync はインターネットに接続できません。",
    ),
    "main_device_list": MessageLookupByLibrary.simpleMessage("クイック接続"),
    "main_display_code": MessageLookupByLibrary.simpleMessage("ディスプレイコード"),
    "main_display_code_description": MessageLookupByLibrary.simpleMessage(
      "ディスプレイコードを入力してください。",
    ),
    "main_display_code_error": MessageLookupByLibrary.simpleMessage(
      "*ディスプレイコードは 11 桁の数字です。",
    ),
    "main_display_code_exceed": MessageLookupByLibrary.simpleMessage(
      "最大参加者数 (6) 名に達した。",
    ),
    "main_display_code_exceed_split_screen":
        MessageLookupByLibrary.simpleMessage("最大発表者数 (4) 名に達した。"),
    "main_display_code_invalid": MessageLookupByLibrary.simpleMessage(
      "無効なディスプレイコードです。",
    ),
    "main_feature_reconnect_fail_toast": MessageLookupByLibrary.simpleMessage(
      "再接続に失敗しました",
    ),
    "main_feature_reconnect_success_toast":
        MessageLookupByLibrary.simpleMessage("再接続に成功しました"),
    "main_feature_reconnecting_toast": MessageLookupByLibrary.simpleMessage(
      "再接続しています",
    ),
    "main_instance_not_found_or_offline": MessageLookupByLibrary.simpleMessage(
      "ディスプレイコードが見つからないか、インスタンスがオフラインになっています。",
    ),
    "main_language": MessageLookupByLibrary.simpleMessage("言語選択"),
    "main_language_name": MessageLookupByLibrary.simpleMessage("English"),
    "main_notice_not_support_description": MessageLookupByLibrary.simpleMessage(
      "このプラットフォームは現在サポートされていません。より良い体験のために、アプリをダウンロードしてください。",
    ),
    "main_notice_positive_button": MessageLookupByLibrary.simpleMessage(
      "ダウンロード",
    ),
    "main_notice_title": MessageLookupByLibrary.simpleMessage("ご注意"),
    "main_otp_error": MessageLookupByLibrary.simpleMessage(
      "*ワンタイムパスワードは 4 桁の数字です。",
    ),
    "main_password": MessageLookupByLibrary.simpleMessage("パスワード"),
    "main_password_description": MessageLookupByLibrary.simpleMessage(
      "ワンタイムパスワードを入力してください。",
    ),
    "main_password_invalid": MessageLookupByLibrary.simpleMessage(
      "パスワードが無効です。",
    ),
    "main_present": MessageLookupByLibrary.simpleMessage("次へ"),
    "main_setting": MessageLookupByLibrary.simpleMessage("設定"),
    "main_touch_back": MessageLookupByLibrary.simpleMessage("タッチバック"),
    "main_update_deny_button": MessageLookupByLibrary.simpleMessage("今はしない"),
    "main_update_description_android": MessageLookupByLibrary.simpleMessage(
      "新バージョンがリリースされました。Google Play からアップデートしてください。",
    ),
    "main_update_description_apple": MessageLookupByLibrary.simpleMessage(
      "新バージョンがリリースされました。App Store からアップデートしてください。",
    ),
    "main_update_description_windows": MessageLookupByLibrary.simpleMessage(
      "新バージョンがリリースされました。ぜひインストールしてください。",
    ),
    "main_update_error_detail": MessageLookupByLibrary.simpleMessage("詳細: "),
    "main_update_error_title": MessageLookupByLibrary.simpleMessage("更新エラー"),
    "main_update_error_type": MessageLookupByLibrary.simpleMessage("エラーの原因: "),
    "main_update_positive_button": MessageLookupByLibrary.simpleMessage("更新"),
    "main_update_title": MessageLookupByLibrary.simpleMessage("新バージョンがあります"),
    "main_webrtc_reconnect_fail_toast": MessageLookupByLibrary.simpleMessage(
      "再接続に失敗しました",
    ),
    "main_webrtc_reconnect_success_toast": MessageLookupByLibrary.simpleMessage(
      "再接続に成功しました",
    ),
    "main_webrtc_reconnecting_toast": MessageLookupByLibrary.simpleMessage(
      "再接続しています",
    ),
    "moderator": MessageLookupByLibrary.simpleMessage("モデレーター"),
    "moderator_back": MessageLookupByLibrary.simpleMessage("戻る"),
    "moderator_exit": MessageLookupByLibrary.simpleMessage("退出"),
    "moderator_fill_out": MessageLookupByLibrary.simpleMessage("必須項目です"),
    "moderator_name": MessageLookupByLibrary.simpleMessage("お名前を入力してください"),
    "moderator_wait": MessageLookupByLibrary.simpleMessage(
      "モデレーターが発表者を選びますので、しばらくお待ちください。",
    ),
    "present_role_cast_screen": MessageLookupByLibrary.simpleMessage("画面を共有"),
    "present_role_receive": MessageLookupByLibrary.simpleMessage("画面を受信"),
    "present_select_screen_cancel": MessageLookupByLibrary.simpleMessage(
      "キャンセル",
    ),
    "present_select_screen_description": MessageLookupByLibrary.simpleMessage(
      "受信画面と共有するビューを選択してください。",
    ),
    "present_select_screen_entire": MessageLookupByLibrary.simpleMessage("全画面"),
    "present_select_screen_ios_restart": MessageLookupByLibrary.simpleMessage(
      "共有を開始",
    ),
    "present_select_screen_ios_restart_description":
        MessageLookupByLibrary.simpleMessage(
          "画面共有を再開するには下のボタンを押してください、中止するには 「戻る」を押してください。",
        ),
    "present_select_screen_share": MessageLookupByLibrary.simpleMessage("共有"),
    "present_select_screen_share_audio": MessageLookupByLibrary.simpleMessage(
      "画面音声を共有する",
    ),
    "present_select_screen_window": MessageLookupByLibrary.simpleMessage(
      "ウインドウ",
    ),
    "present_state_high_quality_description":
        MessageLookupByLibrary.simpleMessage("ネットワーク状態が良好な場合は、高画質を有効にする。"),
    "present_state_high_quality_title": MessageLookupByLibrary.simpleMessage(
      "高画質",
    ),
    "present_state_pause": MessageLookupByLibrary.simpleMessage("一時停止"),
    "present_state_resume": MessageLookupByLibrary.simpleMessage("再開"),
    "present_state_stop": MessageLookupByLibrary.simpleMessage("共有を中止"),
    "present_time": MessageLookupByLibrary.simpleMessage("経過時間"),
    "present_time_unit_hour": MessageLookupByLibrary.simpleMessage("時間"),
    "present_time_unit_min": MessageLookupByLibrary.simpleMessage("分"),
    "present_time_unit_sec": MessageLookupByLibrary.simpleMessage("秒"),
    "present_wait": m0,
    "remote_screen_connect_error": MessageLookupByLibrary.simpleMessage(
      "リモート画面接続エラー",
    ),
    "remote_screen_wait": MessageLookupByLibrary.simpleMessage(
      "画面共有処理中です。しばらくお待ちください。",
    ),
    "settings_audio_configuration": MessageLookupByLibrary.simpleMessage(
      "オーディオ設定",
    ),
    "settings_knowledge_base": MessageLookupByLibrary.simpleMessage("知識ベース"),
    "toast_enable_remote_screen": MessageLookupByLibrary.simpleMessage(
      "AirSync のデバイスへの画面共有を有効にしてください。",
    ),
    "toast_install_audio_driver": MessageLookupByLibrary.simpleMessage(
      "AirSync Audioのドライバーをインストールしてください。",
    ),
    "toast_maximum_moderated": MessageLookupByLibrary.simpleMessage(
      "モデレーターセッション数の上限に達しました。",
    ),
    "toast_maximum_remote_screen": MessageLookupByLibrary.simpleMessage(
      "共有画面数が上限に達しました。",
    ),
    "toast_maximum_split_screen": MessageLookupByLibrary.simpleMessage(
      "分割画面数が上限に達しました。",
    ),
    "v3_device_list_button_device_list": MessageLookupByLibrary.simpleMessage(
      "デバイスリスト",
    ),
    "v3_device_list_button_text": MessageLookupByLibrary.simpleMessage(
      "クイック接続",
    ),
    "v3_device_list_dialog_connect": MessageLookupByLibrary.simpleMessage("接続"),
    "v3_device_list_dialog_invalid_otp": MessageLookupByLibrary.simpleMessage(
      "ワンタイムパスワードが間違っています",
    ),
    "v3_device_list_dialog_title": MessageLookupByLibrary.simpleMessage(
      "クイック接続",
    ),
    "v3_eula_agree": MessageLookupByLibrary.simpleMessage("同意"),
    "v3_eula_disagree": MessageLookupByLibrary.simpleMessage("拒否"),
    "v3_eula_title": MessageLookupByLibrary.simpleMessage("エンドユーザー使用許諾契約"),
    "v3_lbl_change_language": MessageLookupByLibrary.simpleMessage("言語の変更"),
    "v3_lbl_device_list_button_device_list":
        MessageLookupByLibrary.simpleMessage("デバイスリスト"),
    "v3_lbl_device_list_close": MessageLookupByLibrary.simpleMessage(
      "デバイスリストを閉じる",
    ),
    "v3_lbl_device_list_next": MessageLookupByLibrary.simpleMessage("次へ"),
    "v3_lbl_download_independent_version": MessageLookupByLibrary.simpleMessage(
      "Mac 独立版を入手",
    ),
    "v3_lbl_download_menu_minimal": MessageLookupByLibrary.simpleMessage(
      "メニューを最小化",
    ),
    "v3_lbl_main_display_code": MessageLookupByLibrary.simpleMessage(
      "ディスプレイコードを入力",
    ),
    "v3_lbl_main_display_code_remove": MessageLookupByLibrary.simpleMessage(
      "ディスプレイコードを消去",
    ),
    "v3_lbl_main_download": MessageLookupByLibrary.simpleMessage(
      "AirSync Sender アプリをダウンロード",
    ),
    "v3_lbl_main_download_mac_store": MessageLookupByLibrary.simpleMessage(
      "Mac App Store 版を入手",
    ),
    "v3_lbl_main_download_mobile": MessageLookupByLibrary.simpleMessage(
      "モバイル版を入手",
    ),
    "v3_lbl_main_download_windows": MessageLookupByLibrary.simpleMessage(
      "Windows 版を入手",
    ),
    "v3_lbl_main_moderator_action": MessageLookupByLibrary.simpleMessage("共有"),
    "v3_lbl_main_moderator_input_hint": MessageLookupByLibrary.simpleMessage(
      "お名前を入力してください。",
    ),
    "v3_lbl_main_password": MessageLookupByLibrary.simpleMessage("パスワードを入力"),
    "v3_lbl_main_present_action": MessageLookupByLibrary.simpleMessage("次へ"),
    "v3_lbl_main_privacy": MessageLookupByLibrary.simpleMessage("プライバシーポリシー"),
    "v3_lbl_main_receive_app_action": MessageLookupByLibrary.simpleMessage(
      "接続",
    ),
    "v3_lbl_moderator_back": MessageLookupByLibrary.simpleMessage("戻る"),
    "v3_lbl_moderator_disconnect": MessageLookupByLibrary.simpleMessage("切断"),
    "v3_lbl_present_idle_audio_driver_warning_close":
        MessageLookupByLibrary.simpleMessage("オーディオドライバーの警告を閉じる"),
    "v3_lbl_present_idle_audio_driver_warning_download":
        MessageLookupByLibrary.simpleMessage("オーディオドライバーをダウンロード"),
    "v3_lbl_qr_close": MessageLookupByLibrary.simpleMessage("QR コードスキャナーを閉じる"),
    "v3_lbl_qr_code": MessageLookupByLibrary.simpleMessage("QR コードスキャナーを開く"),
    "v3_lbl_select_language": MessageLookupByLibrary.simpleMessage("%s を選択"),
    "v3_lbl_select_role_receive": MessageLookupByLibrary.simpleMessage("画面を受信"),
    "v3_lbl_select_role_share": MessageLookupByLibrary.simpleMessage("画面を共有"),
    "v3_lbl_select_screen_audio": MessageLookupByLibrary.simpleMessage(
      "PC オーディオを共有",
    ),
    "v3_lbl_select_screen_cancel": MessageLookupByLibrary.simpleMessage(
      "共有をキャンセル",
    ),
    "v3_lbl_select_screen_close": MessageLookupByLibrary.simpleMessage(
      "画面選択を閉じる",
    ),
    "v3_lbl_select_screen_ios_back": MessageLookupByLibrary.simpleMessage("戻る"),
    "v3_lbl_select_screen_ios_start_sharing":
        MessageLookupByLibrary.simpleMessage("共有を開始"),
    "v3_lbl_select_screen_share": MessageLookupByLibrary.simpleMessage("画面を共有"),
    "v3_lbl_select_screen_source_name": MessageLookupByLibrary.simpleMessage(
      "画面ソース: %s",
    ),
    "v3_lbl_setting": MessageLookupByLibrary.simpleMessage("設定"),
    "v3_lbl_setting_language_select": MessageLookupByLibrary.simpleMessage(
      "言語選択: %s",
    ),
    "v3_lbl_setting_legal_policy": MessageLookupByLibrary.simpleMessage(
      "法的ポリシーを見る: %s",
    ),
    "v3_lbl_setting_menu_back": MessageLookupByLibrary.simpleMessage(
      "前のメニューに戻る",
    ),
    "v3_lbl_setting_menu_close": MessageLookupByLibrary.simpleMessage(
      "設定メニューを閉じる",
    ),
    "v3_lbl_setting_privacy_policy": MessageLookupByLibrary.simpleMessage(
      "プライバシーポリシー",
    ),
    "v3_lbl_setting_select": MessageLookupByLibrary.simpleMessage("%s を選択"),
    "v3_lbl_setting_software_update_deny_action":
        MessageLookupByLibrary.simpleMessage("後で"),
    "v3_lbl_setting_software_update_fail_close":
        MessageLookupByLibrary.simpleMessage("アップデートのエラーメッセージを閉じる"),
    "v3_lbl_setting_software_update_fail_ok":
        MessageLookupByLibrary.simpleMessage("OK"),
    "v3_lbl_setting_software_update_no_available":
        MessageLookupByLibrary.simpleMessage("利用可能なアップデートはありません。"),
    "v3_lbl_setting_software_update_no_available_action":
        MessageLookupByLibrary.simpleMessage("OK"),
    "v3_lbl_setting_software_update_now_action":
        MessageLookupByLibrary.simpleMessage("今すぐアップデート"),
    "v3_lbl_setting_software_update_positive_action":
        MessageLookupByLibrary.simpleMessage("更新"),
    "v3_lbl_setting_update_close": MessageLookupByLibrary.simpleMessage(
      "アップデートのメッセージを閉じる",
    ),
    "v3_lbl_sharing_pause_off": MessageLookupByLibrary.simpleMessage("一時停止オフ"),
    "v3_lbl_sharing_pause_on": MessageLookupByLibrary.simpleMessage("一時停止オン"),
    "v3_lbl_sharing_stop": MessageLookupByLibrary.simpleMessage("共有を停止"),
    "v3_lbl_streaming_expand_button": MessageLookupByLibrary.simpleMessage(
      "ストリーミング制御の拡張",
    ),
    "v3_lbl_streaming_minimize_button": MessageLookupByLibrary.simpleMessage(
      "ストリーミング制御を最小化",
    ),
    "v3_lbl_streaming_stop_button": MessageLookupByLibrary.simpleMessage(
      "ストリーミングを停止",
    ),
    "v3_lbl_touch_back_off": MessageLookupByLibrary.simpleMessage("タッチバックを無効"),
    "v3_lbl_touch_back_on": MessageLookupByLibrary.simpleMessage("タッチバックを有効"),
    "v3_main_accessibility": MessageLookupByLibrary.simpleMessage("アクセシビリティ"),
    "v3_main_authorize_wait": MessageLookupByLibrary.simpleMessage(
      "ホストがリクエストを承認するまでお待ちください。",
    ),
    "v3_main_connect_network_error": MessageLookupByLibrary.simpleMessage(
      "ネットワーク接続エラーが発生しました。",
    ),
    "v3_main_connect_rate_limited": MessageLookupByLibrary.simpleMessage(
      "AirSync インスタンスがビジー状態です。後で再試行してください。",
    ),
    "v3_main_connect_unknown_error": MessageLookupByLibrary.simpleMessage(
      "不明なエラー。",
    ),
    "v3_main_connection_mode_unsupported": MessageLookupByLibrary.simpleMessage(
      "AirSync はインターネットに接続できません。",
    ),
    "v3_main_copy_rights": m1,
    "v3_main_display_code": MessageLookupByLibrary.simpleMessage("ディスプレイコード"),
    "v3_main_display_code_error": MessageLookupByLibrary.simpleMessage(
      "数字で入力してください。",
    ),
    "v3_main_display_code_invalid": MessageLookupByLibrary.simpleMessage(
      "無効なディスプレイコードです。",
    ),
    "v3_main_download": MessageLookupByLibrary.simpleMessage(
      "AirSync Sender アプリをダウンロード",
    ),
    "v3_main_download_action_download": MessageLookupByLibrary.simpleMessage(
      "ダウンロード",
    ),
    "v3_main_download_action_get": MessageLookupByLibrary.simpleMessage("入手"),
    "v3_main_download_app_dialog_desc": MessageLookupByLibrary.simpleMessage(
      "iOS または Android 端末で QR コードをスキャンしてダウンロードする",
    ),
    "v3_main_download_app_dialog_title": MessageLookupByLibrary.simpleMessage(
      "AirSync Sender をダウンロード",
    ),
    "v3_main_download_app_subtitle": MessageLookupByLibrary.simpleMessage(
      "iOS ＆ Android",
    ),
    "v3_main_download_app_title": MessageLookupByLibrary.simpleMessage(
      "AirSync アプリ",
    ),
    "v3_main_download_desc": MessageLookupByLibrary.simpleMessage(
      "ワンクリック接続で画面共有を簡単に。",
    ),
    "v3_main_download_mac_pkg_label": MessageLookupByLibrary.simpleMessage(
      "For Best User Experience!",
    ),
    "v3_main_download_mac_store": MessageLookupByLibrary.simpleMessage(
      "App Store",
    ),
    "v3_main_download_mac_store_label": MessageLookupByLibrary.simpleMessage(
      "公式からインストール",
    ),
    "v3_main_download_mac_subtitle": MessageLookupByLibrary.simpleMessage(
      "macOS 10.15+",
    ),
    "v3_main_download_mac_title": MessageLookupByLibrary.simpleMessage("Mac"),
    "v3_main_download_title": MessageLookupByLibrary.simpleMessage(
      "AirSync Sender アプリを入手する",
    ),
    "v3_main_download_win_subtitle": MessageLookupByLibrary.simpleMessage(
      "Win 10 (1709+)/ Win 11",
    ),
    "v3_main_download_win_title": MessageLookupByLibrary.simpleMessage(
      "Windows",
    ),
    "v3_main_instance_not_found_or_offline":
        MessageLookupByLibrary.simpleMessage(
          "ディスプレイコードが見つからないか、インスタンスがオフラインです。",
        ),
    "v3_main_moderator_action": MessageLookupByLibrary.simpleMessage("共有"),
    "v3_main_moderator_app_subtitle": MessageLookupByLibrary.simpleMessage(
      "画面共有の前にお名前を入力してください",
    ),
    "v3_main_moderator_app_title": MessageLookupByLibrary.simpleMessage("共有"),
    "v3_main_moderator_disconnect": MessageLookupByLibrary.simpleMessage(
      "接続解除",
    ),
    "v3_main_moderator_input_hint": MessageLookupByLibrary.simpleMessage(
      "お名前を入力してください",
    ),
    "v3_main_moderator_input_limit": MessageLookupByLibrary.simpleMessage(
      "お名前は20文字以内でご記入ください。",
    ),
    "v3_main_moderator_subtitle": MessageLookupByLibrary.simpleMessage(
      "プレゼンテーションのタイトルを入力してください",
    ),
    "v3_main_moderator_title": MessageLookupByLibrary.simpleMessage(
      "あなたの画面を共有",
    ),
    "v3_main_moderator_wait": MessageLookupByLibrary.simpleMessage(
      "モデレーターが共有を招待するまでお待ちください",
    ),
    "v3_main_otp_error": MessageLookupByLibrary.simpleMessage(
      "ワンタイムパスワードが間違っています。",
    ),
    "v3_main_password": MessageLookupByLibrary.simpleMessage("ワンタイムパスワード"),
    "v3_main_password_invalid": MessageLookupByLibrary.simpleMessage(
      "パスワードが無効です。",
    ),
    "v3_main_present_action": MessageLookupByLibrary.simpleMessage("次へ"),
    "v3_main_present_subtitle": MessageLookupByLibrary.simpleMessage(
      "ステップに従ってスタートしましょう。",
    ),
    "v3_main_present_title": MessageLookupByLibrary.simpleMessage("あなたの画面を共有"),
    "v3_main_presenting_message": MessageLookupByLibrary.simpleMessage(
      "あなたの画面が共有されています",
    ),
    "v3_main_privacy": MessageLookupByLibrary.simpleMessage("プライバシーポリシー"),
    "v3_main_receive_app_action": MessageLookupByLibrary.simpleMessage("接続"),
    "v3_main_receive_app_receive_from": MessageLookupByLibrary.simpleMessage(
      "%s から受信",
    ),
    "v3_main_receive_app_stop": MessageLookupByLibrary.simpleMessage("停止"),
    "v3_main_receive_app_subtitle": MessageLookupByLibrary.simpleMessage(
      "画面をお使いの端末に共有する",
    ),
    "v3_main_receive_app_title": MessageLookupByLibrary.simpleMessage("画面受信"),
    "v3_main_select_role_receive": MessageLookupByLibrary.simpleMessage(
      "画面を受信",
    ),
    "v3_main_select_role_share": MessageLookupByLibrary.simpleMessage("画面を共有"),
    "v3_main_select_role_title": MessageLookupByLibrary.simpleMessage(
      "使用したいモードをお選びください",
    ),
    "v3_main_terms": MessageLookupByLibrary.simpleMessage("利用規約"),
    "v3_main_web_nonsupport": MessageLookupByLibrary.simpleMessage(
      "現在のところ、Chrome と Edge ブラウザのみがサポートされています。",
    ),
    "v3_main_web_nonsupport_confirm": MessageLookupByLibrary.simpleMessage(
      "了解",
    ),
    "v3_present_end_information": MessageLookupByLibrary.simpleMessage(
      "画面共有が停止しました。\n合計共有時間は %s です。",
    ),
    "v3_present_idle_download_virtual_audio_device":
        MessageLookupByLibrary.simpleMessage("ダウンロード"),
    "v3_present_moderator_exited": MessageLookupByLibrary.simpleMessage(
      "モデレーターは終了しました",
    ),
    "v3_present_moderator_exited_action": MessageLookupByLibrary.simpleMessage(
      "OK",
    ),
    "v3_present_moderator_exited_description":
        MessageLookupByLibrary.simpleMessage("モデレーターは終了しましたため、再接続してください。"),
    "v3_present_options_menu_he_subtitle": MessageLookupByLibrary.simpleMessage(
      "この端末の GPU を使ってストリームをエンコードします。",
    ),
    "v3_present_options_menu_he_title": MessageLookupByLibrary.simpleMessage(
      "ハードウェアエンコード",
    ),
    "v3_present_options_menu_hq_subtitle": MessageLookupByLibrary.simpleMessage(
      "より高いビットレートでストリームを伝送します。",
    ),
    "v3_present_options_menu_hq_title": MessageLookupByLibrary.simpleMessage(
      "高画質",
    ),
    "v3_present_screen_full": MessageLookupByLibrary.simpleMessage(
      "画面分割数は上限に達しました",
    ),
    "v3_present_screen_full_action": MessageLookupByLibrary.simpleMessage("OK"),
    "v3_present_screen_full_description": MessageLookupByLibrary.simpleMessage(
      "画面分割数は上限に達しました",
    ),
    "v3_present_select_screen_extension": MessageLookupByLibrary.simpleMessage(
      "画面拡張",
    ),
    "v3_present_select_screen_extension_desc":
        MessageLookupByLibrary.simpleMessage("あなたのワークスペースを広げる"),
    "v3_present_select_screen_extension_desc2":
        MessageLookupByLibrary.simpleMessage(
          "これにより、個人用端末と IFP の間でコンテンツをドラッグできるようになり、リアルタイムのインタラクションとコントロールが強化される。",
        ),
    "v3_present_select_screen_mac_audio_driver":
        MessageLookupByLibrary.simpleMessage(
          "オーディオを共有できません。オーディオドライバをダウンロードしてインストールしてください。",
        ),
    "v3_present_select_screen_share_audio":
        MessageLookupByLibrary.simpleMessage("PC のオーディオを共有する。"),
    "v3_present_select_screen_subtitle": MessageLookupByLibrary.simpleMessage(
      "%s が画面を共有しようとしています。どちらの画面を共有するかを選択してください。",
    ),
    "v3_present_session_full": MessageLookupByLibrary.simpleMessage("セッション満席"),
    "v3_present_session_full_action": MessageLookupByLibrary.simpleMessage(
      "OK",
    ),
    "v3_present_session_full_description": MessageLookupByLibrary.simpleMessage(
      "セッションが上限に達しましたため、参加できません。",
    ),
    "v3_present_touch_back_allow": MessageLookupByLibrary.simpleMessage(
      "タッチバックを有効",
    ),
    "v3_present_touch_back_dialog_allow": MessageLookupByLibrary.simpleMessage(
      "許可",
    ),
    "v3_present_touch_back_dialog_description":
        MessageLookupByLibrary.simpleMessage(
          "画面共有を有効にすると、AirSync は一時的に画面の内容をキャプチャし、選択したディスプレイ (例：IFP) に送信します。\\nタッチバックを有効にするには、AirSync はディスプレイからのリモートコントロールを可能にするため、アクセシビリティサービス権限が必要です。\\nAirSync は個人データを収集したり、ユーザーの操作を監視したりしません。この権限は、タッチコントロール機能の有効化のみに利用されます。",
        ),
    "v3_present_touch_back_dialog_not_now":
        MessageLookupByLibrary.simpleMessage("今はしない"),
    "v3_present_touch_back_dialog_title": MessageLookupByLibrary.simpleMessage(
      "タッチバックの許可",
    ),
    "v3_receiver_remote_screen_busy_action":
        MessageLookupByLibrary.simpleMessage("OK"),
    "v3_receiver_remote_screen_busy_description":
        MessageLookupByLibrary.simpleMessage(
          "受信側が別の AirSync 端末の画面を受信しているため、後で再試行してください。",
        ),
    "v3_receiver_remote_screen_busy_title":
        MessageLookupByLibrary.simpleMessage("接続数の上限に達しました"),
    "v3_scan_qr_reminder": MessageLookupByLibrary.simpleMessage(
      "QR コードをスキャンしてクイック接続",
    ),
    "v3_select_screen_ios_countdown": MessageLookupByLibrary.simpleMessage(
      "残り時間",
    ),
    "v3_select_screen_ios_start_sharing": MessageLookupByLibrary.simpleMessage(
      "共有を開始",
    ),
    "v3_setting_accessibility": MessageLookupByLibrary.simpleMessage(
      "アクセシビリティ",
    ),
    "v3_setting_accessibility_size_large": MessageLookupByLibrary.simpleMessage(
      "大",
    ),
    "v3_setting_accessibility_size_normal":
        MessageLookupByLibrary.simpleMessage("デフォルト"),
    "v3_setting_accessibility_size_xlarge":
        MessageLookupByLibrary.simpleMessage("最大"),
    "v3_setting_accessibility_text_size": MessageLookupByLibrary.simpleMessage(
      "テキストサイズ",
    ),
    "v3_setting_app_version": m2,
    "v3_setting_app_version_independent": m3,
    "v3_setting_check_update": MessageLookupByLibrary.simpleMessage(
      "アップデートを確認",
    ),
    "v3_setting_knowledge_base": MessageLookupByLibrary.simpleMessage("知識ベース"),
    "v3_setting_language": MessageLookupByLibrary.simpleMessage("言語選択"),
    "v3_setting_legal_policy": MessageLookupByLibrary.simpleMessage(
      "法的事項とプライバシー",
    ),
    "v3_setting_open_source_license": MessageLookupByLibrary.simpleMessage(
      "オープンソースライセンス",
    ),
    "v3_setting_privacy_policy": MessageLookupByLibrary.simpleMessage(
      "プライバシーポリシー",
    ),
    "v3_setting_privacy_policy_description": MessageLookupByLibrary.simpleMessage(
      "ViewSonic は、お客様のプライバシーの保護に努め、個人情報の取り扱いを真摯に取り扱います。以下のプライバシーポリシーは、ViewSonic が本ウェブサイトのご利用を通じてお客様の個人情報を収集した後、ViewSonic がお客様の個人情報をどのように取り扱うかについて詳しく説明しています。ViewSonic は、セキュリティ技術を使用してお客様の情報のプライバシーを維持し、お客様の個人情報の不正使用を防止するポリシーを遵守します。お客様は、本ウェブサイトを利用することにより、お客様の情報の収集および使用に同意したものとみなされます。ViewSonic.com からリンクするウェブサイトには、ViewSonic のプライバシーポリシーとは異なる独自のプライバシーポリシーが適用される場合があります。お客様がそのウェブサイトを訪問している間に収集された情報の使用方法に関する詳細情報については、それらのウェブサイトのプライバシーポリシーをご確認ください。\n\n当社のプライバシーポリシーの詳細については、以下のリンクをクリックしてください。",
    ),
    "v3_setting_software_update": MessageLookupByLibrary.simpleMessage(
      "ソフトウェアのアップデート",
    ),
    "v3_setting_software_update_deny_action":
        MessageLookupByLibrary.simpleMessage("後で"),
    "v3_setting_software_update_description":
        MessageLookupByLibrary.simpleMessage(
          "新しいバージョンが利用可能になりました。今すぐアップデートしますか？",
        ),
    "v3_setting_software_update_force_action":
        MessageLookupByLibrary.simpleMessage("今すぐアップデート"),
    "v3_setting_software_update_force_description":
        MessageLookupByLibrary.simpleMessage("新しいバージョンがあります。"),
    "v3_setting_software_update_no_available":
        MessageLookupByLibrary.simpleMessage("利用可能なアップデートはありません"),
    "v3_setting_software_update_no_available_action":
        MessageLookupByLibrary.simpleMessage("OK"),
    "v3_setting_software_update_no_available_description":
        MessageLookupByLibrary.simpleMessage("AirSync はすでに最新バージョンです。"),
    "v3_setting_software_update_no_internet_description":
        MessageLookupByLibrary.simpleMessage("インターネット接続を確認して、もう一度お試しください。"),
    "v3_setting_software_update_no_internet_tittle":
        MessageLookupByLibrary.simpleMessage("インターネット接続がありません"),
    "v3_setting_software_update_positive_action":
        MessageLookupByLibrary.simpleMessage("アップデート"),
    "v3_setting_title": MessageLookupByLibrary.simpleMessage("設定"),
  };
}
