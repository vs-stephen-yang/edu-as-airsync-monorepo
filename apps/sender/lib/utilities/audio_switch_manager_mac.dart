import 'package:display_cast_flutter/utilities/audio_switch_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

import 'log.dart';

class AudioSwitch  {
  AudioSwitch._();

  static const MethodChannel _channel = MethodChannel("audio_switch_channel");

  static bool isSupported() {
    return !kIsWeb && Platform.isMacOS;
  }

  static Future<int> getDefaultInputDevice() async {
    return await _channel.invokeMethod('getDefaultInputDevice');
  }

  static Future<int> getDefaultOutputDevice() async {
    return await _channel.invokeMethod('getDefaultOutputDevice');
  }

  static Future<int> getInputDeviceByName(String name) async {
    return await _channel.invokeMethod('getInputDeviceByName', name);
  }

  static Future<int> getOutputDeviceByName(String name) async {
    return await _channel.invokeMethod('getOutputDeviceByName', name);
  }

  static Future<bool> hasInputDevice(String name) async {
    return await _channel.invokeMethod('hasInputDevice', name);
  }

  static Future<bool> hasOutputDevice(String name) async {
    return await _channel.invokeMethod('hasOutputDevice', name);
  }

  static Future<bool> setInputDevice(int deviceID) async {
    return await _channel.invokeMethod('setInputDevice', deviceID);
  }

  static Future<bool> setOutputDevice(int deviceID) async {
    return await _channel.invokeMethod('setOutputDevice', deviceID);
  }

  static Future<Map<String, dynamic>?> getPairedVirtualAudioDevice() async {
    final result = await _channel.invokeMethod<Map>('getPairedVirtualAudioDevice');
    return result == null ? null : Map<String, dynamic>.from(result);
  }
}

class AudioSwitchManagerMac implements AudioSwitchManager {
  int? _defaultOutputDeviceID;
  Map<String, dynamic>? _currentVirtualAudioDevice;


  Future<Map<String, dynamic>?> _checkVirtualAudioDevice() async {
    final virtualDevice = await AudioSwitch.getPairedVirtualAudioDevice();
    if (virtualDevice == null) {
      return null;
    }
    return {
      'inputDeviceID': virtualDevice['inputDeviceID'] as int,
      'outputDeviceID': virtualDevice['outputDeviceID'] as int,
      'deviceName': virtualDevice['deviceName'] as String,
    };
  }

  Future<bool> _saveDefaultAudioOutput() async {
    _defaultOutputDeviceID = await AudioSwitch.getDefaultOutputDevice();
    if (_defaultOutputDeviceID == null) {
      log.info('Failed to get default output device');
      return false;
    }
    _currentVirtualAudioDevice = await _checkVirtualAudioDevice();
    if (_currentVirtualAudioDevice == null) {
      log.info('Failed to get virtual audio device');
      return false;
    }
    String deviceName = _currentVirtualAudioDevice!['deviceName'];
    log.info('default output device: $_defaultOutputDeviceID virtual audio device: $deviceName');
    return true;
  }

  @override
  Future<bool> hasVirtualAudioDevice() async {
    return await _checkVirtualAudioDevice() != null;
  }

  @override
  Future<int?> getVirtualAudioInputDeviceID() async {
    if (_currentVirtualAudioDevice != null) {
      return _currentVirtualAudioDevice!['inputDeviceID'];
    }
    return null;
  }

  @override
  Future<bool> switchToVirtualAudioOutput() async {
    if (!await _saveDefaultAudioOutput()) {
      return false;
    }
    if (_defaultOutputDeviceID == null || _currentVirtualAudioDevice == null) {
      return false;
    }
    final outputDeviceID = _currentVirtualAudioDevice!['outputDeviceID'];
    return await AudioSwitch.setOutputDevice(outputDeviceID!);
  }

  @override
  Future<void> restoreToDefaultAudioOutput() async {
    if (_defaultOutputDeviceID != null) {
      await AudioSwitch.setOutputDevice(_defaultOutputDeviceID!);
    }
    _defaultOutputDeviceID = null;
    _currentVirtualAudioDevice = null;
  }
}
