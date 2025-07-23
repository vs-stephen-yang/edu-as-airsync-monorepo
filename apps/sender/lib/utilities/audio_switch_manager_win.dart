import 'package:display_cast_flutter/utilities/audio_switch_manager.dart';
import 'package:display_cast_flutter/utilities/log.dart';
import 'package:win32audio/win32audio.dart';

class AudioSwitchManagerWin implements AudioSwitchManager {
  AudioDevice? _originalOutputDevice;

  // https://viewsonic-ssi.visualstudio.com/Display%20App/_git/virtual-audio-cable?path=/airsyncaudio.inf
  // The name of the virtual audio device is defined in the inf file in virtual-audio-cable
  static final String _virtualAudioName = "AirSync Audio";

  @override
  Future<bool> hasVirtualAudioDevice() async {
    return true;
  }

  @override
  Future<int?> getVirtualAudioInputDeviceID() async {
    return null;
  }

  Future<AudioDevice?> findVirtualAudioOutput(String name) async {
    final devices = await Audio.enumDevices(AudioDeviceType.output);
    if (devices == null) {
      return null;
    }

    final matches = devices.where(
      (device) => device.name.contains(name),
    );

    return matches.isNotEmpty ? matches.first : null;
  }

  @override
  Future<bool> switchToVirtualAudioOutput() async {
    // Prevent duplicate switch if virtual output is already active
    if (_originalOutputDevice != null) {
      return true;
    }

    _originalOutputDevice = await Audio.getDefaultDevice(
      AudioDeviceType.output,
      audioRole: AudioRole.multimedia,
    );
    log.info("Current default audio output: ${_originalOutputDevice?.name}");

    log.info("Switching default audio output to $_virtualAudioName");

    final virtualAudioOutput = await findVirtualAudioOutput(_virtualAudioName);

    if (virtualAudioOutput == null) {
      log.warning("Do not find virtual audio output device $_virtualAudioName");
      return false;
    }

    try {
      await Audio.setDefaultDevice(virtualAudioOutput.id, multimedia: true);
    } catch (e) {
      log.warning('Failed to set default audio output', e);
      return false;
    }

    return true;
  }

  @override
  Future<void> restoreToDefaultAudioOutput() async {
    if (_originalOutputDevice == null) {
      return;
    }

    log.info(
        "Restoring default audio output to ${_originalOutputDevice!.name}");

    try {
      await Audio.setDefaultDevice(
        _originalOutputDevice!.id,
        multimedia: true,
      );
    } catch (e) {
      log.warning('Failed to set default audio output', e);
      return;
    }

    _originalOutputDevice = null;
  }
}
