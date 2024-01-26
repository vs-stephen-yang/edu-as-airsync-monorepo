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

abstract class ConfigSettings {
  late bool isDevelopEnvironment;

  late String apiGateway;
  late String getIceServer;
  late String mainDisplayUrl;
  late String prefixQRCode;

  late String appSecretAndroid;
  late String appSecretIOS;

  late String icarHostName;
  late String icarRegisterUrl;
  late String icarUpdateUrl;
  late String icarExceptionUrl;
  late String icarExceptionFileUrl;
}
