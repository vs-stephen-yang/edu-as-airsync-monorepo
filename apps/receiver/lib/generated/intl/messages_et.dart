// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a et locale. All the
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
  String get localeName => 'et';

  static String m0(value) =>
      "Ekraani jagamine on lõppemas. Kas soovite seda 3 tunni võrra pikendada? Saate pikendada kuni ${value} korda.";

  static String m1(year, version) => "AirSync ©${year}. version ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "eula_agree": MessageLookupByLibrary.simpleMessage("Nõustun"),
    "eula_disagree": MessageLookupByLibrary.simpleMessage("Ei nõustu"),
    "eula_title": MessageLookupByLibrary.simpleMessage("AirSync EULA"),
    "main_airplay_pin_code": MessageLookupByLibrary.simpleMessage(
      "AirPlay Kood",
    ),
    "main_auto_startup": MessageLookupByLibrary.simpleMessage(
      "Käivita AirSync automaatselt",
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
      "Cast Settings",
    ),
    "main_content_display_code": MessageLookupByLibrary.simpleMessage(
      "Kuvakood",
    ),
    "main_content_lan_only": MessageLookupByLibrary.simpleMessage(
      "Ainult LAN-ühendus",
    ),
    "main_content_one_time_password": MessageLookupByLibrary.simpleMessage(
      "Ühekordne parool",
    ),
    "main_content_one_time_password_get_fail": MessageLookupByLibrary.simpleMessage(
      "Parooli värskendamine ebaõnnestus.\nOodake 30 sekundit enne uuesti proovimist.",
    ),
    "main_feature_no_network_warning": MessageLookupByLibrary.simpleMessage(
      "Juhtimisühendus on katkenud. Palun ühendage uuesti",
    ),
    "main_feature_reconnect_fail_toast": MessageLookupByLibrary.simpleMessage(
      "Võrk (Control) taastamine ebaõnnestus",
    ),
    "main_feature_reconnect_success_toast":
        MessageLookupByLibrary.simpleMessage(
          "Võrk (Control) taastamine õnnestus",
        ),
    "main_feature_reconnecting_toast": MessageLookupByLibrary.simpleMessage(
      "Võrk (Control) taastub",
    ),
    "main_get_display_code_failure": MessageLookupByLibrary.simpleMessage(
      "Kuvakoodi hankimine ebaõnnestus. Oodake, kuni võrguühendus taastub, või taaskäivitage rakendus.",
    ),
    "main_language_name": MessageLookupByLibrary.simpleMessage("Inglise"),
    "main_language_title": MessageLookupByLibrary.simpleMessage("Keel"),
    "main_limit_time_message": MessageLookupByLibrary.simpleMessage(
      "5 minutit jäänud",
    ),
    "main_mirror_from_client": MessageLookupByLibrary.simpleMessage(
      "%s soovib oma ekraani jagada.",
    ),
    "main_mirror_prompt_accept": MessageLookupByLibrary.simpleMessage("Nõustu"),
    "main_mirror_prompt_cancel": MessageLookupByLibrary.simpleMessage(
      "Tühista",
    ),
    "main_register_display_code_failure": MessageLookupByLibrary.simpleMessage(
      "Kuvakoodi ja ühekordse parooli hankimine ebaõnnestus. Selle põhjuseks võib olla võrgu- või serveriprobleem. Palun proovige hiljem uuesti, kui ühendus on taastatud.",
    ),
    "main_settings_airplay_code": MessageLookupByLibrary.simpleMessage(
      "AirPlay kood",
    ),
    "main_settings_device_list": MessageLookupByLibrary.simpleMessage(
      "Kiirühenduse parool",
    ),
    "main_settings_device_name": MessageLookupByLibrary.simpleMessage("Nimi"),
    "main_settings_device_name_cancel": MessageLookupByLibrary.simpleMessage(
      "TÜHISTA",
    ),
    "main_settings_device_name_hint": MessageLookupByLibrary.simpleMessage(
      "Nimi",
    ),
    "main_settings_device_name_save": MessageLookupByLibrary.simpleMessage(
      "SALVESTA",
    ),
    "main_settings_device_name_title": MessageLookupByLibrary.simpleMessage(
      "Nimeta seade ümber",
    ),
    "main_settings_language": MessageLookupByLibrary.simpleMessage("Keel"),
    "main_settings_mirror_confirmation": MessageLookupByLibrary.simpleMessage(
      "Peegeldamise kinnitus",
    ),
    "main_settings_pin_visible": MessageLookupByLibrary.simpleMessage(
      "Ühenduse teave",
    ),
    "main_settings_share_to_sender": MessageLookupByLibrary.simpleMessage(
      "Jaga ekraani seadmega",
    ),
    "main_settings_share_to_sender_limit_desc":
        MessageLookupByLibrary.simpleMessage("Jaga ekraani kuni 10 saatjaga."),
    "main_settings_title": MessageLookupByLibrary.simpleMessage("Seaded"),
    "main_settings_whats_new": MessageLookupByLibrary.simpleMessage(
      "Mis on uut?",
    ),
    "main_split_screen_question": MessageLookupByLibrary.simpleMessage(
      "Klõpsake ülaltoodud lülitil, et aktiveerida Opdelt ekraan Mode. Kuni 4 osalejat saavad korraga esitleda.",
    ),
    "main_split_screen_title": MessageLookupByLibrary.simpleMessage(
      "Opdelt ekraan",
    ),
    "main_split_screen_waiting": MessageLookupByLibrary.simpleMessage(
      "Opdelt ekraan on lubatud. Ootab esitlejat ekraani jagamiseks...",
    ),
    "main_status_go_background": MessageLookupByLibrary.simpleMessage(
      "AirSync rakendus töötab taustal.",
    ),
    "main_status_no_network": MessageLookupByLibrary.simpleMessage(
      "Tuvastati kehv võrguühendus.\nPalun kontrollige oma ühendust.",
    ),
    "main_status_remaining_time": MessageLookupByLibrary.simpleMessage(
      "%02d min : %02d sek",
    ),
    "main_thanks_content": MessageLookupByLibrary.simpleMessage(
      "Aitäh, et kasutate AirSynci.",
    ),
    "main_wait_title": MessageLookupByLibrary.simpleMessage(
      "Ootab esitlejat ekraani jagamiseks...",
    ),
    "main_wait_up_next": MessageLookupByLibrary.simpleMessage("JÄRGMINE"),
    "main_webrtc_reconnect_fail_toast": MessageLookupByLibrary.simpleMessage(
      "Võrk (WebRTC) taastamine ebaõnnestus",
    ),
    "main_webrtc_reconnect_success_toast": MessageLookupByLibrary.simpleMessage(
      "Võrk (WebRTC) taastamine õnnestus",
    ),
    "main_webrtc_reconnecting_toast": MessageLookupByLibrary.simpleMessage(
      "Võrk (WebRTC) taastub",
    ),
    "main_whats_new_content": MessageLookupByLibrary.simpleMessage(
      "[Parandused]  \n\n1. Täielikult numbriline kuvakood parema kasutuskogemuse tagamiseks.  \n\n2. Ühenduse stabiilsuse parandamine.  \n\n3. Vigade parandused.  ",
    ),
    "main_whats_new_title": MessageLookupByLibrary.simpleMessage(
      "Mis on uut AirSyncis?",
    ),
    "moderator_activate_split_screen": MessageLookupByLibrary.simpleMessage(
      "Klõpsake ülaltoodud lülitil, et aktiveerida Opdelt ekraan Mode. Kuni 4 osalejat saavad korraga esitleda.",
    ),
    "moderator_cancel": MessageLookupByLibrary.simpleMessage("TÜHISTA"),
    "moderator_confirm": MessageLookupByLibrary.simpleMessage("Kinnita"),
    "moderator_deactivate_split_screen": MessageLookupByLibrary.simpleMessage(
      "Kas olete kindel, et soovite selle opdelt ekraan seansi lõpetada? Kõik praegu jagatud ekraanid lõpetatakse.",
    ),
    "moderator_exit": MessageLookupByLibrary.simpleMessage("VÄLJU"),
    "moderator_exit_dialog": MessageLookupByLibrary.simpleMessage(
      "Kas olete kindel, et soovite selle moderaatori seansi lõpetada? Kõik esitlejad eemaldatakse.",
    ),
    "moderator_presentersLimit": MessageLookupByLibrary.simpleMessage(
      "Klõpsake ülaltoodud lülitil, et aktiveerida Moderator Mode. Kuni 6 esitlejat saavad liituda.",
    ),
    "moderator_presentersList": MessageLookupByLibrary.simpleMessage(
      "Esitlejad",
    ),
    "moderator_remove": MessageLookupByLibrary.simpleMessage("EEMALDA"),
    "moderator_verifyCode_fail": MessageLookupByLibrary.simpleMessage(
      "Midagi läks valesti. Palun proovige uuesti.",
    ),
    "toast_maximum_split_screen": MessageLookupByLibrary.simpleMessage(
      "On jõudnud maksimaalse opdelt ekraan arvuni.",
    ),
    "update_install_now": MessageLookupByLibrary.simpleMessage("PAIGALDA KOHE"),
    "update_message": MessageLookupByLibrary.simpleMessage(
      "Saadaval on uus tarkvaraversioon",
    ),
    "update_title": MessageLookupByLibrary.simpleMessage("AirSync värskendus"),
    "v3_authorize_prompt_accept": MessageLookupByLibrary.simpleMessage(
      "Nõustu",
    ),
    "v3_authorize_prompt_accept_all": MessageLookupByLibrary.simpleMessage(
      "Nõustu kõigega",
    ),
    "v3_authorize_prompt_decline": MessageLookupByLibrary.simpleMessage(
      "Keeldu",
    ),
        "v3_authorize_prompt_title_launcher":
            MessageLookupByLibrary.simpleMessage(
          "Osalejad soovivad oma ekraani jagada",
        ),
        "v3_broadcast_cast_board_on": MessageLookupByLibrary.simpleMessage(
          "Ülekanne on pooleli",
        ),
        "v3_broadcast_cast_device_on": MessageLookupByLibrary.simpleMessage(
          "Ülekanne on pooleli",
        ),
        "v3_broadcast_indicator": MessageLookupByLibrary.simpleMessage("SEES"),
        "v3_broadcast_multicast_checkbox": MessageLookupByLibrary.simpleMessage(
          "Edasta 10-100 seadmesse",
        ),
        "v3_broadcast_multicast_desc": MessageLookupByLibrary.simpleMessage(
          "Vastuvõtvate seadmete arvu ei saa projektsiooni alustamisel muuta.",
        ),
        "v3_broadcast_multicast_warn": MessageLookupByLibrary.simpleMessage(
          "Muutmiseks katkesta kogu projektsioon.",
        ),
        "v3_cast_to_device_Receiving": MessageLookupByLibrary.simpleMessage(
      "Vastuvõtt",
    ),
    "v3_cast_to_device_list_msg": MessageLookupByLibrary.simpleMessage(
      "Maksimaalselt kuni 10 seadet.",
    ),
    "v3_cast_to_device_menu_or": MessageLookupByLibrary.simpleMessage("Või"),
    "v3_cast_to_device_menu_quick_connect1":
        MessageLookupByLibrary.simpleMessage("Kiirühendus"),
    "v3_cast_to_device_menu_quick_connect2":
        MessageLookupByLibrary.simpleMessage("QR-koodi skaneerimisega"),
    "v3_cast_to_device_menu_title": MessageLookupByLibrary.simpleMessage(
      "Liitu selle ekraani vastuvõtmiseks",
    ),
    "v3_cast_to_device_reached_maximum": MessageLookupByLibrary.simpleMessage(
      "Olete jõudnud maksimaalse piirini.",
    ),
    "v3_cast_to_device_title": MessageLookupByLibrary.simpleMessage(
      "Seadmete loend",
    ),
    "v3_cast_to_device_touch_back": MessageLookupByLibrary.simpleMessage(
      "Tagasiside",
    ),
    "v3_cast_to_device_touch_back_disable":
        MessageLookupByLibrary.simpleMessage("Keela"),
    "v3_cast_to_device_touch_enabled": MessageLookupByLibrary.simpleMessage(
      "Tagasiside",
    ),
    "v3_casting_ended_toast": MessageLookupByLibrary.simpleMessage(
      "Ekraani jagamine on lõppenud.",
    ),
    "v3_casting_time_countdown": m0,
    "v3_casting_time_do_not_extend": MessageLookupByLibrary.simpleMessage(
      "Ärge pikendage",
    ),
    "v3_casting_time_extend": MessageLookupByLibrary.simpleMessage("Laiendada"),
    "v3_casting_time_extend_success_toast":
        MessageLookupByLibrary.simpleMessage("Pikendatud 3 tunni võrra."),
    "v3_download_app_desc": MessageLookupByLibrary.simpleMessage(
      "Skaneeri QR-kood oma iOS-i või Android-seadmega allalaadimiseks",
    ),
    "v3_download_app_desktop": MessageLookupByLibrary.simpleMessage(
      "Parima kasutuskogemuse tagamiseks",
    ),
    "v3_download_app_desktop_hint": MessageLookupByLibrary.simpleMessage(
      "*Käsitsi paigaldaja",
    ),
    "v3_download_app_desktop_store": MessageLookupByLibrary.simpleMessage(
      "Installige MacOS App Store\'i kaudu",
    ),
    "v3_download_app_desktop_store_hint": MessageLookupByLibrary.simpleMessage(
      "*Ainult MacOS-i jaoks",
    ),
    "v3_download_app_desktop_title": MessageLookupByLibrary.simpleMessage(
      "Töölaud",
    ),
    "v3_download_app_entry": MessageLookupByLibrary.simpleMessage(
      "Laadi alla saatjarakendus",
    ),
    "v3_download_app_for_desktop": MessageLookupByLibrary.simpleMessage(
      "Lauaarvutitele",
    ),
    "v3_download_app_for_desktop_desc": MessageLookupByLibrary.simpleMessage(
      "Sisestage järgmine URL allalaadimiseks.",
    ),
    "v3_download_app_for_mobile": MessageLookupByLibrary.simpleMessage(
      "iOS-i ja Androidi jaoks",
    ),
    "v3_download_app_for_mobile_desc": MessageLookupByLibrary.simpleMessage(
      "Skaneerige QR-kood koheseks juurdepääsuks.",
    ),
    "v3_download_app_mobile_title": MessageLookupByLibrary.simpleMessage(
      "Mobiil",
    ),
    "v3_download_app_or": MessageLookupByLibrary.simpleMessage("VÕI"),
    "v3_download_app_title": MessageLookupByLibrary.simpleMessage(
      "Laadi alla saatjarakendus",
    ),
    "v3_eula_agree": MessageLookupByLibrary.simpleMessage("Nõustu"),
    "v3_eula_disagree": MessageLookupByLibrary.simpleMessage("Ei nõustu"),
        "v3_eula_launch": MessageLookupByLibrary.simpleMessage("Käivita"),
        "v3_eula_title": MessageLookupByLibrary.simpleMessage(
      "Lõppkasutaja litsentsileping",
    ),
    "v3_exit_moderator_mode_cancel": MessageLookupByLibrary.simpleMessage(
      "Tühista",
    ),
    "v3_exit_moderator_mode_desc": MessageLookupByLibrary.simpleMessage(
      "Olete kindel? See katkestab kõigi osalejate ühenduse.",
    ),
    "v3_exit_moderator_mode_exit": MessageLookupByLibrary.simpleMessage(
      "Välju",
    ),
    "v3_exit_moderator_mode_title": MessageLookupByLibrary.simpleMessage(
      "Lahku moderaatori režiimist",
    ),
    "v3_group_dialog_accept": MessageLookupByLibrary.simpleMessage("Nõustu"),
    "v3_group_dialog_decline": MessageLookupByLibrary.simpleMessage("Keeldu"),
    "v3_group_dialog_message": MessageLookupByLibrary.simpleMessage(
      "%s on saatnud teie seadmele edastuse taotluse. See toiming sünkroniseerib ja kuvab praeguse sisu. Kas soovite selle taotluse heaks kiita?",
    ),
    "v3_group_dialog_no_device_message": MessageLookupByLibrary.simpleMessage(
      "Ühtegi seadet pole valitud.",
    ),
    "v3_group_dialog_title": MessageLookupByLibrary.simpleMessage(
      "Edastuse taotlus alates %s",
    ),
    "v3_group_receive_view_status_from": MessageLookupByLibrary.simpleMessage(
      "Edastamine alates",
    ),
    "v3_group_receive_view_status_stop": MessageLookupByLibrary.simpleMessage(
      "Peata",
    ),
    "v3_group_reject_invited": MessageLookupByLibrary.simpleMessage(
      "keeldus teie edastustaotlusest, palun kontrollige edastusseadeid.",
    ),
    "v3_help_center_cast_device_title": MessageLookupByLibrary.simpleMessage(
      "Ülekandmine seadmesse",
    ),
    "v3_help_center_cast_device_title_sub":
        MessageLookupByLibrary.simpleMessage(
          "IFP edastab oma ekraani seadmetesse.",
        ),
    "v3_help_center_close": MessageLookupByLibrary.simpleMessage("Sulgema"),
    "v3_help_center_fullscreen_title": MessageLookupByLibrary.simpleMessage(
      "Täisekraan",
    ),
    "v3_help_center_mute_user_title": MessageLookupByLibrary.simpleMessage(
      "Vaigista kasutaja",
    ),
    "v3_help_center_remove_user_title": MessageLookupByLibrary.simpleMessage(
      "Eemalda kasutaja",
    ),
    "v3_help_center_share_title": MessageLookupByLibrary.simpleMessage(
      "Kutsu jagama",
    ),
    "v3_help_center_share_title_sub": MessageLookupByLibrary.simpleMessage(
      "Seadmed, mis jagavad oma ekraani IFP-ga.",
    ),
    "v3_help_center_stop_share_title": MessageLookupByLibrary.simpleMessage(
      "Ühiskasutuse lõpetamine",
    ),
    "v3_help_center_title": MessageLookupByLibrary.simpleMessage("Abi Keskus"),
    "v3_help_center_touchback_title": MessageLookupByLibrary.simpleMessage(
      "Touchback",
    ),
    "v3_help_center_touchback_title_sub": MessageLookupByLibrary.simpleMessage(
      "Kasutaja kaugjuhtimise lubamine.",
    ),
    "v3_help_center_untouchback_title": MessageLookupByLibrary.simpleMessage(
      "Ei Touchback",
    ),
    "v3_help_center_untouchback_title_sub":
        MessageLookupByLibrary.simpleMessage("Ei Touchback"),
    "v3_instruction1a": MessageLookupByLibrary.simpleMessage(
      "Külastage airsync.net või avage saatjarakendus",
    ),
    "v3_instruction1b": MessageLookupByLibrary.simpleMessage(
      "Avage saatjarakendus",
    ),
    "v3_instruction2": MessageLookupByLibrary.simpleMessage(
      "Sisestage kuvakood",
    ),
    "v3_instruction2_onethird": MessageLookupByLibrary.simpleMessage(
      "Kuvakood",
    ),
    "v3_instruction3": MessageLookupByLibrary.simpleMessage(
      "Sisestage ühekordne parool",
    ),
    "v3_instruction3_onethird": MessageLookupByLibrary.simpleMessage(
      "Ühekordne parool",
    ),
    "v3_instruction_share_screen": MessageLookupByLibrary.simpleMessage(
      "Jagage oma ekraane",
    ),
    "v3_instruction_support": MessageLookupByLibrary.simpleMessage(
      "Toetab jagamist AirPlay, Google Cast või Miracast kaudu",
    ),
    "v3_last_casting_time_countdown": MessageLookupByLibrary.simpleMessage(
      "Ekraani jagamine on lõppemas. Vajadusel taaskäivitage ekraani jagamine.",
    ),
    "v3_lbl_authorize_prompt_accept": MessageLookupByLibrary.simpleMessage(
      "Nõustu päringuga",
    ),
    "v3_lbl_authorize_prompt_accept_all": MessageLookupByLibrary.simpleMessage(
      "Võta vastu kõik taotlused",
    ),
    "v3_lbl_authorize_prompt_decline": MessageLookupByLibrary.simpleMessage(
      "Keeldu päringust",
    ),
        "v3_lbl_broadcast_multicast_checkbox":
            MessageLookupByLibrary.simpleMessage(
          "Edasta 10-100 seadmesse",
        ),
        "v3_lbl_cast_device_close": MessageLookupByLibrary.simpleMessage(
      "Sulge seadme ühendus",
    ),
    "v3_lbl_cast_device_next": MessageLookupByLibrary.simpleMessage(
      "Järgmine leht",
    ),
    "v3_lbl_cast_device_previous": MessageLookupByLibrary.simpleMessage(
      "Eelmine lehekülg",
    ),
    "v3_lbl_cast_device_sort_asc": MessageLookupByLibrary.simpleMessage(
      "Sortige tõusvas järjekorras",
    ),
    "v3_lbl_cast_device_sort_desc": MessageLookupByLibrary.simpleMessage(
      "Sordi kahanevas järjekorras",
    ),
    "v3_lbl_cast_device_touchback_disable":
        MessageLookupByLibrary.simpleMessage("Keela seadme touchback"),
    "v3_lbl_cast_device_touchback_enable": MessageLookupByLibrary.simpleMessage(
      "Luba seadme touchback",
    ),
    "v3_lbl_close_download_app_menu": MessageLookupByLibrary.simpleMessage(
      "Sulge allalaaditava saatja rakenduse menüü",
    ),
    "v3_lbl_close_feature_set_cast_device":
        MessageLookupByLibrary.simpleMessage("Sulge seadmete nimekiri"),
    "v3_lbl_close_feature_set_moderator": MessageLookupByLibrary.simpleMessage(
      "Sulge moderaatorite nimekiri",
    ),
    "v3_lbl_close_help_center": MessageLookupByLibrary.simpleMessage(
      "Sulge abikeskus",
    ),
    "v3_lbl_close_streaming_shortcut_menu":
        MessageLookupByLibrary.simpleMessage("Sulge voogedastuse otseteemenüü"),
    "v3_lbl_connection_dialog_close": MessageLookupByLibrary.simpleMessage(
      "Sulge ühenduse oleku dialoog",
    ),
    "v3_lbl_eula_agree": MessageLookupByLibrary.simpleMessage("Nõustu EULA-ga"),
    "v3_lbl_eula_disagree": MessageLookupByLibrary.simpleMessage(
      "Ei nõustu EULA-ga",
    ),
        "v3_lbl_eula_launch": MessageLookupByLibrary.simpleMessage("Käivita"),
        "v3_lbl_exit_moderator_cancel": MessageLookupByLibrary.simpleMessage(
      "Tühista moderaatori režiimist väljumine",
    ),
    "v3_lbl_exit_moderator_exit": MessageLookupByLibrary.simpleMessage(
      "Kinnita moderaatori režiimist väljumine",
    ),
    "v3_lbl_extend_casting_do_not_extend": MessageLookupByLibrary.simpleMessage(
      "Ära pikenda voogedastuse aega",
    ),
    "v3_lbl_extend_casting_extend": MessageLookupByLibrary.simpleMessage(
      "Pikenda voogedastuse aega",
    ),
    "v3_lbl_group_reject_close": MessageLookupByLibrary.simpleMessage(
      "Sulge grupi keeldumise teavitus",
    ),
    "v3_lbl_internet_connection_only_error":
        MessageLookupByLibrary.simpleMessage(
          "Ühenduse tõrge，palun kontrolli seadme võrgu seadeid",
        ),
    "v3_lbl_internet_connection_warning": MessageLookupByLibrary.simpleMessage(
      "Ainult kohalik ühendus",
    ),
    "v3_lbl_main_language_title": MessageLookupByLibrary.simpleMessage(
      "Vali keel",
    ),
    "v3_lbl_main_language_title_item": MessageLookupByLibrary.simpleMessage(
      "Vali %s",
    ),
    "v3_lbl_message_dialog_cancel": MessageLookupByLibrary.simpleMessage(
      "Tühista dialoog",
    ),
    "v3_lbl_message_dialog_confirm": MessageLookupByLibrary.simpleMessage(
      "Kinnita dialoog",
    ),
    "v3_lbl_minimal_quick_connect_menu": MessageLookupByLibrary.simpleMessage(
      "Minimeeri kiire ühenduse menüü",
    ),
    "v3_lbl_minimal_streaming_qrcode_menu":
        MessageLookupByLibrary.simpleMessage(
          "Minimeeri voogedastuse QR-koodi menüü",
        ),
    "v3_lbl_moderator_toggle": MessageLookupByLibrary.simpleMessage(
      "Lülita moderaatori režiimi",
    ),
    "v3_lbl_open_download_app_menu": MessageLookupByLibrary.simpleMessage(
      "Ava allalaaditava saatja rakenduse menüü",
    ),
    "v3_lbl_open_feature_set_cast_device": MessageLookupByLibrary.simpleMessage(
      "Ava seadmete nimekiri",
    ),
    "v3_lbl_open_feature_set_moderator": MessageLookupByLibrary.simpleMessage(
      "Ava moderaatorite nimekiri",
    ),
    "v3_lbl_open_help_center": MessageLookupByLibrary.simpleMessage(
      "Ava abikeskuse menüü",
    ),
    "v3_lbl_open_menu_settings": MessageLookupByLibrary.simpleMessage(
      "Ava seadete menüü",
    ),
    "v3_lbl_open_streaming_qrcode_menu": MessageLookupByLibrary.simpleMessage(
      "Ava voogedastuse QR-koodi menüü",
    ),
    "v3_lbl_open_streaming_shortcut_menu": MessageLookupByLibrary.simpleMessage(
      "Ava voogedastuse otseteemenüü",
    ),
    "v3_lbl_overlay_bring_app_to_top": MessageLookupByLibrary.simpleMessage(
      "Hõljuv ühenduse infokaart",
    ),
    "v3_lbl_overlay_menu_expand": MessageLookupByLibrary.simpleMessage(
      "Laienda ülekatte menüü",
    ),
    "v3_lbl_overlay_menu_minimize": MessageLookupByLibrary.simpleMessage(
      "Minimeeri ülekatte menüü",
    ),
    "v3_lbl_participant_cast_device": MessageLookupByLibrary.simpleMessage(
      "Saada seade sellele osalejale",
    ),
    "v3_lbl_participant_close": MessageLookupByLibrary.simpleMessage(
      "Sulge osaleja ühendus",
    ),
    "v3_lbl_participant_disconnect": MessageLookupByLibrary.simpleMessage(
      "Katkesta selle osaleja ühendus",
    ),
    "v3_lbl_participant_mirror_close": MessageLookupByLibrary.simpleMessage(
      "Sulge peegeldatud osaleja ühendus",
    ),
    "v3_lbl_participant_mirror_share": MessageLookupByLibrary.simpleMessage(
      "Jaga selle osaleja peegeldatud ekraanile",
    ),
    "v3_lbl_participant_mirror_stop": MessageLookupByLibrary.simpleMessage(
      "Peata peegeldatud osaleja voogedastus",
    ),
    "v3_lbl_participant_share": MessageLookupByLibrary.simpleMessage(
      "Jaga selle osaleja ekraanile",
    ),
    "v3_lbl_participant_stop": MessageLookupByLibrary.simpleMessage(
      "Peata osaleja voogedastus",
    ),
    "v3_lbl_participant_touch_back": MessageLookupByLibrary.simpleMessage(
      "Luba sellele osalejale touchback",
    ),
    "v3_lbl_participant_touch_back_disable":
        MessageLookupByLibrary.simpleMessage(
          "Keela sellele osalejale touchback",
        ),
    "v3_lbl_resizable_expand": MessageLookupByLibrary.simpleMessage(
      "Laienda esitlusjuhtimine",
    ),
    "v3_lbl_resizable_minimize": MessageLookupByLibrary.simpleMessage(
      "Minimeeri esitlusjuhtimine",
    ),
    "v3_lbl_resizable_mute": MessageLookupByLibrary.simpleMessage(
      "Vaigista esitlus",
    ),
    "v3_lbl_resizable_stop": MessageLookupByLibrary.simpleMessage(
      "Peata esitlus",
    ),
    "v3_lbl_settings_accessibility": MessageLookupByLibrary.simpleMessage(
      "Juurdepääsetavus",
    ),
    "v3_lbl_settings_back_icon": MessageLookupByLibrary.simpleMessage(
      "Tagasi eelmisele lehele",
    ),
    "v3_lbl_settings_broadcast": MessageLookupByLibrary.simpleMessage(
      "Ava edastuse seadete menüü",
    ),
    "v3_lbl_settings_broadcast_boards": MessageLookupByLibrary.simpleMessage(
      "Ava edastustahvlite menüü",
    ),
    "v3_lbl_settings_broadcast_devices": MessageLookupByLibrary.simpleMessage(
      "Ava edastatavate seadmete menüü",
    ),
    "v3_lbl_settings_broadcast_to_display_group":
        MessageLookupByLibrary.simpleMessage(
          "Ava edastus ekraanigrupile menüü",
        ),
    "v3_lbl_settings_broadcast_to_display_group_cast":
        MessageLookupByLibrary.simpleMessage("Edasta"),
    "v3_lbl_settings_broadcast_to_display_group_checkbox":
        MessageLookupByLibrary.simpleMessage("Vali %s"),
    "v3_lbl_settings_broadcast_to_display_group_confirm":
        MessageLookupByLibrary.simpleMessage(
          "Kinnita, et seadet pole valitud.",
        ),
    "v3_lbl_settings_broadcast_to_display_group_item":
        MessageLookupByLibrary.simpleMessage("Vali %s"),
    "v3_lbl_settings_broadcast_to_display_group_save":
        MessageLookupByLibrary.simpleMessage("Salvesta"),
    "v3_lbl_settings_broadcast_to_display_group_type":
        MessageLookupByLibrary.simpleMessage("Vali %s"),
    "v3_lbl_settings_close_icon": MessageLookupByLibrary.simpleMessage(
      "Sulge seadete menüü",
    ),
    "v3_lbl_settings_connectivity": MessageLookupByLibrary.simpleMessage(
      "Ava ühenduvuse seadete menüü",
    ),
    "v3_lbl_settings_connectivity_item": MessageLookupByLibrary.simpleMessage(
      "Vali %s",
    ),
    "v3_lbl_settings_device_authorize_mode":
        MessageLookupByLibrary.simpleMessage(
          "Lülita autoriseerimise režiim sisse/välja",
        ),
    "v3_lbl_settings_device_auto_fill_otp":
        MessageLookupByLibrary.simpleMessage(
          "Lülita automaatse OTP täitmise režiim sisse/välja",
        ),
    "v3_lbl_settings_device_high_image_quality":
        MessageLookupByLibrary.simpleMessage("Kõrge pildikvaliteet"),
    "v3_lbl_settings_device_launch_on_startup":
        MessageLookupByLibrary.simpleMessage(
          "Lülita automaatse käivitamise režiim sisse/välja",
        ),
    "v3_lbl_settings_device_name": MessageLookupByLibrary.simpleMessage(
      "Muuda seadme nime",
    ),
    "v3_lbl_settings_device_name_close": MessageLookupByLibrary.simpleMessage(
      "Sulge seadme nime seade",
    ),
    "v3_lbl_settings_device_name_save": MessageLookupByLibrary.simpleMessage(
      "Salvesta seadme nimi",
    ),
    "v3_lbl_settings_device_setting": MessageLookupByLibrary.simpleMessage(
      "Ava seadme seadete menüü",
    ),
    "v3_lbl_settings_device_smart_scaling":
        MessageLookupByLibrary.simpleMessage(
          "Lülita nutika skaleerimise lüliti sisse/välja",
        ),
    "v3_lbl_settings_enter_device_name": MessageLookupByLibrary.simpleMessage(
      "Sisesta seadme nimi",
    ),
    "v3_lbl_settings_invite_group": MessageLookupByLibrary.simpleMessage(
      "Ava ekraani edastuse rippmenüü",
    ),
    "v3_lbl_settings_invite_group_item": MessageLookupByLibrary.simpleMessage(
      "Vali %s",
    ),
    "v3_lbl_settings_knowledge_base": MessageLookupByLibrary.simpleMessage(
      "Teadmistepagas",
    ),
    "v3_lbl_settings_legal_policy": MessageLookupByLibrary.simpleMessage(
      "Ava juriidilise poliitika seadete menüü",
    ),
    "v3_lbl_settings_menu_locked": MessageLookupByLibrary.simpleMessage(
      "Seadete menüü on lukustatud",
    ),
    "v3_lbl_settings_mirroring_auto_accept":
        MessageLookupByLibrary.simpleMessage(
          "Lülita acceptera automatiskt sisse/välja",
        ),
    "v3_lbl_settings_mirroring_require_passcode":
        MessageLookupByLibrary.simpleMessage(
          "Lülita nõua pääsukoodi sisse/välja",
        ),
    "v3_lbl_settings_only_when_casting_info":
        MessageLookupByLibrary.simpleMessage(
          "Lisainfo ekraanigrupile edastamise kohta",
        ),
    "v3_lbl_settings_open_source_license": MessageLookupByLibrary.simpleMessage(
      "Vali %s",
    ),
    "v3_lbl_settings_show_display_code": MessageLookupByLibrary.simpleMessage(
      "Lülita kuva koodi lüliti sisse/välja",
    ),
    "v3_lbl_settings_whats_new": MessageLookupByLibrary.simpleMessage(
      "Ava mis on uut seadete menüü",
    ),
    "v3_lbl_settings_whats_new_icon": MessageLookupByLibrary.simpleMessage(
      "mis on uut ikoon",
    ),
    "v3_lbl_shortcuts_airplay": MessageLookupByLibrary.simpleMessage(
      "Lülita AirPlay sisse/välja",
    ),
    "v3_lbl_shortcuts_google_cast": MessageLookupByLibrary.simpleMessage(
      "Lülita Google Cast sisse/välja",
    ),
    "v3_lbl_shortcuts_miracast": MessageLookupByLibrary.simpleMessage(
      "Lülita Miracast sisse/välja",
    ),
    "v3_lbl_shortcuts_mirroring": MessageLookupByLibrary.simpleMessage(
      "Ava peegeldamise seadete menüü",
    ),
    "v3_lbl_streaming_airplay_touchback": MessageLookupByLibrary.simpleMessage(
      "AirPlay touchback",
    ),
    "v3_lbl_streaming_page_control": MessageLookupByLibrary.simpleMessage(
      "Järgmine leht",
    ),
    "v3_lbl_streaming_shortcut_airplay_toggle":
        MessageLookupByLibrary.simpleMessage("AirPlay lüliti"),
    "v3_lbl_streaming_shortcut_cast_device_toggle":
        MessageLookupByLibrary.simpleMessage(
          "Lülita seadmetesse saatmise lüliti",
        ),
    "v3_lbl_streaming_shortcut_expand": MessageLookupByLibrary.simpleMessage(
      "Laienda voogedastuse funktsioonid",
    ),
    "v3_lbl_streaming_shortcut_google_cast_toggle":
        MessageLookupByLibrary.simpleMessage("Google Cast lüliti"),
    "v3_lbl_streaming_shortcut_menu_locked":
        MessageLookupByLibrary.simpleMessage(
          "Voogedastuse otseteemenüü on lukustatud",
        ),
    "v3_lbl_streaming_shortcut_minimize": MessageLookupByLibrary.simpleMessage(
      "Ahenda voogedastuse funktsioonid",
    ),
    "v3_lbl_streaming_shortcut_miracast_toggle":
        MessageLookupByLibrary.simpleMessage("Miracast lüliti"),
    "v3_lbl_streaming_view_expand": MessageLookupByLibrary.simpleMessage(
      "Laienda voogedastuse vaade",
    ),
    "v3_lbl_streaming_view_function_expand":
        MessageLookupByLibrary.simpleMessage(
          "Laiendage voogesituse funktsiooni",
        ),
    "v3_lbl_streaming_view_function_minimize":
        MessageLookupByLibrary.simpleMessage("Ahenda voogesituse funktsioon"),
    "v3_lbl_streaming_view_minimize": MessageLookupByLibrary.simpleMessage(
      "Ahenda voogedastuse vaade",
    ),
    "v3_lbl_streaming_view_mute": MessageLookupByLibrary.simpleMessage(
      "Vaigista heli",
    ),
    "v3_lbl_streaming_view_stop": MessageLookupByLibrary.simpleMessage(
      "Peata voogedastus",
    ),
    "v3_lbl_streaming_view_unmute": MessageLookupByLibrary.simpleMessage(
      "Lülita heli sisse",
    ),
    "v3_lbl_touchback_one_device_cancel": MessageLookupByLibrary.simpleMessage(
      "Tühista dialoog",
    ),
    "v3_lbl_touchback_one_device_confirm": MessageLookupByLibrary.simpleMessage(
      "Kinnita dialoog",
    ),
    "v3_lbl_touchback_restart_bluetooth_btn_cancel":
        MessageLookupByLibrary.simpleMessage("Tühista"),
    "v3_lbl_touchback_restart_bluetooth_btn_restart":
        MessageLookupByLibrary.simpleMessage("Taaskäivita"),
    "v3_main_connection_dialog_close": MessageLookupByLibrary.simpleMessage(
      "Sulge",
    ),
    "v3_main_internet_connection_only": MessageLookupByLibrary.simpleMessage(
      "Ainult internetiühendus。",
    ),
    "v3_main_internet_connection_only_error":
        MessageLookupByLibrary.simpleMessage(
          "Ühenduse tõrge，palun kontrolli seadme võrgu seadeid。",
        ),
    "v3_main_internet_connection_only_error_dialog_desc":
        MessageLookupByLibrary.simpleMessage(
          "Ühenduse tõrge，palun kontrolli seadme võrgu seadeid。",
        ),
    "v3_main_local_connection_only_dialog_desc":
        MessageLookupByLibrary.simpleMessage(
          "Ainult LAN-ühendus，palun kontrolli seadme võrgu seadeid。",
        ),
    "v3_main_status_no_network": MessageLookupByLibrary.simpleMessage(
      "Internetiühendust ei õnnestunud tuvastada. Palun ühendage Wi-Fi või intraneti võrguga ja proovige uuesti.",
    ),
    "v3_miracast_not_support": MessageLookupByLibrary.simpleMessage(
      "Miracast pole hetkel saadaval. Praegune Wi-Fi kanal ei toeta ekraani edastamist.",
    ),
    "v3_miracast_uibc_not_supported_message":
        MessageLookupByLibrary.simpleMessage(
          "See allikas ei toeta Miracasti tagasipöördumist",
        ),
    "v3_mirror_request_passcode": MessageLookupByLibrary.simpleMessage(
      "Pääsukood",
    ),
    "v3_moderator_disable_mirror_cancel": MessageLookupByLibrary.simpleMessage(
      "Tühista",
    ),
    "v3_moderator_disable_mirror_desc": MessageLookupByLibrary.simpleMessage(
      "Peegeldamine keelatakse moderaatori režiimis",
    ),
    "v3_moderator_disable_mirror_ok": MessageLookupByLibrary.simpleMessage(
      "OK",
    ),
    "v3_moderator_disable_mirror_title": MessageLookupByLibrary.simpleMessage(
      "Keela peegeldamine moderaatori režiimis",
    ),
    "v3_moderator_mode": MessageLookupByLibrary.simpleMessage(
      "Moderaatori režiim",
    ),
    "v3_new_sharing_join_session": MessageLookupByLibrary.simpleMessage(
      "liitus sessiooniga",
    ),
    "v3_participant_item_casting": MessageLookupByLibrary.simpleMessage(
      "Edastamine",
    ),
    "v3_participant_item_connected": MessageLookupByLibrary.simpleMessage(
      "Ühendatud",
    ),
    "v3_participant_item_controlling": MessageLookupByLibrary.simpleMessage(
      "Vastuvõtmine + Tagasiside",
    ),
    "v3_participant_item_receiving": MessageLookupByLibrary.simpleMessage(
      "Vastuvõtmine",
    ),
    "v3_participant_item_share": MessageLookupByLibrary.simpleMessage("Jaga"),
    "v3_participant_item_waiting": MessageLookupByLibrary.simpleMessage(
      "Ootan...",
    ),
    "v3_participants_desc": MessageLookupByLibrary.simpleMessage(
      "Maksimaalselt kuni 6 osalejat.",
    ),
    "v3_participants_desc_maximum_9": MessageLookupByLibrary.simpleMessage(
      "Maksimaalselt kuni 9 osalejat.",
    ),
    "v3_participants_title": MessageLookupByLibrary.simpleMessage("Osalejad"),
    "v3_qrcode_quick_connect": MessageLookupByLibrary.simpleMessage(
      "Kiirühendus",
    ),
    "v3_quick_connect_menu_bottom_msg": MessageLookupByLibrary.simpleMessage(
      "Opdelt ekraan aktiveerub, kui kaks või enam kasutajat jagavad ekraane.",
    ),
    "v3_quick_connect_menu_display_code": MessageLookupByLibrary.simpleMessage(
      "Kuvakood",
    ),
    "v3_quick_connect_menu_qrcode": MessageLookupByLibrary.simpleMessage(
      "QR-kood",
    ),
    "v3_setting_passcode_cancel": MessageLookupByLibrary.simpleMessage(
      "Tühista",
    ),
    "v3_setting_passcode_clear": MessageLookupByLibrary.simpleMessage(
      "Tühista",
    ),
    "v3_setting_passcode_confirm": MessageLookupByLibrary.simpleMessage(
      "Kinnita",
    ),
    "v3_setting_passcode_error_description":
        MessageLookupByLibrary.simpleMessage(
          "Kehtetu parool, proovige uuesti.",
        ),
    "v3_setting_passcode_title": MessageLookupByLibrary.simpleMessage(
      "Seadete avamiseks sisestage pääsukood",
    ),
    "v3_settings_accessibility": MessageLookupByLibrary.simpleMessage(
      "Juurdepääsetavus",
    ),
    "v3_settings_all_the_time_info": MessageLookupByLibrary.simpleMessage(
      "Edasta IFP lähtekraan kogu aeg.",
    ),
    "v3_settings_broadcast": MessageLookupByLibrary.simpleMessage("Edasta"),
    "v3_settings_broadcast_boards": MessageLookupByLibrary.simpleMessage(
      "Muudele AirSynci seadmetele",
    ),
    "v3_settings_broadcast_cast_boards": MessageLookupByLibrary.simpleMessage(
      "Edasta tahvlitele",
    ),
    "v3_settings_broadcast_cast_boards_desc": MessageLookupByLibrary.simpleMessage(
      "Jaga oma ekraani kõikidele võrgus olevatele interaktiivsetele ekraanidele (IFP-dele).",
    ),
    "v3_settings_broadcast_cast_to": MessageLookupByLibrary.simpleMessage(
      "Edasta",
    ),
    "v3_settings_broadcast_devices": MessageLookupByLibrary.simpleMessage(
      "Saatjaseadmetele",
    ),
    "v3_settings_broadcast_screen_energy_saving":
        MessageLookupByLibrary.simpleMessage(
          "Palun lülitage energiasäästurežiim välja, et vältida ootamatuid katkestusi edastamise ajal.",
        ),
    "v3_settings_broadcast_to_display_group":
        MessageLookupByLibrary.simpleMessage("Edasta kuvagruppi"),
    "v3_settings_connectivity": MessageLookupByLibrary.simpleMessage(
      "Ühenduvus",
    ),
    "v3_settings_connectivity_both": MessageLookupByLibrary.simpleMessage(
      "Nii interneti- kui ka kohalik ühendus",
    ),
    "v3_settings_connectivity_internet": MessageLookupByLibrary.simpleMessage(
      "Internetiühendus",
    ),
    "v3_settings_connectivity_internet_desc":
        MessageLookupByLibrary.simpleMessage(
          "Internetiühendus nõuab stabiilset võrku.",
        ),
    "v3_settings_connectivity_local": MessageLookupByLibrary.simpleMessage(
      "Kohalik ühendus",
    ),
    "v3_settings_connectivity_local_desc": MessageLookupByLibrary.simpleMessage(
      "Kohalikud ühendused toimivad privaatvõrgus, pakkudes suuremat turvalisust ja stabiilsust.",
    ),
    "v3_settings_device_authorize_mode": MessageLookupByLibrary.simpleMessage(
      "Luba ekraani jagamine ainult kinnitustaotlustega.",
    ),
    "v3_settings_device_auto_fill_otp": MessageLookupByLibrary.simpleMessage(
      "Automaattäida ühekordne parool",
    ),
    "v3_settings_device_auto_fill_otp_desc":
        MessageLookupByLibrary.simpleMessage(
          "Luba ühe puudutusega ühendus, kui valitakse seade seadmete loendist.",
        ),
    "v3_settings_device_high_image_quality":
        MessageLookupByLibrary.simpleMessage("Kõrge pildikvaliteet"),
        "v3_settings_device_high_image_quality_off_desc":
            MessageLookupByLibrary.simpleMessage(
          "Maksimaalne QHD (2K) ekraani jagamine olenevalt saatja ekraani eraldusvõimest.",
        ),
        "v3_settings_device_high_image_quality_on_desc":
            MessageLookupByLibrary.simpleMessage(
          "Maksimaalne UHD (4K) ekraani jagamine veebisaatjalt ja 3K+ Windowsi ja macOS-i saatjalt, olenevalt saatja ekraani eraldusvõimest. Nõuab kvaliteetset võrku.",
        ),
        "v3_settings_device_launch_on_startup":
        MessageLookupByLibrary.simpleMessage("Käivita AirSync automaatselt"),
    "v3_settings_device_name": MessageLookupByLibrary.simpleMessage(
      "Seadme nimi",
    ),
    "v3_settings_device_name_empty_error": MessageLookupByLibrary.simpleMessage(
      "Seadme nimi ei tohi olla tühi",
    ),
    "v3_settings_device_name_save": MessageLookupByLibrary.simpleMessage(
      "Salvesta",
    ),
    "v3_settings_device_not_supported": MessageLookupByLibrary.simpleMessage(
      "Seadme versiooni ei toetata",
    ),
    "v3_settings_device_setting": MessageLookupByLibrary.simpleMessage(
      "Seadme seaded",
    ),
    "v3_settings_device_show_display_code":
        MessageLookupByLibrary.simpleMessage("Näita kuvakoodi ülaosas"),
    "v3_settings_device_show_display_code_desc":
        MessageLookupByLibrary.simpleMessage(
          "Hoia kood nähtaval ekraani ülaosas, isegi teistele rakendustele lülitudes ja ekraani jagamisel.",
        ),
    "v3_settings_device_smart_scaling": MessageLookupByLibrary.simpleMessage(
      "Nutikas skaleerimine",
    ),
    "v3_settings_device_smart_scaling_desc": MessageLookupByLibrary.simpleMessage(
      "Reguleerige ekraani suurust automaatselt, et maksimeerida ekraaniruumi kasutamist. Pilt võib olla veidi moonutatud.",
    ),
    "v3_settings_device_unavailable": MessageLookupByLibrary.simpleMessage(
      "Pole saadaval",
    ),
    "v3_settings_display_group": MessageLookupByLibrary.simpleMessage(
      "Kuvagrupp",
    ),
    "v3_settings_display_group_all_the_time":
        MessageLookupByLibrary.simpleMessage("Kogu aeg"),
    "v3_settings_display_group_cast": MessageLookupByLibrary.simpleMessage(
      "Edasta",
    ),
    "v3_settings_display_group_only_casting":
        MessageLookupByLibrary.simpleMessage("Ainult edastamisel"),
    "v3_settings_feature_locked": MessageLookupByLibrary.simpleMessage(
      "Lukustatud ViewSonic Manageri poolt.",
    ),
    "v3_settings_invite_group": MessageLookupByLibrary.simpleMessage(
      "Kui oled kutsutud kuvagruppi",
    ),
    "v3_settings_invite_group_auto_accept":
        MessageLookupByLibrary.simpleMessage("Acceptera automatiskt"),
    "v3_settings_invite_group_ignore": MessageLookupByLibrary.simpleMessage(
      "Ignoreeri",
    ),
    "v3_settings_invite_group_notify_me": MessageLookupByLibrary.simpleMessage(
      "Teavita mind",
    ),
    "v3_settings_knowledge_base": MessageLookupByLibrary.simpleMessage(
      "Teadmusbaas",
    ),
    "v3_settings_legal_policy": MessageLookupByLibrary.simpleMessage(
      "Õigus ja poliitika",
    ),
    "v3_settings_local_connection_only": MessageLookupByLibrary.simpleMessage(
      "Ainult kohalik ühendus",
    ),
    "v3_settings_mirroring_auto_accept": MessageLookupByLibrary.simpleMessage(
      "Acceptera automatiskt",
    ),
    "v3_settings_mirroring_auto_accept_desc":
        MessageLookupByLibrary.simpleMessage(
          "Luba peegeldamine koheselt ilma moderaatori heakskiiduta.",
        ),
    "v3_settings_mirroring_blocked": MessageLookupByLibrary.simpleMessage(
      "Lülitage esmalt moderaatori režiim välja.",
    ),
    "v3_settings_mirroring_require_passcode":
        MessageLookupByLibrary.simpleMessage("Nõua pääsukoodi"),
    "v3_settings_only_when_casting_info": MessageLookupByLibrary.simpleMessage(
      "Edasta IFP lähtekraan ainult siis, kui see saab jagatud ekraani.",
    ),
    "v3_settings_open_source_license": MessageLookupByLibrary.simpleMessage(
      "Avatud lähtekoodiga litsentsid",
    ),
    "v3_settings_privacy_policy": MessageLookupByLibrary.simpleMessage(
      "Privaatsuspoliitika",
    ),
    "v3_settings_privacy_policy_description": MessageLookupByLibrary.simpleMessage(
      "ViewSonic on pühendunud teie privaatsuse kaitsmisele ja käsitleb isikuandmete töötlemist tõsiselt. Allpool olev privaatsuspoliitika kirjeldab, kuidas ViewSonic töötleb teie isikuandmeid pärast nende kogumist ViewSonicu poolt teie veebisaidi kasutamise kaudu. ViewSonic kaitseb teie teavet turvatehnoloogiate abil ja järgib poliitikaid, mis takistavad teie isikuandmete volitamata kasutamist. Veebisaiti kasutades annate nõusoleku oma teabe kogumiseks ja kasutamiseks.  \n\nVeebisaidid, millele lingite ViewSonic.com-ist, võivad omada oma privaatsuspoliitikat, mis võib erineda ViewSonicu omast. Palun vaadake nende veebisaitide privaatsuspoliitikat, et saada üksikasjalikku teavet selle kohta, kuidas nad võivad teie teavet kasutada.  \n\nPalun klõpsake allolevatel linkidel, et saada rohkem teavet meie privaatsuspoliitika kohta.  ",
    ),
    "v3_settings_resize_text_size": MessageLookupByLibrary.simpleMessage(
      "Muuda tekstisuurust",
    ),
    "v3_settings_resize_text_size_extra_large":
        MessageLookupByLibrary.simpleMessage("Väga suur"),
    "v3_settings_resize_text_size_large": MessageLookupByLibrary.simpleMessage(
      "Suur",
    ),
    "v3_settings_resize_text_size_normal": MessageLookupByLibrary.simpleMessage(
      "Tavaline",
    ),
    "v3_settings_version": m1,
    "v3_settings_whats_new": MessageLookupByLibrary.simpleMessage("Mis on uut"),
    "v3_settings_whats_new_content": MessageLookupByLibrary.simpleMessage(
      "AirSync %s\n\nAirSync on ViewSonicu patenteeritud juhtmevaba ekraanijagamislahendus. Kui seda kasutatakse koos AirSynci saatjaga, võimaldab see kasutajatel oma ekraane sujuvalt jagada ViewSonicu interaktiivsete ekraanidega.\n\nSee väljalase sisaldab järgmisi uusi funktsioone.\n\n1. ViewSonicu LED-ekraanide tugi.\n\n2. Touchback-funktsioon Android-seadmetele IFP-s.\n\n3. Touchbacki funktsioon iPadidele AirPlay kaudu jagamisel.\n\n4. Nutikas skaleerimine.\n\n5. Võimalus muuta seadmesse ülekandmise akna suurust.\n\n6. Miracasti suurem stabiilsus.\n\n7. Parandatud mitmesugused vead.",
    ),
    "v3_shortcuts_airplay": MessageLookupByLibrary.simpleMessage("AirPlay"),
    "v3_shortcuts_cast_device": MessageLookupByLibrary.simpleMessage(
      "Edastage seadmetele",
    ),
    "v3_shortcuts_cast_device_desc": MessageLookupByLibrary.simpleMessage(
      "Edastage oma ekraan mitmele seadmele, sealhulgas sülearvutitele, tahvelarvutitele ja mobiilseadmetele samaaegselt.",
    ),
    "v3_shortcuts_google_cast": MessageLookupByLibrary.simpleMessage(
      "Google Cast",
    ),
    "v3_shortcuts_menu_title": MessageLookupByLibrary.simpleMessage("Otseteed"),
    "v3_shortcuts_miracast": MessageLookupByLibrary.simpleMessage("Miracast"),
    "v3_shortcuts_mirroring": MessageLookupByLibrary.simpleMessage(
      "Peegeldamine",
    ),
    "v3_touchback_alert_message": MessageLookupByLibrary.simpleMessage(
      "Saad kasutada touchbacki ainult ühel seadmel korraga.",
    ),
    "v3_touchback_alert_title": MessageLookupByLibrary.simpleMessage(
      "Touchback seadmele %s？",
    ),
    "v3_touchback_disable_message": MessageLookupByLibrary.simpleMessage(
      "TouchBack on keelatud.",
    ),
    "v3_touchback_fail_message": MessageLookupByLibrary.simpleMessage(
      "Sidumine ebaõnnestus. TouchBack pole aktiveeritud. Palun proovi uuesti",
    ),
    "v3_touchback_restart_bluetooth_btn_cancel":
        MessageLookupByLibrary.simpleMessage("Tühista"),
    "v3_touchback_restart_bluetooth_btn_restart":
        MessageLookupByLibrary.simpleMessage("Taaskäivita"),
    "v3_touchback_restart_bluetooth_message": MessageLookupByLibrary.simpleMessage(
      "Toimingu ajapiirang. Lülita suurel ekraanil Bluetooth välja ja seejärel uuesti sisse, ning taaskäivita touchback.",
    ),
    "v3_touchback_restart_bluetooth_title":
        MessageLookupByLibrary.simpleMessage(
          "Toimingu ajapiirang, taaskäivita Bluetooth",
        ),
    "v3_touchback_state_deviceFinding_message":
        MessageLookupByLibrary.simpleMessage("Seadme otsimine"),
    "v3_touchback_state_deviceFoundSuccess_message":
        MessageLookupByLibrary.simpleMessage("Seade leitud edukalt"),
    "v3_touchback_state_devicePairedSuccess_message":
        MessageLookupByLibrary.simpleMessage("Seade seotud edukalt"),
    "v3_touchback_state_devicePairing_message":
        MessageLookupByLibrary.simpleMessage("Seadme sidumine"),
    "v3_touchback_state_hidConnected_message":
        MessageLookupByLibrary.simpleMessage("Hid ühendatud"),
    "v3_touchback_state_hidConnecting_message":
        MessageLookupByLibrary.simpleMessage("Hid ühendamine"),
    "v3_touchback_state_hidProfileServiceStartedSuccess_message":
        MessageLookupByLibrary.simpleMessage(
          "Hid Profile Service käivitatud edukalt",
        ),
    "v3_touchback_state_hidProfileServiceStarting_message":
        MessageLookupByLibrary.simpleMessage("Hid Profile Service käivitamine"),
    "v3_touchback_state_initialized_message":
        MessageLookupByLibrary.simpleMessage("Alglaaditud"),
    "v3_touchback_state_initializing_message":
        MessageLookupByLibrary.simpleMessage("Alglaadimine"),
    "v3_touchback_success_message": MessageLookupByLibrary.simpleMessage(
      "Nüüd saad juhtida seadet %s eemalt IFP kaudu.",
    ),
    "v3_waiting_desc": MessageLookupByLibrary.simpleMessage(
      "Ootab selle osaleja ekraani jagamist",
    ),
    "v3_waiting_join": MessageLookupByLibrary.simpleMessage(
      "Ootab teiste liitumist",
    ),
    "v3_waiting_up_next": MessageLookupByLibrary.simpleMessage("Järgmine"),
    "vbs_ota_progress_msg": MessageLookupByLibrary.simpleMessage(
      "Süsteemivärskenduste allalaadimine",
    ),
  };
}
