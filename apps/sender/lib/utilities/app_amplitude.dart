import 'dart:io';

import 'package:amplitude_flutter/constants.dart';
import 'package:display_cast_flutter/utilities/app_amplitude_api.dart';
import 'package:display_cast_flutter/utilities/app_amplitude_sdk.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:display_cast_flutter/utilities/client_device_info.dart';
import 'package:flutter/foundation.dart';

class AppAmplitude {
  static final AppAmplitude _instance = AppAmplitude._internal();

  // private 'Named constructors'
  AppAmplitude._internal();

  // passes the instantiation to the _instance object
  factory AppAmplitude() => _instance;

  AppAmplitudeImplement? _implement;

  AppAmplitudeImplement _resolveImplement() {
    if (_implement != null) {
      return _implement!;
    }

    if (!kIsWeb && Platform.isWindows) {
      _implement = AppAmplitudeApi();
    } else {
      _implement = AppAmplitudeSdk();
    }
    return _implement!;
  }

  Future<void> ensureInitialized({
    required String apiKey,
    ServerZone? serverZone,
    required String instanceName,
    String? deviceId,
    String? userId,
    String? appVersion,
    ClientDeviceInfo? clientDeviceInfo,
  }) async {
    await _resolveImplement().ensureInitialized(
      apiKey: apiKey,
      serverZone: serverZone,
      instanceName: instanceName,
      deviceId: deviceId,
      userId: userId,
      appVersion: appVersion,
      clientDeviceInfo: clientDeviceInfo,
    );
  }

  void setGlobalProperty(String name, String value) {
    _resolveImplement().setGlobalProperty(name, value);
  }

  void setMode(EventMode? mode) {
    _resolveImplement().setMode(mode);
  }

  Future<void> trackEvent(
    String name,
    EventCategory category, {
    String? target,
    Map<String, dynamic> properties = const <String, dynamic>{},
  }) async {
    await _resolveImplement().trackEvent(
      name,
      category,
      target: target,
      properties: properties,
    );
  }
}

abstract class AppAmplitudeImplement {
  Future<void> ensureInitialized({
    required String apiKey,
    ServerZone? serverZone,
    required String instanceName,
    String? deviceId,
    String? userId,
    String? appVersion,
    ClientDeviceInfo? clientDeviceInfo,
  });

  void setGlobalProperty(String name, String value);

  void setMode(EventMode? mode);

  Future<void> trackEvent(
    String name,
    EventCategory category, {
    String? target,
    Map<String, dynamic> properties = const <String, dynamic>{},
  });
}
