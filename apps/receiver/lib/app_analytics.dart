import 'dart:async';

import 'package:azure_application_insights/azure_application_insights.dart';
import 'package:display_flutter/utility/app_amplitude.dart';
import 'package:display_flutter/utility/caching_http_client.dart';
import 'package:display_flutter/utility/client_device_info.dart';
import 'package:display_flutter/utility/device_feature_adapter.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:display_flutter/utility/offline_http_client.dart';
import 'package:http/http.dart';

// https://medium.com/bina-nusantara-it-division/how-to-integrate-flutter-app-with-azure-application-insights-447fcc3bdacf
enum EventCategory {
  system,
  setting,
  session,
  menu,
  quickMenu,
  annotation,
  castToBoards,
}

class AppAnalytics {
  TelemetryClient? _client;
  final _globalProperties = <String, String>{};

  // Private constructor
  AppAnalytics._();

  static Future<void> initializeApp({
    required String instrumentationKey,
    required String ingestionEndpoint,
    String? applicationVersion,
    String? sessionId,
    String? userId,
    ClientDeviceInfo? deviceInfo,
    String? serialNumber,
    String? macAddress,
  }) async {
    const timeout = Duration(seconds: 10);

    final cachingClient = CachingHttpClient(
      innerClient: Client(),
      requestTimeout: timeout,
    );

    final processor = BufferedProcessor(
      next: TransmissionProcessor(
        instrumentationKey: instrumentationKey,
        ingestionEndpoint: ingestionEndpoint,
        httpClient: OfflineHttpClient(cachingClient),
        timeout: timeout,
      ),
    );

    final context = TelemetryContext();
    context
      ..applicationVersion = applicationVersion
      ..session.sessionId = sessionId
      ..user.id = userId;

    if (deviceInfo != null) {
      context.device
        ..locale = deviceInfo.locale
        ..type = deviceInfo.clientType
        ..osVersion = deviceInfo.clientOs
        ..model = deviceInfo.clientModel;
    }

    instance._client = TelemetryClient(
      processor: processor,
      context: context,
    );

    if (userId != null) {
      instance.setGlobalProperty('instance_id', userId);
    }

    if (sessionId != null) {
      instance.setGlobalProperty('session_id', sessionId);
    }

    if (serialNumber != null) {
      instance.setGlobalProperty('serial_number', serialNumber);
    }

    if (macAddress != null) {
      instance.setGlobalProperty('mac_address', macAddress);
    }
  }

  // Singleton instance variable
  static final AppAnalytics _instance = AppAnalytics._();

  // Getter to access the singleton instance
  static AppAnalytics get instance => _instance;

  void setGlobalProperty(String name, String value) {
    _globalProperties[name] = value;
  }

  // Log business events
// Typically it is a user interaction such as button click or order checkout.
// It can also be an application life cycle event like initialization or configuration update.
  void trackEvent(
    String name, {
    String? userId,
    Map<String, Object> properties = const <String, Object>{},
  }) {
    log.info('Track event: $name');

    _client?.trackEvent(
      name: name,
      additionalProperties: {
        ...properties,
        ..._globalProperties,
        if (userId != null) 'user_id': userId,
      },
    );
  }

  void trackTrace(
    String message, {
    String? userId,
    Severity severity = Severity.information,
    Map<String, Object> properties = const <String, Object>{},
  }) {
    _client?.trackTrace(
      severity: severity,
      message: message,
      additionalProperties: {
        ...properties,
        ..._globalProperties,
        if (userId != null) 'user_id': userId,
      },
    );
  }

  void trackPageView(String name) {
    instance._client?.trackPageView(name: name);
  }
}

void trackEvent(
  String name,
  EventCategory category, {
  String? target,
  String? participatorId,
  String? userId,
  String? mode,
  Map<String, Object> properties = const <String, Object>{},
}) {
  AppAnalytics.instance.trackEvent(
    name,
    userId: userId,
    properties: {
      ...properties,
      ...{
        'category': category.name,
        if (target != null) 'target': target,
        if (participatorId != null) 'participator_id': participatorId,
        if (mode != null) 'mode': mode,
        if (DeviceFeatureAdapter.roomNumber.isNotEmpty)
          'room_number': DeviceFeatureAdapter.roomNumber,
      },
    },
  );

  AppAmplitude().trackEvent(
    name,
    userId: userId,
    properties: {
      ...properties,
      ...{
        'category': category.name,
        if (target != null) 'target': target,
        if (participatorId != null) 'participator_id': participatorId,
        if (mode != null) 'mode': mode,
        if (DeviceFeatureAdapter.roomNumber.isNotEmpty)
          'room_number': DeviceFeatureAdapter.roomNumber,
      },
    },
  );
}

void trackTrace(
  String message, {
  String? target,
  String? userId,
  Severity severity = Severity.information,
  Map<String, Object> properties = const <String, Object>{},
}) {
  AppAnalytics.instance.trackTrace(
    message,
    userId: userId,
    severity: severity,
    properties: {
      ...properties,
      if (target != null) 'target': target,
    },
  );
}
