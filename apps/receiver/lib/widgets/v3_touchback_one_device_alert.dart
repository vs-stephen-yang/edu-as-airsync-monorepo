import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:display_flutter/widgets/v3_dialog_action_buttons.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:display_flutter/widgets/v3_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:sprintf/sprintf.dart';

class V3TouchbackAlert extends StatelessWidget {
  const V3TouchbackAlert(
      {super.key,
      required this.primaryFocusNode,
      required this.deviceName,
      this.onConfirm});

  final FocusNode primaryFocusNode;
  final String deviceName;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Dialog(
        backgroundColor: context.tokens.color.vsdslColorSurface100,
        insetPadding: EdgeInsets.zero,
        elevation: 16.0,
        shadowColor: context.tokens.color.vsdslColorOpacityNeutralSm,
        child: PortraitWidget(
          primaryFocusNode: primaryFocusNode,
          onConfirm: onConfirm,
          title: sprintf(S.of(context).v3_touchback_alert_title, [deviceName]),
          message: S.of(context).v3_touchback_alert_message,
        ),
      ),
    );
  }
}

class V3TouchbackHintAlert extends StatelessWidget {
  const V3TouchbackHintAlert(
      {super.key,
      required this.primaryFocusNode,
      required this.deviceName,
      this.onConfirm});

  final FocusNode primaryFocusNode;
  final String deviceName;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Dialog(
        backgroundColor: context.tokens.color.vsdslColorSurface100,
        insetPadding: EdgeInsets.zero,
        elevation: 16.0,
        shadowColor: context.tokens.color.vsdslColorOpacityNeutralSm,
        child: PortraitWidget(
          primaryFocusNode: primaryFocusNode,
          onConfirm: onConfirm,
          title: "",
          message: S.of(context).v3_touchback_ipad_bluetooth_hint,
          showCancel: false,
        ),
      ),
    );
  }
}

class PortraitWidget extends StatelessWidget {
  final FocusNode primaryFocusNode;
  final VoidCallback? onConfirm;
  final String title;
  final String message;
  final bool showCancel;

  const PortraitWidget({
    super.key,
    required this.primaryFocusNode,
    this.onConfirm,
    required this.title,
    required this.message,
    this.showCancel = true,
  });

  @override
  Widget build(BuildContext context) {
    final sc = ScrollController();
    final rightButton = V3ButtonInfo(
      text: S.of(context).moderator_confirm,
      label: S.of(context).v3_lbl_touchback_one_device_confirm,
      identifier: 'v3_qa_touchback_one_device_confirm',
      onTap: () {
        onConfirm?.call();
        if (navService.canPop()) navService.goBack();
      },
      backgroundColor: context.tokens.color.vsdslColorPrimary,
      textColor: Colors.white,
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 193),
      child: Container(
        width: 267,
        height: 157,
        padding: const EdgeInsets.all(10),
        decoration: ShapeDecoration(
          color: context.tokens.color.vsdslColorOnSurfaceInverse,
          shape: RoundedRectangleBorder(
            borderRadius: context.tokens.radii.vsdslRadiusLg,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: V3Scrollbar(
                controller: sc,
                child: SingleChildScrollView(
                  controller: sc,
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        V3AutoHyphenatingText(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: context.tokens.color
                                .vsdslColorNeutral /* AirSync-color-neutral */,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Gap(13),
                        V3AutoHyphenatingText(
                          message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: context.tokens.color
                                .vsdslColorNeutral /* AirSync-color-neutral */,
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (showCancel)
              V3DialogActionButtons(
                leftButton: V3ButtonInfo(
                  text: S.of(context).v3_touchback_restart_bluetooth_btn_cancel,
                  label: S.of(context).v3_lbl_touchback_one_device_cancel,
                  identifier: 'v3_qa_touchback_one_device_cancel',
                  onTap: () {
                    if (navService.canPop()) navService.goBack();
                  },
                  backgroundColor: Colors.transparent,
                  borderColor: context.tokens.color.vsdslColorSecondary,
                  textColor: context.tokens.color.vsdslColorSecondary,
                ),
                rightButton: rightButton,
              )
            else
              _SingleButton(info: rightButton),
          ],
        ),
      ),
    );
  }
}

class _SingleButton extends StatelessWidget {
  final V3ButtonInfo info;

  const _SingleButton({required this.info});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 40),
      child: V3Focus(
        label: info.label,
        identifier: info.identifier,
        child: InkWell(
          onTap: info.onTap,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: ShapeDecoration(
              color: info.backgroundColor,
              shape: RoundedRectangleBorder(
                side: info.borderColor != null
                    ? BorderSide(width: 2, color: info.borderColor!)
                    : BorderSide.none,
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
            child: Center(
              child: V3AutoHyphenatingText(
                info.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: info.textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
