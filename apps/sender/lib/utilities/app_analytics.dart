import 'package:azure_application_insights/azure_application_insights.dart';
import 'package:http/http.dart';

// https://medium.com/bina-nusantara-it-division/how-to-integrate-flutter-app-with-azure-application-insights-447fcc3bdacf
class AppAnalytics {
  TelemetryClient? _client;

  // Private constructor
  AppAnalytics._();

  static initializeApp({
    required String instrumentationKey,
    String? applicationVersion,
    String? locale,
    String? sessionId,
  }) {
    final processor = BufferedProcessor(
      next: TransmissionProcessor(
        instrumentationKey: instrumentationKey,
        httpClient: Client(),
        timeout: const Duration(seconds: 10),
      ),
    );

    final context = TelemetryContext();
    context
      ..applicationVersion = applicationVersion
      ..session.sessionId = sessionId
      ..device.locale = locale;

    instance._client = TelemetryClient(
      processor: processor,
      context: context,
    );
  }

  // Singleton instance variable
  static final AppAnalytics _instance = AppAnalytics._();

  // Getter to access the singleton instance
  static AppAnalytics get instance => _instance;

  // Log business events
  // Typically it is a user interaction such as button click or order checkout.
  // It can also be an application life cycle event like initialization or configuration update.
  void trackEvent(
    String name, {
    Map<String, Object> properties = const <String, Object>{},
  }) {
    instance._client?.trackEvent(
      name: name,
      additionalProperties: properties,
    );
  }

  void trackTrace(String message, Severity severity) {
    instance._client?.trackTrace(
      severity: severity,
      message: message,
    );
  }

  void trackPageView(String name) {
    instance._client?.trackPageView(name: name);
  }
}
