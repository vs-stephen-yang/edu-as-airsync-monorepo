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

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}

class SentryConfig {
  String environment;
  String dsn;

  SentryConfig({
    required this.dsn,
    required this.environment,
  });
}

abstract class ConfigSettings {
  late bool isDevelopEnvironment;

  // Sentry
  late SentryConfig sentry;

  late String baseApiUrl;
  late String getIceServer;

  late String appSecretAndroid;
  late String appSecretIOS;

  // Azure Application Insights
  late String instrumentationKey;
  late String ingestionEndpoint;

  // Backdoor OTP. For development only.
  late String? defaultOtp;

  late String icarHostName;
  late String icarRegisterUrl;
  late String icarUpdateUrl;
  late String icarExceptionUrl;
  late String icarExceptionFileUrl;

  late String airSyncUrl;
  late String appStoreUrl;
}
