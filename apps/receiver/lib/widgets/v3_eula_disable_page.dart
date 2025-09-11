import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/multi_window_provider.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

class V3EulaDisablePage extends StatelessWidget {
  const V3EulaDisablePage({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final compat = _V3EulaDisablePage(
        centerHorizontalPadding: 0.0,
        titleFontSize: 13.33,
        imageHeight: 21.33,
        buttonWidth: 125.33,
        buttonHeight: 39.3,
        buttonFontSize: 12.0,
        onPressed: onPressed);
    final mid = _V3EulaDisablePage(
        centerHorizontalPadding: 80.0,
        titleFontSize: 26.66,
        imageHeight: 43.55,
        buttonWidth: 229.3,
        buttonHeight: 39.3,
        buttonFontSize: 12.0,
        onPressed: onPressed);
    return MultiWindowAdaptiveLayout(
      landscape: _V3EulaDisablePage(
          centerHorizontalPadding: 150.0,
          titleFontSize: 32.0,
          imageHeight: 53.0,
          buttonWidth: 279.3,
          buttonHeight: 39.66,
          buttonFontSize: 12.0,
          onPressed: onPressed),
      launcherMain: mid,
      landscapeHalf: mid,
      landscapeTwoThirds: mid,
      landscapeOneThird: compat,
      launcher: compat,
      launcherFull: compat,
      floatingDefault: compat,
    );
  }
}

class _V3EulaDisablePage extends StatelessWidget {
  const _V3EulaDisablePage({
    required this.centerHorizontalPadding,
    required this.titleFontSize,
    required this.imageHeight,
    required this.buttonWidth,
    required this.buttonHeight,
    required this.buttonFontSize,
    required this.onPressed,
  });

  final double centerHorizontalPadding;
  final double titleFontSize;
  final double imageHeight;
  final double buttonWidth;
  final double buttonHeight;
  final double buttonFontSize;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: SvgPicture.asset(
              'assets/images/ic_launcher_disable_eula_bg.svg',
              excludeFromSemantics: true,
              width: 1280,
              height: 720,
              fit: BoxFit.fill,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/ic_wallpaper.png',
              excludeFromSemantics: true,
            ),
          ),
          Positioned.fill(
            bottom: 0,
            left: centerHorizontalPadding,
            right: centerHorizontalPadding,
            child: SvgPicture.asset(
              'assets/images/ic_launcher_disable_eula_bg_center.svg',
              excludeFromSemantics: true,
              width: 1280,
            ),
          ),
          Positioned(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  S.of(context).v3_instruction_share_screen,
                  style: TextStyle(
                    color: context.tokens.color.vsdslColorOnSurface,
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Gap(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/ic_logo_airsync_icon.svg',
                      excludeFromSemantics: true,
                      width: imageHeight,
                      height: imageHeight,
                    ),
                    Gap(6),
                    SvgPicture.asset(
                      'assets/images/ic_logo_airsync_text.svg',
                      excludeFromSemantics: true,
                      height: imageHeight,
                    ),
                  ],
                ),
                Gap(24.6666),
                SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: V3Focus(
                    label: S.of(context).v3_lbl_eula_launch,
                    identifier: 'v3_qa_eula_launch',
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 5.0,
                        shadowColor: context.tokens.color.vsdslColorPrimary,
                        foregroundColor:
                            context.tokens.color.vsdslColorOnSurfaceInverse,
                        overlayColor: context.tokens.color.vsdslColorPrimary,
                        backgroundColor: context.tokens.color.vsdslColorPrimary,
                        textStyle: TextStyle(
                          fontSize: buttonFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: onPressed,
                      child:
                          V3AutoHyphenatingText(S.of(context).v3_eula_launch),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
