import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/screens/v3_cast_devices_menu.dart';
import 'package:display_flutter/utility/device_feature_adapter.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:provider/provider.dart';

class V3ShortcutsMenu extends StatelessWidget {
  const V3ShortcutsMenu({super.key, required this.primaryFocusNode});

  static int _debugCounter = 0;
  final FocusNode primaryFocusNode;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: context.tokens.radii.vsdslRadiusXl,
      ),
      alignment: Alignment.bottomLeft,
      backgroundColor: const Color(0xFF151C32),
      insetPadding: const EdgeInsets.only(left: 70, bottom: 70),
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
                    DeviceFeatureAdapter.showDebugOverlay =
                        !DeviceFeatureAdapter.showDebugOverlay;
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
                  V3Focus(
                    label: S
                        .of(context)
                        .v3_lbl_streaming_shortcut_cast_device_toggle,
                    identifier: 'v3_qa_streaming_shortcut_cast_device_toggle',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            S.of(context).v3_shortcuts_cast_device,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: context
                                  .tokens.color.vsdslColorOnSurfaceInverse,
                            ),
                            maxLines: 3,
                          ),
                        ),
                        Consumer<ChannelProvider>(
                            builder: (_, channelProvider, __) {
                          return SizedBox(
                            height: 21,
                            width: 37,
                            child: IconButton(
                              icon: SvgPicture.asset(
                                channelProvider.isSenderMode
                                    ? 'assets/images/ic_switch_on.svg'
                                    : 'assets/images/ic_switch_off.svg',
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                if (channelProvider.isSenderMode) {
                                  channelProvider.removeSender(
                                      fromSender: true);
                                } else {
                                  V3CastDevicesMenu.fromShortcut = true;
                                  channelProvider.startRemoteScreen(
                                      fromSender: true);
                                  if (navService.canPop()) {
                                    navService.goBack();
                                  }
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
                  Consumer<MirrorStateProvider>(
                    builder: (_, mirrorStateProvider, __) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            S.of(context).v3_shortcuts_mirroring,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: context
                                  .tokens.color.vsdslColorOnSurfaceInverse,
                            ),
                          ),
                          V3Focus(
                            label: S
                                .of(context)
                                .v3_lbl_streaming_shortcut_airplay_toggle,
                            identifier:
                                'v3_qa_streaming_shortcut_airplay_toggle',
                            child: Row(
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
                                      color: context.tokens.color
                                          .vsdslColorOnSurfaceInverse,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 21,
                                  child: IconButton(
                                    icon: SvgPicture.asset(
                                      mirrorStateProvider.airplayEnabled
                                          ? 'assets/images/ic_switch_on.svg'
                                          : 'assets/images/ic_switch_off.svg',
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      if (mirrorStateProvider.airplayEnabled) {
                                        mirrorStateProvider.stopAirPlay();
                                        false;
                                      } else {
                                        mirrorStateProvider.startAirPlay();
                                      }

                                      trackEvent(
                                        'click_airplay',
                                        EventCategory.quickMenu,
                                        target:
                                            mirrorStateProvider.airplayEnabled
                                                ? 'on'
                                                : 'off',
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          V3Focus(
                            label: S
                                .of(context)
                                .v3_lbl_streaming_shortcut_google_cast_toggle,
                            identifier:
                                'v3_qa_streaming_shortcut_google_cast_toggle',
                            child: Row(
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
                                      color: context.tokens.color
                                          .vsdslColorOnSurfaceInverse,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 21,
                                  child: IconButton(
                                    icon: SvgPicture.asset(
                                      mirrorStateProvider.googleCastEnabled
                                          ? 'assets/images/ic_switch_on.svg'
                                          : 'assets/images/ic_switch_off.svg',
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      if (mirrorStateProvider
                                          .googleCastEnabled) {
                                        mirrorStateProvider.stopGoogleCast();
                                        false;
                                      } else {
                                        mirrorStateProvider.startGoogleCast();
                                      }

                                      trackEvent(
                                        'click_google_cast',
                                        EventCategory.quickMenu,
                                        target: mirrorStateProvider
                                                .googleCastEnabled
                                            ? 'on'
                                            : 'off',
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (mirrorStateProvider.miracastSupport) ...[
                            V3Focus(
                              label: S
                                  .of(context)
                                  .v3_lbl_streaming_shortcut_miracast_toggle,
                              identifier:
                                  'v3_qa_streaming_shortcut_miracast_toggle',
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                        color: context.tokens.color
                                            .vsdslColorOnSurfaceInverse,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 21,
                                    child: IconButton(
                                      icon: Opacity(
                                        opacity: mirrorStateProvider
                                                .isVB005AndDFSChannel
                                            ? 0.32
                                            : 1,
                                        child: SvgPicture.asset(
                                          mirrorStateProvider.miracastEnabled &&
                                                  !mirrorStateProvider
                                                      .isVB005AndDFSChannel
                                              ? 'assets/images/ic_switch_on.svg'
                                              : 'assets/images/ic_switch_off.svg',
                                        ),
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () {
                                        if (mirrorStateProvider
                                            .miracastEnabled) {
                                          mirrorStateProvider.stopMiracast();
                                        } else {
                                          mirrorStateProvider.startMiracast();
                                        }

                                        trackEvent(
                                          'click_miracast',
                                          EventCategory.quickMenu,
                                          target: mirrorStateProvider
                                                  .miracastEnabled
                                              ? 'on'
                                              : 'off',
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (mirrorStateProvider.isVB005AndDFSChannel)
                              Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color:
                                      context.tokens.color.vsdslColorSurface900,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: context.tokens.spacing.vsdslSpacingLg,
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/images/ic_toast_alert.svg',
                                      width: 16,
                                      height: 16,
                                    ),
                                    Gap(context
                                        .tokens.spacing.vsdslSpacingLg.right),
                                    SizedBox(
                                      width: 200,
                                      child: AutoSizeText(
                                        S.of(context).v3_miracast_not_support,
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w400,
                                          color: context
                                              .tokens.color.vsdslColorWarning,
                                        ),
                                        minFontSize: 8,
                                        maxLines: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ]
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              left: 8,
              bottom: 8,
              child: V3Focus(
                label: S.of(context).v3_lbl_close_streaming_shortcut_menu,
                identifier: 'v3_qa_close_streaming_shortcut_menu',
                child: SizedBox(
                  width: 33,
                  height: 33,
                  child: IconButton(
                    focusNode: primaryFocusNode,
                    icon: SvgPicture.asset('assets/images/ic_menu_close.svg'),
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
            ),
          ],
        ),
      ),
    );
  }
}
