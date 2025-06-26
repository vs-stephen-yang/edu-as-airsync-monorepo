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
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class V3SettingsMirroring extends StatelessWidget {
  const V3SettingsMirroring({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, MirrorStateProvider>(
        builder: (_, settingsProvider, mirrorStateProvider, __) {
      ChannelProvider channelProvider =
          Provider.of<ChannelProvider>(context, listen: false);
      var disable = settingsProvider.isMirroringLock;
      return V3Setting2ndLayer(
        isDisable: settingsProvider.isMirroringLock,
        isDisableFromNotSupport: mirrorStateProvider.miracastSupport &&
            mirrorStateProvider.isVB005AndDFSChannel,
        child: Consumer<MirrorStateProvider>(
          builder: (context, mirrorStateProvider, _) {
            toggleAirPlayCode(bool value) {
              trackEvent(
                'click_airplay_pincode',
                EventCategory.setting,
                target: value ? 'on' : 'off',
              );

              mirrorStateProvider.setAirPlayCodeEnable(value);
            }

            return Column(
              children: [
                MirroringItem(
                    label: S.of(context).v3_lbl_shortcuts_airplay,
                    identifier: 'v3_qa_shortcuts_airplay',
                    excludeSemantics: false,
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
                    excludeSemantics: false,
                    child: Focus(
                      onKeyEvent: (node, event) {
                        if (event is KeyDownEvent &&
                            (event.logicalKey == LogicalKeyboardKey.enter ||
                                event.logicalKey ==
                                    LogicalKeyboardKey.select)) {
                          toggleAirPlayCode(
                              !mirrorStateProvider.airPlayCodeEnable);
                          return KeyEventResult.handled;
                        }
                        return KeyEventResult.ignored;
                      },
                      child: Row(
                        children: [
                          SizedBox(
                            width: 48,
                            height: 48,
                            child: V3CustomCheckbox(
                              label: S
                                  .of(context)
                                  .v3_lbl_settings_mirroring_require_passcode,
                              identifier:
                                  'v3_qa_settings_mirroring_require_passcode',
                              isDisable: disable,
                              value: mirrorStateProvider.airPlayCodeEnable,
                              onChanged: (bool? value) {
                                if (value != null) {
                                  toggleAirPlayCode(value);
                                }
                              },
                            ),
                          ),
                          Gap(context.tokens.spacing.vsdslSpacingSm.right),
                          Flexible(
                            child: Text(
                              S
                                  .of(context)
                                  .v3_settings_mirroring_require_passcode,
                              style: TextStyle(
                                fontSize: 12,
                                color: context
                                    .tokens.color.vsdslColorOnSurfaceInverse,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Gap(context.tokens.spacing.vsdslSpacingSm.bottom),
                MirroringItem(
                    label: S.of(context).v3_lbl_shortcuts_google_cast,
                    identifier: 'v3_qa_shortcuts_google_cast',
                    excludeSemantics: false,
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
                if (mirrorStateProvider.miracastSupport)
                  MirroringItem(
                      label: S.of(context).v3_lbl_shortcuts_miracast,
                      identifier: 'v3_qa_shortcuts_miracast',
                      excludeSemantics: false,
                      isDisable:
                          disable || mirrorStateProvider.isVB005AndDFSChannel,
                      name: S.of(context).v3_shortcuts_miracast,
                      mirrorEnabled: mirrorStateProvider.miracastEnabled &&
                          !mirrorStateProvider.isVB005AndDFSChannel,
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
                          target: mirrorStateProvider.miracastEnabled
                              ? 'on'
                              : 'off',
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
                  excludeSemantics: false,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 48,
                            height: 48,
                            child: V3CustomCheckbox(
                                label: S
                                    .of(context)
                                    .v3_lbl_settings_mirroring_auto_accept,
                                identifier:
                                    'v3_qa_settings_mirroring_auto_accept',
                                isDisable: disable,
                                value:
                                    !mirrorStateProvider.isMirrorConfirmation,
                                onChanged: (bool? value) {
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
                          Flexible(
                            child: Text(
                              S.of(context).v3_settings_mirroring_auto_accept,
                              style: TextStyle(
                                fontSize: 12,
                                color: context
                                    .tokens.color.vsdslColorOnSurfaceInverse,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            bottom:
                                context.tokens.spacing.vsdslSpacingSm.bottom,
                            left: 20 +
                                context.tokens.spacing.vsdslSpacingSm.right),
                        child: Text(
                          S.of(context).v3_settings_mirroring_auto_accept_desc,
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                context.tokens.color.vsdslColorOnSurfaceInverse,
                          ),
                        ),
                      ),
                    ],
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
    this.label,
    this.identifier,
    this.excludeSemantics = true,
  });

  final bool isDisable;
  final String name;
  final bool mirrorEnabled;
  final VoidCallback callback;
  final FocusNode? focusNode;
  final String? label;
  final String? identifier;
  final bool excludeSemantics;

  @override
  Widget build(BuildContext context) {
    return V3SettingMenuSubItemFocus(
      label: label,
      identifier: identifier,
      excludeSemantics: excludeSemantics,
      child: SizedBox(
        height: 48,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 1,
              child: Text(
                name,
                style: TextStyle(
                  color: context.tokens.color.vsdslColorOnSurfaceInverse,
                  fontSize: 12,
                ),
              ),
            ),
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
