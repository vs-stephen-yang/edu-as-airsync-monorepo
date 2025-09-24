// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a sv locale. All the
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
  String get localeName => 'sv';

  static String m0(value) =>
      "Skärmdelning är på väg att upphöra. Vill du förlänga den med 3 timmar? Du kan utöka upp till ${value} gånger.";

  static String m1(year, version) => "AirSync © ${year}. version ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "eula_agree": MessageLookupByLibrary.simpleMessage("Jag håller med"),
    "eula_disagree": MessageLookupByLibrary.simpleMessage(
      "Jag håller inte med",
    ),
    "eula_title": MessageLookupByLibrary.simpleMessage(
      "Licensavtal för AirSync",
    ),
    "main_airplay_pin_code": MessageLookupByLibrary.simpleMessage(
      "AirPlay kod",
    ),
    "main_auto_startup": MessageLookupByLibrary.simpleMessage(
      "Starta AirSync vid start",
    ),
    "main_cast_settings_airplay": MessageLookupByLibrary.simpleMessage(
      "AirPlay",
    ),
    "main_cast_settings_device_name": MessageLookupByLibrary.simpleMessage(
      "Namn",
    ),
    "main_cast_settings_google_cast": MessageLookupByLibrary.simpleMessage(
      "Google Cast",
    ),
    "main_cast_settings_miracast": MessageLookupByLibrary.simpleMessage(
      "Miracast",
    ),
    "main_cast_settings_title": MessageLookupByLibrary.simpleMessage(
      "Cast-inställningar",
    ),
    "main_content_display_code": MessageLookupByLibrary.simpleMessage(
      "Display kod",
    ),
    "main_content_lan_only": MessageLookupByLibrary.simpleMessage(
      "Endast LAN-anslutning",
    ),
    "main_content_one_time_password": MessageLookupByLibrary.simpleMessage(
      "Engångslösenord",
    ),
    "main_content_one_time_password_get_fail": MessageLookupByLibrary.simpleMessage(
      "Det gick inte att uppdatera lösenordet.\nVänta i 30 sekunder innan du försöker igen.",
    ),
    "main_feature_no_network_warning": MessageLookupByLibrary.simpleMessage(
      "Kontrollanslutningen är frånkopplad. Vänligen anslut igen",
    ),
    "main_feature_reconnect_fail_toast": MessageLookupByLibrary.simpleMessage(
      "Återanslutning av nätverk (kontroll) misslyckades",
    ),
    "main_feature_reconnect_success_toast":
        MessageLookupByLibrary.simpleMessage(
          "Återanslutning av nätverk (kontroll) lyckades",
        ),
    "main_feature_reconnecting_toast": MessageLookupByLibrary.simpleMessage(
      "Återanslutning av nätverk (kontroll)",
    ),
    "main_get_display_code_failure": MessageLookupByLibrary.simpleMessage(
      "Det gick inte att hämta visningskoden. Vänta tills nätverksanslutningen återupptas eller starta om appen.",
    ),
    "main_language_name": MessageLookupByLibrary.simpleMessage("Engelska"),
    "main_language_title": MessageLookupByLibrary.simpleMessage("Språk"),
    "main_limit_time_message": MessageLookupByLibrary.simpleMessage(
      "5 minuter kvar",
    ),
    "main_mirror_from_client": MessageLookupByLibrary.simpleMessage(
      "%s vill dela sin skärm.",
    ),
    "main_mirror_prompt_accept": MessageLookupByLibrary.simpleMessage(
      "Acceptera",
    ),
    "main_mirror_prompt_cancel": MessageLookupByLibrary.simpleMessage("Avbryt"),
    "main_register_display_code_failure": MessageLookupByLibrary.simpleMessage(
      "Det gick inte att få Display kod och engångslösenord. Detta kan bero på ett nätverks- eller serverproblem. Försök igen senare när anslutningen är återställd.",
    ),
    "main_settings_airplay_code": MessageLookupByLibrary.simpleMessage(
      "AirPlay kod",
    ),
    "main_settings_device_list": MessageLookupByLibrary.simpleMessage(
      "Lösenord för snabbanslutning",
    ),
    "main_settings_device_name": MessageLookupByLibrary.simpleMessage("Namn"),
    "main_settings_device_name_cancel": MessageLookupByLibrary.simpleMessage(
      "AVBRYT",
    ),
    "main_settings_device_name_hint": MessageLookupByLibrary.simpleMessage(
      "Namn",
    ),
    "main_settings_device_name_save": MessageLookupByLibrary.simpleMessage(
      "SPARA",
    ),
    "main_settings_device_name_title": MessageLookupByLibrary.simpleMessage(
      "Byt namn på enhet",
    ),
    "main_settings_language": MessageLookupByLibrary.simpleMessage("Språk"),
    "main_settings_mirror_confirmation": MessageLookupByLibrary.simpleMessage(
      "Bekräftelse av spegling",
    ),
    "main_settings_pin_visible": MessageLookupByLibrary.simpleMessage(
      "Anslutningsinformation",
    ),
    "main_settings_share_to_sender": MessageLookupByLibrary.simpleMessage(
      "Dela skärm till enhet",
    ),
    "main_settings_share_to_sender_limit_desc":
        MessageLookupByLibrary.simpleMessage(
          "Dela skärm upp till 10 avsändare.",
        ),
    "main_settings_title": MessageLookupByLibrary.simpleMessage(
      "Inställningar",
    ),
    "main_settings_whats_new": MessageLookupByLibrary.simpleMessage("Nyheter"),
    "main_split_screen_question": MessageLookupByLibrary.simpleMessage(
      "Klicka på reglaget ovan för Delat skärmläge. Upp till 4 deltagare kan presentera samtidigt...",
    ),
    "main_split_screen_title": MessageLookupByLibrary.simpleMessage(
      "Delad skärm",
    ),
    "main_split_screen_waiting": MessageLookupByLibrary.simpleMessage(
      "Delad skärm aktiverad. Väntar på att presentatören ska dela skärm...",
    ),
    "main_status_go_background": MessageLookupByLibrary.simpleMessage(
      "AirSync-appen körs i bakgrunden.",
    ),
    "main_status_no_network": MessageLookupByLibrary.simpleMessage(
      "Dålig nätverksanslutning har upptäckts.\nKontrollera din anslutning.",
    ),
    "main_status_remaining_time": MessageLookupByLibrary.simpleMessage(
      "%02d min : %02d sec",
    ),
    "main_thanks_content": MessageLookupByLibrary.simpleMessage(
      "Tack för att du använder AirSync.",
    ),
    "main_wait_title": MessageLookupByLibrary.simpleMessage(
      "Väntar på att presentatören ska dela skärm...",
    ),
    "main_wait_up_next": MessageLookupByLibrary.simpleMessage("NÄSTA"),
    "main_webrtc_reconnect_fail_toast": MessageLookupByLibrary.simpleMessage(
      "Återanslutning av nätverk (WebRTC) misslyckades",
    ),
    "main_webrtc_reconnect_success_toast": MessageLookupByLibrary.simpleMessage(
      "Lyckad återanslutning av nätverk (WebRTC)",
    ),
    "main_webrtc_reconnecting_toast": MessageLookupByLibrary.simpleMessage(
      "Återanslutning av nätverk (WebRTC)",
    ),
    "main_whats_new_content": MessageLookupByLibrary.simpleMessage(
      "[Förbättring]\n\n1. Numerisk visningskod för bättre användarupplevelse.\n\n2. Förbättra anslutningens stabilitet.\n\n3. Bugg fixar",
    ),
    "main_whats_new_title": MessageLookupByLibrary.simpleMessage(
      "Vad är nytt i AirSync?",
    ),
    "moderator_activate_split_screen": MessageLookupByLibrary.simpleMessage(
      "Klicka på reglaget ovan för Delat skärmläge. Upp till 4 deltagare kan presentera samtidigt.",
    ),
    "moderator_cancel": MessageLookupByLibrary.simpleMessage("Avbryt"),
    "moderator_confirm": MessageLookupByLibrary.simpleMessage("Bekräfta"),
    "moderator_deactivate_split_screen": MessageLookupByLibrary.simpleMessage(
      "Är du säker på att du vill avsluta den här sessionen med delad skärm? Alla skärmar som för närvarande delas kommer att avslutas.",
    ),
    "moderator_exit": MessageLookupByLibrary.simpleMessage("Avsluta"),
    "moderator_exit_dialog": MessageLookupByLibrary.simpleMessage(
      "Är du säker på att du vill avsluta den här moderatorsessionen? Alla presentatörer kommer att tas bort.",
    ),
    "moderator_presentersLimit": MessageLookupByLibrary.simpleMessage(
      "Klicka på reglaget ovan för Moderatorläge. Upp till 6 presentatörer kan delta.",
    ),
    "moderator_presentersList": MessageLookupByLibrary.simpleMessage(
      "Presentatörer",
    ),
    "moderator_remove": MessageLookupByLibrary.simpleMessage("Ta bort"),
    "moderator_verifyCode_fail": MessageLookupByLibrary.simpleMessage(
      "Något gick fel. Försök igen.",
    ),
    "toast_maximum_split_screen": MessageLookupByLibrary.simpleMessage(
      "Har nått det maximala antalet delade skärmar.",
    ),
    "update_install_now": MessageLookupByLibrary.simpleMessage("INSTALLERA NU"),
    "update_message": MessageLookupByLibrary.simpleMessage(
      "En ny version av programvaran är tillgänglig",
    ),
    "update_title": MessageLookupByLibrary.simpleMessage("AirSync-uppdatering"),
    "v3_authorize_prompt_accept": MessageLookupByLibrary.simpleMessage(
      "Acceptera",
    ),
    "v3_authorize_prompt_accept_all": MessageLookupByLibrary.simpleMessage(
      "Acceptera alla",
    ),
    "v3_authorize_prompt_decline": MessageLookupByLibrary.simpleMessage("Neka"),
        "v3_authorize_prompt_title_launcher":
            MessageLookupByLibrary.simpleMessage(
          "Deltagarna vill dela sin skärm",
        ),
        "v3_broadcast_cast_board_on": MessageLookupByLibrary.simpleMessage(
          "Skärmdelning pågår",
        ),
        "v3_broadcast_cast_device_on": MessageLookupByLibrary.simpleMessage(
          "Skärmdelning pågår",
        ),
        "v3_broadcast_indicator": MessageLookupByLibrary.simpleMessage("På"),
        "v3_broadcast_multicast_checkbox": MessageLookupByLibrary.simpleMessage(
          "Casta till 10–100 enheter",
        ),
        "v3_broadcast_multicast_desc": MessageLookupByLibrary.simpleMessage(
          "Antalet mottagande enheter kan inte ändras när prognosen startar.",
        ),
        "v3_broadcast_multicast_warn": MessageLookupByLibrary.simpleMessage(
          "Avbryt all projektion för att redigera.",
        ),
        "v3_cast_to_device_Receiving": MessageLookupByLibrary.simpleMessage(
      "Tar emot",
    ),
    "v3_cast_to_device_list_msg": MessageLookupByLibrary.simpleMessage(
      "Högst upp till 10 enheter.",
    ),
    "v3_cast_to_device_menu_or": MessageLookupByLibrary.simpleMessage("Eller"),
    "v3_cast_to_device_menu_quick_connect1":
        MessageLookupByLibrary.simpleMessage("Snabbanslutning"),
    "v3_cast_to_device_menu_quick_connect2":
        MessageLookupByLibrary.simpleMessage("genom att skanna QR-koden"),
    "v3_cast_to_device_menu_title": MessageLookupByLibrary.simpleMessage(
      "Anslut för att ta emot denna skärm",
    ),
    "v3_cast_to_device_reached_maximum": MessageLookupByLibrary.simpleMessage(
      "Du har nått den maximala gränsen.",
    ),
    "v3_cast_to_device_title": MessageLookupByLibrary.simpleMessage(
      "Enhetslista",
    ),
    "v3_cast_to_device_touch_back": MessageLookupByLibrary.simpleMessage(
      "Touchback",
    ),
    "v3_cast_to_device_touch_back_disable":
        MessageLookupByLibrary.simpleMessage("Avaktivera"),
    "v3_cast_to_device_touch_enabled": MessageLookupByLibrary.simpleMessage(
      "Touchback",
    ),
    "v3_casting_ended_toast": MessageLookupByLibrary.simpleMessage(
      "Skärmdelningen har upphört.",
    ),
    "v3_casting_time_countdown": m0,
    "v3_casting_time_do_not_extend": MessageLookupByLibrary.simpleMessage(
      "Förläng inte",
    ),
    "v3_casting_time_extend": MessageLookupByLibrary.simpleMessage("Förläng"),
    "v3_casting_time_extend_success_toast":
        MessageLookupByLibrary.simpleMessage("Förlängs med 3 timmar."),
    "v3_download_app_desc": MessageLookupByLibrary.simpleMessage(
      "Skanna QR-koden med din iOS- eller Android-enhet för att ladda ner",
    ),
    "v3_download_app_desktop": MessageLookupByLibrary.simpleMessage(
      "För bästa användarupplevelse!",
    ),
    "v3_download_app_desktop_hint": MessageLookupByLibrary.simpleMessage(
      "*Manuellt installationsprogram",
    ),
    "v3_download_app_desktop_store": MessageLookupByLibrary.simpleMessage(
      "Installera MacOS via App Store",
    ),
    "v3_download_app_desktop_store_hint": MessageLookupByLibrary.simpleMessage(
      "*Endast för MacOS",
    ),
    "v3_download_app_desktop_title": MessageLookupByLibrary.simpleMessage(
      "Skrivbord",
    ),
    "v3_download_app_entry": MessageLookupByLibrary.simpleMessage(
      "Ladda ner Sender App",
    ),
    "v3_download_app_for_desktop": MessageLookupByLibrary.simpleMessage(
      "För dator",
    ),
    "v3_download_app_for_desktop_desc": MessageLookupByLibrary.simpleMessage(
      "Ange följande URL för att ladda ner.",
    ),
    "v3_download_app_for_mobile": MessageLookupByLibrary.simpleMessage(
      "För iOS och Android",
    ),
    "v3_download_app_for_mobile_desc": MessageLookupByLibrary.simpleMessage(
      "Skanna QR-koden för omedelbar åtkomst.",
    ),
    "v3_download_app_mobile_title": MessageLookupByLibrary.simpleMessage(
      "Mobil",
    ),
    "v3_download_app_or": MessageLookupByLibrary.simpleMessage("ELLER"),
    "v3_download_app_title": MessageLookupByLibrary.simpleMessage(
      "Ladda ner sändarapp",
    ),
    "v3_eula_agree": MessageLookupByLibrary.simpleMessage("Samtycker"),
    "v3_eula_disagree": MessageLookupByLibrary.simpleMessage("Ej ok"),
        "v3_eula_launch": MessageLookupByLibrary.simpleMessage("Starta"),
        "v3_eula_title": MessageLookupByLibrary.simpleMessage(
      "Slutanvändarlicensavtal",
    ),
    "v3_exit_moderator_mode_cancel": MessageLookupByLibrary.simpleMessage(
      "Avbryt",
    ),
    "v3_exit_moderator_mode_desc": MessageLookupByLibrary.simpleMessage(
      "Är du säker? Detta kommer att koppla bort alla deltagare.",
    ),
    "v3_exit_moderator_mode_exit": MessageLookupByLibrary.simpleMessage(
      "Avsluta",
    ),
    "v3_exit_moderator_mode_title": MessageLookupByLibrary.simpleMessage(
      "Avsluta moderatorläget",
    ),
    "v3_group_dialog_accept": MessageLookupByLibrary.simpleMessage("Acceptera"),
    "v3_group_dialog_decline": MessageLookupByLibrary.simpleMessage("Neka"),
    "v3_group_dialog_message": MessageLookupByLibrary.simpleMessage(
      "%s har skickat en sändningsförfrågan till din enhet. Denna åtgärd synkroniserar och visar det aktuella innehållet, vill du acceptera denna förfrågan?",
    ),
    "v3_group_dialog_no_device_message": MessageLookupByLibrary.simpleMessage(
      "Ingen enhet vald.",
    ),
    "v3_group_dialog_title": MessageLookupByLibrary.simpleMessage(
      "Sändningsförfrågan från %s",
    ),
    "v3_group_receive_view_status_from": MessageLookupByLibrary.simpleMessage(
      "Sänder från",
    ),
    "v3_group_receive_view_status_stop": MessageLookupByLibrary.simpleMessage(
      "Stopp",
    ),
    "v3_group_reject_invited": MessageLookupByLibrary.simpleMessage(
      "avböjde din sändningsförfrågan, vänligen kontrollera inställningarna för sändning.",
    ),
    "v3_help_center_cast_device_title": MessageLookupByLibrary.simpleMessage(
      "Casta till enhet",
    ),
    "v3_help_center_cast_device_title_sub":
        MessageLookupByLibrary.simpleMessage(
          "IFP castar sin skärm till enheter.",
        ),
    "v3_help_center_close": MessageLookupByLibrary.simpleMessage("Stäng"),
    "v3_help_center_fullscreen_title": MessageLookupByLibrary.simpleMessage(
      "Fullskärm",
    ),
    "v3_help_center_mute_user_title": MessageLookupByLibrary.simpleMessage(
      "Tysta användaren",
    ),
    "v3_help_center_remove_user_title": MessageLookupByLibrary.simpleMessage(
      "Ta bort användaren",
    ),
    "v3_help_center_share_title": MessageLookupByLibrary.simpleMessage(
      "Bjud in till att dela",
    ),
    "v3_help_center_share_title_sub": MessageLookupByLibrary.simpleMessage(
      "Enheter som delar sin skärm med IFP.",
    ),
    "v3_help_center_stop_share_title": MessageLookupByLibrary.simpleMessage(
      "Sluta dela",
    ),
    "v3_help_center_title": MessageLookupByLibrary.simpleMessage(
      "Hjälp Center",
    ),
    "v3_help_center_touchback_title": MessageLookupByLibrary.simpleMessage(
      "Touchback",
    ),
    "v3_help_center_touchback_title_sub": MessageLookupByLibrary.simpleMessage(
      "Tillåter fjärrkontroll för användaren.",
    ),
    "v3_help_center_untouchback_title": MessageLookupByLibrary.simpleMessage(
      "Ingen Touchback",
    ),
    "v3_help_center_untouchback_title_sub":
        MessageLookupByLibrary.simpleMessage("Koppla bort touchback-läget."),
    "v3_instruction1a": MessageLookupByLibrary.simpleMessage(
      "Besök airsync.net eller öppna avsändarappen",
    ),
    "v3_instruction1b": MessageLookupByLibrary.simpleMessage(
      "Öppna avsändarappen",
    ),
    "v3_instruction2": MessageLookupByLibrary.simpleMessage("Ange visningskod"),
    "v3_instruction2_onethird": MessageLookupByLibrary.simpleMessage(
      "Skärmkod",
    ),
    "v3_instruction3": MessageLookupByLibrary.simpleMessage(
      "Ange engångslösenord",
    ),
    "v3_instruction3_onethird": MessageLookupByLibrary.simpleMessage(
      "Engångslösenord",
    ),
    "v3_instruction_share_screen": MessageLookupByLibrary.simpleMessage(
      "Dela dina skärmar",
    ),
    "v3_instruction_support": MessageLookupByLibrary.simpleMessage(
      "Stöder delning via AirPlay, Google Cast eller Miracast",
    ),
    "v3_last_casting_time_countdown": MessageLookupByLibrary.simpleMessage(
      "Skärmdelning är på väg att upphöra. Starta om skärmdelningen om det behövs.",
    ),
    "v3_lbl_authorize_prompt_accept": MessageLookupByLibrary.simpleMessage(
      "Acceptera begäran",
    ),
    "v3_lbl_authorize_prompt_accept_all": MessageLookupByLibrary.simpleMessage(
      "Acceptera alla förfrågningar",
    ),
    "v3_lbl_authorize_prompt_decline": MessageLookupByLibrary.simpleMessage(
      "Avvisa begäran",
    ),
        "v3_lbl_broadcast_multicast_checkbox":
            MessageLookupByLibrary.simpleMessage(
          "Casta till 10–100 enheter ",
        ),
        "v3_lbl_cast_device_close": MessageLookupByLibrary.simpleMessage(
      "Stäng anslutningen av Cast-enheten",
    ),
    "v3_lbl_cast_device_next": MessageLookupByLibrary.simpleMessage(
      "Nästa sida",
    ),
    "v3_lbl_cast_device_previous": MessageLookupByLibrary.simpleMessage(
      "Föregående sida",
    ),
    "v3_lbl_cast_device_sort_asc": MessageLookupByLibrary.simpleMessage(
      "Sortera stigande",
    ),
    "v3_lbl_cast_device_sort_desc": MessageLookupByLibrary.simpleMessage(
      "Sortera fallande",
    ),
    "v3_lbl_cast_device_touchback_disable":
        MessageLookupByLibrary.simpleMessage(
          "Inaktivera touchback för Cast-enhet",
        ),
    "v3_lbl_cast_device_touchback_enable": MessageLookupByLibrary.simpleMessage(
      "Aktivera touchback för Cast-enhet",
    ),
    "v3_lbl_close_download_app_menu": MessageLookupByLibrary.simpleMessage(
      "Stäng menyn för den nedladdade avsändarappen",
    ),
    "v3_lbl_close_feature_set_cast_device":
        MessageLookupByLibrary.simpleMessage("Stäng listan över cast-enheter"),
    "v3_lbl_close_feature_set_moderator": MessageLookupByLibrary.simpleMessage(
      "Stäng moderatorlistan",
    ),
    "v3_lbl_close_help_center": MessageLookupByLibrary.simpleMessage(
      "Stäng hjälpcentret",
    ),
    "v3_lbl_close_streaming_shortcut_menu":
        MessageLookupByLibrary.simpleMessage(
          "Stäng snabbmenyn för direktuppspelning",
        ),
    "v3_lbl_connection_dialog_close": MessageLookupByLibrary.simpleMessage(
      "Stäng dialogrutan för anslutningsstatus",
    ),
    "v3_lbl_eula_agree": MessageLookupByLibrary.simpleMessage(
      "Håller med EULA",
    ),
    "v3_lbl_eula_disagree": MessageLookupByLibrary.simpleMessage(
      "Accepterar inte EULA",
    ),
        "v3_lbl_eula_launch": MessageLookupByLibrary.simpleMessage("Starta"),
        "v3_lbl_exit_moderator_cancel": MessageLookupByLibrary.simpleMessage(
      "Avbryt att avsluta moderatorläget",
    ),
    "v3_lbl_exit_moderator_exit": MessageLookupByLibrary.simpleMessage(
      "Bekräfta att du avslutar moderatorläget",
    ),
    "v3_lbl_extend_casting_do_not_extend": MessageLookupByLibrary.simpleMessage(
      "Förläng inte delningstid",
    ),
    "v3_lbl_extend_casting_extend": MessageLookupByLibrary.simpleMessage(
      "Förläng tiden för delning",
    ),
    "v3_lbl_group_reject_close": MessageLookupByLibrary.simpleMessage(
      "Meddelande om avvisning av stängd grupp",
    ),
    "v3_lbl_internet_connection_only_error":
        MessageLookupByLibrary.simpleMessage(
          "Anslutningsfel, kontrollera enhetens nätverksinställning",
        ),
    "v3_lbl_internet_connection_warning": MessageLookupByLibrary.simpleMessage(
      "Endast lokal anslutning",
    ),
    "v3_lbl_main_language_title": MessageLookupByLibrary.simpleMessage(
      "Välj språk",
    ),
    "v3_lbl_main_language_title_item": MessageLookupByLibrary.simpleMessage(
      "Välj %s",
    ),
    "v3_lbl_message_dialog_cancel": MessageLookupByLibrary.simpleMessage(
      "Avbryt Dialogrutan ",
    ),
    "v3_lbl_message_dialog_confirm": MessageLookupByLibrary.simpleMessage(
      "Dialogrutan Bekräfta",
    ),
    "v3_lbl_minimal_quick_connect_menu": MessageLookupByLibrary.simpleMessage(
      "Minimera snabbanslutningsmenyn",
    ),
    "v3_lbl_minimal_streaming_qrcode_menu":
        MessageLookupByLibrary.simpleMessage(
          "Minimera menyn för strömmande QR-kod",
        ),
    "v3_lbl_moderator_toggle": MessageLookupByLibrary.simpleMessage(
      "Växla moderatorläge",
    ),
    "v3_lbl_open_download_app_menu": MessageLookupByLibrary.simpleMessage(
      "Öppna menyn för att ladda ner avsändarappen",
    ),
    "v3_lbl_open_feature_set_cast_device": MessageLookupByLibrary.simpleMessage(
      "Öppna listan över castade enheter",
    ),
    "v3_lbl_open_feature_set_moderator": MessageLookupByLibrary.simpleMessage(
      "Öppna moderatorlistan",
    ),
    "v3_lbl_open_help_center": MessageLookupByLibrary.simpleMessage(
      "Öppna menyn i hjälpcentret",
    ),
    "v3_lbl_open_menu_settings": MessageLookupByLibrary.simpleMessage(
      "Öppna inställningsmenyn",
    ),
    "v3_lbl_open_streaming_qrcode_menu": MessageLookupByLibrary.simpleMessage(
      "Öppna QR-kodmenyn för streaming",
    ),
    "v3_lbl_open_streaming_shortcut_menu": MessageLookupByLibrary.simpleMessage(
      "Öppna snabbmenyn för direktuppspelning",
    ),
    "v3_lbl_overlay_bring_app_to_top": MessageLookupByLibrary.simpleMessage(
      "Ta appen till toppen",
    ),
    "v3_lbl_overlay_menu_expand": MessageLookupByLibrary.simpleMessage(
      "Expandera överläggsmenyn",
    ),
    "v3_lbl_overlay_menu_minimize": MessageLookupByLibrary.simpleMessage(
      "Minimera överläggsmenyn",
    ),
    "v3_lbl_participant_cast_device": MessageLookupByLibrary.simpleMessage(
      "Casta enheten till den här mötesdeltagaren",
    ),
    "v3_lbl_participant_close": MessageLookupByLibrary.simpleMessage(
      "Stäng deltagaranslutning",
    ),
    "v3_lbl_participant_disconnect": MessageLookupByLibrary.simpleMessage(
      "Koppla bort den här mötesdeltagaren",
    ),
    "v3_lbl_participant_mirror_close": MessageLookupByLibrary.simpleMessage(
      "Stäng anslutning för speglingsdeltagare",
    ),
    "v3_lbl_participant_mirror_share": MessageLookupByLibrary.simpleMessage(
      "Dela till den här deltagarens spegling",
    ),
    "v3_lbl_participant_mirror_stop": MessageLookupByLibrary.simpleMessage(
      "Stoppa speglingen av deltagarnas strömning",
    ),
    "v3_lbl_participant_share": MessageLookupByLibrary.simpleMessage(
      "Dela till den här deltagarens skärm",
    ),
    "v3_lbl_participant_stop": MessageLookupByLibrary.simpleMessage(
      "Stoppa deltagares streaming",
    ),
    "v3_lbl_participant_touch_back": MessageLookupByLibrary.simpleMessage(
      "Aktivera touchback för den här mötesdeltagaren",
    ),
    "v3_lbl_participant_touch_back_disable":
        MessageLookupByLibrary.simpleMessage(
          "Inaktivera touchback för den här mötesdeltagaren",
        ),
    "v3_lbl_resizable_expand": MessageLookupByLibrary.simpleMessage(
      "Expandera presentationskontrollen",
    ),
    "v3_lbl_resizable_minimize": MessageLookupByLibrary.simpleMessage(
      "Minimera presentationskontroll",
    ),
    "v3_lbl_resizable_mute": MessageLookupByLibrary.simpleMessage(
      "Stäng av ljudet för presentationen",
    ),
    "v3_lbl_resizable_stop": MessageLookupByLibrary.simpleMessage(
      "Stoppa presentationen",
    ),
    "v3_lbl_settings_accessibility": MessageLookupByLibrary.simpleMessage(
      "Tillgänglighet",
    ),
    "v3_lbl_settings_back_icon": MessageLookupByLibrary.simpleMessage(
      "Tillbaka till föregående sida",
    ),
    "v3_lbl_settings_broadcast": MessageLookupByLibrary.simpleMessage(
      "Öppna menyn för sändningsinställningar",
    ),
    "v3_lbl_settings_broadcast_boards": MessageLookupByLibrary.simpleMessage(
      "Öppna menyn för sändningstavlor",
    ),
    "v3_lbl_settings_broadcast_devices": MessageLookupByLibrary.simpleMessage(
      "Öppna menyn för sändningsenheter",
    ),
    "v3_lbl_settings_broadcast_to_display_group":
        MessageLookupByLibrary.simpleMessage(
          "Öppna sändning för att visa gruppmenyn",
        ),
    "v3_lbl_settings_broadcast_to_display_group_cast":
        MessageLookupByLibrary.simpleMessage("Skicka ut"),
    "v3_lbl_settings_broadcast_to_display_group_checkbox":
        MessageLookupByLibrary.simpleMessage("Välj %s"),
    "v3_lbl_settings_broadcast_to_display_group_confirm":
        MessageLookupByLibrary.simpleMessage(
          "Bekräfta att ingen enhet har valts.",
        ),
    "v3_lbl_settings_broadcast_to_display_group_item":
        MessageLookupByLibrary.simpleMessage("Välj %s"),
    "v3_lbl_settings_broadcast_to_display_group_save":
        MessageLookupByLibrary.simpleMessage("Spara"),
    "v3_lbl_settings_broadcast_to_display_group_type":
        MessageLookupByLibrary.simpleMessage("Välj %s"),
    "v3_lbl_settings_close_icon": MessageLookupByLibrary.simpleMessage(
      "Stäng inställningsmenyn",
    ),
    "v3_lbl_settings_connectivity": MessageLookupByLibrary.simpleMessage(
      "Öppna menyn för anslutningsinställningar",
    ),
    "v3_lbl_settings_connectivity_item": MessageLookupByLibrary.simpleMessage(
      "Välj %s",
    ),
    "v3_lbl_settings_device_authorize_mode":
        MessageLookupByLibrary.simpleMessage("Slå på/av auktoriseringsläge"),
    "v3_lbl_settings_device_auto_fill_otp":
        MessageLookupByLibrary.simpleMessage(
          "Slå på/av OTP-läge för automatisk fyllning",
        ),
    "v3_lbl_settings_device_high_image_quality":
        MessageLookupByLibrary.simpleMessage(
          "v3_lbl_settings_device_high_image_quality",
        ),
    "v3_lbl_settings_device_launch_on_startup":
        MessageLookupByLibrary.simpleMessage("Slå på/av automatiskt startläge"),
    "v3_lbl_settings_device_name": MessageLookupByLibrary.simpleMessage(
      "Ändra enhetsnamn",
    ),
    "v3_lbl_settings_device_name_close": MessageLookupByLibrary.simpleMessage(
      "Stäng inställningen för enhetsnamn",
    ),
    "v3_lbl_settings_device_name_save": MessageLookupByLibrary.simpleMessage(
      "Spara enhetsnamn",
    ),
    "v3_lbl_settings_device_setting": MessageLookupByLibrary.simpleMessage(
      "Öppna enhetens inställningsmeny",
    ),
    "v3_lbl_settings_device_smart_scaling":
        MessageLookupByLibrary.simpleMessage(
          "Slå på/av växlingsknapp för smart skalning",
        ),
    "v3_lbl_settings_enter_device_name": MessageLookupByLibrary.simpleMessage(
      "Ange enhetsnamn",
    ),
    "v3_lbl_settings_invite_group": MessageLookupByLibrary.simpleMessage(
      "Öppna rullgardinsmenyn för skärmsändning",
    ),
    "v3_lbl_settings_invite_group_item": MessageLookupByLibrary.simpleMessage(
      "Välj %s",
    ),
    "v3_lbl_settings_knowledge_base": MessageLookupByLibrary.simpleMessage(
      "v3_lbl_settings_knowledge_base",
    ),
    "v3_lbl_settings_legal_policy": MessageLookupByLibrary.simpleMessage(
      "Öppna inställningsmenyn för juridisk princip",
    ),
    "v3_lbl_settings_menu_locked": MessageLookupByLibrary.simpleMessage(
      "Inställningsmenyn är låst",
    ),
    "v3_lbl_settings_mirroring_auto_accept":
        MessageLookupByLibrary.simpleMessage("Slå på/av automatisk accept"),
    "v3_lbl_settings_mirroring_require_passcode":
        MessageLookupByLibrary.simpleMessage("Slå på/av krav för lösenkod"),
    "v3_lbl_settings_only_when_casting_info":
        MessageLookupByLibrary.simpleMessage(
          "Mer information om sändning till visningsgrupp",
        ),
    "v3_lbl_settings_open_source_license": MessageLookupByLibrary.simpleMessage(
      "Välj %s",
    ),
    "v3_lbl_settings_show_display_code": MessageLookupByLibrary.simpleMessage(
      "Slå på/av växling av visningskod",
    ),
    "v3_lbl_settings_whats_new": MessageLookupByLibrary.simpleMessage(
      "Öppna inställningsmenyn för nyheter",
    ),
    "v3_lbl_settings_whats_new_icon": MessageLookupByLibrary.simpleMessage(
      "Ikon för nyheter",
    ),
    "v3_lbl_shortcuts_airplay": MessageLookupByLibrary.simpleMessage(
      "Slå på/av AirPlay",
    ),
    "v3_lbl_shortcuts_google_cast": MessageLookupByLibrary.simpleMessage(
      "Aktivera/inaktivera Google Cast",
    ),
    "v3_lbl_shortcuts_miracast": MessageLookupByLibrary.simpleMessage(
      "Slå på/av Miracast",
    ),
    "v3_lbl_shortcuts_mirroring": MessageLookupByLibrary.simpleMessage(
      "Öppna inställningsmenyn för spegling",
    ),
    "v3_lbl_streaming_airplay_touchback": MessageLookupByLibrary.simpleMessage(
      "Airplay touchback",
    ),
    "v3_lbl_streaming_page_control": MessageLookupByLibrary.simpleMessage(
      "Nästa sida",
    ),
    "v3_lbl_streaming_shortcut_airplay_toggle":
        MessageLookupByLibrary.simpleMessage("AirPlay-reglage"),
    "v3_lbl_streaming_shortcut_cast_device_toggle":
        MessageLookupByLibrary.simpleMessage("Växla växla casta till enheter"),
    "v3_lbl_streaming_shortcut_expand": MessageLookupByLibrary.simpleMessage(
      "Utöka strömningsfunktioner",
    ),
    "v3_lbl_streaming_shortcut_google_cast_toggle":
        MessageLookupByLibrary.simpleMessage("Google Cast växling"),
    "v3_lbl_streaming_shortcut_menu_locked":
        MessageLookupByLibrary.simpleMessage(
          "Direktuppspelning Snabbmenyn är låst",
        ),
    "v3_lbl_streaming_shortcut_minimize": MessageLookupByLibrary.simpleMessage(
      "Komprimera strömningsfunktioner",
    ),
    "v3_lbl_streaming_shortcut_miracast_toggle":
        MessageLookupByLibrary.simpleMessage("Miracast-växling"),
    "v3_lbl_streaming_view_expand": MessageLookupByLibrary.simpleMessage(
      "Expandera strömningsvyn",
    ),
    "v3_lbl_streaming_view_function_expand":
        MessageLookupByLibrary.simpleMessage("Expandera strömningsfunktionen"),
    "v3_lbl_streaming_view_function_minimize":
        MessageLookupByLibrary.simpleMessage("Komprimera strömningsfunktion"),
    "v3_lbl_streaming_view_minimize": MessageLookupByLibrary.simpleMessage(
      "Komprimera direktuppspelningsvy",
    ),
    "v3_lbl_streaming_view_mute": MessageLookupByLibrary.simpleMessage(
      "Stäng av ljudet",
    ),
    "v3_lbl_streaming_view_stop": MessageLookupByLibrary.simpleMessage(
      "Sluta streama",
    ),
    "v3_lbl_streaming_view_unmute": MessageLookupByLibrary.simpleMessage(
      "Slå på ljudet",
    ),
    "v3_lbl_touchback_one_device_cancel": MessageLookupByLibrary.simpleMessage(
      "Avbryt Dialogrutan ",
    ),
    "v3_lbl_touchback_one_device_confirm": MessageLookupByLibrary.simpleMessage(
      "Bekräfta",
    ),
    "v3_lbl_touchback_restart_bluetooth_btn_cancel":
        MessageLookupByLibrary.simpleMessage("Avbryt"),
    "v3_lbl_touchback_restart_bluetooth_btn_restart":
        MessageLookupByLibrary.simpleMessage("Starta om"),
    "v3_main_connection_dialog_close": MessageLookupByLibrary.simpleMessage(
      "Stäng",
    ),
    "v3_main_internet_connection_only": MessageLookupByLibrary.simpleMessage(
      "Endast internetanslutning。",
    ),
    "v3_main_internet_connection_only_error":
        MessageLookupByLibrary.simpleMessage(
          "Anslutningsfel, kontrollera enhetens nätverksinställning。",
        ),
    "v3_main_internet_connection_only_error_dialog_desc":
        MessageLookupByLibrary.simpleMessage(
          "Anslutningsfel, kontrollera enhetens nätverksinställning。",
        ),
    "v3_main_local_connection_only_dialog_desc":
        MessageLookupByLibrary.simpleMessage(
          "Endast LAN-anslutning, kontrollera enhetens nätverksinställning。",
        ),
    "v3_main_status_no_network": MessageLookupByLibrary.simpleMessage(
      "Kan inte upptäcka en internetanslutning. Anslut till ett Wi-Fi- eller intranätsnätverk och försök igen.",
    ),
    "v3_miracast_not_support": MessageLookupByLibrary.simpleMessage(
      "Miracast är inte tillgängligt nu. Den aktuella Wi-Fi-kanalen har inte stöd för skärmcasting.",
    ),
    "v3_miracast_uibc_not_supported_message":
        MessageLookupByLibrary.simpleMessage(
          "Den här källan stöder inte Miracast-touchback",
        ),
    "v3_mirror_request_passcode": MessageLookupByLibrary.simpleMessage(
      "Lösenkod",
    ),
    "v3_moderator_disable_mirror_cancel": MessageLookupByLibrary.simpleMessage(
      "Avbryt",
    ),
    "v3_moderator_disable_mirror_desc": MessageLookupByLibrary.simpleMessage(
      "Spegling kommer att inaktiveras i moderatormodus",
    ),
    "v3_moderator_disable_mirror_ok": MessageLookupByLibrary.simpleMessage(
      "OK",
    ),
    "v3_moderator_disable_mirror_title": MessageLookupByLibrary.simpleMessage(
      "Inaktivera spegling för moderatormodus",
    ),
    "v3_moderator_mode": MessageLookupByLibrary.simpleMessage("Moderator-läge"),
    "v3_new_sharing_join_session": MessageLookupByLibrary.simpleMessage(
      "Gick med i sessionen",
    ),
    "v3_participant_item_casting": MessageLookupByLibrary.simpleMessage(
      "Delar",
    ),
    "v3_participant_item_connected": MessageLookupByLibrary.simpleMessage(
      "Ansluten",
    ),
    "v3_participant_item_controlling": MessageLookupByLibrary.simpleMessage(
      "Tar emot + Touchback",
    ),
    "v3_participant_item_receiving": MessageLookupByLibrary.simpleMessage(
      "Tar emot",
    ),
    "v3_participant_item_share": MessageLookupByLibrary.simpleMessage("Dela"),
    "v3_participant_item_waiting": MessageLookupByLibrary.simpleMessage(
      "Väntar...",
    ),
    "v3_participants_desc": MessageLookupByLibrary.simpleMessage(
      "Max upp till 6 deltagare.",
    ),
    "v3_participants_desc_maximum_9": MessageLookupByLibrary.simpleMessage(
      "Max upp till 9 deltagare.",
    ),
    "v3_participants_title": MessageLookupByLibrary.simpleMessage("Deltagare"),
    "v3_qrcode_quick_connect": MessageLookupByLibrary.simpleMessage(
      "Snabbanslutning",
    ),
    "v3_quick_connect_menu_bottom_msg": MessageLookupByLibrary.simpleMessage(
      "Delad skärm aktiveras om två eller flera användare delar skärmar.",
    ),
    "v3_quick_connect_menu_display_code": MessageLookupByLibrary.simpleMessage(
      "Display kod",
    ),
    "v3_quick_connect_menu_qrcode": MessageLookupByLibrary.simpleMessage(
      "QR-kod",
    ),
    "v3_setting_passcode_cancel": MessageLookupByLibrary.simpleMessage(
      "Avbryt",
    ),
    "v3_setting_passcode_clear": MessageLookupByLibrary.simpleMessage("Rensa"),
    "v3_setting_passcode_confirm": MessageLookupByLibrary.simpleMessage(
      "Bekräfta",
    ),
    "v3_setting_passcode_error_description":
        MessageLookupByLibrary.simpleMessage("Ogiltigt lösenord, försök igen."),
    "v3_setting_passcode_title": MessageLookupByLibrary.simpleMessage(
      "Ange lösenord för att låsa upp Inställningar",
    ),
    "v3_settings_accessibility": MessageLookupByLibrary.simpleMessage(
      "Tillgänglighet",
    ),
    "v3_settings_all_the_time_info": MessageLookupByLibrary.simpleMessage(
      "https://s3.eu-west-1.amazonaws.com/po-pub/i/Aq0gfcuWlTNP5C8gs21VQiAG.png",
    ),
    "v3_settings_broadcast": MessageLookupByLibrary.simpleMessage("Skicka ut"),
    "v3_settings_broadcast_boards": MessageLookupByLibrary.simpleMessage(
      "Andra AirSync-enheter",
    ),
    "v3_settings_broadcast_cast_boards": MessageLookupByLibrary.simpleMessage(
      "Casta till tavlor",
    ),
    "v3_settings_broadcast_cast_boards_desc":
        MessageLookupByLibrary.simpleMessage(
          "Dela din skärm till alla interaktiva skärmar (IFP) i nätverket.",
        ),
    "v3_settings_broadcast_cast_to": MessageLookupByLibrary.simpleMessage(
      "Sänd till",
    ),
    "v3_settings_broadcast_devices": MessageLookupByLibrary.simpleMessage(
      "Sändarenheter",
    ),
    "v3_settings_broadcast_screen_energy_saving":
        MessageLookupByLibrary.simpleMessage(
          "Stäng av energisparfunktionen för att undvika oväntade avbrott under sändningen.",
        ),
    "v3_settings_broadcast_to_display_group":
        MessageLookupByLibrary.simpleMessage("Sänd till skärmgrupp"),
    "v3_settings_connectivity": MessageLookupByLibrary.simpleMessage(
      "Anslutning",
    ),
    "v3_settings_connectivity_both": MessageLookupByLibrary.simpleMessage(
      "Både internet- och lokal anslutning",
    ),
    "v3_settings_connectivity_internet": MessageLookupByLibrary.simpleMessage(
      "Internetanslutning",
    ),
    "v3_settings_connectivity_internet_desc":
        MessageLookupByLibrary.simpleMessage(
          "Internetanslutning kräver ett stabilt nätverk.",
        ),
    "v3_settings_connectivity_local": MessageLookupByLibrary.simpleMessage(
      "Lokal anslutning",
    ),
    "v3_settings_connectivity_local_desc": MessageLookupByLibrary.simpleMessage(
      "Lokala anslutningar fungerar inom ett privat nätverk och erbjuder mer säkerhet och stabilitet.",
    ),
    "v3_settings_device_authorize_mode": MessageLookupByLibrary.simpleMessage(
      "Tillåt skärmdelning endast med godkännande.",
    ),
    "v3_settings_device_auto_fill_otp": MessageLookupByLibrary.simpleMessage(
      "Autofyll engångslösenord",
    ),
    "v3_settings_device_auto_fill_otp_desc": MessageLookupByLibrary.simpleMessage(
      "Aktivera anslutning med ett tryck när du väljer en enhet från enhetslistan.",
    ),
    "v3_settings_device_high_image_quality":
        MessageLookupByLibrary.simpleMessage("Hög bildkvalitet"),
        "v3_settings_device_high_image_quality_off_desc":
            MessageLookupByLibrary.simpleMessage(
          "Maximal QHD-skärmdelning (2K) beroende på avsändarens skärmupplösning.",
        ),
        "v3_settings_device_high_image_quality_on_desc":
            MessageLookupByLibrary.simpleMessage(
          "Maximal UHD-skärmdelning (4K) från webbavsändaren och 3K+ från Windows- och macOS-avsändaren beroende på avsändarens skärmupplösning. Kräver ett nätverk av hög kvalitet.",
        ),
        "v3_settings_device_launch_on_startup":
        MessageLookupByLibrary.simpleMessage("Starta AirSync vid start"),
    "v3_settings_device_name": MessageLookupByLibrary.simpleMessage(
      "Enhets namn",
    ),
    "v3_settings_device_name_empty_error": MessageLookupByLibrary.simpleMessage(
      "Enhetsnamnet får inte vara tomt",
    ),
    "v3_settings_device_name_save": MessageLookupByLibrary.simpleMessage(
      "Spara",
    ),
    "v3_settings_device_not_supported": MessageLookupByLibrary.simpleMessage(
      "Enhetsversionen stöds inte",
    ),
    "v3_settings_device_setting": MessageLookupByLibrary.simpleMessage(
      "Enhetsinställning",
    ),
    "v3_settings_device_show_display_code":
        MessageLookupByLibrary.simpleMessage("Visa skärmkod överst"),
    "v3_settings_device_show_display_code_desc":
        MessageLookupByLibrary.simpleMessage(
          "Håll koden synlig högst upp på skärmen, även när du växlar till andra appar och skärmdelning är aktiv.",
        ),
    "v3_settings_device_smart_scaling": MessageLookupByLibrary.simpleMessage(
      "Smart skalning",
    ),
    "v3_settings_device_smart_scaling_desc": MessageLookupByLibrary.simpleMessage(
      "Justera skärmstorleken automatiskt för att maximera användningen av skärmutrymmet. Bilden kan vara något förvrängd.",
    ),
    "v3_settings_device_unavailable": MessageLookupByLibrary.simpleMessage(
      "Ej tillgänglig",
    ),
    "v3_settings_display_group": MessageLookupByLibrary.simpleMessage(
      "Skärmgrupp",
    ),
    "v3_settings_display_group_all_the_time":
        MessageLookupByLibrary.simpleMessage("Alltid"),
    "v3_settings_display_group_cast": MessageLookupByLibrary.simpleMessage(
      "Skicka ut",
    ),
    "v3_settings_display_group_only_casting":
        MessageLookupByLibrary.simpleMessage("Endast vid casting"),
    "v3_settings_feature_locked": MessageLookupByLibrary.simpleMessage(
      "Låst av ViewSonic Manager.",
    ),
    "v3_settings_invite_group": MessageLookupByLibrary.simpleMessage(
      "Om jag blir inbjuden till en skärmgrupp",
    ),
    "v3_settings_invite_group_auto_accept":
        MessageLookupByLibrary.simpleMessage("Acceptera automatiskt"),
    "v3_settings_invite_group_ignore": MessageLookupByLibrary.simpleMessage(
      "Bortse från detta",
    ),
    "v3_settings_invite_group_notify_me": MessageLookupByLibrary.simpleMessage(
      "Meddela mig",
    ),
    "v3_settings_knowledge_base": MessageLookupByLibrary.simpleMessage(
      "Kunskapsbas",
    ),
    "v3_settings_legal_policy": MessageLookupByLibrary.simpleMessage(
      "Juridik och policy",
    ),
    "v3_settings_local_connection_only": MessageLookupByLibrary.simpleMessage(
      "Endast lokal anslutning",
    ),
    "v3_settings_mirroring_auto_accept": MessageLookupByLibrary.simpleMessage(
      "Acceptera automatiskt",
    ),
    "v3_settings_mirroring_auto_accept_desc":
        MessageLookupByLibrary.simpleMessage(
          "Aktivera spegling direkt utan att kräva moderatorgodkännande.",
        ),
    "v3_settings_mirroring_blocked": MessageLookupByLibrary.simpleMessage(
      "Stäng av moderatormodus först.",
    ),
    "v3_settings_mirroring_require_passcode":
        MessageLookupByLibrary.simpleMessage("Kräv lösenkod"),
    "v3_settings_only_when_casting_info": MessageLookupByLibrary.simpleMessage(
      "Sänd endast IFP-källskärmen när den tar emot en delad skärmbild",
    ),
    "v3_settings_open_source_license": MessageLookupByLibrary.simpleMessage(
      "Öppna källicenser",
    ),
    "v3_settings_privacy_policy": MessageLookupByLibrary.simpleMessage(
      "Integritetspolicy",
    ),
    "v3_settings_privacy_policy_description": MessageLookupByLibrary.simpleMessage(
      "ViewSonic är engagerad i att skydda din integritet och hanterar personuppgifter med största allvar. Integritetspolicyn nedan beskriver hur ViewSonic behandlar dina personuppgifter efter att de har samlats in via din användning av webbplatsen. ViewSonic upprätthåller sekretessen för din information genom säkerhetstekniker och följer policyer som förhindrar obehörig användning av dina personuppgifter. Genom att använda denna webbplats samtycker du till insamling och användning av din information.\n\nWebbplatser som du länkar till från ViewSonic.com kan ha egna integritetspolicyer som skiljer sig från ViewSonics. Vänligen granska dessa webbplatsers integritetspolicyer för detaljerad information om hur de kan använda information som samlas in när du besöker dem.\n\nKlicka på följande länkar för att lära dig mer om vår integritetspolicy.",
    ),
    "v3_settings_resize_text_size": MessageLookupByLibrary.simpleMessage(
      "Ändra text storlek",
    ),
    "v3_settings_resize_text_size_extra_large":
        MessageLookupByLibrary.simpleMessage("Extra Stor"),
    "v3_settings_resize_text_size_large": MessageLookupByLibrary.simpleMessage(
      "Stor",
    ),
    "v3_settings_resize_text_size_normal": MessageLookupByLibrary.simpleMessage(
      "Normal",
    ),
    "v3_settings_version": m1,
    "v3_settings_whats_new": MessageLookupByLibrary.simpleMessage("Nyheter"),
    "v3_settings_whats_new_content": MessageLookupByLibrary.simpleMessage(
      "AirSync %s\nAirSync är en egenutvecklad trådlös skärmdelningslösning från ViewSonic. När den används med AirSync-sändaren möjliggör den smidig skärmdelning från användarens enhet till ViewSonics interaktiva skärmar.\nHuvudfunktioner:\n1.\tTrådlös skärmdelning.\n2.\tAutomatisk uppdelning av skärmar för flera presentatörer.\n3.\tModeratormodus för bättre kontroll under presentationer.\n4.\tSkärmspegling som stöder AirPlay, Google Cast och Miracast.\n5.\tCasta till enhet med fjärrkontroll.\n6.\tCasta till tavla för att sända skärmar till flera stora skärmar.\n7.\tAnnotation.\n8.\tInteragera med Windows-, macOS-, iOS-, Android- och webbversionen av AirSync-sändaren.\n9.\tTouchback stöds i Windows- och macOS-sändare.\n",
    ),
    "v3_shortcuts_airplay": MessageLookupByLibrary.simpleMessage("AirPlay"),
    "v3_shortcuts_cast_device": MessageLookupByLibrary.simpleMessage(
      "Casta till enheter",
    ),
    "v3_shortcuts_cast_device_desc": MessageLookupByLibrary.simpleMessage(
      "Casta din skärm till flera enheter, inklusive bärbara datorer, surfplattor och mobila enheter samtidigt.",
    ),
    "v3_shortcuts_google_cast": MessageLookupByLibrary.simpleMessage(
      "Google Cast",
    ),
    "v3_shortcuts_menu_title": MessageLookupByLibrary.simpleMessage("Genvägar"),
    "v3_shortcuts_miracast": MessageLookupByLibrary.simpleMessage("Miracast"),
    "v3_shortcuts_mirroring": MessageLookupByLibrary.simpleMessage("Spegling"),
    "v3_touchback_alert_message": MessageLookupByLibrary.simpleMessage(
      "Du kan bara göra touchback en enhet åt gången.",
    ),
    "v3_touchback_alert_title": MessageLookupByLibrary.simpleMessage(
      "Touchback till %s?",
    ),
    "v3_touchback_disable_message": MessageLookupByLibrary.simpleMessage(
      "TouchBack är inaktiverat.",
    ),
    "v3_touchback_fail_message": MessageLookupByLibrary.simpleMessage(
      "Parningen misslyckades. TouchBack är inte aktiverat. Försök igen",
    ),
    "v3_touchback_restart_bluetooth_btn_cancel":
        MessageLookupByLibrary.simpleMessage("Avbryt"),
    "v3_touchback_restart_bluetooth_btn_restart":
        MessageLookupByLibrary.simpleMessage("Starta om"),
    "v3_touchback_restart_bluetooth_message": MessageLookupByLibrary.simpleMessage(
      "Tidsgräns för åtgärd. Stäng av och starta om Bluetooth-funktionen på den stora skärmen och starta sedan om touchback.",
    ),
    "v3_touchback_restart_bluetooth_title":
        MessageLookupByLibrary.simpleMessage(
          "Funktionen har avslutat, starta om Bluetooth",
        ),
    "v3_touchback_state_deviceFinding_message":
        MessageLookupByLibrary.simpleMessage("Hitta enhet"),
    "v3_touchback_state_deviceFoundSuccess_message":
        MessageLookupByLibrary.simpleMessage("Enheten hittades korrekt"),
    "v3_touchback_state_devicePairedSuccess_message":
        MessageLookupByLibrary.simpleMessage("Enhet parad"),
    "v3_touchback_state_devicePairing_message":
        MessageLookupByLibrary.simpleMessage("Parning av enhet"),
    "v3_touchback_state_hidConnected_message":
        MessageLookupByLibrary.simpleMessage("Hid ansluten"),
    "v3_touchback_state_hidConnecting_message":
        MessageLookupByLibrary.simpleMessage("Hid anslutning"),
    "v3_touchback_state_hidProfileServiceStartedSuccess_message":
        MessageLookupByLibrary.simpleMessage("Hid-profiltjänsten har startat"),
    "v3_touchback_state_hidProfileServiceStarting_message":
        MessageLookupByLibrary.simpleMessage(
          "Tjänsten för dold profil startar",
        ),
    "v3_touchback_state_initialized_message":
        MessageLookupByLibrary.simpleMessage("Initierats"),
    "v3_touchback_state_initializing_message":
        MessageLookupByLibrary.simpleMessage("Initierar"),
    "v3_touchback_success_message": MessageLookupByLibrary.simpleMessage(
      "Du kan nu fjärrstyra %s från IFP.",
    ),
    "v3_waiting_desc": MessageLookupByLibrary.simpleMessage(
      "Väntar på att den här deltagaren ska dela sin skärm",
    ),
    "v3_waiting_join": MessageLookupByLibrary.simpleMessage(
      "Väntar på att andra ska gå med",
    ),
    "v3_waiting_up_next": MessageLookupByLibrary.simpleMessage("NÄSTA"),
    "vbs_ota_progress_msg": MessageLookupByLibrary.simpleMessage(
      "Ladda ner systemuppdateringar",
    ),
  };
}
