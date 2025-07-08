import 'dart:developer';

import 'package:android_window/main.dart' as android_window;
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/instance_info_provider.dart';
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
  static const String nameLaunchApp = 'launch_app';

  static const String keyVisibility = 'visibility';
  static const String keyDeviceName = 'device_name';
  static const String keyDisplayCode = 'display_code';
  static const String keyOtpCode = 'otp_code';

  static const String valueVisible = 'visible';
  static const String valueInvisible = 'invisible';

  static const String resultEmptyString = '';
  static const String resultNullString = 'null';
}

class AppOverlayTab {
  static final AppOverlayTab _instance = AppOverlayTab._internal();

  //private "Named constructors"
  AppOverlayTab._internal();

  // passes the instantiation to the _instance object
  factory AppOverlayTab() => _instance;

  ensureInitialized() async {
    android_window.open();
    // wait 10 milliseconds for handle above open process.
    await Future.delayed(const Duration(milliseconds: 10));
    await isOverlayTabRunning();
  }

  Future<bool> isOverlayTabRunning() async {
    bool isRunning = false;
    var retryCount = 10;
    while (retryCount > 0 && !isRunning) {
      isRunning = await android_window.isRunning();
      log('overlay tab isRunning: $isRunning');
      if (isRunning) return true;
      retryCount--;
      // wait 5 milliseconds for next check.
      await Future.delayed(const Duration(milliseconds: 5));
    }
    log('overlay tab is not Running!!');
    return false;
  }

  Future<void> setupOverlayTabHandler(BuildContext buildContext) async {
    await isOverlayTabRunning();
    android_window.setHandler((String name, Object? data) async {
      log('overlay tab handler-> name:$name');
      switch (name) {
        case OverlayTabHandler.nameOverlayTabReady:
          ChannelProvider channelProvider =
              Provider.of<ChannelProvider>(buildContext, listen: false);

          InstanceInfoProvider instanceInfoProvider =
              Provider.of<InstanceInfoProvider>(buildContext, listen: false);

          await _postMessageToAndroidWindow(OverlayTabHandler.nameInitValue, {
            OverlayTabHandler.keyDeviceName: instanceInfoProvider.deviceName,
            OverlayTabHandler.keyDisplayCode: instanceInfoProvider.displayCode,
            OverlayTabHandler.keyOtpCode: channelProvider.otp.value,
          });

          instanceInfoProvider.addListener(() async {
            await setDeviceNameAndDisplayCode(
              instanceInfoProvider.deviceName,
              instanceInfoProvider.displayCode,
            );
          });

          channelProvider.otp.addListener(() async {
            await setOtpCode(channelProvider.otp.value);
          });

          return OverlayTabHandler.resultEmptyString;
      }
      return OverlayTabHandler.resultNullString;
    });
    await _postMessageToAndroidWindow(
        OverlayTabHandler.nameOverlayTabCheck, null);
  }

  Future<void> setVisibility(bool isVisible) async {
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

  Future<void> launchApp() async {
    await _postMessageToAndroidWindow(OverlayTabHandler.nameLaunchApp, {});
  }

  Future<Map<Object?, Object?>> _postMessageToAndroidWindow(
      String key, Map<String, String>? value) async {
    var isRunning = await isOverlayTabRunning();
    if (isRunning) {
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
