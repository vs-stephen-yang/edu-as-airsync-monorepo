import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/utility/device_feature_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:gap/gap.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:provider/provider.dart';

class V3ShortcutsMenu extends StatelessWidget {
  const V3ShortcutsMenu({super.key});

  static int _debugCounter = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: context.tokens.radii.vsdslRadiusXl,
      ),
      alignment: Alignment.bottomLeft,
      backgroundColor: const Color(0xFF151C32),
      insetPadding: const EdgeInsets.only(left: 8, bottom: 8),
      elevation: 16.0,
      shadowColor: context.tokens.color.vsdslColorOpacityNeutralSm,
      child: SizedBox(
        width: 226,
        height: 358,
        child: Stack(
          children: [
            Positioned(
              left: 13,
              top: 13,
              right: 13,
              child: GestureDetector(
                onTap: () {
                  _debugCounter++;
                  if (_debugCounter >= 5) {
                    DeviceFeatureAdapter.showDebugOverlay = !DeviceFeatureAdapter.showDebugOverlay;
                    _debugCounter = 0;
                  }
                },
                child: AutoSizeText(
                  S.of(context).v3_shortcuts_menu_title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.tokens.color.vsdslColorOnSurfaceInverse,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 13,
              top: 57,
              right: 13,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 27,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AutoSizeText(
                          S.of(context).v3_shortcuts_cast_device,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color:
                                context.tokens.color.vsdslColorOnSurfaceInverse,
                          ),
                        ),
                        Consumer<ChannelProvider>(
                            builder: (_, channelProvider, __) {
                          return SizedBox(
                            height: 21,
                            child: IconButton(
                              icon: Image(
                                image: Svg(channelProvider.isSenderMode
                                    ? 'assets/images/ic_switch_on.svg'
                                    : 'assets/images/ic_switch_off.svg'),
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                if (channelProvider.isSenderMode) {
                                  channelProvider.removeSender(
                                      fromSender: true);
                                } else {
                                  channelProvider.startRemoteScreen(
                                      fromSender: true);
                                }

                                trackEvent(
                                  'click_cast_to_device',
                                  EventCategory.quickMenu,
                                  target: channelProvider.isSenderMode
                                      ? 'on'
                                      : 'off',
                                );
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  SizedBox(height: context.tokens.spacing.vsdslSpacingSm.top),
                  AutoSizeText(
                    S.of(context).v3_shortcuts_cast_device_desc,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: context.tokens.color.vsdslColorOnSurfaceVariant,
                    ),
                    minFontSize: 8,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Container(
                      height: 1,
                      color: context.tokens.color.vsdslColorOutlineVariant,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        S.of(context).v3_shortcuts_mirroring,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: ChannelProvider.isModeratorMode
                              ? context.tokens.color.vsdslColorOnSurfaceVariant
                              : context.tokens.color.vsdslColorOnSurfaceInverse,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 13,
                            ),
                            child: AutoSizeText(
                              S.of(context).v3_shortcuts_airplay,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: context
                                    .tokens.color.vsdslColorOnSurfaceInverse,
                              ),
                            ),
                          ),
                          Consumer<MirrorStateProvider>(
                              builder: (_, mirrorStateProvider, __) {
                            return SizedBox(
                              height: 21,
                              child: IconButton(
                                icon: Opacity(
                                  opacity: ChannelProvider.isModeratorMode
                                      ? 0.32
                                      : 1,
                                  child: Image(
                                    image: Svg(mirrorStateProvider
                                            .airplayEnabled
                                        ? 'assets/images/ic_switch_on.svg'
                                        : 'assets/images/ic_switch_off.svg'),
                                  ),
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: ChannelProvider.isModeratorMode
                                    ? null
                                    : () {
                                        ChannelProvider channelProvider =
                                      Provider.of<ChannelProvider>(context,
                                          listen: false);
                                  if (mirrorStateProvider.airplayEnabled) {
                                    mirrorStateProvider.stopAirPlay();
                                    channelProvider.blockRtcConnection = false;
                                  } else {
                                    mirrorStateProvider.startAirPlay();
                                    channelProvider.blockRtcConnection = true;
                                  }

                                  trackEvent(
                                    'click_airplay',
                                    EventCategory.quickMenu,
                                    target: mirrorStateProvider.airplayEnabled
                                        ? 'on'
                                        : 'off',
                                  );
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 13,
                            ),
                            child: AutoSizeText(
                              S.of(context).v3_shortcuts_google_cast,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: context
                                    .tokens.color.vsdslColorOnSurfaceInverse,
                              ),
                            ),
                          ),
                          Consumer<MirrorStateProvider>(
                              builder: (_, mirrorStateProvider, __) {
                            return SizedBox(
                              height: 21,
                              child: IconButton(
                                icon: Opacity(
                                  opacity: ChannelProvider.isModeratorMode
                                      ? 0.32
                                      : 1,
                                  child: Image(
                                    image: Svg(mirrorStateProvider
                                            .googleCastEnabled
                                        ? 'assets/images/ic_switch_on.svg'
                                        : 'assets/images/ic_switch_off.svg'),
                                  ),
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: ChannelProvider.isModeratorMode
                                    ? null
                                    : () {
                                        ChannelProvider channelProvider =
                                      Provider.of<ChannelProvider>(context,
                                          listen: false);
                                  if (mirrorStateProvider.googleCastEnabled) {
                                    mirrorStateProvider.stopGoogleCast();
                                    channelProvider.blockRtcConnection = false;
                                  } else {
                                    mirrorStateProvider.startGoogleCast();
                                    channelProvider.blockRtcConnection = true;
                                  }

                                  trackEvent(
                                    'click_google_cast',
                                    EventCategory.quickMenu,
                                    target:
                                        mirrorStateProvider.googleCastEnabled
                                            ? 'on'
                                            : 'off',
                                  );
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 13,
                            ),
                            child: AutoSizeText(
                              S.of(context).v3_shortcuts_miracast,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: context
                                    .tokens.color.vsdslColorOnSurfaceInverse,
                              ),
                            ),
                          ),
                          Consumer<MirrorStateProvider>(
                              builder: (_, mirrorStateProvider, __) {
                            return SizedBox(
                              height: 21,
                              child: IconButton(
                                icon: Opacity(
                                  opacity: ChannelProvider.isModeratorMode
                                      ? 0.32
                                      : 1,
                                  child: Image(
                                    image: Svg(mirrorStateProvider
                                            .miracastEnabled
                                        ? 'assets/images/ic_switch_on.svg'
                                        : 'assets/images/ic_switch_off.svg'),
                                  ),
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: ChannelProvider.isModeratorMode
                                    ? null
                                    : () {
                                        ChannelProvider channelProvider =
                                      Provider.of<ChannelProvider>(context,
                                          listen: false);
                                  if (mirrorStateProvider.miracastEnabled) {
                                    mirrorStateProvider.stopMiracast();
                                    channelProvider.blockRtcConnection = false;
                                  } else {
                                    mirrorStateProvider.startMiracast();
                                    channelProvider.blockRtcConnection = true;
                                  }

                                  trackEvent(
                                    'click_miracast',
                                    EventCategory.quickMenu,
                                    target: mirrorStateProvider.miracastEnabled
                                        ? 'on'
                                        : 'off',
                                  );
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                      if (ChannelProvider.isModeratorMode) ...[
                        const Padding(
                            padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 13,
                        )),
                        Container(
                          height: 51,
                          decoration: BoxDecoration(
                            color: context.tokens.color.vsdslColorSurface900,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: context.tokens.spacing.vsdslSpacingXl,
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 16,
                                child: Image(
                                  image:
                                      Svg('assets/images/ic_toast_alert.svg'),
                                ),
                              ),
                              Gap(context.tokens.spacing.vsdslSpacingLg.right),
                              SizedBox(
                                width: 200,
                                child: AutoSizeText(
                                  S.of(context).v3_settings_mirroring_blocked,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w400,
                                    color:
                                        context.tokens.color.vsdslColorWarning,
                                  ),
                                  minFontSize: 8,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              left: 8,
              bottom: 8,
              child: SizedBox(
                width: 33,
                height: 33,
                child: IconButton(
                  icon: const Image(
                    image: Svg('assets/images/ic_menu_close.svg'),
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    if (navService.canPop()) {
                      navService.goBack();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
