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

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "main_display_code":
            MessageLookupByLibrary.simpleMessage("Display Code"),
        "main_display_code_description": MessageLookupByLibrary.simpleMessage(
            "Bitte geben Sie den Anzeigecode ein"),
        "main_display_code_exceed": MessageLookupByLibrary.simpleMessage(
            "Maximale Teilnehmerzahl (6) erreicht."),
        "main_display_code_exceed_split_screen":
            MessageLookupByLibrary.simpleMessage(
                "Maximale Anzahl von Präsentatoren (4) erreicht."),
        "main_language": MessageLookupByLibrary.simpleMessage("Sprache"),
        "main_password": MessageLookupByLibrary.simpleMessage("Passwort"),
        "main_password_description":
            MessageLookupByLibrary.simpleMessage("4-stelliges Einmalpasswort"),
        "main_password_invalid":
            MessageLookupByLibrary.simpleMessage("Ungültiges Passwort."),
        "main_present": MessageLookupByLibrary.simpleMessage("PRÄSENT"),
        "main_setting": MessageLookupByLibrary.simpleMessage("Einstellungen"),
        "main_touch_back": MessageLookupByLibrary.simpleMessage("Touchback"),
        "moderator": MessageLookupByLibrary.simpleMessage("Moderator"),
        "moderator_exit": MessageLookupByLibrary.simpleMessage("BEENDEN"),
        "moderator_fill_out":
            MessageLookupByLibrary.simpleMessage("Pflichtfeld"),
        "moderator_name": MessageLookupByLibrary.simpleMessage("Name"),
        "moderator_wait": MessageLookupByLibrary.simpleMessage(
            "Bitte warten Sie, während der Moderator Präsentatoren auswählt…"),
        "present_select_screen_cancel":
            MessageLookupByLibrary.simpleMessage("Abbrechen"),
        "present_select_screen_description": MessageLookupByLibrary.simpleMessage(
            "Wählen Sie eine Ansicht, um sie mit dem empfangenden Bildschirm zu teilen."),
        "present_select_screen_entire":
            MessageLookupByLibrary.simpleMessage("Gesamter Bildschirm"),
        "present_select_screen_share":
            MessageLookupByLibrary.simpleMessage("Teilen"),
        "present_select_screen_window":
            MessageLookupByLibrary.simpleMessage("Fenster"),
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
        "settings_knowledge_base":
            MessageLookupByLibrary.simpleMessage("Wissensdatenbank")
      };
}
