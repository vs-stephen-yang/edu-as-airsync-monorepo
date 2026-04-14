import 'dart:io';
import 'package:display_cast_flutter/utilities/audio_switch_manager.dart';
import 'package:display_cast_flutter/utilities/audio_switch_manager_mac.dart';
import 'package:display_cast_flutter/utilities/audio_switch_manager_win.dart';
import 'package:flutter/foundation.dart';

AudioSwitchManager createAudioSwitchManager() {
  if (kIsWeb) {
    return AudioSwitchManagerStub();
  }

  if (Platform.isMacOS) {
    return AudioSwitchManagerMac();
  }

  if (Platform.isWindows) {
    return AudioSwitchManagerWin();
  }

  return AudioSwitchManagerStub();
}

class AudioSwitchManagerStub implements AudioSwitchManager {
  @override
  Future<bool> isVirtualAudioMissing() async {
    return false;
  }

  @override
  Future<int?> getVirtualAudioInputDeviceID() async {
    return null;
  }

  @override
  Future<bool> switchToVirtualAudioOutput() async {
    return true;
  }

  @override
  Future<void> restoreToDefaultAudioOutput() async {}
}
