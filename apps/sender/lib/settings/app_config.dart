import 'package:display_cast_flutter/model/profile.dart';
import 'package:flutter/material.dart';

class AppConfig extends InheritedWidget {
  const AppConfig(
      {super.key,
      required this.settings,
      required this.profileStore,
      required String appName,
      required String appVersion,
      required super.child})
      : _appName = appName,
        _appVersion = appVersion;

  final ConfigSettings settings;

  final String _appName;

  final String _appVersion;

  final ProfileStore profileStore;

  get appName => _appName;

  get appVersion => _appVersion + settings.versionPostfix;

  static AppConfig? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppConfig>();
  }

  final int platformDirectPort = 5100;
  final int webTransportPort = 8001;

  final String feedbackUrl = 'https://forms.office.com/r/HsuEUMPCU2';

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
  late final String envName;
  late final String versionPostfix;

  // Sentry
  late SentryConfig? sentry;

  late String baseApiUrl;

  // App Insights
  late String appInsightsInstrumentationKey;

  late String appInsightsIngestionEndpoint;

  late String appUpdateVersionEndpoint;
  late String appStoreUrl;
  late String appUpdateMacAppcastUrl;
  late String storeMobileUrl;

  late bool appA11yDebug;
}
