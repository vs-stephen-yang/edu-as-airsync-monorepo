import 'dart:io';

import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:display_cast_flutter/utilities/webrtc_helper.dart';
import 'package:display_cast_flutter/widgets/V3_focus.dart';
import 'package:display_cast_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:display_cast_flutter/widgets/v3_scroll_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:no_context_navigation/no_context_navigation.dart';

class V3TouchBackButton extends StatefulWidget {
  const V3TouchBackButton({super.key});

  @override
  State<StatefulWidget> createState() => _V3TouchBackButtonState();
}

class _V3TouchBackButtonState extends State<V3TouchBackButton>
    with WidgetsBindingObserver {
  AppLifecycleListener? _lifecycleListener;
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    isButtonEnabled = WebRTCHelper().getTouchBack();

    if (Platform.isAndroid) {
      _lifecycleListener = AppLifecycleListener(
        onResume: () async {
          isButtonEnabled =
              await WebRTCHelper().isAccessibilityServiceAllowed();
          WebRTCHelper().setTouchBack(isButtonEnabled);
          setState(() {});
        },
      );

      if (isButtonEnabled) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showAccessibilityServiceDialog();
        });
      }
    }
  }

  @override
  void dispose() {
    _lifecycleListener?.dispose();
    _lifecycleListener = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 66),
      decoration: BoxDecoration(
        color: context.tokens.color.vsdswColorSurface900,
        borderRadius: context.tokens.radii.vsdswRadiusFull,
        border:
            Border.all(color: context.tokens.color.vsdswColorOutlineVariant),
      ),
      padding: EdgeInsets.symmetric(
        vertical: context.tokens.spacing.vsdswSpacingMd.top,
        horizontal: context.tokens.spacing.vsdswSpacingLg.left,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: V3AutoHyphenatingText(
              S.of(context).v3_present_touch_back_allow,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: context.tokens.color.vsdswColorOnSurfaceInverse,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              right: context.tokens.spacing.vsdswSpacingMd.left,
            ),
          ),
          V3Focus(
            label: isButtonEnabled
                ? S.of(context).v3_lbl_touch_back_on
                : S.of(context).v3_lbl_touch_back_off,
            identifier: 'v3_touch_back_button',
            child: SizedBox(
              width: 56,
              height: 48,
              child: InkWell(
                child: isButtonEnabled
                    ? SvgPicture.asset('assets/images/v3_ic_switch_on.svg')
                    : SvgPicture.asset('assets/images/v3_ic_switch_off.svg'),
                onTap: () {
                  trackEvent(
                    'click_touchback',
                    EventCategory.session,
                    target: isButtonEnabled ? 'on' : 'off',
                  );

                  isButtonEnabled = !isButtonEnabled;
                  WebRTCHelper().setTouchBack(isButtonEnabled);
                  setState(() {});
                  if (isButtonEnabled && Platform.isAndroid) {
                    _showAccessibilityServiceDialog();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  _showAccessibilityServiceDialog() async {
    if (!await WebRTCHelper().isAccessibilityServiceAllowed()) {
      // if AccessibilityService not enabled, show dialog to ask permission.
      if (context.mounted) {
        final sc = ScrollController();
        BuildContext buildContext = context;
        await showDialog(
            context: buildContext,
            barrierDismissible: false,
            barrierColor: Colors.grey,
            builder: (_) {
              return AlertDialog(
                backgroundColor: Colors.white,
                // Can not use V3AutoHyphenatingText
                title: Text(S.of(context).v3_present_touch_back_dialog_title),
                content: V3Scrollbar(
                  controller: sc,
                  child: SingleChildScrollView(
                    controller: sc,
                    // Can not use V3AutoHyphenatingText
                    child: Text(
                      S.of(context).v3_present_touch_back_dialog_description,
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () async {
                      isButtonEnabled =
                          await WebRTCHelper().isAccessibilityServiceAllowed();
                      WebRTCHelper().setTouchBack(isButtonEnabled);
                      setState(() {});
                      if (navService.canPop()) {
                        navService.goBack();
                      }
                    },
                    // Can not use V3AutoHyphenatingText
                    child: Text(
                      S.of(context).v3_present_touch_back_dialog_not_now,
                      style: TextStyle(
                        color: context.tokens.color.vsdswColorPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    style: ButtonStyle(
                      // 设置按钮背景颜色
                      backgroundColor:
                          WidgetStateProperty.all<Color>(Colors.blue),
                      // 设置按钮文字颜色
                      foregroundColor:
                          WidgetStateProperty.all<Color>(Colors.white),
                    ),
                    onPressed: () async {
                      await WebRTCHelper().openAccessibilitySettings();
                      if (navService.canPop()) {
                        navService.goBack();
                      }
                    },
                    // Can not use V3AutoHyphenatingText
                    child: Text(
                      S.of(context).v3_present_touch_back_dialog_allow,
                      style: TextStyle(
                        color: context.tokens.color.vsdswColorOnPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              );
            });
      }
    }
  }
}
