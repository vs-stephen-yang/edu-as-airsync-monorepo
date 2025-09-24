// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a no locale. All the
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
  String get localeName => 'no';

  static String m0(value) =>
      "Skjermdeling er i ferd med å avsluttes. Vil du forlenge den med 3 timer? Du kan forlenge opptil ${value} ganger.";

  static String m1(year, version) => "AirSync ©${year}. version ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "eula_agree": MessageLookupByLibrary.simpleMessage("Jeg er enig"),
    "eula_disagree": MessageLookupByLibrary.simpleMessage("Jeg er uenig"),
    "eula_title": MessageLookupByLibrary.simpleMessage("AirSync EULA"),
    "main_airplay_pin_code": MessageLookupByLibrary.simpleMessage(
      "AirPlay-kode",
    ),
    "main_auto_startup": MessageLookupByLibrary.simpleMessage(
      "Start AirSync ved oppstart",
    ),
    "main_cast_settings_airplay": MessageLookupByLibrary.simpleMessage(
      "AirPlay",
    ),
    "main_cast_settings_device_name": MessageLookupByLibrary.simpleMessage(
      "Navn",
    ),
    "main_cast_settings_google_cast": MessageLookupByLibrary.simpleMessage(
      "Google Cast",
    ),
    "main_cast_settings_miracast": MessageLookupByLibrary.simpleMessage(
      "Miracast",
    ),
    "main_cast_settings_title": MessageLookupByLibrary.simpleMessage(
      "Casting-innstillinger",
    ),
    "main_content_display_code": MessageLookupByLibrary.simpleMessage(
      "Skjermkode",
    ),
    "main_content_lan_only": MessageLookupByLibrary.simpleMessage(
      "Kun LAN-tilkobling",
    ),
    "main_content_one_time_password": MessageLookupByLibrary.simpleMessage(
      "Engangspassord",
    ),
    "main_content_one_time_password_get_fail": MessageLookupByLibrary.simpleMessage(
      "Kunne ikke oppdatere passordet.\nVennligst vent i 30 sekunder før du prøver igjen.",
    ),
    "main_feature_no_network_warning": MessageLookupByLibrary.simpleMessage(
      "Kontrolltilkobling er frakoblet. Vennligst koble til igjen.",
    ),
    "main_feature_reconnect_fail_toast": MessageLookupByLibrary.simpleMessage(
      "Nettverk (Kontroll) tilkobling feilet",
    ),
    "main_feature_reconnect_success_toast":
        MessageLookupByLibrary.simpleMessage(
          "Nettverk (Kontroll) tilkobling vellykket",
        ),
    "main_feature_reconnecting_toast": MessageLookupByLibrary.simpleMessage(
      "Nettverk (Kontroll) kobler til igjen",
    ),
    "main_get_display_code_failure": MessageLookupByLibrary.simpleMessage(
      "Kunne ikke hente skjermkode. Vent til nettverkstilkoblingen er gjenopprettet, eller start appen på nytt.",
    ),
    "main_language_name": MessageLookupByLibrary.simpleMessage("Engelsk"),
    "main_language_title": MessageLookupByLibrary.simpleMessage("Språk"),
    "main_limit_time_message": MessageLookupByLibrary.simpleMessage(
      "5 minutter igjen",
    ),
    "main_mirror_from_client": MessageLookupByLibrary.simpleMessage(
      "%s ønsker å dele skjermen sin.",
    ),
    "main_mirror_prompt_accept": MessageLookupByLibrary.simpleMessage("Godta"),
    "main_mirror_prompt_cancel": MessageLookupByLibrary.simpleMessage("Avbryt"),
    "main_register_display_code_failure": MessageLookupByLibrary.simpleMessage(
      "Kunne ikke hente skjermkode og engangspassord. Dette kan skyldes et nettverks- eller serverproblem. Vennligst prøv igjen senere når tilkoblingen er gjenopprettet.",
    ),
    "main_settings_airplay_code": MessageLookupByLibrary.simpleMessage(
      "AirPlay-kode",
    ),
    "main_settings_device_list": MessageLookupByLibrary.simpleMessage(
      "Hurtigkoblingspassord",
    ),
    "main_settings_device_name": MessageLookupByLibrary.simpleMessage("Navn"),
    "main_settings_device_name_cancel": MessageLookupByLibrary.simpleMessage(
      "AVBRYT",
    ),
    "main_settings_device_name_hint": MessageLookupByLibrary.simpleMessage(
      "Navn",
    ),
    "main_settings_device_name_save": MessageLookupByLibrary.simpleMessage(
      "LAGRE",
    ),
    "main_settings_device_name_title": MessageLookupByLibrary.simpleMessage(
      "Gi nytt navn til enheten",
    ),
    "main_settings_language": MessageLookupByLibrary.simpleMessage("Språk"),
    "main_settings_mirror_confirmation": MessageLookupByLibrary.simpleMessage(
      "Speilingsbekreftelse",
    ),
    "main_settings_pin_visible": MessageLookupByLibrary.simpleMessage(
      "Tilkoblingsinformasjon",
    ),
    "main_settings_share_to_sender": MessageLookupByLibrary.simpleMessage(
      "Del skjerm til enhet",
    ),
    "main_settings_share_to_sender_limit_desc":
        MessageLookupByLibrary.simpleMessage(
          "Del skjerm med opptil 10 sendere.",
        ),
    "main_settings_title": MessageLookupByLibrary.simpleMessage(
      "Innstillinger",
    ),
    "main_settings_whats_new": MessageLookupByLibrary.simpleMessage(
      "Hva er nytt?",
    ),
    "main_split_screen_question": MessageLookupByLibrary.simpleMessage(
      "Klikk på bryteren over for delt skjerm-modus. Opptil 4 deltakere kan presentere samtidig.",
    ),
    "main_split_screen_title": MessageLookupByLibrary.simpleMessage(
      "Delt skjerm",
    ),
    "main_split_screen_waiting": MessageLookupByLibrary.simpleMessage(
      "Delt skjerm aktivert. Venter på at presentatøren skal dele skjermen...",
    ),
    "main_status_go_background": MessageLookupByLibrary.simpleMessage(
      "AirSync-appen kjører i bakgrunnen.",
    ),
    "main_status_no_network": MessageLookupByLibrary.simpleMessage(
      "Dårlig nettverkstilkobling oppdaget.\nVennligst sjekk tilkoblingen din.",
    ),
    "main_status_remaining_time": MessageLookupByLibrary.simpleMessage(
      "%02d min : %02d sek",
    ),
    "main_thanks_content": MessageLookupByLibrary.simpleMessage(
      "Takk for at du bruker AirSync.",
    ),
    "main_wait_title": MessageLookupByLibrary.simpleMessage(
      "Venter på at presentatøren skal dele skjermen...",
    ),
    "main_wait_up_next": MessageLookupByLibrary.simpleMessage("OPP NESTE"),
    "main_webrtc_reconnect_fail_toast": MessageLookupByLibrary.simpleMessage(
      "Nettverk (WebRTC) tilkobling feilet",
    ),
    "main_webrtc_reconnect_success_toast": MessageLookupByLibrary.simpleMessage(
      "Nettverk (WebRTC) tilkobling vellykket",
    ),
    "main_webrtc_reconnecting_toast": MessageLookupByLibrary.simpleMessage(
      "Nettverk (WebRTC) kobler til igjen",
    ),
    "main_whats_new_content": MessageLookupByLibrary.simpleMessage(
      "[Forbedringer]  \n\n1. Kun numerisk skjermkode for en bedre opplevelse.  \n\n2. Forbedret tilkoblingsstabilitet.  \n\n3. Feilrettinger.  ",
    ),
    "main_whats_new_title": MessageLookupByLibrary.simpleMessage(
      "Hva er nytt i AirSync?",
    ),
    "moderator_activate_split_screen": MessageLookupByLibrary.simpleMessage(
      "Klikk på bryteren over for delt skjerm-modus. Opptil 4 deltakere kan presentere samtidig.",
    ),
    "moderator_cancel": MessageLookupByLibrary.simpleMessage("AVBRYT"),
    "moderator_confirm": MessageLookupByLibrary.simpleMessage("Bekreft"),
    "moderator_deactivate_split_screen": MessageLookupByLibrary.simpleMessage(
      "Er du sikker på at du vil avslutte denne delte skjermøkten? Alle delte skjermer vil bli avsluttet.",
    ),
    "moderator_exit": MessageLookupByLibrary.simpleMessage("AVSLUTT"),
    "moderator_exit_dialog": MessageLookupByLibrary.simpleMessage(
      "Er du sikker på at du vil avslutte denne moderatorøkten? Alle presentatører vil bli fjernet.",
    ),
    "moderator_presentersLimit": MessageLookupByLibrary.simpleMessage(
      "Klikk på bryteren over for moderator-modus. Opptil 6 presentatører kan delta.",
    ),
    "moderator_presentersList": MessageLookupByLibrary.simpleMessage(
      "Presentatører",
    ),
    "moderator_remove": MessageLookupByLibrary.simpleMessage("FJERN"),
    "moderator_verifyCode_fail": MessageLookupByLibrary.simpleMessage(
      "Noe gikk galt. Vennligst prøv igjen.",
    ),
    "toast_maximum_split_screen": MessageLookupByLibrary.simpleMessage(
      "Har nådd maks antall delte skjermer.",
    ),
    "update_install_now": MessageLookupByLibrary.simpleMessage("INSTALLER NÅ"),
    "update_message": MessageLookupByLibrary.simpleMessage(
      "En ny versjon av programvaren er tilgjengelig",
    ),
    "update_title": MessageLookupByLibrary.simpleMessage("AirSync-oppdatering"),
    "v3_authorize_prompt_accept": MessageLookupByLibrary.simpleMessage("Godta"),
    "v3_authorize_prompt_accept_all": MessageLookupByLibrary.simpleMessage(
      "Godta alle",
    ),
    "v3_authorize_prompt_decline": MessageLookupByLibrary.simpleMessage(
      "Avslå",
    ),
        "v3_authorize_prompt_title_launcher":
            MessageLookupByLibrary.simpleMessage(
          "Deltakere ønsker å dele skjermen sin",
        ),
        "v3_broadcast_cast_board_on": MessageLookupByLibrary.simpleMessage(
          "Casting pågår",
        ),
        "v3_broadcast_cast_device_on": MessageLookupByLibrary.simpleMessage(
          "Casting pågår",
        ),
        "v3_broadcast_indicator": MessageLookupByLibrary.simpleMessage("PÅ"),
        "v3_broadcast_multicast_checkbox": MessageLookupByLibrary.simpleMessage(
          "Cast til 10-100 enheter",
        ),
        "v3_broadcast_multicast_desc": MessageLookupByLibrary.simpleMessage(
          "Antall mottakende enheter kan ikke endres når projiseringen starter.",
        ),
        "v3_broadcast_multicast_warn": MessageLookupByLibrary.simpleMessage(
          "Avbryt all projisering for å redigere.",
        ),
        "v3_cast_to_device_Receiving": MessageLookupByLibrary.simpleMessage(
      "Mottar",
    ),
    "v3_cast_to_device_list_msg": MessageLookupByLibrary.simpleMessage(
      "Maksimalt opptil 10 enheter.",
    ),
    "v3_cast_to_device_menu_or": MessageLookupByLibrary.simpleMessage("Eller"),
    "v3_cast_to_device_menu_quick_connect1":
        MessageLookupByLibrary.simpleMessage("Hurtigkobling"),
    "v3_cast_to_device_menu_quick_connect2":
        MessageLookupByLibrary.simpleMessage("ved å skanne QR-koden"),
    "v3_cast_to_device_menu_title": MessageLookupByLibrary.simpleMessage(
      "Bli med for å motta denne skjermen",
    ),
    "v3_cast_to_device_reached_maximum": MessageLookupByLibrary.simpleMessage(
      "Du har nådd maksgrensen.",
    ),
    "v3_cast_to_device_title": MessageLookupByLibrary.simpleMessage(
      "Enhetsliste",
    ),
    "v3_cast_to_device_touch_back": MessageLookupByLibrary.simpleMessage(
      "Tilbakekobling",
    ),
    "v3_cast_to_device_touch_back_disable":
        MessageLookupByLibrary.simpleMessage("Deaktiver"),
    "v3_cast_to_device_touch_enabled": MessageLookupByLibrary.simpleMessage(
      "Tilbakekobling",
    ),
    "v3_casting_ended_toast": MessageLookupByLibrary.simpleMessage(
      "Skjermdeling er avsluttet.",
    ),
    "v3_casting_time_countdown": m0,
    "v3_casting_time_do_not_extend": MessageLookupByLibrary.simpleMessage(
      "Ikke forleng",
    ),
    "v3_casting_time_extend": MessageLookupByLibrary.simpleMessage("Forleng"),
    "v3_casting_time_extend_success_toast":
        MessageLookupByLibrary.simpleMessage("Forlenget med 3 timer."),
    "v3_download_app_desc": MessageLookupByLibrary.simpleMessage(
      "Skann QR-koden med din iOS- eller Android-enhet for å laste ned",
    ),
    "v3_download_app_desktop": MessageLookupByLibrary.simpleMessage(
      "For best brukeropplevelse!",
    ),
    "v3_download_app_desktop_hint": MessageLookupByLibrary.simpleMessage(
      "*Manuell installasjon",
    ),
    "v3_download_app_desktop_store": MessageLookupByLibrary.simpleMessage(
      "Installer MacOS via App Store",
    ),
    "v3_download_app_desktop_store_hint": MessageLookupByLibrary.simpleMessage(
      "*Kun for MacOS",
    ),
    "v3_download_app_desktop_title": MessageLookupByLibrary.simpleMessage(
      "Skrivebord",
    ),
    "v3_download_app_entry": MessageLookupByLibrary.simpleMessage(
      "Last ned senderappen",
    ),
    "v3_download_app_for_desktop": MessageLookupByLibrary.simpleMessage(
      "For skrivebord",
    ),
    "v3_download_app_for_desktop_desc": MessageLookupByLibrary.simpleMessage(
      "Skriv inn følgende URL for å laste ned.",
    ),
    "v3_download_app_for_mobile": MessageLookupByLibrary.simpleMessage(
      "For iOS og Android",
    ),
    "v3_download_app_for_mobile_desc": MessageLookupByLibrary.simpleMessage(
      "Skann QR-koden for umiddelbar tilgang.",
    ),
    "v3_download_app_mobile_title": MessageLookupByLibrary.simpleMessage(
      "Mobil",
    ),
    "v3_download_app_or": MessageLookupByLibrary.simpleMessage("ELLER"),
    "v3_download_app_title": MessageLookupByLibrary.simpleMessage(
      "Last ned senderappen",
    ),
    "v3_eula_agree": MessageLookupByLibrary.simpleMessage("Godta"),
    "v3_eula_disagree": MessageLookupByLibrary.simpleMessage("Avslå"),
        "v3_eula_launch": MessageLookupByLibrary.simpleMessage("Start"),
        "v3_eula_title": MessageLookupByLibrary.simpleMessage("Sluttbrukeravtale"),
    "v3_exit_moderator_mode_cancel": MessageLookupByLibrary.simpleMessage(
      "Avbryt",
    ),
    "v3_exit_moderator_mode_desc": MessageLookupByLibrary.simpleMessage(
      "Er du sikker? Dette vil koble fra alle deltakerne.",
    ),
    "v3_exit_moderator_mode_exit": MessageLookupByLibrary.simpleMessage(
      "Avslutt",
    ),
    "v3_exit_moderator_mode_title": MessageLookupByLibrary.simpleMessage(
      "Avslutt moderator-modus",
    ),
    "v3_group_dialog_accept": MessageLookupByLibrary.simpleMessage("Godta"),
    "v3_group_dialog_decline": MessageLookupByLibrary.simpleMessage("Avslå"),
    "v3_group_dialog_message": MessageLookupByLibrary.simpleMessage(
      "%s har sendt en forespørsel om sending til enheten din. Denne handlingen vil synkronisere og vise det gjeldende innholdet. Vil du godta denne forespørselen?",
    ),
    "v3_group_dialog_no_device_message": MessageLookupByLibrary.simpleMessage(
      "Ingen enheter valgt.",
    ),
    "v3_group_dialog_title": MessageLookupByLibrary.simpleMessage(
      "Broadcast-forespørsel fra %s",
    ),
    "v3_group_receive_view_status_from": MessageLookupByLibrary.simpleMessage(
      "Sender fra",
    ),
    "v3_group_receive_view_status_stop": MessageLookupByLibrary.simpleMessage(
      "Stopp",
    ),
    "v3_group_reject_invited": MessageLookupByLibrary.simpleMessage(
      "avslo forespørselen om sending, vennligst sjekk kringkastingsinnstillingene.",
    ),
    "v3_help_center_cast_device_title": MessageLookupByLibrary.simpleMessage(
      "Kast til enhet",
    ),
    "v3_help_center_cast_device_title_sub":
        MessageLookupByLibrary.simpleMessage(
          "IFP kaster skjermen sin til enheter.",
        ),
    "v3_help_center_close": MessageLookupByLibrary.simpleMessage("Lukk"),
    "v3_help_center_fullscreen_title": MessageLookupByLibrary.simpleMessage(
      "Fullskjerm",
    ),
    "v3_help_center_mute_user_title": MessageLookupByLibrary.simpleMessage(
      "Demp bruker",
    ),
    "v3_help_center_remove_user_title": MessageLookupByLibrary.simpleMessage(
      "Fjern  ",
    ),
    "v3_help_center_share_title": MessageLookupByLibrary.simpleMessage(
      "Inviter til deling",
    ),
    "v3_help_center_share_title_sub": MessageLookupByLibrary.simpleMessage(
      "Enheter deler skjermen sin til IFP.",
    ),
    "v3_help_center_stop_share_title": MessageLookupByLibrary.simpleMessage(
      "Stopp deling",
    ),
    "v3_help_center_title": MessageLookupByLibrary.simpleMessage(
      "Hjelpesenter",
    ),
    "v3_help_center_touchback_title": MessageLookupByLibrary.simpleMessage(
      "Berøringstilbakemelding",
    ),
    "v3_help_center_touchback_title_sub": MessageLookupByLibrary.simpleMessage(
      "Tillater brukeren å fjernstyre.",
    ),
    "v3_help_center_untouchback_title": MessageLookupByLibrary.simpleMessage(
      "Fjern berøringstilbakemelding",
    ),
    "v3_help_center_untouchback_title_sub":
        MessageLookupByLibrary.simpleMessage("Koble fra berøringsstyring."),
    "v3_instruction1a": MessageLookupByLibrary.simpleMessage(
      "Besøk airsync.net eller åpne senderappen",
    ),
    "v3_instruction1b": MessageLookupByLibrary.simpleMessage(
      "Åpne senderappen",
    ),
    "v3_instruction2": MessageLookupByLibrary.simpleMessage(
      "Skriv inn skjermkode",
    ),
        "v3_instruction2_onethird": MessageLookupByLibrary.simpleMessage(
          "Vis kode",
        ),
        "v3_instruction3": MessageLookupByLibrary.simpleMessage(
      "Skriv inn engangspassord",
    ),
        "v3_instruction3_onethird": MessageLookupByLibrary.simpleMessage(
          "Engangspassord",
        ),
        "v3_instruction_share_screen": MessageLookupByLibrary.simpleMessage(
      "Del skjermene dine",
    ),
    "v3_instruction_support": MessageLookupByLibrary.simpleMessage(
      "Støtter deling via AirPlay, Google Cast eller Miracast",
    ),
    "v3_last_casting_time_countdown": MessageLookupByLibrary.simpleMessage(
      "Skjermdeling er i ferd med å avsluttes. Start skjermdeling på nytt om nødvendig.",
    ),
    "v3_lbl_authorize_prompt_accept": MessageLookupByLibrary.simpleMessage(
      "Godta forespørsel",
    ),
    "v3_lbl_authorize_prompt_accept_all": MessageLookupByLibrary.simpleMessage(
      "Godta alle forespørsler",
    ),
    "v3_lbl_authorize_prompt_decline": MessageLookupByLibrary.simpleMessage(
      "Avslå forespørsel",
    ),
        "v3_lbl_broadcast_multicast_checkbox":
            MessageLookupByLibrary.simpleMessage(
          "Cast til 10-100 enheter",
        ),
        "v3_lbl_cast_device_close": MessageLookupByLibrary.simpleMessage(
      "Lukk cast-enhetstilkobling",
    ),
        "v3_lbl_cast_device_next": MessageLookupByLibrary.simpleMessage(
          "neste side",
        ),
        "v3_lbl_cast_device_previous": MessageLookupByLibrary.simpleMessage(
          "forrige side",
        ),
        "v3_lbl_cast_device_sort_asc": MessageLookupByLibrary.simpleMessage(
          "sorter stigende",
        ),
        "v3_lbl_cast_device_sort_desc": MessageLookupByLibrary.simpleMessage(
          "sorter ned",
        ),
        "v3_lbl_cast_device_touchback_disable":
        MessageLookupByLibrary.simpleMessage(
          "Deaktiver touchback for cast-enhet",
        ),
    "v3_lbl_cast_device_touchback_enable": MessageLookupByLibrary.simpleMessage(
      "Aktiver touchback for cast-enhet",
    ),
    "v3_lbl_close_download_app_menu": MessageLookupByLibrary.simpleMessage(
      "Lukk nedlast sender-app-meny",
    ),
    "v3_lbl_close_feature_set_cast_device":
        MessageLookupByLibrary.simpleMessage("Lukk cast-enhetsliste"),
    "v3_lbl_close_feature_set_moderator": MessageLookupByLibrary.simpleMessage(
      "Lukk moderatorliste",
    ),
    "v3_lbl_close_help_center": MessageLookupByLibrary.simpleMessage(
      "Lukk hjelpesenter",
    ),
    "v3_lbl_close_streaming_shortcut_menu":
        MessageLookupByLibrary.simpleMessage("Lukk strømmehutigmeny"),
    "v3_lbl_connection_dialog_close": MessageLookupByLibrary.simpleMessage(
      "Lukk tilkoblingsstatus-dialog",
    ),
    "v3_lbl_eula_agree": MessageLookupByLibrary.simpleMessage("Godta EULA"),
    "v3_lbl_eula_disagree": MessageLookupByLibrary.simpleMessage("Avvis EULA"),
        "v3_lbl_eula_launch": MessageLookupByLibrary.simpleMessage("Start"),
        "v3_lbl_exit_moderator_cancel": MessageLookupByLibrary.simpleMessage(
      "Avbryt avslutning av moderator-modus",
    ),
    "v3_lbl_exit_moderator_exit": MessageLookupByLibrary.simpleMessage(
      "Bekreft avslutning av moderator-modus",
    ),
    "v3_lbl_extend_casting_do_not_extend": MessageLookupByLibrary.simpleMessage(
      "Ikke forleng castingtid",
    ),
    "v3_lbl_extend_casting_extend": MessageLookupByLibrary.simpleMessage(
      "Forleng castingtid",
    ),
    "v3_lbl_group_reject_close": MessageLookupByLibrary.simpleMessage(
      "Lukk gruppeavvisningsvarsel",
    ),
    "v3_lbl_internet_connection_only_error":
        MessageLookupByLibrary.simpleMessage(
          "Tilkoblingsfeil，sjekk enhetens nettverksinnstillinger",
        ),
    "v3_lbl_internet_connection_warning": MessageLookupByLibrary.simpleMessage(
      "Kun lokal tilkobling",
    ),
    "v3_lbl_main_language_title": MessageLookupByLibrary.simpleMessage(
      "Velg språk",
    ),
    "v3_lbl_main_language_title_item": MessageLookupByLibrary.simpleMessage(
      "Velg %s",
    ),
    "v3_lbl_message_dialog_cancel": MessageLookupByLibrary.simpleMessage(
      "Avbryt dialog",
    ),
    "v3_lbl_message_dialog_confirm": MessageLookupByLibrary.simpleMessage(
      "Bekreft dialog",
    ),
    "v3_lbl_minimal_quick_connect_menu": MessageLookupByLibrary.simpleMessage(
      "Minimer hurtigkoblingsmeny",
    ),
    "v3_lbl_minimal_streaming_qrcode_menu":
        MessageLookupByLibrary.simpleMessage("Minimer strømme QR-kodemeny"),
    "v3_lbl_moderator_toggle": MessageLookupByLibrary.simpleMessage(
      "Bytt moderator-modus",
    ),
    "v3_lbl_open_download_app_menu": MessageLookupByLibrary.simpleMessage(
      "Åpne nedlast sender-app-meny",
    ),
    "v3_lbl_open_feature_set_cast_device": MessageLookupByLibrary.simpleMessage(
      "Åpne cast-enhetsliste",
    ),
    "v3_lbl_open_feature_set_moderator": MessageLookupByLibrary.simpleMessage(
      "Åpne moderatorliste",
    ),
    "v3_lbl_open_help_center": MessageLookupByLibrary.simpleMessage(
      "Åpne hjelpesenter-meny",
    ),
    "v3_lbl_open_menu_settings": MessageLookupByLibrary.simpleMessage(
      "Åpne innstillingsmeny",
    ),
    "v3_lbl_open_streaming_qrcode_menu": MessageLookupByLibrary.simpleMessage(
      "Åpne strømme QR-kodemeny",
    ),
    "v3_lbl_open_streaming_shortcut_menu": MessageLookupByLibrary.simpleMessage(
      "Åpne strømmehutigmeny",
    ),
    "v3_lbl_overlay_bring_app_to_top": MessageLookupByLibrary.simpleMessage(
      "Flytende tilkoblingsinformasjon-fane",
    ),
    "v3_lbl_overlay_menu_expand": MessageLookupByLibrary.simpleMessage(
      "Utvid overleggmeny",
    ),
    "v3_lbl_overlay_menu_minimize": MessageLookupByLibrary.simpleMessage(
      "Minimer overleggmeny",
    ),
    "v3_lbl_participant_cast_device": MessageLookupByLibrary.simpleMessage(
      "Cast enhet til denne deltakeren",
    ),
    "v3_lbl_participant_close": MessageLookupByLibrary.simpleMessage(
      "Lukk deltakerforbindelse",
    ),
    "v3_lbl_participant_disconnect": MessageLookupByLibrary.simpleMessage(
      "Koble fra denne deltakeren",
    ),
    "v3_lbl_participant_mirror_close": MessageLookupByLibrary.simpleMessage(
      "Lukk speildeltakerforbindelse",
    ),
    "v3_lbl_participant_mirror_share": MessageLookupByLibrary.simpleMessage(
      "Del til denne deltakerens speil",
    ),
    "v3_lbl_participant_mirror_stop": MessageLookupByLibrary.simpleMessage(
      "Stopp speildeltakerens strømming",
    ),
    "v3_lbl_participant_share": MessageLookupByLibrary.simpleMessage(
      "Del til denne deltakerens skjerm",
    ),
    "v3_lbl_participant_stop": MessageLookupByLibrary.simpleMessage(
      "Stopp deltakerens strømming",
    ),
    "v3_lbl_participant_touch_back": MessageLookupByLibrary.simpleMessage(
      "Aktiver touchback for denne deltakeren",
    ),
    "v3_lbl_participant_touch_back_disable":
        MessageLookupByLibrary.simpleMessage(
          "Deaktiver touchback for denne deltakeren",
        ),
    "v3_lbl_resizable_expand": MessageLookupByLibrary.simpleMessage(
      "Utvid presentasjonskontroll",
    ),
    "v3_lbl_resizable_minimize": MessageLookupByLibrary.simpleMessage(
      "Minimer presentasjonskontroll",
    ),
    "v3_lbl_resizable_mute": MessageLookupByLibrary.simpleMessage(
      "Slå av presentasjon",
    ),
    "v3_lbl_resizable_stop": MessageLookupByLibrary.simpleMessage(
      "Stopp presentasjon",
    ),
    "v3_lbl_settings_accessibility": MessageLookupByLibrary.simpleMessage(
      "Tilgjengelighet",
    ),
    "v3_lbl_settings_back_icon": MessageLookupByLibrary.simpleMessage(
      "Tilbake til forrige side",
    ),
    "v3_lbl_settings_broadcast": MessageLookupByLibrary.simpleMessage(
      "Åpne kringkastingsinnstillingsmeny",
    ),
    "v3_lbl_settings_broadcast_boards": MessageLookupByLibrary.simpleMessage(
      "Åpne kringkastingsbrettmeny",
    ),
    "v3_lbl_settings_broadcast_devices": MessageLookupByLibrary.simpleMessage(
      "Åpne kringkastingsenhetsmeny",
    ),
    "v3_lbl_settings_broadcast_to_display_group":
        MessageLookupByLibrary.simpleMessage(
          "Åpne kringkasting til displaygruppe-meny",
        ),
    "v3_lbl_settings_broadcast_to_display_group_cast":
        MessageLookupByLibrary.simpleMessage("Kringkast"),
    "v3_lbl_settings_broadcast_to_display_group_checkbox":
        MessageLookupByLibrary.simpleMessage("Velg %s"),
    "v3_lbl_settings_broadcast_to_display_group_confirm":
        MessageLookupByLibrary.simpleMessage(
          "Bekreft at ingen enhet er valgt.",
        ),
    "v3_lbl_settings_broadcast_to_display_group_item":
        MessageLookupByLibrary.simpleMessage("Velg %s"),
    "v3_lbl_settings_broadcast_to_display_group_save":
        MessageLookupByLibrary.simpleMessage("Lagre"),
    "v3_lbl_settings_broadcast_to_display_group_type":
        MessageLookupByLibrary.simpleMessage("Velg %s"),
    "v3_lbl_settings_close_icon": MessageLookupByLibrary.simpleMessage(
      "Lukk innstillingsmeny",
    ),
    "v3_lbl_settings_connectivity": MessageLookupByLibrary.simpleMessage(
      "Åpne tilkoblingsinnstillingsmeny",
    ),
    "v3_lbl_settings_connectivity_item": MessageLookupByLibrary.simpleMessage(
      "Velg %s",
    ),
    "v3_lbl_settings_device_authorize_mode":
        MessageLookupByLibrary.simpleMessage("Slå på/av autorisasjonsmodus"),
    "v3_lbl_settings_device_auto_fill_otp":
        MessageLookupByLibrary.simpleMessage("Slå på/av autofyll OTP-modus"),
        "v3_lbl_settings_device_high_image_quality":
            MessageLookupByLibrary.simpleMessage("Høy bildekvalitet"),
        "v3_lbl_settings_device_launch_on_startup":
        MessageLookupByLibrary.simpleMessage("Slå på/av autooppstartmodus"),
    "v3_lbl_settings_device_name": MessageLookupByLibrary.simpleMessage(
      "Endre enhetsnavn",
    ),
    "v3_lbl_settings_device_name_close": MessageLookupByLibrary.simpleMessage(
      "Lukk enhetsnavninnstilling",
    ),
    "v3_lbl_settings_device_name_save": MessageLookupByLibrary.simpleMessage(
      "Lagre enhetsnavn",
    ),
    "v3_lbl_settings_device_setting": MessageLookupByLibrary.simpleMessage(
      "Åpne enhetsinnstillingsmeny",
    ),
    "v3_lbl_settings_device_smart_scaling":
        MessageLookupByLibrary.simpleMessage(
          "Slå på/av smart skalering-bryter",
        ),
    "v3_lbl_settings_enter_device_name": MessageLookupByLibrary.simpleMessage(
      "Skriv inn enhetsnavn",
    ),
    "v3_lbl_settings_invite_group": MessageLookupByLibrary.simpleMessage(
      "Åpne skjermkringkasting rullegardinmeny",
    ),
    "v3_lbl_settings_invite_group_item": MessageLookupByLibrary.simpleMessage(
      "Velg %s",
    ),
        "v3_lbl_settings_knowledge_base": MessageLookupByLibrary.simpleMessage(
          "Knowledge Base",
        ),
        "v3_lbl_settings_legal_policy": MessageLookupByLibrary.simpleMessage(
      "Åpne juridisk policy-innstillingsmeny",
    ),
    "v3_lbl_settings_menu_locked": MessageLookupByLibrary.simpleMessage(
      "Innstillingsmenyen er låst",
    ),
    "v3_lbl_settings_mirroring_auto_accept":
        MessageLookupByLibrary.simpleMessage("Slå på/av acceptera automatiskt"),
    "v3_lbl_settings_mirroring_require_passcode":
        MessageLookupByLibrary.simpleMessage("Slå på/av krever passord"),
    "v3_lbl_settings_only_when_casting_info":
        MessageLookupByLibrary.simpleMessage(
          "Mer informasjon om kringkasting til displaygruppe",
        ),
    "v3_lbl_settings_open_source_license": MessageLookupByLibrary.simpleMessage(
      "Velg %s",
    ),
    "v3_lbl_settings_show_display_code": MessageLookupByLibrary.simpleMessage(
      "Slå på/av skärmkod-bryter",
    ),
    "v3_lbl_settings_whats_new": MessageLookupByLibrary.simpleMessage(
      "Åpne hva er nytt-innstillingsmeny",
    ),
    "v3_lbl_settings_whats_new_icon": MessageLookupByLibrary.simpleMessage(
      "hva er nytt-ikon",
    ),
    "v3_lbl_shortcuts_airplay": MessageLookupByLibrary.simpleMessage(
      "Slå på/av AirPlay",
    ),
    "v3_lbl_shortcuts_google_cast": MessageLookupByLibrary.simpleMessage(
      "Slå på/av Google Cast",
    ),
    "v3_lbl_shortcuts_miracast": MessageLookupByLibrary.simpleMessage(
      "Slå på/av Miracast",
    ),
    "v3_lbl_shortcuts_mirroring": MessageLookupByLibrary.simpleMessage(
      "Åpne speilingsinnstillingsmeny",
    ),
    "v3_lbl_streaming_airplay_touchback": MessageLookupByLibrary.simpleMessage(
      "AirPlay touchback",
    ),
        "v3_lbl_streaming_page_control": MessageLookupByLibrary.simpleMessage(
          "neste side",
        ),
        "v3_lbl_streaming_shortcut_airplay_toggle":
        MessageLookupByLibrary.simpleMessage("AirPlay-bryter"),
    "v3_lbl_streaming_shortcut_cast_device_toggle":
        MessageLookupByLibrary.simpleMessage("Cast til enheter-bryter"),
    "v3_lbl_streaming_shortcut_expand": MessageLookupByLibrary.simpleMessage(
      "Utvid strømmefunksjoner",
    ),
    "v3_lbl_streaming_shortcut_google_cast_toggle":
        MessageLookupByLibrary.simpleMessage("Google Cast-bryter"),
    "v3_lbl_streaming_shortcut_menu_locked":
        MessageLookupByLibrary.simpleMessage("Strømmehurtigmeny er låst"),
    "v3_lbl_streaming_shortcut_minimize": MessageLookupByLibrary.simpleMessage(
      "Slå sammen strømmefunksjoner",
    ),
    "v3_lbl_streaming_shortcut_miracast_toggle":
        MessageLookupByLibrary.simpleMessage("Miracast-bryter"),
    "v3_lbl_streaming_view_expand": MessageLookupByLibrary.simpleMessage(
      "Utvid strømmevisning",
    ),
    "v3_lbl_streaming_view_function_expand":
        MessageLookupByLibrary.simpleMessage("Utvid strømmefunksjon"),
    "v3_lbl_streaming_view_function_minimize":
        MessageLookupByLibrary.simpleMessage("Slå sammen strømmefunksjon"),
    "v3_lbl_streaming_view_minimize": MessageLookupByLibrary.simpleMessage(
      "Slå sammen strømmevisning",
    ),
    "v3_lbl_streaming_view_mute": MessageLookupByLibrary.simpleMessage(
      "Slå av lyd",
    ),
    "v3_lbl_streaming_view_stop": MessageLookupByLibrary.simpleMessage(
      "Stopp strømming",
    ),
    "v3_lbl_streaming_view_unmute": MessageLookupByLibrary.simpleMessage(
      "Slå på lyd",
    ),
    "v3_lbl_touchback_one_device_cancel": MessageLookupByLibrary.simpleMessage(
      "Avbryt dialog",
    ),
    "v3_lbl_touchback_one_device_confirm": MessageLookupByLibrary.simpleMessage(
      "Bekreft dialog",
    ),
    "v3_lbl_touchback_restart_bluetooth_btn_cancel":
        MessageLookupByLibrary.simpleMessage("Avbryt"),
    "v3_lbl_touchback_restart_bluetooth_btn_restart":
        MessageLookupByLibrary.simpleMessage("Start på nytt"),
    "v3_main_connection_dialog_close": MessageLookupByLibrary.simpleMessage(
      "Lukk",
    ),
    "v3_main_internet_connection_only": MessageLookupByLibrary.simpleMessage(
      "Kun internettforbindelse。",
    ),
    "v3_main_internet_connection_only_error":
        MessageLookupByLibrary.simpleMessage(
          "Tilkoblingsfeil，sjekk enhetens nettverksinnstillinger。",
        ),
    "v3_main_internet_connection_only_error_dialog_desc":
        MessageLookupByLibrary.simpleMessage(
          "Tilkoblingsfeil，sjekk enhetens nettverksinnstillinger。",
        ),
    "v3_main_local_connection_only_dialog_desc":
        MessageLookupByLibrary.simpleMessage(
          "Kun LAN-tilkobling，sjekk enhetens nettverksinnstillinger。",
        ),
    "v3_main_status_no_network": MessageLookupByLibrary.simpleMessage(
      "Kunne ikke oppdage en internettforbindelse. Vennligst koble til et Wi-Fi- eller intranett-nettverk og prøv igjen.",
    ),
    "v3_miracast_not_support": MessageLookupByLibrary.simpleMessage(
      "Miracast ikke tilgjengelig nå. Nåværende Wi-Fi-kanal støtter ikke skjermcasting.",
    ),
        "v3_miracast_uibc_not_supported_message":
            MessageLookupByLibrary.simpleMessage(
          "Denne kilden støtter ikke Miracast touchback",
        ),
        "v3_mirror_request_passcode": MessageLookupByLibrary.simpleMessage(
      "Passord",
    ),
    "v3_moderator_disable_mirror_cancel": MessageLookupByLibrary.simpleMessage(
      "Avbryt",
    ),
    "v3_moderator_disable_mirror_desc": MessageLookupByLibrary.simpleMessage(
      "Speiling vil bli deaktivert i moderator-modus",
    ),
    "v3_moderator_disable_mirror_ok": MessageLookupByLibrary.simpleMessage(
      "OK",
    ),
    "v3_moderator_disable_mirror_title": MessageLookupByLibrary.simpleMessage(
      "Deaktiver speiling for moderator-modus",
    ),
    "v3_moderator_mode": MessageLookupByLibrary.simpleMessage(
      "Moderator-modus",
    ),
    "v3_new_sharing_join_session": MessageLookupByLibrary.simpleMessage(
      "ble med i økten",
    ),
    "v3_participant_item_casting": MessageLookupByLibrary.simpleMessage(
      "Casting",
    ),
    "v3_participant_item_connected": MessageLookupByLibrary.simpleMessage(
      "Tilkoblet",
    ),
    "v3_participant_item_controlling": MessageLookupByLibrary.simpleMessage(
      "Mottar + Tilbakekobling",
    ),
    "v3_participant_item_receiving": MessageLookupByLibrary.simpleMessage(
      "Mottar",
    ),
    "v3_participant_item_share": MessageLookupByLibrary.simpleMessage("Del"),
    "v3_participant_item_waiting": MessageLookupByLibrary.simpleMessage(
      "Venter...",
    ),
    "v3_participants_desc": MessageLookupByLibrary.simpleMessage(
      "Maksimalt opptil 6 deltakere.",
    ),
    "v3_participants_desc_maximum_9": MessageLookupByLibrary.simpleMessage(
      "Maksimalt opptil 9 deltakere.",
    ),
    "v3_participants_title": MessageLookupByLibrary.simpleMessage("Deltakere"),
    "v3_qrcode_quick_connect": MessageLookupByLibrary.simpleMessage(
      "Hurtigkobling",
    ),
    "v3_quick_connect_menu_bottom_msg": MessageLookupByLibrary.simpleMessage(
      "Opdelt skjerm aktiveres hvis to eller flere brukere deler skjermer.",
    ),
    "v3_quick_connect_menu_display_code": MessageLookupByLibrary.simpleMessage(
      "Skjermkode",
    ),
    "v3_quick_connect_menu_qrcode": MessageLookupByLibrary.simpleMessage(
      "QR-kode",
    ),
    "v3_setting_passcode_cancel": MessageLookupByLibrary.simpleMessage(
      "Avbryt",
    ),
    "v3_setting_passcode_clear": MessageLookupByLibrary.simpleMessage("Tøm"),
    "v3_setting_passcode_confirm": MessageLookupByLibrary.simpleMessage(
      "Bekreft",
    ),
    "v3_setting_passcode_error_description":
        MessageLookupByLibrary.simpleMessage(
          "Ugyldig passord, vennligst prøv igjen.",
        ),
    "v3_setting_passcode_title": MessageLookupByLibrary.simpleMessage(
      "Skriv inn passord for å låse opp innstillinger",
    ),
    "v3_settings_accessibility": MessageLookupByLibrary.simpleMessage(
      "Tilgjengelighet",
    ),
    "v3_settings_all_the_time_info": MessageLookupByLibrary.simpleMessage(
      "Send kilde-IFP-skjermen hele tiden.",
    ),
    "v3_settings_broadcast": MessageLookupByLibrary.simpleMessage("Broadcast"),
    "v3_settings_broadcast_boards": MessageLookupByLibrary.simpleMessage(
      "Andre AirSync-enheter",
    ),
    "v3_settings_broadcast_cast_boards": MessageLookupByLibrary.simpleMessage(
      "Cast til tavler",
    ),
    "v3_settings_broadcast_cast_boards_desc": MessageLookupByLibrary.simpleMessage(
      "Del skjermen din til alle interaktive flatskjermer (IFP-er) i nettverket.",
    ),
    "v3_settings_broadcast_cast_to": MessageLookupByLibrary.simpleMessage(
      "Send til",
    ),
    "v3_settings_broadcast_devices": MessageLookupByLibrary.simpleMessage(
      "Senderenheter",
    ),
    "v3_settings_broadcast_screen_energy_saving":
        MessageLookupByLibrary.simpleMessage(
          "Vennligst slå av energisparing for å unngå uventede avbrudd under kringkasting.",
        ),
    "v3_settings_broadcast_to_display_group":
        MessageLookupByLibrary.simpleMessage("Send til skjermgruppen"),
    "v3_settings_connectivity": MessageLookupByLibrary.simpleMessage(
      "Tilkobling",
    ),
    "v3_settings_connectivity_both": MessageLookupByLibrary.simpleMessage(
      "Både internett- og lokal tilkobling",
    ),
    "v3_settings_connectivity_internet": MessageLookupByLibrary.simpleMessage(
      "Internett-tilkobling",
    ),
    "v3_settings_connectivity_internet_desc":
        MessageLookupByLibrary.simpleMessage(
          "Internett-tilkobling krever et stabilt nettverk.",
        ),
    "v3_settings_connectivity_local": MessageLookupByLibrary.simpleMessage(
      "Lokal tilkobling",
    ),
    "v3_settings_connectivity_local_desc": MessageLookupByLibrary.simpleMessage(
      "Lokale tilkoblinger opererer innenfor et privat nettverk, noe som gir mer sikkerhet og stabilitet.",
    ),
    "v3_settings_device_authorize_mode": MessageLookupByLibrary.simpleMessage(
      "Tillat skjermdeling kun med godkjenningsforespørsler.",
    ),
    "v3_settings_device_auto_fill_otp": MessageLookupByLibrary.simpleMessage(
      "Fyll ut engangspassord automatisk",
    ),
    "v3_settings_device_auto_fill_otp_desc": MessageLookupByLibrary.simpleMessage(
      "Aktiver ett-klikks tilkobling når du velger en enhet fra enhetslisten.",
    ),
        "v3_settings_device_high_image_quality":
            MessageLookupByLibrary.simpleMessage("Høy bildekvalitet"),
        "v3_settings_device_high_image_quality_off_desc":
            MessageLookupByLibrary.simpleMessage(
          "Maksimal QHD (2K) skjermdeling avhengig av senderens skjermoppløsning.",
        ),
        "v3_settings_device_high_image_quality_on_desc":
            MessageLookupByLibrary.simpleMessage(
          "Maksimal UHD (4K) skjermdeling fra websender og 3K+ fra Windows- og macOS-sender avhengig av senderens skjermoppløsning. Krever et høykvalitetsnettverk.",
        ),
        "v3_settings_device_launch_on_startup":
        MessageLookupByLibrary.simpleMessage("Start AirSync ved oppstart"),
    "v3_settings_device_name": MessageLookupByLibrary.simpleMessage(
      "Enhetsnavn",
    ),
    "v3_settings_device_name_empty_error": MessageLookupByLibrary.simpleMessage(
      "Enhetsnavn kan ikke være tomt",
    ),
    "v3_settings_device_name_save": MessageLookupByLibrary.simpleMessage(
      "Lagre",
    ),
        "v3_settings_device_not_supported":
            MessageLookupByLibrary.simpleMessage(
          "Enhetsversjonen støttes ikke",
        ),
        "v3_settings_device_setting": MessageLookupByLibrary.simpleMessage(
      "Enhetsinnstilling",
    ),
    "v3_settings_device_show_display_code":
        MessageLookupByLibrary.simpleMessage("Vis skjermkode øverst"),
    "v3_settings_device_show_display_code_desc":
        MessageLookupByLibrary.simpleMessage(
          "Hold koden synlig øverst på skjermen, selv når du bytter til andre apper og skjermdeling er aktiv.",
        ),
    "v3_settings_device_smart_scaling": MessageLookupByLibrary.simpleMessage(
      "Smart skalering",
    ),
    "v3_settings_device_smart_scaling_desc": MessageLookupByLibrary.simpleMessage(
      "Juster automatisk skjermstørrelsen for å maksimere bruken av skjermplassen. Bildet kan bli litt forvrengt.",
    ),
    "v3_settings_device_unavailable": MessageLookupByLibrary.simpleMessage(
      "Utilgjengelig",
    ),
    "v3_settings_display_group": MessageLookupByLibrary.simpleMessage(
      "Skjermgruppe",
    ),
    "v3_settings_display_group_all_the_time":
        MessageLookupByLibrary.simpleMessage("Hele tiden"),
    "v3_settings_display_group_cast": MessageLookupByLibrary.simpleMessage(
      "Send",
    ),
    "v3_settings_display_group_only_casting":
        MessageLookupByLibrary.simpleMessage("Kun når du caster"),
    "v3_settings_feature_locked": MessageLookupByLibrary.simpleMessage(
      "Låst av ViewSonic Manager.",
    ),
    "v3_settings_invite_group": MessageLookupByLibrary.simpleMessage(
      "Hvis invitert til en skjermgruppe",
    ),
    "v3_settings_invite_group_auto_accept":
        MessageLookupByLibrary.simpleMessage("Acceptera automatiskt"),
    "v3_settings_invite_group_ignore": MessageLookupByLibrary.simpleMessage(
      "Ignorer",
    ),
    "v3_settings_invite_group_notify_me": MessageLookupByLibrary.simpleMessage(
      "Varsle meg",
    ),
    "v3_settings_knowledge_base": MessageLookupByLibrary.simpleMessage(
      "Kunnskapsbase",
    ),
    "v3_settings_legal_policy": MessageLookupByLibrary.simpleMessage(
      "Juridisk og policy",
    ),
    "v3_settings_local_connection_only": MessageLookupByLibrary.simpleMessage(
      "Kun lokal tilkobling",
    ),
    "v3_settings_mirroring_auto_accept": MessageLookupByLibrary.simpleMessage(
      "Acceptera automatiskt",
    ),
    "v3_settings_mirroring_auto_accept_desc":
        MessageLookupByLibrary.simpleMessage(
          "Aktiver speiling umiddelbart uten å kreve moderatorgodkjenning.",
        ),
    "v3_settings_mirroring_blocked": MessageLookupByLibrary.simpleMessage(
      "Slå av moderator-modus først.",
    ),
    "v3_settings_mirroring_require_passcode":
        MessageLookupByLibrary.simpleMessage("Krev passord"),
    "v3_settings_only_when_casting_info": MessageLookupByLibrary.simpleMessage(
      "Send kilde-IFP-skjermen bare når den mottar en delt skjerm.",
    ),
    "v3_settings_open_source_license": MessageLookupByLibrary.simpleMessage(
      "Åpen kildekode-lisenser",
    ),
    "v3_settings_privacy_policy": MessageLookupByLibrary.simpleMessage(
      "Personvernpolicy",
    ),
    "v3_settings_privacy_policy_description": MessageLookupByLibrary.simpleMessage(
      "ViewSonic er forpliktet til å beskytte personvernet ditt og behandler håndtering av personopplysninger med stort alvor. Personvernreglene nedenfor beskriver hvordan ViewSonic behandler dine personopplysninger etter at de er samlet inn gjennom din bruk av nettstedet. ViewSonic opprettholder personvernet til informasjonen din ved å bruke sikkerhetsteknologier og følge retningslinjer som forhindrer uautorisert bruk av dine personopplysninger. Ved å bruke dette nettstedet samtykker du i innsamling og bruk av informasjonen din.\n\nNettsteder du lenker til fra ViewSonic.com kan ha sine egne personvernregler som kan avvike fra ViewSonics. Les gjennom disse nettsteders personvernregler for detaljert informasjon om hvordan de kan bruke informasjon samlet inn mens du besøker dem.\n\nKlikk på følgende lenker for å lære mer om våre personvernregler.",
    ),
    "v3_settings_resize_text_size": MessageLookupByLibrary.simpleMessage(
      "Endre tekststørrelse",
    ),
    "v3_settings_resize_text_size_extra_large":
        MessageLookupByLibrary.simpleMessage("Ekstra stor"),
    "v3_settings_resize_text_size_large": MessageLookupByLibrary.simpleMessage(
      "Stor",
    ),
    "v3_settings_resize_text_size_normal": MessageLookupByLibrary.simpleMessage(
      "Normal",
    ),
    "v3_settings_version": m1,
    "v3_settings_whats_new": MessageLookupByLibrary.simpleMessage(
      "Hva er nytt",
    ),
    "v3_settings_whats_new_content": MessageLookupByLibrary.simpleMessage(
      "AirSync %s\n\nAirSync is a proprietary wireless screen-sharing solution from ViewSonic. When utilized with the AirSync sender, it allows users to seamlessly share their screens with ViewSonic interactive displays.\n\nThis release includes the following new features:\n\n1. Support for ViewSonic LED Displays.\n\n2. Touchback functionality for Android devices on IFP.\n\n3. Touchback functionality for iPads when sharing via AirPlay.\n\n4. Smart scaling.\n\n5. Capability to resize the cast to device window.\n\n6. Enhanced stability for Miracast.\n\n7. Fixed various bugs.",
    ),
    "v3_shortcuts_airplay": MessageLookupByLibrary.simpleMessage("AirPlay"),
    "v3_shortcuts_cast_device": MessageLookupByLibrary.simpleMessage(
      "Cast til enheter",
    ),
    "v3_shortcuts_cast_device_desc": MessageLookupByLibrary.simpleMessage(
      "Cast skjermen din til flere enheter, inkludert bærbare datamaskiner, nettbrett og mobile enheter samtidig.",
    ),
    "v3_shortcuts_google_cast": MessageLookupByLibrary.simpleMessage(
      "Google Cast",
    ),
    "v3_shortcuts_menu_title": MessageLookupByLibrary.simpleMessage(
      "Snarveier",
    ),
    "v3_shortcuts_miracast": MessageLookupByLibrary.simpleMessage("Miracast"),
    "v3_shortcuts_mirroring": MessageLookupByLibrary.simpleMessage("Speiling"),
    "v3_touchback_alert_message": MessageLookupByLibrary.simpleMessage(
      "Du kan bare touchback én enhet om gangen.",
    ),
    "v3_touchback_alert_title": MessageLookupByLibrary.simpleMessage(
      "Touchback til %s？",
    ),
    "v3_touchback_disable_message": MessageLookupByLibrary.simpleMessage(
      "TouchBack er deaktivert.",
    ),
    "v3_touchback_fail_message": MessageLookupByLibrary.simpleMessage(
      "Paring mislyktes. TouchBack er ikke aktivert. Vennligst prøv igjen",
    ),
    "v3_touchback_restart_bluetooth_btn_cancel":
        MessageLookupByLibrary.simpleMessage("Avbryt"),
    "v3_touchback_restart_bluetooth_btn_restart":
        MessageLookupByLibrary.simpleMessage("Start på nytt"),
    "v3_touchback_restart_bluetooth_message": MessageLookupByLibrary.simpleMessage(
      "Operasjonen har tidsavbrudd. Slå av og start Bluetooth-funksjonen på den store skjermen på nytt, og start deretter touchback på nytt.",
    ),
    "v3_touchback_restart_bluetooth_title":
        MessageLookupByLibrary.simpleMessage(
          "Operasjonen har tidsavbrudd, start Bluetooth på nytt",
        ),
    "v3_touchback_state_deviceFinding_message":
        MessageLookupByLibrary.simpleMessage("Enhet finner"),
    "v3_touchback_state_deviceFoundSuccess_message":
        MessageLookupByLibrary.simpleMessage("Enhet funnet med suksess"),
    "v3_touchback_state_devicePairedSuccess_message":
        MessageLookupByLibrary.simpleMessage("Enhet paret med suksess"),
    "v3_touchback_state_devicePairing_message":
        MessageLookupByLibrary.simpleMessage("Enhet parer"),
    "v3_touchback_state_hidConnected_message":
        MessageLookupByLibrary.simpleMessage("Hid tilkoblet"),
    "v3_touchback_state_hidConnecting_message":
        MessageLookupByLibrary.simpleMessage("Hid kobler til"),
    "v3_touchback_state_hidProfileServiceStartedSuccess_message":
        MessageLookupByLibrary.simpleMessage(
          "Hid Profile Service startet med suksess",
        ),
    "v3_touchback_state_hidProfileServiceStarting_message":
        MessageLookupByLibrary.simpleMessage("Hid Profile Service starter"),
    "v3_touchback_state_initialized_message":
        MessageLookupByLibrary.simpleMessage("Initialisert"),
    "v3_touchback_state_initializing_message":
        MessageLookupByLibrary.simpleMessage("Initialiserer"),
    "v3_touchback_success_message": MessageLookupByLibrary.simpleMessage(
      "Du kan nå kontrollere %s eksternt fra IFP.",
    ),
    "v3_waiting_desc": MessageLookupByLibrary.simpleMessage(
      "Venter på at denne deltakeren skal dele skjermen",
    ),
    "v3_waiting_join": MessageLookupByLibrary.simpleMessage(
      "Venter på at andre skal bli med",
    ),
    "v3_waiting_up_next": MessageLookupByLibrary.simpleMessage("Opp neste"),
    "vbs_ota_progress_msg": MessageLookupByLibrary.simpleMessage(
      "Laster ned systemoppdateringer",
    ),
  };
}
