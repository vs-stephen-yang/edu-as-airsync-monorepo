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

  static String m0(value) =>
      "画面共有が終了しようとしています。終了時間を 3 時間延長しますか？最大 ${value} 回まで延長可能です。";

  static String m1(year, version) => "AirSync ©${year}. version ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "eula_agree": MessageLookupByLibrary.simpleMessage("同意"),
    "eula_disagree": MessageLookupByLibrary.simpleMessage("拒否"),
    "eula_title": MessageLookupByLibrary.simpleMessage("AirSync エンドユーザー使用許諾契約"),
    "main_airplay_pin_code": MessageLookupByLibrary.simpleMessage(
      "AirPlay コード",
    ),
    "main_auto_startup": MessageLookupByLibrary.simpleMessage(
      "デバイス起動時に AirSync を起動する",
    ),
    "main_cast_settings_airplay": MessageLookupByLibrary.simpleMessage(
      "AirPlay",
    ),
    "main_cast_settings_device_name": MessageLookupByLibrary.simpleMessage(
      "デバイス名",
    ),
    "main_cast_settings_google_cast": MessageLookupByLibrary.simpleMessage(
      "Google Cast",
    ),
    "main_cast_settings_miracast": MessageLookupByLibrary.simpleMessage(
      "ミラーキャスト",
    ),
    "main_cast_settings_title": MessageLookupByLibrary.simpleMessage("キャスト設定"),
    "main_content_display_code": MessageLookupByLibrary.simpleMessage(
      "ディスプレイコード",
    ),
    "main_content_lan_only": MessageLookupByLibrary.simpleMessage("LAN 接続のみ"),
    "main_content_one_time_password": MessageLookupByLibrary.simpleMessage(
      "ワンタイムパスワード",
    ),
    "main_content_one_time_password_get_fail":
        MessageLookupByLibrary.simpleMessage(
          "パスワードの更新に失敗しました。\n再試行する前に 30秒 お待ちください。",
        ),
    "main_feature_no_network_warning": MessageLookupByLibrary.simpleMessage(
      "制御接続が切断されました。再接続してください。",
    ),
    "main_feature_reconnect_fail_toast": MessageLookupByLibrary.simpleMessage(
      "ネットワーク (制御) の再接続に失敗しました。",
    ),
    "main_feature_reconnect_success_toast":
        MessageLookupByLibrary.simpleMessage("ネットワーク (制御) の再接続に成功しました。"),
    "main_feature_reconnecting_toast": MessageLookupByLibrary.simpleMessage(
      "ネットワーク (制御) を再接続しています。",
    ),
    "main_get_display_code_failure": MessageLookupByLibrary.simpleMessage(
      "ディスプレイコードを取得できませんでした。ネットワーク接続が回復するまでお待ちください、またはアプリを再起動してください。",
    ),
    "main_language_name": MessageLookupByLibrary.simpleMessage("English"),
    "main_language_title": MessageLookupByLibrary.simpleMessage("言語選択"),
    "main_limit_time_message": MessageLookupByLibrary.simpleMessage("残り 5 分"),
    "main_mirror_from_client": MessageLookupByLibrary.simpleMessage(
      "%s は画面共有を希望しています。",
    ),
    "main_mirror_prompt_accept": MessageLookupByLibrary.simpleMessage("許可"),
    "main_mirror_prompt_cancel": MessageLookupByLibrary.simpleMessage("キャンセル"),
    "main_register_display_code_failure": MessageLookupByLibrary.simpleMessage(
      "ディスプレイコードとワンタイムパスワードを取得できませんでした。これはネットワークまたはサーバーの問題が原因である可能性があります。接続が回復次第、後ほど再度お試しください。",
    ),
    "main_settings_airplay_code": MessageLookupByLibrary.simpleMessage(
      "AirPlay コード",
    ),
    "main_settings_device_list": MessageLookupByLibrary.simpleMessage(
      "クイック接続パスワード",
    ),
    "main_settings_device_name": MessageLookupByLibrary.simpleMessage("デバイス名"),
    "main_settings_device_name_cancel": MessageLookupByLibrary.simpleMessage(
      "キャンセル",
    ),
    "main_settings_device_name_hint": MessageLookupByLibrary.simpleMessage(
      "デバイス名",
    ),
    "main_settings_device_name_save": MessageLookupByLibrary.simpleMessage(
      "保存",
    ),
    "main_settings_device_name_title": MessageLookupByLibrary.simpleMessage(
      "デバイス名を変更",
    ),
    "main_settings_language": MessageLookupByLibrary.simpleMessage("言語選択"),
    "main_settings_mirror_confirmation": MessageLookupByLibrary.simpleMessage(
      "ミラーリングの確認",
    ),
    "main_settings_pin_visible": MessageLookupByLibrary.simpleMessage("接続情報"),
    "main_settings_share_to_sender": MessageLookupByLibrary.simpleMessage(
      "画面をデバイスに共有",
    ),
    "main_settings_share_to_sender_limit_desc":
        MessageLookupByLibrary.simpleMessage("画面共有は最大 10 人まで可能です。"),
    "main_settings_title": MessageLookupByLibrary.simpleMessage("設定"),
    "main_settings_whats_new": MessageLookupByLibrary.simpleMessage("新着情報"),
    "main_split_screen_question": MessageLookupByLibrary.simpleMessage(
      "分割画面モードをご使用するには、上記のトグルをクリックしてください。最大 4 人の参加者が同時にプレゼンテーションを行うことができます。",
    ),
    "main_split_screen_title": MessageLookupByLibrary.simpleMessage("分割画面モード"),
    "main_split_screen_waiting": MessageLookupByLibrary.simpleMessage(
      "画面分割が有効になりました。プレゼンターが画面を共有するのを待機しています...",
    ),
    "main_status_go_background": MessageLookupByLibrary.simpleMessage(
      "AirSync アプリはバックグラウンドで実行中です。",
    ),
    "main_status_no_network": MessageLookupByLibrary.simpleMessage(
      "ネットワーク接続が不安定です。\n接続状態をご確認ください。",
    ),
    "main_status_remaining_time": MessageLookupByLibrary.simpleMessage(
      "%02d 分 : %02d 秒",
    ),
    "main_thanks_content": MessageLookupByLibrary.simpleMessage(
      "AirSync をご利用いただき、誠にありがとうございます。",
    ),
    "main_wait_title": MessageLookupByLibrary.simpleMessage(
      "プレゼンターの画面共有を待っています...",
    ),
    "main_wait_up_next": MessageLookupByLibrary.simpleMessage("次へ"),
    "main_webrtc_reconnect_fail_toast": MessageLookupByLibrary.simpleMessage(
      "ネットワーク (WebRTC) の再接続に失敗しました。",
    ),
    "main_webrtc_reconnect_success_toast": MessageLookupByLibrary.simpleMessage(
      "ネットワーク (WebRTC) の再接続に成功しました。",
    ),
    "main_webrtc_reconnecting_toast": MessageLookupByLibrary.simpleMessage(
      "ネットワーク (WebRTC) を再接続しています。",
    ),
    "main_whats_new_content": MessageLookupByLibrary.simpleMessage(
      "[改善機能]\n\n1. ディスプレイコードの表示を改善し、より良いユーザー体験を実現しました。\n\n2. 接続の安定性を向上させました。\n\n3. バグを修正しました。",
    ),
    "main_whats_new_title": MessageLookupByLibrary.simpleMessage(
      "AirSync の新着情報",
    ),
    "moderator_activate_split_screen": MessageLookupByLibrary.simpleMessage(
      "分割画面モードの場合は、上記のトグルをクリックしてください。最大 4 人の参加者が同時にプレゼンテーションを行うことができます。",
    ),
    "moderator_cancel": MessageLookupByLibrary.simpleMessage("キャンセル"),
    "moderator_confirm": MessageLookupByLibrary.simpleMessage("確認"),
    "moderator_deactivate_split_screen": MessageLookupByLibrary.simpleMessage(
      "この分割画面セッションを終了してもよろしいですか？現在共有されているすべての画面が終了されます。",
    ),
    "moderator_exit": MessageLookupByLibrary.simpleMessage("終了"),
    "moderator_exit_dialog": MessageLookupByLibrary.simpleMessage(
      "このモデレーターセッションを終了してもよろしいですか？すべてのプレゼンターが削除されます。",
    ),
    "moderator_presentersLimit": MessageLookupByLibrary.simpleMessage(
      "上記のトグルをクリックすると、モデレーターモードに切り替えます。最大 6 人のプレゼンターが参加できます。",
    ),
    "moderator_presentersList": MessageLookupByLibrary.simpleMessage("プレゼンター"),
    "moderator_remove": MessageLookupByLibrary.simpleMessage("削除"),
    "moderator_verifyCode_fail": MessageLookupByLibrary.simpleMessage(
      "何か問題が発生しました。もう一度お試しください。",
    ),
    "toast_maximum_split_screen": MessageLookupByLibrary.simpleMessage(
      "分割画面数が上限に達しました。",
    ),
    "update_install_now": MessageLookupByLibrary.simpleMessage("今すぐインストール"),
    "update_message": MessageLookupByLibrary.simpleMessage(
      "新しいバージョンのソフトウェアが利用可能になりました。",
    ),
    "update_title": MessageLookupByLibrary.simpleMessage("AirSync のアップデート"),
    "v3_authorize_prompt_accept": MessageLookupByLibrary.simpleMessage("許可"),
    "v3_authorize_prompt_accept_all": MessageLookupByLibrary.simpleMessage(
      "すべてを許可",
    ),
    "v3_authorize_prompt_decline": MessageLookupByLibrary.simpleMessage("拒否"),
    "v3_authorize_prompt_notification_cast":
        MessageLookupByLibrary.simpleMessage(
          "設定メニューで「承認を要求」をオフにすると、手動での確認をスキップできます。",
        ),
    "v3_authorize_prompt_notification_mirror":
        MessageLookupByLibrary.simpleMessage(
          "設定メニューで「自動承認」をオンにすると、すべてのストリーミングが自動的に承認されます。",
        ),
    "v3_authorize_prompt_title_launcher": MessageLookupByLibrary.simpleMessage(
      "参加者が画面を共有しようとしています",
    ),
    "v3_broadcast_cast_board_on": MessageLookupByLibrary.simpleMessage(
      "キャスト実行中",
    ),
    "v3_broadcast_cast_device_on": MessageLookupByLibrary.simpleMessage(
      "キャスト実行中",
    ),
    "v3_broadcast_indicator": MessageLookupByLibrary.simpleMessage("有効"),
    "v3_broadcast_multicast_checkbox": MessageLookupByLibrary.simpleMessage(
      "10〜100台のデバイスにキャスト",
    ),
    "v3_broadcast_multicast_desc": MessageLookupByLibrary.simpleMessage(
      "投影の開始後に受信デバイスの数を変更することはできません。",
    ),
    "v3_broadcast_multicast_warn": MessageLookupByLibrary.simpleMessage(
      "編集するには、すべての投影を中断してください。",
    ),
    "v3_cast_to_device_Receiving": MessageLookupByLibrary.simpleMessage("受信中"),
    "v3_cast_to_device_list_msg": MessageLookupByLibrary.simpleMessage(
      "デバイス数は最大 10 台までです。",
    ),
    "v3_cast_to_device_menu_or": MessageLookupByLibrary.simpleMessage("または"),
    "v3_cast_to_device_menu_quick_connect1":
        MessageLookupByLibrary.simpleMessage("クイック接続"),
    "v3_cast_to_device_menu_quick_connect2":
        MessageLookupByLibrary.simpleMessage("QR コードを読み取ってください。"),
    "v3_cast_to_device_menu_title": MessageLookupByLibrary.simpleMessage(
      "この画面の受信に参加",
    ),
    "v3_cast_to_device_reached_maximum": MessageLookupByLibrary.simpleMessage(
      "デバイス数の上限に達しています。",
    ),
    "v3_cast_to_device_title": MessageLookupByLibrary.simpleMessage("デバイスリスト"),
    "v3_cast_to_device_touch_back": MessageLookupByLibrary.simpleMessage(
      "タッチバックを有効",
    ),
    "v3_cast_to_device_touch_back_disable":
        MessageLookupByLibrary.simpleMessage("タッチバックを無効"),
    "v3_cast_to_device_touch_enabled": MessageLookupByLibrary.simpleMessage(
      "タッチバック",
    ),
    "v3_casting_ended_toast": MessageLookupByLibrary.simpleMessage(
      "画面共有が終了しました。",
    ),
    "v3_casting_time_countdown": m0,
    "v3_casting_time_do_not_extend": MessageLookupByLibrary.simpleMessage(
      "延長しない",
    ),
    "v3_casting_time_extend": MessageLookupByLibrary.simpleMessage("延長"),
    "v3_casting_time_extend_success_toast":
        MessageLookupByLibrary.simpleMessage("3 時間延長されました。"),
    "v3_download_app_desc": MessageLookupByLibrary.simpleMessage(
      "お使いの iOS または Android 端末で QR コードをスキャンしてダウンロードする",
    ),
    "v3_download_app_desktop": MessageLookupByLibrary.simpleMessage(
      "最高のユーザー体験のために！",
    ),
    "v3_download_app_desktop_hint": MessageLookupByLibrary.simpleMessage(
      "*手動インストーラー",
    ),
    "v3_download_app_desktop_store": MessageLookupByLibrary.simpleMessage(
      "App Store 経由で MacOS 版をインストール",
    ),
    "v3_download_app_desktop_store_hint": MessageLookupByLibrary.simpleMessage(
      "*MacOS 専用",
    ),
    "v3_download_app_desktop_title": MessageLookupByLibrary.simpleMessage(
      "デスクトップ",
    ),
    "v3_download_app_entry": MessageLookupByLibrary.simpleMessage(
      "AirSync Sender をダウンロード",
    ),
    "v3_download_app_for_desktop": MessageLookupByLibrary.simpleMessage(
      "PC 向け",
    ),
    "v3_download_app_for_desktop_desc": MessageLookupByLibrary.simpleMessage(
      "以下の URL を入力してダウンロードする。",
    ),
    "v3_download_app_for_mobile": MessageLookupByLibrary.simpleMessage(
      "iOS & Android 向け",
    ),
    "v3_download_app_for_mobile_desc": MessageLookupByLibrary.simpleMessage(
      "QR コードをスキャンしてすぐにアクセスできます。",
    ),
    "v3_download_app_mobile_title": MessageLookupByLibrary.simpleMessage(
      "モバイル",
    ),
    "v3_download_app_or": MessageLookupByLibrary.simpleMessage("または"),
    "v3_download_app_title": MessageLookupByLibrary.simpleMessage(
      "AirSync Sender をダウンロード",
    ),
    "v3_eula_agree": MessageLookupByLibrary.simpleMessage("同意"),
    "v3_eula_disagree": MessageLookupByLibrary.simpleMessage("拒否"),
    "v3_eula_launch": MessageLookupByLibrary.simpleMessage("起動"),
    "v3_eula_title": MessageLookupByLibrary.simpleMessage("エンドユーザー使用許諾契約"),
    "v3_exit_moderator_mode_cancel": MessageLookupByLibrary.simpleMessage(
      "キャンセル",
    ),
    "v3_exit_moderator_mode_desc": MessageLookupByLibrary.simpleMessage(
      "よろしいですか？これで参加者全員の接続が切れます。",
    ),
    "v3_exit_moderator_mode_exit": MessageLookupByLibrary.simpleMessage("終了"),
    "v3_exit_moderator_mode_title": MessageLookupByLibrary.simpleMessage(
      "モデレーターモードを終了",
    ),
    "v3_group_dialog_accept": MessageLookupByLibrary.simpleMessage("許可"),
    "v3_group_dialog_decline": MessageLookupByLibrary.simpleMessage("拒否"),
    "v3_group_dialog_message": MessageLookupByLibrary.simpleMessage(
      "%s があなたのデバイスにブロードキャスト要求を送信しました。このアクションにより、現在のコンテンツが同期されて表示されます。この要求を受け入れますか?",
    ),
    "v3_group_dialog_no_device_message": MessageLookupByLibrary.simpleMessage(
      "デバイスが選択されていません。",
    ),
    "v3_group_dialog_title": MessageLookupByLibrary.simpleMessage(
      "%s からのブロードキャスト要求",
    ),
    "v3_group_receive_view_status_from": MessageLookupByLibrary.simpleMessage(
      "デバイスからブロードキャストしています：",
    ),
    "v3_group_receive_view_status_stop": MessageLookupByLibrary.simpleMessage(
      "停止",
    ),
    "v3_group_reject_invited": MessageLookupByLibrary.simpleMessage(
      "ブロードキャストリクエストを拒否する場合は、ブロードキャスト設定を確認してください。",
    ),
    "v3_help_center_cast_device_title": MessageLookupByLibrary.simpleMessage(
      "デバイスにキャスト",
    ),
    "v3_help_center_cast_device_title_sub":
        MessageLookupByLibrary.simpleMessage("IFP の画面をデバイスに表示します。"),
    "v3_help_center_close": MessageLookupByLibrary.simpleMessage("閉じる"),
    "v3_help_center_fullscreen_title": MessageLookupByLibrary.simpleMessage(
      "全画面表示",
    ),
    "v3_help_center_mute_user_title": MessageLookupByLibrary.simpleMessage(
      "ユーザーをミュート",
    ),
    "v3_help_center_remove_user_title": MessageLookupByLibrary.simpleMessage(
      "ユーザーを削除",
    ),
    "v3_help_center_share_title": MessageLookupByLibrary.simpleMessage("共有に招待"),
    "v3_help_center_share_title_sub": MessageLookupByLibrary.simpleMessage(
      "デバイスの画面を IFP と共有します。",
    ),
    "v3_help_center_stop_share_title": MessageLookupByLibrary.simpleMessage(
      "共有を停止",
    ),
    "v3_help_center_title": MessageLookupByLibrary.simpleMessage("ヘルプセンター"),
    "v3_help_center_touchback_title": MessageLookupByLibrary.simpleMessage(
      "タッチバック",
    ),
    "v3_help_center_touchback_title_sub": MessageLookupByLibrary.simpleMessage(
      "ユーザーのリモート制御を許可します。",
    ),
    "v3_help_center_untouchback_title": MessageLookupByLibrary.simpleMessage(
      "タッチバックを解除",
    ),
    "v3_help_center_untouchback_title_sub":
        MessageLookupByLibrary.simpleMessage("タッチバックモードを解除します。"),
    "v3_instruction1a": MessageLookupByLibrary.simpleMessage(
      "airsync.net にアクセスするか、AirSync Sender アプリを開きます。",
    ),
    "v3_instruction1b": MessageLookupByLibrary.simpleMessage(
      "AirSync Sender アプリを開く",
    ),
    "v3_instruction2": MessageLookupByLibrary.simpleMessage("ディスプレイコードを入力する"),
    "v3_instruction2_onethird": MessageLookupByLibrary.simpleMessage(
      "ディスプレイコード",
    ),
    "v3_instruction3": MessageLookupByLibrary.simpleMessage("ワンタイムパスワードを入力する"),
    "v3_instruction3_onethird": MessageLookupByLibrary.simpleMessage(
      "ワンタイムパスワード",
    ),
    "v3_instruction_share_screen": MessageLookupByLibrary.simpleMessage(
      "あなたの画面を共有",
    ),
    "v3_instruction_support": MessageLookupByLibrary.simpleMessage(
      "AirPlay、Google Cast、ミラーキャスト経由での共有に対応",
    ),
    "v3_last_casting_time_countdown": MessageLookupByLibrary.simpleMessage(
      "画面共有が終了しようとしています。必要に応じて画面共有を再開てください。",
    ),
    "v3_lbl_authorize_prompt_accept": MessageLookupByLibrary.simpleMessage(
      "リクエストを許可",
    ),
    "v3_lbl_authorize_prompt_accept_all": MessageLookupByLibrary.simpleMessage(
      "すべてのリクエストを許可",
    ),
    "v3_lbl_authorize_prompt_decline": MessageLookupByLibrary.simpleMessage(
      "リクエストを拒否",
    ),
    "v3_lbl_broadcast_multicast_checkbox": MessageLookupByLibrary.simpleMessage(
      "10〜100台のデバイスにキャスト",
    ),
    "v3_lbl_cast_device_close": MessageLookupByLibrary.simpleMessage(
      "キャストデバイスの接続を終了",
    ),
    "v3_lbl_cast_device_next": MessageLookupByLibrary.simpleMessage("次のページ"),
    "v3_lbl_cast_device_previous": MessageLookupByLibrary.simpleMessage(
      "前のページ",
    ),
    "v3_lbl_cast_device_sort_asc": MessageLookupByLibrary.simpleMessage("昇順"),
    "v3_lbl_cast_device_sort_desc": MessageLookupByLibrary.simpleMessage("降順"),
    "v3_lbl_cast_device_touchback_disable":
        MessageLookupByLibrary.simpleMessage("キャストデバイスのタッチバックを無効にする"),
    "v3_lbl_cast_device_touchback_enable": MessageLookupByLibrary.simpleMessage(
      "キャストデバイスのタッチバックを有効にする",
    ),
    "v3_lbl_close_download_app_menu": MessageLookupByLibrary.simpleMessage(
      "Sender アプリのダウンロードメニューを閉じる",
    ),
    "v3_lbl_close_feature_set_cast_device":
        MessageLookupByLibrary.simpleMessage("キャストデバイスリストを閉じる"),
    "v3_lbl_close_feature_set_moderator": MessageLookupByLibrary.simpleMessage(
      "モデレーターリストを閉じる",
    ),
    "v3_lbl_close_help_center": MessageLookupByLibrary.simpleMessage(
      "ヘルプセンターメニューを閉じる",
    ),
    "v3_lbl_close_streaming_shortcut_menu":
        MessageLookupByLibrary.simpleMessage("ストリーミングのショートカットメニューを閉じる"),
    "v3_lbl_connection_dialog_close": MessageLookupByLibrary.simpleMessage(
      "接続状態ダイアログを閉じる",
    ),
    "v3_lbl_eula_agree": MessageLookupByLibrary.simpleMessage("同意する"),
    "v3_lbl_eula_disagree": MessageLookupByLibrary.simpleMessage("同意しない"),
    "v3_lbl_eula_launch": MessageLookupByLibrary.simpleMessage("起動"),
    "v3_lbl_exit_moderator_cancel": MessageLookupByLibrary.simpleMessage(
      "モデレーターモードの終了をキャンセル",
    ),
    "v3_lbl_exit_moderator_exit": MessageLookupByLibrary.simpleMessage(
      "モデレーターモードの終了を確定",
    ),
    "v3_lbl_extend_casting_do_not_extend": MessageLookupByLibrary.simpleMessage(
      "キャスト時間を延長しない",
    ),
    "v3_lbl_extend_casting_extend": MessageLookupByLibrary.simpleMessage(
      "キャスト時間の延長",
    ),
    "v3_lbl_group_reject_close": MessageLookupByLibrary.simpleMessage(
      "グループ拒否通知を閉じる",
    ),
    "v3_lbl_internet_connection_only_error":
        MessageLookupByLibrary.simpleMessage("モデレーターモードの終了をキャンセル"),
    "v3_lbl_internet_connection_warning": MessageLookupByLibrary.simpleMessage(
      "ローカル接続のみ対応します",
    ),
    "v3_lbl_main_language_title": MessageLookupByLibrary.simpleMessage("言語を選択"),
    "v3_lbl_main_language_title_item": MessageLookupByLibrary.simpleMessage(
      "%s を選択",
    ),
    "v3_lbl_message_dialog_cancel": MessageLookupByLibrary.simpleMessage(
      "ダイアログのキャンセル",
    ),
    "v3_lbl_message_dialog_confirm": MessageLookupByLibrary.simpleMessage(
      "ダイアログの確認",
    ),
    "v3_lbl_minimal_quick_connect_menu": MessageLookupByLibrary.simpleMessage(
      "クイック接続メニューを最小化",
    ),
    "v3_lbl_minimal_streaming_qrcode_menu":
        MessageLookupByLibrary.simpleMessage("ストリーミング QR コードメニューを最小化"),
    "v3_lbl_moderator_toggle": MessageLookupByLibrary.simpleMessage(
      "モデレーターモードの切り替え",
    ),
    "v3_lbl_open_download_app_menu": MessageLookupByLibrary.simpleMessage(
      "Sender アプリのダウンロードメニューを開く",
    ),
    "v3_lbl_open_feature_set_cast_device": MessageLookupByLibrary.simpleMessage(
      "キャストデバイスリストを開く",
    ),
    "v3_lbl_open_feature_set_moderator": MessageLookupByLibrary.simpleMessage(
      "モデレーターリストを開く",
    ),
    "v3_lbl_open_help_center": MessageLookupByLibrary.simpleMessage(
      "ヘルプセンターメニューを開く",
    ),
    "v3_lbl_open_menu_settings": MessageLookupByLibrary.simpleMessage(
      "設定メニューを開く",
    ),
    "v3_lbl_open_streaming_qrcode_menu": MessageLookupByLibrary.simpleMessage(
      "ストリーミング QR コードメニューを開く",
    ),
    "v3_lbl_open_streaming_shortcut_menu": MessageLookupByLibrary.simpleMessage(
      "ストリーミングのショートカットメニューを開く",
    ),
    "v3_lbl_overlay_bring_app_to_top": MessageLookupByLibrary.simpleMessage(
      "フローティング接続情報タブ",
    ),
    "v3_lbl_overlay_menu_expand": MessageLookupByLibrary.simpleMessage(
      "オーバーレイメニューを展開",
    ),
    "v3_lbl_overlay_menu_minimize": MessageLookupByLibrary.simpleMessage(
      "オーバーレイメニューを最小化",
    ),
    "v3_lbl_participant_cast_device": MessageLookupByLibrary.simpleMessage(
      "この参加者にデバイスをキャスト",
    ),
    "v3_lbl_participant_close": MessageLookupByLibrary.simpleMessage(
      "参加者の接続を終了",
    ),
    "v3_lbl_participant_disconnect": MessageLookupByLibrary.simpleMessage(
      "この参加者の接続を切断",
    ),
    "v3_lbl_participant_mirror_close": MessageLookupByLibrary.simpleMessage(
      "ミラーリング参加者の接続を終了",
    ),
    "v3_lbl_participant_mirror_share": MessageLookupByLibrary.simpleMessage(
      "この参加者のミラーリングに共有",
    ),
    "v3_lbl_participant_mirror_stop": MessageLookupByLibrary.simpleMessage(
      "このミラーリング参加者のストリーミングを停止",
    ),
    "v3_lbl_participant_share": MessageLookupByLibrary.simpleMessage(
      "この参加者の画面を共有",
    ),
    "v3_lbl_participant_stop": MessageLookupByLibrary.simpleMessage(
      "参加者のストリーミングを停止",
    ),
    "v3_lbl_participant_touch_back": MessageLookupByLibrary.simpleMessage(
      "この参加者のタッチバックを有効にする",
    ),
    "v3_lbl_participant_touch_back_disable":
        MessageLookupByLibrary.simpleMessage("この参加者のタッチバックを無効にする"),
    "v3_lbl_permission_exit": MessageLookupByLibrary.simpleMessage("閉じる"),
    "v3_lbl_resizable_expand": MessageLookupByLibrary.simpleMessage(
      "プレゼンテーション制御を展開",
    ),
    "v3_lbl_resizable_minimize": MessageLookupByLibrary.simpleMessage(
      "プレゼンテーション制御を最小化",
    ),
    "v3_lbl_resizable_mute": MessageLookupByLibrary.simpleMessage(
      "プレゼンテーションをミュート",
    ),
    "v3_lbl_resizable_stop": MessageLookupByLibrary.simpleMessage(
      "プレゼンテーションを停止",
    ),
    "v3_lbl_settings_accessibility": MessageLookupByLibrary.simpleMessage(
      "アクセシビリティ",
    ),
    "v3_lbl_settings_back_icon": MessageLookupByLibrary.simpleMessage(
      "前のページに戻る",
    ),
    "v3_lbl_settings_broadcast": MessageLookupByLibrary.simpleMessage(
      "ブロードキャスト設定メニューを開く",
    ),
    "v3_lbl_settings_broadcast_boards": MessageLookupByLibrary.simpleMessage(
      "ブロードキャストボードメニューを開く",
    ),
    "v3_lbl_settings_broadcast_devices": MessageLookupByLibrary.simpleMessage(
      "ブロードキャストデバイスメニューを開く",
    ),
    "v3_lbl_settings_broadcast_to_display_group":
        MessageLookupByLibrary.simpleMessage("ディスプレイグループへブロードキャストメニューを開く"),
    "v3_lbl_settings_broadcast_to_display_group_cast":
        MessageLookupByLibrary.simpleMessage("ブロードキャスト"),
    "v3_lbl_settings_broadcast_to_display_group_checkbox":
        MessageLookupByLibrary.simpleMessage("%s を選択"),
    "v3_lbl_settings_broadcast_to_display_group_confirm":
        MessageLookupByLibrary.simpleMessage("デバイスが選択されていないことをご確認ください。"),
    "v3_lbl_settings_broadcast_to_display_group_item":
        MessageLookupByLibrary.simpleMessage("%s を選択"),
    "v3_lbl_settings_broadcast_to_display_group_save":
        MessageLookupByLibrary.simpleMessage("保存"),
    "v3_lbl_settings_broadcast_to_display_group_type":
        MessageLookupByLibrary.simpleMessage("%s を選択"),
    "v3_lbl_settings_close_icon": MessageLookupByLibrary.simpleMessage(
      "設定メニューを閉じる",
    ),
    "v3_lbl_settings_connectivity": MessageLookupByLibrary.simpleMessage(
      "接続設定メニューを開く",
    ),
    "v3_lbl_settings_connectivity_item": MessageLookupByLibrary.simpleMessage(
      "%s を選択",
    ),
    "v3_lbl_settings_device_authorize_mode":
        MessageLookupByLibrary.simpleMessage("認証モードのオン/オフを切り替える"),
    "v3_lbl_settings_device_auto_fill_otp":
        MessageLookupByLibrary.simpleMessage("OTP自動入力モードのオン/オフを切り替える"),
    "v3_lbl_settings_device_high_image_quality":
        MessageLookupByLibrary.simpleMessage("高画質"),
    "v3_lbl_settings_device_launch_on_startup":
        MessageLookupByLibrary.simpleMessage("自動起動モードのオン/オフを切り替える"),
    "v3_lbl_settings_device_name": MessageLookupByLibrary.simpleMessage(
      "デバイス名の変更",
    ),
    "v3_lbl_settings_device_name_close": MessageLookupByLibrary.simpleMessage(
      "デバイス名設定を閉じる",
    ),
    "v3_lbl_settings_device_name_save": MessageLookupByLibrary.simpleMessage(
      "デバイス名を保存",
    ),
    "v3_lbl_settings_device_setting": MessageLookupByLibrary.simpleMessage(
      "デバイス設定メニューを開く",
    ),
    "v3_lbl_settings_device_smart_scaling":
        MessageLookupByLibrary.simpleMessage("スマートスケーリングのオン/オフを切り替える"),
    "v3_lbl_settings_enter_device_name": MessageLookupByLibrary.simpleMessage(
      "デバイス名を入力",
    ),
    "v3_lbl_settings_invite_group": MessageLookupByLibrary.simpleMessage(
      "画面ブロードキャストのドロップダウンメニューを開く",
    ),
    "v3_lbl_settings_invite_group_item": MessageLookupByLibrary.simpleMessage(
      "%s を選択",
    ),
    "v3_lbl_settings_knowledge_base": MessageLookupByLibrary.simpleMessage(
      "知識ベース",
    ),
    "v3_lbl_settings_legal_policy": MessageLookupByLibrary.simpleMessage(
      "法的ポリシー設定メニューを開く",
    ),
    "v3_lbl_settings_menu_locked": MessageLookupByLibrary.simpleMessage(
      "設定メニューがロックされています。",
    ),
    "v3_lbl_settings_mirroring_auto_accept":
        MessageLookupByLibrary.simpleMessage("自動承認のオン/オフを切り替える"),
    "v3_lbl_settings_mirroring_require_passcode":
        MessageLookupByLibrary.simpleMessage("パスコードの要求をオン/オフに切り替える"),
    "v3_lbl_settings_moderator_mode": MessageLookupByLibrary.simpleMessage(
      "モデレーターモード",
    ),
    "v3_lbl_settings_only_when_casting_info":
        MessageLookupByLibrary.simpleMessage("ディスプレイグループへブロードキャストの詳細情報"),
    "v3_lbl_settings_open_source_license": MessageLookupByLibrary.simpleMessage(
      "%s を選択",
    ),
    "v3_lbl_settings_show_display_code": MessageLookupByLibrary.simpleMessage(
      "表示コードのオン/オフを切り替える",
    ),
    "v3_lbl_settings_whats_new": MessageLookupByLibrary.simpleMessage(
      "新着情報設定メニューを開く",
    ),
    "v3_lbl_settings_whats_new_icon": MessageLookupByLibrary.simpleMessage(
      "新着情報アイコン",
    ),
    "v3_lbl_shortcuts_airplay": MessageLookupByLibrary.simpleMessage(
      "AirPlay のオン/オフを切り替える",
    ),
    "v3_lbl_shortcuts_google_cast": MessageLookupByLibrary.simpleMessage(
      "Google Cast のオン/オフを切り替える",
    ),
    "v3_lbl_shortcuts_miracast": MessageLookupByLibrary.simpleMessage(
      "ミラーキャストのオン/オフを切り替える",
    ),
    "v3_lbl_shortcuts_mirroring": MessageLookupByLibrary.simpleMessage(
      "ミラーリング設定メニューを開く",
    ),
    "v3_lbl_streaming_airplay_touchback": MessageLookupByLibrary.simpleMessage(
      "Airplay タッチバック",
    ),
    "v3_lbl_streaming_page_control": MessageLookupByLibrary.simpleMessage(
      "次のページ",
    ),
    "v3_lbl_streaming_shortcut_airplay_toggle":
        MessageLookupByLibrary.simpleMessage("AirPlay の切り替え"),
    "v3_lbl_streaming_shortcut_cast_device_toggle":
        MessageLookupByLibrary.simpleMessage("デバイスへのキャストの切り替え"),
    "v3_lbl_streaming_shortcut_expand": MessageLookupByLibrary.simpleMessage(
      "ストリーミング機能を展開",
    ),
    "v3_lbl_streaming_shortcut_google_cast_toggle":
        MessageLookupByLibrary.simpleMessage("Google Cast の切り替え"),
    "v3_lbl_streaming_shortcut_menu_locked":
        MessageLookupByLibrary.simpleMessage("ストリーミングのショートカットメニューがロックされています。"),
    "v3_lbl_streaming_shortcut_minimize": MessageLookupByLibrary.simpleMessage(
      "ストリーミング機能を折り畳む",
    ),
    "v3_lbl_streaming_shortcut_miracast_toggle":
        MessageLookupByLibrary.simpleMessage("ミラーキャストの切り替え"),
    "v3_lbl_streaming_view_expand": MessageLookupByLibrary.simpleMessage(
      "ストリーミング表示を拡大",
    ),
    "v3_lbl_streaming_view_function_expand":
        MessageLookupByLibrary.simpleMessage("ストリーミング機能を展開"),
    "v3_lbl_streaming_view_function_minimize":
        MessageLookupByLibrary.simpleMessage("ストリーミング機能を折り畳む"),
    "v3_lbl_streaming_view_minimize": MessageLookupByLibrary.simpleMessage(
      "ストリーミング表示を縮小",
    ),
    "v3_lbl_streaming_view_mute": MessageLookupByLibrary.simpleMessage(
      "オーディオをミュート",
    ),
    "v3_lbl_streaming_view_stop": MessageLookupByLibrary.simpleMessage(
      "ストリーミングを停止",
    ),
    "v3_lbl_streaming_view_unmute": MessageLookupByLibrary.simpleMessage(
      "オーディオのミュートを解除",
    ),
    "v3_lbl_touchback_one_device_cancel": MessageLookupByLibrary.simpleMessage(
      "ダイアログのキャンセル",
    ),
    "v3_lbl_touchback_one_device_confirm": MessageLookupByLibrary.simpleMessage(
      "ダイアログの確認",
    ),
    "v3_lbl_touchback_restart_bluetooth_btn_cancel":
        MessageLookupByLibrary.simpleMessage("キャンセル"),
    "v3_lbl_touchback_restart_bluetooth_btn_restart":
        MessageLookupByLibrary.simpleMessage("再起動"),
    "v3_main_connection_dialog_close": MessageLookupByLibrary.simpleMessage(
      "閉じる",
    ),
    "v3_main_internet_connection_only": MessageLookupByLibrary.simpleMessage(
      "インターネット接続のみ。",
    ),
    "v3_main_internet_connection_only_error":
        MessageLookupByLibrary.simpleMessage(
          "接続エラーが発生しました。デバイスのネットワーク設定をご確認ください。",
        ),
    "v3_main_internet_connection_only_error_dialog_desc":
        MessageLookupByLibrary.simpleMessage(
          "接続エラーが発生しました。デバイスのネットワーク設定をご確認ください。",
        ),
    "v3_main_local_connection_only_dialog_desc":
        MessageLookupByLibrary.simpleMessage(
          "LAN 接続のみ対応しています。デバイスのネットワーク設定をご確認ください。",
        ),
    "v3_main_status_no_network": MessageLookupByLibrary.simpleMessage(
      "インターネット接続を検出できません。Wi-Fi または内部ネットワークに接続して、再度お試しください。",
    ),
    "v3_miracast_not_support": MessageLookupByLibrary.simpleMessage(
      "現在の Wi-Fi チャンネルは画面ミラーリングに対応していませんため、Miracast は利用できません。",
    ),
    "v3_miracast_uibc_not_supported_message":
        MessageLookupByLibrary.simpleMessage(
          "このソースはミラーキャストのタッチバック機能に対応していません。",
        ),
    "v3_mirror_request_passcode": MessageLookupByLibrary.simpleMessage("パスコード"),
    "v3_moderator_disable_mirror_cancel": MessageLookupByLibrary.simpleMessage(
      "キャンセル",
    ),
    "v3_moderator_disable_mirror_desc": MessageLookupByLibrary.simpleMessage(
      "モデレーターモードでは、ミラーリングは無効になります。",
    ),
    "v3_moderator_disable_mirror_ok": MessageLookupByLibrary.simpleMessage(
      "OK",
    ),
    "v3_moderator_disable_mirror_title": MessageLookupByLibrary.simpleMessage(
      "モデレーターモードのミラーリングを無効にする",
    ),
    "v3_moderator_mode": MessageLookupByLibrary.simpleMessage("モデレーターモード"),
    "v3_new_sharing_join_session": MessageLookupByLibrary.simpleMessage(
      " セッションに参加した",
    ),
    "v3_participant_item_casting": MessageLookupByLibrary.simpleMessage(
      "キャスティング",
    ),
    "v3_participant_item_connected": MessageLookupByLibrary.simpleMessage(
      "接続済",
    ),
    "v3_participant_item_controlling": MessageLookupByLibrary.simpleMessage(
      "受信中 + タッチバック",
    ),
    "v3_participant_item_receiving": MessageLookupByLibrary.simpleMessage(
      "受信中",
    ),
    "v3_participant_item_share": MessageLookupByLibrary.simpleMessage("画面を共有"),
    "v3_participant_item_waiting": MessageLookupByLibrary.simpleMessage(
      "待っています...",
    ),
    "v3_participants_desc": MessageLookupByLibrary.simpleMessage(
      "最大 6 名まで参加可能です。",
    ),
    "v3_participants_desc_maximum_9": MessageLookupByLibrary.simpleMessage(
      "最大 9 名まで参加可能です。",
    ),
    "v3_participants_title": MessageLookupByLibrary.simpleMessage("参加者"),
    "v3_permission_description": MessageLookupByLibrary.simpleMessage(
      "デバイスの「設定」→「アプリ」から、AirSync アプリに必要な権限を許可してください。",
    ),
    "v3_permission_exit": MessageLookupByLibrary.simpleMessage("閉じる"),
    "v3_permission_title": MessageLookupByLibrary.simpleMessage("権限が必要です。"),
    "v3_qrcode_quick_connect": MessageLookupByLibrary.simpleMessage("クイック接続"),
    "v3_quick_connect_menu_bottom_msg": MessageLookupByLibrary.simpleMessage(
      "2 名以上のユーザーが画面を共有する場合、画面分割が自動的に有効になります。",
    ),
    "v3_quick_connect_menu_display_code": MessageLookupByLibrary.simpleMessage(
      "ディスプレイコード",
    ),
    "v3_quick_connect_menu_qrcode": MessageLookupByLibrary.simpleMessage(
      "QR コード",
    ),
    "v3_setting_passcode_cancel": MessageLookupByLibrary.simpleMessage("キャンセル"),
    "v3_setting_passcode_clear": MessageLookupByLibrary.simpleMessage("クリア"),
    "v3_setting_passcode_confirm": MessageLookupByLibrary.simpleMessage("確認"),
    "v3_setting_passcode_error_description":
        MessageLookupByLibrary.simpleMessage("パスワードが不正です。もう一度お試しください。"),
    "v3_setting_passcode_title": MessageLookupByLibrary.simpleMessage(
      "設定を解除するにはパスコードを入力してください。",
    ),
    "v3_settings_accessibility": MessageLookupByLibrary.simpleMessage(
      "アクセシビリティ",
    ),
    "v3_settings_all_the_time_info": MessageLookupByLibrary.simpleMessage(
      "ブロードキャストの送信元の IFP 画面は常に表示されます。",
    ),
    "v3_settings_broadcast": MessageLookupByLibrary.simpleMessage("ブロードキャスト"),
    "v3_settings_broadcast_boards": MessageLookupByLibrary.simpleMessage(
      "電子黒板",
    ),
    "v3_settings_broadcast_cast_boards": MessageLookupByLibrary.simpleMessage(
      "ViewBoard 電子黒板にキャスト",
    ),
    "v3_settings_broadcast_cast_boards_desc":
        MessageLookupByLibrary.simpleMessage(
          "この画面をネットワーク内のすべての ViewBoard 電子黒板に共有する。",
        ),
    "v3_settings_broadcast_cast_to": MessageLookupByLibrary.simpleMessage(
      "端末にブロードキャスト",
    ),
    "v3_settings_broadcast_devices": MessageLookupByLibrary.simpleMessage(
      "デバイス",
    ),
    "v3_settings_broadcast_screen_energy_saving":
        MessageLookupByLibrary.simpleMessage(
          "ブロードキャスト中の予期せぬ中断を避けるため、省エネを無効にしてください。",
        ),
    "v3_settings_broadcast_to_display_group":
        MessageLookupByLibrary.simpleMessage("ディスプレイグループにブロードキャスト"),
    "v3_settings_connectivity": MessageLookupByLibrary.simpleMessage("接続性"),
    "v3_settings_connectivity_both": MessageLookupByLibrary.simpleMessage(
      "インターネットとローカル接続の両方",
    ),
    "v3_settings_connectivity_internet": MessageLookupByLibrary.simpleMessage(
      "インターネット接続",
    ),
    "v3_settings_connectivity_internet_desc":
        MessageLookupByLibrary.simpleMessage("インターネット接続には安定したネットワーク環境が必要です。"),
    "v3_settings_connectivity_local": MessageLookupByLibrary.simpleMessage(
      "ローカル接続",
    ),
    "v3_settings_connectivity_local_desc": MessageLookupByLibrary.simpleMessage(
      "ローカル接続はプライベートネットワーク内で行われるため、より安全で安定した接続が可能です。",
    ),
    "v3_settings_device_authorize_mode": MessageLookupByLibrary.simpleMessage(
      "すべての画面共有リクエストに承認を要求する。",
    ),
    "v3_settings_device_auto_fill_otp": MessageLookupByLibrary.simpleMessage(
      "ワンタイムパスワード自動入力",
    ),
    "v3_settings_device_auto_fill_otp_desc":
        MessageLookupByLibrary.simpleMessage(
          "AirSync Sender アプリのクイック接続メニューからこのデバイスを選択すると、ワンタッチ接続が有効になります。",
        ),
    "v3_settings_device_high_image_quality":
        MessageLookupByLibrary.simpleMessage("高画質"),
    "v3_settings_device_high_image_quality_off_desc":
        MessageLookupByLibrary.simpleMessage("送信者の画面解像度に応じて、最大QHD（2K）画面共有。"),
    "v3_settings_device_high_image_quality_on_desc":
        MessageLookupByLibrary.simpleMessage(
          "送信者の画面解像度に応じて、Web送信者からの最大UHD（4K）画面共有、およびWindowsおよびmacOS送信者からの3K +。 高品質のネットワークが必要です。",
        ),
    "v3_settings_device_launch_on_startup":
        MessageLookupByLibrary.simpleMessage("起動時に AirSync を立ち上げる"),
    "v3_settings_device_name": MessageLookupByLibrary.simpleMessage("デバイス名"),
    "v3_settings_device_name_empty_error": MessageLookupByLibrary.simpleMessage(
      "デバイス名は空欄にできません。",
    ),
    "v3_settings_device_name_save": MessageLookupByLibrary.simpleMessage("保存"),
    "v3_settings_device_not_supported": MessageLookupByLibrary.simpleMessage(
      "このデバイスのバージョンはサポートされていません。",
    ),
    "v3_settings_device_setting": MessageLookupByLibrary.simpleMessage(
      "デバイス設定",
    ),
    "v3_settings_device_show_display_code":
        MessageLookupByLibrary.simpleMessage("ディスプレイコードを上部に表示"),
    "v3_settings_device_show_display_code_desc":
        MessageLookupByLibrary.simpleMessage(
          "他のアプリに切り替えているとき、もしくは画面共有が有効になっているときでも、コードを画面上部に表示しておきます。",
        ),
    "v3_settings_device_smart_scaling": MessageLookupByLibrary.simpleMessage(
      "スマートスケーリング",
    ),
    "v3_settings_device_smart_scaling_desc":
        MessageLookupByLibrary.simpleMessage(
          "画面サイズを自動的に調整し、画面スペースを最大限に活用します。画像がやや歪む場合があります、予めご了承ください。",
        ),
    "v3_settings_device_unavailable": MessageLookupByLibrary.simpleMessage(
      "利用不可",
    ),
    "v3_settings_display_group": MessageLookupByLibrary.simpleMessage(
      "ディスプレイグループ",
    ),
    "v3_settings_display_group_all_the_time":
        MessageLookupByLibrary.simpleMessage("常にブロードキャスト"),
    "v3_settings_display_group_cast": MessageLookupByLibrary.simpleMessage(
      "ブロードキャスト",
    ),
    "v3_settings_display_group_only_casting":
        MessageLookupByLibrary.simpleMessage("キャスト時のみ"),
    "v3_settings_feature_locked": MessageLookupByLibrary.simpleMessage(
      "デバイスの設定は内部管理によって無効になりました。",
    ),
    "v3_settings_invite_group": MessageLookupByLibrary.simpleMessage(
      "ディスプレイグループ招待の通知",
    ),
    "v3_settings_invite_group_auto_accept":
        MessageLookupByLibrary.simpleMessage("自動承認"),
    "v3_settings_invite_group_ignore": MessageLookupByLibrary.simpleMessage(
      "無視する",
    ),
    "v3_settings_invite_group_notify_me": MessageLookupByLibrary.simpleMessage(
      "通知する",
    ),
    "v3_settings_knowledge_base": MessageLookupByLibrary.simpleMessage("知識ベース"),
    "v3_settings_legal_policy": MessageLookupByLibrary.simpleMessage(
      "リーガル & ポリシー",
    ),
    "v3_settings_local_connection_only": MessageLookupByLibrary.simpleMessage(
      "ローカル接続のみ",
    ),
    "v3_settings_mirroring_auto_accept": MessageLookupByLibrary.simpleMessage(
      "自動承認",
    ),
    "v3_settings_mirroring_auto_accept_desc":
        MessageLookupByLibrary.simpleMessage(
          "モデレーターの承認を必要とせず、即座にミラーリングを有効にします。",
        ),
    "v3_settings_mirroring_blocked": MessageLookupByLibrary.simpleMessage(
      "まずモデレーターモードをオフにします。",
    ),
    "v3_settings_mirroring_require_passcode":
        MessageLookupByLibrary.simpleMessage("パスコードを要求する"),
    "v3_settings_moderator_mode": MessageLookupByLibrary.simpleMessage(
      "モデレーターモード",
    ),
    "v3_settings_only_when_casting_info": MessageLookupByLibrary.simpleMessage(
      "デバイスがブロードキャストを受信するのは、メイン画面がアクティブにキャストされているときだけです。",
    ),
    "v3_settings_open_source_license": MessageLookupByLibrary.simpleMessage(
      "オープンソースライセンス",
    ),
    "v3_settings_privacy_policy": MessageLookupByLibrary.simpleMessage(
      "プライバシーポリシー",
    ),
    "v3_settings_privacy_policy_description": MessageLookupByLibrary.simpleMessage(
      "ViewSonic は、お客様のプライバシーの保護に努め、個人情報の取り扱いを真摯に取り扱います。以下のプライバシーポリシーは、ViewSonic が本ウェブサイトのご利用を通じてお客様の個人情報を収集した後、ViewSonic がお客様の個人情報をどのように取り扱うかについて詳しく説明しています。ViewSonic は、セキュリティ技術を使用してお客様の情報のプライバシーを維持し、お客様の個人情報の不正使用を防止するポリシーを遵守します。本ウェブサイトを利用することにより、お客様は、お客様の情報の収集および使用に同意するものとします。\n\nViewSonic.com からリンクするウェブサイトは、ViewSonic.com とは異なる独自のプライバシーポリシーを持っている場合があります。お客様がそのウェブサイトを訪問している間に収集された情報の使用方法に関する詳細情報については、それらのウェブサイトのプライバシーポリシーをご確認ください。\n\n当社のプライバシーポリシーの詳細については、以下のリンクにてご参照ください。",
    ),
    "v3_settings_resize_text_size": MessageLookupByLibrary.simpleMessage(
      "文字サイズの変更",
    ),
    "v3_settings_resize_text_size_extra_large":
        MessageLookupByLibrary.simpleMessage("特大"),
    "v3_settings_resize_text_size_large": MessageLookupByLibrary.simpleMessage(
      "大",
    ),
    "v3_settings_resize_text_size_normal": MessageLookupByLibrary.simpleMessage(
      "普通",
    ),
    "v3_settings_version": m1,
    "v3_settings_whats_new": MessageLookupByLibrary.simpleMessage("新着情報"),
    "v3_settings_whats_new_content": MessageLookupByLibrary.simpleMessage(
      "AirSync %s\n\nAirSync は ViewSonic 独自のワイヤレス画面共有ソリューションです。AirSync sender と組み合わせて使用することで、ユーザーは ViewSonic の ViewBoard 電子黒板と画面をシームレスに共有できます。\n\n今回のリリースには以下の新機能が追加されています：\n\n1. ViewBoard の分割画面表示機能のサポート。\n\n2. ウェブ sender インタフェース経由での高画質画面共有 (最大 4K 解像度) のサポート。\n\n3. Windows sender アプリ経由で共有する際、デバイスのオーディオ出力をミュートできる機能。\n\n4. 安定性の向上。\n\n5. その他のバグの修正。",
    ),
    "v3_shortcuts_airplay": MessageLookupByLibrary.simpleMessage("AirPlay"),
    "v3_shortcuts_cast_device": MessageLookupByLibrary.simpleMessage(
      "デバイスにキャスト",
    ),
    "v3_shortcuts_cast_device_desc": MessageLookupByLibrary.simpleMessage(
      "この画面をノート PC、タブレット、モバイル機器など、複数のデバイスに同時にキャストします。",
    ),
    "v3_shortcuts_google_cast": MessageLookupByLibrary.simpleMessage(
      "Google Cast",
    ),
    "v3_shortcuts_menu_title": MessageLookupByLibrary.simpleMessage("ショートカット"),
    "v3_shortcuts_miracast": MessageLookupByLibrary.simpleMessage("ミラーキャスト"),
    "v3_shortcuts_mirroring": MessageLookupByLibrary.simpleMessage("ミラーリング"),
    "v3_touchback_alert_message": MessageLookupByLibrary.simpleMessage(
      "一度に 1 台のデバイスしかタッチバックできません。",
    ),
    "v3_touchback_alert_title": MessageLookupByLibrary.simpleMessage(
      "%s にタッチバックしますか？",
    ),
    "v3_touchback_disable_message": MessageLookupByLibrary.simpleMessage(
      "タッチバックは無効になっています。",
    ),
    "v3_touchback_fail_message": MessageLookupByLibrary.simpleMessage(
      "ペアリングに失敗しました。タッチバックが有効になっていません。もう一度お試しください。",
    ),
    "v3_touchback_restart_bluetooth_btn_cancel":
        MessageLookupByLibrary.simpleMessage("キャンセル"),
    "v3_touchback_restart_bluetooth_btn_restart":
        MessageLookupByLibrary.simpleMessage("再起動"),
    "v3_touchback_restart_bluetooth_message": MessageLookupByLibrary.simpleMessage(
      "操作タイムアウトが発生しました。Bluetooth 機能をオフにしてから、再起動してください。その後、タッチバック機能を再起動してください。",
    ),
    "v3_touchback_restart_bluetooth_title":
        MessageLookupByLibrary.simpleMessage(
          "操作がタイムアウトしました。Bluetooth を再起動してください。",
        ),
    "v3_touchback_state_deviceFinding_message":
        MessageLookupByLibrary.simpleMessage("デバイス検出中"),
    "v3_touchback_state_deviceFoundSuccess_message":
        MessageLookupByLibrary.simpleMessage("デバイスが正常に検出されました。"),
    "v3_touchback_state_devicePairedSuccess_message":
        MessageLookupByLibrary.simpleMessage("デバイスが正常にペアリングされました。"),
    "v3_touchback_state_devicePairing_message":
        MessageLookupByLibrary.simpleMessage("デバイスペアリング中"),
    "v3_touchback_state_hidConnected_message":
        MessageLookupByLibrary.simpleMessage("HID 接続済"),
    "v3_touchback_state_hidConnecting_message":
        MessageLookupByLibrary.simpleMessage("HID 接続中"),
    "v3_touchback_state_hidProfileServiceStartedSuccess_message":
        MessageLookupByLibrary.simpleMessage("HID プロファイルサービスが正常に開始されました。"),
    "v3_touchback_state_hidProfileServiceStarting_message":
        MessageLookupByLibrary.simpleMessage("HID プロファイルサービスを開始"),
    "v3_touchback_state_initialized_message":
        MessageLookupByLibrary.simpleMessage("初期化が正常に完了されました。"),
    "v3_touchback_state_initializing_message":
        MessageLookupByLibrary.simpleMessage("初期化中"),
    "v3_touchback_success_message": MessageLookupByLibrary.simpleMessage(
      "IFP から %s をリモートで操作できるようになりました。",
    ),
    "v3_waiting_desc": MessageLookupByLibrary.simpleMessage(
      "この参加者からの画面共有を待っています。",
    ),
    "v3_waiting_join": MessageLookupByLibrary.simpleMessage("他の参加者を待っています。"),
    "v3_waiting_up_next": MessageLookupByLibrary.simpleMessage("次の番"),
    "vbs_ota_progress_msg": MessageLookupByLibrary.simpleMessage(
      "システム更新をダウンロードしています。",
    ),
  };
}
