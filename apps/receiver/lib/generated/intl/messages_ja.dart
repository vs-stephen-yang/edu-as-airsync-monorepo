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

  static String m1(year, version) => "AirSync ©${year}. version ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "eula_agree": MessageLookupByLibrary.simpleMessage("同意"),
    "eula_disagree": MessageLookupByLibrary.simpleMessage("拒否"),
    "eula_title": MessageLookupByLibrary.simpleMessage("AirSync エンドユーザー使用許諾契約"),
    "main_content_display_code": MessageLookupByLibrary.simpleMessage(
      "ディスプレイコード",
    ),
    "main_content_one_time_password": MessageLookupByLibrary.simpleMessage(
      "ワンタイムパスワード",
    ),
    "main_status_go_background": MessageLookupByLibrary.simpleMessage(
      "AirSync アプリはバックグラウンドで実行中です。",
    ),
    "main_status_remaining_time": MessageLookupByLibrary.simpleMessage(
      "%02d 分 : %02d 秒",
    ),
    "update_install_now": MessageLookupByLibrary.simpleMessage("今すぐインストール"),
    "update_message": MessageLookupByLibrary.simpleMessage(
      "新しいバージョンのソフトウェアが利用可能になりました。",
    ),
    "update_title": MessageLookupByLibrary.simpleMessage("AirSync のアップデート"),
    "v3_authorize_prompt_accept": MessageLookupByLibrary.simpleMessage("許可"),
    "v3_authorize_prompt_decline": MessageLookupByLibrary.simpleMessage("拒否"),
    "v3_broadcast_indicator": MessageLookupByLibrary.simpleMessage("有効"),
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
    "v3_download_app_desc": MessageLookupByLibrary.simpleMessage(
      "お使いの iOS または Android 端末で QR コードをスキャンしてダウンロードする",
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
    "v3_download_app_or": MessageLookupByLibrary.simpleMessage("または"),
    "v3_download_app_title": MessageLookupByLibrary.simpleMessage(
      "AirSync Sender をダウンロード",
    ),
    "v3_eula_agree": MessageLookupByLibrary.simpleMessage("同意"),
    "v3_eula_disagree": MessageLookupByLibrary.simpleMessage("拒否"),
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
    "v3_instruction1a": MessageLookupByLibrary.simpleMessage(
      "airsync.net にアクセスするか、AirSync Sender アプリを開きます。",
    ),
    "v3_instruction1b": MessageLookupByLibrary.simpleMessage(
      "AirSync Sender アプリを開く",
    ),
    "v3_instruction2": MessageLookupByLibrary.simpleMessage("ディスプレイコードを入力する"),
    "v3_instruction3": MessageLookupByLibrary.simpleMessage("ワンタイムパスワードを入力する"),
    "v3_instruction_share_screen": MessageLookupByLibrary.simpleMessage(
      "あなたの画面を共有",
    ),
    "v3_instruction_support": MessageLookupByLibrary.simpleMessage(
      "AirPlay、Google Cast、Miracast 経由での共有に対応",
    ),
    "v3_main_status_no_network": MessageLookupByLibrary.simpleMessage(
      "インターネット接続を検出できません。Wi-Fi または内部ネットワークに接続して、再度お試しください。",
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
      "すべての画面共有リクエストに承認を求める。",
    ),
    "v3_settings_device_auto_fill_otp": MessageLookupByLibrary.simpleMessage(
      "ワンタイムパスワード自動入力",
    ),
    "v3_settings_device_auto_fill_otp_desc":
        MessageLookupByLibrary.simpleMessage(
          "AirSync Sender アプリのクイック接続メニューからこのデバイスを選択すると、ワンタッチ接続が有効になります。",
        ),
    "v3_settings_device_launch_on_startup":
        MessageLookupByLibrary.simpleMessage("起動時に AirSync を立ち上げる"),
    "v3_settings_device_name": MessageLookupByLibrary.simpleMessage("デバイス名"),
    "v3_settings_device_name_save": MessageLookupByLibrary.simpleMessage("保存"),
    "v3_settings_device_setting": MessageLookupByLibrary.simpleMessage(
      "デバイス設定",
    ),
    "v3_settings_device_show_display_code":
        MessageLookupByLibrary.simpleMessage("ディスプレイコードを上部に表示"),
    "v3_settings_device_show_display_code_desc":
        MessageLookupByLibrary.simpleMessage(
          "他のアプリに切り替えているとき、もしくは画面共有が有効になっているときでも、コードを画面上部に表示しておきます。",
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
        MessageLookupByLibrary.simpleMessage("自動で参加"),
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
      "自動で参加",
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
    "v3_settings_version": m1,
    "v3_settings_whats_new": MessageLookupByLibrary.simpleMessage("新着情報"),
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
