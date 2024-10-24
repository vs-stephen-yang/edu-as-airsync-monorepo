import 'dart:io';

import 'package:display_cast_flutter/utilities/log.dart';
import 'package:flutter/foundation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

enum AppScene {
  rtcPublishing,
  rtcHangUp,
  rtcRemoteScreenDisplaying,
  rtcRemoteScreenHangUp,
}

class WakelockManager {
  static final WakelockManager _instance = WakelockManager._internal();

  factory WakelockManager() {
    return _instance;
  }

  WakelockManager._internal();

  bool _isSupported() {
    // see https://viewsonic-ssi.visualstudio.com/Display%20App/_workitems/edit/72687/
    // Currently, we only apply wakelock on macOS, Windows, and Web.
    return kIsWeb || Platform.isMacOS || Platform.isWindows;
  }

  Future<void> _enableWakelock(String message) async {
    if (!_isSupported()) {
      log.info('Wakelock is not supported on this platform: $message');
      return;
    }
    await WakelockPlus.enable();
    log.info('Wakelock enabled: $message');
  }

  Future<void> _disableWakelock(String message) async {
    if (!_isSupported()) {
      log.info('Wakelock is not supported on this platform: $message');
      return;
    }
    await WakelockPlus.disable();
    log.info('Wakelock disabled: $message');
  }

  Future<void> manageWakelock(AppScene appScene) async {
    switch (appScene) {
      case AppScene.rtcHangUp:
      case AppScene.rtcRemoteScreenHangUp:
        await _disableWakelock(appScene.toString());
        break;
      case AppScene.rtcPublishing:
      case AppScene.rtcRemoteScreenDisplaying:
        await _enableWakelock(appScene.toString());
        break;
    }
  }
}