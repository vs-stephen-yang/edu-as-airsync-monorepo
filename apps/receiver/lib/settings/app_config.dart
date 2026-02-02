import 'package:flutter/material.dart';

class AppConfig extends InheritedWidget {
  const AppConfig(
      {super.key,
      required this.settings,
      required this.appName,
      required this.appVersion,
      required super.child});

  final ConfigSettings settings;
  final String appName;
  final String appVersion;

  static AppConfig? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppConfig>();
  }

  final int webTransportServerPort = 8001;

  final String enKnowledgeBaseUrl =
      'https://www.viewsonic.com/solution/kb/en_US/airsync-overview/airsync';
  final String zhKnowledgeBaseUrl =
      'https://www.viewsonic.com/solution/kb/t_CN/airsync-overview/airsync';

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}

class SentryConfig {
  String environment;
  String dsn;
  double tracesSampleRate;

  SentryConfig({
    required this.dsn,
    required this.environment,
    required this.tracesSampleRate,
  });
}

abstract class ConfigSettings {
  late bool isDevelopEnvironment;

  // Sentry
  late SentryConfig? sentry;

  late String baseApiUrl;

  // Azure Application Insights
  late String instrumentationKey;
  late String ingestionEndpoint;

  // Amplitude
  late String appAmplitudeKey;

  // Backdoor OTP. For development only.
  late String? defaultOtp;

  late String airSyncUrl;
  late String appStoreUrl;
  late String storeMobileUrl;

  // Accessibility. For development only.
  late bool? appA11yDebug;

  // Amplify Firehose
  late String amplifyRegion;
  late String amplifyIdentityPoolId;
  late String firehoseStreamName;
}
