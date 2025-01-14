import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/providers/settings_provider.dart';
import 'package:display_flutter/widgets/v3_custom_checkbox.dart';
import 'package:display_flutter/widgets/v3_setting_2ndLayer.dart';
import 'package:display_flutter/widgets/v3_setting_menu_sub_item_focus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class V3SettingsMirroring extends StatelessWidget {
  const V3SettingsMirroring({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(builder: (_, settingsProvider, __) {
      ChannelProvider channelProvider =
          Provider.of<ChannelProvider>(context, listen: false);
      var disable =
          ChannelProvider.isModeratorMode || settingsProvider.isMirroringLock;
      return V3Setting2ndLayer(
        isDisable: settingsProvider.isMirroringLock,
        isDisableFromModerator: ChannelProvider.isModeratorMode,
        child: Consumer<MirrorStateProvider>(
          builder: (context, mirrorStateProvider, _) {
            return Column(
              children: [
                MirroringItem(
                    isDisable: disable,
                    focusNode: settingsProvider.subFocusNode,
                    name: S.of(context).v3_shortcuts_airplay,
                    mirrorEnabled: mirrorStateProvider.airplayEnabled,
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
                        target:
                            mirrorStateProvider.airplayEnabled ? 'on' : 'off',
                      );
                    }),
                if (mirrorStateProvider.airplayEnabled)
                  V3SettingMenuSubItemFocus(
                    child: Focus(
                      child: SizedBox(
                        height: 26,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: V3CustomCheckbox(
                                isDisable: disable,
                                value: mirrorStateProvider.airPlayCodeEnable,
                                onChanged: (bool? value) {
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
                              S
                                  .of(context)
                                  .v3_settings_mirroring_require_passcode,
                              style: TextStyle(
                                fontSize: 12,
                                color: context.tokens.color.vsdslColorOnPrimary,
                              ),
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Gap(context.tokens.spacing.vsdslSpacingSm.bottom),
                MirroringItem(
                    isDisable: disable,
                    name: S.of(context).v3_shortcuts_google_cast,
                    mirrorEnabled: mirrorStateProvider.googleCastEnabled,
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
                        target: mirrorStateProvider.googleCastEnabled
                            ? 'on'
                            : 'off',
                      );
                    }),
                Gap(context.tokens.spacing.vsdslSpacingSm.bottom),
                MirroringItem(
                    isDisable: disable,
                    name: S.of(context).v3_shortcuts_miracast,
                    mirrorEnabled: mirrorStateProvider.miracastEnabled,
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
                V3SettingMenuSubItemFocus(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: V3CustomCheckbox(
                            isDisable: disable,
                            value: !mirrorStateProvider.isMirrorConfirmation,
                            onChanged: (bool? value) {
                              mirrorStateProvider.isMirrorConfirmation =
                                  !mirrorStateProvider.isMirrorConfirmation;

                              trackEvent(
                                'click_auto_accept',
                                EventCategory.setting,
                                target: mirrorStateProvider.isMirrorConfirmation
                                    ? 'on'
                                    : 'off',
                              );
                            }),
                      ),
                      Gap(context.tokens.spacing.vsdslSpacingSm.right),
                      AutoSizeText(
                        S.of(context).v3_settings_mirroring_auto_accept,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.tokens.color.vsdslColorOnPrimary,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      bottom: context.tokens.spacing.vsdslSpacingSm.bottom,
                      left: 20 + context.tokens.spacing.vsdslSpacingSm.right),
                  child: AutoSizeText(
                    S.of(context).v3_settings_mirroring_auto_accept_desc,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.tokens.color.vsdslColorOnSurfaceVariant,
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            );
          },
        ),
      );
    });
  }
}

class MirroringItem extends StatelessWidget {
  const MirroringItem({
    super.key,
    this.isDisable = false,
    required this.name,
    required this.mirrorEnabled,
    required this.callback,
    this.focusNode,
  });

  final bool isDisable;
  final String name;
  final bool mirrorEnabled;
  final VoidCallback callback;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return V3SettingMenuSubItemFocus(
      child: SizedBox(
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
              focusNode: focusNode,
              onTap: isDisable ? null : callback,
              child: Opacity(
                opacity: isDisable ? 0.32 : 1,
                child: SvgPicture.asset(
                  mirrorEnabled
                      ? 'assets/images/ic_switch_on.svg'
                      : 'assets/images/ic_switch_off.svg',
                  width: 36,
                  height: 21,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
