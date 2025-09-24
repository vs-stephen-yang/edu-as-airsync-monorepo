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

  static String m1(year) =>
      "Авторские права © ViewSonic Corporation ${year}. Все права защищены.";

  static String m2(year, version) => "AirSync ©${year}. версия ${version}";

  static String m3(year, version) =>
      "AirSync ©${year}. версия ${version} (Отд.)";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "device_list_enter_pin": MessageLookupByLibrary.simpleMessage(
      "Одноразовый пароль",
    ),
    "device_list_enter_pin_ok": MessageLookupByLibrary.simpleMessage("ОК"),
    "main_connect_network_error": MessageLookupByLibrary.simpleMessage(
      "Ошибка сети. Пожалуйста, проверьте подключение к сети и попробуйте снова.",
    ),
    "main_connect_rate_limited": MessageLookupByLibrary.simpleMessage(
      "Экземпляр AirSync занят. Пожалуйста, попробуйте позже.",
    ),
    "main_connect_unknown_error": MessageLookupByLibrary.simpleMessage(
      "Неизвестная ошибка.",
    ),
    "main_connection_mode_unsupported": MessageLookupByLibrary.simpleMessage(
      "AirSync не может подключиться к Интернету.",
    ),
    "main_device_list": MessageLookupByLibrary.simpleMessage(
      "Быстрое подключение",
    ),
    "main_display_code": MessageLookupByLibrary.simpleMessage("Код дисплея"),
    "main_display_code_description": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, введите отображаемый код",
    ),
    "main_display_code_error": MessageLookupByLibrary.simpleMessage(
      "Принимайте только буквы и цифры.",
    ),
    "main_display_code_exceed": MessageLookupByLibrary.simpleMessage(
      "Достугнуто максимальное число участников (6)",
    ),
    "main_display_code_exceed_split_screen":
        MessageLookupByLibrary.simpleMessage(
          "Достугнуто максимальное число презентующих (4)",
        ),
    "main_display_code_invalid": MessageLookupByLibrary.simpleMessage(
      "Неверный код дисплея",
    ),
    "main_feature_reconnect_fail_toast": MessageLookupByLibrary.simpleMessage(
      "Сбой переподключения к сети (управление)",
    ),
    "main_feature_reconnect_success_toast":
        MessageLookupByLibrary.simpleMessage(
          "Успешное переподключение к сети (управление)",
        ),
    "main_feature_reconnecting_toast": MessageLookupByLibrary.simpleMessage(
      "Переподключение к сети (управление)",
    ),
    "main_instance_not_found_or_offline": MessageLookupByLibrary.simpleMessage(
      "Код дисплея не найден или экземпляр не в сети.",
    ),
    "main_language": MessageLookupByLibrary.simpleMessage("Язык"),
    "main_language_name": MessageLookupByLibrary.simpleMessage("Русский"),
    "main_notice_not_support_description": MessageLookupByLibrary.simpleMessage(
      "Совместное использование экрана через браузер не поддерживается на мобильных устройствах. Пожалуйста, загрузите и используйте приложение AirSync для отправки для лучшего взаимодействия.",
    ),
    "main_notice_positive_button": MessageLookupByLibrary.simpleMessage(
      "Загрузить приложение AirSync для отправки.",
    ),
    "main_notice_title": MessageLookupByLibrary.simpleMessage("Уведомление"),
    "main_otp_error": MessageLookupByLibrary.simpleMessage(
      "Принимайте только цифры.",
    ),
    "main_password": MessageLookupByLibrary.simpleMessage("Пароль"),
    "main_password_description": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, введите одноразовый пароль",
    ),
    "main_password_invalid": MessageLookupByLibrary.simpleMessage(
      "Недействительный пароль",
    ),
    "main_present": MessageLookupByLibrary.simpleMessage("Презентовать"),
    "main_setting": MessageLookupByLibrary.simpleMessage("Настройки"),
    "main_touch_back": MessageLookupByLibrary.simpleMessage("Тачбэк"),
    "main_update_deny_button": MessageLookupByLibrary.simpleMessage(
      "Не сейчас",
    ),
    "main_update_description_android": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, нажмите «Обновить», чтобы установить новую версию.",
    ),
    "main_update_description_apple": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, нажмите «Обновить», чтобы установить новую версию.",
    ),
    "main_update_description_windows": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, нажмите «Обновить», чтобы установить новую версию.",
    ),
    "main_update_error_detail": MessageLookupByLibrary.simpleMessage(
      "Описание:",
    ),
    "main_update_error_title": MessageLookupByLibrary.simpleMessage(
      "Сбой обновления версии",
    ),
    "main_update_error_type": MessageLookupByLibrary.simpleMessage(
      "Причина сбоя:",
    ),
    "main_update_positive_button": MessageLookupByLibrary.simpleMessage(
      "Обновить",
    ),
    "main_update_title": MessageLookupByLibrary.simpleMessage(
      "Доступна новая версия",
    ),
    "main_webrtc_reconnect_fail_toast": MessageLookupByLibrary.simpleMessage(
      "Сбой переподключения к сети (WebRTC)",
    ),
    "main_webrtc_reconnect_success_toast": MessageLookupByLibrary.simpleMessage(
      "Успешное переподключение к сети (WebRTC)",
    ),
    "main_webrtc_reconnecting_toast": MessageLookupByLibrary.simpleMessage(
      "Переподключение к сети (WebRTC)",
    ),
    "moderator": MessageLookupByLibrary.simpleMessage("Модератор"),
    "moderator_back": MessageLookupByLibrary.simpleMessage("Назад"),
    "moderator_exit": MessageLookupByLibrary.simpleMessage("Выйти"),
    "moderator_fill_out": MessageLookupByLibrary.simpleMessage(
      "Обязательное поле",
    ),
    "moderator_name": MessageLookupByLibrary.simpleMessage("Имя"),
    "moderator_wait": MessageLookupByLibrary.simpleMessage(
      "Дождитесь, когда модератор выберет презентующих...",
    ),
    "present_role_cast_screen": MessageLookupByLibrary.simpleMessage(
      "Поделиться экраном",
    ),
    "present_role_receive": MessageLookupByLibrary.simpleMessage(
      "Получить экран",
    ),
    "present_select_screen_cancel": MessageLookupByLibrary.simpleMessage(
      "Отмена",
    ),
    "present_select_screen_description": MessageLookupByLibrary.simpleMessage(
      "Выберите вид для передача на принимающем экране.",
    ),
    "present_select_screen_entire": MessageLookupByLibrary.simpleMessage(
      "Весь экран",
    ),
    "present_select_screen_ios_restart": MessageLookupByLibrary.simpleMessage(
      "Начать трансляцию",
    ),
    "present_select_screen_ios_restart_description":
        MessageLookupByLibrary.simpleMessage(
          "Нажмите «Начать трансляцию», чтобы возобновить демонстрацию до истечения времени ожидания, или нажмите «Назад», чтобы вернуться к исходному экрану.",
        ),
    "present_select_screen_share": MessageLookupByLibrary.simpleMessage(
      "Передать",
    ),
    "present_select_screen_share_audio": MessageLookupByLibrary.simpleMessage(
      "Поделиться звуком экрана",
    ),
    "present_select_screen_window": MessageLookupByLibrary.simpleMessage(
      "Окно",
    ),
    "present_state_high_quality_description":
        MessageLookupByLibrary.simpleMessage(
          "Включите высокое качество при хороших сетевых условиях.",
        ),
    "present_state_high_quality_title": MessageLookupByLibrary.simpleMessage(
      "Высокое качество",
    ),
    "present_state_pause": MessageLookupByLibrary.simpleMessage("Пауза"),
    "present_state_resume": MessageLookupByLibrary.simpleMessage("Возобновить"),
    "present_state_stop": MessageLookupByLibrary.simpleMessage(
      "Остановить презентацию",
    ),
    "present_time": MessageLookupByLibrary.simpleMessage("Время"),
    "present_time_unit_hour": MessageLookupByLibrary.simpleMessage("ч"),
    "present_time_unit_min": MessageLookupByLibrary.simpleMessage("мин"),
    "present_time_unit_sec": MessageLookupByLibrary.simpleMessage("сек"),
    "present_wait": m0,
    "remote_screen_connect_error": MessageLookupByLibrary.simpleMessage(
      "Ошибка подключения к удаленному экрану",
    ),
    "remote_screen_wait": MessageLookupByLibrary.simpleMessage(
      "Идет обработка демонстрации. Пожалуйста, подождите.",
    ),
    "settings_audio_configuration": MessageLookupByLibrary.simpleMessage(
      "Настройка аудио",
    ),
    "settings_knowledge_base": MessageLookupByLibrary.simpleMessage(
      "База знаний",
    ),
    "toast_enable_remote_screen": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, включите демонстрацию экрана на устройстве в AirSync.",
    ),
    "toast_install_audio_driver": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, установите драйвер виртуального аудиоустройства.",
    ),
    "toast_maximum_moderated": MessageLookupByLibrary.simpleMessage(
      "Достигнуто максимальное количество модераторских сессий.",
    ),
    "toast_maximum_remote_screen": MessageLookupByLibrary.simpleMessage(
      "Достигнуто максимальное количество общих экранов.",
    ),
    "toast_maximum_split_screen": MessageLookupByLibrary.simpleMessage(
      "Достигнуто максимальное количество разделенных экранов.",
    ),
    "v3_device_list_button_device_list": MessageLookupByLibrary.simpleMessage(
      "Список устройств",
    ),
    "v3_device_list_button_text": MessageLookupByLibrary.simpleMessage(
      "Быстрое подключение через",
    ),
    "v3_device_list_dialog_connect": MessageLookupByLibrary.simpleMessage(
      "Подключиться",
    ),
    "v3_device_list_dialog_invalid_otp": MessageLookupByLibrary.simpleMessage(
      "Неверный одноразовый пароль",
    ),
    "v3_device_list_dialog_title": MessageLookupByLibrary.simpleMessage(
      "Введите одноразовый пароль",
    ),
    "v3_device_list_next": MessageLookupByLibrary.simpleMessage("Далее"),
    "v3_eula_agree": MessageLookupByLibrary.simpleMessage("Согласен"),
    "v3_eula_disagree": MessageLookupByLibrary.simpleMessage("Не согласен"),
    "v3_eula_title": MessageLookupByLibrary.simpleMessage(
      "Лицензионное соглашение с конечным пользователем",
    ),
    "v3_exit_action_cancel": MessageLookupByLibrary.simpleMessage("Отмена"),
    "v3_exit_action_exit": MessageLookupByLibrary.simpleMessage("Выход"),
    "v3_exit_title": MessageLookupByLibrary.simpleMessage(
      "Вы действительно хотите выйти?",
    ),
    "v3_lbl_change_language": MessageLookupByLibrary.simpleMessage(
      "Изменить ваш язык",
    ),
    "v3_lbl_device_list_button_device_list":
        MessageLookupByLibrary.simpleMessage("Список устройств"),
    "v3_lbl_device_list_close": MessageLookupByLibrary.simpleMessage(
      "Закрыть список устройств",
    ),
    "v3_lbl_device_list_next": MessageLookupByLibrary.simpleMessage("Далее"),
    "v3_lbl_download_independent_version": MessageLookupByLibrary.simpleMessage(
      "Получить независимую версию для Mac",
    ),
    "v3_lbl_download_menu_minimal": MessageLookupByLibrary.simpleMessage(
      "минимальное меню",
    ),
    "v3_lbl_exit_action_cancel": MessageLookupByLibrary.simpleMessage("Отмена"),
    "v3_lbl_exit_action_exit": MessageLookupByLibrary.simpleMessage("Выход"),
    "v3_lbl_main_display_code": MessageLookupByLibrary.simpleMessage(
      "Введите код дисплея",
    ),
    "v3_lbl_main_display_code_remove": MessageLookupByLibrary.simpleMessage(
      "Очистить код дисплея",
    ),
    "v3_lbl_main_download": MessageLookupByLibrary.simpleMessage(
      "Загрузить приложение для отправки",
    ),
    "v3_lbl_main_download_mac_store": MessageLookupByLibrary.simpleMessage(
      "Получить версию для Mac App Store",
    ),
    "v3_lbl_main_download_mobile": MessageLookupByLibrary.simpleMessage(
      "Получить версию для мобильных устройств",
    ),
    "v3_lbl_main_download_windows": MessageLookupByLibrary.simpleMessage(
      "Получить версию для Windows",
    ),
    "v3_lbl_main_feedback": MessageLookupByLibrary.simpleMessage(
      "Обратная связь",
    ),
    "v3_lbl_main_knowledge_base": MessageLookupByLibrary.simpleMessage(
      "База знаний",
    ),
    "v3_lbl_main_moderator_action": MessageLookupByLibrary.simpleMessage(
      "Отправить Поделиться",
    ),
    "v3_lbl_main_moderator_input_hint": MessageLookupByLibrary.simpleMessage(
      "Введите свое имя",
    ),
    "v3_lbl_main_password": MessageLookupByLibrary.simpleMessage(
      "Введите пароль",
    ),
    "v3_lbl_main_present_action": MessageLookupByLibrary.simpleMessage(
      "Отправить Далее",
    ),
    "v3_lbl_main_privacy": MessageLookupByLibrary.simpleMessage(
      "Политика конфиденциальности",
    ),
    "v3_lbl_main_receive_app_action": MessageLookupByLibrary.simpleMessage(
      "Отправить Подключиться",
    ),
    "v3_lbl_moderator_back": MessageLookupByLibrary.simpleMessage("Назад"),
    "v3_lbl_moderator_disconnect": MessageLookupByLibrary.simpleMessage(
      "Отключиться",
    ),
    "v3_lbl_present_idle_audio_driver_warning_close":
        MessageLookupByLibrary.simpleMessage(
          "Закрыть предупреждение об аудиодрайвере",
        ),
    "v3_lbl_present_idle_audio_driver_warning_download":
        MessageLookupByLibrary.simpleMessage("Загрузить аудиодрайвер"),
    "v3_lbl_qr_close": MessageLookupByLibrary.simpleMessage(
      "Закрыть сканер QR-кодов",
    ),
    "v3_lbl_qr_code": MessageLookupByLibrary.simpleMessage(
      "Открыть сканер QR-кодов",
    ),
    "v3_lbl_select_language": MessageLookupByLibrary.simpleMessage(
      "Выберите %s",
    ),
    "v3_lbl_select_role_receive": MessageLookupByLibrary.simpleMessage(
      "Получить экран",
    ),
    "v3_lbl_select_role_share": MessageLookupByLibrary.simpleMessage(
      "Поделиться экраном",
    ),
    "v3_lbl_select_screen_audio": MessageLookupByLibrary.simpleMessage(
      "Поделиться звуком компьютера",
    ),
    "v3_lbl_select_screen_cancel": MessageLookupByLibrary.simpleMessage(
      "Отменить демонстрацию",
    ),
    "v3_lbl_select_screen_close": MessageLookupByLibrary.simpleMessage(
      "Закрыть выбор экрана",
    ),
    "v3_lbl_select_screen_ios_back": MessageLookupByLibrary.simpleMessage(
      "Назад",
    ),
    "v3_lbl_select_screen_ios_start_sharing":
        MessageLookupByLibrary.simpleMessage("Начать демонстрацию"),
    "v3_lbl_select_screen_share": MessageLookupByLibrary.simpleMessage(
      "Поделиться экраном",
    ),
    "v3_lbl_select_screen_source_name": MessageLookupByLibrary.simpleMessage(
      "Источник экрана: %s",
    ),
    "v3_lbl_setting": MessageLookupByLibrary.simpleMessage("Настройки"),
    "v3_lbl_setting_language_select": MessageLookupByLibrary.simpleMessage(
      "Выбрать язык: %s",
    ),
    "v3_lbl_setting_legal_policy": MessageLookupByLibrary.simpleMessage(
      "Просмотреть юридическую политику: %s",
    ),
    "v3_lbl_setting_menu_back": MessageLookupByLibrary.simpleMessage(
      "Назад к предыдущему меню",
    ),
    "v3_lbl_setting_menu_close": MessageLookupByLibrary.simpleMessage(
      "Закрыть меню настроек",
    ),
    "v3_lbl_setting_privacy_policy": MessageLookupByLibrary.simpleMessage(
      "Политика конфиденциальности",
    ),
    "v3_lbl_setting_select": MessageLookupByLibrary.simpleMessage("Выбрать %s"),
    "v3_lbl_setting_software_update_deny_action":
        MessageLookupByLibrary.simpleMessage("Позже"),
    "v3_lbl_setting_software_update_fail_close":
        MessageLookupByLibrary.simpleMessage(
          "Закрыть диалоговое окно ошибки обновления",
        ),
    "v3_lbl_setting_software_update_fail_ok":
        MessageLookupByLibrary.simpleMessage("ОК"),
    "v3_lbl_setting_software_update_no_available":
        MessageLookupByLibrary.simpleMessage("Нет доступных обновлений"),
    "v3_lbl_setting_software_update_no_available_action":
        MessageLookupByLibrary.simpleMessage("ОК"),
    "v3_lbl_setting_software_update_now_action":
        MessageLookupByLibrary.simpleMessage("Обновить сейчас"),
    "v3_lbl_setting_software_update_positive_action":
        MessageLookupByLibrary.simpleMessage("Обновить"),
    "v3_lbl_setting_update_close": MessageLookupByLibrary.simpleMessage(
      "Закрыть диалоговое окно обновления",
    ),
    "v3_lbl_sharing_pause_off": MessageLookupByLibrary.simpleMessage(
      "Пауза выключена",
    ),
    "v3_lbl_sharing_pause_on": MessageLookupByLibrary.simpleMessage(
      "Пауза включена",
    ),
    "v3_lbl_sharing_stop": MessageLookupByLibrary.simpleMessage(
      "Остановить демонстрацию",
    ),
    "v3_lbl_streaming_expand_button": MessageLookupByLibrary.simpleMessage(
      "Развернуть элементы управления потоковой передачей",
    ),
    "v3_lbl_streaming_minimize_button": MessageLookupByLibrary.simpleMessage(
      "Свернуть элементы управления потоковой передачей",
    ),
    "v3_lbl_streaming_stop_button": MessageLookupByLibrary.simpleMessage(
      "Остановить потоковую передачу",
    ),
    "v3_lbl_touch_back_off": MessageLookupByLibrary.simpleMessage(
      "Отключить обратное касание",
    ),
    "v3_lbl_touch_back_on": MessageLookupByLibrary.simpleMessage(
      "Включить обратное касание",
    ),
    "v3_main_accessibility": MessageLookupByLibrary.simpleMessage(
      "Доступность",
    ),
    "v3_main_authorize_wait": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, подождите, пока хост одобрит ваш запрос.",
    ),
    "v3_main_connect_network_error": MessageLookupByLibrary.simpleMessage(
      "Ошибка подключения к сети.",
    ),
    "v3_main_connect_rate_limited": MessageLookupByLibrary.simpleMessage(
      "Экземпляр AirSync занят. Пожалуйста, попробуйте позже.",
    ),
    "v3_main_connect_unknown_error": MessageLookupByLibrary.simpleMessage(
      "Неизвестная ошибка.",
    ),
    "v3_main_connection_mode_unsupported": MessageLookupByLibrary.simpleMessage(
      "Ваш приемник временно не поддерживает демонстрацию экрана через Интернет.",
    ),
    "v3_main_copy_rights": m1,
    "v3_main_display_code": MessageLookupByLibrary.simpleMessage("Код дисплея"),
    "v3_main_display_code_error": MessageLookupByLibrary.simpleMessage(
      "Принимаются только цифры.",
    ),
    "v3_main_display_code_invalid": MessageLookupByLibrary.simpleMessage(
      "Неверный код дисплея",
    ),
    "v3_main_download": MessageLookupByLibrary.simpleMessage(
      "Загрузить приложение для отправки",
    ),
    "v3_main_download_action_download": MessageLookupByLibrary.simpleMessage(
      "Загрузить",
    ),
    "v3_main_download_action_get": MessageLookupByLibrary.simpleMessage(
      "Получить",
    ),
    "v3_main_download_app_dialog_desc": MessageLookupByLibrary.simpleMessage(
      "Отсканируйте QR-код с помощью вашего устройства iOS или Android, чтобы загрузить",
    ),
    "v3_main_download_app_dialog_title": MessageLookupByLibrary.simpleMessage(
      "Загрузить приложение для отправки",
    ),
    "v3_main_download_app_subtitle": MessageLookupByLibrary.simpleMessage(
      "iOS и Android",
    ),
    "v3_main_download_app_title": MessageLookupByLibrary.simpleMessage(
      "Приложение AirSync",
    ),
    "v3_main_download_desc": MessageLookupByLibrary.simpleMessage(
      "Простая демонстрация экрана с подключением в один клик.",
    ),
    "v3_main_download_mac_pkg_label": MessageLookupByLibrary.simpleMessage(
      "Для лучшего пользовательского опыта!",
    ),
    "v3_main_download_mac_store": MessageLookupByLibrary.simpleMessage(
      "App Store",
    ),
    "v3_main_download_mac_store_label": MessageLookupByLibrary.simpleMessage(
      "Или установить через",
    ),
    "v3_main_download_mac_subtitle": MessageLookupByLibrary.simpleMessage(
      "macOS 10.15+",
    ),
    "v3_main_download_mac_title": MessageLookupByLibrary.simpleMessage("Mac"),
    "v3_main_download_title": MessageLookupByLibrary.simpleMessage(
      "Получите приложение AirSync для отправки",
    ),
    "v3_main_download_win_subtitle": MessageLookupByLibrary.simpleMessage(
      "Win 10 (1709+)/ Win 11",
    ),
    "v3_main_download_win_title": MessageLookupByLibrary.simpleMessage(
      "Windows",
    ),
    "v3_main_feedback": MessageLookupByLibrary.simpleMessage("Обратная связь"),
    "v3_main_instance_not_found_or_offline":
        MessageLookupByLibrary.simpleMessage(
          "Код дисплея не найден или экземпляр не в сети.",
        ),
    "v3_main_knowledge_base": MessageLookupByLibrary.simpleMessage(
      "База знаний",
    ),
    "v3_main_moderator_action": MessageLookupByLibrary.simpleMessage(
      "Поделиться",
    ),
    "v3_main_moderator_app_subtitle": MessageLookupByLibrary.simpleMessage(
      "Введите свое имя перед демонстрацией экрана",
    ),
    "v3_main_moderator_app_title": MessageLookupByLibrary.simpleMessage(
      "Поделиться",
    ),
    "v3_main_moderator_disconnect": MessageLookupByLibrary.simpleMessage(
      "Отключиться",
    ),
    "v3_main_moderator_input_hint": MessageLookupByLibrary.simpleMessage(
      "Введите свое имя",
    ),
    "v3_main_moderator_input_limit": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, ограничьте имя до 20 символов.",
    ),
    "v3_main_moderator_subtitle": MessageLookupByLibrary.simpleMessage(
      "Введите заголовок презентации",
    ),
    "v3_main_moderator_title": MessageLookupByLibrary.simpleMessage(
      "Делитесь своим экраном",
    ),
    "v3_main_moderator_wait": MessageLookupByLibrary.simpleMessage(
      "Подождите, пока модератор пригласит вас для демонстрации",
    ),
    "v3_main_otp_error": MessageLookupByLibrary.simpleMessage(
      "Принимаются только цифры.",
    ),
    "v3_main_password": MessageLookupByLibrary.simpleMessage("Пароль"),
    "v3_main_password_invalid": MessageLookupByLibrary.simpleMessage(
      "Неверный пароль.",
    ),
    "v3_main_present_action": MessageLookupByLibrary.simpleMessage("Далее"),
    "v3_main_present_or": MessageLookupByLibrary.simpleMessage("или"),
    "v3_main_present_subtitle": MessageLookupByLibrary.simpleMessage(
      "Следуйте инструкциям, чтобы начать.",
    ),
    "v3_main_present_title": MessageLookupByLibrary.simpleMessage(
      "Делитесь своим экраном",
    ),
    "v3_main_presenting_message": MessageLookupByLibrary.simpleMessage(
      "airsync.net демонстрирует ваш экран.",
    ),
    "v3_main_privacy": MessageLookupByLibrary.simpleMessage(
      "Политика конфиденциальности",
    ),
    "v3_main_receive_app_action": MessageLookupByLibrary.simpleMessage(
      "Подключиться",
    ),
    "v3_main_receive_app_receive_from": MessageLookupByLibrary.simpleMessage(
      "Получить от %s",
    ),
    "v3_main_receive_app_stop": MessageLookupByLibrary.simpleMessage(
      "Остановить",
    ),
    "v3_main_receive_app_subtitle": MessageLookupByLibrary.simpleMessage(
      "Демонстрация экрана на мое устройство",
    ),
    "v3_main_receive_app_title": MessageLookupByLibrary.simpleMessage(
      "Получить",
    ),
    "v3_main_select_role_receive": MessageLookupByLibrary.simpleMessage(
      "Получить",
    ),
    "v3_main_select_role_share": MessageLookupByLibrary.simpleMessage(
      "Поделиться",
    ),
    "v3_main_select_role_title": MessageLookupByLibrary.simpleMessage(
      "Выберите режим презентации",
    ),
    "v3_main_terms": MessageLookupByLibrary.simpleMessage(
      "Условия использования",
    ),
    "v3_main_web_nonsupport": MessageLookupByLibrary.simpleMessage(
      "В настоящее время поддерживаются только браузеры Chrome и Edge.",
    ),
    "v3_main_web_nonsupport_confirm": MessageLookupByLibrary.simpleMessage(
      "Понял!",
    ),
    "v3_present_end_information": MessageLookupByLibrary.simpleMessage(
      "Демонстрация экрана остановлена.\nОбщее время демонстрации %s.",
    ),
    "v3_present_idle_download_virtual_audio_device":
        MessageLookupByLibrary.simpleMessage("Загрузить"),
        "v3_present_joined_before_moderator_on":
            MessageLookupByLibrary.simpleMessage("Режим модератора включён"),
        "v3_present_joined_before_moderator_on_action":
            MessageLookupByLibrary.simpleMessage("OK"),
        "v3_present_joined_before_moderator_on_description":
            MessageLookupByLibrary.simpleMessage(
          "Режим модератора включён. Пожалуйста, переподключитесь.",
        ),
        "v3_present_moderator_exited": MessageLookupByLibrary.simpleMessage(
      "Модератор закрыл сессию",
    ),
    "v3_present_moderator_exited_action": MessageLookupByLibrary.simpleMessage(
      "ОК",
    ),
    "v3_present_moderator_exited_description":
        MessageLookupByLibrary.simpleMessage(
          "Модератор закрыл сессию. Пожалуйста, переподключитесь.",
        ),
    "v3_present_options_menu_he_subtitle": MessageLookupByLibrary.simpleMessage(
      "Используйте видеокарту устройства для кодирования потока.",
    ),
    "v3_present_options_menu_he_title": MessageLookupByLibrary.simpleMessage(
      "Аппаратное кодирование",
    ),
    "v3_present_options_menu_hq_subtitle": MessageLookupByLibrary.simpleMessage(
      "Используйте более высокий битрейт для передачи потока.",
    ),
    "v3_present_options_menu_hq_title": MessageLookupByLibrary.simpleMessage(
      "Высокое качество",
    ),
    "v3_present_screen_full": MessageLookupByLibrary.simpleMessage(
      "Экран заполнен",
    ),
    "v3_present_screen_full_action": MessageLookupByLibrary.simpleMessage("ОК"),
    "v3_present_screen_full_description": MessageLookupByLibrary.simpleMessage(
      "Достигнуто максимальное количество разделенных экранов.",
    ),
    "v3_present_select_screen_extension": MessageLookupByLibrary.simpleMessage(
      "Расширение экрана",
    ),
    "v3_present_select_screen_extension_desc":
        MessageLookupByLibrary.simpleMessage(
          "Расширьте свое рабочее пространство",
        ),
    "v3_present_select_screen_extension_desc2":
        MessageLookupByLibrary.simpleMessage(
          "Перетаскивайте контент между вашим личным устройством и IFP, улучшая взаимодействие и контроль в реальном времени.",
        ),
    "v3_present_select_screen_mac_audio_driver":
        MessageLookupByLibrary.simpleMessage(
          "Не удается поделиться аудио. Пожалуйста, загрузите и установите аудиодрайвер.",
        ),
    "v3_present_select_screen_share_audio":
        MessageLookupByLibrary.simpleMessage("Поделиться звуком компьютера."),
    "v3_present_select_screen_subtitle": MessageLookupByLibrary.simpleMessage(
      "%s хочет продемонстрировать ваш экран. Выберите, чем поделиться.",
    ),
    "v3_present_session_full": MessageLookupByLibrary.simpleMessage(
      "Сессия заполнена",
    ),
    "v3_present_session_full_action": MessageLookupByLibrary.simpleMessage(
      "ОК",
    ),
    "v3_present_session_full_description": MessageLookupByLibrary.simpleMessage(
      "Невозможно присоединиться. Сессия достигла максимального лимита.",
    ),
    "v3_present_touch_back_allow": MessageLookupByLibrary.simpleMessage(
      "Разрешить обратное касание",
    ),
    "v3_present_touch_back_dialog_allow": MessageLookupByLibrary.simpleMessage(
      "Разрешить",
    ),
    "v3_present_touch_back_dialog_description":
        MessageLookupByLibrary.simpleMessage(
          "Когда вы включаете демонстрацию экрана, AirSync временно захватывает и передает содержимое вашего экрана на выбранный дисплей (например, IFP). Чтобы включить обратное касание, AirSync требует разрешения службы доступности, чтобы разрешить удаленное управление с дисплея. AirSync не собирает ваши личные данные и не отслеживает ваши действия. Это разрешение используется только для включения функции сенсорного управления.",
        ),
    "v3_present_touch_back_dialog_not_now":
        MessageLookupByLibrary.simpleMessage("Не сейчас"),
    "v3_present_touch_back_dialog_title": MessageLookupByLibrary.simpleMessage(
      "Разрешить обратное касание",
    ),
    "v3_receiver_remote_screen_busy_action":
        MessageLookupByLibrary.simpleMessage("ОК"),
    "v3_receiver_remote_screen_busy_description":
        MessageLookupByLibrary.simpleMessage(
          "Экран транслируется на другие экраны. Пожалуйста, попробуйте позже.",
        ),
    "v3_receiver_remote_screen_busy_title":
        MessageLookupByLibrary.simpleMessage("Экран транслируется"),
    "v3_scan_qr_reminder": MessageLookupByLibrary.simpleMessage(
      "Быстрое подключение путем сканирования QR-кода",
    ),
    "v3_select_screen_ios_countdown": MessageLookupByLibrary.simpleMessage(
      "Оставшееся время",
    ),
    "v3_select_screen_ios_start_sharing": MessageLookupByLibrary.simpleMessage(
      "Начать демонстрацию",
    ),
    "v3_setting_accessibility": MessageLookupByLibrary.simpleMessage(
      "Доступность",
    ),
    "v3_setting_accessibility_size_large": MessageLookupByLibrary.simpleMessage(
      "Крупный",
    ),
    "v3_setting_accessibility_size_normal":
        MessageLookupByLibrary.simpleMessage("Нормальный"),
    "v3_setting_accessibility_size_xlarge":
        MessageLookupByLibrary.simpleMessage("Очень крупный"),
    "v3_setting_accessibility_text_size": MessageLookupByLibrary.simpleMessage(
      "Размер текста",
    ),
    "v3_setting_app_version": m2,
    "v3_setting_app_version_independent": m3,
    "v3_setting_check_update": MessageLookupByLibrary.simpleMessage(
      "Проверить наличие обновлений",
    ),
    "v3_setting_knowledge_base": MessageLookupByLibrary.simpleMessage(
      "База знаний",
    ),
    "v3_setting_language": MessageLookupByLibrary.simpleMessage("Язык"),
    "v3_setting_legal_policy": MessageLookupByLibrary.simpleMessage(
      "Юридическая информация и конфиденциальность",
    ),
    "v3_setting_open_source_license": MessageLookupByLibrary.simpleMessage(
      "Лицензии с открытым исходным кодом",
    ),
    "v3_setting_privacy_policy": MessageLookupByLibrary.simpleMessage(
      "Политика конфиденциальности",
    ),
    "v3_setting_privacy_policy_description": MessageLookupByLibrary.simpleMessage(
      "ViewSonic стремится защитить вашу конфиденциальность и серьезно относится к обработке персональных данных. Политика конфиденциальности ниже подробно описывает, как ViewSonic будет обрабатывать ваши персональные данные после того, как они будут собраны ViewSonic в результате использования вами Веб-сайта. ViewSonic обеспечивает конфиденциальность вашей информации с помощью технологий безопасности и придерживается политик, которые предотвращают несанкционированное использование ваших личных данных. Используя этот Веб-сайт, вы соглашаетесь на сбор и использование вашей информации.\\n\\nВеб-сайты, на которые вы переходите с ViewSonic.com, могут иметь собственную политику конфиденциальности, которая может отличаться от политики ViewSonic. Пожалуйста, ознакомьтесь с политикой конфиденциальности этих веб-сайтов для получения подробной информации о том, как они могут использовать информацию, собранную во время вашего посещения.\n\nПожалуйста, нажмите на следующие ссылки, чтобы узнать больше о нашей Политике конфиденциальности.",
    ),
    "v3_setting_software_update": MessageLookupByLibrary.simpleMessage(
      "Обновление программного обеспечения",
    ),
    "v3_setting_software_update_deny_action":
        MessageLookupByLibrary.simpleMessage("Позже"),
    "v3_setting_software_update_description":
        MessageLookupByLibrary.simpleMessage(
          "Доступна новая версия. Хотите обновить сейчас?",
        ),
    "v3_setting_software_update_force_action":
        MessageLookupByLibrary.simpleMessage("Обновить сейчас"),
    "v3_setting_software_update_force_description":
        MessageLookupByLibrary.simpleMessage("Доступна новая версия."),
    "v3_setting_software_update_no_available":
        MessageLookupByLibrary.simpleMessage("Нет доступных обновлений"),
    "v3_setting_software_update_no_available_action":
        MessageLookupByLibrary.simpleMessage("ОК"),
    "v3_setting_software_update_no_available_description":
        MessageLookupByLibrary.simpleMessage(
          "AirSync уже обновлен до последней версии.",
        ),
    "v3_setting_software_update_no_internet_description":
        MessageLookupByLibrary.simpleMessage(
          "Пожалуйста, проверьте ваше интернет-соединение и попробуйте снова.",
        ),
    "v3_setting_software_update_no_internet_tittle":
        MessageLookupByLibrary.simpleMessage("Нет подключения к Интернету"),
    "v3_setting_software_update_positive_action":
        MessageLookupByLibrary.simpleMessage("Обновить"),
    "v3_setting_title": MessageLookupByLibrary.simpleMessage("Настройки"),
  };
}
