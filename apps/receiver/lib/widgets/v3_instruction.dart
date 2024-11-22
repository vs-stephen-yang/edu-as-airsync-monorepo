import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/connectivity_provider.dart';
import 'package:display_flutter/providers/instance_info_provider.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';

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
      crossAxisAlignment:
          isQuickConnect ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
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
                  margin: const EdgeInsets.only(bottom: 38),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Image(
                        image:
                            Svg('assets/images/ic_local_connection_only.svg'),
                        width: 21,
                        height: 21,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: context.tokens.spacing.vsdslSpacingSm.left),
                        child: AutoSizeText(
                          S.of(context).v3_settings_local_connection_only,
                          style: context.tokens.textStyle.airsyncFontSubtitle600
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
        if (!isQuickConnect && !isCastToDevice) ...[
          AutoSizeText(
            S.of(context).v3_instruction_share_screen,
            style: context.tokens.textStyle.airsyncFontTitle.apply(
              color: context.tokens.color.vsdslColorSurface600,
            ),
          ),
          SizedBox(height: context.tokens.spacing.vsdslSpacing5xl.top),
        ],
        if (isQuickConnect) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image(
                image: const Svg('assets/images/ic_screen.svg'),
                width: 27,
                height: 27,
                color: context.tokens.color.vsdslColorSurface600,
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: context.tokens.spacing.vsdslSpacingSm.left),
                child: Consumer<InstanceInfoProvider>(
                  builder: (_, instanceInfoProvider, __) {
                    return AutoSizeText(
                      instanceInfoProvider.deviceName,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: context.tokens.color.vsdslColorSurface600,
                        letterSpacing: -0.48,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: context.tokens.spacing.vsdslSpacing4xl.top),
        ],
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Image(
              image: Svg('assets/images/ic_item1.svg'),
              height: 27,
              width: 27,
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: context.tokens.spacing.vsdslSpacingMd.left),
              child: Consumer<ConnectivityProvider>(
                  builder: (_, connectivityProvider, __) {
                return FutureBuilder(
                  future: connectivityProvider.checkInternetConnection(),
                  builder: (context, snapshot) {
                    bool isInternet = false;
                    if (snapshot.hasData) {
                      isInternet = snapshot.data as bool;
                    }
                    String airsync =
                        AppConfig.of(context)?.settings.airSyncUrl ?? '';
                    return AutoSizeText.rich(
                      _buildTextSpan(
                        fullText: isInternet && !isCastToDevice
                            ? S
                                .of(context)
                                .v3_instruction1a
                                .replaceAll('airsync.net', airsync)
                            : S.of(context).v3_instruction1b,
                        formatTexts: [airsync],
                        formatStyle: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          color: context.tokens.color.vsdslColorSurface600,
                          letterSpacing: -0.48,
                        ),
                      ),
                      style: context.tokens.textStyle.airsyncFontTitle.apply(
                        color: context.tokens.color.vsdslColorSurface600,
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
        SizedBox(height: context.tokens.spacing.vsdslSpacing3xl.top),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Image(
              image: Svg('assets/images/ic_item2.svg'),
              height: 27,
              width: 27,
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: context.tokens.spacing.vsdslSpacingMd.left),
              child: AutoSizeText(
                S.of(context).v3_instruction2,
                style: context.tokens.textStyle.airsyncFontTitle.apply(
                  color: context.tokens.color.vsdslColorSurface600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: context.tokens.spacing.vsdslSpacingXl.top),
        Padding(
          padding: isQuickConnect
              ? EdgeInsets.zero
              : const EdgeInsets.only(left: 35),
          child: Consumer<InstanceInfoProvider>(
              builder: (_, instanceInfoProvider, __) {
            return AutoSizeText(
              _getDisplayCodeVisualIdentity(instanceInfoProvider.displayCode),
              style: context.tokens.textStyle.airsyncFontDisplay.apply(
                color: context.tokens.color.vsdslColorSurface700,
              ),
            );
          }),
        ),
        SizedBox(height: context.tokens.spacing.vsdslSpacing3xl.top),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Image(
              image: Svg('assets/images/ic_item3.svg'),
              height: 27,
              width: 27,
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: context.tokens.spacing.vsdslSpacingMd.left),
              child: AutoSizeText(
                S.of(context).v3_instruction3,
                style: context.tokens.textStyle.airsyncFontTitle.apply(
                  color: context.tokens.color.vsdslColorSurface600,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: context.tokens.spacing.vsdslSpacingMd.left),
              child:
                  Consumer<ChannelProvider>(builder: (_, channelProvider, __) {
                return ValueListenableBuilder<int>(
                  valueListenable: channelProvider.countDownProgress,
                  builder: (_, progress, __) {
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(math.pi),
                      child: SizedBox(
                        width: 27,
                        height: 27,
                        child: CircularProgressIndicator(
                          value: progress / channelProvider.maxCountDown,
                          strokeWidth: 4,
                          backgroundColor: const Color(0xFFE9EAF0),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF636D8A)),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
        SizedBox(height: context.tokens.spacing.vsdslSpacingXl.top),
        Padding(
          padding: isQuickConnect
              ? EdgeInsets.zero
              : const EdgeInsets.only(left: 35),
          child: Consumer<ChannelProvider>(builder: (_, channelProvider, __) {
            return ValueListenableBuilder<String>(
              valueListenable: channelProvider.otp,
              builder: (_, otp, __) {
                return AutoSizeText(
                  otp,
                  style: context.tokens.textStyle.airsyncFontDisplay.apply(
                    color: context.tokens.color.vsdslColorSurface700,
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
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

  TextSpan _buildTextSpan(
      {required String fullText,
      required List<String> formatTexts,
      required TextStyle formatStyle}) {
    List<TextSpan> spans = [];
    int start = 0;

    // Process text based on each substring that needs to be formatted
    while (start < fullText.length) {
      int closestBoldStart = -1;
      String? closestBoldText;

      // Find the earliest occurrence of format text
      for (String boldText in formatTexts) {
        int index = fullText.indexOf(boldText, start);
        if (index != -1 &&
            (closestBoldStart == -1 || index < closestBoldStart)) {
          closestBoldStart = index;
          closestBoldText = boldText;
        }
      }

      // If there is no more format text, add the remaining text
      if (closestBoldStart == -1) {
        spans.add(TextSpan(
          text: fullText.substring(start),
        ));
        break;
      }

      // Add the normal part before the format text
      if (closestBoldStart > start) {
        spans.add(TextSpan(
          text: fullText.substring(start, closestBoldStart),
        ));
      }

      // Add format text
      spans.add(TextSpan(
        text: closestBoldText,
        style: formatStyle,
      ));

      // Update the start position
      start = closestBoldStart + closestBoldText!.length;
    }
    return TextSpan(children: spans);
  }
}
