import 'dart:convert';
import 'dart:io' show HttpStatus, Platform;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

enum CompareVersionResult{
  forceUpgrade,
  userChoose,
  none
}

CompareVersionResult compareVersion(
    String currentVersion, String targetVersion, String minVersion) {
  List<int> current =
      currentVersion.split('-').first.split('.').map(int.parse).toList();
  List<int> target = targetVersion.split('.').map(int.parse).toList();
  List<int> min = minVersion.split('.').map(int.parse).toList();
  CompareVersionResult result = CompareVersionResult.none;

  for (int i = 0; i < min.length; i++) {
    if (min[i] > current[i]) {
      return CompareVersionResult.forceUpgrade;
    }
    if (min[i] != current[i]) break;
  }

  for (int i = 0; i < target.length; i++) {
    if (target[i] > current[i]) {
      return CompareVersionResult.userChoose;
    }
    if (target[i] != current[i]) break;
  }
  return result;
}

Future<CompareVersionResult> getVersion(String url, String currentVersion) async {
  try {
    http.Response response = await http.get(
      Uri.parse(url),
    );

    if (response.statusCode >= HttpStatus.ok && response.statusCode < HttpStatus.multiStatus) {
      Map json = jsonDecode(response.body);
      String targetVersion = '';
      String minSupportedVersion = '';
      if (Platform.isAndroid) {
        targetVersion = json['android']['target-version'];
        minSupportedVersion = json['android']['min-supported-version'];
      } else if (Platform.isIOS) {
        targetVersion = json['ios']['target-version'];
        minSupportedVersion = json['ios']['min-supported-version'];
      } else if (Platform.isMacOS) {
        targetVersion = json['macos']['target-version'];
        minSupportedVersion = json['macos']['min-supported-version'];
      } else if (Platform.isWindows) {
        targetVersion = json['windows']['target-version'];
        minSupportedVersion = json['windows']['min-supported-version'];
      } else if (kIsWeb) {
        targetVersion = json['web']['target-version'];
        minSupportedVersion = json['web']['min-supported-version'];
      }

      return compareVersion(currentVersion, targetVersion, minSupportedVersion);
    }
  } catch (e) {
    debugPrint('Error getting version: $e');
  }

  return CompareVersionResult.none;
}