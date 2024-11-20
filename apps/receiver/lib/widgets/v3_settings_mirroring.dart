import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class V3SettingsMirroring extends StatelessWidget {
  const V3SettingsMirroring({super.key});

  @override
  Widget build(BuildContext context) {
    ChannelProvider channelProvider =
        Provider.of<ChannelProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.only(left: 13, top: 57, right: 13, bottom: 13),
      child: Consumer<MirrorStateProvider>(
        builder: (BuildContext context, MirrorStateProvider mirrorStateProvider,
            Widget? child) {
          var disable = ChannelProvider.isModeratorMode;
          var colorPrimary = context.tokens.color.vsdslColorPrimary
              .withOpacity(disable ? 0.32 : 1);
          var colorOnPrimary = context.tokens.color.vsdslColorOnPrimary
              .withOpacity(disable ? 0.32 : 1);
          var colorFill = WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              if (states.contains(WidgetState.selected)) {
                return context.tokens.color.vsdslColorPrimary.withOpacity(0.32);
              }
              return Colors.transparent;
            }
            if (states.contains(WidgetState.selected)) {
              return context.tokens.color.vsdslColorPrimary;
            }
            return Colors.transparent;
          });
          return Column(
            children: [
              MirroringItem(
                  name: S.of(context).v3_shortcuts_airplay,
                  enabled: mirrorStateProvider.airplayEnabled,
                  callback: () {
                    if (mirrorStateProvider.airplayEnabled) {
                      mirrorStateProvider.stopAirPlay();
                      channelProvider.blockRtcConnection = false;
                    } else {
                      mirrorStateProvider.startAirPlay();
                      channelProvider.blockRtcConnection = true;
                    }

                    trackEvent(
                      'click_airplay',
                      EventCategory.setting,
                      target: mirrorStateProvider.airplayEnabled ? 'on' : 'off',
                    );
                  }),
              if (mirrorStateProvider.airplayEnabled)
                SizedBox(
                  height: 26,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: mirrorStateProvider.airPlayCodeEnable,
                          side: BorderSide(color: colorOnPrimary, width: 2),
                          activeColor: colorPrimary,
                          checkColor: colorOnPrimary,
                          fillColor: colorFill,
                          onChanged: disable
                              ? null
                              : (bool? value) {
                                  if (value != null) {
                                    trackEvent(
                                      'click_airplay_pincode',
                                      EventCategory.setting,
                                      target: value ? 'on' : 'off',
                                    );

                                    mirrorStateProvider
                                        .setAirPlayCodeEnable(value);
                                  }
                                },
                        ),
                      ),
                      Gap(context.tokens.spacing.vsdslSpacingSm.right),
                      AutoSizeText(
                        S.of(context).v3_settings_mirroring_require_passcode,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.tokens.color.vsdslColorOnPrimary,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              Gap(context.tokens.spacing.vsdslSpacingSm.bottom),
              MirroringItem(
                  name: S.of(context).v3_shortcuts_google_cast,
                  enabled: mirrorStateProvider.googleCastEnabled,
                  callback: () {
                    if (mirrorStateProvider.googleCastEnabled) {
                      mirrorStateProvider.stopGoogleCast();
                      channelProvider.blockRtcConnection = false;
                    } else {
                      mirrorStateProvider.startGoogleCast();
                      channelProvider.blockRtcConnection = true;
                    }

                    trackEvent(
                      'click_google_cast',
                      EventCategory.setting,
                      target:
                          mirrorStateProvider.googleCastEnabled ? 'on' : 'off',
                    );
                  }),
              Gap(context.tokens.spacing.vsdslSpacingSm.bottom),
              MirroringItem(
                  name: S.of(context).v3_shortcuts_miracast,
                  enabled: mirrorStateProvider.miracastEnabled,
                  callback: () {
                    if (mirrorStateProvider.miracastEnabled) {
                      mirrorStateProvider.stopMiracast();
                      channelProvider.blockRtcConnection = false;
                    } else {
                      mirrorStateProvider.startMiracast();
                      channelProvider.blockRtcConnection = true;
                    }

                    trackEvent(
                      'click_miracast',
                      EventCategory.setting,
                      target:
                          mirrorStateProvider.miracastEnabled ? 'on' : 'off',
                    );
                  }),
              Container(
                height: 1,
                margin: EdgeInsets.only(
                    top: context.tokens.spacing.vsdslSpacingSm.top,
                    bottom: context.tokens.spacing.vsdslSpacingSm.bottom),
                color: context.tokens.color.vsdslColorOutlineVariant,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                        value: !mirrorStateProvider.isMirrorConfirmation,
                        side: BorderSide(color: colorOnPrimary, width: 2),
                        activeColor: colorPrimary,
                        checkColor: colorOnPrimary,
                        fillColor: colorFill,
                        onChanged: disable
                            ? null
                            : (bool? value) {
                                mirrorStateProvider.isMirrorConfirmation =
                                    !mirrorStateProvider.isMirrorConfirmation;

                                trackEvent(
                            'click_auto_accept',
                            EventCategory.setting,
                            target:
                            mirrorStateProvider.isMirrorConfirmation
                                ? 'on'
                                : 'off',
                          );
                        }),
                  ),
                  Gap(context.tokens.spacing.vsdslSpacingSm.right),
                  AutoSizeText(
                    S
                        .of(context)
                        .v3_settings_mirroring_auto_accept,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.tokens.color.vsdslColorOnPrimary,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(
                    bottom: context.tokens.spacing.vsdslSpacingSm.bottom,
                    left: 20 + context.tokens.spacing.vsdslSpacingSm.right),
                child: AutoSizeText(
                  S
                      .of(context)
                      .v3_settings_mirroring_auto_accept_desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.tokens.color.vsdslColorOnSurfaceVariant,
                  ),
                  maxLines: 1,
                ),
              ),
              if (disable) ...[
                const Spacer(),
                Container(
                  width: 325,
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
                          image: Svg('assets/images/ic_toast_alert.svg'),
                        ),
                      ),
                      Gap(context.tokens.spacing.vsdslSpacingLg.right),
                      SizedBox(
                        width: 270,
                        child: AutoSizeText(
                          S
                              .of(context)
                              .v3_settings_mirroring_blocked,
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
              ],
            ],
          );
        },
      ),
    );
  }
}

class MirroringItem extends StatelessWidget {
  const MirroringItem(
      {super.key,
      required this.name,
      required this.enabled,
      required this.callback});

  final String name;
  final bool enabled;
  final VoidCallback callback;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 26,
      child: Row(
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: ChannelProvider.isModeratorMode ? null : callback,
            child: Opacity(
              opacity: ChannelProvider.isModeratorMode ? 0.32 : 1,
              child: Image(
                width: 36,
                height: 21,
                image: Svg(enabled
                    ? 'assets/images/ic_switch_on.svg'
                    : 'assets/images/ic_switch_off.svg'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
