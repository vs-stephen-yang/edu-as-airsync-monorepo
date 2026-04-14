import 'dart:developer';
import 'dart:io';

import 'package:android_window/main.dart' as android_window;
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/instance_info_provider.dart';
import 'package:display_flutter/screens/v3_overlay_tab.dart';
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
  static const String nameUpdateTextSize = 'update_text_size';

  static const String keyVisibility = 'visibility';
  static const String keyDeviceName = 'device_name';
  static const String keyDisplayCode = 'display_code';
  static const String keyOtpCode = 'otp_code';

  static const String valueVisible = 'visible';
  static const String valueInvisible = 'invisible';

  static const String resultEmptyString = '';
  static const String resultNullString = 'null';

  static const String actionRecreatePublisher = 'recreate_publisher';
  static const String actionStopPublisher = 'stop_publisher';
  static const String actionShowZeroDialog = 'show_zero_dialog';
  static const String actionShowOverlayTab = 'show_overlay_tab';
  static const String actionShowFpsKeeper = 'show_fps_keeper';

  static const String nameGetOverlayType = 'get_overlay_Type';
  static const String keyOverlayType = 'overlay_type';
  static const String valueTab = 'tab';
  static const String valueFpsKeeper = 'fps_keeper';
  static const String valueRetryDialog = 'retry_dialog';
}

class AppOverlayTab {
  static final AppOverlayTab _instance = AppOverlayTab._internal();

  //private "Named constructors"
  AppOverlayTab._internal();

  // passes the instantiation to the _instance object
  factory AppOverlayTab() => _instance;

  ensureInitialized() async {
    if (Platform.isWindows) return;
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
    if (Platform.isWindows) return;
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

          AppPreferences().textSizeOptionNotifier.addListener(() async {
            await updateTextSize();
          });

          return OverlayTabHandler.resultEmptyString;
        case OverlayTabHandler.actionRecreatePublisher:
          ChannelProvider channelProvider =
              Provider.of<ChannelProvider>(buildContext, listen: false);
          await channelProvider.remoteScreenRecreatePublish();
          return OverlayTabHandler.resultEmptyString;
        case OverlayTabHandler.actionStopPublisher:
          ChannelProvider channelProvider =
              Provider.of<ChannelProvider>(buildContext, listen: false);
          await channelProvider.stopRemoteScreenFromFail();
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

  Future<void> updateTextSize() async {
    await _postMessageToAndroidWindow(OverlayTabHandler.nameUpdateTextSize, {});
  }

  Future<void> showZeroDialog() async {
    await _postMessageToAndroidWindow(
        OverlayTabHandler.actionShowZeroDialog, {});
  }

  Future<void> showOverlayTab() async {
    await _postMessageToAndroidWindow(
        OverlayTabHandler.actionShowOverlayTab, {});
  }

  Future<void> showFpsKeeper() async {
    await _postMessageToAndroidWindow(
        OverlayTabHandler.actionShowFpsKeeper, {});
  }

  Future<OverlayType> getOverlayType() async {
    final response = await _postMessageToAndroidWindow(
        OverlayTabHandler.nameGetOverlayType, null);
    final type = response[OverlayTabHandler.keyOverlayType];
    switch (type) {
      case OverlayTabHandler.valueTab:
        return OverlayType.tab;
      case OverlayTabHandler.valueRetryDialog:
        return OverlayType.retryDialog;
      case OverlayTabHandler.valueFpsKeeper:
        return OverlayType.fpsKeeper;
      default:
        return OverlayType.tab;
    }
  }

  Future<Map<Object?, Object?>> _postMessageToAndroidWindow(
      String key, Map<String, String>? value) async {
    if (Platform.isWindows) return <Object?, Object?>{};
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
