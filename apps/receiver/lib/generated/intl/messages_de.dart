// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de locale. All the
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
  String get localeName => 'de';

  static String m0(value) =>
      "Die Bildschirmfreigabe endet in Kürze. Möchten Sie sie um 3 Stunden verlängern? Sie können sie bis zu ${value} Mal verlängern.";

  static String m1(year, version) => "AirSync ©${year}. Version ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "eula_agree": MessageLookupByLibrary.simpleMessage("Ich stimme zu"),
    "eula_disagree": MessageLookupByLibrary.simpleMessage("Ich lehne ab"),
    "eula_title": MessageLookupByLibrary.simpleMessage("AirSync EULA"),
    "main_airplay_pin_code": MessageLookupByLibrary.simpleMessage(
      "AirPlay-Code",
    ),
    "main_auto_startup": MessageLookupByLibrary.simpleMessage(
      "AirSync beim Start starten",
    ),
    "main_cast_settings_airplay": MessageLookupByLibrary.simpleMessage(
      "AirPlay",
    ),
    "main_cast_settings_device_name": MessageLookupByLibrary.simpleMessage(
      "Name",
    ),
    "main_cast_settings_google_cast": MessageLookupByLibrary.simpleMessage(
      "Google Cast",
    ),
    "main_cast_settings_miracast": MessageLookupByLibrary.simpleMessage(
      "Miracast",
    ),
    "main_cast_settings_title": MessageLookupByLibrary.simpleMessage(
      "Übertragungseinstellungen",
    ),
    "main_content_display_code": MessageLookupByLibrary.simpleMessage(
      "Anzeigecode",
    ),
    "main_content_lan_only": MessageLookupByLibrary.simpleMessage(
      "Nur LAN-Verbindung",
    ),
    "main_content_one_time_password": MessageLookupByLibrary.simpleMessage(
      "Einmaliges Passwort",
    ),
    "main_content_one_time_password_get_fail": MessageLookupByLibrary.simpleMessage(
      "Passwort konnte nicht aktualisiert werden.\nBitte warten Sie 30 Sekunden, bevor Sie es erneut versuchen.",
    ),
    "main_feature_no_network_warning": MessageLookupByLibrary.simpleMessage(
      "Steuerungsverbindung getrennt. Bitte erneut verbinden",
    ),
    "main_feature_reconnect_fail_toast": MessageLookupByLibrary.simpleMessage(
      "Netzwerk (Steuerung) Wiederverbindung fehlgeschlagen",
    ),
    "main_feature_reconnect_success_toast":
        MessageLookupByLibrary.simpleMessage(
          "Netzwerk (Steuerung) Wiederverbindung erfolgreich",
        ),
    "main_feature_reconnecting_toast": MessageLookupByLibrary.simpleMessage(
      "Netzwerk (Steuerung) wird wieder verbunden",
    ),
    "main_get_display_code_failure": MessageLookupByLibrary.simpleMessage(
      "Anzeigecode konnte nicht abgerufen werden. Warten Sie, bis die Netzwerkverbindung wiederhergestellt ist, oder starten Sie die App neu.",
    ),
    "main_language_name": MessageLookupByLibrary.simpleMessage("Deutsch"),
    "main_language_title": MessageLookupByLibrary.simpleMessage("Sprache"),
    "main_limit_time_message": MessageLookupByLibrary.simpleMessage(
      "Noch 5 Minuten",
    ),
    "main_mirror_from_client": MessageLookupByLibrary.simpleMessage(
      "%s möchte seinen Bildschirm freigeben.",
    ),
    "main_mirror_prompt_accept": MessageLookupByLibrary.simpleMessage(
      "Akzeptieren",
    ),
    "main_mirror_prompt_cancel": MessageLookupByLibrary.simpleMessage(
      "Abbrechen",
    ),
    "main_register_display_code_failure": MessageLookupByLibrary.simpleMessage(
      "Fehler beim Abrufen von Anzeigecode und Einmalpasswort. Dies kann an einem Netzwerk- oder Serverproblem liegen. Bitte versuchen Sie es später erneut, wenn die Verbindung wiederhergestellt ist.",
    ),
    "main_settings_airplay_code": MessageLookupByLibrary.simpleMessage(
      "AirPlay-Code",
    ),
    "main_settings_device_list": MessageLookupByLibrary.simpleMessage(
      "Schnellverbindungs-Passwort",
    ),
    "main_settings_device_name": MessageLookupByLibrary.simpleMessage("Name"),
    "main_settings_device_name_cancel": MessageLookupByLibrary.simpleMessage(
      "ABBRECHEN",
    ),
    "main_settings_device_name_hint": MessageLookupByLibrary.simpleMessage(
      "Name",
    ),
    "main_settings_device_name_save": MessageLookupByLibrary.simpleMessage(
      "SPEICHERN",
    ),
    "main_settings_device_name_title": MessageLookupByLibrary.simpleMessage(
      "Gerät umbenennen",
    ),
    "main_settings_language": MessageLookupByLibrary.simpleMessage("Sprache"),
    "main_settings_mirror_confirmation": MessageLookupByLibrary.simpleMessage(
      "Spiegelungsbestätigung",
    ),
    "main_settings_pin_visible": MessageLookupByLibrary.simpleMessage(
      "Verbindungsinformationen",
    ),
    "main_settings_share_to_sender": MessageLookupByLibrary.simpleMessage(
      "Bildschirm für Gerät freigeben",
    ),
    "main_settings_share_to_sender_limit_desc":
        MessageLookupByLibrary.simpleMessage(
          "Bildschirm für bis zu 10 Absender freigeben.",
        ),
    "main_settings_title": MessageLookupByLibrary.simpleMessage(
      "Einstellungen",
    ),
    "main_settings_whats_new": MessageLookupByLibrary.simpleMessage(
      "Was ist neu?",
    ),
    "main_split_screen_question": MessageLookupByLibrary.simpleMessage(
      "Klicken Sie auf den obigen Schalter für den Split-Screen-Modus. Bis zu 4 Teilnehmer können gleichzeitig präsentieren.",
    ),
    "main_split_screen_title": MessageLookupByLibrary.simpleMessage(
      "Geteilter Bildschirm",
    ),
    "main_split_screen_waiting": MessageLookupByLibrary.simpleMessage(
      "Geteilter Bildschirm aktiviert. Warten, bis der Moderator den Bildschirm freigibt...",
    ),
    "main_status_go_background": MessageLookupByLibrary.simpleMessage(
      "Die AirSync-App läuft im Hintergrund.",
    ),
    "main_status_no_network": MessageLookupByLibrary.simpleMessage(
      "Schlechte Netzwerkverbindung erkannt.\nBitte überprüfen Sie Ihre Konnektivität.",
    ),
    "main_status_remaining_time": MessageLookupByLibrary.simpleMessage(
      "%02d Min : %02d Sek",
    ),
    "main_thanks_content": MessageLookupByLibrary.simpleMessage(
      "Vielen Dank, dass Sie AirSync verwenden.",
    ),
    "main_wait_title": MessageLookupByLibrary.simpleMessage(
      "Warten, bis der Moderator den Bildschirm freigibt...",
    ),
    "main_wait_up_next": MessageLookupByLibrary.simpleMessage("ALS NÄCHSTES"),
    "main_webrtc_reconnect_fail_toast": MessageLookupByLibrary.simpleMessage(
      "Netzwerk (WebRTC) Wiederverbindung fehlgeschlagen",
    ),
    "main_webrtc_reconnect_success_toast": MessageLookupByLibrary.simpleMessage(
      "Netzwerk (WebRTC) Wiederverbindung erfolgreich",
    ),
    "main_webrtc_reconnecting_toast": MessageLookupByLibrary.simpleMessage(
      "Netzwerk (WebRTC) wird wieder verbunden",
    ),
    "main_whats_new_content": MessageLookupByLibrary.simpleMessage(
      "[Verbesserung]\n\n1. Alle numerischen Anzeigecodes für eine bessere Erfahrung.\n\n2. Verbesserte Verbindungsstabilität.\n\n3. Fehler behoben.\n",
    ),
    "main_whats_new_title": MessageLookupByLibrary.simpleMessage(
      "Was ist neu bei AirSync?",
    ),
    "moderator_activate_split_screen": MessageLookupByLibrary.simpleMessage(
      "Klicken Sie auf den obigen Schalter für den Split-Screen-Modus. Bis zu 4 Teilnehmer können gleichzeitig präsentieren.",
    ),
    "moderator_cancel": MessageLookupByLibrary.simpleMessage("ABBRECHEN"),
    "moderator_confirm": MessageLookupByLibrary.simpleMessage("Bestätigen"),
    "moderator_deactivate_split_screen": MessageLookupByLibrary.simpleMessage(
      "Sind Sie sicher, dass Sie diese Split-Screen-Sitzung beenden möchten? Alle aktuell freigegebenen Bildschirme werden beendet.",
    ),
    "moderator_exit": MessageLookupByLibrary.simpleMessage("BEENDEN"),
    "moderator_exit_dialog": MessageLookupByLibrary.simpleMessage(
      "Sind Sie sicher, dass Sie diese Moderatorsitzung beenden möchten? Alle Moderatoren werden entfernt.",
    ),
    "moderator_presentersLimit": MessageLookupByLibrary.simpleMessage(
      "Klicken Sie auf den obigen Schalter für den Moderator-Modus. Bis zu 6 Moderatoren können teilnehmen.",
    ),
    "moderator_presentersList": MessageLookupByLibrary.simpleMessage(
      "Moderatoren",
    ),
    "moderator_remove": MessageLookupByLibrary.simpleMessage("ENTFERNEN"),
    "moderator_verifyCode_fail": MessageLookupByLibrary.simpleMessage(
      "Etwas ist schief gelaufen. Bitte versuchen Sie es erneut.",
    ),
    "toast_maximum_split_screen": MessageLookupByLibrary.simpleMessage(
      "Maximale Anzahl an geteilten Bildschirmen erreicht.",
    ),
    "update_install_now": MessageLookupByLibrary.simpleMessage(
      "JETZT INSTALLIEREN",
    ),
    "update_message": MessageLookupByLibrary.simpleMessage(
      "Eine neue Version der Software ist verfügbar",
    ),
    "update_title": MessageLookupByLibrary.simpleMessage("AirSync-Update"),
    "v3_authorize_prompt_accept": MessageLookupByLibrary.simpleMessage(
      "Akzeptieren",
    ),
    "v3_authorize_prompt_accept_all": MessageLookupByLibrary.simpleMessage(
      "Alle akzeptieren",
    ),
    "v3_authorize_prompt_decline": MessageLookupByLibrary.simpleMessage(
      "Ablehnen",
    ),
    "v3_authorize_prompt_notification_cast": MessageLookupByLibrary.simpleMessage(
      "Deaktivieren Sie „Genehmigung erforderlich“ im Einstellungsmenü, um alle Casting-Anfragen zu akzeptieren.",
    ),
    "v3_authorize_prompt_notification_mirror": MessageLookupByLibrary.simpleMessage(
      "Aktivieren Sie „Automatisch akzeptieren“ im Einstellungsmenü, um alle Spiegelungsanfragen zu akzeptieren.",
    ),
    "v3_authorize_prompt_title_launcher": MessageLookupByLibrary.simpleMessage(
      "Teilnehmer möchten ihren Bildschirm freigeben",
    ),
    "v3_broadcast_cast_board_on": MessageLookupByLibrary.simpleMessage(
      "Übertragung läuft",
    ),
    "v3_broadcast_cast_device_on": MessageLookupByLibrary.simpleMessage(
      "Übertragung läuft",
    ),
    "v3_broadcast_indicator": MessageLookupByLibrary.simpleMessage("AN"),
    "v3_broadcast_multicast_checkbox": MessageLookupByLibrary.simpleMessage(
      "Auf 10-100 Geräte übertragen",
    ),
    "v3_broadcast_multicast_desc": MessageLookupByLibrary.simpleMessage(
      "Die Anzahl der empfangenden Geräte kann nach dem Start der Projektion nicht mehr geändert werden.",
    ),
    "v3_broadcast_multicast_warn": MessageLookupByLibrary.simpleMessage(
      "Unterbrechen Sie alle Projektionen, um sie zu bearbeiten.",
    ),
    "v3_cast_to_device_Receiving": MessageLookupByLibrary.simpleMessage(
      "Empfängt",
    ),
    "v3_cast_to_device_list_msg": MessageLookupByLibrary.simpleMessage(
      "Maximal bis zu 10 Geräte.",
    ),
    "v3_cast_to_device_menu_or": MessageLookupByLibrary.simpleMessage("Oder"),
    "v3_cast_to_device_menu_quick_connect1":
        MessageLookupByLibrary.simpleMessage("Schnellverbindung"),
    "v3_cast_to_device_menu_quick_connect2":
        MessageLookupByLibrary.simpleMessage("durch Scannen des QR-Codes"),
    "v3_cast_to_device_menu_title": MessageLookupByLibrary.simpleMessage(
      "Beitreten, um diesen Bildschirm zu empfangen",
    ),
    "v3_cast_to_device_reached_maximum": MessageLookupByLibrary.simpleMessage(
      "Sie haben das maximale Limit erreicht.",
    ),
    "v3_cast_to_device_title": MessageLookupByLibrary.simpleMessage(
      "Geräteliste",
    ),
    "v3_cast_to_device_touch_back": MessageLookupByLibrary.simpleMessage(
      "Touchback",
    ),
    "v3_cast_to_device_touch_back_disable":
        MessageLookupByLibrary.simpleMessage("Deaktivieren"),
    "v3_cast_to_device_touch_enabled": MessageLookupByLibrary.simpleMessage(
      "Touchback",
    ),
    "v3_casting_ended_toast": MessageLookupByLibrary.simpleMessage(
      "Die Bildschirmfreigabe wurde beendet.",
    ),
    "v3_casting_time_countdown": m0,
    "v3_casting_time_do_not_extend": MessageLookupByLibrary.simpleMessage(
      "Nicht verlängern",
    ),
    "v3_casting_time_extend": MessageLookupByLibrary.simpleMessage(
      "Verlängern",
    ),
    "v3_casting_time_extend_success_toast":
        MessageLookupByLibrary.simpleMessage("Um 3 Stunden verlängert."),
    "v3_download_app_desc": MessageLookupByLibrary.simpleMessage(
      "Scannen Sie den QR-Code mit Ihrem iOS- oder Android-Gerät zum Herunterladen",
    ),
    "v3_download_app_desktop": MessageLookupByLibrary.simpleMessage(
      "Für die beste Nutzererfahrung!",
    ),
    "v3_download_app_desktop_hint": MessageLookupByLibrary.simpleMessage(
      "*manuelle Installation",
    ),
    "v3_download_app_desktop_store": MessageLookupByLibrary.simpleMessage(
      "Installieren Sie MacOS über den App Store.",
    ),
    "v3_download_app_desktop_store_hint": MessageLookupByLibrary.simpleMessage(
      "*Nur für MacOS",
    ),
    "v3_download_app_desktop_title": MessageLookupByLibrary.simpleMessage(
      "Desktop",
    ),
    "v3_download_app_entry": MessageLookupByLibrary.simpleMessage(
      "Absender-App herunterladen",
    ),
    "v3_download_app_for_desktop": MessageLookupByLibrary.simpleMessage(
      "Für Desktop",
    ),
    "v3_download_app_for_desktop_desc": MessageLookupByLibrary.simpleMessage(
      "Geben Sie die folgende URL zum Herunterladen ein.",
    ),
    "v3_download_app_for_mobile": MessageLookupByLibrary.simpleMessage(
      "Für iOS & Android",
    ),
    "v3_download_app_for_mobile_desc": MessageLookupByLibrary.simpleMessage(
      "Scannen Sie den QR-Code für sofortigen Zugriff.",
    ),
    "v3_download_app_mobile_title": MessageLookupByLibrary.simpleMessage(
      "Mobil",
    ),
    "v3_download_app_or": MessageLookupByLibrary.simpleMessage("ODER"),
    "v3_download_app_title": MessageLookupByLibrary.simpleMessage(
      "Absender-App herunterladen",
    ),
    "v3_eula_agree": MessageLookupByLibrary.simpleMessage("Zustimmen"),
    "v3_eula_disagree": MessageLookupByLibrary.simpleMessage("Ablehnen"),
    "v3_eula_launch": MessageLookupByLibrary.simpleMessage("Starten"),
    "v3_eula_title": MessageLookupByLibrary.simpleMessage(
      "Endbenutzer-Lizenzvereinbarung",
    ),
    "v3_exit_moderator_mode_cancel": MessageLookupByLibrary.simpleMessage(
      "Abbrechen",
    ),
    "v3_exit_moderator_mode_desc": MessageLookupByLibrary.simpleMessage(
      "Sind Sie sicher? Dadurch werden alle Teilnehmer getrennt.",
    ),
    "v3_exit_moderator_mode_exit": MessageLookupByLibrary.simpleMessage(
      "Beenden",
    ),
    "v3_exit_moderator_mode_title": MessageLookupByLibrary.simpleMessage(
      "Moderator-Modus beenden",
    ),
    "v3_group_dialog_accept": MessageLookupByLibrary.simpleMessage(
      "Akzeptieren",
    ),
    "v3_group_dialog_decline": MessageLookupByLibrary.simpleMessage("Ablehnen"),
    "v3_group_dialog_message": MessageLookupByLibrary.simpleMessage(
      "%s hat eine Übertragungsanfrage an Ihr Gerät gesendet. Diese Aktion synchronisiert und zeigt den aktuellen Inhalt an. Möchten Sie diese Anfrage akzeptieren?",
    ),
    "v3_group_dialog_no_device_message": MessageLookupByLibrary.simpleMessage(
      "Kein Gerät ausgewählt.",
    ),
    "v3_group_dialog_title": MessageLookupByLibrary.simpleMessage(
      "Übertragungsanfrage von %s",
    ),
    "v3_group_receive_view_status_from": MessageLookupByLibrary.simpleMessage(
      "Übertragung von",
    ),
    "v3_group_receive_view_status_stop": MessageLookupByLibrary.simpleMessage(
      "Stopp",
    ),
    "v3_group_reject_invited": MessageLookupByLibrary.simpleMessage(
      "hat Ihre Übertragungsanfrage abgelehnt, bitte überprüfen Sie die Übertragungseinstellungen.",
    ),
    "v3_help_center_cast_device_title": MessageLookupByLibrary.simpleMessage(
      "Auf Gerät übertragen",
    ),
    "v3_help_center_cast_device_title_sub":
        MessageLookupByLibrary.simpleMessage(
          "IFP überträgt seinen Bildschirm auf Geräte.",
        ),
    "v3_help_center_close": MessageLookupByLibrary.simpleMessage("Schließen"),
    "v3_help_center_fullscreen_title": MessageLookupByLibrary.simpleMessage(
      "Vollbild",
    ),
    "v3_help_center_mute_user_title": MessageLookupByLibrary.simpleMessage(
      "Benutzer stummschalten",
    ),
    "v3_help_center_remove_user_title": MessageLookupByLibrary.simpleMessage(
      "Benutzer entfernen",
    ),
    "v3_help_center_share_title": MessageLookupByLibrary.simpleMessage(
      "Zum Teilen einladen",
    ),
    "v3_help_center_share_title_sub": MessageLookupByLibrary.simpleMessage(
      "Geräte, die ihren Bildschirm auf IFP teilen.",
    ),
    "v3_help_center_stop_share_title": MessageLookupByLibrary.simpleMessage(
      "Freigabe beenden",
    ),
    "v3_help_center_title": MessageLookupByLibrary.simpleMessage(
      "Hilfe-Center",
    ),
    "v3_help_center_touchback_title": MessageLookupByLibrary.simpleMessage(
      "Touchback",
    ),
    "v3_help_center_touchback_title_sub": MessageLookupByLibrary.simpleMessage(
      "Benutzerfernsteuerung zulassen.",
    ),
    "v3_help_center_untouchback_title": MessageLookupByLibrary.simpleMessage(
      "Untouchback",
    ),
    "v3_help_center_untouchback_title_sub":
        MessageLookupByLibrary.simpleMessage("Touchback-Modus trennen."),
    "v3_instruction1a": MessageLookupByLibrary.simpleMessage(
      "Besuchen Sie airsync.net oder öffnen Sie die Absender-App",
    ),
    "v3_instruction1b": MessageLookupByLibrary.simpleMessage(
      "Öffnen Sie die Absender-App",
    ),
    "v3_instruction2": MessageLookupByLibrary.simpleMessage(
      "Anzeigecode eingeben",
    ),
    "v3_instruction2_onethird": MessageLookupByLibrary.simpleMessage(
      "Code anzeigen",
    ),
    "v3_instruction3": MessageLookupByLibrary.simpleMessage(
      "Einmaliges Passwort eingeben",
    ),
    "v3_instruction3_onethird": MessageLookupByLibrary.simpleMessage(
      "Einmalpasswort",
    ),
    "v3_instruction_share_screen": MessageLookupByLibrary.simpleMessage(
      "Teilen Sie Ihre Bildschirme",
    ),
    "v3_instruction_support": MessageLookupByLibrary.simpleMessage(
      "Unterstützt die Freigabe über AirPlay, Google Cast oder Miracast",
    ),
    "v3_last_casting_time_countdown": MessageLookupByLibrary.simpleMessage(
      "Die Bildschirmfreigabe wird in Kürze beendet. Bitte starten Sie die Bildschirmfreigabe bei Bedarf neu.",
    ),
    "v3_lbl_authorize_prompt_accept": MessageLookupByLibrary.simpleMessage(
      "Anfrage annehmen",
    ),
    "v3_lbl_authorize_prompt_accept_all": MessageLookupByLibrary.simpleMessage(
      "Alle Anfragen akzeptieren",
    ),
    "v3_lbl_authorize_prompt_decline": MessageLookupByLibrary.simpleMessage(
      "Anfrage ablehnen",
    ),
    "v3_lbl_broadcast_multicast_checkbox": MessageLookupByLibrary.simpleMessage(
      "Auf 10-100 Geräte übertragen",
    ),
    "v3_lbl_cast_device_close": MessageLookupByLibrary.simpleMessage(
      "Übertragungsgeräteverbindung schließen",
    ),
    "v3_lbl_cast_device_next": MessageLookupByLibrary.simpleMessage(
      "Nächste Seite",
    ),
    "v3_lbl_cast_device_previous": MessageLookupByLibrary.simpleMessage(
      "Vorherige Seite",
    ),
    "v3_lbl_cast_device_sort_asc": MessageLookupByLibrary.simpleMessage(
      "Aufsteigend sortieren",
    ),
    "v3_lbl_cast_device_sort_desc": MessageLookupByLibrary.simpleMessage(
      "Absteigend sortieren",
    ),
    "v3_lbl_cast_device_touchback_disable":
        MessageLookupByLibrary.simpleMessage(
          "Touchback für Übertragungsgerät deaktivieren",
        ),
    "v3_lbl_cast_device_touchback_enable": MessageLookupByLibrary.simpleMessage(
      "Touchback für Übertragungsgerät aktivieren",
    ),
    "v3_lbl_close_download_app_menu": MessageLookupByLibrary.simpleMessage(
      "Download-Sender-App-Menü schließen",
    ),
    "v3_lbl_close_feature_set_cast_device":
        MessageLookupByLibrary.simpleMessage(
          "Geräteliste für Übertragung schließen",
        ),
    "v3_lbl_close_feature_set_moderator": MessageLookupByLibrary.simpleMessage(
      "Moderatorenliste schließen",
    ),
    "v3_lbl_close_help_center": MessageLookupByLibrary.simpleMessage(
      "Hilfecenter schließen",
    ),
    "v3_lbl_close_streaming_shortcut_menu":
        MessageLookupByLibrary.simpleMessage(
          "Streaming-Kontextmenü schließen\n",
        ),
    "v3_lbl_connection_dialog_close": MessageLookupByLibrary.simpleMessage(
      "Dialogfeld „Verbindungsstatus schließen“\n",
    ),
    "v3_lbl_eula_agree": MessageLookupByLibrary.simpleMessage("EULA zustimmen"),
    "v3_lbl_eula_disagree": MessageLookupByLibrary.simpleMessage(
      "Nicht mit der EULA einverstanden",
    ),
    "v3_lbl_eula_launch": MessageLookupByLibrary.simpleMessage("Starten"),
    "v3_lbl_exit_moderator_cancel": MessageLookupByLibrary.simpleMessage(
      "Moderatormodus verlassen abbrechen",
    ),
    "v3_lbl_exit_moderator_exit": MessageLookupByLibrary.simpleMessage(
      "Moderatormodus verlassen bestätigen",
    ),
    "v3_lbl_extend_casting_do_not_extend": MessageLookupByLibrary.simpleMessage(
      "Verlängere die Übertragungszeit nicht",
    ),
    "v3_lbl_extend_casting_extend": MessageLookupByLibrary.simpleMessage(
      "Übertragungszeit verlängern",
    ),
    "v3_lbl_group_reject_close": MessageLookupByLibrary.simpleMessage(
      "Gruppenablehnungsbenachrichtigung schließen",
    ),
    "v3_lbl_internet_connection_only_error": MessageLookupByLibrary.simpleMessage(
      "Verbindungsfehler, bitte überprüfen Sie die Netzwerkeinstellungen des Geräts.",
    ),
    "v3_lbl_internet_connection_warning": MessageLookupByLibrary.simpleMessage(
      "Nur lokale Verbindung",
    ),
    "v3_lbl_main_language_title": MessageLookupByLibrary.simpleMessage(
      "Sprache auswählen",
    ),
    "v3_lbl_main_language_title_item": MessageLookupByLibrary.simpleMessage(
      "%s auswählen",
    ),
    "v3_lbl_message_dialog_cancel": MessageLookupByLibrary.simpleMessage(
      "Dialog abbrechen",
    ),
    "v3_lbl_message_dialog_confirm": MessageLookupByLibrary.simpleMessage(
      "Dialog bestätigen",
    ),
    "v3_lbl_minimal_quick_connect_menu": MessageLookupByLibrary.simpleMessage(
      "Schnellverbindungsmenü minimieren",
    ),
    "v3_lbl_minimal_streaming_qrcode_menu":
        MessageLookupByLibrary.simpleMessage(
          "Minimieren Streaming QR-Code-Menü",
        ),
    "v3_lbl_moderator_toggle": MessageLookupByLibrary.simpleMessage(
      "Moderatormodus umschalten",
    ),
    "v3_lbl_open_download_app_menu": MessageLookupByLibrary.simpleMessage(
      "Menü der Download-Sender-App öffnen",
    ),
    "v3_lbl_open_feature_set_cast_device": MessageLookupByLibrary.simpleMessage(
      "Geräteliste für Übertragung öffnen",
    ),
    "v3_lbl_open_feature_set_moderator": MessageLookupByLibrary.simpleMessage(
      "Moderatorenliste öffnen",
    ),
    "v3_lbl_open_help_center": MessageLookupByLibrary.simpleMessage(
      "Hilfe-Center-Menü öffnen",
    ),
    "v3_lbl_open_menu_settings": MessageLookupByLibrary.simpleMessage(
      "Einstellungsmenü öffnen",
    ),
    "v3_lbl_open_streaming_qrcode_menu": MessageLookupByLibrary.simpleMessage(
      "Streaming-QR-Code-Menü öffnen",
    ),
    "v3_lbl_open_streaming_shortcut_menu": MessageLookupByLibrary.simpleMessage(
      "Kontextmenü für Streaming öffnen\n",
    ),
    "v3_lbl_overlay_bring_app_to_top": MessageLookupByLibrary.simpleMessage(
      "Schwebende Registerkarte mit Verbindungsinformationen",
    ),
    "v3_lbl_overlay_menu_expand": MessageLookupByLibrary.simpleMessage(
      "Overlay-Menü erweitern",
    ),
    "v3_lbl_overlay_menu_minimize": MessageLookupByLibrary.simpleMessage(
      "Overlay-Menü minimieren",
    ),
    "v3_lbl_participant_cast_device": MessageLookupByLibrary.simpleMessage(
      "Gerät an diesen Teilnehmer übertragen",
    ),
    "v3_lbl_participant_close": MessageLookupByLibrary.simpleMessage(
      "Teilnehmerverbindung schließen",
    ),
    "v3_lbl_participant_disconnect": MessageLookupByLibrary.simpleMessage(
      "Diesen Teilnehmer trennen",
    ),
    "v3_lbl_participant_mirror_close": MessageLookupByLibrary.simpleMessage(
      "Teilnehmerspiegelverbindung schließen",
    ),
    "v3_lbl_participant_mirror_share": MessageLookupByLibrary.simpleMessage(
      "An den Spiegel dieses Teilnehmers weiterleiten",
    ),
    "v3_lbl_participant_mirror_stop": MessageLookupByLibrary.simpleMessage(
      "Streaming des Spiegelteilnehmers stoppen",
    ),
    "v3_lbl_participant_share": MessageLookupByLibrary.simpleMessage(
      "Auf den Bildschirm dieses Teilnehmers übertragen",
    ),
    "v3_lbl_participant_stop": MessageLookupByLibrary.simpleMessage(
      "Streaming des Teilnehmers beenden",
    ),
    "v3_lbl_participant_touch_back": MessageLookupByLibrary.simpleMessage(
      "Touchback für diesen Teilnehmer aktivieren",
    ),
    "v3_lbl_participant_touch_back_disable":
        MessageLookupByLibrary.simpleMessage(
          "Touchback für diesen Teilnehmer deaktivieren",
        ),
    "v3_lbl_permission_exit": MessageLookupByLibrary.simpleMessage("Beenden"),
    "v3_lbl_resizable_expand": MessageLookupByLibrary.simpleMessage(
      "Präsentationssteuerung erweitern",
    ),
    "v3_lbl_resizable_minimize": MessageLookupByLibrary.simpleMessage(
      "Präsentationssteuerung minimieren",
    ),
    "v3_lbl_resizable_mute": MessageLookupByLibrary.simpleMessage(
      "Präsentation stummschalten",
    ),
    "v3_lbl_resizable_stop": MessageLookupByLibrary.simpleMessage(
      "Präsentation stoppen",
    ),
    "v3_lbl_settings_accessibility": MessageLookupByLibrary.simpleMessage(
      "Barrierefreiheit",
    ),
    "v3_lbl_settings_back_icon": MessageLookupByLibrary.simpleMessage(
      "Zur vorherigen Seite zurückkehren",
    ),
    "v3_lbl_settings_broadcast": MessageLookupByLibrary.simpleMessage(
      "Broadcast-Einstellungsmenü öffnen",
    ),
    "v3_lbl_settings_broadcast_boards": MessageLookupByLibrary.simpleMessage(
      "Broadcast-Boards-Menü öffnen",
    ),
    "v3_lbl_settings_broadcast_connect": MessageLookupByLibrary.simpleMessage(
      "Verbinden",
    ),
    "v3_lbl_settings_broadcast_connecting":
        MessageLookupByLibrary.simpleMessage("Verbinden wird hergestellt"),
    "v3_lbl_settings_broadcast_device_favorite":
        MessageLookupByLibrary.simpleMessage("Favorit"),
    "v3_lbl_settings_broadcast_device_remove":
        MessageLookupByLibrary.simpleMessage("Gerät entfernen"),
    "v3_lbl_settings_broadcast_devices": MessageLookupByLibrary.simpleMessage(
      "Broadcast-Geräte-Menü öffnen",
    ),
    "v3_lbl_settings_broadcast_ip_hint": MessageLookupByLibrary.simpleMessage(
      "Boards über IP finden",
    ),
    "v3_lbl_settings_broadcast_to_display_group":
        MessageLookupByLibrary.simpleMessage(
          "Broadcast-zu-Anzeigegruppen-Menü öffnen",
        ),
    "v3_lbl_settings_broadcast_to_display_group_cast":
        MessageLookupByLibrary.simpleMessage("Übertragen"),
    "v3_lbl_settings_broadcast_to_display_group_checkbox":
        MessageLookupByLibrary.simpleMessage("%s auswählen"),
    "v3_lbl_settings_broadcast_to_display_group_confirm":
        MessageLookupByLibrary.simpleMessage(
          "Bestätigen Sie, dass kein Gerät ausgewählt ist.",
        ),
    "v3_lbl_settings_broadcast_to_display_group_item":
        MessageLookupByLibrary.simpleMessage("%s auswählen"),
    "v3_lbl_settings_broadcast_to_display_group_save":
        MessageLookupByLibrary.simpleMessage("Speichern"),
    "v3_lbl_settings_broadcast_to_display_group_type":
        MessageLookupByLibrary.simpleMessage("%s auswählen"),
    "v3_lbl_settings_close_icon": MessageLookupByLibrary.simpleMessage(
      "Einstellungen-Menü schließen",
    ),
    "v3_lbl_settings_connectivity": MessageLookupByLibrary.simpleMessage(
      "Menü für Konnektivitätseinstellungen öffnen",
    ),
    "v3_lbl_settings_connectivity_item": MessageLookupByLibrary.simpleMessage(
      "%s auswählen",
    ),
    "v3_lbl_settings_device_authorize_mode":
        MessageLookupByLibrary.simpleMessage(
          "Autorisierungsmodus ein- / ausschalten",
        ),
    "v3_lbl_settings_device_auto_fill_otp":
        MessageLookupByLibrary.simpleMessage(
          "Auto-Fill-OTP-Modus ein- / ausschalten",
        ),
    "v3_lbl_settings_device_high_image_quality":
        MessageLookupByLibrary.simpleMessage("Hohe Bildqualität"),
    "v3_lbl_settings_device_launch_on_startup":
        MessageLookupByLibrary.simpleMessage(
          "Auto-Startmodus ein- / ausschalten",
        ),
    "v3_lbl_settings_device_name": MessageLookupByLibrary.simpleMessage(
      "Gerätenamen ändern",
    ),
    "v3_lbl_settings_device_name_close": MessageLookupByLibrary.simpleMessage(
      "Gerätenamen-Einstellung schließen",
    ),
    "v3_lbl_settings_device_name_save": MessageLookupByLibrary.simpleMessage(
      "Gerätenamen speichern",
    ),
    "v3_lbl_settings_device_setting": MessageLookupByLibrary.simpleMessage(
      "Geräteeinstellungsmenü öffnen",
    ),
    "v3_lbl_settings_device_smart_scaling":
        MessageLookupByLibrary.simpleMessage(
          "Smart Scaling-Umschalter ein- / ausschalten",
        ),
    "v3_lbl_settings_enter_device_name": MessageLookupByLibrary.simpleMessage(
      "Gerätenamen eingeben",
    ),
    "v3_lbl_settings_invite_group": MessageLookupByLibrary.simpleMessage(
      "Dropdown-Menü für Bildschirmübertragung öffnen",
    ),
    "v3_lbl_settings_invite_group_item": MessageLookupByLibrary.simpleMessage(
      "%s auswählen",
    ),
    "v3_lbl_settings_ip_add": MessageLookupByLibrary.simpleMessage(
      "IP hinzufügen",
    ),
    "v3_lbl_settings_ip_clear": MessageLookupByLibrary.simpleMessage("löschen"),
    "v3_lbl_settings_knowledge_base": MessageLookupByLibrary.simpleMessage(
      "Wissensdatenbank",
    ),
    "v3_lbl_settings_legal_policy": MessageLookupByLibrary.simpleMessage(
      "Menü für die Einstellung der Rechtsgrundlage öffnen",
    ),
    "v3_lbl_settings_menu_locked": MessageLookupByLibrary.simpleMessage(
      "Einstellungsmenü ist gesperrt",
    ),
    "v3_lbl_settings_mirroring_auto_accept":
        MessageLookupByLibrary.simpleMessage(
          "Automatische Annahme aktivieren / deaktivieren",
        ),
    "v3_lbl_settings_mirroring_require_passcode":
        MessageLookupByLibrary.simpleMessage(
          "Passcode aktivieren / deaktivieren",
        ),
    "v3_lbl_settings_moderator_mode": MessageLookupByLibrary.simpleMessage(
      "Moderator-Modus ein/ausschalten",
    ),
    "v3_lbl_settings_only_when_casting_info":
        MessageLookupByLibrary.simpleMessage(
          "Weitere Informationen zum Senden an eine Anzeigegruppe",
        ),
    "v3_lbl_settings_open_source_license": MessageLookupByLibrary.simpleMessage(
      "%s auswählen",
    ),
    "v3_lbl_settings_show_display_code": MessageLookupByLibrary.simpleMessage(
      "Displaycode-Umschalter ein- / ausschalten",
    ),
    "v3_lbl_settings_whats_new": MessageLookupByLibrary.simpleMessage(
      "\"Was gibt´s neues?\" Menü öffnen",
    ),
    "v3_lbl_settings_whats_new_icon": MessageLookupByLibrary.simpleMessage(
      "Symbol „Neuigkeiten“",
    ),
    "v3_lbl_shortcuts_airplay": MessageLookupByLibrary.simpleMessage(
      "AirPlay ein- / ausschalten",
    ),
    "v3_lbl_shortcuts_google_cast": MessageLookupByLibrary.simpleMessage(
      "Google Cast ein- / ausschalten",
    ),
    "v3_lbl_shortcuts_miracast": MessageLookupByLibrary.simpleMessage(
      "Miracast ein- / ausschalten",
    ),
    "v3_lbl_shortcuts_mirroring": MessageLookupByLibrary.simpleMessage(
      "Menü für Bildschirmsynchronisierung öffnen",
    ),
    "v3_lbl_streaming_airplay_touchback": MessageLookupByLibrary.simpleMessage(
      "Airplay-Touchback",
    ),
    "v3_lbl_streaming_page_control": MessageLookupByLibrary.simpleMessage(
      "Nächste Seite",
    ),
    "v3_lbl_streaming_shortcut_airplay_toggle":
        MessageLookupByLibrary.simpleMessage("AirPlay-Umschalter"),
    "v3_lbl_streaming_shortcut_cast_device_toggle":
        MessageLookupByLibrary.simpleMessage(
          "Auf Geräte übertragen umschalten",
        ),
    "v3_lbl_streaming_shortcut_expand": MessageLookupByLibrary.simpleMessage(
      "Streaming-Funktionen erweitern",
    ),
    "v3_lbl_streaming_shortcut_google_cast_toggle":
        MessageLookupByLibrary.simpleMessage("Google Cast umschalten"),
    "v3_lbl_streaming_shortcut_menu_locked":
        MessageLookupByLibrary.simpleMessage(
          "Das Kontextmenü für Streaming ist gesperrt.",
        ),
    "v3_lbl_streaming_shortcut_minimize": MessageLookupByLibrary.simpleMessage(
      "Streaming-Funktionen ausblenden",
    ),
    "v3_lbl_streaming_shortcut_miracast_toggle":
        MessageLookupByLibrary.simpleMessage("Miracast-Umschaltung"),
    "v3_lbl_streaming_shortcut_move": MessageLookupByLibrary.simpleMessage(
      "Bewegen",
    ),
    "v3_lbl_streaming_view_expand": MessageLookupByLibrary.simpleMessage(
      "Streaming-Ansicht erweitern",
    ),
    "v3_lbl_streaming_view_function_expand":
        MessageLookupByLibrary.simpleMessage("Streaming-Funktion erweitern"),
    "v3_lbl_streaming_view_function_minimize":
        MessageLookupByLibrary.simpleMessage("Streaming-Funktion einblenden"),
    "v3_lbl_streaming_view_minimize": MessageLookupByLibrary.simpleMessage(
      "Streaming-Ansicht ausblenden",
    ),
    "v3_lbl_streaming_view_mute": MessageLookupByLibrary.simpleMessage(
      "Ton stummschalten",
    ),
    "v3_lbl_streaming_view_stop": MessageLookupByLibrary.simpleMessage(
      "Streaming beenden",
    ),
    "v3_lbl_streaming_view_unmute": MessageLookupByLibrary.simpleMessage(
      "Unmute audio",
    ),
    "v3_lbl_touchback_one_device_cancel": MessageLookupByLibrary.simpleMessage(
      "Dialogfeld abbrechen",
    ),
    "v3_lbl_touchback_one_device_confirm": MessageLookupByLibrary.simpleMessage(
      "Dialogfeld bestätigen",
    ),
    "v3_lbl_touchback_restart_bluetooth_btn_cancel":
        MessageLookupByLibrary.simpleMessage("Abbrechen"),
    "v3_lbl_touchback_restart_bluetooth_btn_restart":
        MessageLookupByLibrary.simpleMessage("Neustart"),
    "v3_main_connection_dialog_close": MessageLookupByLibrary.simpleMessage(
      "Schließen",
    ),
    "v3_main_internet_connection_only": MessageLookupByLibrary.simpleMessage(
      "Nur Internetverbindung",
    ),
    "v3_main_internet_connection_only_error": MessageLookupByLibrary.simpleMessage(
      "Verbindungsfehler, bitte überprüfen Sie die Netzwerkeinstellungen des Geräts.",
    ),
    "v3_main_internet_connection_only_error_dialog_desc":
        MessageLookupByLibrary.simpleMessage(
          "Verbindungsfehler, bitte überprüfen Sie die Netzwerkeinstellungen des Geräts.",
        ),
    "v3_main_local_connection_only_dialog_desc":
        MessageLookupByLibrary.simpleMessage(
          "Nur LAN-Verbindung, bitte überprüfen Sie die Netzwerkeinstellungen des Geräts.",
        ),
    "v3_main_status_no_network": MessageLookupByLibrary.simpleMessage(
      "Es konnte keine Internetverbindung erkannt werden. Bitte verbinden Sie sich mit einem WLAN- oder Intranet-Netzwerk und versuchen Sie es erneut.",
    ),
    "v3_miracast_not_support": MessageLookupByLibrary.simpleMessage(
      "Miracast ist jetzt nicht verfügbar. Der aktuelle WLAN-Kanal unterstützt keine Bildschirmübertragung.",
    ),
    "v3_miracast_uibc_not_supported_message":
        MessageLookupByLibrary.simpleMessage(
          "Diese Quelle unterstützt kein Miracast-Touchback",
        ),
    "v3_mirror_request_passcode": MessageLookupByLibrary.simpleMessage(
      "Passcode",
    ),
    "v3_moderator_disable_mirror_cancel": MessageLookupByLibrary.simpleMessage(
      "Abbrechen",
    ),
    "v3_moderator_disable_mirror_desc": MessageLookupByLibrary.simpleMessage(
      "Die Spiegelung wird im Moderator-Modus deaktiviert",
    ),
    "v3_moderator_disable_mirror_ok": MessageLookupByLibrary.simpleMessage(
      "OK",
    ),
    "v3_moderator_disable_mirror_title": MessageLookupByLibrary.simpleMessage(
      "Spiegelung für den Moderator-Modus deaktivieren",
    ),
    "v3_moderator_mode": MessageLookupByLibrary.simpleMessage(
      "Moderator-Modus",
    ),
    "v3_new_sharing_join_session": MessageLookupByLibrary.simpleMessage(
      " ist der Sitzung beigetreten",
    ),
    "v3_participant_item_casting": MessageLookupByLibrary.simpleMessage(
      "Übertragung läuft",
    ),
    "v3_participant_item_connected": MessageLookupByLibrary.simpleMessage(
      "Verbunden",
    ),
    "v3_participant_item_controlling": MessageLookupByLibrary.simpleMessage(
      "Empfangen + Touchback",
    ),
    "v3_participant_item_receiving": MessageLookupByLibrary.simpleMessage(
      "Empfängt",
    ),
    "v3_participant_item_share": MessageLookupByLibrary.simpleMessage("Teilen"),
    "v3_participant_item_waiting": MessageLookupByLibrary.simpleMessage(
      "Warten...",
    ),
    "v3_participants_desc": MessageLookupByLibrary.simpleMessage(
      "Maximal bis zu 6 Teilnehmer.",
    ),
    "v3_participants_desc_maximum_9": MessageLookupByLibrary.simpleMessage(
      "Maximal bis zu 9 Teilnehmer.",
    ),
    "v3_participants_title": MessageLookupByLibrary.simpleMessage("Teilnehmer"),
    "v3_permission_description": MessageLookupByLibrary.simpleMessage(
      "Bitte gehen Sie zu \"Einstellungen\" des Geräts und dann zum \"App\"-Menü, um die Erlaubnis zu erteilen.",
    ),
    "v3_permission_exit": MessageLookupByLibrary.simpleMessage("Beenden"),
    "v3_permission_title": MessageLookupByLibrary.simpleMessage(
      "Erlaubnis erforderlich",
    ),
    "v3_qrcode_quick_connect": MessageLookupByLibrary.simpleMessage(
      "Schnellverbindung",
    ),
    "v3_quick_connect_menu_bottom_msg": MessageLookupByLibrary.simpleMessage(
      "Der geteilte Bildschirm wird aktiviert, wenn zwei oder mehr Benutzer Bildschirme freigeben.",
    ),
    "v3_quick_connect_menu_display_code": MessageLookupByLibrary.simpleMessage(
      "Anzeigecode",
    ),
    "v3_quick_connect_menu_qrcode": MessageLookupByLibrary.simpleMessage(
      "QR-Code",
    ),
    "v3_recording_stopped_dialog_msg": MessageLookupByLibrary.simpleMessage(
      "Bitte starten Sie die Übertragungssitzung bei Bedarf neu.",
    ),
    "v3_recording_stopped_dialog_title": MessageLookupByLibrary.simpleMessage(
      "Bildschirmaufnahme wurde gestoppt",
    ),
    "v3_setting_passcode_cancel": MessageLookupByLibrary.simpleMessage(
      "Abbrechen",
    ),
    "v3_setting_passcode_clear": MessageLookupByLibrary.simpleMessage(
      "Löschen",
    ),
    "v3_setting_passcode_confirm": MessageLookupByLibrary.simpleMessage(
      "Bestätigen",
    ),
    "v3_setting_passcode_error_description":
        MessageLookupByLibrary.simpleMessage(
          "Ungültiges Passwort, bitte versuchen Sie es erneut.",
        ),
    "v3_setting_passcode_title": MessageLookupByLibrary.simpleMessage(
      "Passcode eingeben, um Einstellungen zu entsperren",
    ),
    "v3_settings_accessibility": MessageLookupByLibrary.simpleMessage(
      "Barrierefreiheit",
    ),
    "v3_settings_all_the_time_info": MessageLookupByLibrary.simpleMessage(
      "Quell-IFP-Bildschirm die ganze Zeit übertragen.",
    ),
    "v3_settings_broadcast": MessageLookupByLibrary.simpleMessage(
      "Übertragung",
    ),
    "v3_settings_broadcast_boards": MessageLookupByLibrary.simpleMessage(
      "Andere AirSync-Geräte",
    ),
    "v3_settings_broadcast_cast_boards": MessageLookupByLibrary.simpleMessage(
      "Auf Tafeln übertragen",
    ),
    "v3_settings_broadcast_cast_boards_desc": MessageLookupByLibrary.simpleMessage(
      "Geben Sie diesen Bildschirm für alle interaktiven Flachbildschirme (IFPs) im Netzwerk frei.",
    ),
    "v3_settings_broadcast_cast_to": MessageLookupByLibrary.simpleMessage(
      "Übertragen an",
    ),
    "v3_settings_broadcast_devices": MessageLookupByLibrary.simpleMessage(
      "Absendergeräte",
    ),
    "v3_settings_broadcast_ip": MessageLookupByLibrary.simpleMessage(
      "Boards über IP finden",
    ),
    "v3_settings_broadcast_ip_hint": MessageLookupByLibrary.simpleMessage(
      "IP-Adresse eingeben",
    ),
    "v3_settings_broadcast_not_find": MessageLookupByLibrary.simpleMessage(
      "nicht gefunden",
    ),
    "v3_settings_broadcast_screen_energy_saving":
        MessageLookupByLibrary.simpleMessage(
          "Bitte schalten Sie den Energiesparmodus aus, um unerwartete Unterbrechungen während der Übertragung zu vermeiden.",
        ),
    "v3_settings_broadcast_to_display_group":
        MessageLookupByLibrary.simpleMessage("An die Anzeigegruppe übertragen"),
    "v3_settings_connectivity": MessageLookupByLibrary.simpleMessage(
      "Konnektivität",
    ),
    "v3_settings_connectivity_both": MessageLookupByLibrary.simpleMessage(
      "Sowohl Internet- als auch lokale Verbindung",
    ),
    "v3_settings_connectivity_internet": MessageLookupByLibrary.simpleMessage(
      "Internetverbindung",
    ),
    "v3_settings_connectivity_internet_desc":
        MessageLookupByLibrary.simpleMessage(
          "Die Internetverbindung erfordert ein stabiles Netzwerk.",
        ),
    "v3_settings_connectivity_local": MessageLookupByLibrary.simpleMessage(
      "Lokale Verbindung",
    ),
    "v3_settings_connectivity_local_desc": MessageLookupByLibrary.simpleMessage(
      "Lokale Verbindungen arbeiten in einem privaten Netzwerk und bieten mehr Sicherheit und Stabilität.",
    ),
    "v3_settings_device_authorize_mode": MessageLookupByLibrary.simpleMessage(
      "Genehmigung für alle Bildschirmfreigabeanfragen verlangen.",
    ),
    "v3_settings_device_auto_fill_otp": MessageLookupByLibrary.simpleMessage(
      "Einmaliges Passwort automatisch ausfüllen",
    ),
    "v3_settings_device_auto_fill_otp_desc": MessageLookupByLibrary.simpleMessage(
      "Aktivieren Sie die Ein-Klick-Verbindung, wenn dieses Gerät im Schnellverbindungsmenü der Absender-App ausgewählt ist.",
    ),
    "v3_settings_device_high_image_quality":
        MessageLookupByLibrary.simpleMessage("Hohe Bildqualität"),
    "v3_settings_device_high_image_quality_off_desc":
        MessageLookupByLibrary.simpleMessage(
          "Maximale QHD (2K) Bildschirmfreigabe, abhängig von der Bildschirmauflösung des Absenders.",
        ),
    "v3_settings_device_high_image_quality_on_desc":
        MessageLookupByLibrary.simpleMessage(
          "Maximale UHD (4K) Bildschirmfreigabe vom Web-Absender und 3K+ vom Windows- und macOS-Absender, abhängig von der Bildschirmauflösung des Absenders. Erfordert ein hochwertiges Netzwerk.",
        ),
    "v3_settings_device_launch_on_startup":
        MessageLookupByLibrary.simpleMessage("AirSync beim Start starten"),
    "v3_settings_device_name": MessageLookupByLibrary.simpleMessage(
      "Gerätename",
    ),
    "v3_settings_device_name_empty_error": MessageLookupByLibrary.simpleMessage(
      "Der Gerätename darf nicht leer sein",
    ),
    "v3_settings_device_name_save": MessageLookupByLibrary.simpleMessage(
      "Speichern",
    ),
    "v3_settings_device_not_supported": MessageLookupByLibrary.simpleMessage(
      "Die Geräteversion wird nicht unterstützt",
    ),
    "v3_settings_device_setting": MessageLookupByLibrary.simpleMessage(
      "Geräteeinstellung",
    ),
    "v3_settings_device_show_display_code":
        MessageLookupByLibrary.simpleMessage("Anzeigecode oben anzeigen"),
    "v3_settings_device_show_display_code_desc":
        MessageLookupByLibrary.simpleMessage(
          "Halten Sie den Code oben auf dem Bildschirm sichtbar, auch wenn Sie zu anderen Apps wechseln und die Bildschirmfreigabe aktiv ist.",
        ),
    "v3_settings_device_smart_scaling": MessageLookupByLibrary.simpleMessage(
      "Smart Scaling",
    ),
    "v3_settings_device_smart_scaling_desc": MessageLookupByLibrary.simpleMessage(
      "Passen Sie die Bildschirmgröße automatisch an, um den Bildschirmplatz optimal zu nutzen. Das Bild kann leicht verzerrt sein.",
    ),
    "v3_settings_device_unavailable": MessageLookupByLibrary.simpleMessage(
      "Nicht verfügbar",
    ),
    "v3_settings_display_group": MessageLookupByLibrary.simpleMessage(
      "Anzeigegruppe",
    ),
    "v3_settings_display_group_all_the_time":
        MessageLookupByLibrary.simpleMessage("Die ganze Zeit"),
    "v3_settings_display_group_cast": MessageLookupByLibrary.simpleMessage(
      "Übertragung",
    ),
    "v3_settings_display_group_only_casting":
        MessageLookupByLibrary.simpleMessage("Nur bei Übertragung"),
    "v3_settings_feature_locked": MessageLookupByLibrary.simpleMessage(
      "Durch ViewSonic Manager gesperrt.",
    ),
    "v3_settings_invite_group": MessageLookupByLibrary.simpleMessage(
      "Wenn zu einer Anzeigegruppe eingeladen",
    ),
    "v3_settings_invite_group_auto_accept":
        MessageLookupByLibrary.simpleMessage("Automatisch akzeptieren"),
    "v3_settings_invite_group_ignore": MessageLookupByLibrary.simpleMessage(
      "Ignorieren",
    ),
    "v3_settings_invite_group_notify_me": MessageLookupByLibrary.simpleMessage(
      "Mich benachrichtigen",
    ),
    "v3_settings_knowledge_base": MessageLookupByLibrary.simpleMessage(
      "Wissensdatenbank",
    ),
    "v3_settings_legal_policy": MessageLookupByLibrary.simpleMessage(
      "Rechtliches und Richtlinien",
    ),
    "v3_settings_local_connection_only": MessageLookupByLibrary.simpleMessage(
      "Nur lokale Verbindung",
    ),
    "v3_settings_mirroring_auto_accept": MessageLookupByLibrary.simpleMessage(
      "Automatisch akzeptieren",
    ),
    "v3_settings_mirroring_auto_accept_desc": MessageLookupByLibrary.simpleMessage(
      "Aktivieren Sie die Spiegelung sofort, ohne dass eine Genehmigung durch den Moderator erforderlich ist.",
    ),
    "v3_settings_mirroring_blocked": MessageLookupByLibrary.simpleMessage(
      "Schalten Sie zuerst den Moderator-Modus aus.",
    ),
    "v3_settings_mirroring_require_passcode":
        MessageLookupByLibrary.simpleMessage("Passcode erforderlich"),
    "v3_settings_moderator_mode": MessageLookupByLibrary.simpleMessage(
      "Moderator-Modus",
    ),
    "v3_settings_only_when_casting_info": MessageLookupByLibrary.simpleMessage(
      "Übertragen Sie den Quell-IFP-Bildschirm nur, wenn er einen freigegebenen Bildschirm empfängt.",
    ),
    "v3_settings_open_source_license": MessageLookupByLibrary.simpleMessage(
      "Open-Source-Lizenzen",
    ),
    "v3_settings_privacy_policy": MessageLookupByLibrary.simpleMessage(
      "Datenschutzrichtlinie",
    ),
    "v3_settings_privacy_policy_description": MessageLookupByLibrary.simpleMessage(
      "ViewSonic verpflichtet sich, Ihre Privatsphäre zu schützen und behandelt den Umgang mit personenbezogenen Daten mit großer Sorgfalt. Die nachstehende Datenschutzrichtlinie erläutert, wie ViewSonic Ihre personenbezogenen Daten behandelt, nachdem sie von ViewSonic durch Ihre Nutzung der Website erfasst wurden. ViewSonic wahrt die Vertraulichkeit Ihrer Daten durch den Einsatz von Sicherheitstechnologien und hält sich an Richtlinien, die eine unbefugte Nutzung Ihrer personenbezogenen Daten verhindern. Durch die Nutzung dieser Website erklären Sie sich mit der Erfassung und Nutzung Ihrer Daten einverstanden.\n\nWebsites, auf die Sie von ViewSonic.com aus verlinken, haben möglicherweise eigene Datenschutzrichtlinien, die von denen von ViewSonic abweichen können. Bitte lesen Sie die Datenschutzrichtlinien dieser Websites, um detaillierte Informationen darüber zu erhalten, wie sie die während Ihres Besuchs erfassten Daten verwenden können.\n\nBitte klicken Sie auf die folgenden Links, um mehr über unsere Datenschutzrichtlinie zu erfahren.",
    ),
    "v3_settings_resize_text_size": MessageLookupByLibrary.simpleMessage(
      "Textgröße ändern",
    ),
    "v3_settings_resize_text_size_extra_large":
        MessageLookupByLibrary.simpleMessage("XLarge"),
    "v3_settings_resize_text_size_large": MessageLookupByLibrary.simpleMessage(
      "Groß",
    ),
    "v3_settings_resize_text_size_normal": MessageLookupByLibrary.simpleMessage(
      "Normal",
    ),
    "v3_settings_version": m1,
    "v3_settings_whats_new": MessageLookupByLibrary.simpleMessage(
      "Was ist neu",
    ),
    "v3_settings_whats_new_content": MessageLookupByLibrary.simpleMessage(
      "AirSync %s\n\nAirSync ist eine ViewSonic-ösung zur drahtlosen Bildschirmfreigabe. Wenn sie mit dem AirSync-Sender verwendet wird, ermöglicht sie eine nahtlose Bildschirmfreigabe vom Gerät eines Benutzers zu den interaktiven Displays von ViewSonic.\n\nNeue Funktionen in dieser Version:\n\n1. Der Moderatormodus unterstützt jetzt Mirroring.\n\n2. Integration mit ViewSonic Manager durch Manager-Fernsteuerung.\n\n3. PWA-Sender für Chromebooks zur Bildschirmfreigabe im Internet.\n\n4. Unterstützung für 9 Bildschirme-Splitscreen bei ausgewählten Modellen.\n\n5. Unterstützung von Bildschirmerweiterung mit Touchback.\n\n6. Verbesserte Stabilität.\n\n7. Behobene Bugs.",
    ),
    "v3_shortcuts_airplay": MessageLookupByLibrary.simpleMessage("AirPlay"),
    "v3_shortcuts_cast_device": MessageLookupByLibrary.simpleMessage(
      "Auf Geräte übertragen",
    ),
    "v3_shortcuts_cast_device_desc": MessageLookupByLibrary.simpleMessage(
      "Übertragen Sie diesen Bildschirm gleichzeitig auf mehrere Geräte, einschließlich Laptops, Tablets und Mobilgeräte.",
    ),
    "v3_shortcuts_google_cast": MessageLookupByLibrary.simpleMessage(
      "Google Cast",
    ),
    "v3_shortcuts_menu_title": MessageLookupByLibrary.simpleMessage(
      "Verknüpfungen",
    ),
    "v3_shortcuts_miracast": MessageLookupByLibrary.simpleMessage("Miracast"),
    "v3_shortcuts_mirroring": MessageLookupByLibrary.simpleMessage(
      "Spiegelung",
    ),
    "v3_touchback_alert_message": MessageLookupByLibrary.simpleMessage(
      "Sie können jeweils nur ein Gerät per Touchback verbinden.",
    ),
    "v3_touchback_alert_title": MessageLookupByLibrary.simpleMessage(
      "Touchback zu %s?",
    ),
    "v3_touchback_disable_message": MessageLookupByLibrary.simpleMessage(
      "TouchBack ist deaktiviert.",
    ),
    "v3_touchback_fail_message": MessageLookupByLibrary.simpleMessage(
      "Kopplung fehlgeschlagen. TouchBack ist nicht aktiviert. Bitte versuchen Sie es erneut.",
    ),
    "v3_touchback_restart_bluetooth_btn_cancel":
        MessageLookupByLibrary.simpleMessage("Abbrechen"),
    "v3_touchback_restart_bluetooth_btn_restart":
        MessageLookupByLibrary.simpleMessage("Neustart"),
    "v3_touchback_restart_bluetooth_message": MessageLookupByLibrary.simpleMessage(
      "Zeitüberschreitung der Operation. Bitte schalten Sie die Bluetooth-Funktion auf dem großen Bildschirm aus und starten Sie sie neu. Starten Sie dann den Touchback neu.",
    ),
    "v3_touchback_restart_bluetooth_title": MessageLookupByLibrary.simpleMessage(
      "Zeitüberschreitung bei der Operation, bitte starten Sie Bluetooth neu",
    ),
    "v3_touchback_state_deviceFinding_message":
        MessageLookupByLibrary.simpleMessage("Gerätesuche"),
    "v3_touchback_state_deviceFoundSuccess_message":
        MessageLookupByLibrary.simpleMessage("Gerät erfolgreich gefunden"),
    "v3_touchback_state_devicePairedSuccess_message":
        MessageLookupByLibrary.simpleMessage("Gerät erfolgreich gekoppelt"),
    "v3_touchback_state_devicePairing_message":
        MessageLookupByLibrary.simpleMessage("Gerätekopplung"),
    "v3_touchback_state_hidConnected_message":
        MessageLookupByLibrary.simpleMessage("Hid verbunden"),
    "v3_touchback_state_hidConnecting_message":
        MessageLookupByLibrary.simpleMessage("Hid verbindet"),
    "v3_touchback_state_hidProfileServiceStartedSuccess_message":
        MessageLookupByLibrary.simpleMessage(
          "Hid-Profil-Dienst wurde erfolgreich gestartet",
        ),
    "v3_touchback_state_hidProfileServiceStarting_message":
        MessageLookupByLibrary.simpleMessage(
          "Hid-Profil-Dienst wird gestartet",
        ),
    "v3_touchback_state_initialized_message":
        MessageLookupByLibrary.simpleMessage("Initialisiert"),
    "v3_touchback_state_initializing_message":
        MessageLookupByLibrary.simpleMessage("Initialisierung"),
    "v3_touchback_success_message": MessageLookupByLibrary.simpleMessage(
      "Sie können %s jetzt per Fernzugriff vom IFP aus steuern.",
    ),
    "v3_waiting_desc": MessageLookupByLibrary.simpleMessage(
      "Warten, bis dieser Teilnehmer seinen Bildschirm freigibt",
    ),
    "v3_waiting_join": MessageLookupByLibrary.simpleMessage(
      "Warten, bis andere beitreten",
    ),
    "v3_waiting_up_next": MessageLookupByLibrary.simpleMessage("Als nächstes"),
    "v3_zero_fps_capture_failed_message": MessageLookupByLibrary.simpleMessage(
      "Derzeit kann kein Screenshot von der Quell-App abgerufen werden. Ein Erfassungsfehler könnte aufgetreten sein. Bitte kehren Sie zur Quell-App zurück, um einen neuen Screenshot zu erstellen und versuchen Sie es erneut.",
    ),
    "v3_zero_fps_capture_failed_title": MessageLookupByLibrary.simpleMessage(
      "Screenshot-Erfassung fehlgeschlagen",
    ),
    "v3_zero_fps_close": MessageLookupByLibrary.simpleMessage("Schließen"),
    "v3_zero_fps_failed_to_repair_message": MessageLookupByLibrary.simpleMessage(
      "Der Screenshot-Mechanismus in der Quell-App konnte nicht neu gestartet werden.",
    ),
    "v3_zero_fps_failed_to_repair_title": MessageLookupByLibrary.simpleMessage(
      "Screenshot-Funktion konnte nicht repariert werden",
    ),
    "v3_zero_fps_prompt_message": MessageLookupByLibrary.simpleMessage(
      "Der Bildschirm konnte nicht erfasst und an die Projektions-App gesendet werden. Möchten Sie die Screenshot-Funktion neu starten und es erneut versuchen oder die Projektion beenden?",
    ),
    "v3_zero_fps_prompt_title": MessageLookupByLibrary.simpleMessage(
      "Erfolgreich neu gestartet",
    ),
    "v3_zero_fps_repairing_message": MessageLookupByLibrary.simpleMessage(
      "Der Screenshot-Mechanismus in der Quell-App wird neu gestartet. Dies kann einige Sekunden dauern. Bitte warten.",
    ),
    "v3_zero_fps_repairing_title": MessageLookupByLibrary.simpleMessage(
      "Screenshot-Funktion wird repariert",
    ),
    "v3_zero_fps_restart_failed": MessageLookupByLibrary.simpleMessage(
      "Neustart fehlgeschlagen",
    ),
    "v3_zero_fps_restarted_Successfully": MessageLookupByLibrary.simpleMessage(
      "Erfolgreich neu gestartet",
    ),
    "v3_zero_fps_restarting_content": MessageLookupByLibrary.simpleMessage(
      "Bitte warten.",
    ),
    "v3_zero_fps_restarting_title": MessageLookupByLibrary.simpleMessage(
      "Neustart",
    ),
    "vbs_ota_progress_msg": MessageLookupByLibrary.simpleMessage(
      "Systemupdates werden heruntergeladen",
    ),
  };
}
