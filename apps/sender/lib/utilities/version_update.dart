import 'dart:convert';
import 'dart:io' show HttpStatus, Platform, exit;

import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/utilities/updater_windows.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

enum CompareVersionResult { forceUpgrade, userChoose, none }

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

Future<CompareVersionResult> getVersion(
    String url, String currentVersion) async {
  try {
    http.Response response = await http.get(
      Uri.parse(url),
    );

    if (response.statusCode >= HttpStatus.ok &&
        response.statusCode < HttpStatus.multiStatus) {
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

Future<void> showUpdateDialogIos(
    BuildContext context, CompareVersionResult status) async {
  await showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CupertinoAlertDialog(
            title: Text(S.of(context).v3_setting_software_update),
            content: Text(S.of(context).v3_setting_software_update_description),
            actions: [
              if (status == CompareVersionResult.userChoose)
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                      S.of(context).v3_setting_software_update_deny_action,
                      style: const TextStyle(
                          color: Color(0xFF007AFF), fontSize: 17)),
                ),
              CupertinoDialogAction(
                onPressed: () {
                  if (status == CompareVersionResult.userChoose) {
                    Navigator.of(context).pop();
                  }
                  launchUrl(Uri.parse(
                      'https://apps.apple.com/us/app/airsync-sender/id6453759985'));
                },
                child: Text(
                    S.of(context).v3_setting_software_update_positive_action,
                    style: const TextStyle(
                        color: Color(0xFF007AFF), fontSize: 17)),
              ),
            ],
          ));
}

Future<void> showUpdateDialogAndroid(
    BuildContext context, CompareVersionResult status) async {
  await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
            title: Text(S.of(context).v3_setting_software_update),
            content: Text(S.of(context).v3_setting_software_update_description),
            actions: [
              if (status == CompareVersionResult.userChoose)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                      S.of(context).v3_setting_software_update_deny_action),
                ),
              TextButton(
                onPressed: () async {
                  if (status == CompareVersionResult.userChoose) {
                    Navigator.of(context).pop();
                  }
                  if (Platform.isAndroid) {
                    launchUrl(Uri.parse(
                        'https://play.google.com/store/apps/details?id=com.viewsonic.display.cast'));
                  } else if (Platform.isMacOS) {
                    launchUrl(Uri.parse(
                        'macappstore://apps.apple.com/app/airsync-sender/id6453759985'));
                  } else {
                    // windows
                    try {
                      await installUpdates();
                      exit(0);
                    } on UpdateErrorExecption catch (e) {
                      if (context.mounted) {
                        showUpdateErrorDialogDesktop(context, e);
                      }
                    }
                  }
                },
                child: Text(
                    S.of(context).v3_setting_software_update_positive_action),
              ),
            ],
          ));
}

Future<void> showUpdateDialogDesktop(
    BuildContext context, CompareVersionResult status) async {
  await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
            title: Stack(
              children: [
                if (status == CompareVersionResult.userChoose)
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      iconSize: 12,
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.only(
                      top: context.tokens.spacing.vsdswSpacingMd.top),
                  child: Center(
                    child: Text(
                      S.of(context).v3_setting_software_update,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 436,
              height: 128,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S.of(context).v3_setting_software_update_description),
                  const Spacer(),
                  const Divider(),
                ],
              ),
            ),
            actions: [
              if (status == CompareVersionResult.userChoose)
                _updateDialogButton(
                  text: S.of(context).v3_setting_software_update_deny_action,
                  textColor: context.tokens.color.vsdswColorSecondary,
                  backgroundColor: Colors.transparent,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              _updateDialogButton(
                text: S.of(context).v3_setting_software_update_positive_action,
                textColor: context.tokens.color.vsdswColorOnPrimary,
                backgroundColor: context.tokens.color.vsdswColorPrimary,
                onPressed: () async {
                  if (status == CompareVersionResult.userChoose) {
                    Navigator.of(context).pop();
                  }
                  if (Platform.isMacOS) {
                    launchUrl(Uri.parse(
                        'macappstore://apps.apple.com/app/airsync-sender/id6453759985'));
                  } else {
                    // windows
                    try {
                      await installUpdates();
                      exit(0);
                    } on UpdateErrorExecption catch (e) {
                      if (context.mounted) {
                        showUpdateErrorDialogDesktop(context, e);
                      }
                    }
                  }
                },
              ),
            ],
          ));
}

Widget _updateDialogButton(
    {required String text,
    required Color textColor,
    required Color backgroundColor,
    required GestureTapCallback onPressed}) {
  return InkWell(
    onTap: onPressed,
    child: Container(
      alignment: Alignment.center,
      width: 105,
      height: 48,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9999),
        ),
        shadows: backgroundColor != Colors.transparent
            ? [
                BoxShadow(
                  color: backgroundColor.withOpacity(0.31),
                  blurRadius: 24,
                  offset: const Offset(0, 16),
                  spreadRadius: 0,
                )
              ]
            : null,
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor),
      ),
    ),
  );
}

Future<void> showUpdateErrorDialogDesktop(
    BuildContext context, UpdateErrorExecption e) async {
  await showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Stack(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    iconSize: 12,
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: context.tokens.spacing.vsdswSpacingMd.top),
                  child: Center(
                    child: Text(
                      S.of(context).v3_setting_software_update,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 436,
              height: 128,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      '${S.of(context).main_update_error_type}: ${e.error.name} \n${S.of(context).main_update_error_detail}: ${e.details.toString()}'),
                  const Spacer(),
                  const Divider(),
                ],
              ),
            ),
            actions: [
              _updateDialogButton(
                text: S.of(context).device_list_enter_pin_ok,
                textColor: context.tokens.color.vsdswColorSecondary,
                backgroundColor: Colors.transparent,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ));
}
