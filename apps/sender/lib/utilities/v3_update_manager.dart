import 'dart:convert';
import 'dart:io';

import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/settings/app_config.dart';
import 'package:display_cast_flutter/utilities/updater_windows.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

enum CompareVersionResult { forceUpgrade, userChoose, noUpdate, noNetwork }

class V3UpdateManager {
  static final V3UpdateManager _instance = V3UpdateManager._internal();

  factory V3UpdateManager() {
    return _instance;
  }

  V3UpdateManager._internal();

  bool _isDialogShowing = false;

  Future<void> showUpdateDialog(
      BuildContext context, CompareVersionResult status) async {
    if (_isDialogShowing) {
      return;
    }
    _isDialogShowing = true;

    if (Platform.isIOS) {
      _showUpdateDialogIos(context, status).then((_) {
        _isDialogShowing = false;
      });
    } else if (Platform.isAndroid) {
      _showUpdateDialogAndroid(context, status).then((_) {
        _isDialogShowing = false;
      });
    } else {
      _showUpdateDialogDesktop(context, status).then((_) {
        _isDialogShowing = false;
      });
    }
  }

  Future<void> checkUpdateVersion(BuildContext context,
      Function(CompareVersionResult) onUpdateResult) async {
    String version = AppConfig.of(context)?.appVersion;
    String? api = AppConfig.of(context)?.settings.appUpdateVersionEndpoint;
    if (api == null) return onUpdateResult(CompareVersionResult.noUpdate);

    final result = await getVersion(api, version);
    onUpdateResult(result);
  }

  CompareVersionResult compareVersion(
      String currentVersion, String targetVersion, String minVersion) {
    List<int> current =
        currentVersion.split('-').first.split('.').map(int.parse).toList();
    List<int> target = targetVersion.split('.').map(int.parse).toList();
    List<int> min = minVersion.split('.').map(int.parse).toList();
    CompareVersionResult result = CompareVersionResult.noUpdate;

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

        return compareVersion(
            currentVersion, targetVersion, minSupportedVersion);
      }
    } catch (e) {
      debugPrint('Error getting version: $e');
    }

    return CompareVersionResult.noUpdate;
  }

  Future<void> _showUpdateDialogIos(
      BuildContext context, CompareVersionResult status) async {
    bool isUpdate = (status == CompareVersionResult.forceUpgrade ||
        status == CompareVersionResult.userChoose);

    await showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => CupertinoAlertDialog(
              title: Text(_dialogTittle(context, status)),
              content: Text(_dialogDescription(context, status)),
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
                if (isUpdate)
                  CupertinoDialogAction(
                    onPressed: () {
                      if (status == CompareVersionResult.userChoose) {
                        Navigator.of(context).pop();
                      }
                      launchUrl(Uri.parse(
                          'https://apps.apple.com/us/app/airsync-sender/id6453759985'));
                    },
                    child: Text(
                        status == CompareVersionResult.forceUpgrade
                            ? S
                                .of(context)
                                .v3_setting_software_update_force_action
                            : S
                                .of(context)
                                .v3_setting_software_update_positive_action,
                        style: const TextStyle(
                            color: Color(0xFF007AFF), fontSize: 17)),
                  ),
                if (!isUpdate)
                  CupertinoDialogAction(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                        S
                            .of(context)
                            .v3_setting_software_update_no_available_action,
                        style: const TextStyle(
                            color: Color(0xFF007AFF), fontSize: 17)),
                  ),
              ],
            ));
  }

  Future<void> _showUpdateDialogAndroid(
      BuildContext context, CompareVersionResult status) async {
    bool isUpdate = (status == CompareVersionResult.forceUpgrade ||
        status == CompareVersionResult.userChoose);
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
              title: Text(_dialogTittle(context, status)),
              content: Text(_dialogDescription(context, status)),
              actions: [
                if (status == CompareVersionResult.userChoose)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                        S.of(context).v3_setting_software_update_deny_action),
                  ),
                if (isUpdate)
                  TextButton(
                    onPressed: () async {
                      if (status == CompareVersionResult.userChoose) {
                        Navigator.of(context).pop();
                      }
                      launchUrl(Uri.parse(
                          'https://play.google.com/store/apps/details?id=com.viewsonic.display.cast'));
                    },
                    child: Text(S
                        .of(context)
                        .v3_setting_software_update_positive_action),
                  ),
                if (!isUpdate)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(S
                        .of(context)
                        .v3_setting_software_update_no_available_action),
                  ),
              ],
            ));
  }

  Future<void> _showUpdateDialogDesktop(
      BuildContext context, CompareVersionResult status) async {
    bool isUpdate = (status == CompareVersionResult.forceUpgrade ||
        status == CompareVersionResult.userChoose);
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
                        _dialogTittle(context, status),
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
                    Text(_dialogDescription(context, status)),
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
                if (isUpdate)
                  _updateDialogButton(
                    text: S
                        .of(context)
                        .v3_setting_software_update_positive_action,
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
                            _showUpdateErrorDialogDesktop(context, e);
                          }
                        }
                      }
                    },
                  ),
                if (!isUpdate)
                  _updateDialogButton(
                    text: S
                        .of(context)
                        .v3_setting_software_update_no_available_action,
                    textColor: context.tokens.color.vsdswColorSecondary,
                    backgroundColor: Colors.transparent,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
              ],
            ));
  }

  String _dialogTittle(BuildContext context, CompareVersionResult status) {
    return status == CompareVersionResult.noNetwork
        ? S.of(context).v3_setting_software_update_no_available
        : status == CompareVersionResult.noUpdate
            ? S.of(context).v3_setting_software_update_no_available
            : S.of(context).v3_setting_software_update;
  }

  String _dialogDescription(BuildContext context, CompareVersionResult status) {
    return status == CompareVersionResult.forceUpgrade
        ? S.of(context).v3_setting_software_update_force_description
        : status == CompareVersionResult.userChoose
            ? S.of(context).v3_setting_software_update_description
            : status == CompareVersionResult.noUpdate
                ? S
                    .of(context)
                    .v3_setting_software_update_no_available_description
                : S
                    .of(context)
                    .v3_setting_software_update_no_internet_description;
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

  Future<void> _showUpdateErrorDialogDesktop(
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
}
