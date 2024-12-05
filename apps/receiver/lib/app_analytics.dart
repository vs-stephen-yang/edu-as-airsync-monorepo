import 'dart:async';

import 'package:azure_application_insights/azure_application_insights.dart';
import 'package:display_flutter/utility/client_device_info.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:display_flutter/vsapi/vs_api.dart';
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
  static VSApi? _vsApi;

  // Private constructor
  AppAnalytics._();

  static Future<void> initializeApp({
    required String instrumentationKey,
    required String ingestionEndpoint,
    required VSApi? vsApi,
    String? applicationVersion,
    String? sessionId,
    String? userId,
    ClientDeviceInfo? deviceInfo,
  }) async {
    final processor = BufferedProcessor(
      next: TransmissionProcessor(
        instrumentationKey: instrumentationKey,
        ingestionEndpoint: ingestionEndpoint,
        httpClient: Client(),
        timeout: const Duration(seconds: 10),
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

    _vsApi = vsApi;

    final serialNumber = await _vsApi?.getSerialNumber();
    if (serialNumber != null) {
      instance.setGlobalProperty('serial_number', serialNumber);
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
    Map<String, Object> properties = const <String, Object>{},
  }) {
    log.info('Track event: $name');

    if (_vsApi == null) {
      _client?.trackEvent(
        name: name,
        additionalProperties: {
          ...properties,
          ..._globalProperties,
        },
      );
    } else {
      unawaited(_vsApi!.getCurrentMacAddress().then((macAddress) {
        _client?.trackEvent(
          name: name,
          additionalProperties: {
            ...properties,
            ..._globalProperties,
            'mac_address': macAddress,
          },
        );
      }));
    }
  }

  void trackTrace(
    String message, {
    Severity severity = Severity.information,
    Map<String, Object> properties = const <String, Object>{},
  }) {
    if (_vsApi == null) {
      _client?.trackTrace(
        severity: severity,
        message: message,
        additionalProperties: {
          ...properties,
          ..._globalProperties,
        },
      );
    } else {
      unawaited(_vsApi!.getCurrentMacAddress().then((macAddress) {
        _client?.trackTrace(
          severity: severity,
          message: message,
          additionalProperties: {
            ...properties,
            ..._globalProperties,
            'mac_address': macAddress,
          },
        );
      }));
    }
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
  String? mode,
  Map<String, Object> properties = const <String, Object>{},
}) {
  AppAnalytics.instance.trackEvent(name, properties: {
    ...properties,
    ...{
      'category': category.name,
      if (target != null) 'target': target,
      if (participatorId != null) 'participator_id': participatorId,
      if (mode != null) 'mode': mode,
    },
  });
}

void trackTrace(
  String message, {
  String? target,
  Severity severity = Severity.information,
  Map<String, Object> properties = const <String, Object>{},
}) {
  AppAnalytics.instance.trackTrace(
    message,
    severity: severity,
    properties: {
      ...properties,
      if (target != null) 'target': target,
    },
  );
}
