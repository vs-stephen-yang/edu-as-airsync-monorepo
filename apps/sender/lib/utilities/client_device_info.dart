import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class ClientDeviceInfo {
  String clientType;
  String? locale;
  String? clientModel;
  String? clientOs;

  ClientDeviceInfo(
    this.clientType,
    this.locale,
    this.clientModel,
    this.clientOs,
  );

  static Future<ClientDeviceInfo?> fetch() async {
    final deviceInfo = DeviceInfoPlugin();

    if (kIsWeb) {
      final info = await deviceInfo.webBrowserInfo;
      return fetchWeb(info);
    }

    if (Platform.isAndroid) {
      // android
      final info = await deviceInfo.androidInfo;
      return fetchAndroid(info);
    } else if (Platform.isIOS) {
      // ios
      final info = await deviceInfo.iosInfo;
      return fetchIos(info);
    } else if (Platform.isMacOS) {
      // macos
      final info = await deviceInfo.macOsInfo;
      return fetchMacOs(info);
    } else if (Platform.isWindows) {
      // windows
      final info = await deviceInfo.windowsInfo;
      return fetchWindows(info);
    } else {
      return null;
    }
  }

  static ClientDeviceInfo fetchWeb(WebBrowserInfo info) {
    return ClientDeviceInfo(
      'web',
      info.language,
      null,
      null,
    );
  }

  static ClientDeviceInfo fetchAndroid(AndroidDeviceInfo info) {
    return ClientDeviceInfo(
      'Android',
      Platform.localeName,
      info.model,
      'Android ${info.version.release}',
    );
  }

  static ClientDeviceInfo fetchIos(IosDeviceInfo info) {
    return ClientDeviceInfo(
      'iOS',
      Platform.localeName,
      info.model,
      'iOS ${info.systemVersion}',
    );
  }

  static ClientDeviceInfo fetchWindows(WindowsDeviceInfo info) {
    return ClientDeviceInfo(
      'Windows',
      Platform.localeName,
      info.editionId,
      'Windows ${info.majorVersion}.${info.minorVersion}.${info.buildNumber}',
    );
  }

  static ClientDeviceInfo fetchMacOs(MacOsDeviceInfo info) {
    return ClientDeviceInfo(
      'Mac',
      Platform.localeName,
      info.model,
      'macOS ${info.osRelease}',
    );
  }
}
