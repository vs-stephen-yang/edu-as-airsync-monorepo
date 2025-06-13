// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ru locale. All the
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
  String get localeName => 'ru';

  static String m0(value) =>
      "Выберите экран для передачи через ${value} сек...";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "main_display_code":
            MessageLookupByLibrary.simpleMessage("Код дисплея"),
        "main_display_code_description": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста, введите отображаемый код"),
        "main_display_code_error": MessageLookupByLibrary.simpleMessage(
            "Принимайте только буквы и цифры."),
        "main_display_code_exceed": MessageLookupByLibrary.simpleMessage(
            "Достугнуто максимальное число участников (6)"),
        "main_display_code_exceed_split_screen":
            MessageLookupByLibrary.simpleMessage(
                "Достугнуто максимальное число презентующих (4)"),
        "main_language": MessageLookupByLibrary.simpleMessage("Язык"),
        "main_otp_error":
            MessageLookupByLibrary.simpleMessage("Принимайте только цифры."),
        "main_password": MessageLookupByLibrary.simpleMessage("Пароль"),
        "main_password_description": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста, введите одноразовый пароль"),
        "main_password_invalid":
            MessageLookupByLibrary.simpleMessage("Недействительный пароль"),
        "main_present": MessageLookupByLibrary.simpleMessage("Презентовать"),
        "main_setting": MessageLookupByLibrary.simpleMessage("Настройки"),
        "main_touch_back": MessageLookupByLibrary.simpleMessage("Тачбэк"),
        "moderator": MessageLookupByLibrary.simpleMessage("Модератор"),
        "moderator_exit": MessageLookupByLibrary.simpleMessage("Выйти"),
        "moderator_fill_out":
            MessageLookupByLibrary.simpleMessage("Обязательное поле"),
        "moderator_name": MessageLookupByLibrary.simpleMessage("Имя"),
        "moderator_wait": MessageLookupByLibrary.simpleMessage(
            "Дождитесь, когда модератор выберет презентующих..."),
        "present_select_screen_cancel":
            MessageLookupByLibrary.simpleMessage("Отмена"),
        "present_select_screen_description":
            MessageLookupByLibrary.simpleMessage(
                "Выберите вид для передача на принимающем экране."),
        "present_select_screen_entire":
            MessageLookupByLibrary.simpleMessage("Весь экран"),
        "present_select_screen_share":
            MessageLookupByLibrary.simpleMessage("Передать"),
        "present_select_screen_window":
            MessageLookupByLibrary.simpleMessage("Окно"),
        "present_state_pause": MessageLookupByLibrary.simpleMessage("Пауза"),
        "present_state_resume":
            MessageLookupByLibrary.simpleMessage("Возобновить"),
        "present_state_stop":
            MessageLookupByLibrary.simpleMessage("Остановить презентацию"),
        "present_time": MessageLookupByLibrary.simpleMessage("Время"),
        "present_time_unit_hour": MessageLookupByLibrary.simpleMessage("ч"),
        "present_time_unit_min": MessageLookupByLibrary.simpleMessage("мин"),
        "present_time_unit_sec": MessageLookupByLibrary.simpleMessage("сек"),
        "present_wait": m0,
        "settings_knowledge_base":
            MessageLookupByLibrary.simpleMessage("База знаний")
      };
}
