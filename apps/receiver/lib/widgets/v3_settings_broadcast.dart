import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/settings_provider.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:display_flutter/widgets/v3_setting_2ndLayer.dart';
import 'package:display_flutter/widgets/v3_setting_menu_sub_item_focus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class V3SettingsBroadcast extends StatelessWidget {
  const V3SettingsBroadcast({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(builder: (_, settingsProvider, __) {
      return V3Setting2ndLayer(
        isDisable: settingsProvider.isBroadcastLock,
        showEnergySaving: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoSizeText(
              S.of(context).v3_settings_broadcast_cast_to,
              style: TextStyle(
                color: context.tokens.color.vsdslColorOnSurfaceInverse,
                fontSize: 12,
              ),
            ),
            SizedBox(height: context.tokens.spacing.vsdslSpacingXl.top),
            V3SettingMenuSubItemFocus(
              excludeSemantics: false,
              child: CastToDevices(
                settingsProvider: settingsProvider,
                focusNode: settingsProvider.subFocusNode ?? FocusNode(),
              ),
            ),
            SizedBox(height: context.tokens.spacing.vsdslSpacingMd.top),
            V3SettingMenuSubItemFocus(
                excludeSemantics: false,
                child: CastToBoards(settingsProvider: settingsProvider)),
          ],
        ),
      );
    });
  }
}

class CastToDevices extends StatelessWidget {
  const CastToDevices({
    super.key,
    required this.settingsProvider,
    required this.focusNode,
  });

  final FocusNode focusNode;

  final SettingsProvider settingsProvider;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 325,
      constraints: const BoxConstraints(
        minHeight: 88,
      ),
      decoration: BoxDecoration(
        borderRadius: context.tokens.radii.vsdslRadiusLg,
        color: context.tokens.color.vsdslColorSurface900,
      ),
      padding: context.tokens.spacing.vsdslSpacingXl,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 43,
            height: 43,
            child: SvgPicture.asset(
              'assets/images/ic_cast_to_devices.svg',
            ),
          ),
          SizedBox(
            width: context.tokens.spacing.vsdslSpacingXl.left,
          ),
          Expanded(
            child: Column(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 27),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          S.of(context).v3_settings_broadcast_devices,
                          style: TextStyle(
                            color:
                                context.tokens.color.vsdslColorOnSurfaceInverse,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Consumer<ChannelProvider>(
                        builder: (_, channelProvider, __) {
                          return SizedBox(
                            width: 41,
                            height: 25,
                            child: V3Focus(
                              label: S
                                  .of(context)
                                  .v3_lbl_settings_broadcast_devices,
                              identifier: 'v3_qa_settings_broadcast_devices',
                              child: IconButton(
                                focusNode: focusNode,
                                icon: SvgPicture.asset(
                                  channelProvider.isSenderMode
                                      ? 'assets/images/ic_switch_on.svg'
                                      : 'assets/images/ic_switch_off.svg',
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: settingsProvider.isBroadcastLock
                                    ? null
                                    : () async {
                                        if (channelProvider.isSenderMode) {
                                          await channelProvider.removeSender(
                                              fromSender: true);
                                        } else {
                                          await channelProvider
                                              .startRemoteScreen(
                                                  fromSender: true);
                                        }

                                        trackEvent(
                                          'click_cast_to_device',
                                          EventCategory.setting,
                                          target: channelProvider.isSenderMode
                                              ? 'on'
                                              : 'off',
                                        );
                                      },
                              ),
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
                SizedBox(height: context.tokens.spacing.vsdslSpacingSm.top),
                AutoSizeText(
                  S.of(context).v3_shortcuts_cast_device_desc,
                  minFontSize: 8,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    color: context.tokens.color.vsdslColorOnSurfaceInverse,
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

class CastToBoards extends StatelessWidget {
  const CastToBoards({super.key, required this.settingsProvider});

  final SettingsProvider settingsProvider;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 325,
      constraints: const BoxConstraints(
        minHeight: 88,
      ),
      decoration: BoxDecoration(
        borderRadius: context.tokens.radii.vsdslRadiusLg,
        color: context.tokens.color.vsdslColorSurface900,
      ),
      padding: context.tokens.spacing.vsdslSpacingXl,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            label: S.of(context).v3_lbl_settings_broadcast_boards,
            identifier: 'v3_qa_settings_broadcast_boards',
            child: SvgPicture.asset(
              'assets/images/ic_cast_to_boards.svg',
              width: 43,
              height: 43,
            ),
          ),
          SizedBox(
            width: context.tokens.spacing.vsdslSpacingXl.left,
          ),
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          S.of(context).v3_settings_broadcast_boards,
                          style: TextStyle(
                            color:
                                context.tokens.color.vsdslColorOnSurfaceInverse,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      SizedBox(
                        child: Semantics(
                          label: S.of(context).v3_lbl_settings_broadcast_boards,
                          identifier: 'v3_qa_settings_broadcast_boards',
                          child: InkWell(
                            onTap: settingsProvider.isBroadcastLock
                                ? null
                                : () {
                                    settingsProvider.setPage(
                                        SettingPageState.broadcastBoards);
                                  },
                            child: Container(
                              padding: const EdgeInsets.only(
                                  top: 13, bottom: 13, left: 26),
                              child: SvgPicture.asset(
                                settingsProvider.isBroadcastLock
                                    ? 'assets/images/ic_arrow_right_lock.svg'
                                    : 'assets/images/ic_arrow_right.svg',
                                width: 22,
                                height: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.tokens.spacing.vsdslSpacingSm.top),
                AutoSizeText(
                  S.of(context).v3_settings_broadcast_cast_boards_desc,
                  minFontSize: 8,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    color: context.tokens.color.vsdslColorOnSurfaceInverse,
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
