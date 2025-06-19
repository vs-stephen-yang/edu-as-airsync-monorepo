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

  static String m0(value) => "Välj en skärm att dela inom ${value} sekunder...";

  static String m1(year) =>
      "Copyright © ViewSonic Corporation ${year}. Alla rättigheter förbehållna.";

  static String m2(year, version) => "AirSync ©${year}. version ${version}";

  static String m3(year, version) =>
      "AirSync © ${year}. version ${version} (Ind.)";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "device_list_enter_pin":
            MessageLookupByLibrary.simpleMessage("Engångslösenord"),
        "device_list_enter_pin_ok": MessageLookupByLibrary.simpleMessage("OK"),
        "main_connect_network_error": MessageLookupByLibrary.simpleMessage(
            "Nätverksfel. Kontrollera nätverksanslutningen och försök igen."),
        "main_connect_rate_limited": MessageLookupByLibrary.simpleMessage(
            "AirSync-instansen är upptagen. Försök igen senare."),
        "main_connect_unknown_error":
            MessageLookupByLibrary.simpleMessage("Okänt fel."),
        "main_connection_mode_unsupported":
            MessageLookupByLibrary.simpleMessage(
                "AirSync kan inte ansluta till internet."),
        "main_device_list":
            MessageLookupByLibrary.simpleMessage("Snabbanslutning"),
        "main_display_code": MessageLookupByLibrary.simpleMessage("Skärmkod"),
        "main_display_code_description":
            MessageLookupByLibrary.simpleMessage("Ange skärmkod"),
        "main_display_code_error": MessageLookupByLibrary.simpleMessage(
            "Accepterar endast bokstäver och siffror."),
        "main_display_code_exceed": MessageLookupByLibrary.simpleMessage(
            "Maximalt antal deltagare (6) har uppnåtts."),
        "main_display_code_exceed_split_screen":
            MessageLookupByLibrary.simpleMessage(
                "Maximalt antal presentatörer (4) har uppnåtts."),
        "main_display_code_invalid":
            MessageLookupByLibrary.simpleMessage("Ogiltig skärmkod"),
        "main_feature_reconnect_fail_toast":
            MessageLookupByLibrary.simpleMessage(
                "Nätverk (Control) kunde inte återansluta"),
        "main_feature_reconnect_success_toast":
            MessageLookupByLibrary.simpleMessage(
                "Nätverk (Control) återanslöt framgångsrikt"),
        "main_feature_reconnecting_toast": MessageLookupByLibrary.simpleMessage(
            "Nätverk (Control) återansluter"),
        "main_instance_not_found_or_offline":
            MessageLookupByLibrary.simpleMessage(
                "Skärmkod hittades inte eller instansen är offline."),
        "main_language": MessageLookupByLibrary.simpleMessage("Språk"),
        "main_language_name": MessageLookupByLibrary.simpleMessage("Engelska"),
        "main_notice_not_support_description": MessageLookupByLibrary.simpleMessage(
            "Delning via webbläsare stöds inte på mobila enheter. Ladda ner och använd AirSync-sändarappen för en bättre upplevelse."),
        "main_notice_positive_button": MessageLookupByLibrary.simpleMessage(
            "Ladda ner AirSync-sändarapp."),
        "main_notice_title": MessageLookupByLibrary.simpleMessage("Meddelande"),
        "main_otp_error":
            MessageLookupByLibrary.simpleMessage("Accepterar endast siffror."),
        "main_password": MessageLookupByLibrary.simpleMessage("Lösenord"),
        "main_password_description":
            MessageLookupByLibrary.simpleMessage("Ange engångslösenord"),
        "main_password_invalid":
            MessageLookupByLibrary.simpleMessage("Ogiltigt lösenord."),
        "main_present": MessageLookupByLibrary.simpleMessage("Nästa"),
        "main_setting": MessageLookupByLibrary.simpleMessage("Inställningar"),
        "main_touch_back": MessageLookupByLibrary.simpleMessage("Touchback"),
        "main_update_deny_button":
            MessageLookupByLibrary.simpleMessage("Inte nu"),
        "main_update_description_android": MessageLookupByLibrary.simpleMessage(
            "Klicka på \"Uppdatera\" för att installera den nya versionen."),
        "main_update_description_apple": MessageLookupByLibrary.simpleMessage(
            "Klicka på \"Uppdatera\" för att installera den nya versionen."),
        "main_update_description_windows": MessageLookupByLibrary.simpleMessage(
            "Klicka på \"Uppdatera\" för att installera den nya versionen."),
        "main_update_error_detail":
            MessageLookupByLibrary.simpleMessage("Beskrivning:"),
        "main_update_error_title": MessageLookupByLibrary.simpleMessage(
            "Versionen kunde inte uppdateras"),
        "main_update_error_type":
            MessageLookupByLibrary.simpleMessage("Felorsak:"),
        "main_update_positive_button":
            MessageLookupByLibrary.simpleMessage("Uppdatera"),
        "main_update_title":
            MessageLookupByLibrary.simpleMessage("Ny version tillgänglig"),
        "main_webrtc_reconnect_fail_toast":
            MessageLookupByLibrary.simpleMessage(
                "Nätverk (WebRTC) kunde inte återansluta"),
        "main_webrtc_reconnect_success_toast":
            MessageLookupByLibrary.simpleMessage(
                "Nätverk (WebRTC) återanslöt framgångsrikt"),
        "main_webrtc_reconnecting_toast": MessageLookupByLibrary.simpleMessage(
            "Nätverk (WebRTC) återansluter"),
        "moderator": MessageLookupByLibrary.simpleMessage("Ange ditt namn"),
        "moderator_back": MessageLookupByLibrary.simpleMessage("Tillbaka"),
        "moderator_exit": MessageLookupByLibrary.simpleMessage("AVSLUTA"),
        "moderator_fill_out":
            MessageLookupByLibrary.simpleMessage("Fältet krävs"),
        "moderator_name": MessageLookupByLibrary.simpleMessage("Namn"),
        "moderator_wait": MessageLookupByLibrary.simpleMessage(
            "Vänta medan moderatorn väljer presentatörer..."),
        "present_role_cast_screen":
            MessageLookupByLibrary.simpleMessage("Dela skärm"),
        "present_role_receive":
            MessageLookupByLibrary.simpleMessage("Ta emot skärmbild"),
        "present_select_screen_cancel":
            MessageLookupByLibrary.simpleMessage("Avbryt"),
        "present_select_screen_description":
            MessageLookupByLibrary.simpleMessage(
                "Välj en vy att dela med mottagande skärm."),
        "present_select_screen_entire":
            MessageLookupByLibrary.simpleMessage("Hela skärmen"),
        "present_select_screen_ios_restart":
            MessageLookupByLibrary.simpleMessage("Starta sändning"),
        "present_select_screen_ios_restart_description":
            MessageLookupByLibrary.simpleMessage(
                "Klicka på \"Starta sändning\" för att återuppta delning innan timeout eller klicka på \"Tillbaka\" för att återgå till startsidan."),
        "present_select_screen_share":
            MessageLookupByLibrary.simpleMessage("Dela"),
        "present_select_screen_share_audio":
            MessageLookupByLibrary.simpleMessage("Dela skärmens ljud"),
        "present_select_screen_window":
            MessageLookupByLibrary.simpleMessage("Fönster"),
        "present_state_high_quality_description":
            MessageLookupByLibrary.simpleMessage(
                "Aktivera hög kvalitet vid goda nätverksförhållanden."),
        "present_state_high_quality_title":
            MessageLookupByLibrary.simpleMessage("Hög kvalitet"),
        "present_state_pause": MessageLookupByLibrary.simpleMessage("Pausa"),
        "present_state_resume":
            MessageLookupByLibrary.simpleMessage("Återuppta"),
        "present_state_stop":
            MessageLookupByLibrary.simpleMessage("Avsluta presentation"),
        "present_time": MessageLookupByLibrary.simpleMessage("Tid förfluten"),
        "present_time_unit_hour": MessageLookupByLibrary.simpleMessage("tim"),
        "present_time_unit_min": MessageLookupByLibrary.simpleMessage("min"),
        "present_time_unit_sec": MessageLookupByLibrary.simpleMessage("sek"),
        "present_wait": m0,
        "remote_screen_connect_error": MessageLookupByLibrary.simpleMessage(
            "Fel vid anslutning till fjärrskärm"),
        "remote_screen_wait":
            MessageLookupByLibrary.simpleMessage("Delning bearbetas. Vänta."),
        "settings_audio_configuration":
            MessageLookupByLibrary.simpleMessage("Ljudkonfiguration"),
        "settings_knowledge_base":
            MessageLookupByLibrary.simpleMessage("Kunskapsbas"),
        "toast_enable_remote_screen": MessageLookupByLibrary.simpleMessage(
            "Aktivera delning av skärm till enhet i AirSync."),
        "toast_install_audio_driver": MessageLookupByLibrary.simpleMessage(
            "Installera virtuell ljuddrivrutin."),
        "toast_maximum_moderated": MessageLookupByLibrary.simpleMessage(
            "Maximalt antal modererade sessioner har uppnåtts."),
        "toast_maximum_remote_screen": MessageLookupByLibrary.simpleMessage(
            "Maximalt antal delade skärmar har uppnåtts."),
        "toast_maximum_split_screen": MessageLookupByLibrary.simpleMessage(
            "Maximalt antal delade skärmar har uppnåtts."),
        "v3_device_list_button_device_list":
            MessageLookupByLibrary.simpleMessage("Enhetslista"),
        "v3_device_list_button_text":
            MessageLookupByLibrary.simpleMessage("Snabbanslut genom"),
        "v3_device_list_dialog_connect":
            MessageLookupByLibrary.simpleMessage("Anslut"),
        "v3_device_list_dialog_invalid_otp":
            MessageLookupByLibrary.simpleMessage("Felaktigt engångslösenord"),
        "v3_device_list_dialog_title":
            MessageLookupByLibrary.simpleMessage("Ange engångslösenord"),
        "v3_eula_agree": MessageLookupByLibrary.simpleMessage("Godkänn"),
        "v3_eula_disagree": MessageLookupByLibrary.simpleMessage("Avböj"),
        "v3_eula_title": MessageLookupByLibrary.simpleMessage(
            "Licensavtal för slutanvändare"),
        "v3_lbl_change_language":
            MessageLookupByLibrary.simpleMessage("Ändra språk"),
        "v3_lbl_device_list_button_device_list":
            MessageLookupByLibrary.simpleMessage("Enhetslista"),
        "v3_lbl_device_list_close":
            MessageLookupByLibrary.simpleMessage("Stäng enhetslistan"),
        "v3_lbl_device_list_next":
            MessageLookupByLibrary.simpleMessage("Nästa"),
        "v3_lbl_download_independent_version":
            MessageLookupByLibrary.simpleMessage(
                "Skaffa den oberoende Mac-versionen"),
        "v3_lbl_download_menu_minimal":
            MessageLookupByLibrary.simpleMessage("Minimal meny"),
        "v3_lbl_main_display_code":
            MessageLookupByLibrary.simpleMessage("Skriv in Visningskod"),
        "v3_lbl_main_display_code_remove":
            MessageLookupByLibrary.simpleMessage("Ta bort visningskod"),
        "v3_lbl_main_download":
            MessageLookupByLibrary.simpleMessage("Ladda ner Sender App"),
        "v3_lbl_main_download_mac_store": MessageLookupByLibrary.simpleMessage(
            "Skaffa Mac App Store-versionen"),
        "v3_lbl_main_download_mobile":
            MessageLookupByLibrary.simpleMessage("Skaffa mobilversionen"),
        "v3_lbl_main_download_windows":
            MessageLookupByLibrary.simpleMessage("Skaffa Windows-versionen"),
        "v3_lbl_main_moderator_action":
            MessageLookupByLibrary.simpleMessage("Dela möte"),
        "v3_lbl_main_moderator_input_hint":
            MessageLookupByLibrary.simpleMessage("Skriv ditt namn"),
        "v3_lbl_main_password":
            MessageLookupByLibrary.simpleMessage("Ange Lösenord"),
        "v3_lbl_main_present_action":
            MessageLookupByLibrary.simpleMessage("Nästa möte"),
        "v3_lbl_main_privacy":
            MessageLookupByLibrary.simpleMessage("Integritetspolicy"),
        "v3_lbl_main_receive_app_action":
            MessageLookupByLibrary.simpleMessage("Mötesanslutning"),
        "v3_lbl_moderator_back":
            MessageLookupByLibrary.simpleMessage("Gå tillbaka"),
        "v3_lbl_moderator_disconnect":
            MessageLookupByLibrary.simpleMessage("Koppla ifrån"),
        "v3_lbl_present_idle_audio_driver_warning_close":
            MessageLookupByLibrary.simpleMessage(
                "Varning för stängning av ljuddrivrutin"),
        "v3_lbl_present_idle_audio_driver_warning_download":
            MessageLookupByLibrary.simpleMessage("Ladda ner ljuddrivrutin"),
        "v3_lbl_qr_close":
            MessageLookupByLibrary.simpleMessage("Stäng QR-kodskanner"),
        "v3_lbl_qr_code":
            MessageLookupByLibrary.simpleMessage("Öppna QR-kodskanner"),
        "v3_lbl_select_language":
            MessageLookupByLibrary.simpleMessage("Välj %s"),
        "v3_lbl_select_role_receive":
            MessageLookupByLibrary.simpleMessage("Ta emot skärmbild"),
        "v3_lbl_select_role_share":
            MessageLookupByLibrary.simpleMessage("Dela skärm"),
        "v3_lbl_select_screen_audio":
            MessageLookupByLibrary.simpleMessage("Dela datorljud"),
        "v3_lbl_select_screen_cancel":
            MessageLookupByLibrary.simpleMessage("Avbryt delning"),
        "v3_lbl_select_screen_close":
            MessageLookupByLibrary.simpleMessage("Stäng skärmmarkering"),
        "v3_lbl_select_screen_ios_back":
            MessageLookupByLibrary.simpleMessage("Gå tillbaka"),
        "v3_lbl_select_screen_ios_start_sharing":
            MessageLookupByLibrary.simpleMessage("Starta delning"),
        "v3_lbl_select_screen_share":
            MessageLookupByLibrary.simpleMessage("Dela skärm"),
        "v3_lbl_select_screen_source_name":
            MessageLookupByLibrary.simpleMessage("Skärmens källa: %s"),
        "v3_lbl_setting": MessageLookupByLibrary.simpleMessage("Inställningar"),
        "v3_lbl_setting_language_select":
            MessageLookupByLibrary.simpleMessage("Välj språk: %s"),
        "v3_lbl_setting_legal_policy":
            MessageLookupByLibrary.simpleMessage("Visa juridisk princip: %s"),
        "v3_lbl_setting_menu_back": MessageLookupByLibrary.simpleMessage(
            "Tillbaka till föregående meny"),
        "v3_lbl_setting_menu_close":
            MessageLookupByLibrary.simpleMessage("Stäng inställningsmenyn"),
        "v3_lbl_setting_privacy_policy": MessageLookupByLibrary.simpleMessage(
            "\nv3_lbl_setting_privacy_policy"),
        "v3_lbl_setting_select":
            MessageLookupByLibrary.simpleMessage("Välj %s"),
        "v3_lbl_setting_software_update_deny_action":
            MessageLookupByLibrary.simpleMessage("Senare"),
        "v3_lbl_setting_software_update_fail_close":
            MessageLookupByLibrary.simpleMessage(
                "Stäng dialogrutan för uppdateringsfel"),
        "v3_lbl_setting_software_update_fail_ok":
            MessageLookupByLibrary.simpleMessage("OK"),
        "v3_lbl_setting_software_update_no_available":
            MessageLookupByLibrary.simpleMessage(
                "Ingen uppdatering tillgänglig"),
        "v3_lbl_setting_software_update_no_available_action":
            MessageLookupByLibrary.simpleMessage("OK"),
        "v3_lbl_setting_software_update_now_action":
            MessageLookupByLibrary.simpleMessage("Uppdatera nu"),
        "v3_lbl_setting_software_update_positive_action":
            MessageLookupByLibrary.simpleMessage("Uppdatera"),
        "v3_lbl_setting_update_close": MessageLookupByLibrary.simpleMessage(
            "Stäng dialogrutan för uppdatering"),
        "v3_lbl_sharing_pause_off":
            MessageLookupByLibrary.simpleMessage("Paus AV"),
        "v3_lbl_sharing_pause_on":
            MessageLookupByLibrary.simpleMessage("Paus PÅ"),
        "v3_lbl_sharing_stop":
            MessageLookupByLibrary.simpleMessage("Stopp för delning"),
        "v3_lbl_streaming_expand_button": MessageLookupByLibrary.simpleMessage(
            "Expandera strömningskontroller"),
        "v3_lbl_streaming_minimize_button":
            MessageLookupByLibrary.simpleMessage(
                "Minimera strömningskontroller"),
        "v3_lbl_streaming_stop_button":
            MessageLookupByLibrary.simpleMessage("Sluta streama"),
        "v3_lbl_touch_back_off":
            MessageLookupByLibrary.simpleMessage("Inaktivera touchback"),
        "v3_lbl_touch_back_on":
            MessageLookupByLibrary.simpleMessage("Aktivera touchback"),
        "v3_main_accessibility":
            MessageLookupByLibrary.simpleMessage("Tillgänglighet"),
        "v3_main_authorize_wait": MessageLookupByLibrary.simpleMessage(
            "Vänta på att värden godkänner din begäran."),
        "v3_main_connect_network_error":
            MessageLookupByLibrary.simpleMessage("Fel i nätverksanslutning."),
        "v3_main_connect_rate_limited": MessageLookupByLibrary.simpleMessage(
            "AirSync-instansen är upptagen. Försök senare."),
        "v3_main_connect_unknown_error":
            MessageLookupByLibrary.simpleMessage("Okänt fel."),
        "v3_main_connection_mode_unsupported":
            MessageLookupByLibrary.simpleMessage(
                "AirSync ansluter inte till internet."),
        "v3_main_copy_rights": m1,
        "v3_main_display_code":
            MessageLookupByLibrary.simpleMessage("Skärmkod"),
        "v3_main_display_code_error":
            MessageLookupByLibrary.simpleMessage("Accepterar endast siffror."),
        "v3_main_display_code_invalid":
            MessageLookupByLibrary.simpleMessage("Ogiltig skärmkod"),
        "v3_main_download":
            MessageLookupByLibrary.simpleMessage("Ladda ner sändarapp"),
        "v3_main_download_action_download":
            MessageLookupByLibrary.simpleMessage("Ladda ner"),
        "v3_main_download_action_get":
            MessageLookupByLibrary.simpleMessage("Hämta"),
        "v3_main_download_app_dialog_desc": MessageLookupByLibrary.simpleMessage(
            "Skanna QR-koden med din iOS- eller Android-enhet för att ladda ner"),
        "v3_main_download_app_dialog_title":
            MessageLookupByLibrary.simpleMessage("Ladda ner sändarapp"),
        "v3_main_download_app_subtitle":
            MessageLookupByLibrary.simpleMessage("iOS och Android"),
        "v3_main_download_app_title":
            MessageLookupByLibrary.simpleMessage("AirSync App"),
        "v3_main_download_desc": MessageLookupByLibrary.simpleMessage(
            "Smidig skärmdelning med ett klick."),
        "v3_main_download_mac_pkg_label": MessageLookupByLibrary.simpleMessage(
            "För bästa användarupplevelse!"),
        "v3_main_download_mac_store":
            MessageLookupByLibrary.simpleMessage("App Store"),
        "v3_main_download_mac_store_label":
            MessageLookupByLibrary.simpleMessage("Eller installera via"),
        "v3_main_download_mac_subtitle":
            MessageLookupByLibrary.simpleMessage("macOS 10.15+"),
        "v3_main_download_mac_title":
            MessageLookupByLibrary.simpleMessage("Mac"),
        "v3_main_download_title":
            MessageLookupByLibrary.simpleMessage("Hämta din AirSync-sändarapp"),
        "v3_main_download_win_subtitle":
            MessageLookupByLibrary.simpleMessage("Win 10 (1709+)/ Win 11"),
        "v3_main_download_win_title":
            MessageLookupByLibrary.simpleMessage("Windows"),
        "v3_main_instance_not_found_or_offline":
            MessageLookupByLibrary.simpleMessage(
                "Skärmkod hittades inte eller instansen är offline."),
        "v3_main_moderator_action":
            MessageLookupByLibrary.simpleMessage("Dela"),
        "v3_main_moderator_app_subtitle": MessageLookupByLibrary.simpleMessage(
            "Ange ditt namn innan du delar din skärm"),
        "v3_main_moderator_app_title":
            MessageLookupByLibrary.simpleMessage("Dela"),
        "v3_main_moderator_disconnect":
            MessageLookupByLibrary.simpleMessage("Koppla bort"),
        "v3_main_moderator_input_hint":
            MessageLookupByLibrary.simpleMessage("Skriv ditt namn"),
        "v3_main_moderator_input_limit": MessageLookupByLibrary.simpleMessage(
            "Begränsa namnet till 20 tecken."),
        "v3_main_moderator_subtitle":
            MessageLookupByLibrary.simpleMessage("Ange din presentationstitel"),
        "v3_main_moderator_title":
            MessageLookupByLibrary.simpleMessage("Dela din skärm"),
        "v3_main_moderator_wait": MessageLookupByLibrary.simpleMessage(
            "Vänta på att moderatorn bjuder in dig att dela"),
        "v3_main_otp_error":
            MessageLookupByLibrary.simpleMessage("Accepterar endast siffror."),
        "v3_main_password": MessageLookupByLibrary.simpleMessage("Lösenord"),
        "v3_main_password_invalid":
            MessageLookupByLibrary.simpleMessage("Ogiltigt lösenord."),
        "v3_main_present_action": MessageLookupByLibrary.simpleMessage("Nästa"),
        "v3_main_present_subtitle": MessageLookupByLibrary.simpleMessage(
            "Följ stegen för att komma igång."),
        "v3_main_present_title":
            MessageLookupByLibrary.simpleMessage("Dela din skärm"),
        "v3_main_presenting_message": MessageLookupByLibrary.simpleMessage(
            "airsync.net delar din skärm."),
        "v3_main_privacy":
            MessageLookupByLibrary.simpleMessage("Integritetspolicy"),
        "v3_main_receive_app_action":
            MessageLookupByLibrary.simpleMessage("Anslut"),
        "v3_main_receive_app_receive_from":
            MessageLookupByLibrary.simpleMessage("Ta emot från %s"),
        "v3_main_receive_app_stop":
            MessageLookupByLibrary.simpleMessage("Stoppa"),
        "v3_main_receive_app_subtitle":
            MessageLookupByLibrary.simpleMessage("Dela skärm till min enhet"),
        "v3_main_receive_app_title":
            MessageLookupByLibrary.simpleMessage("Ta emot"),
        "v3_main_select_role_receive":
            MessageLookupByLibrary.simpleMessage("Ta emot"),
        "v3_main_select_role_share":
            MessageLookupByLibrary.simpleMessage("Dela"),
        "v3_main_select_role_title":
            MessageLookupByLibrary.simpleMessage("Välj presentationsläge"),
        "v3_main_terms":
            MessageLookupByLibrary.simpleMessage("Användarvillkor"),
        "v3_main_web_nonsupport": MessageLookupByLibrary.simpleMessage(
            "För närvarande stöds endast webbläsarna Chrome och Edge."),
        "v3_main_web_nonsupport_confirm":
            MessageLookupByLibrary.simpleMessage("Jag fattar!"),
        "v3_present_end_information": MessageLookupByLibrary.simpleMessage(
            "Skärmdelning har avslutats.\nTotal delningstid %s."),
        "v3_present_idle_download_virtual_audio_device":
            MessageLookupByLibrary.simpleMessage("Ladda ner"),
        "v3_present_moderator_exited":
            MessageLookupByLibrary.simpleMessage("Moderatorn är stängd"),
        "v3_present_moderator_exited_action":
            MessageLookupByLibrary.simpleMessage("OK"),
        "v3_present_moderator_exited_description":
            MessageLookupByLibrary.simpleMessage(
                "Moderatorn är stängd, vänligen anslut igen."),
        "v3_present_options_menu_he_subtitle":
            MessageLookupByLibrary.simpleMessage(
                "Använd enhetens grafikkort för att koda streamen."),
        "v3_present_options_menu_he_title":
            MessageLookupByLibrary.simpleMessage("Hårdvarukodning"),
        "v3_present_options_menu_hq_subtitle":
            MessageLookupByLibrary.simpleMessage(
                "Använd högre bitrate för att överföra streamen."),
        "v3_present_options_menu_hq_title":
            MessageLookupByLibrary.simpleMessage("Hög kvalitet"),
        "v3_present_screen_full":
            MessageLookupByLibrary.simpleMessage("Skärm full"),
        "v3_present_screen_full_action":
            MessageLookupByLibrary.simpleMessage("OK"),
        "v3_present_screen_full_description":
            MessageLookupByLibrary.simpleMessage(
                "Maximalt antal delade skärmar har uppnåtts."),
        "v3_present_select_screen_extension":
            MessageLookupByLibrary.simpleMessage("Skärmförlängning"),
        "v3_present_select_screen_extension_desc":
            MessageLookupByLibrary.simpleMessage("Utöka din arbetsyta"),
        "v3_present_select_screen_extension_desc2":
            MessageLookupByLibrary.simpleMessage(
                "Detta låter dig dra innehåll mellan din personliga enhet och IFP, vilket förbättrar realtidsinteraktion och kontroll."),
        "v3_present_select_screen_mac_audio_driver":
            MessageLookupByLibrary.simpleMessage(
                "Det går inte att dela ljud. Ladda ner och installera ljuddrivrutinen."),
        "v3_present_select_screen_share_audio":
            MessageLookupByLibrary.simpleMessage("Dela datorljud."),
        "v3_present_select_screen_subtitle":
            MessageLookupByLibrary.simpleMessage(
                "%s vill dela din skärm. Välj vad som ska delas."),
        "v3_present_session_full":
            MessageLookupByLibrary.simpleMessage("Session full"),
        "v3_present_session_full_action":
            MessageLookupByLibrary.simpleMessage("OK"),
        "v3_present_session_full_description":
            MessageLookupByLibrary.simpleMessage(
                "Kan inte ansluta. Sessionen har nått sitt maxantal."),
        "v3_present_touch_back_allow":
            MessageLookupByLibrary.simpleMessage("Tillåt touchback"),
        "v3_present_touch_back_dialog_allow":
            MessageLookupByLibrary.simpleMessage("Tillåt"),
        "v3_present_touch_back_dialog_description":
            MessageLookupByLibrary.simpleMessage(
                "När du aktiverar skärmdelning kommer AirSync tillfälligt att fånga och överföra ditt skärminnehåll till den valda skärmen (t.ex. IFP).För att aktivera Touchback kräver AirSync tillstånd från Tillgänglighetstjänsten för att tillåta fjärrstyrning från skärmen.AirSync samlar inte in dina personuppgifter och övervakar inte dina handlingar. Denna behörighet används endast för att aktivera pekkontrollfunktionen."),
        "v3_present_touch_back_dialog_not_now":
            MessageLookupByLibrary.simpleMessage("Inte nu"),
        "v3_present_touch_back_dialog_title":
            MessageLookupByLibrary.simpleMessage("Tillåt touchback"),
        "v3_receiver_remote_screen_busy_action":
            MessageLookupByLibrary.simpleMessage("OK"),
        "v3_receiver_remote_screen_busy_description":
            MessageLookupByLibrary.simpleMessage(
                "Skärmen sänder redan till andra skärmar. Försök igen senare."),
        "v3_receiver_remote_screen_busy_title":
            MessageLookupByLibrary.simpleMessage("Skärmen sänder"),
        "v3_scan_qr_reminder": MessageLookupByLibrary.simpleMessage(
            "Snabbanslut genom att skanna QR-koden"),
        "v3_select_screen_ios_countdown":
            MessageLookupByLibrary.simpleMessage("Återstående tid"),
        "v3_select_screen_ios_start_sharing":
            MessageLookupByLibrary.simpleMessage("Starta delning"),
        "v3_setting_accessibility":
            MessageLookupByLibrary.simpleMessage("Tillgänglighet"),
        "v3_setting_accessibility_size_large":
            MessageLookupByLibrary.simpleMessage("Stor"),
        "v3_setting_accessibility_size_normal":
            MessageLookupByLibrary.simpleMessage("Normal"),
        "v3_setting_accessibility_size_xlarge":
            MessageLookupByLibrary.simpleMessage("Extra Stor"),
        "v3_setting_accessibility_text_size":
            MessageLookupByLibrary.simpleMessage("Textstorlek"),
        "v3_setting_app_version": m2,
        "v3_setting_app_version_independent": m3,
        "v3_setting_check_update":
            MessageLookupByLibrary.simpleMessage("Sök efter uppdateringar"),
        "v3_setting_knowledge_base":
            MessageLookupByLibrary.simpleMessage("Kunskapsbas"),
        "v3_setting_language": MessageLookupByLibrary.simpleMessage("Språk"),
        "v3_setting_legal_policy":
            MessageLookupByLibrary.simpleMessage("Juridik och integritet"),
        "v3_setting_open_source_license":
            MessageLookupByLibrary.simpleMessage("Öppna källkodslicenser"),
        "v3_setting_privacy_policy":
            MessageLookupByLibrary.simpleMessage("Integritetspolicy"),
        "v3_setting_privacy_policy_description":
            MessageLookupByLibrary.simpleMessage(
                "ViewSonic är engagerad i att skydda din integritet och hanterar personuppgifter med största allvar. Integritetspolicyn nedan beskriver hur ViewSonic behandlar dina personuppgifter efter att de har samlats in via din användning av webbplatsen. ViewSonic upprätthåller sekretessen för din information genom säkerhetstekniker och följer policyer som förhindrar obehörig användning av dina personuppgifter. Genom att använda denna webbplats samtycker du till insamling och användning av din information.\n\nWebbplatser som du länkar till från ViewSonic.com kan ha sina egna integritetspolicyer som skiljer sig från ViewSonics. Vänligen granska dessa webbplatsers integritetspolicyer för detaljerad information om hur de kan använda information som samlas in när du besöker dem.\n\nKlicka på följande länkar för att lära dig mer om vår integritetspolicy."),
        "v3_setting_software_update":
            MessageLookupByLibrary.simpleMessage("Programuppdatering"),
        "v3_setting_software_update_deny_action":
            MessageLookupByLibrary.simpleMessage("Senare"),
        "v3_setting_software_update_description":
            MessageLookupByLibrary.simpleMessage(
                "En ny version är nu tillgänglig. Vill du uppdatera nu?"),
        "v3_setting_software_update_force_action":
            MessageLookupByLibrary.simpleMessage("Uppdatera nu"),
        "v3_setting_software_update_force_description":
            MessageLookupByLibrary.simpleMessage(
                "En ny version är nu tillgänglig."),
        "v3_setting_software_update_no_available":
            MessageLookupByLibrary.simpleMessage(
                "Ingen uppdatering tillgänglig"),
        "v3_setting_software_update_no_available_action":
            MessageLookupByLibrary.simpleMessage("OK"),
        "v3_setting_software_update_no_available_description":
            MessageLookupByLibrary.simpleMessage(
                "AirSync är redan uppdaterad till den senaste versionen."),
        "v3_setting_software_update_no_internet_description":
            MessageLookupByLibrary.simpleMessage(
                "Kontrollera din internetanslutning och försök igen."),
        "v3_setting_software_update_no_internet_tittle":
            MessageLookupByLibrary.simpleMessage("Ingen internetanslutning"),
        "v3_setting_software_update_positive_action":
            MessageLookupByLibrary.simpleMessage("Uppdatera"),
        "v3_setting_title":
            MessageLookupByLibrary.simpleMessage("Inställningar")
      };
}
