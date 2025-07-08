import 'dart:developer';

import 'package:android_window/android_window.dart';
import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/app_overlay_tab.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:flutter/material.dart';

class OverlayTab extends StatefulWidget {
  const OverlayTab({super.key});

  @override
  State createState() => _OverlayTabState();
}

class _OverlayTabState extends State<OverlayTab> {
  String _deviceName = '';
  String _displayCode = '';
  String _otp = '';

  @override
  void initState() {
    super.initState();
    _setUpAndroidWindow();
  }

  @override
  Widget build(BuildContext context) {
    var textStyle = const TextStyle(
      fontFamily: 'Inconsolata',
      fontSize: 15,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    );
    return AndroidWindow(
      child: ClipRRect(
        clipBehavior: Clip.hardEdge,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: Scaffold(
          backgroundColor: AppColors.primaryWhiteA50,
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              AndroidWindow.launchApp();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    V3AutoHyphenatingText(
                        S.of(context).main_settings_device_name),
                    V3AutoHyphenatingText(_deviceName, style: textStyle),
                  ],
                ),
                Container(
                  width: 2,
                  height: 40,
                  color: Colors.black,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    V3AutoHyphenatingText(
                        S.of(context).main_content_display_code),
                    V3AutoHyphenatingText(_displayCode, style: textStyle),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    V3AutoHyphenatingText(
                        S.of(context).main_content_one_time_password),
                    V3AutoHyphenatingText(_otp, style: textStyle),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _setUpAndroidWindow() {
    AndroidWindow.setHandler((String name, Object? data) async {
      switch (name) {
        case OverlayTabHandler.nameOverlayTabCheck:
          await AndroidWindow.post(OverlayTabHandler.nameOverlayTabReady);
          return OverlayTabHandler.resultEmptyString;

        case OverlayTabHandler.nameInitValue:
          if (data is Map<Object?, Object?>) {
            setState(() {
              var info = Map<String, String>.from(data);
              _deviceName = info[OverlayTabHandler.keyDeviceName] ?? '';
              _displayCode = info[OverlayTabHandler.keyDisplayCode] ?? '';
              _otp = info[OverlayTabHandler.keyOtpCode] ?? '';
            });
          } else {
            log('set init value with wrong data type: ${data.runtimeType}');
          }
          return OverlayTabHandler.resultEmptyString;

        case OverlayTabHandler.nameSetVisibility:
          if (data is Map<Object?, Object?>) {
            setState(() {
              var info = Map<String, String>.from(data);
              AndroidWindow.setVisibility(
                  (info[OverlayTabHandler.keyVisibility] ??
                          OverlayTabHandler.valueInvisible) ==
                      OverlayTabHandler.valueVisible);
            });
          } else {
            log('set visibility with wrong data type: ${data.runtimeType}');
          }
          return OverlayTabHandler.resultEmptyString;

        case OverlayTabHandler.nameGetVisibility:
          var visible = await AndroidWindow.getVisibility()
              ? OverlayTabHandler.valueVisible
              : OverlayTabHandler.valueInvisible;
          return {OverlayTabHandler.keyVisibility: visible};

        case OverlayTabHandler.nameSetMainInfo:
          if (data is Map<Object?, Object?>) {
            setState(() {
              var info = Map<String, String>.from(data);
              _deviceName = info[OverlayTabHandler.keyDeviceName] ?? '';
              _displayCode = info[OverlayTabHandler.keyDisplayCode] ?? '';
            });
          } else {
            log('set main info with wrong data type: ${data.runtimeType}');
          }
          return OverlayTabHandler.resultEmptyString;

        case OverlayTabHandler.nameSetOtp:
          if (data is Map<Object?, Object?>) {
            setState(() {
              var info = Map<String, String>.from(data);
              _otp = info[OverlayTabHandler.keyOtpCode] ?? '';
            });
          } else {
            log('set otp with wrong data type: ${data.runtimeType}');
          }
          return OverlayTabHandler.resultEmptyString;

        case OverlayTabHandler.nameLaunchApp:
          if (data is Map<Object?, Object?>) {
            AndroidWindow.launchApp();
          } else {
            log('launch app with wrong data type: ${data.runtimeType}');
          }
          return OverlayTabHandler.resultEmptyString;
      }
      return OverlayTabHandler.resultNullString;
    });
  }
}
