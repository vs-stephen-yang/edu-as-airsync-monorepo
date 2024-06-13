import 'dart:developer';

import 'package:android_window/main.dart' as android_window;
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/pref_language_provider.dart';
import 'package:display_flutter/providers/instance_info_provider.dart';
import 'package:display_flutter/screens/home.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OverlayTabHandler {
  OverlayTabHandler._();

  static const String nameOverlayTabCheck = 'overlay_tab_check';
  static const String nameOverlayTabReady = 'overlay_tab_ready';
  static const String nameInitValue = 'init_value';
  static const String nameSetVisibility = 'set_visibility';
  static const String nameGetVisibility = 'get_visibility';
  static const String nameSetMainInfo = 'set_main_info';
  static const String nameSetOtp = 'set_otp';
  static const String nameSetLanguage = 'set_language';
  static const String nameLaunchApp = 'launch_app';

  static const String keyVisibility = 'visibility';
  static const String keyDeviceName = 'device_name';
  static const String keyDisplayCode = 'display_code';
  static const String keyOtpCode = 'otp_code';
  static const String keyLanguage = 'language';

  static const String valueVisible = 'visible';
  static const String valueInvisible = 'invisible';

  static const String resultEmptyString = '';
  static const String resultNullString = 'null';
}

class AppOverlayTab {
  var infoWidth = PlatformDispatcher.instance.displays.first.size.width / 3;
  var infoHeight = PlatformDispatcher.instance.displays.first.size.height / 15;

  static final AppOverlayTab _instance = AppOverlayTab._internal();

  //private "Named constructors"
  AppOverlayTab._internal();

  // passes the instantiation to the _instance object
  factory AppOverlayTab() => _instance;

  ensureInitialized() {
    android_window.open(
      size: Size(infoWidth, infoHeight),
      position: Offset(infoWidth * 2, 0),
      draggableY: false,
    );
  }

  Future<bool> isOverlayTabRunning() async {
    var isRunning = await android_window.isRunning();
    log('overlay tab isRunning: $isRunning');
    return isRunning;
  }

  void setupOverlayTabHandler(
      {required BuildContext buildContext, required bool isVisible}) {
    android_window.setHandler((String name, Object? data) async {
      log('overlay tab handler-> name:$name');
      switch (name) {
        case OverlayTabHandler.nameOverlayTabReady:
          ChannelProvider channelProvider =
              Provider.of<ChannelProvider>(buildContext, listen: false);

          PrefLanguageProvider languageProvider =
              Provider.of<PrefLanguageProvider>(buildContext, listen: false);

          InstanceInfoProvider instanceInfoProvider =
              Provider.of<InstanceInfoProvider>(buildContext, listen: false);

          await _postMessageToAndroidWindow(OverlayTabHandler.nameInitValue, {
            OverlayTabHandler.keyVisibility: isVisible
                ? OverlayTabHandler.valueVisible
                : OverlayTabHandler.valueInvisible,
            OverlayTabHandler.keyDeviceName: instanceInfoProvider.deviceName,
            OverlayTabHandler.keyDisplayCode: instanceInfoProvider.displayCode,
            OverlayTabHandler.keyOtpCode: channelProvider.isEyeOpen.value
                ? channelProvider.otp.value.toString()
                : 'XXXX',
            OverlayTabHandler.keyLanguage: languageProvider.language,
          });

          instanceInfoProvider.addListener(() async {
            await setDeviceNameAndDisplayCode(
              instanceInfoProvider.deviceName,
              instanceInfoProvider.displayCode,
            );
          });

          channelProvider.otp.addListener(() async {
            await setOtpCode(channelProvider.isEyeOpen.value
                ? channelProvider.otp.value.toString()
                : 'XXXX');
          });

          channelProvider.isEyeOpen.addListener(() async {
            await setOtpCode(channelProvider.isEyeOpen.value
                ? channelProvider.otp.value.toString()
                : 'XXXX');
          });

          languageProvider.addListener(() async {
            setLanguage(languageProvider.language);
          });

          Home.showTitleBottomBar.addListener(() {
            if (!Home.showTitleBottomBar.value) {
              launchApp();
            }
          });

          Home.orientation.addListener(() {
            AppOverlayTab().updateWindowSize(
                Home.orientation.value == Orientation.portrait.index,
                AppPreferences().showOverlayTab);
          });
          AppOverlayTab().updateWindowSize(
              Home.orientation.value == Orientation.portrait.index,
              AppPreferences().showOverlayTab);

          return OverlayTabHandler.resultEmptyString;
      }
      return OverlayTabHandler.resultNullString;
    });
    _postMessageToAndroidWindow(OverlayTabHandler.nameOverlayTabCheck, null);
  }

  Future<void> setVisibility(bool isVisible) async {
    if (isVisible) {
      android_window.resize(infoWidth.toInt(), infoHeight.toInt());
    } else {
      android_window.resize(0, 0);
    }
    await _postMessageToAndroidWindow(OverlayTabHandler.nameSetVisibility, {
      OverlayTabHandler.keyVisibility: isVisible
          ? OverlayTabHandler.valueVisible
          : OverlayTabHandler.valueInvisible
    });
  }

  Future<bool> getVisibility() async {
    final response = await _postMessageToAndroidWindow(
        OverlayTabHandler.nameGetVisibility, null);
    final visible = response[OverlayTabHandler.keyVisibility];
    return visible == OverlayTabHandler.valueVisible;
  }

  Future<void> updateWindowSize(bool isPortrait, bool isVisible) async {
    if (isPortrait) {
      infoWidth = PlatformDispatcher.instance.displays.first.size.width / 1.6;
      infoHeight = PlatformDispatcher.instance.displays.first.size.height / 26;
    } else {
      infoWidth = PlatformDispatcher.instance.displays.first.size.width / 3;
      infoHeight = PlatformDispatcher.instance.displays.first.size.height / 15;
    }
    log('overlay tab isPortrait: $isPortrait, infoWidth: $infoWidth, infoHeight: $infoHeight');
    bool running = await isOverlayTabRunning();
    if (running) {
      if (isVisible) {
        android_window.resize(infoWidth.toInt(), infoHeight.toInt());
      } else {
        android_window.resize(0, 0);
      }
    }
  }

  Future<void> setDeviceNameAndDisplayCode(
      String deviceName, String displayCode) async {
    await _postMessageToAndroidWindow(OverlayTabHandler.nameSetMainInfo, {
      OverlayTabHandler.keyDeviceName: deviceName,
      OverlayTabHandler.keyDisplayCode: displayCode
    });
  }

  Future<void> setOtpCode(String otpCode) async {
    await _postMessageToAndroidWindow(
        OverlayTabHandler.nameSetOtp, {OverlayTabHandler.keyOtpCode: otpCode});
  }

  Future<void> setLanguage(String language) async {
    await _postMessageToAndroidWindow(OverlayTabHandler.nameSetLanguage,
        {OverlayTabHandler.keyLanguage: language});
  }

  Future<void> launchApp() async {
    await _postMessageToAndroidWindow(OverlayTabHandler.nameLaunchApp, {});
  }

  Future<Map<Object?, Object?>> _postMessageToAndroidWindow(
      String key, Map<String, String>? value) async {
    bool running = await isOverlayTabRunning();
    if (running) {
      log('overlay tab post message-> key:$key, value:$value');
      final response = await android_window.post(key, value);
      log('overlay tab response: $response');
      if (response is Map<Object?, Object?>) {
        return response;
      }
    }
    return <Object?, Object?>{};
  }
}
