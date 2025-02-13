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
      "Bitte wählen Sie einen Bildschirm aus, um ihn innerhalb von ${value} Sekunden zu teilen...";

  static String m1(year) =>
      "Copyright © ViewSonic Corporation ${year}. Alle Rechte vorbehalten.";

  static String m2(year, version) => "AirSync ©${year}. Version ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "device_list_enter_pin":
            MessageLookupByLibrary.simpleMessage("Einmaliges Passwort"),
        "device_list_enter_pin_ok": MessageLookupByLibrary.simpleMessage("OK"),
        "main_connect_network_error": MessageLookupByLibrary.simpleMessage(
            "Netzwerkfehler. Bitte überprüfen Sie die Netzwerkverbindung und versuchen Sie es erneut."),
        "main_connect_rate_limited": MessageLookupByLibrary.simpleMessage(
            "Die AirSync-Instanz ist beschäftigt. Bitte versuchen Sie es später erneut."),
        "main_connect_unknown_error":
            MessageLookupByLibrary.simpleMessage("Unbekannter Fehler."),
        "main_connection_mode_unsupported":
            MessageLookupByLibrary.simpleMessage(
                "AirSync kann keine Verbindung zum Internet herstellen."),
        "main_device_list":
            MessageLookupByLibrary.simpleMessage("Schnellverbindung"),
        "main_display_code":
            MessageLookupByLibrary.simpleMessage("Anzeigecode"),
        "main_display_code_description": MessageLookupByLibrary.simpleMessage(
            "Bitte geben Sie den Anzeigecode ein"),
        "main_display_code_error": MessageLookupByLibrary.simpleMessage(
            "Akzeptiert nur Buchstaben und Zahlen."),
        "main_display_code_exceed": MessageLookupByLibrary.simpleMessage(
            "Maximale Teilnehmerzahl (6) erreicht."),
        "main_display_code_exceed_split_screen":
            MessageLookupByLibrary.simpleMessage(
                "Maximale Anzahl von Präsentatoren (4) erreicht."),
        "main_display_code_invalid":
            MessageLookupByLibrary.simpleMessage("Ungültiger Anzeigecode"),
        "main_feature_reconnect_fail_toast":
            MessageLookupByLibrary.simpleMessage(
                "Netzwerk (Steuerung) Wiederverbindung fehlgeschlagen"),
        "main_feature_reconnect_success_toast":
            MessageLookupByLibrary.simpleMessage(
                "Netzwerk (Steuerung) Wiederverbindung erfolgreich"),
        "main_feature_reconnecting_toast": MessageLookupByLibrary.simpleMessage(
            "Netzwerk (Steuerung) verbindet sich wieder"),
        "main_instance_not_found_or_offline":
            MessageLookupByLibrary.simpleMessage(
                "Anzeigecode nicht gefunden oder Instanz ist offline."),
        "main_language": MessageLookupByLibrary.simpleMessage("Sprache"),
        "main_language_name": MessageLookupByLibrary.simpleMessage("Deutsch"),
        "main_notice_not_support_description": MessageLookupByLibrary.simpleMessage(
            "Die Freigabe über den Browser wird auf mobilen Geräten nicht unterstützt. Bitte laden Sie die AirSync-Sender-App herunter und verwenden Sie sie für eine bessere Erfahrung."),
        "main_notice_positive_button": MessageLookupByLibrary.simpleMessage(
            "AirSync-Sender-App herunterladen."),
        "main_notice_title": MessageLookupByLibrary.simpleMessage("Hinweis"),
        "main_otp_error":
            MessageLookupByLibrary.simpleMessage("Akzeptiert nur Zahlen."),
        "main_password": MessageLookupByLibrary.simpleMessage("Passwort"),
        "main_password_description": MessageLookupByLibrary.simpleMessage(
            "Bitte geben Sie ein Einmalpasswort ein"),
        "main_password_invalid":
            MessageLookupByLibrary.simpleMessage("Ungültiges Passwort."),
        "main_present": MessageLookupByLibrary.simpleMessage("Präsentieren"),
        "main_setting": MessageLookupByLibrary.simpleMessage("Einstellungen"),
        "main_touch_back": MessageLookupByLibrary.simpleMessage("Touchback"),
        "main_update_deny_button":
            MessageLookupByLibrary.simpleMessage("Nicht jetzt"),
        "main_update_description_android": MessageLookupByLibrary.simpleMessage(
            "Bitte klicken Sie auf \"Aktualisieren\", um die neue Version zu installieren."),
        "main_update_description_apple": MessageLookupByLibrary.simpleMessage(
            "Bitte klicken Sie auf \"Aktualisieren\", um die neue Version zu installieren."),
        "main_update_description_windows": MessageLookupByLibrary.simpleMessage(
            "Bitte klicken Sie auf \"Aktualisieren\", um die neue Version zu installieren."),
        "main_update_error_detail":
            MessageLookupByLibrary.simpleMessage("Beschreibung: "),
        "main_update_error_title": MessageLookupByLibrary.simpleMessage(
            "Fehler bei der Versionsaktualisierung"),
        "main_update_error_type":
            MessageLookupByLibrary.simpleMessage("Fehlerursache: "),
        "main_update_positive_button":
            MessageLookupByLibrary.simpleMessage("Aktualisieren"),
        "main_update_title":
            MessageLookupByLibrary.simpleMessage("Neue Version verfügbar"),
        "main_webrtc_reconnect_fail_toast":
            MessageLookupByLibrary.simpleMessage(
                "Netzwerk (WebRTC) Wiederverbindung fehlgeschlagen"),
        "main_webrtc_reconnect_success_toast":
            MessageLookupByLibrary.simpleMessage(
                "Netzwerk (WebRTC) Wiederverbindung erfolgreich"),
        "main_webrtc_reconnecting_toast": MessageLookupByLibrary.simpleMessage(
            "Netzwerk (WebRTC) verbindet sich wieder"),
        "moderator": MessageLookupByLibrary.simpleMessage("Moderator"),
        "moderator_back": MessageLookupByLibrary.simpleMessage("Zurück"),
        "moderator_exit": MessageLookupByLibrary.simpleMessage("Beenden"),
        "moderator_fill_out":
            MessageLookupByLibrary.simpleMessage("Pflichtfeld"),
        "moderator_name": MessageLookupByLibrary.simpleMessage("Name"),
        "moderator_wait": MessageLookupByLibrary.simpleMessage(
            "Bitte warten Sie, während der Moderator Präsentatoren auswählt..."),
        "present_role_cast_screen":
            MessageLookupByLibrary.simpleMessage("Bildschirm teilen"),
        "present_role_receive":
            MessageLookupByLibrary.simpleMessage("Bildschirm empfangen"),
        "present_select_screen_cancel":
            MessageLookupByLibrary.simpleMessage("Abbrechen"),
        "present_select_screen_description": MessageLookupByLibrary.simpleMessage(
            "Wählen Sie eine Ansicht, um sie mit dem empfangenden Bildschirm zu teilen."),
        "present_select_screen_entire":
            MessageLookupByLibrary.simpleMessage("Gesamter Bildschirm"),
        "present_select_screen_ios_restart":
            MessageLookupByLibrary.simpleMessage("Übertragung starten"),
        "present_select_screen_ios_restart_description":
            MessageLookupByLibrary.simpleMessage(
                "Klicken Sie auf \"Übertragung starten\", um die Freigabe vor dem Timeout fortzusetzen, oder klicken Sie auf \"Zurück\", um zum Startbildschirm zurückzukehren."),
        "present_select_screen_share":
            MessageLookupByLibrary.simpleMessage("Teilen"),
        "present_select_screen_share_audio":
            MessageLookupByLibrary.simpleMessage("Bildschirm-Audio teilen"),
        "present_select_screen_window":
            MessageLookupByLibrary.simpleMessage("Fenster"),
        "present_state_high_quality_description":
            MessageLookupByLibrary.simpleMessage(
                "Aktivieren Sie hohe Qualität bei guten Netzwerkbedingungen."),
        "present_state_high_quality_title":
            MessageLookupByLibrary.simpleMessage("Hohe Qualität"),
        "present_state_pause": MessageLookupByLibrary.simpleMessage("Pause"),
        "present_state_resume":
            MessageLookupByLibrary.simpleMessage("Fortsetzen"),
        "present_state_stop":
            MessageLookupByLibrary.simpleMessage("Präsentation beenden"),
        "present_time": MessageLookupByLibrary.simpleMessage("Vergangene Zeit"),
        "present_time_unit_hour": MessageLookupByLibrary.simpleMessage("Std"),
        "present_time_unit_min": MessageLookupByLibrary.simpleMessage("Min"),
        "present_time_unit_sec": MessageLookupByLibrary.simpleMessage("Sek"),
        "present_wait": m0,
        "remote_screen_connect_error": MessageLookupByLibrary.simpleMessage(
            "Fehler bei der Verbindung zum Remote-Bildschirm"),
        "remote_screen_wait": MessageLookupByLibrary.simpleMessage(
            "Die Freigabe wird verarbeitet. Bitte warten Sie."),
        "settings_audio_configuration":
            MessageLookupByLibrary.simpleMessage("Audiokonfiguration"),
        "settings_knowledge_base":
            MessageLookupByLibrary.simpleMessage("Wissensdatenbank"),
        "toast_enable_remote_screen": MessageLookupByLibrary.simpleMessage(
            "Bitte aktivieren Sie die Bildschirmfreigabe für das Gerät in AirSync."),
        "toast_install_audio_driver": MessageLookupByLibrary.simpleMessage(
            "Bitte installieren Sie den virtuellen Audiotreiber."),
        "toast_maximum_moderated": MessageLookupByLibrary.simpleMessage(
            "Die maximale Anzahl moderierter Sitzungen wurde erreicht."),
        "toast_maximum_remote_screen": MessageLookupByLibrary.simpleMessage(
            "Die maximale Anzahl von freigegebenen Bildschirmen wurde erreicht."),
        "toast_maximum_split_screen": MessageLookupByLibrary.simpleMessage(
            "Die maximale Anzahl von geteilten Bildschirmen wurde erreicht."),
        "v3_device_list_button_device_list":
            MessageLookupByLibrary.simpleMessage("Geräteliste"),
        "v3_device_list_button_text":
            MessageLookupByLibrary.simpleMessage("Schnellverbindung durch"),
        "v3_device_list_dialog_connect":
            MessageLookupByLibrary.simpleMessage("Verbinden"),
        "v3_device_list_dialog_invalid_otp":
            MessageLookupByLibrary.simpleMessage("Falsches Einmal-Passwort"),
        "v3_device_list_dialog_title": MessageLookupByLibrary.simpleMessage(
            "Einmaliges Passwort eingeben"),
        "v3_eula_agree": MessageLookupByLibrary.simpleMessage("Zustimmen"),
        "v3_eula_disagree": MessageLookupByLibrary.simpleMessage("Ablehnen"),
        "v3_eula_title": MessageLookupByLibrary.simpleMessage(
            "Endbenutzer-Lizenzvereinbarung"),
        "v3_main_accessibility":
            MessageLookupByLibrary.simpleMessage("Barrierefreiheit"),
        "v3_main_authorize_wait": MessageLookupByLibrary.simpleMessage(
            "Bitte warten Sie, bis der Gastgeber Ihre Anfrage genehmigt hat."),
        "v3_main_connect_network_error":
            MessageLookupByLibrary.simpleMessage("Netzwerkverbindungsfehler."),
        "v3_main_connect_rate_limited": MessageLookupByLibrary.simpleMessage(
            "Die AirSync-Instanz ist beschäftigt. Bitte versuchen Sie es später erneut."),
        "v3_main_connect_unknown_error":
            MessageLookupByLibrary.simpleMessage("Unbekannter Fehler."),
        "v3_main_connection_mode_unsupported":
            MessageLookupByLibrary.simpleMessage(
                "AirSync stellt keine Verbindung zum Internet her."),
        "v3_main_copy_rights": m1,
        "v3_main_display_code":
            MessageLookupByLibrary.simpleMessage("Anzeigecode"),
        "v3_main_display_code_error":
            MessageLookupByLibrary.simpleMessage("Akzeptiert nur Zahlen."),
        "v3_main_display_code_invalid":
            MessageLookupByLibrary.simpleMessage("Ungültiger Anzeigecode"),
        "v3_main_download":
            MessageLookupByLibrary.simpleMessage("Sender-App herunterladen"),
        "v3_main_download_action_download":
            MessageLookupByLibrary.simpleMessage("Herunterladen"),
        "v3_main_download_action_get":
            MessageLookupByLibrary.simpleMessage("Holen"),
        "v3_main_download_app_dialog_desc": MessageLookupByLibrary.simpleMessage(
            "Scannen Sie den QR-Code mit Ihrem iOS- oder Android-Gerät zum Herunterladen"),
        "v3_main_download_app_dialog_title":
            MessageLookupByLibrary.simpleMessage("Sender-App herunterladen"),
        "v3_main_download_app_subtitle":
            MessageLookupByLibrary.simpleMessage("iOS und Android"),
        "v3_main_download_app_title":
            MessageLookupByLibrary.simpleMessage("AirSync App"),
        "v3_main_download_desc": MessageLookupByLibrary.simpleMessage(
            "Mühelose Bildschirmfreigabe mit Ein-Klick-Verbindung."),
        "v3_main_download_mac_subtitle":
            MessageLookupByLibrary.simpleMessage("macOS 10.15+"),
        "v3_main_download_mac_title":
            MessageLookupByLibrary.simpleMessage("Mac"),
        "v3_main_download_title": MessageLookupByLibrary.simpleMessage(
            "Holen Sie sich Ihre AirSync-Sender-App"),
        "v3_main_download_win_subtitle":
            MessageLookupByLibrary.simpleMessage("Win 10 (1709+)/ Win 11"),
        "v3_main_download_win_title":
            MessageLookupByLibrary.simpleMessage("Windows"),
        "v3_main_instance_not_found_or_offline":
            MessageLookupByLibrary.simpleMessage(
                "Anzeigecode nicht gefunden oder Instanz ist offline."),
        "v3_main_moderator_action":
            MessageLookupByLibrary.simpleMessage("Teilen"),
        "v3_main_moderator_app_subtitle": MessageLookupByLibrary.simpleMessage(
            "Geben Sie Ihren Namen ein, bevor Sie Ihren Bildschirm teilen"),
        "v3_main_moderator_app_title":
            MessageLookupByLibrary.simpleMessage("Teilen"),
        "v3_main_moderator_disconnect":
            MessageLookupByLibrary.simpleMessage("Verbindung trennen"),
        "v3_main_moderator_input_hint":
            MessageLookupByLibrary.simpleMessage("Geben Sie Ihren Namen ein"),
        "v3_main_moderator_input_limit": MessageLookupByLibrary.simpleMessage(
            "Bitte beschränken Sie den Namen auf 20 Zeichen."),
        "v3_main_moderator_subtitle": MessageLookupByLibrary.simpleMessage(
            "Geben Sie Ihren Präsentationstitel ein"),
        "v3_main_moderator_title":
            MessageLookupByLibrary.simpleMessage("Teilen Sie Ihren Bildschirm"),
        "v3_main_moderator_wait": MessageLookupByLibrary.simpleMessage(
            "Warten Sie, bis der Moderator Sie zum Teilen einlädt"),
        "v3_main_otp_error":
            MessageLookupByLibrary.simpleMessage("Akzeptiert nur Zahlen."),
        "v3_main_password": MessageLookupByLibrary.simpleMessage("Passwort"),
        "v3_main_password_invalid":
            MessageLookupByLibrary.simpleMessage("Ungültiges Passwort."),
        "v3_main_present_action":
            MessageLookupByLibrary.simpleMessage("Weiter"),
        "v3_main_present_subtitle": MessageLookupByLibrary.simpleMessage(
            "Folgen Sie den Schritten, um zu beginnen."),
        "v3_main_present_title":
            MessageLookupByLibrary.simpleMessage("Teilen Sie Ihren Bildschirm"),
        "v3_main_presenting_message": MessageLookupByLibrary.simpleMessage(
            "airsync.net teilt Ihren Bildschirm."),
        "v3_main_privacy":
            MessageLookupByLibrary.simpleMessage("Datenschutzrichtlinie"),
        "v3_main_receive_app_action":
            MessageLookupByLibrary.simpleMessage("Verbinden"),
        "v3_main_receive_app_receive_from":
            MessageLookupByLibrary.simpleMessage("Empfangen von %s"),
        "v3_main_receive_app_stop":
            MessageLookupByLibrary.simpleMessage("Stopp"),
        "v3_main_receive_app_subtitle": MessageLookupByLibrary.simpleMessage(
            "Bildschirm auf mein Gerät teilen"),
        "v3_main_receive_app_title":
            MessageLookupByLibrary.simpleMessage("Empfangen"),
        "v3_main_select_role_receive":
            MessageLookupByLibrary.simpleMessage("Empfangen"),
        "v3_main_select_role_share":
            MessageLookupByLibrary.simpleMessage("Teilen"),
        "v3_main_select_role_title": MessageLookupByLibrary.simpleMessage(
            "Wählen Sie Ihren Präsentationsmodus"),
        "v3_main_terms":
            MessageLookupByLibrary.simpleMessage("Nutzungsbedingungen"),
        "v3_main_web_nonsupport": MessageLookupByLibrary.simpleMessage(
            "Derzeit werden nur die Browser Chrome und Edge unterstützt."),
        "v3_main_web_nonsupport_confirm":
            MessageLookupByLibrary.simpleMessage("Verstanden!"),
        "v3_present_end_information": MessageLookupByLibrary.simpleMessage(
            "Bildschirmfreigabe wurde beendet.\nGesamte Freigabezeit %s."),
        "v3_present_moderator_exited":
            MessageLookupByLibrary.simpleMessage("Moderator ist geschlossen"),
        "v3_present_moderator_exited_action":
            MessageLookupByLibrary.simpleMessage("OK"),
        "v3_present_moderator_exited_description":
            MessageLookupByLibrary.simpleMessage(
                "Der Moderator ist geschlossen, bitte verbinden Sie sich erneut."),
        "v3_present_options_menu_he_subtitle": MessageLookupByLibrary.simpleMessage(
            "Verwenden Sie die Grafikkarte des Geräts, um den Stream zu codieren."),
        "v3_present_options_menu_he_title":
            MessageLookupByLibrary.simpleMessage("Hardware-Codierung"),
        "v3_present_options_menu_hq_subtitle":
            MessageLookupByLibrary.simpleMessage(
                "Verwenden Sie eine höhere Bitrate, um den Stream zu übertragen."),
        "v3_present_options_menu_hq_title":
            MessageLookupByLibrary.simpleMessage("Hohe Qualität"),
        "v3_present_screen_full":
            MessageLookupByLibrary.simpleMessage("Bildschirm voll"),
        "v3_present_screen_full_action":
            MessageLookupByLibrary.simpleMessage("OK"),
        "v3_present_screen_full_description":
            MessageLookupByLibrary.simpleMessage(
                "Die maximale Anzahl von geteilten Bildschirmen wurde erreicht."),
        "v3_present_select_screen_extension":
            MessageLookupByLibrary.simpleMessage("Bildschirmerweiterung"),
        "v3_present_select_screen_extension_desc":
            MessageLookupByLibrary.simpleMessage(
                "Erweitern Sie Ihren Arbeitsbereich"),
        "v3_present_select_screen_extension_desc2":
            MessageLookupByLibrary.simpleMessage(
                "Dies ermöglicht Ihnen, Inhalte zwischen Ihrem persönlichen Gerät und dem IFP zu ziehen, was die Echtzeit-Interaktion und -Steuerung verbessert."),
        "v3_present_select_screen_share_audio":
            MessageLookupByLibrary.simpleMessage("Computeraudio teilen."),
        "v3_present_select_screen_subtitle": MessageLookupByLibrary.simpleMessage(
            "%s möchte Ihren Bildschirm teilen. Wählen Sie aus, was Sie teilen möchten."),
        "v3_present_session_full":
            MessageLookupByLibrary.simpleMessage("Sitzung voll"),
        "v3_present_session_full_action":
            MessageLookupByLibrary.simpleMessage("OK"),
        "v3_present_session_full_description": MessageLookupByLibrary.simpleMessage(
            "Beitritt nicht möglich. Die Sitzung hat ihre maximale Teilnehmerzahl erreicht."),
        "v3_present_touch_back_allow":
            MessageLookupByLibrary.simpleMessage("Touchback zulassen"),
        "v3_receiver_remote_screen_busy_action":
            MessageLookupByLibrary.simpleMessage("OK"),
        "v3_receiver_remote_screen_busy_description":
            MessageLookupByLibrary.simpleMessage(
                "Der Bildschirm wird auf andere Bildschirme übertragen. Bitte versuchen Sie es später erneut."),
        "v3_receiver_remote_screen_busy_title":
            MessageLookupByLibrary.simpleMessage(
                "Der Bildschirm wird übertragen"),
        "v3_scan_qr_reminder": MessageLookupByLibrary.simpleMessage(
            "Schnellverbindung durch Scannen des QR-Codes"),
        "v3_select_screen_ios_countdown":
            MessageLookupByLibrary.simpleMessage("Verbleibende Zeit"),
        "v3_select_screen_ios_start_sharing":
            MessageLookupByLibrary.simpleMessage("Freigabe starten"),
        "v3_setting_app_version": m2,
        "v3_setting_check_update":
            MessageLookupByLibrary.simpleMessage("Nach Updates suchen"),
        "v3_setting_knowledge_base":
            MessageLookupByLibrary.simpleMessage("Wissensdatenbank"),
        "v3_setting_language": MessageLookupByLibrary.simpleMessage("Sprache"),
        "v3_setting_legal_policy":
            MessageLookupByLibrary.simpleMessage("Rechtliches und Datenschutz"),
        "v3_setting_open_source_license":
            MessageLookupByLibrary.simpleMessage("Open-Source-Lizenzen"),
        "v3_setting_privacy_policy":
            MessageLookupByLibrary.simpleMessage("Datenschutzrichtlinie"),
        "v3_setting_privacy_policy_description":
            MessageLookupByLibrary.simpleMessage(
                "ViewSonic verpflichtet sich, Ihre Privatsphäre zu schützen und behandelt die Handhabung personenbezogener Daten mit Ernsthaftigkeit. Die folgende Datenschutzrichtlinie erläutert, wie ViewSonic Ihre personenbezogenen Daten behandelt, nachdem sie von ViewSonic durch Ihre Nutzung der Website erfasst wurden. ViewSonic wahrt die Vertraulichkeit Ihrer Informationen durch den Einsatz von Sicherheitstechnologien und hält sich an Richtlinien, die eine unbefugte Nutzung Ihrer personenbezogenen Daten verhindern. Durch die Nutzung dieser Website stimmen Sie der Erfassung und Nutzung Ihrer Daten zu.\\n\\nWebsites, auf die Sie von ViewSonic.com aus verlinken, haben möglicherweise eigene Datenschutzrichtlinien, die von denen von ViewSonic abweichen können. Bitte lesen Sie die Datenschutzrichtlinien dieser Websites, um detaillierte Informationen darüber zu erhalten, wie sie Informationen verwenden, die gesammelt werden, während Sie sie besuchen.\n\nBitte klicken Sie auf die folgenden Links, um mehr über unsere Datenschutzrichtlinie zu erfahren."),
        "v3_setting_software_update":
            MessageLookupByLibrary.simpleMessage("Software-Aktualisierung"),
        "v3_setting_software_update_deny_action":
            MessageLookupByLibrary.simpleMessage("Später"),
        "v3_setting_software_update_description":
            MessageLookupByLibrary.simpleMessage(
                "Eine neue Version ist jetzt verfügbar. Möchten Sie jetzt aktualisieren?"),
        "v3_setting_software_update_force_action":
            MessageLookupByLibrary.simpleMessage("Jetzt aktualisieren"),
        "v3_setting_software_update_force_description":
            MessageLookupByLibrary.simpleMessage(
                "Eine neue Version ist jetzt verfügbar."),
        "v3_setting_software_update_no_available":
            MessageLookupByLibrary.simpleMessage("Kein Update verfügbar"),
        "v3_setting_software_update_no_available_action":
            MessageLookupByLibrary.simpleMessage("Ok"),
        "v3_setting_software_update_no_available_description":
            MessageLookupByLibrary.simpleMessage(
                "AirSync ist bereits auf dem neuesten Stand."),
        "v3_setting_software_update_no_internet_description":
            MessageLookupByLibrary.simpleMessage(
                "Bitte überprüfen Sie Ihre Internetverbindung und versuchen Sie es erneut."),
        "v3_setting_software_update_no_internet_tittle":
            MessageLookupByLibrary.simpleMessage("Keine Internetverbindung"),
        "v3_setting_software_update_positive_action":
            MessageLookupByLibrary.simpleMessage("Aktualisieren"),
        "v3_setting_title":
            MessageLookupByLibrary.simpleMessage("Einstellungen")
      };
}
