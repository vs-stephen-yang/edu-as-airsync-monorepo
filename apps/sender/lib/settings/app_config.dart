import 'package:display_cast_flutter/model/profile.dart';

class AppConfig {
  AppConfig({
    required this.settings,
    required this.profileStore,
    required String appName,
    required String appVersion,
  })  : _appName = appName,
        _appVersion = appVersion;

  final ConfigSettings settings;

  final String _appName;

  final String _appVersion;

  final ProfileStore profileStore;

  String get appName => _appName;

  String get appVersion => _appVersion + settings.versionPostfix;

  static const int platformDirectPort = 5100;
  static const int webTransportPort = 8001;

  final String feedbackUrl = 'https://forms.office.com/r/HsuEUMPCU2';

  final String enKnowledgeBaseUrl =
      'https://www.viewsonic.com/solution/kb/en_US/airsync-overview/airsync';
  final String zhKnowledgeBaseUrl =
      'https://www.viewsonic.com/solution/kb/t_CN/airsync-overview/airsync';
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
  late final String envName;
  late final String versionPostfix;

  // Sentry
  late SentryConfig? sentry;

  late String baseApiUrl;

  // App Insights
  late String appInsightsInstrumentationKey;

  late String appInsightsIngestionEndpoint;

  // Amplitude
  late String appAmplitudeKey;

  late String appUpdateVersionEndpoint;
  late String appStoreUrl;
  late String appUpdateMacAppcastUrl;
  late String storeMobileUrl;

  late bool appA11yDebug;
}
