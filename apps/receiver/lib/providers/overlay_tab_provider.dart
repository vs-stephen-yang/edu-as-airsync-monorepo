import 'dart:developer';

import 'package:android_window/main.dart' as android_window;
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/providers/pref_language_provider.dart';
import 'package:display_flutter/screens/home.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OverlayTabHandler {
  OverlayTabHandler._();

  static const String nameOverlayTabReady = 'overlay_tab_ready';
  static const String nameInitValue = 'init_value';
  static const String nameSetMainInfo = 'set_main_info';
  static const String nameSetOtp = 'set_otp';
  static const String nameSetLanguage = 'set_language';
  static const String nameLaunchApp = 'launch_app';

  static const String keyDeviceName = 'device_name';
  static const String keyDisplayCode = 'display_code';
  static const String keyOtpCode = 'otp_code';
  static const String keyLanguage = 'language';

  static const String resultEmptyString = '';
  static const String resultNullString = 'null';
}

class OverlayTabProvider extends ChangeNotifier {
  var infoWidth = PlatformDispatcher.instance.displays.first.size.width / 3;
  var infoHeight = PlatformDispatcher.instance.displays.first.size.height / 15;

  BuildContext? _context;

  OverlayTabProvider();

  initContext(BuildContext context) {
    _context = context;
  }

  Future<bool> isFloatingInformationRunning() async {
    return android_window.isRunning();
  }

  void openAndroidWindow(bool isOpen) {
    assert(_context != null,
        'Should call initContext() once before using openAndroidWindow().');

    if (isOpen) {
      android_window.open(
        size: Size(infoWidth, infoHeight),
        position: Offset(infoWidth * 2, 0),
        draggableY: false,
      );
      android_window.setHandler((String name, Object? data) async {
        if (_context == null) OverlayTabHandler.resultEmptyString;

        switch (name) {
          case OverlayTabHandler.nameOverlayTabReady:
            ChannelProvider channelProvider =
                Provider.of<ChannelProvider>(_context!, listen: false);

            MirrorStateProvider mirrorProvider =
                Provider.of<MirrorStateProvider>(_context!, listen: false);

            PrefLanguageProvider languageProvider =
                Provider.of<PrefLanguageProvider>(_context!, listen: false);

            await postMessageToAndroidWindow(OverlayTabHandler.nameInitValue, {
              OverlayTabHandler.keyDeviceName: mirrorProvider.deviceName,
              OverlayTabHandler.keyDisplayCode:
                  channelProvider.displayCodeWithDash,
              OverlayTabHandler.keyOtpCode: channelProvider.isEyeOpen.value
                  ? channelProvider.otp.value.toString()
                  : 'XXXX',
              OverlayTabHandler.keyLanguage: languageProvider.language,
            });

            channelProvider.addListener(() async {
              await setDeviceNameAndDisplayCode(mirrorProvider.deviceName,
                  channelProvider.displayCodeWithDash);
            });

            mirrorProvider.addListener(() async {
              await setDeviceNameAndDisplayCode(mirrorProvider.deviceName,
                  channelProvider.displayCodeWithDash);
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

            return OverlayTabHandler.resultEmptyString;
        }
        return OverlayTabHandler.resultNullString;
      });
    } else {
      android_window.close();
    }
  }

  Future<void> setDeviceNameAndDisplayCode(
      String deviceName, String displayCode) async {
    await postMessageToAndroidWindow(OverlayTabHandler.nameSetMainInfo, {
      OverlayTabHandler.keyDeviceName: deviceName,
      OverlayTabHandler.keyDisplayCode: displayCode
    });
  }

  Future<void> setOtpCode(String otpCode) async {
    await postMessageToAndroidWindow(
        OverlayTabHandler.nameSetOtp, {OverlayTabHandler.keyOtpCode: otpCode});
  }

  Future<void> setLanguage(String language) async {
    await postMessageToAndroidWindow(OverlayTabHandler.nameSetLanguage,
        {OverlayTabHandler.keyLanguage: language});
  }

  Future<void> launchApp() async {
    await postMessageToAndroidWindow(OverlayTabHandler.nameLaunchApp, {});
  }

  Future<void> postMessageToAndroidWindow(
      String key, Map<String, String> value) async {
    log('overlay tab post message-> key:$key, value:$value');
    if (await android_window.isRunning()) {
      final response = await android_window.post(key, value);
      log('overlay tab response: $response');
    }
  }
}
