import 'dart:developer';
import 'dart:io';

import 'package:display_flutter/settings/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_appcenter_bundle/flutter_appcenter_bundle.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppAnalytics {
  static final AppAnalytics _instance = AppAnalytics._internal();

  //private "Named constructors"
  AppAnalytics._internal();

  // passes the instantiation to the _instance object
  factory AppAnalytics() => _instance;

  ensureInitialized(
      ConfigSettings configSettings, PackageInfo packageInfo) async {
    _eventProperties.addAll({
      'version': packageInfo.version,
    });
    _eventNetworkQualityProperties.addAll({
      'version': packageInfo.version,
    });
    if (kIsWeb) {
      // todo: support other platform analytics.
    } else {
      if (Platform.isAndroid || Platform.isIOS) {
        await AppCenter.startAsync(
          appSecretAndroid: configSettings.appSecretAndroid,
          appSecretIOS: configSettings.appSecretIOS,
          enableAnalytics: true,
          enableCrashes: true,
          enableDistribute: false,
        );
        _instance._isInitialized = true;
      } else {
        // todo: support other platform analytics.
      }
    }
  }

  bool _isInitialized = false;
  final Map<String, String> _eventProperties = {};
  final Map<String, String> _eventNetworkQualityProperties = {};

  setEventProperties(Map<String, String> properties) {
    _eventProperties.addAll(properties);
    _eventNetworkQualityProperties.addAll(properties);
  }

  trackEventAppStarted() {
    _trackEventWithProperties('appStarted', _eventProperties);
  }

  trackEventAppTerminated() {
    _trackEventWithProperties('appTerminated', _eventProperties);
  }

  trackEventMaskOTPCode() {
    _trackEventWithProperties('maskOTPCode', _eventProperties);
  }

  trackEventUnMaskOTPCode() {
    _trackEventWithProperties('unmaskOTPCode', _eventProperties);
  }

  trackEventNetworkQuality() {
    _trackEventWithProperties('networkQuality', _eventNetworkQualityProperties);
  }

  trackEventPresentStart() {
    _trackEventWithProperties('presentStart', _eventProperties);
  }

  trackEventPresentPaused() {
    _trackEventWithProperties('presentPaused', _eventProperties);
  }

  trackEventPresentResumed() {
    _trackEventWithProperties('presentResumed', _eventProperties);
  }

  trackEventPresentStopped() {
    _trackEventWithProperties('presentStopped', _eventProperties);
  }

  trackEventPresentTimeout() {
    _trackEventWithProperties('presentTimeout', _eventProperties);
  }

  _trackEventWithProperties(String event, Map<String, String> properties) {
    if (_isInitialized) {
      log('event: $event, properties: $properties');
      AppCenter.trackEventAsync(event, properties);
    }
  }
}
