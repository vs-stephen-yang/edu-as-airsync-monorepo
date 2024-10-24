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
    // Wakelock works well on macOS, Windows, and Web, but on Android and iOS,
    // it only functions when the app is in the foreground.
    await WakelockPlus.enable();
    log.info('Wakelock enabled: $message');
  }

  Future<void> _disableWakelock(String message) async {
    // Wakelock works well on macOS, Windows, and Web, but on Android and iOS,
    // it only functions when the app is in the foreground.
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