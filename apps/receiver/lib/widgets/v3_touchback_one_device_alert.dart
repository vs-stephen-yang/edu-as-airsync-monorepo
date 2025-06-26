import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
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
          deviceName: deviceName,
          onConfirm: onConfirm,
        ),
      ),
    );
  }
}

class PortraitWidget extends StatelessWidget {
  final FocusNode primaryFocusNode;
  final String deviceName;
  final VoidCallback? onConfirm;

  const PortraitWidget({
    super.key,
    required this.primaryFocusNode,
    required this.deviceName,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 193),
      child: Container(
        width: 267,
        height: 193,
        padding: const EdgeInsets.only(
          top: 26,
          left: 20,
          right: 20,
          bottom: 20,
        ),
        decoration: ShapeDecoration(
          color: Colors.white /* AirSync-color-surface-100 */,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    sprintf(
                        S.of(context).v3_touchback_alert_title, [deviceName]),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.tokens.color
                          .vsdslColorNeutral /* AirSync-color-neutral */,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(13),
                  Text(
                    S.of(context).v3_touchback_alert_message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.tokens.color
                          .vsdslColorNeutral /* AirSync-color-neutral */,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: V3Focus(
                    label: S.of(context).v3_lbl_touchback_one_device_cancel,
                    identifier: 'v3_qa_touchback_one_device_cancel',
                    child: InkWell(
                      child: Container(
                        height: 40,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 29),
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 2,
                              color: context.tokens.color.vsdslColorSecondary,
                            ),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                        ),
                        child: Text(
                          S
                              .of(context)
                              .v3_touchback_restart_bluetooth_btn_cancel,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: context.tokens.color.vsdslColorSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      onTap: () {
                        if (navService.canPop()) {
                          navService.goBack();
                        }
                      },
                    ),
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: V3Focus(
                    label: S.of(context).v3_lbl_touchback_one_device_confirm,
                    identifier: 'v3_qa_touchback_one_device_confirm',
                    child: InkWell(
                      child: Container(
                        height: 40,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 29),
                        decoration: ShapeDecoration(
                          color: context.tokens.color.vsdslColorPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9999),
                          ),
                        ),
                        child: Text(
                          S.of(context).moderator_confirm,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      onTap: () {
                        onConfirm?.call();
                        if (navService.canPop()) {
                          navService.goBack();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
