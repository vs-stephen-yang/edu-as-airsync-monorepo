// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a tr locale. All the
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
  String get localeName => 'tr';

  static String m0(value) =>
      "Ekran paylaşımı sona ermek üzere. 3 saat uzatmak ister misiniz? ${value} kez uzatabilirsiniz.";

  static String m1(year, version) => "AirSync ©${year}. sürüm ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "eula_agree": MessageLookupByLibrary.simpleMessage("Kabul Ediyorum"),
    "eula_disagree": MessageLookupByLibrary.simpleMessage("Kabul Etmiyorum"),
    "eula_title": MessageLookupByLibrary.simpleMessage("AirSync EULA"),
    "main_airplay_pin_code": MessageLookupByLibrary.simpleMessage(
      "AirPlay Kodu",
    ),
    "main_auto_startup": MessageLookupByLibrary.simpleMessage(
      "Başlangıçta AirSync\'i başlat",
    ),
    "main_cast_settings_airplay": MessageLookupByLibrary.simpleMessage(
      "AirPlay",
    ),
    "main_cast_settings_device_name": MessageLookupByLibrary.simpleMessage(
      "Ad",
    ),
    "main_cast_settings_google_cast": MessageLookupByLibrary.simpleMessage(
      "Google Cast",
    ),
    "main_cast_settings_miracast": MessageLookupByLibrary.simpleMessage(
      "Miracast",
    ),
    "main_cast_settings_title": MessageLookupByLibrary.simpleMessage(
      "Yayın Ayarları",
    ),
    "main_content_display_code": MessageLookupByLibrary.simpleMessage(
      "Ekran Kodu",
    ),
    "main_content_lan_only": MessageLookupByLibrary.simpleMessage(
      "Sadece LAN bağlantısı",
    ),
    "main_content_one_time_password": MessageLookupByLibrary.simpleMessage(
      "Tek Kullanımlık Şifre",
    ),
    "main_content_one_time_password_get_fail":
        MessageLookupByLibrary.simpleMessage(
          "Şifre yenileme başarısız.\nLütfen 30 saniye bekleyip tekrar deneyin.",
        ),
    "main_feature_no_network_warning": MessageLookupByLibrary.simpleMessage(
      "Kontrol bağlantısı kesildi. Lütfen yeniden bağlanın",
    ),
    "main_feature_reconnect_fail_toast": MessageLookupByLibrary.simpleMessage(
      "Ağ (Kontrol) yeniden bağlanma başarısız",
    ),
    "main_feature_reconnect_success_toast":
        MessageLookupByLibrary.simpleMessage(
          "Ağ (Kontrol) yeniden bağlanma başarılı",
        ),
    "main_feature_reconnecting_toast": MessageLookupByLibrary.simpleMessage(
      "Ağ (Kontrol) yeniden bağlanıyor",
    ),
    "main_get_display_code_failure": MessageLookupByLibrary.simpleMessage(
      "Ekran kodu alınamadı. Ağ bağlantısının devam etmesini bekleyin veya uygulamayı yeniden başlatın.",
    ),
    "main_language_name": MessageLookupByLibrary.simpleMessage("İngilizce"),
    "main_language_title": MessageLookupByLibrary.simpleMessage("Dil"),
    "main_limit_time_message": MessageLookupByLibrary.simpleMessage(
      "5 dakika kaldı",
    ),
    "main_mirror_from_client": MessageLookupByLibrary.simpleMessage(
      "%s ekranını paylaşmak istiyor.",
    ),
    "main_mirror_prompt_accept": MessageLookupByLibrary.simpleMessage(
      "Kabul Et",
    ),
    "main_mirror_prompt_cancel": MessageLookupByLibrary.simpleMessage("İptal"),
    "main_register_display_code_failure": MessageLookupByLibrary.simpleMessage(
      "Ekran Kodu ve Tek Kullanımlık Şifre alınamadı. Bu, bir ağ veya sunucu sorunundan kaynaklanıyor olabilir. Lütfen bağlantı yeniden sağlandığında tekrar deneyin.",
    ),
    "main_settings_airplay_code": MessageLookupByLibrary.simpleMessage(
      "AirPlay kodu",
    ),
    "main_settings_device_list": MessageLookupByLibrary.simpleMessage(
      "Hızlı Bağlantı Şifresi",
    ),
    "main_settings_device_name": MessageLookupByLibrary.simpleMessage("Ad"),
    "main_settings_device_name_cancel": MessageLookupByLibrary.simpleMessage(
      "İPTAL",
    ),
    "main_settings_device_name_hint": MessageLookupByLibrary.simpleMessage(
      "Ad",
    ),
    "main_settings_device_name_save": MessageLookupByLibrary.simpleMessage(
      "KAYDET",
    ),
    "main_settings_device_name_title": MessageLookupByLibrary.simpleMessage(
      "Cihazı yeniden adlandır",
    ),
    "main_settings_language": MessageLookupByLibrary.simpleMessage("Dil"),
    "main_settings_mirror_confirmation": MessageLookupByLibrary.simpleMessage(
      "Yansıtma onayı",
    ),
    "main_settings_pin_visible": MessageLookupByLibrary.simpleMessage(
      "Bağlantı bilgileri",
    ),
    "main_settings_share_to_sender": MessageLookupByLibrary.simpleMessage(
      "Ekranı göndericiye paylaş",
    ),
    "main_settings_share_to_sender_limit_desc":
        MessageLookupByLibrary.simpleMessage(
          "Ekranı 10 göndericiye kadar paylaş.",
        ),
    "main_settings_title": MessageLookupByLibrary.simpleMessage("Ayarlar"),
    "main_settings_whats_new": MessageLookupByLibrary.simpleMessage(
      "Yenilikler?",
    ),
    "main_split_screen_question": MessageLookupByLibrary.simpleMessage(
      "Bölünmüş Ekran Modu için yukarıdaki düğmeye tıklayın. Aynı anda 4\'e kadar katılımcı sunum yapabilir.",
    ),
    "main_split_screen_title": MessageLookupByLibrary.simpleMessage(
      "Bölünmüş Ekran",
    ),
    "main_split_screen_waiting": MessageLookupByLibrary.simpleMessage(
      "Bölünmüş ekran etkin. Sunucunun ekranı paylaşmasını bekliyor...",
    ),
    "main_status_go_background": MessageLookupByLibrary.simpleMessage(
      "AirSync uygulaması arka planda çalışıyor.",
    ),
    "main_status_no_network": MessageLookupByLibrary.simpleMessage(
      "Zayıf ağ bağlantısı algılandı.\nLütfen bağlantınızı kontrol edin.",
    ),
    "main_status_remaining_time": MessageLookupByLibrary.simpleMessage(
      "%02d dk : %02d sn",
    ),
    "main_thanks_content": MessageLookupByLibrary.simpleMessage(
      "AirSync\'i kullandığınız için teşekkür ederiz.",
    ),
    "main_wait_title": MessageLookupByLibrary.simpleMessage(
      "Sunucunun ekranı paylaşmasını bekliyor...",
    ),
    "main_wait_up_next": MessageLookupByLibrary.simpleMessage("SIRADA"),
    "main_webrtc_reconnect_fail_toast": MessageLookupByLibrary.simpleMessage(
      "Ağ (WebRTC) yeniden bağlanma başarısız",
    ),
    "main_webrtc_reconnect_success_toast": MessageLookupByLibrary.simpleMessage(
      "Ağ (WebRTC) yeniden bağlanma başarılı",
    ),
    "main_webrtc_reconnecting_toast": MessageLookupByLibrary.simpleMessage(
      "Ağ (WebRTC) yeniden bağlanıyor",
    ),
    "main_whats_new_content": MessageLookupByLibrary.simpleMessage(
      "[İyileştirme]\n\n1. Daha iyi bir deneyim için tamamen sayısal ekran kodu.\n\n2. Bağlantı kararlılığı geliştirildi.\n\n3. Hatalar giderildi.\n",
    ),
    "main_whats_new_title": MessageLookupByLibrary.simpleMessage(
      "AirSync\'te Ne Var?",
    ),
    "moderator_activate_split_screen": MessageLookupByLibrary.simpleMessage(
      "Bölünmüş Ekran Modu için yukarıdaki düğmeye tıklayın. Aynı anda 4\'e kadar katılımcı sunum yapabilir.",
    ),
    "moderator_cancel": MessageLookupByLibrary.simpleMessage("İPTAL"),
    "moderator_confirm": MessageLookupByLibrary.simpleMessage("Onayla"),
    "moderator_deactivate_split_screen": MessageLookupByLibrary.simpleMessage(
      "Bu bölünmüş ekran oturumunu sonlandırmak istediğinizden emin misiniz? Şu anda paylaşılan tüm ekranlar sonlandırılacaktır.",
    ),
    "moderator_exit": MessageLookupByLibrary.simpleMessage("ÇIKIŞ"),
    "moderator_exit_dialog": MessageLookupByLibrary.simpleMessage(
      "Bu moderatör oturumunu sonlandırmak istediğinizden emin misiniz? Tüm sunucular kaldırılacaktır.",
    ),
    "moderator_presentersLimit": MessageLookupByLibrary.simpleMessage(
      "Moderatör Modu için yukarıdaki düğmeye tıklayın. 6\'ya kadar sunucu katılabilir.",
    ),
    "moderator_presentersList": MessageLookupByLibrary.simpleMessage(
      "Sunucular",
    ),
    "moderator_remove": MessageLookupByLibrary.simpleMessage("KALDIR"),
    "moderator_verifyCode_fail": MessageLookupByLibrary.simpleMessage(
      "Bir şeyler ters gitti. Lütfen tekrar deneyin.",
    ),
    "toast_maximum_split_screen": MessageLookupByLibrary.simpleMessage(
      "Maksimum bölünmüş ekran miktarına ulaşıldı.",
    ),
    "update_install_now": MessageLookupByLibrary.simpleMessage("ŞİMDİ YÜKLE"),
    "update_message": MessageLookupByLibrary.simpleMessage(
      "Yazılımın yeni bir sürümü mevcut",
    ),
    "update_title": MessageLookupByLibrary.simpleMessage(
      "AirSync Güncellemesi",
    ),
    "v3_authorize_prompt_accept": MessageLookupByLibrary.simpleMessage(
      "Kabul Et",
    ),
    "v3_authorize_prompt_accept_all": MessageLookupByLibrary.simpleMessage(
      "Tümünü Kabul Et",
    ),
    "v3_authorize_prompt_decline": MessageLookupByLibrary.simpleMessage(
      "Reddet",
    ),
    "v3_broadcast_cast_board_on": MessageLookupByLibrary.simpleMessage(
      "Yayın devam ediyor",
    ),
    "v3_broadcast_cast_device_on": MessageLookupByLibrary.simpleMessage(
      "Yayın devam ediyor",
    ),
    "v3_broadcast_indicator": MessageLookupByLibrary.simpleMessage("AÇIK"),
    "v3_broadcast_multicast_checkbox": MessageLookupByLibrary.simpleMessage(
      "10-100 Cihaza Yayınla",
    ),
    "v3_broadcast_multicast_desc": MessageLookupByLibrary.simpleMessage(
      "Projeksiyon başladığında alıcı cihaz sayısı değiştirilemez.",
    ),
    "v3_broadcast_multicast_warn": MessageLookupByLibrary.simpleMessage(
      "Düzenlemek için tüm projeksiyonu durdur.",
    ),
    "v3_cast_to_device_Receiving": MessageLookupByLibrary.simpleMessage(
      "Alınıyor",
    ),
    "v3_cast_to_device_list_msg": MessageLookupByLibrary.simpleMessage(
      "Maksimum 10 cihaza kadar.",
    ),
    "v3_cast_to_device_menu_or": MessageLookupByLibrary.simpleMessage("Veya"),
    "v3_cast_to_device_menu_quick_connect1":
        MessageLookupByLibrary.simpleMessage("Hızlı Bağlantı"),
    "v3_cast_to_device_menu_quick_connect2":
        MessageLookupByLibrary.simpleMessage("QR kodunu tarayarak"),
    "v3_cast_to_device_menu_title": MessageLookupByLibrary.simpleMessage(
      "Bu Ekranı Almak İçin Katılın",
    ),
    "v3_cast_to_device_reached_maximum": MessageLookupByLibrary.simpleMessage(
      "Maksimum sınıra ulaştınız.",
    ),
    "v3_cast_to_device_title": MessageLookupByLibrary.simpleMessage(
      "Cihaz listesi",
    ),
    "v3_cast_to_device_touch_back": MessageLookupByLibrary.simpleMessage(
      "Dokunmatik Geri Dönüş",
    ),
    "v3_cast_to_device_touch_back_disable":
        MessageLookupByLibrary.simpleMessage("Devre Dışı Bırak"),
    "v3_cast_to_device_touch_enabled": MessageLookupByLibrary.simpleMessage(
      "Dokunmatik Geri Dönüş",
    ),
    "v3_casting_ended_toast": MessageLookupByLibrary.simpleMessage(
      "Ekran paylaşımı sona erdi.",
    ),
    "v3_casting_time_countdown": m0,
    "v3_casting_time_do_not_extend": MessageLookupByLibrary.simpleMessage(
      "Uzatma",
    ),
    "v3_casting_time_extend": MessageLookupByLibrary.simpleMessage("Uzat"),
    "v3_casting_time_extend_success_toast":
        MessageLookupByLibrary.simpleMessage("3 saat uzatıldı."),
    "v3_download_app_desc": MessageLookupByLibrary.simpleMessage(
      "İndirmek için iOS veya Android cihazınızla QR kodunu tarayın",
    ),
    "v3_download_app_desktop": MessageLookupByLibrary.simpleMessage(
      "En İyi Kullanıcı Deneyimi İçin!",
    ),
    "v3_download_app_desktop_hint": MessageLookupByLibrary.simpleMessage(
      "*Manuel Kurulum",
    ),
    "v3_download_app_desktop_store": MessageLookupByLibrary.simpleMessage(
      "App Store üzerinden MacOS\'u yükle",
    ),
    "v3_download_app_desktop_store_hint": MessageLookupByLibrary.simpleMessage(
      "*Sadece MacOS için",
    ),
    "v3_download_app_desktop_title": MessageLookupByLibrary.simpleMessage(
      "Masaüstü",
    ),
    "v3_download_app_entry": MessageLookupByLibrary.simpleMessage(
      "Gönderici Uygulamasını İndir",
    ),
    "v3_download_app_for_desktop": MessageLookupByLibrary.simpleMessage(
      "Masaüstü için",
    ),
    "v3_download_app_for_desktop_desc": MessageLookupByLibrary.simpleMessage(
      "İndirmek için aşağıdaki URL\'yi girin.",
    ),
    "v3_download_app_for_mobile": MessageLookupByLibrary.simpleMessage(
      "iOS ve Android için",
    ),
    "v3_download_app_for_mobile_desc": MessageLookupByLibrary.simpleMessage(
      "Anında erişim için QR kodunu tarayın.",
    ),
    "v3_download_app_mobile_title": MessageLookupByLibrary.simpleMessage(
      "Mobil",
    ),
    "v3_download_app_or": MessageLookupByLibrary.simpleMessage("VEYA"),
    "v3_download_app_title": MessageLookupByLibrary.simpleMessage(
      "Gönderici Uygulamasını İndir",
    ),
    "v3_eula_agree": MessageLookupByLibrary.simpleMessage("Kabul Et"),
    "v3_eula_disagree": MessageLookupByLibrary.simpleMessage("Kabul Etme"),
    "v3_eula_title": MessageLookupByLibrary.simpleMessage(
      "Son Kullanıcı Lisans Sözleşmesi",
    ),
    "v3_exit_moderator_mode_cancel": MessageLookupByLibrary.simpleMessage(
      "İptal",
    ),
    "v3_exit_moderator_mode_desc": MessageLookupByLibrary.simpleMessage(
      "Emin misin? Bu, tüm katılımcıların bağlantısını kesecektir.",
    ),
    "v3_exit_moderator_mode_exit": MessageLookupByLibrary.simpleMessage(
      "Çıkış",
    ),
    "v3_exit_moderator_mode_title": MessageLookupByLibrary.simpleMessage(
      "Moderatör Modundan Çık",
    ),
    "v3_group_dialog_accept": MessageLookupByLibrary.simpleMessage("Kabul Et"),
    "v3_group_dialog_decline": MessageLookupByLibrary.simpleMessage("Reddet"),
    "v3_group_dialog_message": MessageLookupByLibrary.simpleMessage(
      "%s cihazınıza bir yayın isteği gönderdi. Bu eylem, mevcut içeriği senkronize edecek ve görüntüleyecektir, bu isteği kabul etmek ister misiniz?",
    ),
    "v3_group_dialog_no_device_message": MessageLookupByLibrary.simpleMessage(
      "Cihaz seçilmedi.",
    ),
    "v3_group_dialog_title": MessageLookupByLibrary.simpleMessage(
      "Yayın İsteği: %s",
    ),
    "v3_group_receive_view_status_from": MessageLookupByLibrary.simpleMessage(
      "Şuradan yayınlanıyor",
    ),
    "v3_group_receive_view_status_stop": MessageLookupByLibrary.simpleMessage(
      "Durdur",
    ),
    "v3_group_reject_invited": MessageLookupByLibrary.simpleMessage(
      "yayın isteğinizi reddetti, lütfen Yayın ayarlarını kontrol edin.",
    ),
    "v3_help_center_cast_device_title": MessageLookupByLibrary.simpleMessage(
      "Cihaza yayınla",
    ),
    "v3_help_center_cast_device_title_sub":
        MessageLookupByLibrary.simpleMessage(
          "Ekranını cihazlara yayınlayan IFP.",
        ),
    "v3_help_center_close": MessageLookupByLibrary.simpleMessage("Kapat"),
    "v3_help_center_fullscreen_title": MessageLookupByLibrary.simpleMessage(
      "Tam ekran",
    ),
    "v3_help_center_mute_user_title": MessageLookupByLibrary.simpleMessage(
      "Kullanıcıyı sessize al",
    ),
    "v3_help_center_remove_user_title": MessageLookupByLibrary.simpleMessage(
      "Kullanıcıyı kaldır",
    ),
    "v3_help_center_share_title": MessageLookupByLibrary.simpleMessage(
      "Paylaşmaya davet et",
    ),
    "v3_help_center_share_title_sub": MessageLookupByLibrary.simpleMessage(
      "Ekranını IFP\'ye paylaşan cihazlar.",
    ),
    "v3_help_center_stop_share_title": MessageLookupByLibrary.simpleMessage(
      "Paylaşımı durdur",
    ),
    "v3_help_center_title": MessageLookupByLibrary.simpleMessage(
      "Yardım Merkezi",
    ),
    "v3_help_center_touchback_title": MessageLookupByLibrary.simpleMessage(
      "Dokunmatik Geri Dönüş",
    ),
    "v3_help_center_touchback_title_sub": MessageLookupByLibrary.simpleMessage(
      "Kullanıcının uzaktan kontrolüne izin verir.",
    ),
    "v3_help_center_untouchback_title": MessageLookupByLibrary.simpleMessage(
      "Dokunmatik Geri Dönüşü Kapat",
    ),
    "v3_help_center_untouchback_title_sub":
        MessageLookupByLibrary.simpleMessage(
          "Dokunmatik geri dönüş modunu ayır.",
        ),
    "v3_instruction1a": MessageLookupByLibrary.simpleMessage(
      "airsync.net adresini ziyaret edin veya gönderici uygulamasını açın",
    ),
    "v3_instruction1b": MessageLookupByLibrary.simpleMessage(
      "Gönderici uygulamasını açın",
    ),
    "v3_instruction2": MessageLookupByLibrary.simpleMessage(
      "Ekran kodunu girin",
    ),
    "v3_instruction2_onethird": MessageLookupByLibrary.simpleMessage(
      "Ekran kodu",
    ),
    "v3_instruction3": MessageLookupByLibrary.simpleMessage(
      "Tek kullanımlık şifreyi girin",
    ),
    "v3_instruction3_onethird": MessageLookupByLibrary.simpleMessage(
      "Tek kullanımlık şifre",
    ),
    "v3_instruction_share_screen": MessageLookupByLibrary.simpleMessage(
      "Ekranlarınızı Paylaşın",
    ),
    "v3_instruction_support": MessageLookupByLibrary.simpleMessage(
      "AirPlay, Google Cast veya Miracast aracılığıyla paylaşımı destekler",
    ),
    "v3_last_casting_time_countdown": MessageLookupByLibrary.simpleMessage(
      "Ekran paylaşımı sona ermek üzere. Gerekirse lütfen ekran paylaşımını yeniden başlatın.",
    ),
    "v3_lbl_authorize_prompt_accept": MessageLookupByLibrary.simpleMessage(
      "İsteği kabul et",
    ),
    "v3_lbl_authorize_prompt_accept_all": MessageLookupByLibrary.simpleMessage(
      "Tüm istekleri kabul et",
    ),
    "v3_lbl_authorize_prompt_decline": MessageLookupByLibrary.simpleMessage(
      "İsteği reddet",
    ),
    "v3_lbl_broadcast_multicast_checkbox": MessageLookupByLibrary.simpleMessage(
      "10-100 Cihaza Yayınla",
    ),
    "v3_lbl_cast_device_close": MessageLookupByLibrary.simpleMessage(
      "Yayınlanan cihaz bağlantısını kapat",
    ),
    "v3_lbl_cast_device_next": MessageLookupByLibrary.simpleMessage(
      "sonraki sayfa",
    ),
    "v3_lbl_cast_device_previous": MessageLookupByLibrary.simpleMessage(
      "önceki sayfa",
    ),
    "v3_lbl_cast_device_sort_asc": MessageLookupByLibrary.simpleMessage(
      "artan sırala",
    ),
    "v3_lbl_cast_device_sort_desc": MessageLookupByLibrary.simpleMessage(
      "azalan sırala",
    ),
    "v3_lbl_cast_device_touchback_disable":
        MessageLookupByLibrary.simpleMessage(
          "Yayınlanan cihaz için dokunmatik geri dönüşü devre dışı bırak",
        ),
    "v3_lbl_cast_device_touchback_enable": MessageLookupByLibrary.simpleMessage(
      "Yayınlanan cihaz için dokunmatik geri dönüşü etkinleştir",
    ),
    "v3_lbl_close_download_app_menu": MessageLookupByLibrary.simpleMessage(
      "Gönderici uygulamasını indirme menüsünü kapat",
    ),
    "v3_lbl_close_feature_set_cast_device":
        MessageLookupByLibrary.simpleMessage(
          "Yayınlanan cihaz listesini kapat",
        ),
    "v3_lbl_close_feature_set_moderator": MessageLookupByLibrary.simpleMessage(
      "Moderatör listesini kapat",
    ),
    "v3_lbl_close_help_center": MessageLookupByLibrary.simpleMessage(
      "Yardım merkezini kapat",
    ),
    "v3_lbl_close_streaming_shortcut_menu":
        MessageLookupByLibrary.simpleMessage("Akış Kısayol menüsünü kapat"),
    "v3_lbl_connection_dialog_close": MessageLookupByLibrary.simpleMessage(
      "Bağlantı durumu iletişim kutusunu kapat",
    ),
    "v3_lbl_eula_agree": MessageLookupByLibrary.simpleMessage(
      "EULA\'yı kabul et",
    ),
    "v3_lbl_eula_disagree": MessageLookupByLibrary.simpleMessage(
      "EULA\'yı kabul etme",
    ),
    "v3_lbl_exit_moderator_cancel": MessageLookupByLibrary.simpleMessage(
      "Moderatör modundan çıkışı iptal et",
    ),
    "v3_lbl_exit_moderator_exit": MessageLookupByLibrary.simpleMessage(
      "Moderatör modundan çıkışı onayla",
    ),
    "v3_lbl_extend_casting_do_not_extend": MessageLookupByLibrary.simpleMessage(
      "Yayın süresini uzatma",
    ),
    "v3_lbl_extend_casting_extend": MessageLookupByLibrary.simpleMessage(
      "Yayın süresini uzat",
    ),
    "v3_lbl_group_reject_close": MessageLookupByLibrary.simpleMessage(
      "Grup reddetme bildirimini kapat",
    ),
    "v3_lbl_internet_connection_only_error":
        MessageLookupByLibrary.simpleMessage(
          "Bağlantı hatası, lütfen cihaz ağ ayarlarını kontrol edin",
        ),
    "v3_lbl_internet_connection_warning": MessageLookupByLibrary.simpleMessage(
      "Sadece yerel bağlantı",
    ),
    "v3_lbl_main_language_title": MessageLookupByLibrary.simpleMessage(
      "Dil seçin",
    ),
    "v3_lbl_main_language_title_item": MessageLookupByLibrary.simpleMessage(
      "%s seç",
    ),
    "v3_lbl_message_dialog_cancel": MessageLookupByLibrary.simpleMessage(
      "İletişim kutusunu iptal et",
    ),
    "v3_lbl_message_dialog_confirm": MessageLookupByLibrary.simpleMessage(
      "İletişim kutusunu onayla",
    ),
    "v3_lbl_minimal_quick_connect_menu": MessageLookupByLibrary.simpleMessage(
      "Hızlı bağlantı menüsünü küçült",
    ),
    "v3_lbl_minimal_streaming_qrcode_menu":
        MessageLookupByLibrary.simpleMessage("Akış QR Kodu menüsünü küçült"),
    "v3_lbl_moderator_toggle": MessageLookupByLibrary.simpleMessage(
      "Moderatör modunu aç/kapat",
    ),
    "v3_lbl_open_download_app_menu": MessageLookupByLibrary.simpleMessage(
      "Gönderici uygulamasını indirme menüsünü aç",
    ),
    "v3_lbl_open_feature_set_cast_device": MessageLookupByLibrary.simpleMessage(
      "Yayınlanan cihaz listesini aç",
    ),
    "v3_lbl_open_feature_set_moderator": MessageLookupByLibrary.simpleMessage(
      "Moderatör listesini aç",
    ),
    "v3_lbl_open_help_center": MessageLookupByLibrary.simpleMessage(
      "Yardım merkezi menüsünü aç",
    ),
    "v3_lbl_open_menu_settings": MessageLookupByLibrary.simpleMessage(
      "Ayarlar Menüsünü Aç",
    ),
    "v3_lbl_open_streaming_qrcode_menu": MessageLookupByLibrary.simpleMessage(
      "Akış QR Kodu Menüsünü Aç",
    ),
    "v3_lbl_open_streaming_shortcut_menu": MessageLookupByLibrary.simpleMessage(
      "Akış Kısayol Menüsünü Aç",
    ),
    "v3_lbl_overlay_bring_app_to_top": MessageLookupByLibrary.simpleMessage(
      "Kayan bağlantı bilgisi sekmesi",
    ),
    "v3_lbl_overlay_menu_expand": MessageLookupByLibrary.simpleMessage(
      "Katman menüsünü genişlet",
    ),
    "v3_lbl_overlay_menu_minimize": MessageLookupByLibrary.simpleMessage(
      "Katman menüsünü küçült",
    ),
    "v3_lbl_participant_cast_device": MessageLookupByLibrary.simpleMessage(
      "Bu katılımcıya cihaz yayınla",
    ),
    "v3_lbl_participant_close": MessageLookupByLibrary.simpleMessage(
      "Katılımcı bağlantısını kapat",
    ),
    "v3_lbl_participant_disconnect": MessageLookupByLibrary.simpleMessage(
      "Bu katılımcının bağlantısını kes",
    ),
    "v3_lbl_participant_mirror_close": MessageLookupByLibrary.simpleMessage(
      "Yansıtma katılımcı bağlantısını kapat",
    ),
    "v3_lbl_participant_mirror_share": MessageLookupByLibrary.simpleMessage(
      "Bu katılımcının yansıtma ekranına paylaş",
    ),
    "v3_lbl_participant_mirror_stop": MessageLookupByLibrary.simpleMessage(
      "Yansıtma katılımcısının akışını durdur",
    ),
    "v3_lbl_participant_share": MessageLookupByLibrary.simpleMessage(
      "Bu katılımcının ekranına paylaş",
    ),
    "v3_lbl_participant_stop": MessageLookupByLibrary.simpleMessage(
      "Katılımcının akışını durdur",
    ),
    "v3_lbl_participant_touch_back": MessageLookupByLibrary.simpleMessage(
      "Bu katılımcı için dokunmatik geri dönüşü etkinleştir",
    ),
    "v3_lbl_participant_touch_back_disable":
        MessageLookupByLibrary.simpleMessage(
          "Bu katılımcı için dokunmatik geri dönüşü devre dışı bırak",
        ),
    "v3_lbl_resizable_expand": MessageLookupByLibrary.simpleMessage(
      "Sunum kontrolünü genişlet",
    ),
    "v3_lbl_resizable_minimize": MessageLookupByLibrary.simpleMessage(
      "Sunum kontrolünü küçült",
    ),
    "v3_lbl_resizable_mute": MessageLookupByLibrary.simpleMessage(
      "Sunumu sessize al",
    ),
    "v3_lbl_resizable_stop": MessageLookupByLibrary.simpleMessage(
      "Sunumu durdur",
    ),
    "v3_lbl_settings_accessibility": MessageLookupByLibrary.simpleMessage(
      "Erişilebilirlik",
    ),
    "v3_lbl_settings_back_icon": MessageLookupByLibrary.simpleMessage(
      "Önceki sayfaya dön",
    ),
    "v3_lbl_settings_broadcast": MessageLookupByLibrary.simpleMessage(
      "Yayın ayarları menüsünü aç",
    ),
    "v3_lbl_settings_broadcast_boards": MessageLookupByLibrary.simpleMessage(
      "Yayın panoları menüsünü aç",
    ),
    "v3_lbl_settings_broadcast_devices": MessageLookupByLibrary.simpleMessage(
      "Yayın cihazları menüsünü aç",
    ),
    "v3_lbl_settings_broadcast_to_display_group":
        MessageLookupByLibrary.simpleMessage(
          "Ekran grubuna yayınla menüsünü aç",
        ),
    "v3_lbl_settings_broadcast_to_display_group_cast":
        MessageLookupByLibrary.simpleMessage("Yayınla"),
    "v3_lbl_settings_broadcast_to_display_group_checkbox":
        MessageLookupByLibrary.simpleMessage("Seç %s"),
    "v3_lbl_settings_broadcast_to_display_group_confirm":
        MessageLookupByLibrary.simpleMessage("Seçili cihaz yok"),
    "v3_lbl_settings_broadcast_to_display_group_item":
        MessageLookupByLibrary.simpleMessage("%s seç"),
    "v3_lbl_settings_broadcast_to_display_group_save":
        MessageLookupByLibrary.simpleMessage("Kaydet"),
    "v3_lbl_settings_broadcast_to_display_group_type":
        MessageLookupByLibrary.simpleMessage("Tür seç %s"),
    "v3_lbl_settings_close_icon": MessageLookupByLibrary.simpleMessage(
      "Ayarlar menüsünü kapat",
    ),
    "v3_lbl_settings_connectivity": MessageLookupByLibrary.simpleMessage(
      "Bağlantı ayarları menüsünü aç",
    ),
    "v3_lbl_settings_connectivity_item": MessageLookupByLibrary.simpleMessage(
      "%s seç",
    ),
    "v3_lbl_settings_device_authorize_mode":
        MessageLookupByLibrary.simpleMessage("Yetkilendirme modunu aç/kapat"),
    "v3_lbl_settings_device_auto_fill_otp":
        MessageLookupByLibrary.simpleMessage(
          "OTP otomatik doldurma modunu aç/kapat",
        ),
    "v3_lbl_settings_device_high_image_quality":
        MessageLookupByLibrary.simpleMessage("Yüksek görüntü kalitesi"),
    "v3_lbl_settings_device_launch_on_startup":
        MessageLookupByLibrary.simpleMessage(
          "Otomatik başlangıç modunu aç/kapat",
        ),
    "v3_lbl_settings_device_name": MessageLookupByLibrary.simpleMessage(
      "Cihaz adını değiştir",
    ),
    "v3_lbl_settings_device_name_close": MessageLookupByLibrary.simpleMessage(
      "Cihaz adı ayarını kapat",
    ),
    "v3_lbl_settings_device_name_save": MessageLookupByLibrary.simpleMessage(
      "Cihaz adını kaydet",
    ),
    "v3_lbl_settings_device_setting": MessageLookupByLibrary.simpleMessage(
      "Cihaz ayarları menüsünü aç",
    ),
    "v3_lbl_settings_device_smart_scaling":
        MessageLookupByLibrary.simpleMessage(
          "Akıllı ölçekleme düğmesini aç/kapat",
        ),
    "v3_lbl_settings_enter_device_name": MessageLookupByLibrary.simpleMessage(
      "Cihaz adını girin",
    ),
    "v3_lbl_settings_invite_group": MessageLookupByLibrary.simpleMessage(
      "Ekran yayınlama açılır menüsünü aç",
    ),
    "v3_lbl_settings_invite_group_item": MessageLookupByLibrary.simpleMessage(
      "%s seç",
    ),
    "v3_lbl_settings_knowledge_base": MessageLookupByLibrary.simpleMessage(
      "Bilgi Tabanı",
    ),
    "v3_lbl_settings_legal_policy": MessageLookupByLibrary.simpleMessage(
      "Yasal ve politika ayarları menüsünü aç",
    ),
    "v3_lbl_settings_menu_locked": MessageLookupByLibrary.simpleMessage(
      "Ayarlar Menüsü kilitli",
    ),
    "v3_lbl_settings_mirroring_auto_accept":
        MessageLookupByLibrary.simpleMessage("Otomatik kabul etmeyi aç/kapat"),
    "v3_lbl_settings_mirroring_require_passcode":
        MessageLookupByLibrary.simpleMessage("Şifre istemeyi aç/kapat"),
    "v3_lbl_settings_only_when_casting_info":
        MessageLookupByLibrary.simpleMessage(
          "Ekran grubuna yayınlama hakkında daha fazla bilgi",
        ),
    "v3_lbl_settings_open_source_license": MessageLookupByLibrary.simpleMessage(
      "%s seç",
    ),
    "v3_lbl_settings_show_display_code": MessageLookupByLibrary.simpleMessage(
      "Ekran kodu düğmesini aç/kapat",
    ),
    "v3_lbl_settings_whats_new": MessageLookupByLibrary.simpleMessage(
      "Yenilikler ayarları menüsünü aç",
    ),
    "v3_lbl_settings_whats_new_icon": MessageLookupByLibrary.simpleMessage(
      "yenilikler simgesi",
    ),
    "v3_lbl_shortcuts_airplay": MessageLookupByLibrary.simpleMessage(
      "AirPlay\'i aç/kapat",
    ),
    "v3_lbl_shortcuts_google_cast": MessageLookupByLibrary.simpleMessage(
      "Google Cast\'i aç/kapat",
    ),
    "v3_lbl_shortcuts_miracast": MessageLookupByLibrary.simpleMessage(
      "Miracast\'i aç/kapat",
    ),
    "v3_lbl_shortcuts_mirroring": MessageLookupByLibrary.simpleMessage(
      "Yansıtma ayarları menüsünü aç",
    ),
    "v3_lbl_streaming_airplay_touchback": MessageLookupByLibrary.simpleMessage(
      "Airplay dokunmatik geri dönüş",
    ),
    "v3_lbl_streaming_page_control": MessageLookupByLibrary.simpleMessage(
      "sonraki sayfa",
    ),
    "v3_lbl_streaming_shortcut_airplay_toggle":
        MessageLookupByLibrary.simpleMessage("AirPlay düğmesi"),
    "v3_lbl_streaming_shortcut_cast_device_toggle":
        MessageLookupByLibrary.simpleMessage("Cihazlara yayınla düğmesi"),
    "v3_lbl_streaming_shortcut_expand": MessageLookupByLibrary.simpleMessage(
      "Akış özelliklerini genişlet",
    ),
    "v3_lbl_streaming_shortcut_google_cast_toggle":
        MessageLookupByLibrary.simpleMessage("Google Cast düğmesi"),
    "v3_lbl_streaming_shortcut_menu_locked":
        MessageLookupByLibrary.simpleMessage("Akış Kısayol Menüsü kilitli"),
    "v3_lbl_streaming_shortcut_minimize": MessageLookupByLibrary.simpleMessage(
      "Akış özelliklerini daralt",
    ),
    "v3_lbl_streaming_shortcut_miracast_toggle":
        MessageLookupByLibrary.simpleMessage("Miracast düğmesi"),
    "v3_lbl_streaming_view_expand": MessageLookupByLibrary.simpleMessage(
      "Akış görünümünü genişlet",
    ),
    "v3_lbl_streaming_view_function_expand":
        MessageLookupByLibrary.simpleMessage("Akış fonksiyonunu genişlet"),
    "v3_lbl_streaming_view_function_minimize":
        MessageLookupByLibrary.simpleMessage("Akış fonksiyonunu daralt"),
    "v3_lbl_streaming_view_minimize": MessageLookupByLibrary.simpleMessage(
      "Akış görünümünü daralt",
    ),
    "v3_lbl_streaming_view_mute": MessageLookupByLibrary.simpleMessage(
      "Sesi kapat",
    ),
    "v3_lbl_streaming_view_stop": MessageLookupByLibrary.simpleMessage(
      "Akışı durdur",
    ),
    "v3_lbl_streaming_view_unmute": MessageLookupByLibrary.simpleMessage(
      "Sesi aç",
    ),
    "v3_lbl_touchback_one_device_cancel": MessageLookupByLibrary.simpleMessage(
      "İletişim kutusunu iptal et",
    ),
    "v3_lbl_touchback_one_device_confirm": MessageLookupByLibrary.simpleMessage(
      "İletişim kutusunu onayla",
    ),
    "v3_lbl_touchback_restart_bluetooth_btn_cancel":
        MessageLookupByLibrary.simpleMessage("İptal"),
    "v3_lbl_touchback_restart_bluetooth_btn_restart":
        MessageLookupByLibrary.simpleMessage("Yeniden Başlat"),
    "v3_main_connection_dialog_close": MessageLookupByLibrary.simpleMessage(
      "Kapat",
    ),
    "v3_main_internet_connection_only": MessageLookupByLibrary.simpleMessage(
      "Sadece internet bağlantısı.",
    ),
    "v3_main_internet_connection_only_error":
        MessageLookupByLibrary.simpleMessage(
          "Bağlantı hatası, lütfen cihaz ağ ayarlarını kontrol edin.",
        ),
    "v3_main_internet_connection_only_error_dialog_desc":
        MessageLookupByLibrary.simpleMessage(
          "Bağlantı hatası, lütfen cihaz ağ ayarlarını kontrol edin.",
        ),
    "v3_main_local_connection_only_dialog_desc":
        MessageLookupByLibrary.simpleMessage(
          "Sadece LAN bağlantısı, lütfen cihaz ağ ayarlarını kontrol edin.",
        ),
    "v3_main_status_no_network": MessageLookupByLibrary.simpleMessage(
      "İnternet bağlantısı algılanamıyor. Lütfen bir Wi-Fi veya intranet ağına bağlanın ve tekrar deneyin.",
    ),
    "v3_miracast_not_support": MessageLookupByLibrary.simpleMessage(
      "Miracast şu anda kullanılamıyor. Mevcut Wi-Fi kanalı ekran yansıtmasını desteklemiyor.",
    ),
    "v3_miracast_uibc_not_supported_message":
        MessageLookupByLibrary.simpleMessage(
          "Bu kaynak Miracast dokunmatik geri dönüşü desteklemiyor",
        ),
    "v3_mirror_request_passcode": MessageLookupByLibrary.simpleMessage("Şifre"),
    "v3_moderator_disable_mirror_cancel": MessageLookupByLibrary.simpleMessage(
      "İptal",
    ),
    "v3_moderator_disable_mirror_desc": MessageLookupByLibrary.simpleMessage(
      "Yansıtma, moderatör modunda devre dışı bırakılacaktır",
    ),
    "v3_moderator_disable_mirror_ok": MessageLookupByLibrary.simpleMessage(
      "TAMAM",
    ),
    "v3_moderator_disable_mirror_title": MessageLookupByLibrary.simpleMessage(
      "Moderatör Modu İçin Yansıtmayı Devre Dışı Bırak",
    ),
    "v3_moderator_mode": MessageLookupByLibrary.simpleMessage("Moderatör modu"),
    "v3_new_sharing_join_session": MessageLookupByLibrary.simpleMessage(
      " oturuma katıldı",
    ),
    "v3_participant_item_casting": MessageLookupByLibrary.simpleMessage(
      "Yayınlanıyor",
    ),
    "v3_participant_item_connected": MessageLookupByLibrary.simpleMessage(
      "Bağlandı",
    ),
    "v3_participant_item_controlling": MessageLookupByLibrary.simpleMessage(
      "Alınıyor + Dokunmatik Geri Dönüş",
    ),
    "v3_participant_item_receiving": MessageLookupByLibrary.simpleMessage(
      "Alınıyor",
    ),
    "v3_participant_item_share": MessageLookupByLibrary.simpleMessage("Paylaş"),
    "v3_participant_item_waiting": MessageLookupByLibrary.simpleMessage(
      "Bekleniyor...",
    ),
    "v3_participants_desc": MessageLookupByLibrary.simpleMessage(
      "Maksimum 6 katılımcıya kadar.",
    ),
    "v3_participants_desc_maximum_9": MessageLookupByLibrary.simpleMessage(
      "Maksimum 9 katılımcıya kadar.",
    ),
    "v3_participants_title": MessageLookupByLibrary.simpleMessage(
      "Katılımcılar",
    ),
    "v3_qrcode_quick_connect": MessageLookupByLibrary.simpleMessage(
      "Hızlı Bağlantı",
    ),
    "v3_quick_connect_menu_bottom_msg": MessageLookupByLibrary.simpleMessage(
      "İki veya daha fazla kullanıcı ekran paylaştığında bölünmüş ekran etkinleşir.",
    ),
    "v3_quick_connect_menu_display_code": MessageLookupByLibrary.simpleMessage(
      "Ekran Kodu",
    ),
    "v3_quick_connect_menu_qrcode": MessageLookupByLibrary.simpleMessage(
      "QR Kodu",
    ),
    "v3_setting_passcode_cancel": MessageLookupByLibrary.simpleMessage("İptal"),
    "v3_setting_passcode_clear": MessageLookupByLibrary.simpleMessage(
      "Temizle",
    ),
    "v3_setting_passcode_confirm": MessageLookupByLibrary.simpleMessage(
      "Onayla",
    ),
    "v3_setting_passcode_error_description":
        MessageLookupByLibrary.simpleMessage(
          "Geçersiz şifre, lütfen tekrar deneyin.",
        ),
    "v3_setting_passcode_title": MessageLookupByLibrary.simpleMessage(
      "Ayarların kilidini açmak için şifreyi girin",
    ),
    "v3_settings_accessibility": MessageLookupByLibrary.simpleMessage(
      "Erişilebilirlik",
    ),
    "v3_settings_all_the_time_info": MessageLookupByLibrary.simpleMessage(
      "Kaynak IFP ekranını her zaman yayınla.",
    ),
    "v3_settings_broadcast": MessageLookupByLibrary.simpleMessage("Yayın"),
    "v3_settings_broadcast_boards": MessageLookupByLibrary.simpleMessage(
      "Diğer AirSync cihazları",
    ),
    "v3_settings_broadcast_cast_boards": MessageLookupByLibrary.simpleMessage(
      "Panolara yayınla",
    ),
    "v3_settings_broadcast_cast_boards_desc":
        MessageLookupByLibrary.simpleMessage(
          "Bu ekranı ağdaki tüm Etkileşimli Düz Panellere (IFP) paylaşın.",
        ),
    "v3_settings_broadcast_cast_to": MessageLookupByLibrary.simpleMessage(
      "Yayınla:",
    ),
    "v3_settings_broadcast_devices": MessageLookupByLibrary.simpleMessage(
      "Gönderici cihazlar",
    ),
    "v3_settings_broadcast_screen_energy_saving":
        MessageLookupByLibrary.simpleMessage(
          "Yayın sırasında beklenmedik kesintileri önlemek için lütfen enerji tasarrufunu kapatın.",
        ),
    "v3_settings_broadcast_to_display_group":
        MessageLookupByLibrary.simpleMessage("Ekran grubuna yayınla"),
    "v3_settings_connectivity": MessageLookupByLibrary.simpleMessage(
      "Bağlantı",
    ),
    "v3_settings_connectivity_both": MessageLookupByLibrary.simpleMessage(
      "Hem internet hem de yerel bağlantı",
    ),
    "v3_settings_connectivity_internet": MessageLookupByLibrary.simpleMessage(
      "İnternet bağlantısı",
    ),
    "v3_settings_connectivity_internet_desc":
        MessageLookupByLibrary.simpleMessage(
          "İnternet bağlantısı istikrarlı bir ağ gerektirir.",
        ),
    "v3_settings_connectivity_local": MessageLookupByLibrary.simpleMessage(
      "Yerel bağlantı",
    ),
    "v3_settings_connectivity_local_desc": MessageLookupByLibrary.simpleMessage(
      "Yerel bağlantılar, daha fazla güvenlik ve kararlılık sunarak özel bir ağ içinde çalışır.",
    ),
    "v3_settings_device_authorize_mode": MessageLookupByLibrary.simpleMessage(
      "Tüm ekran paylaşımı istekleri için onay iste.",
    ),
    "v3_settings_device_auto_fill_otp": MessageLookupByLibrary.simpleMessage(
      "Tek kullanımlık şifreyi otomatik doldur",
    ),
    "v3_settings_device_auto_fill_otp_desc": MessageLookupByLibrary.simpleMessage(
      "Bu cihaz, Gönderici uygulamasının Hızlı Bağlantı menüsünden seçildiğinde tek dokunuşla bağlantıyı etkinleştirin.",
    ),
    "v3_settings_device_high_image_quality":
        MessageLookupByLibrary.simpleMessage("Yüksek görüntü kalitesi"),
    "v3_settings_device_high_image_quality_off_desc":
        MessageLookupByLibrary.simpleMessage(
          "Gönderici ekran çözünürlüğüne bağlı olarak maksimum QHD (2K) ekran paylaşımı.",
        ),
    "v3_settings_device_high_image_quality_on_desc":
        MessageLookupByLibrary.simpleMessage(
          "Web göndericiden maksimum UHD (4K) ekran paylaşımı ve gönderici ekran çözünürlüğüne bağlı olarak Windows ve macOS göndericiden 3K+ ekran paylaşımı. Yüksek kaliteli ağ gerektirir.",
        ),
    "v3_settings_device_launch_on_startup":
        MessageLookupByLibrary.simpleMessage("Başlangıçta AirSync\'i başlat"),
    "v3_settings_device_name": MessageLookupByLibrary.simpleMessage(
      "Cihaz Adı",
    ),
    "v3_settings_device_name_empty_error": MessageLookupByLibrary.simpleMessage(
      "Cihaz adı boş bırakılamaz",
    ),
    "v3_settings_device_name_save": MessageLookupByLibrary.simpleMessage(
      "Kaydet",
    ),
    "v3_settings_device_not_supported": MessageLookupByLibrary.simpleMessage(
      "Cihaz sürümü desteklenmiyor",
    ),
    "v3_settings_device_setting": MessageLookupByLibrary.simpleMessage(
      "Cihaz ayarları",
    ),
    "v3_settings_device_show_display_code":
        MessageLookupByLibrary.simpleMessage("Ekran kodunu üstte göster"),
    "v3_settings_device_show_display_code_desc":
        MessageLookupByLibrary.simpleMessage(
          "Başka uygulamalara geçildiğinde ve ekran paylaşımı etkin olduğunda bile kodun ekranın üstünde görünür kalmasını sağlayın.",
        ),
    "v3_settings_device_smart_scaling": MessageLookupByLibrary.simpleMessage(
      "Akıllı ölçekleme",
    ),
    "v3_settings_device_smart_scaling_desc": MessageLookupByLibrary.simpleMessage(
      "Ekran alanını en üst düzeye çıkarmak için ekran boyutunu otomatik olarak ayarla. Görüntü biraz bozulabilir.",
    ),
    "v3_settings_device_unavailable": MessageLookupByLibrary.simpleMessage(
      "Kullanılamıyor",
    ),
    "v3_settings_display_group": MessageLookupByLibrary.simpleMessage(
      "Ekran Grubu",
    ),
    "v3_settings_display_group_all_the_time":
        MessageLookupByLibrary.simpleMessage("Her zaman"),
    "v3_settings_display_group_cast": MessageLookupByLibrary.simpleMessage(
      "Yayınla",
    ),
    "v3_settings_display_group_only_casting":
        MessageLookupByLibrary.simpleMessage("Sadece yayınlandığında"),
    "v3_settings_feature_locked": MessageLookupByLibrary.simpleMessage(
      "ViewSonic Manager tarafından kilitlendi.",
    ),
    "v3_settings_invite_group": MessageLookupByLibrary.simpleMessage(
      "Bir ekran grubuna davet edildiğinde",
    ),
    "v3_settings_invite_group_auto_accept":
        MessageLookupByLibrary.simpleMessage("Otomatik Kabul Et"),
    "v3_settings_invite_group_ignore": MessageLookupByLibrary.simpleMessage(
      "Yoksay",
    ),
    "v3_settings_invite_group_notify_me": MessageLookupByLibrary.simpleMessage(
      "Beni bilgilendir",
    ),
    "v3_settings_knowledge_base": MessageLookupByLibrary.simpleMessage(
      "Bilgi Tabanı",
    ),
    "v3_settings_legal_policy": MessageLookupByLibrary.simpleMessage(
      "Yasal ve Politika",
    ),
    "v3_settings_local_connection_only": MessageLookupByLibrary.simpleMessage(
      "Sadece yerel bağlantı",
    ),
    "v3_settings_mirroring_auto_accept": MessageLookupByLibrary.simpleMessage(
      "Otomatik Kabul Et",
    ),
    "v3_settings_mirroring_auto_accept_desc":
        MessageLookupByLibrary.simpleMessage(
          "Moderatör onayı gerektirmeden yansıtmayı anında etkinleştirin.",
        ),
    "v3_settings_mirroring_blocked": MessageLookupByLibrary.simpleMessage(
      "Önce moderatör modunu kapatın.",
    ),
    "v3_settings_mirroring_require_passcode":
        MessageLookupByLibrary.simpleMessage("Şifre iste"),
    "v3_settings_only_when_casting_info": MessageLookupByLibrary.simpleMessage(
      "Yalnızca paylaşılan bir ekranı alırken kaynak IFP ekranını yayınla.",
    ),
    "v3_settings_open_source_license": MessageLookupByLibrary.simpleMessage(
      "Açık Kaynak Lisansları",
    ),
    "v3_settings_privacy_policy": MessageLookupByLibrary.simpleMessage(
      "Gizlilik Politikası",
    ),
    "v3_settings_privacy_policy_description": MessageLookupByLibrary.simpleMessage(
      "ViewSonic, gizliliğinizi korumaya kararlıdır ve kişisel verilerin işlenmesini ciddiye alır. Aşağıdaki Gizlilik Politikası, ViewSonic\'in, sizin Web Sitesini kullanımınız aracılığıyla toplanan kişisel verilerinizi nasıl işleyeceğini ayrıntılı olarak anlatır. ViewSonic, güvenlik teknolojileri kullanarak bilgilerinizin gizliliğini korur ve kişisel bilgilerinizin yetkisiz kullanımını önleyen politikalara uyar. Bu Web Sitesini kullanarak, bilgilerinizin toplanmasına ve kullanılmasına izin vermiş olursunuz.\n\nViewSonic.com\'dan bağlantı verdiğiniz Web sitelerinin kendi gizlilik politikaları olabilir ve bunlar ViewSonic\'in politikasından farklı olabilir. Onları ziyaret ettiğinizde toplanan bilgileri nasıl kullanabilecekleri hakkında ayrıntılı bilgi için lütfen bu Web sitelerinin gizlilik politikalarını inceleyin.\n\nGizlilik Politikamız hakkında daha fazla bilgi edinmek için lütfen aşağıdaki bağlantılara tıklayın.",
    ),
    "v3_settings_resize_text_size": MessageLookupByLibrary.simpleMessage(
      "Metin boyutunu yeniden boyutlandır",
    ),
    "v3_settings_resize_text_size_extra_large":
        MessageLookupByLibrary.simpleMessage("Ekstra Büyük"),
    "v3_settings_resize_text_size_large": MessageLookupByLibrary.simpleMessage(
      "Büyük",
    ),
    "v3_settings_resize_text_size_normal": MessageLookupByLibrary.simpleMessage(
      "Normal",
    ),
    "v3_settings_version": m1,
    "v3_settings_whats_new": MessageLookupByLibrary.simpleMessage("Yenilikler"),
    "v3_settings_whats_new_content": MessageLookupByLibrary.simpleMessage(
      "AirSync %s\n\nAirSync, ViewSonic\'e ait tescilli bir kablosuz ekran paylaşım çözümüdür. AirSync gönderici ile kullanıldığında, kullanıcıların ekranlarını ViewSonic interaktif ekranlarla sorunsuz bir şekilde paylaşmalarını sağlar.\n\nBu sürüm aşağıdaki yeni özellikleri içerir:\n\n1. ViewBoard bölünmüş ekran görünümü desteği.\n\n2. Web gönderici aracılığıyla yüksek kaliteli ekran paylaşımı (4K\'ya kadar) desteği.\n\n3. Windows gönderici aracılığıyla paylaşım yaparken cihaz ses çıkışını sessize alma.\n\n4. Gelişmiş kararlılık.\n\n5. Çeşitli hatalar giderildi.\n",
    ),
    "v3_shortcuts_airplay": MessageLookupByLibrary.simpleMessage("AirPlay"),
    "v3_shortcuts_cast_device": MessageLookupByLibrary.simpleMessage(
      "Cihazlara Yayınla",
    ),
    "v3_shortcuts_cast_device_desc": MessageLookupByLibrary.simpleMessage(
      "Bu ekranı aynı anda birden fazla cihaza, dizüstü bilgisayarlara, tabletlere ve mobil cihazlara yayınlayın.",
    ),
    "v3_shortcuts_google_cast": MessageLookupByLibrary.simpleMessage(
      "Google Cast",
    ),
    "v3_shortcuts_menu_title": MessageLookupByLibrary.simpleMessage(
      "Kısayollar",
    ),
    "v3_shortcuts_miracast": MessageLookupByLibrary.simpleMessage("Miracast"),
    "v3_shortcuts_mirroring": MessageLookupByLibrary.simpleMessage("Yansıtma"),
    "v3_touchback_alert_message": MessageLookupByLibrary.simpleMessage(
      "Aynı anda sadece bir cihaza dokunmatik geri dönüş yapabilirsiniz.",
    ),
    "v3_touchback_alert_title": MessageLookupByLibrary.simpleMessage(
      "%s\'ye dokunmatik geri dönüş?",
    ),
    "v3_touchback_disable_message": MessageLookupByLibrary.simpleMessage(
      "Dokunmatik Geri Dönüş devre dışı bırakıldı.",
    ),
    "v3_touchback_fail_message": MessageLookupByLibrary.simpleMessage(
      "Eşleştirme başarısız oldu. Dokunmatik Geri Dönüş etkinleştirilmedi. Lütfen tekrar deneyin",
    ),
    "v3_touchback_restart_bluetooth_btn_restart":
        MessageLookupByLibrary.simpleMessage("Yeniden Başlat"),
    "v3_touchback_restart_bluetooth_message": MessageLookupByLibrary.simpleMessage(
      "İşlem zaman aşımına uğradı. Lütfen büyük ekrandaki Bluetooth işlevini kapatıp yeniden başlatın, ardından dokunmatik geri dönüşü yeniden başlatın.",
    ),
    "v3_touchback_restart_bluetooth_title":
        MessageLookupByLibrary.simpleMessage(
          "İşlem zaman aşımına uğradı, lütfen Bluetooth\'u yeniden başlatın",
        ),
    "v3_touchback_state_deviceFinding_message":
        MessageLookupByLibrary.simpleMessage("Cihaz Bulunuyor"),
    "v3_touchback_state_deviceFoundSuccess_message":
        MessageLookupByLibrary.simpleMessage("Cihaz Başarıyla Bulundu"),
    "v3_touchback_state_devicePairedSuccess_message":
        MessageLookupByLibrary.simpleMessage("Cihaz Başarıyla Eşleştirildi"),
    "v3_touchback_state_devicePairing_message":
        MessageLookupByLibrary.simpleMessage("Cihaz Eşleştiriliyor"),
    "v3_touchback_state_hidConnected_message":
        MessageLookupByLibrary.simpleMessage("Hid Bağlandı"),
    "v3_touchback_state_hidConnecting_message":
        MessageLookupByLibrary.simpleMessage("Hid Bağlanıyor"),
    "v3_touchback_state_hidProfileServiceStartedSuccess_message":
        MessageLookupByLibrary.simpleMessage(
          "Hid Profil Hizmeti Başarıyla Başlatıldı",
        ),
    "v3_touchback_state_hidProfileServiceStarting_message":
        MessageLookupByLibrary.simpleMessage("Hid Profil Hizmeti Başlatılıyor"),
    "v3_touchback_state_initialized_message":
        MessageLookupByLibrary.simpleMessage("Başlatıldı"),
    "v3_touchback_state_initializing_message":
        MessageLookupByLibrary.simpleMessage("Başlatılıyor"),
    "v3_touchback_success_message": MessageLookupByLibrary.simpleMessage(
      "Artık IFP\'den %s\'yi uzaktan kontrol edebilirsiniz.",
    ),
    "v3_waiting_desc": MessageLookupByLibrary.simpleMessage(
      "Bu katılımcının ekranını paylaşmasını bekliyor",
    ),
    "v3_waiting_join": MessageLookupByLibrary.simpleMessage(
      "Diğerlerinin katılmasını bekliyor",
    ),
    "v3_waiting_up_next": MessageLookupByLibrary.simpleMessage("Sırada"),
    "vbs_ota_progress_msg": MessageLookupByLibrary.simpleMessage(
      "Sistem güncellemeleri indiriliyor",
    ),
  };
}
