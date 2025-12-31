// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a lt locale. All the
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
  String get localeName => 'lt';

  static String m0(value) =>
      "Ekrano bendrinimas netrukus baigsis. Ar norėtumėte jį pratęsti 3 valandomis? Galite pratęsti iki ${value} kartų.";

  static String m1(year, version) => "AirSync ©${year}. version ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "eula_agree": MessageLookupByLibrary.simpleMessage("Sutinku"),
    "eula_disagree": MessageLookupByLibrary.simpleMessage("Nesutinku"),
    "eula_title": MessageLookupByLibrary.simpleMessage(
      "AirSync galutinio vartotojo licencijos sutartis (EULA)",
    ),
    "main_airplay_pin_code": MessageLookupByLibrary.simpleMessage(
      "AirPlay kodas",
    ),
    "main_auto_startup": MessageLookupByLibrary.simpleMessage(
      "Paleisti AirSync paleidžiant sistemą",
    ),
    "main_cast_settings_airplay": MessageLookupByLibrary.simpleMessage(
      "AirPlay",
    ),
    "main_cast_settings_device_name": MessageLookupByLibrary.simpleMessage(
      "Pavadinimas",
    ),
    "main_cast_settings_google_cast": MessageLookupByLibrary.simpleMessage(
      "Google Cast",
    ),
    "main_cast_settings_miracast": MessageLookupByLibrary.simpleMessage(
      "Miracast",
    ),
    "main_cast_settings_title": MessageLookupByLibrary.simpleMessage(
      "Srautinio perdavimo nustatymai",
    ),
    "main_content_display_code": MessageLookupByLibrary.simpleMessage(
      "Ekrano kodas",
    ),
    "main_content_lan_only": MessageLookupByLibrary.simpleMessage(
      "Tik LAN ryšys",
    ),
    "main_content_one_time_password": MessageLookupByLibrary.simpleMessage(
      "Vienkartinis slaptažodis",
    ),
    "main_content_one_time_password_get_fail": MessageLookupByLibrary.simpleMessage(
      "Nepavyko atnaujinti slaptažodžio.  \nPalaukite 30 sekundžių prieš bandydami dar kartą.  ",
    ),
    "main_feature_no_network_warning": MessageLookupByLibrary.simpleMessage(
      "Valdymo ryšys atjungtas. Prašome prisijungti iš naujo",
    ),
    "main_feature_reconnect_fail_toast": MessageLookupByLibrary.simpleMessage(
      "Tinklas (Valdymas) nepavyko prisijungti iš naujo",
    ),
    "main_feature_reconnect_success_toast":
        MessageLookupByLibrary.simpleMessage(
          "Tinklas (Valdymas) sėkmingai prisijungė iš naujo",
        ),
    "main_feature_reconnecting_toast": MessageLookupByLibrary.simpleMessage(
      "Tinklas (Valdymas) vėl prisijungia",
    ),
    "main_get_display_code_failure": MessageLookupByLibrary.simpleMessage(
      "Nepavyko gauti ekrano kodo. Palaukite, kol tinklo ryšys atsistatys, arba paleiskite programą iš naujo.",
    ),
    "main_language_name": MessageLookupByLibrary.simpleMessage("Anglų"),
    "main_language_title": MessageLookupByLibrary.simpleMessage("Kalba"),
    "main_limit_time_message": MessageLookupByLibrary.simpleMessage(
      "Likę 5 minutės",
    ),
    "main_mirror_from_client": MessageLookupByLibrary.simpleMessage(
      "%s nori pasidalinti savo ekranu.",
    ),
    "main_mirror_prompt_accept": MessageLookupByLibrary.simpleMessage(
      "Priimti",
    ),
    "main_mirror_prompt_cancel": MessageLookupByLibrary.simpleMessage(
      "Atšaukti",
    ),
    "main_register_display_code_failure": MessageLookupByLibrary.simpleMessage(
      "Nepavyko gauti ekrano kodo ir vienkartinio slaptažodžio. Tai gali būti dėl tinklo arba serverio problemos. Bandykite vėliau, kai ryšys bus atkurtas.",
    ),
    "main_settings_airplay_code": MessageLookupByLibrary.simpleMessage(
      "AirPlay kodas",
    ),
    "main_settings_device_list": MessageLookupByLibrary.simpleMessage(
      "Greito ryšio slaptažodis",
    ),
    "main_settings_device_name": MessageLookupByLibrary.simpleMessage(
      "Pavadinimas",
    ),
    "main_settings_device_name_cancel": MessageLookupByLibrary.simpleMessage(
      "ATŠAUKTI",
    ),
    "main_settings_device_name_hint": MessageLookupByLibrary.simpleMessage(
      "Pavadinimas",
    ),
    "main_settings_device_name_save": MessageLookupByLibrary.simpleMessage(
      "IŠSAUGOTI",
    ),
    "main_settings_device_name_title": MessageLookupByLibrary.simpleMessage(
      "Pervadinti įrenginį",
    ),
    "main_settings_language": MessageLookupByLibrary.simpleMessage("Kalba"),
    "main_settings_mirror_confirmation": MessageLookupByLibrary.simpleMessage(
      "Veidrodinio atvaizdavimo patvirtinimas",
    ),
    "main_settings_pin_visible": MessageLookupByLibrary.simpleMessage(
      "Ryšio informacija",
    ),
    "main_settings_share_to_sender": MessageLookupByLibrary.simpleMessage(
      "Bendrinti ekraną įrenginyje",
    ),
    "main_settings_share_to_sender_limit_desc":
        MessageLookupByLibrary.simpleMessage(
          "Bendrinti ekraną iki 10 siuntėjų.",
        ),
    "main_settings_title": MessageLookupByLibrary.simpleMessage("Nustatymai"),
    "main_settings_whats_new": MessageLookupByLibrary.simpleMessage(
      "Kas naujo?",
    ),
    "main_split_screen_question": MessageLookupByLibrary.simpleMessage(
      "Spustelėkite aukščiau esantį perjungiklį, kad įjungtumėte padalinto ekrano režimą. Iki 4 dalyvių gali pristatyti vienu metu.",
    ),
    "main_split_screen_title": MessageLookupByLibrary.simpleMessage(
      "Padalintas ekranas",
    ),
    "main_split_screen_waiting": MessageLookupByLibrary.simpleMessage(
      "Padalinto ekrano funkcija įjungta. Laukiama, kol pranešėjas pasidalins ekranu...",
    ),
    "main_status_go_background": MessageLookupByLibrary.simpleMessage(
      "AirSync programa veikia fone.",
    ),
    "main_status_no_network": MessageLookupByLibrary.simpleMessage(
      "Aptiktas prastas tinklo ryšys.  \nPrašome patikrinti savo ryšį.  ",
    ),
    "main_status_remaining_time": MessageLookupByLibrary.simpleMessage(
      "%02d min : %02d sek",
    ),
    "main_thanks_content": MessageLookupByLibrary.simpleMessage(
      "Ačiū, kad naudojatės AirSync.",
    ),
    "main_wait_title": MessageLookupByLibrary.simpleMessage(
      "Laukiama, kol pranešėjas pasidalins ekranu...",
    ),
    "main_wait_up_next": MessageLookupByLibrary.simpleMessage("TOLIAU"),
    "main_webrtc_reconnect_fail_toast": MessageLookupByLibrary.simpleMessage(
      "Tinklas (WebRTC) nepavyko prisijungti iš naujo",
    ),
    "main_webrtc_reconnect_success_toast": MessageLookupByLibrary.simpleMessage(
      "Tinklas (WebRTC) sėkmingai prisijungė iš naujo",
    ),
    "main_webrtc_reconnecting_toast": MessageLookupByLibrary.simpleMessage(
      "Tinklas (WebRTC) vėl prisijungia",
    ),
    "main_whats_new_content": MessageLookupByLibrary.simpleMessage(
      "[Patobulinimai]  \n\n1. Visi skaitmeniniai ekrano kodai geresnei patirčiai.  \n\n2. Pagerintas ryšio stabilumas.  \n\n3. Ištaisyti klaidų.  ",
    ),
    "main_whats_new_title": MessageLookupByLibrary.simpleMessage(
      "Kas naujo AirSync?",
    ),
    "moderator_activate_split_screen": MessageLookupByLibrary.simpleMessage(
      "Spustelėkite aukščiau esantį perjungiklį, kad įjungtumėte padalinto ekrano režimą. Iki 4 dalyvių gali pristatyti vienu metu.",
    ),
    "moderator_cancel": MessageLookupByLibrary.simpleMessage("ATŠAUKTI"),
    "moderator_confirm": MessageLookupByLibrary.simpleMessage("Patvirtinti"),
    "moderator_deactivate_split_screen": MessageLookupByLibrary.simpleMessage(
      "Ar tikrai norite baigti šią padalinto ekrano sesiją? Visi šiuo metu bendrinami ekranai bus nutraukti.",
    ),
    "moderator_exit": MessageLookupByLibrary.simpleMessage("IŠEITI"),
    "moderator_exit_dialog": MessageLookupByLibrary.simpleMessage(
      "Ar tikrai norite baigti šią moderatoriaus sesiją? Visi pranešėjai bus pašalinti.",
    ),
    "moderator_presentersLimit": MessageLookupByLibrary.simpleMessage(
      "Spustelėkite aukščiau esantį perjungiklį, kad įjungtumėte moderatoriaus režimą. Iki 6 pranešėjų gali prisijungti.",
    ),
    "moderator_presentersList": MessageLookupByLibrary.simpleMessage(
      "Pranešėjai",
    ),
    "moderator_remove": MessageLookupByLibrary.simpleMessage("PAŠALINTI"),
    "moderator_verifyCode_fail": MessageLookupByLibrary.simpleMessage(
      "Kažkas nepavyko. Bandykite dar kartą.",
    ),
    "toast_maximum_split_screen": MessageLookupByLibrary.simpleMessage(
      "Pasiektas maksimalus padalinto ekrano kiekis.",
    ),
    "update_install_now": MessageLookupByLibrary.simpleMessage("ĮDIEGTI DABAR"),
    "update_message": MessageLookupByLibrary.simpleMessage(
      "Yra prieinama nauja programinės įrangos versija",
    ),
    "update_title": MessageLookupByLibrary.simpleMessage(
      "AirSync atnaujinimas",
    ),
    "v3_authorize_prompt_accept": MessageLookupByLibrary.simpleMessage(
      "Sutikti",
    ),
    "v3_authorize_prompt_accept_all": MessageLookupByLibrary.simpleMessage(
      "Priimti viską",
    ),
    "v3_authorize_prompt_decline": MessageLookupByLibrary.simpleMessage(
      "Atsisakyti",
    ),
    "v3_authorize_prompt_notification_cast": MessageLookupByLibrary.simpleMessage(
      "Panaikinkite žymėjimą „Reikalauti patvirtinimo“ nustatymų meniu, kad priimtumėte visus transliacijos užklausas.",
    ),
    "v3_authorize_prompt_notification_mirror": MessageLookupByLibrary.simpleMessage(
      "Pažymėkite „Automatiškai priimti“ nustatymų meniu, kad priimtumėte visus veidrodinio atvaizdavimo užklausas.",
    ),
    "v3_authorize_prompt_title_launcher": MessageLookupByLibrary.simpleMessage(
      "Dalyviai norėtų pasidalinti savo ekranu",
    ),
    "v3_broadcast_cast_board_on": MessageLookupByLibrary.simpleMessage(
      "Transliacija vyksta",
    ),
    "v3_broadcast_cast_device_on": MessageLookupByLibrary.simpleMessage(
      "Transliacija vyksta",
    ),
    "v3_broadcast_indicator": MessageLookupByLibrary.simpleMessage("ĮJUNGTA"),
    "v3_broadcast_multicast_checkbox": MessageLookupByLibrary.simpleMessage(
      "Transliuoti į 10–100 įrenginių",
    ),
    "v3_broadcast_multicast_desc": MessageLookupByLibrary.simpleMessage(
      "Prasidėjus projekcijai, priimančių įrenginių skaičiaus pakeisti negalima.",
    ),
    "v3_broadcast_multicast_warn": MessageLookupByLibrary.simpleMessage(
      "Norėdami redaguoti, nutraukite visą projekciją.",
    ),
    "v3_cast_to_device_Receiving": MessageLookupByLibrary.simpleMessage(
      "Gavimas",
    ),
    "v3_cast_to_device_list_msg": MessageLookupByLibrary.simpleMessage(
      "Maksimaliai iki 10 įrenginių.",
    ),
    "v3_cast_to_device_menu_or": MessageLookupByLibrary.simpleMessage("Arba"),
    "v3_cast_to_device_menu_quick_connect1":
        MessageLookupByLibrary.simpleMessage("Greitas prisijungimas"),
    "v3_cast_to_device_menu_quick_connect2":
        MessageLookupByLibrary.simpleMessage("nuskenuokite QR kodą"),
    "v3_cast_to_device_menu_title": MessageLookupByLibrary.simpleMessage(
      "Prisijunkite, kad gautumėte šį ekraną",
    ),
    "v3_cast_to_device_reached_maximum": MessageLookupByLibrary.simpleMessage(
      "Pasiekėte maksimalų limitą.",
    ),
    "v3_cast_to_device_title": MessageLookupByLibrary.simpleMessage(
      "Įrenginių sąrašas",
    ),
    "v3_cast_to_device_touch_back": MessageLookupByLibrary.simpleMessage(
      "Grįžtamasis ryšys",
    ),
    "v3_cast_to_device_touch_back_disable":
        MessageLookupByLibrary.simpleMessage("Išjungti"),
    "v3_cast_to_device_touch_enabled": MessageLookupByLibrary.simpleMessage(
      "Grįžtamasis ryšys",
    ),
    "v3_casting_ended_toast": MessageLookupByLibrary.simpleMessage(
      "Ekrano bendrinimas baigėsi.",
    ),
    "v3_casting_time_countdown": m0,
    "v3_casting_time_do_not_extend": MessageLookupByLibrary.simpleMessage(
      "Negalima pratęsti",
    ),
    "v3_casting_time_extend": MessageLookupByLibrary.simpleMessage("Išplėsti"),
    "v3_casting_time_extend_success_toast":
        MessageLookupByLibrary.simpleMessage("Pratęstas 3 valandoms."),
    "v3_download_app_desc": MessageLookupByLibrary.simpleMessage(
      "Nuskenuokite QR kodą su savo iOS ar Android įrenginiu, kad atsisiųstumėte",
    ),
    "v3_download_app_desktop": MessageLookupByLibrary.simpleMessage(
      "Už geriausią vartotojo patirtį!",
    ),
    "v3_download_app_desktop_hint": MessageLookupByLibrary.simpleMessage(
      "*Rankinis diegimo įrenginys",
    ),
    "v3_download_app_desktop_store": MessageLookupByLibrary.simpleMessage(
      "Įdiekite \"MacOS\" per \"App Store\".",
    ),
    "v3_download_app_desktop_store_hint": MessageLookupByLibrary.simpleMessage(
      "*Tik \"MacOS\"",
    ),
    "v3_download_app_desktop_title": MessageLookupByLibrary.simpleMessage(
      "Darbalaukis",
    ),
    "v3_download_app_entry": MessageLookupByLibrary.simpleMessage(
      "Atsisiųsti siuntėjo programėlę",
    ),
    "v3_download_app_for_desktop": MessageLookupByLibrary.simpleMessage(
      "Darbalaukiui",
    ),
    "v3_download_app_for_desktop_desc": MessageLookupByLibrary.simpleMessage(
      "Įveskite šį URL, kad atsisiųstumėte.",
    ),
    "v3_download_app_for_mobile": MessageLookupByLibrary.simpleMessage(
      "iOS ir Android įrenginiams",
    ),
    "v3_download_app_for_mobile_desc": MessageLookupByLibrary.simpleMessage(
      "Nuskenuokite QR kodą greitai prieigai.",
    ),
    "v3_download_app_mobile_title": MessageLookupByLibrary.simpleMessage(
      "Mobilus",
    ),
    "v3_download_app_or": MessageLookupByLibrary.simpleMessage("ARBA"),
    "v3_download_app_title": MessageLookupByLibrary.simpleMessage(
      "Atsisiųsti siuntėjo programėlę",
    ),
    "v3_eula_agree": MessageLookupByLibrary.simpleMessage("Sutinku"),
    "v3_eula_disagree": MessageLookupByLibrary.simpleMessage("Nesutinku"),
    "v3_eula_launch": MessageLookupByLibrary.simpleMessage("Paleisti"),
    "v3_eula_title": MessageLookupByLibrary.simpleMessage(
      "Galutinio vartotojo licencijos sutartis",
    ),
    "v3_exit_moderator_mode_cancel": MessageLookupByLibrary.simpleMessage(
      "Atšaukti",
    ),
    "v3_exit_moderator_mode_desc": MessageLookupByLibrary.simpleMessage(
      "Ar tikrai? Tai atjungs visus dalyvius.",
    ),
    "v3_exit_moderator_mode_exit": MessageLookupByLibrary.simpleMessage(
      "Išeiti",
    ),
    "v3_exit_moderator_mode_title": MessageLookupByLibrary.simpleMessage(
      "Išeiti iš moderatoriaus režimo",
    ),
    "v3_group_dialog_accept": MessageLookupByLibrary.simpleMessage("Priimti"),
    "v3_group_dialog_decline": MessageLookupByLibrary.simpleMessage("Atmesti"),
    "v3_group_dialog_message": MessageLookupByLibrary.simpleMessage(
      "%s išsiuntė transliacijos užklausą jūsų įrenginiui. Šis veiksmas sinchronizuos ir rodys dabartinį turinį. Ar norite priimti šią užklausą?",
    ),
    "v3_group_dialog_no_device_message": MessageLookupByLibrary.simpleMessage(
      "Įrenginys nepasirinktas.",
    ),
    "v3_group_dialog_title": MessageLookupByLibrary.simpleMessage(
      "Transliacijos užklausa iš %s",
    ),
    "v3_group_receive_view_status_from": MessageLookupByLibrary.simpleMessage(
      "Transliuojama iš",
    ),
    "v3_group_receive_view_status_stop": MessageLookupByLibrary.simpleMessage(
      "Sustabdyti",
    ),
    "v3_group_reject_invited": MessageLookupByLibrary.simpleMessage(
      "atsisakė jūsų transliacijos užklausos, patikrinkite transliacijos nustatymus.",
    ),
    "v3_help_center_cast_device_title": MessageLookupByLibrary.simpleMessage(
      "Perduoti į įrenginį",
    ),
    "v3_help_center_cast_device_title_sub":
        MessageLookupByLibrary.simpleMessage(
          "IFP perduoda savo ekraną į įrenginius.",
        ),
    "v3_help_center_close": MessageLookupByLibrary.simpleMessage("Uždaryti"),
    "v3_help_center_fullscreen_title": MessageLookupByLibrary.simpleMessage(
      "Visas ekranas",
    ),
    "v3_help_center_mute_user_title": MessageLookupByLibrary.simpleMessage(
      "Nutildyti vartotoją",
    ),
    "v3_help_center_remove_user_title": MessageLookupByLibrary.simpleMessage(
      "Pašalinti vartotoją",
    ),
    "v3_help_center_share_title": MessageLookupByLibrary.simpleMessage(
      "Kvietimas bendrinti",
    ),
    "v3_help_center_share_title_sub": MessageLookupByLibrary.simpleMessage(
      "Įrenginiai, bendrinantys ekraną su IFP.",
    ),
    "v3_help_center_stop_share_title": MessageLookupByLibrary.simpleMessage(
      "Bendrinimo sustabdymas",
    ),
    "v3_help_center_title": MessageLookupByLibrary.simpleMessage(
      "Pagalbos Centras",
    ),
    "v3_help_center_touchback_title": MessageLookupByLibrary.simpleMessage(
      "Touchback",
    ),
    "v3_help_center_touchback_title_sub": MessageLookupByLibrary.simpleMessage(
      "Leidimas vartotojui valdyti nuotolinio valdymo pultą.",
    ),
    "v3_help_center_untouchback_title": MessageLookupByLibrary.simpleMessage(
      "Ne Touchback",
    ),
    "v3_help_center_untouchback_title_sub":
        MessageLookupByLibrary.simpleMessage("Ne Touchback"),
    "v3_instruction1a": MessageLookupByLibrary.simpleMessage(
      "Apsilankykite airsync.net arba atidarykite siuntėjo programėlę",
    ),
    "v3_instruction1b": MessageLookupByLibrary.simpleMessage(
      "Atidarykite siuntėjo programėlę",
    ),
    "v3_instruction2": MessageLookupByLibrary.simpleMessage(
      "Įveskite ekrano kodą",
    ),
    "v3_instruction2_onethird": MessageLookupByLibrary.simpleMessage(
      "Ekrano kodas",
    ),
    "v3_instruction3": MessageLookupByLibrary.simpleMessage(
      "Įveskite vienkartinį slaptažodį",
    ),
    "v3_instruction3_onethird": MessageLookupByLibrary.simpleMessage(
      "Vienkartinis slaptažodis",
    ),
    "v3_instruction_share_screen": MessageLookupByLibrary.simpleMessage(
      "Bendrinkite savo ekranus",
    ),
    "v3_instruction_support": MessageLookupByLibrary.simpleMessage(
      "Palaikomas bendrinimas per AirPlay, Google Cast arba Miracast",
    ),
    "v3_last_casting_time_countdown": MessageLookupByLibrary.simpleMessage(
      "Ekrano bendrinimas netrukus baigsis. Jei reikia, iš naujo paleiskite ekrano bendrinimą.",
    ),
    "v3_lbl_authorize_prompt_accept": MessageLookupByLibrary.simpleMessage(
      "Priimti užklausą",
    ),
    "v3_lbl_authorize_prompt_accept_all": MessageLookupByLibrary.simpleMessage(
      "Priimkite visas užklausas",
    ),
    "v3_lbl_authorize_prompt_decline": MessageLookupByLibrary.simpleMessage(
      "Atmetimo užklausa",
    ),
    "v3_lbl_broadcast_multicast_checkbox": MessageLookupByLibrary.simpleMessage(
      "Transliuoti į 10–100 įrenginių",
    ),
    "v3_lbl_cast_device_close": MessageLookupByLibrary.simpleMessage(
      "Uždarykite perdavimo įrenginio ryšį",
    ),
    "v3_lbl_cast_device_next": MessageLookupByLibrary.simpleMessage(
      "Kitas puslapis",
    ),
    "v3_lbl_cast_device_previous": MessageLookupByLibrary.simpleMessage(
      "Ankstesnis puslapis",
    ),
    "v3_lbl_cast_device_sort_asc": MessageLookupByLibrary.simpleMessage(
      "Rūšiuoti didėjančia tvarka",
    ),
    "v3_lbl_cast_device_sort_desc": MessageLookupByLibrary.simpleMessage(
      "Rūšiuoti mažėjančia tvarka",
    ),
    "v3_lbl_cast_device_touchback_disable":
        MessageLookupByLibrary.simpleMessage(
          "Išjunkite \"Cast\" įrenginio jutiklinį grąžinimą",
        ),
    "v3_lbl_cast_device_touchback_enable": MessageLookupByLibrary.simpleMessage(
      "Įgalinkite perdavimo įrenginio jutiklinį grąžinimą",
    ),
    "v3_lbl_close_download_app_menu": MessageLookupByLibrary.simpleMessage(
      "Uždarykite atsisiuntimo siuntėjo programos meniu",
    ),
    "v3_lbl_close_feature_set_cast_device":
        MessageLookupByLibrary.simpleMessage(
          "Uždarykite perdavimo įrenginių sąrašą",
        ),
    "v3_lbl_close_feature_set_moderator": MessageLookupByLibrary.simpleMessage(
      "Uždaryti moderatorių sąrašą",
    ),
    "v3_lbl_close_help_center": MessageLookupByLibrary.simpleMessage(
      "Uždaryti pagalbos centrą",
    ),
    "v3_lbl_close_streaming_shortcut_menu":
        MessageLookupByLibrary.simpleMessage(
          "Uždarykite srautinio perdavimo nuorodų meniu",
        ),
    "v3_lbl_connection_dialog_close": MessageLookupByLibrary.simpleMessage(
      "Dialogo langas Uždaryti ryšio būseną",
    ),
    "v3_lbl_eula_agree": MessageLookupByLibrary.simpleMessage(
      "Sutinku su EULA",
    ),
    "v3_lbl_eula_disagree": MessageLookupByLibrary.simpleMessage(
      "Nesutinka su EULA",
    ),
    "v3_lbl_eula_launch": MessageLookupByLibrary.simpleMessage("Paleisti"),
    "v3_lbl_exit_moderator_cancel": MessageLookupByLibrary.simpleMessage(
      "Atšaukti išeinantį moderatoriaus režimą",
    ),
    "v3_lbl_exit_moderator_exit": MessageLookupByLibrary.simpleMessage(
      "Patvirtinkite išeinantį moderatoriaus režimą",
    ),
    "v3_lbl_extend_casting_do_not_extend": MessageLookupByLibrary.simpleMessage(
      "Nepratęskite liejimo laiko",
    ),
    "v3_lbl_extend_casting_extend": MessageLookupByLibrary.simpleMessage(
      "Prailginkite liejimo laiką",
    ),
    "v3_lbl_group_reject_close": MessageLookupByLibrary.simpleMessage(
      "Uždaryti grupės atmetimo pranešimą",
    ),
    "v3_lbl_internet_connection_only_error":
        MessageLookupByLibrary.simpleMessage(
          "Ryšio klaida, patikrinkite įrenginio tinklo nustatymą",
        ),
    "v3_lbl_internet_connection_warning": MessageLookupByLibrary.simpleMessage(
      "Tik vietinis ryšys",
    ),
    "v3_lbl_main_language_title": MessageLookupByLibrary.simpleMessage(
      "Pasirinkite kalbą",
    ),
    "v3_lbl_main_language_title_item": MessageLookupByLibrary.simpleMessage(
      "Pasirinkite %s",
    ),
    "v3_lbl_message_dialog_cancel": MessageLookupByLibrary.simpleMessage(
      "Atšaukimo dialogo langas",
    ),
    "v3_lbl_message_dialog_confirm": MessageLookupByLibrary.simpleMessage(
      "Patvirtinimo dialogo langas",
    ),
    "v3_lbl_minimal_quick_connect_menu": MessageLookupByLibrary.simpleMessage(
      "Sumažinkite greito prisijungimo meniu",
    ),
    "v3_lbl_minimal_streaming_qrcode_menu":
        MessageLookupByLibrary.simpleMessage(
          "Sumažinkite srautinio perdavimo QR kodo meniu",
        ),
    "v3_lbl_moderator_toggle": MessageLookupByLibrary.simpleMessage(
      "Perjungti moderatoriaus režimą",
    ),
    "v3_lbl_open_download_app_menu": MessageLookupByLibrary.simpleMessage(
      "Atidarykite atsisiuntimo siuntėjo programos meniu",
    ),
    "v3_lbl_open_feature_set_cast_device": MessageLookupByLibrary.simpleMessage(
      "Atidarykite perdavimo įrenginių sąrašą",
    ),
    "v3_lbl_open_feature_set_moderator": MessageLookupByLibrary.simpleMessage(
      "Atidaryti moderatorių sąrašą",
    ),
    "v3_lbl_open_help_center": MessageLookupByLibrary.simpleMessage(
      "Atidaryti pagalbos centro meniu",
    ),
    "v3_lbl_open_menu_settings": MessageLookupByLibrary.simpleMessage(
      "Atidaryti nustatymų meniu",
    ),
    "v3_lbl_open_streaming_qrcode_menu": MessageLookupByLibrary.simpleMessage(
      "Atidarykite srautinio perdavimo QR kodo meniu",
    ),
    "v3_lbl_open_streaming_shortcut_menu": MessageLookupByLibrary.simpleMessage(
      "Atidarykite srautinį spartųjį meniu",
    ),
    "v3_lbl_overlay_bring_app_to_top": MessageLookupByLibrary.simpleMessage(
      "Slankiojo ryšio informacijos skirtukas",
    ),
    "v3_lbl_overlay_menu_expand": MessageLookupByLibrary.simpleMessage(
      "Išplėsti perdangos meniu",
    ),
    "v3_lbl_overlay_menu_minimize": MessageLookupByLibrary.simpleMessage(
      "Sumažinti perdangos meniu",
    ),
    "v3_lbl_participant_cast_device": MessageLookupByLibrary.simpleMessage(
      "Perduokite įrenginį šiam dalyviui",
    ),
    "v3_lbl_participant_close": MessageLookupByLibrary.simpleMessage(
      "Glaudus dalyvių ryšys",
    ),
    "v3_lbl_participant_disconnect": MessageLookupByLibrary.simpleMessage(
      "Atjunkite šį dalyvį",
    ),
    "v3_lbl_participant_mirror_close": MessageLookupByLibrary.simpleMessage(
      "Uždarykite veidrodinio atspindžio dalyvio ryšį",
    ),
    "v3_lbl_participant_mirror_share": MessageLookupByLibrary.simpleMessage(
      "Pasidalinkite šio dalyvio veidrodžiu",
    ),
    "v3_lbl_participant_mirror_stop": MessageLookupByLibrary.simpleMessage(
      "Sustabdyti veidrodinio dalyvio transliaciją",
    ),
    "v3_lbl_participant_share": MessageLookupByLibrary.simpleMessage(
      "Bendrinti šio dalyvio ekrane",
    ),
    "v3_lbl_participant_stop": MessageLookupByLibrary.simpleMessage(
      "Dalyvio srautinio perdavimo sustabdymas",
    ),
    "v3_lbl_participant_touch_back": MessageLookupByLibrary.simpleMessage(
      "Įgalinti šio dalyvio jutiklinį grąžinimą",
    ),
    "v3_lbl_participant_touch_back_disable":
        MessageLookupByLibrary.simpleMessage(
          "Išjungti šio dalyvio prisilietimą",
        ),
    "v3_lbl_permission_exit": MessageLookupByLibrary.simpleMessage("Išeiti"),
    "v3_lbl_resizable_expand": MessageLookupByLibrary.simpleMessage(
      "Išskleisti pateikties valdiklį",
    ),
    "v3_lbl_resizable_minimize": MessageLookupByLibrary.simpleMessage(
      "Minimizuoti pateikties valdymą",
    ),
    "v3_lbl_resizable_mute": MessageLookupByLibrary.simpleMessage(
      "Nutildyti pristatymą",
    ),
    "v3_lbl_resizable_stop": MessageLookupByLibrary.simpleMessage(
      "Sustabdyti pristatymą",
    ),
    "v3_lbl_settings_accessibility": MessageLookupByLibrary.simpleMessage(
      "Prieinamumas",
    ),
    "v3_lbl_settings_back_icon": MessageLookupByLibrary.simpleMessage(
      "Grįžti į ankstesnį puslapį",
    ),
    "v3_lbl_settings_broadcast": MessageLookupByLibrary.simpleMessage(
      "Atidaryti transliacijos nustatymų meniu",
    ),
    "v3_lbl_settings_broadcast_boards": MessageLookupByLibrary.simpleMessage(
      "Atidaryti transliavimo lentų meniu",
    ),
    "v3_lbl_settings_broadcast_connect": MessageLookupByLibrary.simpleMessage(
      "Prisijungti",
    ),
    "v3_lbl_settings_broadcast_connecting":
        MessageLookupByLibrary.simpleMessage("Jungiamasi"),
    "v3_lbl_settings_broadcast_device_favorite":
        MessageLookupByLibrary.simpleMessage("mėgstamiausias"),
    "v3_lbl_settings_broadcast_device_remove":
        MessageLookupByLibrary.simpleMessage("pašalinti įrenginį"),
    "v3_lbl_settings_broadcast_devices": MessageLookupByLibrary.simpleMessage(
      "Atidarykite transliavimo įrenginių meniu",
    ),
    "v3_lbl_settings_broadcast_ip_hint": MessageLookupByLibrary.simpleMessage(
      "rasti lentas pagal ip",
    ),
    "v3_lbl_settings_broadcast_to_display_group":
        MessageLookupByLibrary.simpleMessage(
          "Atidarykite transliaciją, kad būtų rodomas grupės meniu",
        ),
    "v3_lbl_settings_broadcast_to_display_group_cast":
        MessageLookupByLibrary.simpleMessage("Transliacija"),
    "v3_lbl_settings_broadcast_to_display_group_checkbox":
        MessageLookupByLibrary.simpleMessage("Pasirinkite %s"),
    "v3_lbl_settings_broadcast_to_display_group_confirm":
        MessageLookupByLibrary.simpleMessage(
          "Patvirtinkite, kad nė vienas įrenginys nepasirinktas.",
        ),
    "v3_lbl_settings_broadcast_to_display_group_item":
        MessageLookupByLibrary.simpleMessage("Pasirinkite %s"),
    "v3_lbl_settings_broadcast_to_display_group_save":
        MessageLookupByLibrary.simpleMessage("Sutaupyti"),
    "v3_lbl_settings_broadcast_to_display_group_type":
        MessageLookupByLibrary.simpleMessage("Pasirinkite %s"),
    "v3_lbl_settings_close_icon": MessageLookupByLibrary.simpleMessage(
      "Uždaryti nustatymų meniu",
    ),
    "v3_lbl_settings_connectivity": MessageLookupByLibrary.simpleMessage(
      "Atidarykite ryšio nustatymų meniu",
    ),
    "v3_lbl_settings_connectivity_item": MessageLookupByLibrary.simpleMessage(
      "Pasirinkite %s",
    ),
    "v3_lbl_settings_device_authorize_mode":
        MessageLookupByLibrary.simpleMessage(
          "Autorizacijos režimo įjungimas / išjungimas",
        ),
    "v3_lbl_settings_device_auto_fill_otp":
        MessageLookupByLibrary.simpleMessage(
          "Automatinio užpildymo OTP režimo įjungimas / išjungimas",
        ),
    "v3_lbl_settings_device_high_image_quality":
        MessageLookupByLibrary.simpleMessage("Aukšta vaizdo kokybė"),
    "v3_lbl_settings_device_launch_on_startup":
        MessageLookupByLibrary.simpleMessage(
          "Automatinio paleidimo režimo įjungimas / išjungimas",
        ),
    "v3_lbl_settings_device_name": MessageLookupByLibrary.simpleMessage(
      "Pakeiskite įrenginio pavadinimą",
    ),
    "v3_lbl_settings_device_name_close": MessageLookupByLibrary.simpleMessage(
      "Uždaryti įrenginio pavadinimo parametrą",
    ),
    "v3_lbl_settings_device_name_save": MessageLookupByLibrary.simpleMessage(
      "Išsaugokite įrenginio pavadinimą",
    ),
    "v3_lbl_settings_device_setting": MessageLookupByLibrary.simpleMessage(
      "Atidarykite įrenginio nustatymų meniu",
    ),
    "v3_lbl_settings_device_smart_scaling":
        MessageLookupByLibrary.simpleMessage(
          "Įjunkite / išjunkite išmanųjį mastelio keitimo jungiklį",
        ),
    "v3_lbl_settings_enter_device_name": MessageLookupByLibrary.simpleMessage(
      "Įveskite įrenginio pavadinimą",
    ),
    "v3_lbl_settings_invite_group": MessageLookupByLibrary.simpleMessage(
      "Atidarykite ekrano transliavimo išskleidžiamąjį meniu",
    ),
    "v3_lbl_settings_invite_group_item": MessageLookupByLibrary.simpleMessage(
      "Pasirinkite %s",
    ),
    "v3_lbl_settings_ip_add": MessageLookupByLibrary.simpleMessage(
      "pridėti ip",
    ),
    "v3_lbl_settings_ip_clear": MessageLookupByLibrary.simpleMessage(
      "išvalyti",
    ),
    "v3_lbl_settings_knowledge_base": MessageLookupByLibrary.simpleMessage(
      "Žinių bazė",
    ),
    "v3_lbl_settings_legal_policy": MessageLookupByLibrary.simpleMessage(
      "Atidaryti teisinės strategijos parametrų meniu",
    ),
    "v3_lbl_settings_menu_locked": MessageLookupByLibrary.simpleMessage(
      "Nustatymų meniu užrakintas",
    ),
    "v3_lbl_settings_mirroring_auto_accept":
        MessageLookupByLibrary.simpleMessage(
          "Automatinio priėmimo įjungimas / išjungimas",
        ),
    "v3_lbl_settings_mirroring_require_passcode":
        MessageLookupByLibrary.simpleMessage(
          "Įjungti / išjungti reikalaujamą prieigos kodą",
        ),
    "v3_lbl_settings_moderator_mode": MessageLookupByLibrary.simpleMessage(
      "Įjungti/išjungti moderatoriaus režimą",
    ),
    "v3_lbl_settings_only_when_casting_info":
        MessageLookupByLibrary.simpleMessage(
          "Daugiau informacijos apie transliaciją į Vaizdinės reklamos grupę",
        ),
    "v3_lbl_settings_open_source_license": MessageLookupByLibrary.simpleMessage(
      "Pasirinkite %s",
    ),
    "v3_lbl_settings_show_display_code": MessageLookupByLibrary.simpleMessage(
      "Įjunkite / išjunkite ekrano kodo perjungimą",
    ),
    "v3_lbl_settings_whats_new": MessageLookupByLibrary.simpleMessage(
      "Atidaryti nustatymų meniu Kas naujo",
    ),
    "v3_lbl_settings_whats_new_icon": MessageLookupByLibrary.simpleMessage(
      "piktograma kas naujo",
    ),
    "v3_lbl_shortcuts_airplay": MessageLookupByLibrary.simpleMessage(
      "\"AirPlay\" įjungimas / išjungimas",
    ),
    "v3_lbl_shortcuts_google_cast": MessageLookupByLibrary.simpleMessage(
      "\"Google Cast\" įjungimas / išjungimas",
    ),
    "v3_lbl_shortcuts_miracast": MessageLookupByLibrary.simpleMessage(
      "\"Miracast\" įjungimas / išjungimas",
    ),
    "v3_lbl_shortcuts_mirroring": MessageLookupByLibrary.simpleMessage(
      "Atidarykite veidrodinio atspindžio nustatymų meniu",
    ),
    "v3_lbl_streaming_airplay_touchback": MessageLookupByLibrary.simpleMessage(
      "\"Airplay\" jutiklinis ryšys",
    ),
    "v3_lbl_streaming_page_control": MessageLookupByLibrary.simpleMessage(
      "Kitas puslapis",
    ),
    "v3_lbl_streaming_shortcut_airplay_toggle":
        MessageLookupByLibrary.simpleMessage("\"AirPlay\" perjungimas"),
    "v3_lbl_streaming_shortcut_cast_device_toggle":
        MessageLookupByLibrary.simpleMessage("Perduoti į įrenginius perjungti"),
    "v3_lbl_streaming_shortcut_expand": MessageLookupByLibrary.simpleMessage(
      "Išplėskite srautinio perdavimo funkcijas",
    ),
    "v3_lbl_streaming_shortcut_google_cast_toggle":
        MessageLookupByLibrary.simpleMessage("\"Google Cast\" perjungimas"),
    "v3_lbl_streaming_shortcut_menu_locked":
        MessageLookupByLibrary.simpleMessage(
          "Srautinio perdavimo nuorodų meniu užrakintas",
        ),
    "v3_lbl_streaming_shortcut_minimize": MessageLookupByLibrary.simpleMessage(
      "Sutraukti srautinio perdavimo funkcijas",
    ),
    "v3_lbl_streaming_shortcut_miracast_toggle":
        MessageLookupByLibrary.simpleMessage("\"Miracast\" perjungimas"),
    "v3_lbl_streaming_shortcut_move": MessageLookupByLibrary.simpleMessage(
      "Perkelti",
    ),
    "v3_lbl_streaming_view_expand": MessageLookupByLibrary.simpleMessage(
      "Išplėskite srautinio perdavimo rodinį",
    ),
    "v3_lbl_streaming_view_function_expand":
        MessageLookupByLibrary.simpleMessage(
          "Išplėskite srautinio perdavimo funkciją",
        ),
    "v3_lbl_streaming_view_function_minimize":
        MessageLookupByLibrary.simpleMessage(
          "Sutraukti srautinio perdavimo funkciją",
        ),
    "v3_lbl_streaming_view_minimize": MessageLookupByLibrary.simpleMessage(
      "Sutraukti srautinio perdavimo rodinį",
    ),
    "v3_lbl_streaming_view_mute": MessageLookupByLibrary.simpleMessage(
      "Nutildyti garsą",
    ),
    "v3_lbl_streaming_view_stop": MessageLookupByLibrary.simpleMessage(
      "Sustabdyti srautinį perdavimą",
    ),
    "v3_lbl_streaming_view_unmute": MessageLookupByLibrary.simpleMessage(
      "Garso nutildymo išjungimas",
    ),
    "v3_lbl_touchback_one_device_cancel": MessageLookupByLibrary.simpleMessage(
      "Atšaukimo dialogo langas",
    ),
    "v3_lbl_touchback_one_device_confirm": MessageLookupByLibrary.simpleMessage(
      "Patvirtinimo dialogo langas",
    ),
    "v3_lbl_touchback_restart_bluetooth_btn_cancel":
        MessageLookupByLibrary.simpleMessage("Atšaukti"),
    "v3_lbl_touchback_restart_bluetooth_btn_restart":
        MessageLookupByLibrary.simpleMessage("Paleisti"),
    "v3_main_connection_dialog_close": MessageLookupByLibrary.simpleMessage(
      "Uždaryti",
    ),
    "v3_main_internet_connection_only": MessageLookupByLibrary.simpleMessage(
      "Tik interneto ryšys。",
    ),
    "v3_main_internet_connection_only_error":
        MessageLookupByLibrary.simpleMessage(
          "Ryšio klaida, patikrinkite įrenginio tinklo nustatymą。",
        ),
    "v3_main_internet_connection_only_error_dialog_desc":
        MessageLookupByLibrary.simpleMessage(
          "Ryšio klaida, patikrinkite įrenginio tinklo nustatymą。",
        ),
    "v3_main_local_connection_only_dialog_desc":
        MessageLookupByLibrary.simpleMessage(
          "Tik LAN ryšys, patikrinkite įrenginio tinklo nustatymą。",
        ),
    "v3_main_status_no_network": MessageLookupByLibrary.simpleMessage(
      "Nepavyko aptikti interneto ryšio. Prisijunkite prie „Wi-Fi“ arba intraneto tinklo ir bandykite dar kartą.",
    ),
    "v3_miracast_not_support": MessageLookupByLibrary.simpleMessage(
      "\"Miracast\" dabar nepasiekiamas. Dabartinis \"Wi-Fi\" kanalas nepalaiko ekrano perdavimo.",
    ),
    "v3_miracast_uibc_not_supported_message":
        MessageLookupByLibrary.simpleMessage(
          "Šis šaltinis nepalaiko \"Miracast\" atgalinio ryšio",
        ),
    "v3_mirror_request_passcode": MessageLookupByLibrary.simpleMessage(
      "Slaptažodis",
    ),
    "v3_moderator_disable_mirror_cancel": MessageLookupByLibrary.simpleMessage(
      "Atšaukti",
    ),
    "v3_moderator_disable_mirror_desc": MessageLookupByLibrary.simpleMessage(
      "Veidrodinis atvaizdavimas bus išjungtas moderatoriaus režime",
    ),
    "v3_moderator_disable_mirror_ok": MessageLookupByLibrary.simpleMessage(
      "GERAI",
    ),
    "v3_moderator_disable_mirror_title": MessageLookupByLibrary.simpleMessage(
      "Išjungti veidrodinį atvaizdavimą moderatoriaus režimui",
    ),
    "v3_moderator_mode": MessageLookupByLibrary.simpleMessage(
      "Moderatoriaus režimas",
    ),
    "v3_new_sharing_join_session": MessageLookupByLibrary.simpleMessage(
      "prisijungė prie sesijos",
    ),
    "v3_participant_item_casting": MessageLookupByLibrary.simpleMessage(
      "Siuntimas",
    ),
    "v3_participant_item_connected": MessageLookupByLibrary.simpleMessage(
      "Prisijungta",
    ),
    "v3_participant_item_controlling": MessageLookupByLibrary.simpleMessage(
      "Gavimas + Grįžtamasis ryšys",
    ),
    "v3_participant_item_receiving": MessageLookupByLibrary.simpleMessage(
      "Gavimas",
    ),
    "v3_participant_item_share": MessageLookupByLibrary.simpleMessage(
      "Bendrinti",
    ),
    "v3_participant_item_waiting": MessageLookupByLibrary.simpleMessage(
      "Laukiama...",
    ),
    "v3_participants_desc": MessageLookupByLibrary.simpleMessage(
      "Maksimaliai iki 6 dalyvių.",
    ),
    "v3_participants_desc_maximum_9": MessageLookupByLibrary.simpleMessage(
      "Maksimaliai iki 9 dalyvių.",
    ),
    "v3_participants_title": MessageLookupByLibrary.simpleMessage("Dalyviai"),
    "v3_permission_description": MessageLookupByLibrary.simpleMessage(
      "Eikite į įrenginio „Nustatymai“, tada „Programos“ meniu, kad suteiktumėte leidimą.",
    ),
    "v3_permission_exit": MessageLookupByLibrary.simpleMessage("Išeiti"),
    "v3_permission_title": MessageLookupByLibrary.simpleMessage(
      "Reikalingas leidimas",
    ),
    "v3_qrcode_quick_connect": MessageLookupByLibrary.simpleMessage(
      "Greitas prisijungimas",
    ),
    "v3_quick_connect_menu_bottom_msg": MessageLookupByLibrary.simpleMessage(
      "Padalintas ekranas įsijungia, kai du ar daugiau vartotojų bendrina ekranus.  ",
    ),
    "v3_quick_connect_menu_display_code": MessageLookupByLibrary.simpleMessage(
      "Ekrano kodas",
    ),
    "v3_quick_connect_menu_qrcode": MessageLookupByLibrary.simpleMessage(
      "QR kodas",
    ),
    "v3_recording_stopped_dialog_msg": MessageLookupByLibrary.simpleMessage(
      "Prieiga prie ekrano baigėsi, todėl įrašymas sustabdytas.",
    ),
    "v3_recording_stopped_dialog_title": MessageLookupByLibrary.simpleMessage(
      "Prieiga prie ekrano baigėsi, todėl įrašymas sustabdytas.",
    ),
    "v3_setting_passcode_cancel": MessageLookupByLibrary.simpleMessage(
      "Atšaukti",
    ),
    "v3_setting_passcode_clear": MessageLookupByLibrary.simpleMessage(
      "Atšaukti",
    ),
    "v3_setting_passcode_confirm": MessageLookupByLibrary.simpleMessage(
      "Patvirtinti",
    ),
    "v3_setting_passcode_error_description":
        MessageLookupByLibrary.simpleMessage(
          "Neteisingas slaptažodis, bandykite dar kartą.",
        ),
    "v3_setting_passcode_title": MessageLookupByLibrary.simpleMessage(
      "Įveskite prieigos kodą, kad atrakintumėte nustatymus",
    ),
    "v3_settings_accessibility": MessageLookupByLibrary.simpleMessage(
      "Prieinamumas",
    ),
    "v3_settings_all_the_time_info": MessageLookupByLibrary.simpleMessage(
      "Transliuoti IFP ekraną visada.",
    ),
    "v3_settings_broadcast": MessageLookupByLibrary.simpleMessage(
      "Transliacija",
    ),
    "v3_settings_broadcast_boards": MessageLookupByLibrary.simpleMessage(
      "Kitus AirSync įrenginius",
    ),
    "v3_settings_broadcast_cast_boards": MessageLookupByLibrary.simpleMessage(
      "Siųsti į lentas",
    ),
    "v3_settings_broadcast_cast_boards_desc":
        MessageLookupByLibrary.simpleMessage(
          "Bendrinti ekraną su visomis tinklo interaktyviomis plokštėmis (IFPs).",
        ),
    "v3_settings_broadcast_cast_to": MessageLookupByLibrary.simpleMessage(
      "Transliuoti į",
    ),
    "v3_settings_broadcast_devices": MessageLookupByLibrary.simpleMessage(
      "Siuntėjo įrenginius",
    ),
    "v3_settings_broadcast_ip": MessageLookupByLibrary.simpleMessage(
      "Rasti lentas pagal IP",
    ),
    "v3_settings_broadcast_ip_hint": MessageLookupByLibrary.simpleMessage(
      "Įveskite IP adresą",
    ),
    "v3_settings_broadcast_not_find": MessageLookupByLibrary.simpleMessage(
      "nerasta",
    ),
    "v3_settings_broadcast_screen_energy_saving":
        MessageLookupByLibrary.simpleMessage(
          "Prašome išjungti energijos taupymo režimą, kad išvengtumėte netikėtų transliacijos pertraukimų.",
        ),
    "v3_settings_broadcast_to_display_group":
        MessageLookupByLibrary.simpleMessage("Transliuoti į ekrano grupę"),
    "v3_settings_connectivity": MessageLookupByLibrary.simpleMessage("Ryšys"),
    "v3_settings_connectivity_both": MessageLookupByLibrary.simpleMessage(
      "Tiek interneto, tiek vietinis ryšys",
    ),
    "v3_settings_connectivity_internet": MessageLookupByLibrary.simpleMessage(
      "Interneto ryšys",
    ),
    "v3_settings_connectivity_internet_desc":
        MessageLookupByLibrary.simpleMessage(
          "Interneto ryšiui reikalingas stabilus tinklas.",
        ),
    "v3_settings_connectivity_local": MessageLookupByLibrary.simpleMessage(
      "Vietinis ryšys",
    ),
    "v3_settings_connectivity_local_desc": MessageLookupByLibrary.simpleMessage(
      "Vietiniai ryšiai veikia privačiame tinkle, užtikrinant didesnį saugumą ir stabilumą.",
    ),
    "v3_settings_device_authorize_mode": MessageLookupByLibrary.simpleMessage(
      "Leisti ekrano bendrinimą tik su patvirtinimo užklausomis.",
    ),
    "v3_settings_device_auto_fill_otp": MessageLookupByLibrary.simpleMessage(
      "Automatiškai užpildyti vienkartinį slaptažodį",
    ),
    "v3_settings_device_auto_fill_otp_desc":
        MessageLookupByLibrary.simpleMessage(
          "Įjunkite vieno prisilietimo ryšį pasirinkdami įrenginį iš sąrašo.",
        ),
    "v3_settings_device_high_image_quality":
        MessageLookupByLibrary.simpleMessage("Aukšta vaizdo kokybė"),
    "v3_settings_device_high_image_quality_off_desc":
        MessageLookupByLibrary.simpleMessage(
          "Didžiausias QHD (2K) ekrano bendrinimas, priklausomai nuo siuntėjo ekrano skiriamosios gebos.",
        ),
    "v3_settings_device_high_image_quality_on_desc":
        MessageLookupByLibrary.simpleMessage(
          "Didžiausias UHD (4K) ekrano bendrinimas iš žiniatinklio siuntėjo ir 3K+ iš „Windows“ ir „macOS“ siuntėjo, priklausomai nuo siuntėjo ekrano skiriamosios gebos. Reikia aukštos kokybės tinklo.",
        ),
    "v3_settings_device_launch_on_startup":
        MessageLookupByLibrary.simpleMessage(
          "Paleisti AirSync paleidžiant sistemą",
        ),
    "v3_settings_device_name": MessageLookupByLibrary.simpleMessage(
      "Įrenginio pavadinimas",
    ),
    "v3_settings_device_name_empty_error": MessageLookupByLibrary.simpleMessage(
      "Įrenginio pavadinimas negali būti tuščias",
    ),
    "v3_settings_device_name_save": MessageLookupByLibrary.simpleMessage(
      "Išsaugoti",
    ),
    "v3_settings_device_not_supported": MessageLookupByLibrary.simpleMessage(
      "Įrenginio versija nepalaikoma",
    ),
    "v3_settings_device_setting": MessageLookupByLibrary.simpleMessage(
      "Įrenginio nustatymai",
    ),
    "v3_settings_device_show_display_code":
        MessageLookupByLibrary.simpleMessage("Rodyti ekrano kodą viršuje"),
    "v3_settings_device_show_display_code_desc":
        MessageLookupByLibrary.simpleMessage(
          "Išlaikyti kodą matomą ekrano viršuje, net ir pereinant prie kitų programų arba kai aktyvi ekrano bendrinimo funkcija.",
        ),
    "v3_settings_device_smart_scaling": MessageLookupByLibrary.simpleMessage(
      "Išmanusis mastelio keitimas",
    ),
    "v3_settings_device_smart_scaling_desc": MessageLookupByLibrary.simpleMessage(
      "Automatiškai sureguliuokite ekrano dydį, kad maksimaliai išnaudotumėte vietą ekrane. Vaizdas gali būti šiek tiek iškraipytas.",
    ),
    "v3_settings_device_unavailable": MessageLookupByLibrary.simpleMessage(
      "Nepasiekiama",
    ),
    "v3_settings_display_group": MessageLookupByLibrary.simpleMessage(
      "Ekrano grupė",
    ),
    "v3_settings_display_group_all_the_time":
        MessageLookupByLibrary.simpleMessage("Visada"),
    "v3_settings_display_group_cast": MessageLookupByLibrary.simpleMessage(
      "Transliacija",
    ),
    "v3_settings_display_group_only_casting":
        MessageLookupByLibrary.simpleMessage("Tik siuntimo metu"),
    "v3_settings_feature_locked": MessageLookupByLibrary.simpleMessage(
      "Užrakinta ViewSonic valdymo programoje.",
    ),
    "v3_settings_invite_group": MessageLookupByLibrary.simpleMessage(
      "Jei esate pakviesti į ekrano grupę",
    ),
    "v3_settings_invite_group_auto_accept":
        MessageLookupByLibrary.simpleMessage("Acceptera automatiskt"),
    "v3_settings_invite_group_ignore": MessageLookupByLibrary.simpleMessage(
      "Ignoruoti",
    ),
    "v3_settings_invite_group_notify_me": MessageLookupByLibrary.simpleMessage(
      "Praneškite man",
    ),
    "v3_settings_knowledge_base": MessageLookupByLibrary.simpleMessage(
      "Žinių bazė",
    ),
    "v3_settings_legal_policy": MessageLookupByLibrary.simpleMessage(
      "Teisiniai ir politikos klausimai",
    ),
    "v3_settings_local_connection_only": MessageLookupByLibrary.simpleMessage(
      "Tik vietinis ryšys",
    ),
    "v3_settings_mirroring_auto_accept": MessageLookupByLibrary.simpleMessage(
      "Acceptera automatiskt",
    ),
    "v3_settings_mirroring_auto_accept_desc": MessageLookupByLibrary.simpleMessage(
      "Iškart įjunkite veidrodinį atvaizdavimą be moderatoriaus patvirtinimo.",
    ),
    "v3_settings_mirroring_blocked": MessageLookupByLibrary.simpleMessage(
      "Pirmiausia išjunkite moderatoriaus režimą.",
    ),
    "v3_settings_mirroring_require_passcode":
        MessageLookupByLibrary.simpleMessage("Reikalauti slaptažodžio"),
    "v3_settings_moderator_mode": MessageLookupByLibrary.simpleMessage(
      "Moderatoriaus režimas",
    ),
    "v3_settings_only_when_casting_info": MessageLookupByLibrary.simpleMessage(
      "Transliuoti tik tada, kai IFP ekranas gauna bendrinamą ekraną.",
    ),
    "v3_settings_open_source_license": MessageLookupByLibrary.simpleMessage(
      "Atvirojo kodo licencijos",
    ),
    "v3_settings_privacy_policy": MessageLookupByLibrary.simpleMessage(
      "Privatumo politika",
    ),
    "v3_settings_privacy_policy_description": MessageLookupByLibrary.simpleMessage(
      "ViewSonic yra įsipareigojusi saugoti jūsų privatumą ir rimtai žiūri į asmens duomenų tvarkymą. Toliau pateikta privatumo politika išsamiai paaiškina, kaip ViewSonic tvarkys jūsų asmens duomenis, kai jie bus surinkti per jūsų naudojimąsi svetaine. ViewSonic saugo jūsų informaciją naudodama saugumo technologijas ir laikosi politikos, kuri neleidžia neteisėtai naudoti jūsų asmens duomenų. Naudodamiesi šia svetaine, sutinkate su jūsų informacijos rinkimu ir naudojimu.  \n\nSvetainės, į kurias galite patekti iš ViewSonic.com, gali turėti savo privatumo politiką, kuri gali skirtis nuo ViewSonic politikos. Prašome peržiūrėti tų svetainių privatumo politiką, kad gautumėte išsamią informaciją apie tai, kaip jos gali naudoti informaciją, surinktą jums lankantis.  \n\nSpustelėkite šias nuorodas, kad sužinotumėte daugiau apie mūsų privatumo politiką.  ",
    ),
    "v3_settings_resize_text_size": MessageLookupByLibrary.simpleMessage(
      "Teksto dydžio keitimas",
    ),
    "v3_settings_resize_text_size_extra_large":
        MessageLookupByLibrary.simpleMessage("XLarge"),
    "v3_settings_resize_text_size_large": MessageLookupByLibrary.simpleMessage(
      "Didelis",
    ),
    "v3_settings_resize_text_size_normal": MessageLookupByLibrary.simpleMessage(
      "Įprastas",
    ),
    "v3_settings_version": m1,
    "v3_settings_whats_new": MessageLookupByLibrary.simpleMessage("Kas naujo"),
    "v3_settings_whats_new_content": MessageLookupByLibrary.simpleMessage(
      "\"AirSync\" yra \"ViewSonic\" patentuotas belaidžio ekrano bendrinimo sprendimas. Kai naudojamas su \"AirSync\" siuntėju, jis leidžia sklandžiai bendrinti ekraną iš vartotojo įrenginio į \"ViewSonic\" interaktyvius ekranus.\n\nNaujos šio leidimo funkcijos: \n\n1. Moderatoriaus režimas dabar palaiko atspindėjimą.\n\n2. Integracija su ViewSonic Manager per Manager nuotolinio valdymo pultą.\n\n3. PWA versijos siuntėjas, skirtas \"Chromebook\" įrenginiams, skirtas ekrano bendrinimui internete.\n\n4. 9 padalintų ekranų palaikymas pasirinktuose modeliuose.\n\n5. Palaikykite ekrano plėtinį su jutikliniu grąžinimu. \n\n6. Pagerintas stabilumas.\n\n7. Klaidos ištaisytos.",
    ),
    "v3_shortcuts_airplay": MessageLookupByLibrary.simpleMessage("AirPlay"),
    "v3_shortcuts_cast_device": MessageLookupByLibrary.simpleMessage(
      "Siųsti į įrenginius",
    ),
    "v3_shortcuts_cast_device_desc": MessageLookupByLibrary.simpleMessage(
      "Bendrinkite savo ekraną su keliais įrenginiais, įskaitant nešiojamuosius kompiuterius, planšetinius ir mobiliuosius įrenginius, vienu metu.",
    ),
    "v3_shortcuts_google_cast": MessageLookupByLibrary.simpleMessage(
      "Google Cast",
    ),
    "v3_shortcuts_menu_title": MessageLookupByLibrary.simpleMessage("Nuorodos"),
    "v3_shortcuts_miracast": MessageLookupByLibrary.simpleMessage("Miracast"),
    "v3_shortcuts_mirroring": MessageLookupByLibrary.simpleMessage(
      "Veidrodinis atvaizdavimas",
    ),
    "v3_touchback_alert_message": MessageLookupByLibrary.simpleMessage(
      "Vienu metu galite paliesti tik vieną įrenginį.",
    ),
    "v3_touchback_alert_title": MessageLookupByLibrary.simpleMessage(
      "Prisilietimas prie %s?",
    ),
    "v3_touchback_disable_message": MessageLookupByLibrary.simpleMessage(
      "\"TouchBack\" išjungtas.",
    ),
    "v3_touchback_fail_message": MessageLookupByLibrary.simpleMessage(
      "Susieti nepavyko. \"TouchBack\" nesuaktyvintas. Bandykite dar kartą",
    ),
    "v3_touchback_restart_bluetooth_btn_cancel":
        MessageLookupByLibrary.simpleMessage("Atšaukti"),
    "v3_touchback_restart_bluetooth_btn_restart":
        MessageLookupByLibrary.simpleMessage("Paleisti"),
    "v3_touchback_restart_bluetooth_message": MessageLookupByLibrary.simpleMessage(
      "Operacijos skirtasis laikas. Išjunkite ir iš naujo paleiskite \"Bluetooth\" funkciją dideliame ekrane, tada iš naujo paleiskite jutiklinį ryšį.",
    ),
    "v3_touchback_restart_bluetooth_title":
        MessageLookupByLibrary.simpleMessage(
          "Baigėsi veikimo laikas, iš naujo paleiskite \"Bluetooth\"",
        ),
    "v3_touchback_state_deviceFinding_message":
        MessageLookupByLibrary.simpleMessage("Įrenginių paieška"),
    "v3_touchback_state_deviceFoundSuccess_message":
        MessageLookupByLibrary.simpleMessage("Įrenginys rado sėkmę"),
    "v3_touchback_state_devicePairedSuccess_message":
        MessageLookupByLibrary.simpleMessage("Įrenginio suporuota sėkmė"),
    "v3_touchback_state_devicePairing_message":
        MessageLookupByLibrary.simpleMessage("Įrenginių susiejimas"),
    "v3_touchback_state_hidConnected_message":
        MessageLookupByLibrary.simpleMessage("Slėpti prisijungus"),
    "v3_touchback_state_hidConnecting_message":
        MessageLookupByLibrary.simpleMessage("Paslėpė ryšį"),
    "v3_touchback_state_hidProfileServiceStartedSuccess_message":
        MessageLookupByLibrary.simpleMessage(
          "\"Hid Profile Service\" pradėjo sėkmę",
        ),
    "v3_touchback_state_hidProfileServiceStarting_message":
        MessageLookupByLibrary.simpleMessage(
          "\"Hid Profile\" paslaugos paleidimas",
        ),
    "v3_touchback_state_initialized_message":
        MessageLookupByLibrary.simpleMessage("Inicijuotas"),
    "v3_touchback_state_initializing_message":
        MessageLookupByLibrary.simpleMessage("Inicializuojama"),
    "v3_touchback_success_message": MessageLookupByLibrary.simpleMessage(
      "Dabar galite valdyti %s nuotoliniu būdu iš IFP.",
    ),
    "v3_waiting_desc": MessageLookupByLibrary.simpleMessage(
      "Laukiama, kol šis dalyvis pasidalins savo ekranu",
    ),
    "v3_waiting_join": MessageLookupByLibrary.simpleMessage(
      "Laukiama, kol prisijungs kiti",
    ),
    "v3_waiting_up_next": MessageLookupByLibrary.simpleMessage("Toliau"),
    "v3_zero_fps_capture_failed_message": MessageLookupByLibrary.simpleMessage(
      "Šiuo metu nepavyksta gauti ekrano kopijos iš šaltinio programos. Gali būti įvykusi klaida. Grįžkite į šaltinio programą, kad padarytumėte naują ekrano kopiją, ir bandykite dar kartą.",
    ),
    "v3_zero_fps_capture_failed_title": MessageLookupByLibrary.simpleMessage(
      "Nepavyko padaryti ekrano kopijos",
    ),
    "v3_zero_fps_close": MessageLookupByLibrary.simpleMessage("Uždaryti"),
    "v3_zero_fps_failed_to_repair_message": MessageLookupByLibrary.simpleMessage(
      "Nepavyksta paleisti iš naujo ekrano kopijos mechanizmo šaltinio programoje.",
    ),
    "v3_zero_fps_failed_to_repair_title": MessageLookupByLibrary.simpleMessage(
      "Nepavyko pataisyti ekrano kopijos funkcijos",
    ),
    "v3_zero_fps_prompt_message": MessageLookupByLibrary.simpleMessage(
      "Nepavyksta užfiksuoti ekrano ir nusiųsti į projekcijos programą. Ar norėtumėte paleisti iš naujo ekrano kopijos funkciją ir bandyti dar kartą, ar sustabdyti projekciją?",
    ),
    "v3_zero_fps_prompt_title": MessageLookupByLibrary.simpleMessage(
      "Sėkmingai paleista iš naujo",
    ),
    "v3_zero_fps_repairing_message": MessageLookupByLibrary.simpleMessage(
      "Paleidžiama iš naujo ekrano kopijos mechanizmas šaltinio programoje. Tai gali užtrukti kelias sekundes. Prašome palaukti.",
    ),
    "v3_zero_fps_repairing_title": MessageLookupByLibrary.simpleMessage(
      "Taisoma ekrano kopijos funkcija",
    ),
    "v3_zero_fps_restart_failed": MessageLookupByLibrary.simpleMessage(
      "Paleidimas iš naujo nepavyko",
    ),
    "v3_zero_fps_restarted_Successfully": MessageLookupByLibrary.simpleMessage(
      "Sėkmingai paleista iš naujo",
    ),
    "v3_zero_fps_restarting_content": MessageLookupByLibrary.simpleMessage(
      "Prašome palaukti.",
    ),
    "v3_zero_fps_restarting_title": MessageLookupByLibrary.simpleMessage(
      "Paleidžiama iš naujo",
    ),
    "vbs_ota_progress_msg": MessageLookupByLibrary.simpleMessage(
      "Atsisiunčiami sistemos atnaujinimai",
    ),
  };
}
