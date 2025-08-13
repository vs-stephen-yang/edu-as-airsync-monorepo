import 'dart:io';
import 'dart:ui';

import 'package:flutter_multicast_plugin/flutter_multicast_plugin.dart';
import 'package:window_size/window_size.dart';

enum IonResolutionType {
  hd,
  fhd,
}

const deviceResolutionsMap = <String, IonResolutionType>{
  'CDE30': IonResolutionType.hd,
  // NOTE: see device_feature_adapter.dart's deviceOptions
};

IonResolutionType getCaptureVideoResolution(
  String? deviceType,
  double screenWidth,
  double screenHeight,
) {
  final resolutionType = deviceResolutionsMap[deviceType];
  if (resolutionType != null) {
    return resolutionType;
  }

  const fullHd = 1080.0;

  if (screenHeight / 2 >= fullHd) {
    return IonResolutionType.fhd;
  } else {
    return IonResolutionType.hd;
  }
}

const multicastDeviceResolutionsMap = <String, Resolution>{};

Resolution getMulticastCaptureVideoResolution(
  String? deviceType,
  double screenWidth,
  double screenHeight,
) {
  final resolutionType = multicastDeviceResolutionsMap[deviceType];
  if (resolutionType != null) {
    return resolutionType;
  }

  const fullHd = 1080.0;

  if (screenHeight / 2 >= fullHd) {
    return Resolution.fhd;
  } else {
    return Resolution.hd;
  }
}

const defaultScreenWidth = 3840.0;
const defaultScreenHeight = 2160.0;

Future<(double, double)> updateScreenSize() async {
  if (Platform.isWindows) {
    // PlatformDispatcher did not support get windows width and height yet.
    // Using window_size for workaround.
    // https://github.com/flutter/flutter/issues/125938
    // https://github.com/flutter/flutter/issues/125939
    // todo: tracking issue status to remove this workaround.
    Screen? screen = await getCurrentScreen();
    if (screen != null) {
      final screenWidth = screen.frame.width;
      final screenHeight = screen.frame.height;
      return (screenWidth, screenHeight);
    }
  } else {
    final screenWidth = PlatformDispatcher.instance.displays.first.size.width;
    final screenHeight = PlatformDispatcher.instance.displays.first.size.height;
    return (screenWidth, screenHeight);
  }
  return (defaultScreenWidth, defaultScreenHeight);
}
