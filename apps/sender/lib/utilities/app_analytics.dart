import 'package:azure_application_insights/azure_application_insights.dart';
import 'package:display_cast_flutter/utilities/client_device_info.dart';
import 'package:http/http.dart';
import 'package:display_cast_flutter/utilities/log.dart';

// https://medium.com/bina-nusantara-it-division/how-to-integrate-flutter-app-with-azure-application-insights-447fcc3bdacf
enum EventCategory {
  system,
  setting,
  session,
  menu,
  annotation,
}

class AppAnalytics {
  TelemetryClient? _client;
  final _globalProperties = <String, String>{};

  // Private constructor
  AppAnalytics._();

  static initializeApp({
    required String instrumentationKey,
    required String ingestionEndpoint,
    String? applicationVersion,
    String? sessionId,
    String? userId,
    ClientDeviceInfo? deviceInfo,
  }) {
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
    String name,
    EventCategory category, {
    String? target,
    Map<String, Object> properties = const <String, Object>{},
  }) {
    log.info('Track event: $name');

    _client?.trackEvent(
      name: name,
      additionalProperties: {
        ...properties,
        ..._globalProperties,
        'category': category.name,
        if (target != null) 'target': target,
      },
    );
  }

  void trackTrace(
    String message, {
    Severity severity = Severity.information,
    Map<String, Object> properties = const <String, Object>{},
  }) {
    _client?.trackTrace(
      severity: severity,
      message: message,
      additionalProperties: {
        ...properties,
        ..._globalProperties,
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
  Map<String, Object> properties = const <String, Object>{},
}) {
  AppAnalytics.instance.trackEvent(
    name,
    category,
    target: target,
    properties: properties,
  );
}

void trackTrace(
  String message, {
  Severity severity = Severity.information,
  Map<String, Object> properties = const <String, Object>{},
}) {
  AppAnalytics.instance.trackTrace(
    message,
    severity: severity,
    properties: properties,
  );
}
