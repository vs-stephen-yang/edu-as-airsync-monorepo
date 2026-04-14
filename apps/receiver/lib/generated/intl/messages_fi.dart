// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fi locale. All the
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
  String get localeName => 'fi';

  static String m0(value) =>
      "Näytönjako on loppumassa. Haluatko jatkaa 3 tuntia? Voit jatkaa enintään ${value} kertaa.";

  static String m1(year, version) => "AirSync ©${year}. version ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "eula_agree": MessageLookupByLibrary.simpleMessage("Hyväksyn"),
    "eula_disagree": MessageLookupByLibrary.simpleMessage("En hyväksy"),
    "eula_title": MessageLookupByLibrary.simpleMessage("AirSync EULA"),
    "main_airplay_pin_code": MessageLookupByLibrary.simpleMessage(
      "AirPlay-koodi",
    ),
    "main_auto_startup": MessageLookupByLibrary.simpleMessage(
      "Käynnistä AirSync automaattisesti käynnistyksessä",
    ),
    "main_cast_settings_airplay": MessageLookupByLibrary.simpleMessage(
      "AirPlay",
    ),
    "main_cast_settings_device_name": MessageLookupByLibrary.simpleMessage(
      "Nimi",
    ),
    "main_cast_settings_google_cast": MessageLookupByLibrary.simpleMessage(
      "Google Cast",
    ),
    "main_cast_settings_miracast": MessageLookupByLibrary.simpleMessage(
      "Miracast",
    ),
    "main_cast_settings_title": MessageLookupByLibrary.simpleMessage(
      "Lähetysasetukset",
    ),
    "main_content_display_code": MessageLookupByLibrary.simpleMessage(
      "Näyttökoodi",
    ),
    "main_content_lan_only": MessageLookupByLibrary.simpleMessage(
      "Vain LAN-yhteys",
    ),
    "main_content_one_time_password": MessageLookupByLibrary.simpleMessage(
      "Kertakäyttösalasana",
    ),
    "main_content_one_time_password_get_fail": MessageLookupByLibrary.simpleMessage(
      "Salasanaa ei voitu päivittää. Odota 30 sekuntia ennen uudelleenyritystä.",
    ),
    "main_feature_no_network_warning": MessageLookupByLibrary.simpleMessage(
      "Ohjausyhteys katkaistu. Yhdistä uudelleen.",
    ),
    "main_feature_reconnect_fail_toast": MessageLookupByLibrary.simpleMessage(
      "Verkko (Control) yhteyden muodostus epäonnistui",
    ),
    "main_feature_reconnect_success_toast":
        MessageLookupByLibrary.simpleMessage(
          "Verkko (Control) yhteyden muodostus onnistui",
        ),
    "main_feature_reconnecting_toast": MessageLookupByLibrary.simpleMessage(
      "Verkko (Control) muodostaa uudelleen yhteyttä",
    ),
    "main_get_display_code_failure": MessageLookupByLibrary.simpleMessage(
      "Näyttökoodin hakeminen epäonnistui. Odota verkkoyhteyden palautumista tai käynnistä sovellus uudelleen.",
    ),
    "main_language_name": MessageLookupByLibrary.simpleMessage("Englanti"),
    "main_language_title": MessageLookupByLibrary.simpleMessage("Kieli"),
    "main_limit_time_message": MessageLookupByLibrary.simpleMessage(
      "5 minuuttia jäljellä",
    ),
    "main_mirror_from_client": MessageLookupByLibrary.simpleMessage(
      "%s haluaa jakaa näyttönsä.",
    ),
    "main_mirror_prompt_accept": MessageLookupByLibrary.simpleMessage(
      "Hyväksy",
    ),
    "main_mirror_prompt_cancel": MessageLookupByLibrary.simpleMessage(
      "Peruuta",
    ),
    "main_register_display_code_failure": MessageLookupByLibrary.simpleMessage(
      "Näyttökoodin ja kertakäyttösalasanan hakeminen epäonnistui. Tämä voi johtua verkko- tai palvelinongelmasta. Yritä myöhemmin uudelleen, kun yhteys on palautettu.",
    ),
    "main_settings_airplay_code": MessageLookupByLibrary.simpleMessage(
      "AirPlay-koodi",
    ),
    "main_settings_device_list": MessageLookupByLibrary.simpleMessage(
      "Pikayhteyden salasana",
    ),
    "main_settings_device_name": MessageLookupByLibrary.simpleMessage("Nimi"),
    "main_settings_device_name_cancel": MessageLookupByLibrary.simpleMessage(
      "PERUUTA",
    ),
    "main_settings_device_name_hint": MessageLookupByLibrary.simpleMessage(
      "Nimi",
    ),
    "main_settings_device_name_save": MessageLookupByLibrary.simpleMessage(
      "TALLENNA",
    ),
    "main_settings_device_name_title": MessageLookupByLibrary.simpleMessage(
      "Nimeä laite uudelleen",
    ),
    "main_settings_language": MessageLookupByLibrary.simpleMessage("Kieli"),
    "main_settings_mirror_confirmation": MessageLookupByLibrary.simpleMessage(
      "Peilauksen vahvistus",
    ),
    "main_settings_pin_visible": MessageLookupByLibrary.simpleMessage(
      "Yhteystiedot",
    ),
    "main_settings_share_to_sender": MessageLookupByLibrary.simpleMessage(
      "Jaa näyttö laitteeseen",
    ),
    "main_settings_share_to_sender_limit_desc":
        MessageLookupByLibrary.simpleMessage(
          "Jaa näyttö jopa 10 lähettäjälle.",
        ),
    "main_settings_title": MessageLookupByLibrary.simpleMessage("Asetukset"),
    "main_settings_whats_new": MessageLookupByLibrary.simpleMessage(
      "Mitä uutta?",
    ),
    "main_split_screen_question": MessageLookupByLibrary.simpleMessage(
      "Klikkaa yllä olevaa painiketta ottaaksesi käyttöön Jaetun näytön tila. Enintään 4 osallistujaa voi esittää samanaikaisesti.",
    ),
    "main_split_screen_title": MessageLookupByLibrary.simpleMessage(
      "Jaettu näyttö",
    ),
    "main_split_screen_waiting": MessageLookupByLibrary.simpleMessage(
      "Jaettu näyttö käytössä. Odotetaan esittäjää jakamaan näyttö...",
    ),
    "main_status_go_background": MessageLookupByLibrary.simpleMessage(
      "AirSync-sovellus toimii taustalla.",
    ),
    "main_status_no_network": MessageLookupByLibrary.simpleMessage(
      "Huono verkkoyhteys havaittu.Tarkista verkkoyhteytesi.",
    ),
    "main_status_remaining_time": MessageLookupByLibrary.simpleMessage(
      "%02d min : %02d sek",
    ),
    "main_thanks_content": MessageLookupByLibrary.simpleMessage(
      "Kiitos, että käytit AirSynciä.",
    ),
    "main_wait_title": MessageLookupByLibrary.simpleMessage(
      "Odotetaan esittäjää jakamaan näyttöä...",
    ),
    "main_wait_up_next": MessageLookupByLibrary.simpleMessage("SEURAAVAKSI"),
    "main_webrtc_reconnect_fail_toast": MessageLookupByLibrary.simpleMessage(
      "Verkko (WebRTC) yhteyden muodostus epäonnistui",
    ),
    "main_webrtc_reconnect_success_toast": MessageLookupByLibrary.simpleMessage(
      "Verkko (WebRTC) yhteyden muodostus onnistui",
    ),
    "main_webrtc_reconnecting_toast": MessageLookupByLibrary.simpleMessage(
      "Verkko (WebRTC) muodostaa uudelleen yhteyttä",
    ),
    "main_whats_new_content": MessageLookupByLibrary.simpleMessage(
      "[Parannukset]\n\nKaikki numeerinen näyttökoodi paremman käyttökokemuksen takaamiseksi.\n\nYhteyden vakauden parantaminen.\n\nVirheet korjattu.",
    ),
    "main_whats_new_title": MessageLookupByLibrary.simpleMessage(
      "Mitä uutta AirSyncissä?",
    ),
    "moderator_activate_split_screen": MessageLookupByLibrary.simpleMessage(
      "Klikkaa yllä olevaa painiketta ottaaksesi käyttöön Jaetun näytön tila. Enintään 4 osallistujaa voi esittää samanaikaisesti.",
    ),
    "moderator_cancel": MessageLookupByLibrary.simpleMessage("PERUUTA"),
    "moderator_confirm": MessageLookupByLibrary.simpleMessage("Vahvista"),
    "moderator_deactivate_split_screen": MessageLookupByLibrary.simpleMessage(
      "Haluatko varmasti lopettaa tämän jaetun näytön session? Kaikki tällä hetkellä jaetut näytöt lopetetaan.",
    ),
    "moderator_exit": MessageLookupByLibrary.simpleMessage("POISTU"),
    "moderator_exit_dialog": MessageLookupByLibrary.simpleMessage(
      "Haluatko varmasti lopettaa tämän moderaattorisession? Kaikki esittäjät poistetaan.",
    ),
    "moderator_presentersLimit": MessageLookupByLibrary.simpleMessage(
      "Klikkaa yllä olevaa painiketta ottaaksesi käyttöön Moderaattoritila. Enintään 6 esittäjää voi liittyä.",
    ),
    "moderator_presentersList": MessageLookupByLibrary.simpleMessage(
      "Esittäjät",
    ),
    "moderator_remove": MessageLookupByLibrary.simpleMessage("POISTA"),
    "moderator_verifyCode_fail": MessageLookupByLibrary.simpleMessage(
      "Jokin meni pieleen. Yritä uudelleen.",
    ),
    "toast_maximum_split_screen": MessageLookupByLibrary.simpleMessage(
      "Jaetun näytön määrä on saavutettu.",
    ),
    "update_install_now": MessageLookupByLibrary.simpleMessage("ASENNA NYT"),
    "update_message": MessageLookupByLibrary.simpleMessage(
      "Uusi ohjelmistoversio on saatavilla",
    ),
    "update_title": MessageLookupByLibrary.simpleMessage("AirSync-päivitys"),
    "v3_authorize_prompt_accept": MessageLookupByLibrary.simpleMessage(
      "Hyväksy",
    ),
    "v3_authorize_prompt_accept_all": MessageLookupByLibrary.simpleMessage(
      "Hyväksy kaikki",
    ),
    "v3_authorize_prompt_decline": MessageLookupByLibrary.simpleMessage(
      "Hylkää",
    ),
    "v3_authorize_prompt_notification_cast": MessageLookupByLibrary.simpleMessage(
      "Poista valinta \"Vaadi hyväksyntä\" Asetukset-valikossa hyväksyäksesi kaikki lähetyspyynnöt.",
    ),
    "v3_authorize_prompt_notification_mirror": MessageLookupByLibrary.simpleMessage(
      "Valitse \"Hyväksy automaattisesti\" Asetukset-valikossa hyväksyäksesi kaikki peilauspyynnöt.",
    ),
    "v3_authorize_prompt_title_launcher": MessageLookupByLibrary.simpleMessage(
      "Osallistujat haluaisivat jakaa näyttönsä",
    ),
    "v3_broadcast_cast_board_on": MessageLookupByLibrary.simpleMessage(
      "Lähetys käynnissä",
    ),
    "v3_broadcast_cast_device_on": MessageLookupByLibrary.simpleMessage(
      "Lähetys käynnissä",
    ),
    "v3_broadcast_indicator": MessageLookupByLibrary.simpleMessage("PÄÄLLÄ"),
    "v3_broadcast_multicast_checkbox": MessageLookupByLibrary.simpleMessage(
      "Lähetä 10–100 laitteeseen",
    ),
    "v3_broadcast_multicast_desc": MessageLookupByLibrary.simpleMessage(
      "Vastaanottavien laitteiden määrää ei voi muuttaa projektoinnin aloittamisen jälkeen.",
    ),
    "v3_broadcast_multicast_warn": MessageLookupByLibrary.simpleMessage(
      "Keskeytä kaikki projektiot muokataksesi.",
    ),
    "v3_cast_to_device_Receiving": MessageLookupByLibrary.simpleMessage(
      "Vastaanotetaan",
    ),
    "v3_cast_to_device_list_msg": MessageLookupByLibrary.simpleMessage(
      "Enintään 10 laitetta.",
    ),
    "v3_cast_to_device_menu_or": MessageLookupByLibrary.simpleMessage("Tai"),
    "v3_cast_to_device_menu_quick_connect1":
        MessageLookupByLibrary.simpleMessage("Pikayhteys"),
    "v3_cast_to_device_menu_quick_connect2":
        MessageLookupByLibrary.simpleMessage("skannaamalla QR-koodi"),
    "v3_cast_to_device_menu_title": MessageLookupByLibrary.simpleMessage(
      "Liity vastaanottamaan tämä näyttö",
    ),
    "v3_cast_to_device_reached_maximum": MessageLookupByLibrary.simpleMessage(
      "Olet saavuttanut enimmäismäärän.",
    ),
    "v3_cast_to_device_title": MessageLookupByLibrary.simpleMessage(
      "Laitelista",
    ),
    "v3_cast_to_device_touch_back": MessageLookupByLibrary.simpleMessage(
      "Palautus",
    ),
    "v3_cast_to_device_touch_back_disable":
        MessageLookupByLibrary.simpleMessage("Poista käytöstä"),
    "v3_cast_to_device_touch_enabled": MessageLookupByLibrary.simpleMessage(
      "Palautus",
    ),
    "v3_casting_ended_toast": MessageLookupByLibrary.simpleMessage(
      "Näytönjako on päättynyt.",
    ),
    "v3_casting_time_countdown": m0,
    "v3_casting_time_do_not_extend": MessageLookupByLibrary.simpleMessage(
      "Älä jatka",
    ),
    "v3_casting_time_extend": MessageLookupByLibrary.simpleMessage("Jatka"),
    "v3_casting_time_extend_success_toast":
        MessageLookupByLibrary.simpleMessage("Jatkettu 3 tuntia."),
    "v3_download_app_desc": MessageLookupByLibrary.simpleMessage(
      "Skannaa QR-koodi iOS- tai Android-laitteellasi ladataksesi",
    ),
    "v3_download_app_desktop": MessageLookupByLibrary.simpleMessage(
      "Parhaan käyttökokemuksen varmistamiseksi!",
    ),
    "v3_download_app_desktop_hint": MessageLookupByLibrary.simpleMessage(
      "*Manuaalinen asennus",
    ),
    "v3_download_app_desktop_store": MessageLookupByLibrary.simpleMessage(
      "Asenna MacOS App Storen kautta",
    ),
    "v3_download_app_desktop_store_hint": MessageLookupByLibrary.simpleMessage(
      "*Vain MacOS:lle",
    ),
    "v3_download_app_desktop_title": MessageLookupByLibrary.simpleMessage(
      "Työpöytä",
    ),
    "v3_download_app_entry": MessageLookupByLibrary.simpleMessage(
      "Lataa lähettäjäsovellus",
    ),
    "v3_download_app_for_desktop": MessageLookupByLibrary.simpleMessage(
      "Työpöydälle",
    ),
    "v3_download_app_for_desktop_desc": MessageLookupByLibrary.simpleMessage(
      "Anna seuraava URL-osoite ladataksesi.",
    ),
    "v3_download_app_for_mobile": MessageLookupByLibrary.simpleMessage(
      "iOS:lle ja Androidille",
    ),
    "v3_download_app_for_mobile_desc": MessageLookupByLibrary.simpleMessage(
      "Skannaa QR-koodi saadaksesi välittömän pääsyn.",
    ),
    "v3_download_app_mobile_title": MessageLookupByLibrary.simpleMessage(
      "Mobiili",
    ),
    "v3_download_app_or": MessageLookupByLibrary.simpleMessage("TAI"),
    "v3_download_app_title": MessageLookupByLibrary.simpleMessage(
      "Lataa lähettäjäsovellus",
    ),
    "v3_eula_agree": MessageLookupByLibrary.simpleMessage("Hyväksy"),
    "v3_eula_disagree": MessageLookupByLibrary.simpleMessage("Hylkää"),
    "v3_eula_launch": MessageLookupByLibrary.simpleMessage("Käynnistä"),
    "v3_eula_title": MessageLookupByLibrary.simpleMessage("Käyttöehtosopimus"),
    "v3_exit_moderator_mode_cancel": MessageLookupByLibrary.simpleMessage(
      "Peruuta",
    ),
    "v3_exit_moderator_mode_desc": MessageLookupByLibrary.simpleMessage(
      "Oletko varma? Tämä katkaisee kaikkien osallistujien yhteyden.",
    ),
    "v3_exit_moderator_mode_exit": MessageLookupByLibrary.simpleMessage(
      "Poistu",
    ),
    "v3_exit_moderator_mode_title": MessageLookupByLibrary.simpleMessage(
      "Poistu Moderaattoritilasta",
    ),
    "v3_group_dialog_accept": MessageLookupByLibrary.simpleMessage("Hyväksy"),
    "v3_group_dialog_decline": MessageLookupByLibrary.simpleMessage("Hylkää"),
    "v3_group_dialog_message": MessageLookupByLibrary.simpleMessage(
      "%s on lähettänyt lähetyspyynnön laitteellesi. Tämä toiminto synkronoi ja näyttää nykyisen sisällön, haluatko hyväksyä tämän pyynnön?",
    ),
    "v3_group_dialog_no_device_message": MessageLookupByLibrary.simpleMessage(
      "Ei valittua laitetta.",
    ),
    "v3_group_dialog_title": MessageLookupByLibrary.simpleMessage(
      "Lähetyspyyntö %s:lta",
    ),
    "v3_group_receive_view_status_from": MessageLookupByLibrary.simpleMessage(
      "Lähetys lähteestä",
    ),
    "v3_group_receive_view_status_stop": MessageLookupByLibrary.simpleMessage(
      "Pysäytä",
    ),
    "v3_group_reject_invited": MessageLookupByLibrary.simpleMessage(
      "hylkäsi lähetyspyyntösi, tarkista Lähetyksen asetukset.",
    ),
    "v3_help_center_cast_device_title": MessageLookupByLibrary.simpleMessage(
      "Lähetä laitteeseen",
    ),
    "v3_help_center_cast_device_title_sub":
        MessageLookupByLibrary.simpleMessage(
          "IFP lähettää näyttönsä laitteille.",
        ),
    "v3_help_center_close": MessageLookupByLibrary.simpleMessage("Sulje"),
    "v3_help_center_fullscreen_title": MessageLookupByLibrary.simpleMessage(
      "Koko näyttö",
    ),
    "v3_help_center_mute_user_title": MessageLookupByLibrary.simpleMessage(
      "Mykistä käyttäjä",
    ),
    "v3_help_center_remove_user_title": MessageLookupByLibrary.simpleMessage(
      "Poista käyttäjä",
    ),
    "v3_help_center_share_title": MessageLookupByLibrary.simpleMessage(
      "Kutsu jakamaan",
    ),
    "v3_help_center_share_title_sub": MessageLookupByLibrary.simpleMessage(
      "Laitteet jakavat näyttöään IFP:lle.",
    ),
    "v3_help_center_stop_share_title": MessageLookupByLibrary.simpleMessage(
      "Lopeta jakaminen",
    ),
    "v3_help_center_title": MessageLookupByLibrary.simpleMessage("Ohjekeskus"),
    "v3_help_center_touchback_title": MessageLookupByLibrary.simpleMessage(
      "Touchback",
    ),
    "v3_help_center_touchback_title_sub": MessageLookupByLibrary.simpleMessage(
      "Sallii käyttäjän etäohjauksen.",
    ),
    "v3_help_center_untouchback_title": MessageLookupByLibrary.simpleMessage(
      "Untouchback",
    ),
    "v3_help_center_untouchback_title_sub":
        MessageLookupByLibrary.simpleMessage("Poista touchback-tila käytöstä."),
    "v3_instruction1a": MessageLookupByLibrary.simpleMessage(
      "Käy osoitteessa airsync.net tai avaa lähettäjäsovellus",
    ),
    "v3_instruction1b": MessageLookupByLibrary.simpleMessage(
      "Avaa lähettäjäsovellus",
    ),
    "v3_instruction2": MessageLookupByLibrary.simpleMessage("Anna näyttökoodi"),
    "v3_instruction2_onethird": MessageLookupByLibrary.simpleMessage(
      "Näytä koodi",
    ),
    "v3_instruction3": MessageLookupByLibrary.simpleMessage(
      "Anna kertakäyttösalasana",
    ),
    "v3_instruction3_onethird": MessageLookupByLibrary.simpleMessage(
      "Kertakäyttösalasana",
    ),
    "v3_instruction_share_screen": MessageLookupByLibrary.simpleMessage(
      "Jaa näyttösi",
    ),
    "v3_instruction_support": MessageLookupByLibrary.simpleMessage(
      "Tukee jakamista AirPlayn, Google Castin tai Miracastin kautta",
    ),
    "v3_last_casting_time_countdown": MessageLookupByLibrary.simpleMessage(
      "Näytönjako on loppumassa. Käynnistä näytönjako uudelleen tarvittaessa.",
    ),
    "v3_lbl_authorize_prompt_accept": MessageLookupByLibrary.simpleMessage(
      "Hyväksy pyyntö",
    ),
    "v3_lbl_authorize_prompt_accept_all": MessageLookupByLibrary.simpleMessage(
      "Hyväksy kaikki pyynnöt",
    ),
    "v3_lbl_authorize_prompt_decline": MessageLookupByLibrary.simpleMessage(
      "Hylkää pyyntö",
    ),
    "v3_lbl_broadcast_multicast_checkbox": MessageLookupByLibrary.simpleMessage(
      "Lähetä 10–100 laitteeseen",
    ),
    "v3_lbl_cast_device_close": MessageLookupByLibrary.simpleMessage(
      "Sulje lähetettävän laitteen yhteys",
    ),
    "v3_lbl_cast_device_next": MessageLookupByLibrary.simpleMessage(
      "seuraava sivu",
    ),
    "v3_lbl_cast_device_previous": MessageLookupByLibrary.simpleMessage(
      "edellinen sivu",
    ),
    "v3_lbl_cast_device_sort_asc": MessageLookupByLibrary.simpleMessage(
      "järjestä nousevasti",
    ),
    "v3_lbl_cast_device_sort_desc": MessageLookupByLibrary.simpleMessage(
      "lajittele laskevasti",
    ),
    "v3_lbl_cast_device_touchback_disable":
        MessageLookupByLibrary.simpleMessage(
          "Poista touchback käytöstä lähetettävälle laitteelle",
        ),
    "v3_lbl_cast_device_touchback_enable": MessageLookupByLibrary.simpleMessage(
      "Ota touchback käyttöön lähetettävälle laitteelle",
    ),
    "v3_lbl_close_download_app_menu": MessageLookupByLibrary.simpleMessage(
      "Sulje lähettäjäsovelluksen latausvalikko",
    ),
    "v3_lbl_close_feature_set_cast_device":
        MessageLookupByLibrary.simpleMessage(
          "Sulje lähetettävien laitteiden lista",
        ),
    "v3_lbl_close_feature_set_moderator": MessageLookupByLibrary.simpleMessage(
      "Sulje moderaattorilista",
    ),
    "v3_lbl_close_help_center": MessageLookupByLibrary.simpleMessage(
      "Sulje ohjekeskus",
    ),
    "v3_lbl_close_streaming_shortcut_menu":
        MessageLookupByLibrary.simpleMessage("Sulje suoratoiston pikavalikko"),
    "v3_lbl_connection_dialog_close": MessageLookupByLibrary.simpleMessage(
      "Sulje yhteystilan dialogi",
    ),
    "v3_lbl_eula_agree": MessageLookupByLibrary.simpleMessage("Hyväksy EULA"),
    "v3_lbl_eula_disagree": MessageLookupByLibrary.simpleMessage("Hylkää EULA"),
    "v3_lbl_eula_launch": MessageLookupByLibrary.simpleMessage("Käynnistä"),
    "v3_lbl_exit_moderator_cancel": MessageLookupByLibrary.simpleMessage(
      "Peruuta moderaattoritilan poistuminen",
    ),
    "v3_lbl_exit_moderator_exit": MessageLookupByLibrary.simpleMessage(
      "Vahvista moderaattoritilan poistuminen",
    ),
    "v3_lbl_extend_casting_do_not_extend": MessageLookupByLibrary.simpleMessage(
      "Älä jatka lähetystä",
    ),
    "v3_lbl_extend_casting_extend": MessageLookupByLibrary.simpleMessage(
      "Jatka lähetystä",
    ),
    "v3_lbl_group_reject_close": MessageLookupByLibrary.simpleMessage(
      "Sulje ryhmän hylkäysilmoitus",
    ),
    "v3_lbl_internet_connection_only_error":
        MessageLookupByLibrary.simpleMessage(
          "Yhteysvirhe，tarkista laitteen verkkoasetukset",
        ),
    "v3_lbl_internet_connection_warning": MessageLookupByLibrary.simpleMessage(
      "Vain paikallinen yhteys",
    ),
    "v3_lbl_main_language_title": MessageLookupByLibrary.simpleMessage(
      "Valitse kieli",
    ),
    "v3_lbl_main_language_title_item": MessageLookupByLibrary.simpleMessage(
      "Valitse %s",
    ),
    "v3_lbl_message_dialog_cancel": MessageLookupByLibrary.simpleMessage(
      "Peruuta dialogi",
    ),
    "v3_lbl_message_dialog_confirm": MessageLookupByLibrary.simpleMessage(
      "Vahvista dialogi",
    ),
    "v3_lbl_minimal_quick_connect_menu": MessageLookupByLibrary.simpleMessage(
      "Pienennä pikayhdistysvalikko",
    ),
    "v3_lbl_minimal_streaming_qrcode_menu":
        MessageLookupByLibrary.simpleMessage(
          "Pienennä suoratoiston QR-koodivalikko",
        ),
    "v3_lbl_moderator_toggle": MessageLookupByLibrary.simpleMessage(
      "Vaihda moderaattoritila",
    ),
    "v3_lbl_open_download_app_menu": MessageLookupByLibrary.simpleMessage(
      "Avaa lähettäjäsovelluksen latausvalikko",
    ),
    "v3_lbl_open_feature_set_cast_device": MessageLookupByLibrary.simpleMessage(
      "Avaa lähetettävien laitteiden lista",
    ),
    "v3_lbl_open_feature_set_moderator": MessageLookupByLibrary.simpleMessage(
      "Avaa moderaattorilista",
    ),
    "v3_lbl_open_help_center": MessageLookupByLibrary.simpleMessage(
      "Avaa ohjekeskuksen valikko",
    ),
    "v3_lbl_open_menu_settings": MessageLookupByLibrary.simpleMessage(
      "Avaa asetusvalikko",
    ),
    "v3_lbl_open_streaming_qrcode_menu": MessageLookupByLibrary.simpleMessage(
      "Avaa suoratoiston QR-koodivalikko",
    ),
    "v3_lbl_open_streaming_shortcut_menu": MessageLookupByLibrary.simpleMessage(
      "Avaa suoratoiston pikavalikko",
    ),
    "v3_lbl_overlay_bring_app_to_top": MessageLookupByLibrary.simpleMessage(
      "Kelluva yhteystietovälilehti",
    ),
    "v3_lbl_overlay_menu_expand": MessageLookupByLibrary.simpleMessage(
      "Laajenna peitemenu",
    ),
    "v3_lbl_overlay_menu_minimize": MessageLookupByLibrary.simpleMessage(
      "Pienennä peitemenu",
    ),
    "v3_lbl_participant_cast_device": MessageLookupByLibrary.simpleMessage(
      "Lähetä laite tälle osallistujalle",
    ),
    "v3_lbl_participant_close": MessageLookupByLibrary.simpleMessage(
      "Sulje osallistujan yhteys",
    ),
    "v3_lbl_participant_disconnect": MessageLookupByLibrary.simpleMessage(
      "Katkaise tämän osallistujan yhteys",
    ),
    "v3_lbl_participant_mirror_close": MessageLookupByLibrary.simpleMessage(
      "Sulje peiliosallistujan yhteys",
    ),
    "v3_lbl_participant_mirror_share": MessageLookupByLibrary.simpleMessage(
      "Jaa tämän osallistujan peilinäytölle",
    ),
    "v3_lbl_participant_mirror_stop": MessageLookupByLibrary.simpleMessage(
      "Lopeta peiliosallistujan suoratoisto",
    ),
    "v3_lbl_participant_share": MessageLookupByLibrary.simpleMessage(
      "Jaa tämän osallistujan näytölle",
    ),
    "v3_lbl_participant_stop": MessageLookupByLibrary.simpleMessage(
      "Lopeta osallistujan suoratoisto",
    ),
    "v3_lbl_participant_touch_back": MessageLookupByLibrary.simpleMessage(
      "Ota touchback käyttöön tälle osallistujalle",
    ),
    "v3_lbl_participant_touch_back_disable":
        MessageLookupByLibrary.simpleMessage(
          "Poista touchback käytöstä tälle osallistujalle",
        ),
    "v3_lbl_permission_exit": MessageLookupByLibrary.simpleMessage("Poistu"),
    "v3_lbl_resizable_expand": MessageLookupByLibrary.simpleMessage(
      "Laajenna esityksen hallinta",
    ),
    "v3_lbl_resizable_minimize": MessageLookupByLibrary.simpleMessage(
      "Pienennä esityksen hallinta",
    ),
    "v3_lbl_resizable_mute": MessageLookupByLibrary.simpleMessage(
      "Mykistä esitys",
    ),
    "v3_lbl_resizable_stop": MessageLookupByLibrary.simpleMessage(
      "Lopeta esitys",
    ),
    "v3_lbl_settings_accessibility": MessageLookupByLibrary.simpleMessage(
      "Helppokäyttöisyys",
    ),
    "v3_lbl_settings_back_icon": MessageLookupByLibrary.simpleMessage(
      "Takaisin edelliselle sivulle",
    ),
    "v3_lbl_settings_broadcast": MessageLookupByLibrary.simpleMessage(
      "Avaa lähetysasetukset",
    ),
    "v3_lbl_settings_broadcast_boards": MessageLookupByLibrary.simpleMessage(
      "Avaa lähetyslevyt-valikko",
    ),
    "v3_lbl_settings_broadcast_connect": MessageLookupByLibrary.simpleMessage(
      "Yhdistä",
    ),
    "v3_lbl_settings_broadcast_connecting":
        MessageLookupByLibrary.simpleMessage("Yhdistetään"),
    "v3_lbl_settings_broadcast_device_favorite":
        MessageLookupByLibrary.simpleMessage("suosikki"),
    "v3_lbl_settings_broadcast_device_remove":
        MessageLookupByLibrary.simpleMessage("poista laite"),
    "v3_lbl_settings_broadcast_devices": MessageLookupByLibrary.simpleMessage(
      "Avaa lähetettävät laitteet -valikko",
    ),
    "v3_lbl_settings_broadcast_ip_hint": MessageLookupByLibrary.simpleMessage(
      "etsi taulut IP:n avulla",
    ),
    "v3_lbl_settings_broadcast_to_display_group":
        MessageLookupByLibrary.simpleMessage(
          "Avaa lähetys näyttöryhmälle -valikko",
        ),
    "v3_lbl_settings_broadcast_to_display_group_cast":
        MessageLookupByLibrary.simpleMessage("Lähetä"),
    "v3_lbl_settings_broadcast_to_display_group_checkbox":
        MessageLookupByLibrary.simpleMessage("Valitse %s"),
    "v3_lbl_settings_broadcast_to_display_group_confirm":
        MessageLookupByLibrary.simpleMessage(
          "Vahvista, ettei laitetta ole valittu.",
        ),
    "v3_lbl_settings_broadcast_to_display_group_item":
        MessageLookupByLibrary.simpleMessage("Valitse %s"),
    "v3_lbl_settings_broadcast_to_display_group_save":
        MessageLookupByLibrary.simpleMessage("Tallenna"),
    "v3_lbl_settings_broadcast_to_display_group_type":
        MessageLookupByLibrary.simpleMessage("Valitse %s"),
    "v3_lbl_settings_close_icon": MessageLookupByLibrary.simpleMessage(
      "Sulje asetusvalikko",
    ),
    "v3_lbl_settings_connectivity": MessageLookupByLibrary.simpleMessage(
      "Avaa yhteysasetukset",
    ),
    "v3_lbl_settings_connectivity_item": MessageLookupByLibrary.simpleMessage(
      "Valitse %s",
    ),
    "v3_lbl_settings_device_authorize_mode":
        MessageLookupByLibrary.simpleMessage(
          "Ota käyttöön/poista käytöstä valtuutustila",
        ),
    "v3_lbl_settings_device_auto_fill_otp":
        MessageLookupByLibrary.simpleMessage(
          "Ota käyttöön/poista käytöstä automaattinen OTP-täyttötila",
        ),
    "v3_lbl_settings_device_high_image_quality":
        MessageLookupByLibrary.simpleMessage("Korkea kuvanlaatu"),
    "v3_lbl_settings_device_launch_on_startup":
        MessageLookupByLibrary.simpleMessage(
          "Ota käyttöön/poista käytöstä automaattinen käynnistystila",
        ),
    "v3_lbl_settings_device_name": MessageLookupByLibrary.simpleMessage(
      "Muokkaa laitteen nimeä",
    ),
    "v3_lbl_settings_device_name_close": MessageLookupByLibrary.simpleMessage(
      "Sulje laitteen nimi -asetus",
    ),
    "v3_lbl_settings_device_name_save": MessageLookupByLibrary.simpleMessage(
      "Tallenna laitteen nimi",
    ),
    "v3_lbl_settings_device_setting": MessageLookupByLibrary.simpleMessage(
      "Avaa laiteasetukset",
    ),
    "v3_lbl_settings_device_smart_scaling":
        MessageLookupByLibrary.simpleMessage(
          "Ota käyttöön/poista käytöstä älykäs skaalaus -kytkin",
        ),
    "v3_lbl_settings_enter_device_name": MessageLookupByLibrary.simpleMessage(
      "Anna laitteen nimi",
    ),
    "v3_lbl_settings_invite_group": MessageLookupByLibrary.simpleMessage(
      "Avaa näytönlähetyksen avattava valikko",
    ),
    "v3_lbl_settings_invite_group_item": MessageLookupByLibrary.simpleMessage(
      "Valitse %s",
    ),
    "v3_lbl_settings_ip_add": MessageLookupByLibrary.simpleMessage("lisää ip"),
    "v3_lbl_settings_ip_clear": MessageLookupByLibrary.simpleMessage(
      "tyhjennä",
    ),
    "v3_lbl_settings_knowledge_base": MessageLookupByLibrary.simpleMessage(
      "Tietokanta",
    ),
    "v3_lbl_settings_legal_policy": MessageLookupByLibrary.simpleMessage(
      "Avaa lakikäytäntöjen asetusvalikko",
    ),
    "v3_lbl_settings_menu_locked": MessageLookupByLibrary.simpleMessage(
      "Asetusvalikko on lukittu",
    ),
    "v3_lbl_settings_mirroring_auto_accept":
        MessageLookupByLibrary.simpleMessage(
          "Ota käyttöön/poista käytöstä acceptera automatiskt",
        ),
    "v3_lbl_settings_mirroring_require_passcode":
        MessageLookupByLibrary.simpleMessage(
          "Ota käyttöön/poista käytöstä vaadi pääsykoodi",
        ),
    "v3_lbl_settings_moderator_mode": MessageLookupByLibrary.simpleMessage(
      "Kytke päälle/pois moderaattoritila",
    ),
    "v3_lbl_settings_only_when_casting_info":
        MessageLookupByLibrary.simpleMessage(
          "Lisätietoja lähetyksestä näyttöryhmälle",
        ),
    "v3_lbl_settings_open_source_license": MessageLookupByLibrary.simpleMessage(
      "Valitse %s",
    ),
    "v3_lbl_settings_show_display_code": MessageLookupByLibrary.simpleMessage(
      "Ota käyttöön/poista käytöstä skärmkod-kytkin",
    ),
    "v3_lbl_settings_whats_new": MessageLookupByLibrary.simpleMessage(
      "Avaa uutuudet-asetusvalikko",
    ),
    "v3_lbl_settings_whats_new_icon": MessageLookupByLibrary.simpleMessage(
      "uutuudet-kuvake",
    ),
    "v3_lbl_shortcuts_airplay": MessageLookupByLibrary.simpleMessage(
      "Ota käyttöön/poista käytöstä AirPlay",
    ),
    "v3_lbl_shortcuts_google_cast": MessageLookupByLibrary.simpleMessage(
      "Ota käyttöön/poista käytöstä Google Cast",
    ),
    "v3_lbl_shortcuts_miracast": MessageLookupByLibrary.simpleMessage(
      "Ota käyttöön/poista käytöstä Miracast",
    ),
    "v3_lbl_shortcuts_mirroring": MessageLookupByLibrary.simpleMessage(
      "Avaa peilausasetukset",
    ),
    "v3_lbl_streaming_airplay_touchback": MessageLookupByLibrary.simpleMessage(
      "AirPlay touchback",
    ),
    "v3_lbl_streaming_page_control": MessageLookupByLibrary.simpleMessage(
      "seuraava sivu",
    ),
    "v3_lbl_streaming_shortcut_airplay_toggle":
        MessageLookupByLibrary.simpleMessage("AirPlay-kytkin"),
    "v3_lbl_streaming_shortcut_cast_device_toggle":
        MessageLookupByLibrary.simpleMessage("Lähetä laitteisiin -kytkin"),
    "v3_lbl_streaming_shortcut_expand": MessageLookupByLibrary.simpleMessage(
      "Laajenna suoratoisto-ominaisuudet",
    ),
    "v3_lbl_streaming_shortcut_google_cast_toggle":
        MessageLookupByLibrary.simpleMessage("Google Cast -kytkin"),
    "v3_lbl_streaming_shortcut_menu_locked":
        MessageLookupByLibrary.simpleMessage(
          "Suoratoiston pikavalikko on lukittu",
        ),
    "v3_lbl_streaming_shortcut_minimize": MessageLookupByLibrary.simpleMessage(
      "Pienennä suoratoisto-ominaisuudet",
    ),
    "v3_lbl_streaming_shortcut_miracast_toggle":
        MessageLookupByLibrary.simpleMessage("Miracast-kytkin"),
    "v3_lbl_streaming_shortcut_move": MessageLookupByLibrary.simpleMessage(
      "Siirrä",
    ),
    "v3_lbl_streaming_view_expand": MessageLookupByLibrary.simpleMessage(
      "Laajenna suoratoistonäkymä",
    ),
    "v3_lbl_streaming_view_function_expand":
        MessageLookupByLibrary.simpleMessage("Laajenna suoratoistotoiminto"),
    "v3_lbl_streaming_view_function_minimize":
        MessageLookupByLibrary.simpleMessage("Pienennä suoratoistotoiminto"),
    "v3_lbl_streaming_view_minimize": MessageLookupByLibrary.simpleMessage(
      "Pienennä suoratoistonäkymä",
    ),
    "v3_lbl_streaming_view_mute": MessageLookupByLibrary.simpleMessage(
      "Mykistä ääni",
    ),
    "v3_lbl_streaming_view_stop": MessageLookupByLibrary.simpleMessage(
      "Lopeta suoratoisto",
    ),
    "v3_lbl_streaming_view_unmute": MessageLookupByLibrary.simpleMessage(
      "Poista mykistys",
    ),
    "v3_lbl_touchback_one_device_cancel": MessageLookupByLibrary.simpleMessage(
      "Peruuta dialogi",
    ),
    "v3_lbl_touchback_one_device_confirm": MessageLookupByLibrary.simpleMessage(
      "Vahvista dialogi",
    ),
    "v3_lbl_touchback_restart_bluetooth_btn_cancel":
        MessageLookupByLibrary.simpleMessage("Peruuta"),
    "v3_lbl_touchback_restart_bluetooth_btn_restart":
        MessageLookupByLibrary.simpleMessage("Käynnistä uudelleen"),
    "v3_main_connection_dialog_close": MessageLookupByLibrary.simpleMessage(
      "Sulje",
    ),
    "v3_main_internet_connection_only": MessageLookupByLibrary.simpleMessage(
      "Vain internet-yhteys。",
    ),
    "v3_main_internet_connection_only_error":
        MessageLookupByLibrary.simpleMessage(
          "Yhteysvirhe，tarkista laitteen verkkoasetukset。",
        ),
    "v3_main_internet_connection_only_error_dialog_desc":
        MessageLookupByLibrary.simpleMessage(
          "Yhteysvirhe，tarkista laitteen verkkoasetukset。",
        ),
    "v3_main_local_connection_only_dialog_desc":
        MessageLookupByLibrary.simpleMessage(
          "Vain LAN-yhteys，tarkista laitteen verkkoasetukset。",
        ),
    "v3_main_status_no_network": MessageLookupByLibrary.simpleMessage(
      "Internet-yhteyttä ei löydy. Yhdistä Wi-Fi- tai intranet-verkkoon ja yritä uudelleen.",
    ),
    "v3_miracast_not_support": MessageLookupByLibrary.simpleMessage(
      "Miracast ei ole nyt käytettävissä. Nykyinen Wi-Fi-kanava ei tue näytönjakoa.",
    ),
    "v3_miracast_uibc_not_supported_message":
        MessageLookupByLibrary.simpleMessage(
          "Tämä lähde ei tue Miracast-kosketuspalautetta",
        ),
    "v3_mirror_request_passcode": MessageLookupByLibrary.simpleMessage(
      "Salasana",
    ),
    "v3_moderator_disable_mirror_cancel": MessageLookupByLibrary.simpleMessage(
      "Peruuta",
    ),
    "v3_moderator_disable_mirror_desc": MessageLookupByLibrary.simpleMessage(
      "Peilaus poistetaan käytöstä moderaattoritilassa",
    ),
    "v3_moderator_disable_mirror_ok": MessageLookupByLibrary.simpleMessage(
      "OK",
    ),
    "v3_moderator_disable_mirror_title": MessageLookupByLibrary.simpleMessage(
      "Poista peilaus käytöstä moderaattoritilassa",
    ),
    "v3_moderator_mode": MessageLookupByLibrary.simpleMessage(
      "Moderaattoritila",
    ),
    "v3_new_sharing_join_session": MessageLookupByLibrary.simpleMessage(
      "liittyi istuntoon",
    ),
    "v3_overlay_retry_dialog_end": MessageLookupByLibrary.simpleMessage(
      "Lopeta",
    ),
    "v3_overlay_retry_dialog_retry": MessageLookupByLibrary.simpleMessage(
      "Yritä uudelleen",
    ),
    "v3_overlay_retry_dialog_stop_broadcast":
        MessageLookupByLibrary.simpleMessage("Lopeta lähetys"),
    "v3_overlay_retry_dialog_title": MessageLookupByLibrary.simpleMessage(
      "Lähetys keskeytyi. Hanki lähetyslupa uudelleen.",
    ),
    "v3_participant_item_casting": MessageLookupByLibrary.simpleMessage(
      "Lähetys",
    ),
    "v3_participant_item_connected": MessageLookupByLibrary.simpleMessage(
      "Yhdistetty",
    ),
    "v3_participant_item_controlling": MessageLookupByLibrary.simpleMessage(
      "Vastaanottaminen + Palautus",
    ),
    "v3_participant_item_receiving": MessageLookupByLibrary.simpleMessage(
      "Vastaanottaminen",
    ),
    "v3_participant_item_share": MessageLookupByLibrary.simpleMessage("Jaa"),
    "v3_participant_item_waiting": MessageLookupByLibrary.simpleMessage(
      "Odotetaan...",
    ),
    "v3_participants_desc": MessageLookupByLibrary.simpleMessage(
      "Enintään 6 osallistujaa.",
    ),
    "v3_participants_desc_maximum_9": MessageLookupByLibrary.simpleMessage(
      "Enintään 9 osallistujaa.",
    ),
    "v3_participants_title": MessageLookupByLibrary.simpleMessage(
      "Osallistujat",
    ),
    "v3_permission_description": MessageLookupByLibrary.simpleMessage(
      "Siirry laitteen \"Asetukset\"-kohtaan ja sitten \"Sovellus\"-valikkoon myöntääksesi luvan.",
    ),
    "v3_permission_exit": MessageLookupByLibrary.simpleMessage("Poistu"),
    "v3_permission_title": MessageLookupByLibrary.simpleMessage(
      "Lupa vaaditaan",
    ),
    "v3_qrcode_quick_connect": MessageLookupByLibrary.simpleMessage(
      "Pikayhteys",
    ),
    "v3_quick_connect_menu_bottom_msg": MessageLookupByLibrary.simpleMessage(
      "Jaettu näyttö aktivoituu, jos kaksi tai useampi käyttäjä jakaa näyttöjään.",
    ),
    "v3_quick_connect_menu_display_code": MessageLookupByLibrary.simpleMessage(
      "Näyttökoodi",
    ),
    "v3_quick_connect_menu_qrcode": MessageLookupByLibrary.simpleMessage(
      "QR-koodi",
    ),
    "v3_recording_stopped_dialog_msg": MessageLookupByLibrary.simpleMessage(
      "Käynnistä lähetyssessio uudelleen tarvittaessa.",
    ),
    "v3_recording_stopped_dialog_title": MessageLookupByLibrary.simpleMessage(
      "Näytön tallennus on pysäytetty",
    ),
    "v3_setting_passcode_cancel": MessageLookupByLibrary.simpleMessage(
      "Peruuta",
    ),
    "v3_setting_passcode_clear": MessageLookupByLibrary.simpleMessage(
      "Tyhjennä",
    ),
    "v3_setting_passcode_confirm": MessageLookupByLibrary.simpleMessage(
      "Vahvista",
    ),
    "v3_setting_passcode_error_description":
        MessageLookupByLibrary.simpleMessage(
          "Virheellinen salasana, yritä uudelleen.",
        ),
    "v3_setting_passcode_title": MessageLookupByLibrary.simpleMessage(
      "Anna pääsykoodi asetusten avaamiseksi",
    ),
    "v3_settings_accessibility": MessageLookupByLibrary.simpleMessage(
      "Helppokäyttöisyys",
    ),
    "v3_settings_all_the_time_info": MessageLookupByLibrary.simpleMessage(
      "Lähetyslähteen IFP-näyttö koko ajan.",
    ),
    "v3_settings_broadcast": MessageLookupByLibrary.simpleMessage("Lähetys"),
    "v3_settings_broadcast_boards": MessageLookupByLibrary.simpleMessage(
      "Muut AirSync-laitteet",
    ),
    "v3_settings_broadcast_cast_boards": MessageLookupByLibrary.simpleMessage(
      "Lähetä tauluihin",
    ),
    "v3_settings_broadcast_cast_boards_desc":
        MessageLookupByLibrary.simpleMessage(
          "Jaa näyttösi kaikkiin verkon interaktiivisiin tasopaneeleihin (IFP).",
        ),
    "v3_settings_broadcast_cast_to": MessageLookupByLibrary.simpleMessage(
      "Lähetä kohteeseen",
    ),
    "v3_settings_broadcast_devices": MessageLookupByLibrary.simpleMessage(
      "Lähetyslaitteet",
    ),
    "v3_settings_broadcast_ip": MessageLookupByLibrary.simpleMessage(
      "Etsi taulut IP:n avulla",
    ),
    "v3_settings_broadcast_ip_error": MessageLookupByLibrary.simpleMessage(
      "Anna kelvollinen IP-osoite.",
    ),
    "v3_settings_broadcast_ip_hint": MessageLookupByLibrary.simpleMessage(
      "Anna IP-osoite",
    ),
    "v3_settings_broadcast_not_find": MessageLookupByLibrary.simpleMessage(
      "ei löydy",
    ),
    "v3_settings_broadcast_screen_energy_saving":
        MessageLookupByLibrary.simpleMessage(
          "Ota virransäästö pois päältä välttääksesi odottamattomat keskeytykset lähetyksen aikana.",
        ),
    "v3_settings_broadcast_to_display_group":
        MessageLookupByLibrary.simpleMessage("Lähetys näyttöryhmään"),
    "v3_settings_connectivity": MessageLookupByLibrary.simpleMessage("Yhteys"),
    "v3_settings_connectivity_both": MessageLookupByLibrary.simpleMessage(
      "Sekä internet- että paikallinen yhteys",
    ),
    "v3_settings_connectivity_internet": MessageLookupByLibrary.simpleMessage(
      "Internet-yhteys",
    ),
    "v3_settings_connectivity_internet_desc":
        MessageLookupByLibrary.simpleMessage(
          "Internet-yhteys vaatii vakaan verkon.",
        ),
    "v3_settings_connectivity_local": MessageLookupByLibrary.simpleMessage(
      "Paikallinen yhteys",
    ),
    "v3_settings_connectivity_local_desc": MessageLookupByLibrary.simpleMessage(
      "Paikalliset yhteydet toimivat yksityisessä verkossa, tarjoten enemmän turvallisuutta ja vakautta.",
    ),
    "v3_settings_device_authorize_mode": MessageLookupByLibrary.simpleMessage(
      "Salli näytön jakaminen vain hyväksyntäpyynnöillä.",
    ),
    "v3_settings_device_auto_fill_otp": MessageLookupByLibrary.simpleMessage(
      "Täytä kertakäyttösalasana automaattisesti",
    ),
    "v3_settings_device_auto_fill_otp_desc": MessageLookupByLibrary.simpleMessage(
      "Ota käyttöön yhden kosketuksen yhteys, kun valitset laitteen laitelistasta.",
    ),
    "v3_settings_device_high_image_quality":
        MessageLookupByLibrary.simpleMessage("Korkea kuvanlaatu"),
    "v3_settings_device_high_image_quality_off_desc":
        MessageLookupByLibrary.simpleMessage(
          "Suurin QHD (2K) -näytönjako lähettäjän näytön tarkkuudesta riippuen.",
        ),
    "v3_settings_device_high_image_quality_on_desc":
        MessageLookupByLibrary.simpleMessage(
          "Suurin UHD (4K) -näytönjako web-lähettäjältä ja 3K+ Windows- ja macOS-lähettäjältä lähettäjän näytön tarkkuudesta riippuen. Vaatii korkealaatuisen verkon.",
        ),
    "v3_settings_device_launch_on_startup":
        MessageLookupByLibrary.simpleMessage(
          "Käynnistä AirSync käynnistyksen yhteydessä",
        ),
    "v3_settings_device_name": MessageLookupByLibrary.simpleMessage(
      "Laitteen nimi",
    ),
    "v3_settings_device_name_empty_error": MessageLookupByLibrary.simpleMessage(
      "Laitteen nimi ei voi olla tyhjä",
    ),
    "v3_settings_device_name_save": MessageLookupByLibrary.simpleMessage(
      "Tallenna",
    ),
    "v3_settings_device_not_supported": MessageLookupByLibrary.simpleMessage(
      "Laitteen versiota ei tueta",
    ),
    "v3_settings_device_setting": MessageLookupByLibrary.simpleMessage(
      "Laitteen asetukset",
    ),
    "v3_settings_device_show_display_code":
        MessageLookupByLibrary.simpleMessage("Näytä näyttökoodi ylhäällä"),
    "v3_settings_device_show_display_code_desc":
        MessageLookupByLibrary.simpleMessage(
          "Pidä koodi näkyvissä näytön yläosassa, vaikka vaihdat toiseen sovellukseen ja näytön jakaminen on aktiivista.",
        ),
    "v3_settings_device_smart_scaling": MessageLookupByLibrary.simpleMessage(
      "Älykäs skaalaus",
    ),
    "v3_settings_device_smart_scaling_desc": MessageLookupByLibrary.simpleMessage(
      "Säädä näytön kokoa automaattisesti niin, että näytön tila hyödynnetään maksimaalisesti. Kuva saattaa olla hieman vääristynyt.",
    ),
    "v3_settings_device_unavailable": MessageLookupByLibrary.simpleMessage(
      "Ei saatavilla",
    ),
    "v3_settings_display_group": MessageLookupByLibrary.simpleMessage(
      "Näyttöryhmä",
    ),
    "v3_settings_display_group_all_the_time":
        MessageLookupByLibrary.simpleMessage("Koko ajan"),
    "v3_settings_display_group_cast": MessageLookupByLibrary.simpleMessage(
      "Lähetys",
    ),
    "v3_settings_display_group_only_casting":
        MessageLookupByLibrary.simpleMessage("Vain jakamisen aikana"),
    "v3_settings_feature_locked": MessageLookupByLibrary.simpleMessage(
      "Lukittu ViewSonic Managerin toimesta.",
    ),
    "v3_settings_invite_group": MessageLookupByLibrary.simpleMessage(
      "Jos olet kutsuttu näyttöryhmään",
    ),
    "v3_settings_invite_group_auto_accept":
        MessageLookupByLibrary.simpleMessage("Hyväksy automaattisesti"),
    "v3_settings_invite_group_ignore": MessageLookupByLibrary.simpleMessage(
      "Ohita",
    ),
    "v3_settings_invite_group_notify_me": MessageLookupByLibrary.simpleMessage(
      "Ilmoita minulle",
    ),
    "v3_settings_knowledge_base": MessageLookupByLibrary.simpleMessage(
      "Tietopankki",
    ),
    "v3_settings_legal_policy": MessageLookupByLibrary.simpleMessage(
      "Laki & Käytännöt",
    ),
    "v3_settings_local_connection_only": MessageLookupByLibrary.simpleMessage(
      "Vain paikallinen yhteys",
    ),
    "v3_settings_mirroring_auto_accept": MessageLookupByLibrary.simpleMessage(
      "Hyväksy automaattisesti",
    ),
    "v3_settings_mirroring_auto_accept_desc":
        MessageLookupByLibrary.simpleMessage(
          "Ota peilaus käyttöön välittömästi ilman moderaattorin hyväksyntää.",
        ),
    "v3_settings_mirroring_blocked": MessageLookupByLibrary.simpleMessage(
      "Poista ensin moderaattoritila käytöstä.",
    ),
    "v3_settings_mirroring_require_passcode":
        MessageLookupByLibrary.simpleMessage("Vaadi salasana"),
    "v3_settings_moderator_mode": MessageLookupByLibrary.simpleMessage(
      "Moderaattoritila",
    ),
    "v3_settings_only_when_casting_info": MessageLookupByLibrary.simpleMessage(
      "Lähetä lähteen IFP-näyttö vain silloin, kun se vastaanottaa jaetun näytön.",
    ),
    "v3_settings_open_source_license": MessageLookupByLibrary.simpleMessage(
      "Avoimen lähdekoodin lisenssit",
    ),
    "v3_settings_privacy_policy": MessageLookupByLibrary.simpleMessage(
      "Tietosuojakäytäntö",
    ),
    "v3_settings_privacy_policy_description": MessageLookupByLibrary.simpleMessage(
      "ViewSonic on sitoutunut suojaamaan yksityisyyttäsi ja käsittelee henkilötietojen käsittelyä vakavasti. Alla oleva tietosuojakäytäntö selittää, miten ViewSonic käsittelee henkilötietojasi sen jälkeen, kun ne on kerätty ViewSonicin verkkosivuston käytön yhteydessä. ViewSonic säilyttää tietojesi yksityisyyden tietoturvatekniikoiden avulla ja noudattaa käytäntöjä, jotka estävät henkilötietojesi luvattoman käytön. Käyttämällä tätä verkkosivustoa hyväksyt tietojesi keräämisen ja käytön.\n\nVerkkosivustot, joihin linkität ViewSonic.comista, saattavat noudattaa omia tietosuojakäytäntöjään, jotka voivat poiketa ViewSonicin käytännöistä. Tarkista näiden verkkosivustojen tietosuojakäytännöt saadaksesi tarkempaa tietoa siitä, miten ne voivat käyttää vierailusi aikana kerättyjä tietoja.\n\nKlikkaa seuraavia linkkejä saadaksesi lisätietoa tietosuojakäytännöstämme.",
    ),
    "v3_settings_resize_text_size": MessageLookupByLibrary.simpleMessage(
      "Muuta tekstin kokoa",
    ),
    "v3_settings_resize_text_size_extra_large":
        MessageLookupByLibrary.simpleMessage("Erittäin suuri"),
    "v3_settings_resize_text_size_large": MessageLookupByLibrary.simpleMessage(
      "Suuri",
    ),
    "v3_settings_resize_text_size_normal": MessageLookupByLibrary.simpleMessage(
      "Normaali",
    ),
    "v3_settings_version": m1,
    "v3_settings_whats_new": MessageLookupByLibrary.simpleMessage("Mitä uutta"),
    "v3_settings_whats_new_content": MessageLookupByLibrary.simpleMessage(
      "AirSync %s\n\nAirSync is a proprietary wireless screen-sharing solution from ViewSonic. When utilized with the AirSync sender, it allows users to seamlessly share their screens with ViewSonic interactive displays.\n\nThis release includes the following new features:\n\n1. Support for ViewSonic LED Displays.\n\n2. Touchback functionality for Android devices on IFP.\n\n3. Touchback functionality for iPads when sharing via AirPlay.\n\n4. Smart scaling.\n\n5. Capability to resize the cast to device window.\n\n6. Enhanced stability for Miracast.\n\n7. Fixed various bugs.",
    ),
    "v3_shortcuts_airplay": MessageLookupByLibrary.simpleMessage("AirPlay"),
    "v3_shortcuts_cast_device": MessageLookupByLibrary.simpleMessage(
      "Lähetä laitteisiin",
    ),
    "v3_shortcuts_cast_device_desc": MessageLookupByLibrary.simpleMessage(
      "Lähetä näyttösi useisiin laitteisiin, mukaan lukien kannettavat, tabletit ja mobiililaitteet.",
    ),
    "v3_shortcuts_google_cast": MessageLookupByLibrary.simpleMessage(
      "Google Cast",
    ),
    "v3_shortcuts_menu_title": MessageLookupByLibrary.simpleMessage(
      "Pikavalinnat",
    ),
    "v3_shortcuts_miracast": MessageLookupByLibrary.simpleMessage("Miracast"),
    "v3_shortcuts_mirroring": MessageLookupByLibrary.simpleMessage("Peilaus"),
    "v3_touchback_alert_message": MessageLookupByLibrary.simpleMessage(
      "Voit käyttää touchbackia vain yhdelle laitteelle kerrallaan.",
    ),
    "v3_touchback_alert_title": MessageLookupByLibrary.simpleMessage(
      "Touchback laitteeseen %s？",
    ),
    "v3_touchback_disable_message": MessageLookupByLibrary.simpleMessage(
      "TouchBack on poistettu käytöstä.",
    ),
    "v3_touchback_fail_message": MessageLookupByLibrary.simpleMessage(
      "Pariliitos epäonnistui. TouchBack ei ole aktivoitu. Yritä uudelleen",
    ),
    "v3_touchback_ipad_bluetooth_hint": MessageLookupByLibrary.simpleMessage(
      "Bluetooth-asetussivun avaaminen iPadillasi voi nopeuttaa pariliitosprosessia.",
    ),
    "v3_touchback_restart_bluetooth_btn_cancel":
        MessageLookupByLibrary.simpleMessage("Peruuta"),
    "v3_touchback_restart_bluetooth_btn_restart":
        MessageLookupByLibrary.simpleMessage("Käynnistä uudelleen"),
    "v3_touchback_restart_bluetooth_message": MessageLookupByLibrary.simpleMessage(
      "Toiminnon aikakatkaisu. Kytke pois päältä ja käynnistä uudelleen Bluetooth-toiminto isolta näytöltä ja käynnistä sitten touchback uudelleen.",
    ),
    "v3_touchback_restart_bluetooth_title":
        MessageLookupByLibrary.simpleMessage(
          "Toiminnon aikakatkaisu, käynnistä Bluetooth uudelleen",
        ),
    "v3_touchback_state_deviceFinding_message":
        MessageLookupByLibrary.simpleMessage("Laitteen haku"),
    "v3_touchback_state_deviceFoundSuccess_message":
        MessageLookupByLibrary.simpleMessage("Laite löytyi onnistuneesti"),
    "v3_touchback_state_devicePairedSuccess_message":
        MessageLookupByLibrary.simpleMessage(
          "Laite pariliitetty onnistuneesti",
        ),
    "v3_touchback_state_devicePairing_message":
        MessageLookupByLibrary.simpleMessage("Laitteen pariliitos"),
    "v3_touchback_state_hidConnected_message":
        MessageLookupByLibrary.simpleMessage("Hid yhdistetty"),
    "v3_touchback_state_hidConnecting_message":
        MessageLookupByLibrary.simpleMessage("Hid-yhdistetään"),
    "v3_touchback_state_hidProfileServiceStartedSuccess_message":
        MessageLookupByLibrary.simpleMessage(
          "Hid Profile Service käynnistyi onnistuneesti",
        ),
    "v3_touchback_state_hidProfileServiceStarting_message":
        MessageLookupByLibrary.simpleMessage("Hid Profile Service käynnistyy"),
    "v3_touchback_state_initialized_message":
        MessageLookupByLibrary.simpleMessage("Alustettu"),
    "v3_touchback_state_initializing_message":
        MessageLookupByLibrary.simpleMessage("Alustetaan"),
    "v3_touchback_success_message": MessageLookupByLibrary.simpleMessage(
      "Voit nyt ohjata %s laitetta etänä IFP:stä.",
    ),
    "v3_waiting_desc": MessageLookupByLibrary.simpleMessage(
      "Odotetaan tämän osallistujan jakavan näyttönsä",
    ),
    "v3_waiting_join": MessageLookupByLibrary.simpleMessage(
      "Odotetaan muiden liittymistä",
    ),
    "v3_waiting_up_next": MessageLookupByLibrary.simpleMessage("Seuraavaksi"),
    "v3_zero_fps_capture_failed_message": MessageLookupByLibrary.simpleMessage(
      "Näyttökuvaa ei tällä hetkellä voida hakea lähdesovelluksesta. Näyttökuvan ottamisessa on saattanut tapahtua virhe. Palaa lähdesovellukseen ottamaan uusi näyttökuva ja yritä uudelleen.",
    ),
    "v3_zero_fps_capture_failed_title": MessageLookupByLibrary.simpleMessage(
      "Näyttökuvan ottaminen epäonnistui",
    ),
    "v3_zero_fps_capture_failed_wait": MessageLookupByLibrary.simpleMessage(
      "Jatka odottamista",
    ),
    "v3_zero_fps_close": MessageLookupByLibrary.simpleMessage("Sulje"),
    "v3_zero_fps_failed_to_repair_message": MessageLookupByLibrary.simpleMessage(
      "Näyttökuvamekanismia ei voitu käynnistää uudelleen lähdesovelluksessa.",
    ),
    "v3_zero_fps_failed_to_repair_title": MessageLookupByLibrary.simpleMessage(
      "Näyttökuvatoiminnon korjaaminen epäonnistui",
    ),
    "v3_zero_fps_prompt_message": MessageLookupByLibrary.simpleMessage(
      "Näyttöä ei voitu kaapata ja lähettää projektiosovellukseen. Haluatko käynnistää näyttökuvatoiminnon uudelleen ja yrittää uudelleen vai lopettaa projektio?",
    ),
    "v3_zero_fps_prompt_title": MessageLookupByLibrary.simpleMessage(
      "Käynnistetty uudelleen onnistuneesti",
    ),
    "v3_zero_fps_repairing_message": MessageLookupByLibrary.simpleMessage(
      "Näyttökuvamekanismia käynnistetään uudelleen lähdesovelluksessa. Tämä voi kestää muutaman sekunnin. Odota, ole hyvä.",
    ),
    "v3_zero_fps_repairing_title": MessageLookupByLibrary.simpleMessage(
      "Näyttökuvatoiminnon korjaaminen",
    ),
    "v3_zero_fps_restart_failed": MessageLookupByLibrary.simpleMessage(
      "Uudelleenkäynnistys epäonnistui",
    ),
    "v3_zero_fps_restarted_Successfully": MessageLookupByLibrary.simpleMessage(
      "Käynnistetty uudelleen onnistuneesti",
    ),
    "v3_zero_fps_restarting_content": MessageLookupByLibrary.simpleMessage(
      "Odota, ole hyvä.",
    ),
    "v3_zero_fps_restarting_title": MessageLookupByLibrary.simpleMessage(
      "Käynnistetään uudelleen",
    ),
    "vbs_ota_progress_msg": MessageLookupByLibrary.simpleMessage(
      "Järjestelmäpäivityksiä ladataan",
    ),
  };
}
