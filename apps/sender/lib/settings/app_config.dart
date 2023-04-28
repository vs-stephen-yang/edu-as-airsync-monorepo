import 'package:flutter/material.dart';

class AppConfig extends InheritedWidget {
  const AppConfig(
      {Key? key,
      required this.settings,
      required String appName,
      required String appVersion,
      required int appVersionCode,
      required Widget child})
      : _appName = appName,
        _appVersion = appVersion,
        _appVersionCode = appVersionCode,
        super(key: key, child: child);

  final ConfigSettings settings;

  final String _appName;

  final String _appVersion;

  final int _appVersionCode;

  get appName => _appName;

  get appVersion => _appVersion + settings.versionPostfix;

  get appVersionCode => _appVersionCode;

  static AppConfig? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppConfig>();
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}

abstract class ConfigSettings {
  late final String envName;
  late final String versionPostfix;
}
