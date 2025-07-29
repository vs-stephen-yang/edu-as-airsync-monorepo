abstract class AudioSwitchManager {
  Future<bool> isVirtualAudioMissing();

  Future<int?> getVirtualAudioInputDeviceID();

  Future<bool> switchToVirtualAudioOutput();

  Future<void> restoreToDefaultAudioOutput();
}
