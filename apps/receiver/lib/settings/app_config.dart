import 'package:flutter/material.dart';

class AppConfig extends InheritedWidget {
  const AppConfig(
      {Key? key,
      required this.settings,
      required this.appName,
      required this.appVersion,
      required Widget child})
      : super(key: key, child: child);

  final ConfigSettings settings;
  final String appName;
  final String appVersion;

  static AppConfig? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppConfig>();
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}

abstract class ConfigSettings {
  late String apiGateway;
  late String mainDisplayUrl;
  late String prefixQRCode;
  late String vbsOtaUrl;

  late String icarHostName;
  late String icarRegisterUrl;
  late String icarUpdateUrl;
}
