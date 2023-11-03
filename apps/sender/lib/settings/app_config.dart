import 'package:flutter/material.dart';

class AppConfig extends InheritedWidget {
  const AppConfig(
      {super.key,
      required this.settings,
      required String appName,
      required String appVersion,
      required super.child})
      : _appName = appName,
        _appVersion = appVersion;

  final ConfigSettings settings;

  final String _appName;

  final String _appVersion;

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

  late String urlGateway;
  late String urlGetIce;
}
