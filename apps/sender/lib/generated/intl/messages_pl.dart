// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a pl locale. All the
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
  String get localeName => 'pl';

  static String m0(value) =>
      "Wybierz ekran do udostępnienia w ciągu ${value} sekund...";

  static String m1(year) =>
      "Prawa autorskie © ViewSonic Corporation ${year}. Wszelkie prawa zastrzeżone.";

  static String m2(year, version) => "AirSync ©${year}. wersja ${version}";

  static String m3(year, version) =>
      "AirSync ©${year}. wersja ${version} (niezależna)";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "device_list_enter_pin": MessageLookupByLibrary.simpleMessage(
      "Jednorazowe hasło",
    ),
    "device_list_enter_pin_ok": MessageLookupByLibrary.simpleMessage("OK"),
    "main_connect_network_error": MessageLookupByLibrary.simpleMessage(
      "Błąd sieci. Sprawdź łączność z siecią i spróbuj ponownie.",
    ),
    "main_connect_rate_limited": MessageLookupByLibrary.simpleMessage(
      "Instancja AirSync jest zajęta. Spróbuj ponownie później.",
    ),
    "main_connect_unknown_error": MessageLookupByLibrary.simpleMessage(
      "Nieznany błąd.",
    ),
    "main_connection_mode_unsupported": MessageLookupByLibrary.simpleMessage(
      "AirSync nie może połączyć się z internetem.",
    ),
    "main_device_list": MessageLookupByLibrary.simpleMessage(
      "Szybkie połączenie",
    ),
    "main_display_code": MessageLookupByLibrary.simpleMessage("Kod ekranu"),
    "main_display_code_description": MessageLookupByLibrary.simpleMessage(
      "Wprowadź kod ekranu",
    ),
    "main_display_code_error": MessageLookupByLibrary.simpleMessage(
      "Akceptuje tylko litery i cyfry.",
    ),
    "main_display_code_exceed": MessageLookupByLibrary.simpleMessage(
      "Osiągnięto maksymalną liczbę uczestników (6).",
    ),
    "main_display_code_exceed_split_screen":
        MessageLookupByLibrary.simpleMessage(
          "Osiągnięto maksymalną liczbę prezenterów (4).",
        ),
    "main_display_code_invalid": MessageLookupByLibrary.simpleMessage(
      "Nieprawidłowy kod ekranu",
    ),
    "main_feature_reconnect_fail_toast": MessageLookupByLibrary.simpleMessage(
      "Ponowne połączenie z siecią (sterowanie) nie powiodło się",
    ),
    "main_feature_reconnect_success_toast":
        MessageLookupByLibrary.simpleMessage(
          "Ponowne połączenie z siecią (sterowanie) powiodło się",
        ),
    "main_feature_reconnecting_toast": MessageLookupByLibrary.simpleMessage(
      "Sieć (sterowanie) ponownie łączy się",
    ),
    "main_instance_not_found_or_offline": MessageLookupByLibrary.simpleMessage(
      "Nie znaleziono kodu ekranu lub instancja jest w trybie offline.",
    ),
    "main_language": MessageLookupByLibrary.simpleMessage("Język"),
    "main_language_name": MessageLookupByLibrary.simpleMessage("Polski"),
    "main_notice_not_support_description": MessageLookupByLibrary.simpleMessage(
      "Udostępnianie za pomocą przeglądarki nie jest obsługiwane na urządzeniach mobilnych. Pobierz i użyj aplikacji nadawcy AirSync, aby uzyskać lepsze wrażenia.",
    ),
    "main_notice_positive_button": MessageLookupByLibrary.simpleMessage(
      "Pobierz aplikację nadawcy AirSync.",
    ),
    "main_notice_title": MessageLookupByLibrary.simpleMessage("Uwaga"),
    "main_otp_error": MessageLookupByLibrary.simpleMessage(
      "Akceptuje tylko cyfry.",
    ),
    "main_password": MessageLookupByLibrary.simpleMessage("Hasło"),
    "main_password_description": MessageLookupByLibrary.simpleMessage(
      "Wprowadź jednorazowe hasło",
    ),
    "main_password_invalid": MessageLookupByLibrary.simpleMessage(
      "Nieprawidłowe hasło.",
    ),
    "main_present": MessageLookupByLibrary.simpleMessage("Dalej"),
    "main_setting": MessageLookupByLibrary.simpleMessage("Ustawienia"),
    "main_touch_back": MessageLookupByLibrary.simpleMessage(
      "Sterowanie dotykiem",
    ),
    "main_update_deny_button": MessageLookupByLibrary.simpleMessage(
      "Nie teraz",
    ),
    "main_update_description_android": MessageLookupByLibrary.simpleMessage(
      "Kliknij „Aktualizuj”, aby zainstalować nową wersję.",
    ),
    "main_update_description_apple": MessageLookupByLibrary.simpleMessage(
      "Kliknij „Aktualizuj”, aby zainstalować nową wersję.",
    ),
    "main_update_description_windows": MessageLookupByLibrary.simpleMessage(
      "Kliknij „Aktualizuj”, aby zainstalować nową wersję.",
    ),
    "main_update_error_detail": MessageLookupByLibrary.simpleMessage("Opis: "),
    "main_update_error_title": MessageLookupByLibrary.simpleMessage(
      "Błąd aktualizacji wersji",
    ),
    "main_update_error_type": MessageLookupByLibrary.simpleMessage(
      "Przyczyna błędu: ",
    ),
    "main_update_positive_button": MessageLookupByLibrary.simpleMessage(
      "Aktualizuj",
    ),
    "main_update_title": MessageLookupByLibrary.simpleMessage(
      "Dostępna nowa wersja",
    ),
    "main_webrtc_reconnect_fail_toast": MessageLookupByLibrary.simpleMessage(
      "Ponowne połączenie z siecią (WebRTC) nie powiodło się",
    ),
    "main_webrtc_reconnect_success_toast": MessageLookupByLibrary.simpleMessage(
      "Ponowne połączenie z siecią (WebRTC) powiodło się",
    ),
    "main_webrtc_reconnecting_toast": MessageLookupByLibrary.simpleMessage(
      "Sieć (WebRTC) ponownie łączy się",
    ),
    "moderator": MessageLookupByLibrary.simpleMessage("Wprowadź swoje imię"),
    "moderator_back": MessageLookupByLibrary.simpleMessage("Wstecz"),
    "moderator_exit": MessageLookupByLibrary.simpleMessage("WYJŚCIE"),
    "moderator_fill_out": MessageLookupByLibrary.simpleMessage("Pole wymagane"),
    "moderator_name": MessageLookupByLibrary.simpleMessage("Imię"),
    "moderator_wait": MessageLookupByLibrary.simpleMessage(
      "Poczekaj, aż moderator wybierze prezenterów...",
    ),
    "present_role_cast_screen": MessageLookupByLibrary.simpleMessage(
      "Udostępnij ekran",
    ),
    "present_role_receive": MessageLookupByLibrary.simpleMessage(
      "Odbieraj ekran",
    ),
    "present_select_screen_cancel": MessageLookupByLibrary.simpleMessage(
      "Anuluj",
    ),
    "present_select_screen_description": MessageLookupByLibrary.simpleMessage(
      "Wybierz widok do udostępnienia na ekranie odbiorcy.",
    ),
    "present_select_screen_entire": MessageLookupByLibrary.simpleMessage(
      "Cały ekran",
    ),
    "present_select_screen_ios_restart": MessageLookupByLibrary.simpleMessage(
      "Rozpocznij transmisję",
    ),
    "present_select_screen_ios_restart_description":
        MessageLookupByLibrary.simpleMessage(
          "Kliknij „Rozpocznij transmisję”, aby wznowić udostępnianie przed upływem czasu, lub kliknij „Wstecz”, aby powrócić do ekranu początkowego.",
        ),
    "present_select_screen_share": MessageLookupByLibrary.simpleMessage(
      "Udostępnij",
    ),
    "present_select_screen_share_audio": MessageLookupByLibrary.simpleMessage(
      "Udostępnij dźwięk z ekranu",
    ),
    "present_select_screen_window": MessageLookupByLibrary.simpleMessage(
      "Okno",
    ),
    "present_state_high_quality_description":
        MessageLookupByLibrary.simpleMessage(
          "Włącz wysoką jakość przy dobrych warunkach sieciowych.",
        ),
    "present_state_high_quality_title": MessageLookupByLibrary.simpleMessage(
      "Wysoka jakość",
    ),
    "present_state_pause": MessageLookupByLibrary.simpleMessage("Wstrzymaj"),
    "present_state_resume": MessageLookupByLibrary.simpleMessage("Wznów"),
    "present_state_stop": MessageLookupByLibrary.simpleMessage(
      "Zakończ prezentację",
    ),
    "present_time": MessageLookupByLibrary.simpleMessage("Czas, który upłynął"),
    "present_time_unit_hour": MessageLookupByLibrary.simpleMessage("godz."),
    "present_time_unit_min": MessageLookupByLibrary.simpleMessage("min"),
    "present_time_unit_sec": MessageLookupByLibrary.simpleMessage("sek"),
    "present_wait": m0,
    "remote_screen_connect_error": MessageLookupByLibrary.simpleMessage(
      "Błąd połączenia z ekranem zdalnym",
    ),
    "remote_screen_wait": MessageLookupByLibrary.simpleMessage(
      "Udostępnianie jest w trakcie przetwarzania. Proszę czekać.",
    ),
    "settings_audio_configuration": MessageLookupByLibrary.simpleMessage(
      "Konfiguracja audio",
    ),
    "settings_knowledge_base": MessageLookupByLibrary.simpleMessage(
      "Baza wiedzy",
    ),
    "toast_enable_remote_screen": MessageLookupByLibrary.simpleMessage(
      "Włącz opcję \'Udostępnij ekran na urządzenie\' w AirSync.",
    ),
    "toast_install_audio_driver": MessageLookupByLibrary.simpleMessage(
      "Zainstaluj wirtualny sterownik audio.",
    ),
    "toast_maximum_moderated": MessageLookupByLibrary.simpleMessage(
      "Osiągnięto maksymalną liczbę moderowanych sesji.",
    ),
    "toast_maximum_remote_screen": MessageLookupByLibrary.simpleMessage(
      "Osiągnięto maksymalną liczbę udostępnionych ekranów.",
    ),
    "toast_maximum_split_screen": MessageLookupByLibrary.simpleMessage(
      "Osiągnięto maksymalną liczbę podzielonych ekranów.",
    ),
    "v3_device_list_button_device_list": MessageLookupByLibrary.simpleMessage(
      "Lista urządzeń",
    ),
    "v3_device_list_button_text": MessageLookupByLibrary.simpleMessage(
      "Szybkie połączenie przez",
    ),
    "v3_device_list_dialog_connect": MessageLookupByLibrary.simpleMessage(
      "Połącz",
    ),
    "v3_device_list_dialog_invalid_otp": MessageLookupByLibrary.simpleMessage(
      "Nieprawidłowe jednorazowe hasło",
    ),
    "v3_device_list_dialog_title": MessageLookupByLibrary.simpleMessage(
      "Wprowadź jednorazowe hasło",
    ),
    "v3_device_list_next": MessageLookupByLibrary.simpleMessage("Dalej"),
    "v3_eula_agree": MessageLookupByLibrary.simpleMessage("Zgadzam się"),
    "v3_eula_disagree": MessageLookupByLibrary.simpleMessage("Nie zgadzam się"),
    "v3_eula_title": MessageLookupByLibrary.simpleMessage(
      "Umowa licencyjna użytkownika końcowego",
    ),
    "v3_exit_action_cancel": MessageLookupByLibrary.simpleMessage("Anuluj"),
    "v3_exit_action_exit": MessageLookupByLibrary.simpleMessage("Zakończ"),
    "v3_exit_title": MessageLookupByLibrary.simpleMessage(
      "Czy na pewno chcesz zakończyć?",
    ),
    "v3_lbl_change_language": MessageLookupByLibrary.simpleMessage(
      "Zmień swój język",
    ),
    "v3_lbl_device_list_button_device_list":
        MessageLookupByLibrary.simpleMessage("Lista urządzeń"),
    "v3_lbl_device_list_close": MessageLookupByLibrary.simpleMessage(
      "Zamknij listę urządzeń",
    ),
    "v3_lbl_device_list_next": MessageLookupByLibrary.simpleMessage("Dalej"),
    "v3_lbl_download_independent_version": MessageLookupByLibrary.simpleMessage(
      "Pobierz niezależną wersję dla Mac",
    ),
    "v3_lbl_download_menu_minimal": MessageLookupByLibrary.simpleMessage(
      "menu minimalistyczne",
    ),
    "v3_lbl_exit_action_cancel": MessageLookupByLibrary.simpleMessage("Anuluj"),
    "v3_lbl_exit_action_exit": MessageLookupByLibrary.simpleMessage("Zakończ"),
    "v3_lbl_main_display_code": MessageLookupByLibrary.simpleMessage(
      "Wpisz kod ekranu",
    ),
    "v3_lbl_main_display_code_remove": MessageLookupByLibrary.simpleMessage(
      "Wyczyść kod ekranu",
    ),
    "v3_lbl_main_download": MessageLookupByLibrary.simpleMessage(
      "Pobierz aplikację nadawcy",
    ),
    "v3_lbl_main_download_mac_store": MessageLookupByLibrary.simpleMessage(
      "Pobierz wersję z Mac App Store",
    ),
    "v3_lbl_main_download_mobile": MessageLookupByLibrary.simpleMessage(
      "Pobierz wersję mobilną",
    ),
    "v3_lbl_main_download_windows": MessageLookupByLibrary.simpleMessage(
      "Pobierz wersję dla Windows",
    ),
    "v3_lbl_main_feedback": MessageLookupByLibrary.simpleMessage("Opinie"),
    "v3_lbl_main_knowledge_base": MessageLookupByLibrary.simpleMessage(
      "Baza wiedzy",
    ),
    "v3_lbl_main_moderator_action": MessageLookupByLibrary.simpleMessage(
      "Wyślij udostępnienie",
    ),
    "v3_lbl_main_moderator_input_hint": MessageLookupByLibrary.simpleMessage(
      "Wpisz swoje imię",
    ),
    "v3_lbl_main_password": MessageLookupByLibrary.simpleMessage("Wpisz hasło"),
    "v3_lbl_main_present_action": MessageLookupByLibrary.simpleMessage(
      "Wyślij dalej",
    ),
    "v3_lbl_main_privacy": MessageLookupByLibrary.simpleMessage(
      "Polityka prywatności",
    ),
    "v3_lbl_main_receive_app_action": MessageLookupByLibrary.simpleMessage(
      "Wyślij połączenie",
    ),
    "v3_lbl_moderator_back": MessageLookupByLibrary.simpleMessage("Wróć"),
    "v3_lbl_moderator_disconnect": MessageLookupByLibrary.simpleMessage(
      "Rozłącz",
    ),
    "v3_lbl_present_idle_audio_driver_warning_close":
        MessageLookupByLibrary.simpleMessage(
          "Zamknij ostrzeżenie o sterowniku audio",
        ),
    "v3_lbl_present_idle_audio_driver_warning_download":
        MessageLookupByLibrary.simpleMessage("Pobierz sterownik audio"),
    "v3_lbl_qr_close": MessageLookupByLibrary.simpleMessage(
      "Zamknij skaner kodu QR",
    ),
    "v3_lbl_qr_code": MessageLookupByLibrary.simpleMessage(
      "Otwórz skaner kodu QR",
    ),
    "v3_lbl_select_language": MessageLookupByLibrary.simpleMessage(
      "Wybierz %s",
    ),
    "v3_lbl_select_role_receive": MessageLookupByLibrary.simpleMessage(
      "Odbierz ekran",
    ),
    "v3_lbl_select_role_share": MessageLookupByLibrary.simpleMessage(
      "Udostępnij ekran",
    ),
    "v3_lbl_select_screen_audio": MessageLookupByLibrary.simpleMessage(
      "Udostępnij dźwięk z komputera",
    ),
    "v3_lbl_select_screen_cancel": MessageLookupByLibrary.simpleMessage(
      "Anuluj udostępnianie",
    ),
    "v3_lbl_select_screen_close": MessageLookupByLibrary.simpleMessage(
      "Zamknij wybór ekranu",
    ),
    "v3_lbl_select_screen_ios_back": MessageLookupByLibrary.simpleMessage(
      "Wróć",
    ),
    "v3_lbl_select_screen_ios_start_sharing":
        MessageLookupByLibrary.simpleMessage("Rozpocznij udostępnianie"),
    "v3_lbl_select_screen_share": MessageLookupByLibrary.simpleMessage(
      "Udostępnij ekran",
    ),
    "v3_lbl_select_screen_source_name": MessageLookupByLibrary.simpleMessage(
      "Źródło ekranu: %s",
    ),
    "v3_lbl_setting": MessageLookupByLibrary.simpleMessage("Ustawienia"),
    "v3_lbl_setting_language_select": MessageLookupByLibrary.simpleMessage(
      "Wybierz język: %s",
    ),
    "v3_lbl_setting_legal_policy": MessageLookupByLibrary.simpleMessage(
      "Wyświetl politykę prawną: %s",
    ),
    "v3_lbl_setting_menu_back": MessageLookupByLibrary.simpleMessage(
      "Wróć do poprzedniego menu",
    ),
    "v3_lbl_setting_menu_close": MessageLookupByLibrary.simpleMessage(
      "Zamknij menu ustawień",
    ),
    "v3_lbl_setting_privacy_policy": MessageLookupByLibrary.simpleMessage(
      "Polityka prywatności",
    ),
    "v3_lbl_setting_select": MessageLookupByLibrary.simpleMessage("Wybierz %s"),
    "v3_lbl_setting_software_update_deny_action":
        MessageLookupByLibrary.simpleMessage("Później"),
    "v3_lbl_setting_software_update_fail_close":
        MessageLookupByLibrary.simpleMessage(
          "Zamknij okno dialogowe błędu aktualizacji",
        ),
    "v3_lbl_setting_software_update_fail_ok":
        MessageLookupByLibrary.simpleMessage("OK"),
    "v3_lbl_setting_software_update_no_available":
        MessageLookupByLibrary.simpleMessage("Brak dostępnych aktualizacji"),
    "v3_lbl_setting_software_update_no_available_action":
        MessageLookupByLibrary.simpleMessage("OK"),
    "v3_lbl_setting_software_update_now_action":
        MessageLookupByLibrary.simpleMessage("Aktualizuj teraz"),
    "v3_lbl_setting_software_update_positive_action":
        MessageLookupByLibrary.simpleMessage("Aktualizuj"),
    "v3_lbl_setting_update_close": MessageLookupByLibrary.simpleMessage(
      "Zamknij okno dialogowe aktualizacji",
    ),
    "v3_lbl_sharing_pause_off": MessageLookupByLibrary.simpleMessage(
      "Wstrzymaj wyłączone",
    ),
    "v3_lbl_sharing_pause_on": MessageLookupByLibrary.simpleMessage(
      "Wstrzymaj włączone",
    ),
    "v3_lbl_sharing_stop": MessageLookupByLibrary.simpleMessage(
      "Zakończ udostępnianie",
    ),
    "v3_lbl_streaming_expand_button": MessageLookupByLibrary.simpleMessage(
      "Rozwiń kontrolki strumieniowania",
    ),
    "v3_lbl_streaming_minimize_button": MessageLookupByLibrary.simpleMessage(
      "Zwiń kontrolki strumieniowania",
    ),
    "v3_lbl_streaming_stop_button": MessageLookupByLibrary.simpleMessage(
      "Zatrzymaj strumieniowanie",
    ),
    "v3_lbl_touch_back_off": MessageLookupByLibrary.simpleMessage(
      "Wyłącz sterowanie dotykiem",
    ),
    "v3_lbl_touch_back_on": MessageLookupByLibrary.simpleMessage(
      "Włącz sterowanie dotykiem",
    ),
        "v3_lbl_v3_exit_close": MessageLookupByLibrary.simpleMessage("Zamknąć"),
        "v3_main_accessibility": MessageLookupByLibrary.simpleMessage(
      "Ułatwienia dostępu",
    ),
    "v3_main_authorize_wait": MessageLookupByLibrary.simpleMessage(
      "Proszę poczekać, aż host zatwierdzi Twoje żądanie.",
    ),
    "v3_main_connect_network_error": MessageLookupByLibrary.simpleMessage(
      "Błąd połączenia sieciowego.",
    ),
    "v3_main_connect_rate_limited": MessageLookupByLibrary.simpleMessage(
      "Instancja AirSync jest zajęta. Spróbuj ponownie później.",
    ),
    "v3_main_connect_unknown_error": MessageLookupByLibrary.simpleMessage(
      "Nieznany błąd.",
    ),
    "v3_main_connection_mode_unsupported": MessageLookupByLibrary.simpleMessage(
      "Twój odbiornik tymczasowo nie obsługuje udostępniania ekranu przez internet.",
    ),
    "v3_main_copy_rights": m1,
    "v3_main_display_code": MessageLookupByLibrary.simpleMessage("Kod ekranu"),
    "v3_main_display_code_error": MessageLookupByLibrary.simpleMessage(
      "Akceptuje tylko cyfry.",
    ),
    "v3_main_display_code_invalid": MessageLookupByLibrary.simpleMessage(
      "Nieprawidłowy kod ekranu",
    ),
    "v3_main_download": MessageLookupByLibrary.simpleMessage(
      "Pobierz aplikację nadawcy",
    ),
    "v3_main_download_action_download": MessageLookupByLibrary.simpleMessage(
      "Pobierz",
    ),
    "v3_main_download_action_get": MessageLookupByLibrary.simpleMessage(
      "Pobierz",
    ),
    "v3_main_download_app_dialog_desc": MessageLookupByLibrary.simpleMessage(
      "Zeskanuj kod QR za pomocą urządzenia z systemem iOS lub Android, aby pobrać aplikację",
    ),
    "v3_main_download_app_dialog_title": MessageLookupByLibrary.simpleMessage(
      "Pobierz aplikację nadawcy",
    ),
    "v3_main_download_app_subtitle": MessageLookupByLibrary.simpleMessage(
      "iOS i Android",
    ),
    "v3_main_download_app_title": MessageLookupByLibrary.simpleMessage(
      "Aplikacja AirSync",
    ),
    "v3_main_download_desc": MessageLookupByLibrary.simpleMessage(
      "Bezproblemowe udostępnianie ekranu za pomocą połączenia jednym kliknięciem.",
    ),
    "v3_main_download_mac_pkg_label": MessageLookupByLibrary.simpleMessage(
      "Dla najlepszego doświadczenia użytkownika!",
    ),
    "v3_main_download_mac_store": MessageLookupByLibrary.simpleMessage(
      "App Store",
    ),
    "v3_main_download_mac_store_label": MessageLookupByLibrary.simpleMessage(
      "Lub zainstaluj przez",
    ),
    "v3_main_download_mac_subtitle": MessageLookupByLibrary.simpleMessage(
      "macOS 10.15+",
    ),
    "v3_main_download_mac_title": MessageLookupByLibrary.simpleMessage("Mac"),
    "v3_main_download_title": MessageLookupByLibrary.simpleMessage(
      "Pobierz aplikację nadawcy AirSync",
    ),
    "v3_main_download_win_subtitle": MessageLookupByLibrary.simpleMessage(
      "Win 10 (1709+)/ Win 11",
    ),
    "v3_main_download_win_title": MessageLookupByLibrary.simpleMessage(
      "Windows",
    ),
    "v3_main_feedback": MessageLookupByLibrary.simpleMessage("Opinie"),
    "v3_main_instance_not_found_or_offline":
        MessageLookupByLibrary.simpleMessage(
          "Nie znaleziono kodu ekranu lub instancja jest w trybie offline.",
        ),
    "v3_main_knowledge_base": MessageLookupByLibrary.simpleMessage(
      "Baza wiedzy",
    ),
    "v3_main_moderator_action": MessageLookupByLibrary.simpleMessage(
      "Udostępnij",
    ),
    "v3_main_moderator_app_subtitle": MessageLookupByLibrary.simpleMessage(
      "Wpisz swoje imię przed udostępnieniem ekranu",
    ),
    "v3_main_moderator_app_title": MessageLookupByLibrary.simpleMessage(
      "Udostępnij",
    ),
    "v3_main_moderator_disconnect": MessageLookupByLibrary.simpleMessage(
      "Rozłącz",
    ),
    "v3_main_moderator_input_hint": MessageLookupByLibrary.simpleMessage(
      "Wpisz swoje imię",
    ),
    "v3_main_moderator_input_limit": MessageLookupByLibrary.simpleMessage(
      "Imię powinno mieć maksymalnie 20 znaków.",
    ),
    "v3_main_moderator_subtitle": MessageLookupByLibrary.simpleMessage(
      "Wpisz tytuł swojej prezentacji",
    ),
    "v3_main_moderator_title": MessageLookupByLibrary.simpleMessage(
      "Udostępnij swój ekran",
    ),
    "v3_main_moderator_wait": MessageLookupByLibrary.simpleMessage(
      "Czekaj, aż moderator zaprosi Cię do udostępnienia",
    ),
    "v3_main_otp_error": MessageLookupByLibrary.simpleMessage(
      "Akceptuje tylko cyfry.",
    ),
    "v3_main_password": MessageLookupByLibrary.simpleMessage("Hasło"),
    "v3_main_password_invalid": MessageLookupByLibrary.simpleMessage(
      "Nieprawidłowe hasło.",
    ),
    "v3_main_present_action": MessageLookupByLibrary.simpleMessage("Dalej"),
    "v3_main_present_or": MessageLookupByLibrary.simpleMessage("lub"),
    "v3_main_present_subtitle": MessageLookupByLibrary.simpleMessage(
      "Postępuj zgodnie z instrukcjami, aby rozpocząć.",
    ),
    "v3_main_present_title": MessageLookupByLibrary.simpleMessage(
      "Udostępnij swój ekran",
    ),
    "v3_main_presenting_message": MessageLookupByLibrary.simpleMessage(
      "airsync.net udostępnia Twój ekran.",
    ),
    "v3_main_privacy": MessageLookupByLibrary.simpleMessage(
      "Polityka prywatności",
    ),
    "v3_main_receive_app_action": MessageLookupByLibrary.simpleMessage(
      "Połącz",
    ),
    "v3_main_receive_app_receive_from": MessageLookupByLibrary.simpleMessage(
      "Odbieraj z %s",
    ),
    "v3_main_receive_app_stop": MessageLookupByLibrary.simpleMessage(
      "Zatrzymaj",
    ),
    "v3_main_receive_app_subtitle": MessageLookupByLibrary.simpleMessage(
      "Udostępnij ekran na moim urządzeniu",
    ),
    "v3_main_receive_app_title": MessageLookupByLibrary.simpleMessage(
      "Odbierz",
    ),
    "v3_main_select_role_receive": MessageLookupByLibrary.simpleMessage(
      "Odbierz",
    ),
    "v3_main_select_role_share": MessageLookupByLibrary.simpleMessage(
      "Udostępnij",
    ),
    "v3_main_select_role_title": MessageLookupByLibrary.simpleMessage(
      "Wybierz tryb prezentacji",
    ),
    "v3_main_terms": MessageLookupByLibrary.simpleMessage(
      "Warunki użytkowania",
    ),
    "v3_main_web_nonsupport": MessageLookupByLibrary.simpleMessage(
      "Obecnie obsługiwane są tylko przeglądarki Chrome i Edge.",
    ),
    "v3_main_web_nonsupport_confirm": MessageLookupByLibrary.simpleMessage(
      "Rozumiem!",
    ),
    "v3_present_end_information": MessageLookupByLibrary.simpleMessage(
      "Udostępnianie ekranu zostało zatrzymane.\nCałkowity czas udostępniania: %s.",
    ),
    "v3_present_idle_download_virtual_audio_device":
            MessageLookupByLibrary.simpleMessage("Zainstaluj"),
        "v3_present_joined_before_moderator_on":
        MessageLookupByLibrary.simpleMessage("Tryb moderatora jest włączony"),
    "v3_present_joined_before_moderator_on_action":
        MessageLookupByLibrary.simpleMessage("OK"),
    "v3_present_joined_before_moderator_on_description":
        MessageLookupByLibrary.simpleMessage(
          "Tryb moderatora jest włączony. Proszę połączyć się ponownie.",
        ),
    "v3_present_moderator_exited": MessageLookupByLibrary.simpleMessage(
      "Moderator zakończył sesję",
    ),
    "v3_present_moderator_exited_action": MessageLookupByLibrary.simpleMessage(
      "OK",
    ),
    "v3_present_moderator_exited_description":
        MessageLookupByLibrary.simpleMessage(
          "Moderator zakończył sesję. Połącz się ponownie.",
        ),
    "v3_present_options_menu_he_subtitle": MessageLookupByLibrary.simpleMessage(
      "Użyj karty graficznej urządzenia do kodowania strumienia.",
    ),
    "v3_present_options_menu_he_title": MessageLookupByLibrary.simpleMessage(
      "Kodowanie sprzętowe",
    ),
    "v3_present_options_menu_hq_subtitle": MessageLookupByLibrary.simpleMessage(
      "Użyj wyższej przepływności do przesyłania strumienia.",
    ),
    "v3_present_options_menu_hq_title": MessageLookupByLibrary.simpleMessage(
      "Wysoka jakość",
    ),
    "v3_present_screen_full": MessageLookupByLibrary.simpleMessage(
      "Ekran jest pełny",
    ),
    "v3_present_screen_full_action": MessageLookupByLibrary.simpleMessage("OK"),
    "v3_present_screen_full_description": MessageLookupByLibrary.simpleMessage(
      "Osiągnięto maksymalną liczbę podzielonych ekranów.",
    ),
    "v3_present_select_screen_extension": MessageLookupByLibrary.simpleMessage(
      "Rozszerzenie ekranu",
    ),
    "v3_present_select_screen_extension_desc":
        MessageLookupByLibrary.simpleMessage(
          "Rozszerz swoją przestrzeń roboczą",
        ),
    "v3_present_select_screen_extension_desc2":
        MessageLookupByLibrary.simpleMessage(
          "Przeciągaj zawartość między urządzeniem osobistym a IFP, co usprawni interakcję i kontrolę w czasie rzeczywistym.",
        ),
    "v3_present_select_screen_mac_audio_driver":
        MessageLookupByLibrary.simpleMessage(
          "Nie można udostępnić dźwięku. Zainstaluj sterownik audio.",
        ),
    "v3_present_select_screen_share_audio":
        MessageLookupByLibrary.simpleMessage("Udostępnij dźwięk z komputera."),
    "v3_present_select_screen_subtitle": MessageLookupByLibrary.simpleMessage(
      "%s chce udostępnić Twój ekran. Wybierz, co chcesz udostępnić.",
    ),
    "v3_present_session_full": MessageLookupByLibrary.simpleMessage(
      "Sesja jest pełna",
    ),
    "v3_present_session_full_action": MessageLookupByLibrary.simpleMessage(
      "OK",
    ),
    "v3_present_session_full_description": MessageLookupByLibrary.simpleMessage(
      "Nie można dołączyć. Sesja osiągnęła maksymalny limit.",
    ),
    "v3_present_touch_back_allow": MessageLookupByLibrary.simpleMessage(
      "Zezwalaj na sterowanie dotykiem",
    ),
    "v3_present_touch_back_dialog_allow": MessageLookupByLibrary.simpleMessage(
      "Zezwól",
    ),
    "v3_present_touch_back_dialog_description":
        MessageLookupByLibrary.simpleMessage(
          "Po włączeniu udostępniania ekranu, AirSync tymczasowo przechwyci i prześle zawartość Twojego ekranu na wybrany wyświetlacz (np. IFP). Aby włączyć sterowanie dotykiem, AirSync wymaga uprawnienia Usługi ułatwień dostępu, aby umożliwić zdalne sterowanie z wyświetlacza. AirSync nie zbiera Twoich danych osobowych ani nie monitoruje Twoich działań. To uprawnienie jest używane wyłącznie do włączenia funkcji sterowania dotykowego.",
        ),
    "v3_present_touch_back_dialog_not_now":
        MessageLookupByLibrary.simpleMessage("Nie teraz"),
    "v3_present_touch_back_dialog_title": MessageLookupByLibrary.simpleMessage(
      "Zezwalaj na sterowanie dotykiem",
    ),
    "v3_receiver_remote_screen_busy_action":
        MessageLookupByLibrary.simpleMessage("OK"),
    "v3_receiver_remote_screen_busy_description":
        MessageLookupByLibrary.simpleMessage(
          "Ekran jest transmitowany na inne ekrany. Spróbuj ponownie później.",
        ),
    "v3_receiver_remote_screen_busy_title":
        MessageLookupByLibrary.simpleMessage("Ekran jest transmitowany"),
    "v3_scan_qr_reminder": MessageLookupByLibrary.simpleMessage(
      "Szybkie połączenie przez skanowanie kodu QR",
    ),
    "v3_select_screen_ios_countdown": MessageLookupByLibrary.simpleMessage(
      "Pozostały czas",
    ),
    "v3_select_screen_ios_start_sharing": MessageLookupByLibrary.simpleMessage(
      "Rozpocznij udostępnianie",
    ),
    "v3_setting_accessibility": MessageLookupByLibrary.simpleMessage(
      "Ułatwienia dostępu",
    ),
    "v3_setting_accessibility_size_large": MessageLookupByLibrary.simpleMessage(
      "Duży",
    ),
    "v3_setting_accessibility_size_normal":
        MessageLookupByLibrary.simpleMessage("Normalny"),
    "v3_setting_accessibility_size_xlarge":
        MessageLookupByLibrary.simpleMessage("Bardzo duży"),
    "v3_setting_accessibility_text_size": MessageLookupByLibrary.simpleMessage(
      "Rozmiar tekstu",
    ),
    "v3_setting_app_version": m2,
    "v3_setting_app_version_independent": m3,
    "v3_setting_check_update": MessageLookupByLibrary.simpleMessage(
      "Sprawdź aktualizacje",
    ),
    "v3_setting_knowledge_base": MessageLookupByLibrary.simpleMessage(
      "Baza wiedzy",
    ),
    "v3_setting_language": MessageLookupByLibrary.simpleMessage("Język"),
    "v3_setting_legal_policy": MessageLookupByLibrary.simpleMessage(
      "Informacje prawne i polityka",
    ),
    "v3_setting_open_source_license": MessageLookupByLibrary.simpleMessage(
      "Licencje na oprogramowanie open source",
    ),
    "v3_setting_privacy_policy": MessageLookupByLibrary.simpleMessage(
      "Polityka prywatności",
    ),
    "v3_setting_privacy_policy_description": MessageLookupByLibrary.simpleMessage(
      "ViewSonic zobowiązuje się do ochrony Twojej prywatności i poważnie traktuje przetwarzanie danych osobowych. Poniższa Polityka prywatności szczegółowo opisuje, w jaki sposób ViewSonic będzie postępować z Twoimi danymi osobowymi, zebranymi za pośrednictwem Twojego korzystania z Witryny. ViewSonic zapewnia prywatność Twoich informacji, używając technologii bezpieczeństwa i przestrzegając zasad, które zapobiegają nieautoryzowanemu użyciu Twoich danych osobowych. Korzystając z tej Witryny, wyrażasz zgodę na zbieranie i wykorzystywanie Twoich informacji.\\n\\nWitryny, do których prowadzą linki z ViewSonic.com, mogą mieć własną politykę prywatności, która może różnić się od polityki ViewSonic. Zapoznaj się z politykami prywatności tych witryn, aby uzyskać szczegółowe informacje na temat sposobu, w jaki mogą one wykorzystywać informacje zebrane podczas Twojej wizyty.\n\nKliknij poniższe linki, aby dowiedzieć się więcej o naszej Polityce prywatności.",
    ),
    "v3_setting_software_update": MessageLookupByLibrary.simpleMessage(
      "Aktualizacja oprogramowania",
    ),
    "v3_setting_software_update_deny_action":
        MessageLookupByLibrary.simpleMessage("Później"),
    "v3_setting_software_update_description":
        MessageLookupByLibrary.simpleMessage(
          "Dostępna jest nowa wersja. Czy chcesz zaktualizować teraz?",
        ),
    "v3_setting_software_update_force_action":
        MessageLookupByLibrary.simpleMessage("Aktualizuj teraz"),
    "v3_setting_software_update_force_description":
        MessageLookupByLibrary.simpleMessage("Nowa wersja jest już dostępna."),
    "v3_setting_software_update_no_available":
        MessageLookupByLibrary.simpleMessage("Brak dostępnych aktualizacji"),
    "v3_setting_software_update_no_available_action":
        MessageLookupByLibrary.simpleMessage("OK"),
    "v3_setting_software_update_no_available_description":
        MessageLookupByLibrary.simpleMessage("AirSync jest już aktualny."),
    "v3_setting_software_update_no_internet_description":
        MessageLookupByLibrary.simpleMessage(
          "Sprawdź połączenie z internetem i spróbuj ponownie.",
        ),
    "v3_setting_software_update_no_internet_tittle":
        MessageLookupByLibrary.simpleMessage("Brak połączenia z internetem"),
    "v3_setting_software_update_positive_action":
        MessageLookupByLibrary.simpleMessage("Aktualizuj"),
    "v3_setting_title": MessageLookupByLibrary.simpleMessage("Ustawienia"),
  };
}
