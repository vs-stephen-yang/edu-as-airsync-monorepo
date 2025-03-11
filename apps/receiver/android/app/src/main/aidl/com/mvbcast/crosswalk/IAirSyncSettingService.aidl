package com.mvbcast.crosswalk;

interface IAirSyncSettingService {
    const String AIRSYNC_SETTING_SERVICE_VERSION = "1.1.0";

    // V1.1.0 start
    // region settings
    const String KEY_SETTINGS_LOCK = "key_settings_lock";
    const String VAL_SETTINGS_LOCK = "val_settings_lock";
    const String VAL_SETTINGS_UNLOCK = "val_settings_unlock";

    const String KEY_SETTINGS_PASSWORD = "key_settings_password";
    const String VAL_SETTINGS_PASSWORD = "";
    // endregion

    // V1.0.0 start
    // region device setting
    const String KEY_DEVICE_SETTING_LOCK = "key_device_setting_lock";
    const String VAL_DEVICE_SETTING_LOCK = "val_device_setting_lock";
    const String VAL_DEVICE_SETTING_UNLOCK = "val_device_setting_unlock";

    const String KEY_DEVICE_NAME = "key_device_name";
    const String VAL_DEVICE_NAME = "";

    const String KEY_LANGUAGE = "key_language";
    const String VAL_LANGUAGE_DANISH = "val_language_danish";
    const String VAL_LANGUAGE_GERMAN = "val_language_german";
    const String VAL_LANGUAGE_ENGLISH = "val_language_english";
    const String VAL_LANGUAGE_FINNISH = "val_language_finnish";
    const String VAL_LANGUAGE_NORWEGIAN = "val_language_norwegian";
    const String VAL_LANGUAGE_SPANISH = "val_language_spanish";
    const String VAL_LANGUAGE_FRENCH = "val_language_french";
    const String VAL_LANGUAGE_SWEDISH = "val_language_swedish";
    const String VAL_LANGUAGE_CHINESE_ZH = "val_language_chinese_zh";

    const String KEY_SHOW_DISPLAY_CODE = "key_show_display_code";
    const String VAL_SHOW_DISPLAY_CODE_ON = "val_show_display_code_on";
    const String VAL_SHOW_DISPLAY_CODE_OFF = "val_show_display_code_off";

    const String KEY_INVITED_TO_GROUP = "key_invited_to_group";
    const String VAL_INVITED_TO_GROUP_NOTIFY_ME = "val_invited_to_group_notify_me";
    const String VAL_INVITED_TO_GROUP_AUTO_ACCEPT = "val_invited_to_group_auto_accept";
    const String VAL_INVITED_TO_GROUP_IGNORE = "val_invited_to_group_ignore";

    const String KEY_AUTO_FILL_OTP = "key_auto_fill_otp";
    const String VAL_AUTO_FILL_OTP_ON = "val_auto_fill_otp_on";
    const String VAL_AUTO_FILL_OTP_OFF = "val_auto_fill_otp_off";

    const String KEY_SCREENSHARING_WITH_APPROVAL = "key_screensharing_with_approval";
    const String VAL_SCREENSHARING_WITH_APPROVAL_ON = "val_screensharing_with_approval_on";
    const String VAL_SCREENSHARING_WITH_APPROVAL_OFF = "val_screensharing_with_approval_off";
    // endregion

    // region broadcast
    const String KEY_BROADCAST_LOCK = "key_broadcast_lock";
    const String VAL_BROADCAST_LOCK = "val_broadcast_lock";
    const String VAL_BROADCAST_UNLOCK = "val_broadcast_unlock";

    const String KEY_CAST_TO_DEVICE = "key_cast_to_device";
    const String VAL_CAST_TO_DEVICE_ON = "val_cast_to_device_on";
    const String VAL_CAST_TO_DEVICE_OFF = "val_cast_to_device_off";
    // endregion

    // region mirroring
    const String KEY_MIRRORING_LOCK = "key_mirroring_lock";
    const String VAL_MIRRORING_LOCK = "val_mirroring_lock";
    const String VAL_MIRRORING_UNLOCK = "val_mirroring_unlock";

    const String KEY_AIRPLAY = "key_airplay";
    const String VAL_AIRPLAY_ON = "val_airplay_on";
    const String VAL_AIRPLAY_OFF = "val_airplay_off";

    const String KEY_AIRPLAY_CODE = "key_airplay_code";
    const String VAL_AIRPLAY_CODE_ON = "val_airplay_code_on";
    const String VAL_AIRPLAY_CODE_OFF = "val_airplay_code_off";

    const String KEY_GOOGLE_CAST = "key_google_cast";
    const String VAL_GOOGLE_CAST_ON = "val_google_cast_on";
    const String VAL_GOOGLE_CAST_OFF = "val_google_cast_off";

    const String KEY_MIRACAST = "key_miracast";
    const String VAL_MIRACAST_ON = "val_miracast_on";
    const String VAL_MIRACAST_OFF = "val_miracast_off";

    const String KEY_MIRROR_AUTO_ACCEPT = "key_mirror_auto_accept";
    const String VAL_MIRROR_AUTO_ACCEPT_ON = "val_mirror_auto_accept_on";
    const String VAL_MIRROR_AUTO_ACCEPT_OFF = "val_mirror_auto_accept_off";
    // endregion

    // region connectivity
    const String KEY_CONNECTIVITY_LOCK = "key_connectivity_lock";
    const String VAL_CONNECTIVITY_LOCK = "val_connectivity_lock";
    const String VAL_CONNECTIVITY_UNLOCK = "val_connectivity_unlock";

    const String KEY_CONNECTIVITY = "key_connectivity";
    const String VAL_CONNECTIVITY_BOTH = "val_connectivity_both";
    const String VAL_CONNECTIVITY_LOCAL = "val_connectivity_local";
    const String VAL_CONNECTIVITY_INTERNET = "val_connectivity_internet";
    // endregion

    String getAirSyncSettingVersion();

    boolean setAirSyncSetting(String key, String value);

    String getAirSyncSetting(String key);
}