import 'package:flutter/material.dart';
import 'package:display_cast_flutter/model/profile.dart';

class AppConfig extends InheritedWidget {
  const AppConfig(
      {super.key,
      required this.settings,
      required this.profile,
      required String appName,
      required String appVersion,
      required super.child})
      : _appName = appName,
        _appVersion = appVersion;

  final ConfigSettings settings;

  final String _appName;

  final String _appVersion;

  final Profile profile;

  get appName => _appName;

  get appVersion => _appVersion + settings.versionPostfix;

  static AppConfig? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppConfig>();
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}

abstract class ConfigSettings {
  late final String envName;
  late final String versionPostfix;
  late final String selectedProfile;

  late String urlGateway;

  // App Insights
  late String appInsightsInstrumentationKey;

  late String appInsightsIngestionEndpoint;

  late String appUpdateVersionEndpoint;
}
