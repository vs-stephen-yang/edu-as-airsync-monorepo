
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

class AudioSwitch {
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
}