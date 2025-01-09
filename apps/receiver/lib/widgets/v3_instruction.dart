import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/connectivity_provider.dart';
import 'package:display_flutter/providers/instance_info_provider.dart';
import 'package:display_flutter/screens/v3_download_app_menu.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/widgets/focus_aware_builder.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:gap/gap.dart';
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
          Row(
            children: [
              AutoSizeText(
                S.of(context).v3_instruction_share_screen,
                style: context.tokens.textStyle.airsyncFontTitle.apply(
                    color: context.tokens.color.vsdslColorOnSurface,
                    fontWeightDelta: FontWeight.w700.value),
              ),
              Gap(context.tokens.spacing.vsdslSpacing3xl.right),
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
                            horizontal:
                                context.tokens.spacing.vsdslSpacingXl.left,
                            vertical:
                                context.tokens.spacing.vsdslSpacingSm.top),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Image(
                              image: Svg(
                                  'assets/images/ic_local_connection_only.svg'),
                              width: 21,
                              height: 21,
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: context
                                      .tokens.spacing.vsdslSpacingSm.left),
                              child: AutoSizeText(
                                S.of(context).v3_settings_local_connection_only,
                                style: context
                                    .tokens.textStyle.airsyncFontSubtitle600
                                    .apply(
                                  color:
                                      context.tokens.color.vsdslColorSurface600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const SizedBox();
                    }
                  }),
            ],
          ),
          SizedBox(height: context.tokens.spacing.vsdslSpacing5xl.top),
        ],
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoSizeText.rich(
                          _buildTextSpan(
                            fullText: isInternet &&
                                    (!isCastToDevice || isQuickConnect)
                                ? S
                                    .of(context)
                                    .v3_instruction1a
                                    .replaceAll('airsync.net', airsync)
                                    .replaceAll(
                                        S.current.v3_instruction1b
                                            .toLowerCase(),
                                        '')
                                    .replaceAll(
                                        S.current.v3_cast_to_device_menu_or
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
                          style:
                              context.tokens.textStyle.airsyncFontTitle.apply(
                            color: context.tokens.color.vsdslColorOnSurface,
                          ),
                        ),
                        if (isInternet && !isCastToDevice)
                          Row(
                            children: [
                              AutoSizeText.rich(
                                _buildTextSpan(
                                  fullText: S.current.v3_cast_to_device_menu_or
                                      .toLowerCase(),
                                  formatTexts: [airsync],
                                  formatStyle: TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w700,
                                    color: context
                                        .tokens.color.vsdslColorOnSurface,
                                    letterSpacing: -0.48,
                                  ),
                                ),
                                style: context.tokens.textStyle.airsyncFontTitle
                                    .apply(
                                  color:
                                      context.tokens.color.vsdslColorOnSurface,
                                ),
                              ),
                              V3Focus(
                                child: InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                              color: context.tokens.color
                                                  .vsdslColorOnSurface,
                                              width: 1),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Image(
                                            image: Svg(
                                                'assets/images/ic_download_sender.svg'),
                                            width: 23,
                                            height: 23,
                                          ),
                                          const Gap(5),
                                          Text(
                                            S.current.v3_download_app_title,
                                            style: context.tokens.textStyle
                                                .airsyncFontTitle
                                                .apply(
                                                    color: context.tokens.color
                                                        .vsdslColorOnSurface,
                                                    fontWeightDelta:
                                                        FontWeight.w700.value),
                                          )
                                        ],
                                      ),
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
                  color: context.tokens.color.vsdslColorOnSurface,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: context.tokens.spacing.vsdslSpacingXl.top),
        Padding(
          padding: const EdgeInsets.only(left: 35),
          child: Consumer<InstanceInfoProvider>(
              builder: (_, instanceInfoProvider, __) {
            return AutoSizeText(
              _getDisplayCodeVisualIdentity(instanceInfoProvider.displayCode),
              style: context.tokens.textStyle.airsyncFontDisplay.apply(
                color: context.tokens.color.vsdslColorOnSurface,
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
                  color: context.tokens.color.vsdslColorOnSurface,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: context.tokens.spacing.vsdslSpacingXl.top),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 35),
              child:
                  Consumer<ChannelProvider>(builder: (_, channelProvider, __) {
                return ValueListenableBuilder<String>(
                  valueListenable: channelProvider.otp,
                  builder: (_, otp, __) {
                    return AutoSizeText(
                      otp,
                      style: context.tokens.textStyle.airsyncFontDisplay.apply(
                        color: context.tokens.color.vsdslColorOnSurface,
                      ),
                    );
                  },
                );
              }),
            ),
            const Gap(16),
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
      ],
    );
  }

  _showDownloadAppMenuDialog(BuildContext context) {
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
