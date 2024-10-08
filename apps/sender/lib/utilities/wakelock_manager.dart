import 'dart:io';
import 'package:display_cast_flutter/utilities/log.dart';
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

  Future<void> _enableWakelock(String message) async {
    if (Platform.isAndroid || Platform.isIOS) {
      return; // TODO: Implement wakelock for Android and iOS
    }
    await WakelockPlus.enable();
    log.info('Wakelock enabled: $message');
  }

  Future<void> _disableWakelock(String message) async {
    if (Platform.isAndroid || Platform.isIOS) {
      return; // TODO: Implement wakelock for Android and iOS
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