
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

class AudioSwitch {

  static AudioSwitch _instance = AudioSwitch._internal();

  static AudioSwitch getInstance() {
    return _instance;
  }

  AudioSwitch._internal();

  final MethodChannel _channel = MethodChannel("audio_switch_channel");

  int? originalInputDevice, originalOutputDevice;

  Future<bool> checkAirSyncAudio() async {
    bool hasAirSyncInputDevice = await hasInputDevice('AirSyncAudio');
    bool hasAirSyncOutputDevice = await hasOutputDevice('AirSyncAudio');
    print('zz checkAirSyncAudio in:$hasAirSyncInputDevice out:$hasAirSyncOutputDevice');
    return hasAirSyncInputDevice && hasAirSyncOutputDevice;
  }

  Future<void> rememberOriginalDevice() async {
    originalInputDevice = await getDefaultInputDevice();
    originalOutputDevice = await getDefaultOutputDevice();
  }

  Future<void> setAirSyncAudio() async {
    int inputDeviceID = await getInputDeviceByName('AirSyncAudio');
    int outputDeviceID = await getOutputDeviceByName('AirSyncAudio');

    bool a = await setInputDevice(inputDeviceID);
    bool b = await setOutputDevice(outputDeviceID);
    print('zz setAirSyncAudio $a $b');
  }

  Future<void> restoreOriginalDevice() async {
    if (originalInputDevice != null && originalOutputDevice != null) {
      await setInputDevice(originalInputDevice!);
      await setOutputDevice(originalOutputDevice!);
    }
  }

  bool isSupported() {
    return !kIsWeb && Platform.isMacOS;
  }

   Future<int> getDefaultInputDevice() async {
    return await _channel.invokeMethod('getDefaultInputDevice');
  }

   Future<int> getDefaultOutputDevice() async {
    return await _channel.invokeMethod('getDefaultOutputDevice');
  }

   Future<int> getInputDeviceByName(String name) async {
    return await _channel.invokeMethod('getInputDeviceByName', name);
  }

   Future<int> getOutputDeviceByName(String name) async {
    return await _channel.invokeMethod('getOutputDeviceByName', name);
  }

   Future<bool> hasInputDevice(String name) async {
    return await _channel.invokeMethod('hasInputDevice', name);
  }

   Future<bool> hasOutputDevice(String name) async {
    return await _channel.invokeMethod('hasOutputDevice', name);
  }

   Future<bool> setInputDevice(int deviceID) async {
    return await _channel.invokeMethod('setInputDevice', deviceID);
  }

   Future<bool> setOutputDevice(int deviceID) async {
    return await _channel.invokeMethod('setOutputDevice', deviceID);
  }
}