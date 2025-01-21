import 'dart:developer';

import 'package:android_window/android_window.dart';
import 'package:device_info_vs/device_info_vs.dart';
import 'package:display_flutter/app_overlay_tab.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/providers/pref_language_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';

class V3OverlayTab extends StatefulWidget {
  const V3OverlayTab({super.key});

  @override
  State<StatefulWidget> createState() => _V3OverlayTabState();
}

class _V3OverlayTabState extends State<V3OverlayTab> {
  bool _isExpandedMode = false;
  String _deviceName = '';
  String _displayCode = '';
  String _otp = '';

  @override
  void initState() {
    super.initState();
    setExpandedMode();
    _setUpAndroidWindow();
  }

  Future<void> setExpandedMode() async {
    var deviceType = await DeviceInfoVs.deviceType;
    bool isCDE = deviceType?.toString().startsWith('CDE') ?? false;
    if (isCDE) _isExpandedMode = true;
  }

  @override
  Widget build(BuildContext context) {
    var textStyle = TextStyle(
      fontSize: 12,
      color: context.tokens.color.vsdslColorOnSurfaceInverse,
      fontWeight: FontWeight.w500,
      decoration: TextDecoration.none,
    );

    /// todo: improve relayout mechanism
    ///  currently will show overflow markings (yellow/back strips) in debug mode
    ///  however release mode won't.
    return AndroidWindow(
      child: ClipRRect(
        clipBehavior: Clip.hardEdge,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        child: Container(
          color: context.tokens.color.vsdslColorOpacityNeutralXl,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 11),
          child: _isExpandedMode
              ? GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    AndroidWindow.launchApp();
                  },
                  child: Row(
                    children: [
                      Image(
                        width: 7,
                        height: 14,
                        image:
                            const Svg('assets/images/ic_overlay_tab_dots.svg'),
                        color: context.tokens.color.vsdslColorNeutralInverse,
                      ),
                      const SizedBox(width: 13),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          setState(() {
                            _isExpandedMode = false;
                          });
                        },
                        child: const Image(
                          width: 26,
                          height: 26,
                          image: Svg('assets/images/ic_overlay_tab_opened.svg'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Image(
                        width: 16,
                        height: 16,
                        image: const Svg('assets/images/ic_screen.svg'),
                        color: context.tokens.color.vsdslColorOnSurfaceVariant,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        _deviceName,
                        style: textStyle,
                      ),
                      const SizedBox(width: 8),
                      Image(
                        width: 16,
                        height: 16,
                        image: const Svg('assets/images/ic_qrcode.svg'),
                        color: context.tokens.color.vsdslColorOnSurfaceVariant,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        _getDisplayCodeVisualIdentity(_displayCode),
                        style: textStyle,
                      ),
                      const SizedBox(width: 8),
                      Image(
                        width: 16,
                        height: 16,
                        image: const Svg('assets/images/ic_otp.svg'),
                        color: context.tokens.color.vsdslColorOnSurfaceVariant,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        _otp,
                        style: textStyle,
                      ),
                      const SizedBox(width: 13),
                      Image(
                        width: 7,
                        height: 14,
                        image:
                            const Svg('assets/images/ic_overlay_tab_dots.svg'),
                        color: context.tokens.color.vsdslColorNeutralInverse,
                      ),
                    ],
                  ),
                )
              : GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      _isExpandedMode = true;
                    });
                  },
                  child: const Image(
                    width: 26,
                    height: 26,
                    image: Svg('assets/images/ic_overlay_tab_closed.svg'),
                  ),
                ),
        ),
      ),
    );
  }

  _setUpAndroidWindow() {
    var self = this;
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
              Provider.of<PrefLanguageProvider>(context, listen: false)
                  .setLanguage(
                      info[OverlayTabHandler.keyLanguage] ?? 'English');
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
            self.setState(() {
              var info = Map<String, String>.from(data);
              _otp = info[OverlayTabHandler.keyOtpCode] ?? '';
            });
          } else {
            log('set otp with wrong data type: ${data.runtimeType}');
          }
          return OverlayTabHandler.resultEmptyString;

        case OverlayTabHandler.nameSetLanguage:
          if (data is Map<Object?, Object?>) {
            setState(() {
              var info = Map<String, String>.from(data);
              Provider.of<PrefLanguageProvider>(context, listen: false)
                  .setLanguage(
                      info[OverlayTabHandler.keyLanguage] ?? 'English');
            });
          } else {
            log('set language with wrong data type: ${data.runtimeType}');
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

  String _getDisplayCodeVisualIdentity(String displayCode) {
    String result = displayCode;
    if (displayCode.length > 5) {
      // https://stackoverflow.com/a/56845471/13160681
      result = displayCode
          .replaceAllMapped(RegExp(r".{4}"), (match) => "${match.group(0)} ")
          .trimRight();
    }
    return result;
  }
}
