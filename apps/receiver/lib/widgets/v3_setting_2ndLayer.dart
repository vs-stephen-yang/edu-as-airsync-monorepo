import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

class V3Setting2ndLayer extends StatelessWidget {
  const V3Setting2ndLayer({
    super.key,
    required this.child,
    this.isDisable = false,
    this.disableScroll = false,
  });

  final Widget child;
  final bool isDisable;
  final bool disableScroll;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: context.tokens.spacing.vsdslSpacingXl.left,
          top: 57,
          right: context.tokens.spacing.vsdslSpacingXl.right,
          bottom: context.tokens.spacing.vsdslSpacingXl.bottom +
              // 67 = 51 (Size of message height) + 16 (Figma space: 48)
              (isDisable ? 67 : 0),
          child: disableScroll
              ? child
              : SingleChildScrollView(
                  child: child,
                ),
        ),
        if (isDisable)
          Positioned(
            left: context.tokens.spacing.vsdslSpacingXl.left,
            right: context.tokens.spacing.vsdslSpacingXl.right,
            bottom: context.tokens.spacing.vsdslSpacingXl.bottom,
            child: Container(
              width: 325,
              height: 51,
              decoration: BoxDecoration(
                color: context.tokens.color.vsdslColorSurface900,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: context.tokens.spacing.vsdslSpacingXl,
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/ic_toast_alert.svg',
                    width: 16,
                    height: 16,
                  ),
                  Gap(context.tokens.spacing.vsdslSpacingLg.right),
                  SizedBox(
                    width: 270,
                    child: AutoSizeText(
                      S.of(context).v3_settings_feature_locked,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w400,
                        color: context.tokens.color.vsdslColorWarning,
                      ),
                      minFontSize: 8,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
