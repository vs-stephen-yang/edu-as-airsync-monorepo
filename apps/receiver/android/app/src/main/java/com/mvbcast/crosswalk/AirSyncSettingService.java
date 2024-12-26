package com.mvbcast.crosswalk;

import android.annotation.SuppressLint;
import android.app.Service;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.IBinder;
import android.os.RemoteException;

public class AirSyncSettingService extends Service {
    public AirSyncSettingService() {
    }

    @Override
    public IBinder onBind(Intent intent) {
        return mBinder;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        return START_STICKY;
    }

    private final IAirSyncSettingService.Stub mBinder = new IAirSyncSettingService.Stub() {
        @Override
        public String getAirSyncSettingVersion() {
            return IAirSyncSettingService.AIRSYNC_SETTING_SERVICE_VERSION;
        }

        @SuppressLint("ApplySharedPref")
        @Override
        public boolean setAirSyncSetting(String key, String value) throws RemoteException {
            if (key == null || value == null) {
                throw new RemoteException("key or value is null");
            }

            SharedPreferences flutterPref =
                    getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE);
            SharedPreferences.Editor flutterEditor = flutterPref.edit();
            SharedPreferences androidPref =
                    getSharedPreferences("AndroidWindowsOptions", MODE_PRIVATE);
            SharedPreferences.Editor androidEditor = androidPref.edit();

            switch (key) {
                case IAirSyncSettingService.KEY_DEVICE_SETTING_LOCK:
                    flutterEditor.putBoolean("flutter.app_isDeviceSettingLock",
                            value.equals(VAL_DEVICE_SETTING_LOCK)).commit();

                    flutterEditor.putBoolean("flutter.mgr_updateDeviceSettingLock", true).commit();
                    break;
                case IAirSyncSettingService.KEY_DEVICE_NAME:
                    flutterEditor.putString("flutter.app_instanceName", value).commit();

                    flutterEditor.putBoolean("flutter.mgr_updateDeviceName", true).commit();
                    break;
                case IAirSyncSettingService.KEY_LANGUAGE:
                    switch (value) {
                        case VAL_LANGUAGE_GERMAN:
                            flutterEditor.putString("flutter.app_language", "Deutsch").commit();
                            break;
                        case VAL_LANGUAGE_SPANISH:
                            flutterEditor.putString("flutter.app_language", "Español").commit();
                            break;
                        case VAL_LANGUAGE_FRENCH:
                            flutterEditor.putString("flutter.app_language", "Français").commit();
                            break;
                        case VAL_LANGUAGE_CHINESE_ZH:
                            flutterEditor.putString("flutter.app_language", "繁體中文").commit();
                            break;
                        case VAL_LANGUAGE_ENGLISH:
                        default:
                            flutterEditor.putString("flutter.app_language", "English").commit();
                            break;
                    }

                    flutterEditor.putBoolean("flutter.mgr_UpdateLanguage", true).commit();
                    break;
                case IAirSyncSettingService.KEY_SHOW_DISPLAY_CODE:
                    androidEditor.putBoolean("visibility",
                            value.equals(VAL_SHOW_DISPLAY_CODE_ON)).commit();

                    flutterEditor.putBoolean("flutter.mgr_UpdateShowDisplayCode", true).commit();
                    break;
                case IAirSyncSettingService.KEY_INVITED_TO_GROUP:
                    switch (value) {
                        case VAL_INVITED_TO_GROUP_AUTO_ACCEPT:
                            flutterEditor.putString("flutter.app_setting_invited_to_group", "1").commit();
                            break;
                        case VAL_INVITED_TO_GROUP_IGNORE:
                            flutterEditor.putString("flutter.app_setting_invited_to_group", "2").commit();
                            break;
                        case VAL_INVITED_TO_GROUP_NOTIFY_ME:
                        default:
                            flutterEditor.putString("flutter.app_setting_invited_to_group", "0").commit();
                            break;
                    }

                    flutterEditor.putBoolean("flutter.mgr_UpdateInvitedToGroup", true).commit();
                    break;
                case IAirSyncSettingService.KEY_AUTO_FILL_OTP:
                    flutterEditor.putBoolean("flutter.app_DeviceListQuickConnect",
                            value.equals(VAL_AUTO_FILL_OTP_ON)).commit();

                    flutterEditor.putBoolean("flutter.mgr_UpdateAutoFillOTP", true).commit();
                    break;
                case IAirSyncSettingService.KEY_SCREENSHARING_WITH_APPROVAL:
                    flutterEditor.putBoolean("flutter.app_AuthorizeModeEnable",
                            value.equals(VAL_SCREENSHARING_WITH_APPROVAL_ON)).commit();

                    flutterEditor.putBoolean("flutter.mgr_UpdateScreenSharingWithApproval", true).commit();
                    break;
                case IAirSyncSettingService.KEY_BROADCAST_LOCK:
                    flutterEditor.putBoolean("flutter.app_isBroadcastLock",
                            value.equals(VAL_BROADCAST_LOCK)).commit();

                    flutterEditor.putBoolean("flutter.mgr_UpdateBroadcastLock", true).commit();
                    break;
                case IAirSyncSettingService.KEY_CAST_TO_DEVICE:
                    flutterEditor.putBoolean("flutter.app_SenderModeEnable",
                            value.equals(VAL_CAST_TO_DEVICE_ON)).commit();

                    flutterEditor.putBoolean("flutter.mgr_UpdateCastToDevice", true).commit();
                    break;
                case IAirSyncSettingService.KEY_MIRRORING_LOCK:
                    flutterEditor.putBoolean("flutter.app_isMirroringLock",
                            value.equals(VAL_MIRRORING_LOCK)).commit();

                    flutterEditor.putBoolean("flutter.mgr_UpdateMirroringLock", true).commit();
                    break;
                case IAirSyncSettingService.KEY_AIRPLAY:
                    flutterEditor.putBoolean("flutter.app_AirPlayEnable",
                            value.equals(VAL_AIRPLAY_ON)).commit();

                    flutterEditor.putBoolean("flutter.mgr_UpdateAirPlay", true).commit();
                    break;
                case IAirSyncSettingService.KEY_AIRPLAY_CODE:
                    flutterEditor.putBoolean("flutter.app_AirPlayCodeEnable",
                            value.equals(VAL_AIRPLAY_CODE_ON)).commit();

                    flutterEditor.putBoolean("flutter.mgr_UpdateAirPlayCode", true).commit();
                    break;
                case IAirSyncSettingService.KEY_GOOGLE_CAST:
                    flutterEditor.putBoolean("flutter.app_GoogleCastEnable",
                            value.equals(VAL_GOOGLE_CAST_ON)).commit();

                    flutterEditor.putBoolean("flutter.mgr_UpdateGoogleCast", true).commit();
                    break;
                case IAirSyncSettingService.KEY_MIRACAST:
                    flutterEditor.putBoolean("flutter.app_MiracastEnable",
                            value.equals(VAL_MIRACAST_ON)).commit();

                    flutterEditor.putBoolean("flutter.mgr_UpdateMiracast", true).commit();
                    break;
                case IAirSyncSettingService.KEY_MIRROR_AUTO_ACCEPT:
                    flutterEditor.putBoolean("flutter.app_autoAcceptRequired",
                            value.equals(VAL_MIRROR_AUTO_ACCEPT_ON)).commit();

                    flutterEditor.putBoolean("flutter.mgr_UpdateMirrorAutoAccept", true).commit();
                    break;
                case IAirSyncSettingService.KEY_CONNECTIVITY_LOCK:
                    flutterEditor.putBoolean("flutter.app_isConnectivityLock",
                            value.equals(VAL_CONNECTIVITY_LOCK)).commit();

                    flutterEditor.putBoolean("flutter.mgr_UpdateConnectivityLock", true).commit();
                    break;
                case IAirSyncSettingService.KEY_CONNECTIVITY:
                    switch (value) {
                        case VAL_CONNECTIVITY_LOCAL:
                            flutterEditor.putString("flutter.app_settings_connectivity_type",
                                    "local").commit();
                            break;
                        case VAL_CONNECTIVITY_INTERNET:
                            flutterEditor.putString("flutter.app_settings_connectivity_type",
                                    "internet").commit();
                            break;
                        case VAL_CONNECTIVITY_BOTH:
                        default:
                            flutterEditor.putString("flutter.app_settings_connectivity_type",
                                    "both").commit();
                            break;
                    }

                    flutterEditor.putBoolean("flutter.mgr_UpdateConnectivity", true).commit();
                    break;
            }
            return true;
        }

        @Override
        public String getAirSyncSetting(String key) throws RemoteException {
            if (key == null) {
                throw new RemoteException("key is null");
            }

            SharedPreferences flutterPref =
                    getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE);
            SharedPreferences androidPref =
                    getSharedPreferences("AndroidWindowsOptions", MODE_PRIVATE);

            String value = "";

            switch (key) {
                case IAirSyncSettingService.KEY_DEVICE_SETTING_LOCK:
                    value = flutterPref.getBoolean("flutter.app_isDeviceSettingLock",
                            false) ? VAL_DEVICE_SETTING_LOCK : VAL_DEVICE_SETTING_UNLOCK;
                    break;
                case IAirSyncSettingService.KEY_DEVICE_NAME:
                    value = flutterPref.getString("flutter.app_instanceName",
                            "AirSync");
                    break;
                case IAirSyncSettingService.KEY_LANGUAGE:
                    String language = flutterPref.getString("flutter.app_language",
                            "English");
                    switch (language) {
                        case "Deutsch":
                            value = String.format("%s (%s)", VAL_LANGUAGE_GERMAN, language);
                            break;
                        case "Español":
                            value = String.format("%s (%s)", VAL_LANGUAGE_SPANISH, language);
                            break;
                        case "Français":
                            value = String.format("%s (%s)", VAL_LANGUAGE_FRENCH, language);
                            break;
                        case "繁體中文":
                            value = String.format("%s (%s)", VAL_LANGUAGE_CHINESE_ZH, language);
                            break;
                        case "English":
                        default:
                            value = String.format("%s (%s)", VAL_LANGUAGE_ENGLISH, language);
                            break;
                    }
                    break;
                case IAirSyncSettingService.KEY_SHOW_DISPLAY_CODE:
                    value = androidPref.getBoolean("visibility",
                            false) ? VAL_SHOW_DISPLAY_CODE_ON : VAL_SHOW_DISPLAY_CODE_OFF;
                    break;
                case IAirSyncSettingService.KEY_INVITED_TO_GROUP:
                    String invited = flutterPref.getString("flutter.app_setting_invited_to_group",
                            "0");
                    switch (invited) {
                        case "1":
                            value = IAirSyncSettingService.VAL_INVITED_TO_GROUP_AUTO_ACCEPT;
                            break;
                        case "2":
                            value = IAirSyncSettingService.VAL_INVITED_TO_GROUP_IGNORE;
                            break;
                        case "0":
                        default:
                            value = IAirSyncSettingService.VAL_INVITED_TO_GROUP_NOTIFY_ME;
                            break;
                    }
                    break;
                case IAirSyncSettingService.KEY_AUTO_FILL_OTP:
                    value = flutterPref.getBoolean("flutter.app_DeviceListQuickConnect",
                            true) ? VAL_AUTO_FILL_OTP_ON : VAL_AUTO_FILL_OTP_OFF;
                    break;
                case IAirSyncSettingService.KEY_SCREENSHARING_WITH_APPROVAL:
                    value = flutterPref.getBoolean("flutter.app_AuthorizeModeEnable",
                            true) ? VAL_SCREENSHARING_WITH_APPROVAL_ON :
                            VAL_SCREENSHARING_WITH_APPROVAL_OFF;
                    break;
                case IAirSyncSettingService.KEY_BROADCAST_LOCK:
                    value = flutterPref.getBoolean("flutter.app_isBroadcastLock",
                            false) ? VAL_BROADCAST_LOCK : VAL_BROADCAST_UNLOCK;
                    break;
                case IAirSyncSettingService.KEY_CAST_TO_DEVICE:
                    value = flutterPref.getBoolean("flutter.app_SenderModeEnable",
                            false) ? VAL_CAST_TO_DEVICE_ON : VAL_CAST_TO_DEVICE_OFF;
                    break;
                case IAirSyncSettingService.KEY_MIRRORING_LOCK:
                    value = flutterPref.getBoolean("flutter.app_isMirroringLock",
                            false) ? VAL_MIRRORING_LOCK : VAL_MIRRORING_UNLOCK;
                    break;
                case IAirSyncSettingService.KEY_AIRPLAY:
                    value = flutterPref.getBoolean("flutter.app_AirPlayEnable",
                            true) ? VAL_AIRPLAY_ON : VAL_AIRPLAY_OFF;
                    break;
                case IAirSyncSettingService.KEY_AIRPLAY_CODE:
                    value = flutterPref.getBoolean("flutter.app_AirPlayCodeEnable",
                            false) ? VAL_AIRPLAY_CODE_ON : VAL_AIRPLAY_CODE_OFF;
                    break;
                case IAirSyncSettingService.KEY_GOOGLE_CAST:
                    value = flutterPref.getBoolean("flutter.app_GoogleCastEnable",
                            true) ? VAL_GOOGLE_CAST_ON : VAL_GOOGLE_CAST_OFF;
                    break;
                case IAirSyncSettingService.KEY_MIRACAST:
                    value = flutterPref.getBoolean("flutter.app_MiracastEnable",
                            true) ? VAL_MIRACAST_ON : VAL_MIRACAST_OFF;
                    break;
                case IAirSyncSettingService.KEY_MIRROR_AUTO_ACCEPT:
                    value = flutterPref.getBoolean("flutter.app_autoAcceptRequired",
                            false) ? VAL_MIRROR_AUTO_ACCEPT_ON : VAL_MIRROR_AUTO_ACCEPT_OFF;
                    break;
                case IAirSyncSettingService.KEY_CONNECTIVITY_LOCK:
                    value = flutterPref.getBoolean("flutter.app_isConnectivityLock",
                            false) ? VAL_CONNECTIVITY_LOCK : VAL_CONNECTIVITY_UNLOCK;
                    break;
                case IAirSyncSettingService.KEY_CONNECTIVITY:
                    String connectivity = flutterPref.getString("flutter" +
                                    ".app_settings_connectivity_type",
                            "both");
                    switch (connectivity) {
                        case "local":
                            value = IAirSyncSettingService.VAL_CONNECTIVITY_LOCAL;
                            break;
                        case "internet":
                            value = IAirSyncSettingService.VAL_CONNECTIVITY_INTERNET;
                            break;
                        case "both":
                        default:
                            value = IAirSyncSettingService.VAL_CONNECTIVITY_BOTH;
                            break;
                    }
                    break;
            }
            return value;
        }
    };
}