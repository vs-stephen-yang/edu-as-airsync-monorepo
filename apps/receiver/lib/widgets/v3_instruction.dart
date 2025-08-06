import 'package:auto_hyphenating_text/auto_hyphenating_text.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/connectivity_provider.dart';
import 'package:display_flutter/screens/v3_download_app_menu.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/widgets/connection_status.dart';
import 'package:display_flutter/widgets/focus_aware_builder.dart';
import 'package:display_flutter/widgets/multi_line_underline_text.dart';
import 'package:display_flutter/widgets/v3_display_code.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:display_flutter/widgets/v3_otp_with_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

/// This file contains a composable component system for AirSync connection instructions:
///
/// 1. Base Components:
///    - V3InstructionStep: Universal instruction step component, all steps are based on this
///    - V3InstructionHeader: Title and connection status display
///
/// 2. Specific Step Components:
///    - V3InstructionDownloadApp: Download app step
///    - V3InstructionDisplayCode: Enter display code step
///    - V3InstructionOtpCode: Enter OTP verification code step
///
/// Modification Guidelines:
/// - To modify individual step styling/content, edit the corresponding specific step component
/// - To modify common layout for all steps, edit V3InstructionStep
/// - To add new screen size support, compose needed step components at usage site
/// - Don't directly modify V3Instruction, it's preserved for backward compatibility

/// Header component for page title, connection status and local connection hints
/// Displayed across all screen sizes
class V3InstructionHeader extends StatelessWidget {
  final bool isCastToDevice;
  final bool isQuickConnect;

  const V3InstructionHeader({
    super.key,
    required this.isCastToDevice,
    required this.isQuickConnect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isCastToDevice) ...[
          ValueListenableBuilder(
              valueListenable: AppPreferences().connectivityTypeNotifier,
              builder: (context, connectivityType, child) {
                if (AppPreferences().connectivityType ==
                    ConnectivityType.local.name) {
                  return Container(
                    decoration: ShapeDecoration(
                      color: context.tokens.color.vsdslColorSurface200,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: context.tokens.spacing.vsdslSpacingXl.left,
                        vertical: context.tokens.spacing.vsdslSpacingSm.top),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/images/ic_local_connection_only.svg',
                          excludeFromSemantics: true,
                          width: 21,
                          height: 21,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: context.tokens.spacing.vsdslSpacingSm.left),
                          child: AutoHyphenatingText(
                            S.of(context).v3_settings_local_connection_only,
                            style: context
                                .tokens.textStyle.airsyncFontSubtitle600
                                .apply(
                              color: context.tokens.color.vsdslColorSurface600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return const SizedBox(
                    height: 27,
                  );
                }
              }),
        ],
        if (!isQuickConnect && !isCastToDevice) ...[
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AutoHyphenatingText(
                S.of(context).v3_instruction_share_screen,
                style: context.tokens.textStyle.airsyncFontTitle.apply(
                    color: context.tokens.color.vsdslColorOnSurface,
                    fontWeightDelta: FontWeight.w700.value),
              ),
              Gap(context.tokens.spacing.vsdslSpacingSm.right),
              const ConnectionStatus(),
            ],
          ),
          SizedBox(height: context.tokens.spacing.vsdslSpacing5xl.top),
        ],
      ],
    );
  }
}

/// Universal instruction step component
///
/// Base component for all instruction steps, providing unified layout structure:
/// - Optional icon (27x27)
/// - Text content area (auto-expanding)
/// - Optional action widget (DisplayCode/OtpWithTimer)
///
/// Usage:
/// ```dart
/// V3InstructionStep(
///   iconAsset: 'assets/images/ic_item2.svg',
///   showIcon: false, // Hide icon on small screens
///   textContent: AutoHyphenatingText(...),
///   actionWidget: const V3DisplayCode(),
/// )
/// ```
class V3InstructionStep extends StatelessWidget {
  final String? iconAsset; // Icon path, no icon when null
  final Widget textContent; // Text content widget
  final Widget? actionWidget; // Action widget (DisplayCode/OtpWithTimer)
  final bool showIcon; // Whether to show icon (even if iconAsset is not null)
  final double iconSize;
  final EdgeInsets? actionPadding; // Custom padding for action widget

  const V3InstructionStep({
    super.key,
    this.iconAsset,
    required this.textContent,
    this.actionWidget,
    this.showIcon = true,
    this.actionPadding,
    this.iconSize = 27.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (showIcon && iconAsset != null) ...[
              SvgPicture.asset(
                iconAsset!,
                excludeFromSemantics: true,
                height: iconSize,
                width: iconSize,
              ),
              Gap(context.tokens.spacing.vsdslSpacingMd.left),
            ],
            Expanded(child: textContent),
          ],
        ),
        if (actionWidget != null) ...[
          if (actionPadding != null)
            Padding(
              padding: actionPadding!,
              child: actionWidget!,
            )
          else
            Padding(
              padding: EdgeInsets.only(left: showIcon ? 35 : 0),
              child: actionWidget!,
            ),
        ],
      ],
    );
  }
}

/// Step 1: Download Application
///
/// Contains complex logic:
/// - Shows different content based on network status
/// - Includes interactive download app button
/// - Removed on 1/2 and 1/3 screens to save space
class V3InstructionDownloadApp extends StatelessWidget {
  final bool isCastToDevice;
  final bool isQuickConnect;
  final bool showIcon;

  const V3InstructionDownloadApp({
    super.key,
    required this.isCastToDevice,
    required this.isQuickConnect,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return V3InstructionStep(
      iconAsset: 'assets/images/ic_item1.svg',
      showIcon: showIcon,
      textContent: Consumer<ConnectivityProvider>(
          builder: (_, connectivityProvider, __) {
        return FutureBuilder(
          future: connectivityProvider.checkInternetConnection(),
          builder: (context, snapshot) {
            bool isInternet = false;
            if (snapshot.hasData) {
              isInternet = snapshot.data as bool;
            }
            String airsync = AppConfig.of(context)?.settings.airSyncUrl ?? '';
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText.rich(
                  _buildTextSpan(
                    fullText: isInternet && (!isCastToDevice || isQuickConnect)
                        ? S
                            .of(context)
                            .v3_instruction1a
                            .replaceAll('airsync.net', airsync)
                            .replaceAll(
                                S.of(context).v3_instruction1b.toLowerCase(),
                                '')
                            .replaceAll(
                                S
                                    .of(context)
                                    .v3_cast_to_device_menu_or
                                    .toLowerCase(),
                                '')
                        : S.of(context).v3_instruction1b,
                    formatTexts: [airsync],
                    formatStyle: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: context.tokens.color.vsdslColorOnSurface,
                      letterSpacing: -0.48,
                    ),
                  ),
                  style: context.tokens.textStyle.airsyncFontTitle.apply(
                    color: context.tokens.color.vsdslColorOnSurface,
                  ),
                ),
                if (isInternet && !isCastToDevice)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      AutoSizeText.rich(
                        _buildTextSpan(
                          fullText: S
                              .of(context)
                              .v3_cast_to_device_menu_or
                              .toLowerCase(),
                          formatTexts: [airsync],
                          formatStyle: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                            color: context.tokens.color.vsdslColorOnSurface,
                            letterSpacing: -0.48,
                          ),
                        ),
                        style: context.tokens.textStyle.airsyncFontTitle.apply(
                          color: context.tokens.color.vsdslColorOnSurface,
                        ),
                      ),
                      V3Focus(
                        label: S.of(context).v3_lbl_open_download_app_menu,
                        identifier: 'v3_qa_open_download_app_menu',
                        child: InkWell(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5, right: 5),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/ic_download_sender.svg',
                                  excludeFromSemantics: true,
                                  width: 23,
                                  height: 23,
                                ),
                                const Gap(5),
                                Flexible(
                                  child: MultiLineUnderlineText(
                                    text: S.of(context).v3_download_app_title,
                                    style: context
                                        .tokens.textStyle.airsyncFontTitle
                                        .apply(
                                      color: context
                                          .tokens.color.vsdslColorOnSurface,
                                      fontWeightDelta: FontWeight.w700.value,
                                    ),
                                    underlineColor: context
                                        .tokens.color.vsdslColorOnSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            trackEvent('click_dl_qrcode_icon',
                                EventCategory.quickMenu);
                            _showDownloadAppMenuDialog(context);
                          },
                        ),
                      ),
                    ],
                  ),
              ],
            );
          },
        );
      }),
    );
  }

  void _showDownloadAppMenuDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return FocusAwareBuilder(
            builder: (primaryFocusNode) =>
                V3DownloadAppMenu(primaryFocusNode: primaryFocusNode));
      },
    );
  }

  TextSpan _buildTextSpan(
      {required String fullText,
      required List<String> formatTexts,
      required TextStyle formatStyle}) {
    List<TextSpan> spans = [];
    int start = 0;

    while (start < fullText.length) {
      int closestBoldStart = -1;
      String? closestBoldText;

      for (String boldText in formatTexts) {
        int index = fullText.indexOf(boldText, start);
        if (index != -1 &&
            (closestBoldStart == -1 || index < closestBoldStart)) {
          closestBoldStart = index;
          closestBoldText = boldText;
        }
      }

      if (closestBoldStart == -1) {
        spans.add(TextSpan(
          text: fullText.substring(start),
        ));
        break;
      }

      if (closestBoldStart > start) {
        spans.add(TextSpan(
          text: fullText.substring(start, closestBoldStart),
        ));
      }

      spans.add(TextSpan(
        text: closestBoldText,
        style: formatStyle,
      ));

      start = closestBoldStart + closestBoldText!.length;
    }
    return TextSpan(children: spans);
  }
}

/// Step 2: Enter Display Code
///
/// Core functionality component, displayed across all screen sizes
/// Contains V3DisplayCode component to show connection code
class V3InstructionDisplayCode extends StatelessWidget {
  final bool showIcon;

  const V3InstructionDisplayCode({
    super.key,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return V3InstructionStep(
      iconAsset: 'assets/images/ic_item2.svg',
      showIcon: showIcon,
      textContent: AutoHyphenatingText(
        S.of(context).v3_instruction2,
        style: context.tokens.textStyle.airsyncFontTitle.apply(
          color: context.tokens.color.vsdslColorOnSurface,
        ),
        maxLines: 6,
      ),
      actionWidget: const V3DisplayCode(),
    );
  }
}

/// Step 3: Enter OTP Verification Code
///
/// Core functionality component, displayed across all screen sizes
/// Contains V3OtpWithTimer component for OTP input and countdown
class V3InstructionOtpCode extends StatelessWidget {
  final bool showIcon;

  const V3InstructionOtpCode({
    super.key,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return V3InstructionStep(
      iconAsset: 'assets/images/ic_item3.svg',
      showIcon: showIcon,
      textContent: AutoHyphenatingText(
        S.of(context).v3_instruction3,
        style: context.tokens.textStyle.airsyncFontTitle.apply(
          color: context.tokens.color.vsdslColorOnSurface,
        ),
      ),
      actionWidget: const V3OtpWithTimer(),
      actionPadding: EdgeInsets.only(
        top: context.tokens.spacing.vsdslSpacingXl.top,
        left: showIcon ? 35 : 0,
      ),
    );
  }
}

/// Full version connection instruction composer
///
/// Contains all three steps and complete visual elements
/// Used for:
/// - Full screen landscape layout
/// - 2/3 screen layout
/// - Portrait layout
///
/// Note: Don't modify this component directly, it's preserved for backward compatibility
/// For new combinations, compose step components directly at usage site
class V3Instruction extends StatelessWidget {
  const V3Instruction({
    super.key,
    this.isQuickConnect = false,
    this.isCastToDevice = false,
  });

  final bool isQuickConnect;
  final bool isCastToDevice;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        V3InstructionHeader(
          isCastToDevice: isCastToDevice,
          isQuickConnect: isQuickConnect,
        ),
        V3InstructionDownloadApp(
          isCastToDevice: isCastToDevice,
          isQuickConnect: isQuickConnect,
          showIcon: true,
        ),
        SizedBox(height: context.tokens.spacing.vsdslSpacing3xl.top),
        V3InstructionDisplayCode(showIcon: true),
        SizedBox(height: context.tokens.spacing.vsdslSpacing3xl.top),
        V3InstructionOtpCode(showIcon: true),
      ],
    );
  }
}
