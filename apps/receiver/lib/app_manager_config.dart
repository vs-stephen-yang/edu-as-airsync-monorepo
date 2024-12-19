import 'dart:async';
import 'dart:developer';

import 'package:display_flutter/app_overlay_tab.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/instance_info_provider.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/providers/pref_language_provider.dart';
import 'package:display_flutter/providers/settings_provider.dart';
import 'package:display_flutter/services/display_service_broadcast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppManagerConfig {
  static final AppManagerConfig _instance = AppManagerConfig._internal();

  //private "Named constructors"
  AppManagerConfig._internal();

  // passes the instantiation to the _instance object
  factory AppManagerConfig() => _instance;

  Future<void> ensureInitialized() async {
    _load();
  }

  Timer? _appPreferenceUpdateTimer;

  bool _isDeviceSettingLockUpdate = false;
  bool _isDeviceNameUpdate = false;
  bool _isLanguageUpdate = false;
  bool _isShowDisplayCodeUpdate = false;
  bool _isInvitedToGroupUpdate = false;
  bool _isAutoFillOTPUpdate = false;
  bool _isScreenSharingWithApprovalUpdate = false;
  bool _isBroadcastLockUpdate = false;
  bool _isCastToDeviceUpdate = false;
  bool _isMirroringLockUpdate = false;
  bool _isAirPlayUpdate = false;
  bool _isAirPlayCodeUpdate = false;
  bool _isGoogleCastUpdate = false;
  bool _isMiracastUpdate = false;
  bool _isMirrorAutoAcceptUpdate = false;
  bool _isConnectivityLockUpdate = false;
  bool _isConnectivityUpdate = false;

  _load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDeviceSettingLockUpdate =
        prefs.getBool('mgr_updateDeviceSettingLock') ?? false;
    _isDeviceNameUpdate = prefs.getBool('mgr_updateDeviceName') ?? false;
    _isLanguageUpdate = prefs.getBool('mgr_UpdateLanguage') ?? false;
    _isShowDisplayCodeUpdate =
        prefs.getBool('mgr_UpdateShowDisplayCode') ?? false;
    _isInvitedToGroupUpdate =
        prefs.getBool('mgr_UpdateInvitedToGroup') ?? false;
    _isAutoFillOTPUpdate = prefs.getBool('mgr_UpdateAutoFillOTP') ?? false;
    _isScreenSharingWithApprovalUpdate =
        prefs.getBool('mgr_UpdateScreenSharingWithApproval') ?? false;
    _isBroadcastLockUpdate = prefs.getBool('mgr_UpdateBroadcastLock') ?? false;
    _isCastToDeviceUpdate = prefs.getBool('mgr_UpdateCastToDevice') ?? false;
    _isMirroringLockUpdate = prefs.getBool('mgr_UpdateMirroringLock') ?? false;
    _isAirPlayUpdate = prefs.getBool('mgr_UpdateAirPlay') ?? false;
    _isAirPlayCodeUpdate = prefs.getBool('mgr_UpdateAirPlayCode') ?? false;
    _isGoogleCastUpdate = prefs.getBool('mgr_UpdateGoogleCast') ?? false;
    _isMiracastUpdate = prefs.getBool('mgr_UpdateMiracast') ?? false;
    _isMirrorAutoAcceptUpdate =
        prefs.getBool('mgr_UpdateMirrorAutoAccept') ?? false;
    _isConnectivityLockUpdate =
        prefs.getBool('mgr_UpdateConnectivityLock') ?? false;
    _isConnectivityUpdate = prefs.getBool('mgr_UpdateConnectivity') ?? false;
  }

  startHandleManagerUpdateRequest(BuildContext context) {
    _appPreferenceUpdateTimer?.cancel();
    _appPreferenceUpdateTimer =
        Timer.periodic(const Duration(seconds: 30), (_) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.reload(); // reload from storage
      await _load(); // load to memory

      log('handle manager update -> context mounted: ${context.mounted}');

      if (context.mounted &&
          (_isDeviceSettingLockUpdate ||
              _isBroadcastLockUpdate ||
              _isMirroringLockUpdate ||
              _isConnectivityLockUpdate)) {
        _isDeviceSettingLockUpdate = false;
        _isBroadcastLockUpdate = false;
        _isMirroringLockUpdate = false;
        _isConnectivityLockUpdate = false;

        SettingsProvider settingsProvider =
            Provider.of<SettingsProvider>(context, listen: false);
        // reload to memory
        await settingsProvider.reloadPreferences();

        // clear manager update request
        await prefs.setBool('mgr_updateDeviceSettingLock', false);
        await prefs.setBool('mgr_UpdateBroadcastLock', false);
        await prefs.setBool('mgr_UpdateMirroringLock', false);
        await prefs.setBool('mgr_UpdateConnectivityLock', false);
      }

      if (context.mounted && _isDeviceNameUpdate) {
        _isDeviceNameUpdate = false;

        InstanceInfoProvider instanceInfoProvider =
            Provider.of<InstanceInfoProvider>(context, listen: false);

        // reload to memory
        await AppPreferences().reloadPreferences();

        // Apply new settings
        instanceInfoProvider.instanceName = AppPreferences().instanceName;

        // clear manager update request
        await prefs.setBool('mgr_updateDeviceName', false);
      }

      if (context.mounted && _isLanguageUpdate) {
        _isLanguageUpdate = false;

        PrefLanguageProvider prefLanguageProvider =
            Provider.of<PrefLanguageProvider>(context, listen: false);

        // reload to memory
        await prefLanguageProvider.reloadPreferences();

        // Apply new settings
        prefLanguageProvider.setLanguage(prefLanguageProvider.language);

        // clear manager update request
        await prefs.setBool('mgr_UpdateLanguage', false);
      }

      if (_isShowDisplayCodeUpdate) {
        _isShowDisplayCodeUpdate = false;
        await AppOverlayTab()
            .setVisibility(await AppOverlayTab().getVisibility());

        // clear manager update request
        await prefs.setBool('mgr_UpdateShowDisplayCode', false);
      }

      if (context.mounted && _isInvitedToGroupUpdate) {
        _isInvitedToGroupUpdate = false;

        // reload to memory
        await AppPreferences().loadInvitedToGroupSelectedItem();

        // Apply new settings
        DisplayServiceBroadcast.instance
            .updateInvitedToGroupOption(AppPreferences().invitedToGroup);

        // clear manager update request
        await prefs.setBool('mgr_UpdateInvitedToGroup', false);
      }

      if (context.mounted &&
          (_isAutoFillOTPUpdate || _isScreenSharingWithApprovalUpdate)) {
        _isAutoFillOTPUpdate = false;
        _isScreenSharingWithApprovalUpdate = false;

        ChannelProvider channelProvider =
            Provider.of<ChannelProvider>(context, listen: false);
        // reload to memory
        await channelProvider.reloadPreferences();

        // clear manager update request
        await prefs.setBool('mgr_UpdateAutoFillOTP', false);
        await prefs.setBool('mgr_UpdateScreenSharingWithApproval', false);
      }

      if (context.mounted && _isCastToDeviceUpdate) {
        _isCastToDeviceUpdate = false;

        ChannelProvider channelProvider =
            Provider.of<ChannelProvider>(context, listen: false);
        // reload to memory
        await channelProvider.reloadPreferences();

        // Apply new settings
        if (channelProvider.isSenderMode) {
          await channelProvider.startRemoteScreen(fromSender: true);
        } else {
          await channelProvider.removeSender(fromSender: true);
        }

        // clear manager update request
        await prefs.setBool('mgr_UpdateCastToDevice', false);
      }

      if (context.mounted && _isAirPlayUpdate) {
        _isAirPlayUpdate = false;

        MirrorStateProvider mirrorStateProvider =
            Provider.of<MirrorStateProvider>(context, listen: false);

        // reload to memory
        await mirrorStateProvider.reloadPreferences();

        // Apply new settings
        if (mirrorStateProvider.airplayEnabled) {
          await mirrorStateProvider.startAirPlay(updatePreference: false);
        } else {
          await mirrorStateProvider.stopAirPlay(updatePreference: false);
        }

        // clear manager update request
        await prefs.setBool('mgr_UpdateAirPlay', false);
      }

      if (context.mounted && _isAirPlayCodeUpdate) {
        _isAirPlayCodeUpdate = false;

        MirrorStateProvider mirrorStateProvider =
            Provider.of<MirrorStateProvider>(context, listen: false);

        // reload to memory
        await mirrorStateProvider.reloadPreferences();

        // Apply new settings
        await mirrorStateProvider
            .setAirPlayCodeEnable(mirrorStateProvider.airPlayCodeEnable);

        // clear manager update request
        await prefs.setBool('mgr_UpdateAirPlayCode', false);
      }

      if (context.mounted && _isGoogleCastUpdate) {
        _isGoogleCastUpdate = false;

        MirrorStateProvider mirrorStateProvider =
            Provider.of<MirrorStateProvider>(context, listen: false);

        // reload to memory
        await mirrorStateProvider.reloadPreferences();

        // Apply new settings
        if (mirrorStateProvider.googleCastEnabled) {
          await mirrorStateProvider.startGoogleCast(updatePreference: false);
        } else {
          await mirrorStateProvider.stopGoogleCast(updatePreference: false);
        }

        // clear manager update request
        await prefs.setBool('mgr_UpdateGoogleCast', false);
      }

      if (context.mounted && _isMiracastUpdate) {
        _isMiracastUpdate = false;

        MirrorStateProvider mirrorStateProvider =
            Provider.of<MirrorStateProvider>(context, listen: false);

        // reload to memory
        await mirrorStateProvider.reloadPreferences();

        // Apply new settings
        if (mirrorStateProvider.miracastEnabled) {
          await mirrorStateProvider.startMiracast(updatePreference: false);
        } else {
          await mirrorStateProvider.stopMiracast(updatePreference: false);
        }

        // clear manager update request
        await prefs.setBool('mgr_UpdateMiracast', false);
      }

      if (context.mounted && _isMirrorAutoAcceptUpdate) {
        _isMirrorAutoAcceptUpdate = false;

        MirrorStateProvider mirrorStateProvider =
            Provider.of<MirrorStateProvider>(context, listen: false);

        // reload to memory
        await mirrorStateProvider.reloadPreferences();

        // Apply new settings
        await mirrorStateProvider
            .setAirPlayCodeEnable(mirrorStateProvider.airPlayCodeEnable);

        // clear manager update request
        await prefs.setBool('mgr_UpdateMirrorAutoAccept', false);
      }

      if (context.mounted && _isConnectivityUpdate) {
        _isConnectivityUpdate = false;

        ChannelProvider channelProvider =
            Provider.of<ChannelProvider>(context, listen: false);

        // reload to memory
        await AppPreferences().loadSelectedConnectivityType();

        // Apply new settings
        channelProvider.launchChannelServer();

        // clear manager update request
        await prefs.setBool('mgr_UpdateConnectivity', false);
      }

    });
  }

  stopHandleManagerUpdateRequest() {
    _appPreferenceUpdateTimer?.cancel();
    _appPreferenceUpdateTimer = null;
  }
}
