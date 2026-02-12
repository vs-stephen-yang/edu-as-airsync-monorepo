import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/appSettings.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/group_list_provider.dart';
import 'package:display_flutter/providers/group_provider.dart';
import 'package:display_flutter/providers/settings_provider.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:display_flutter/widgets/v3_global_toast.dart';
import 'package:display_flutter/widgets/v3_setting_2ndLayer.dart';
import 'package:display_flutter/widgets/v3_setting_menu_sub_item_focus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class V3SettingsBroadcast extends StatelessWidget {
  const V3SettingsBroadcast({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, AppSettings>(
        builder: (_, settingsProvider, appSettings, __) {
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
            // [USER STORY #101732] 多點傳送功能暫時停用
            // Receiver 開啟 Cast to 10-100 Devices 時，Windows/Mac/iOS Sender 接收畫面異常
            // Multicast feature (Cast to 10-100 Devices) temporarily disabled
            // When Receiver enables this feature, Windows/Mac/iOS Sender experiences abnormal screen display
            // Consumer<ChannelProvider>(
            //   builder: (context, channelProvider, _) {
            //     return Column(
            //       children: [
            //         Row(
            //           children: [
            //             SizedBox(
            //               width: 20,
            //               height: 20,
            //               child: V3Focus(
            //                 label: S
            //                     .of(context)
            //                     .v3_lbl_broadcast_multicast_checkbox,
            //                 identifier: "v3_qa_settings_device_authorize_mode",
            //                 child: V3CustomCheckbox(
            //                   value: appSettings.useMulticast,
            //                   isDisable: channelProvider.castModeLocked,
            //                   onChanged: (bool? value) {
            //                     if (value != null) {
            //                       EasyThrottle.throttle('changeCastMode',
            //                           const Duration(milliseconds: 1500),
            //                           () async {
            //                         await channelProvider
            //                             .setAndRestartRemoteScreen(
            //                           appSettings: context.read<AppSettings>(),
            //                           multicast: value,
            //                         );
            //                       });
            //                     }
            //                   },
            //                 ),
            //               ),
            //             ),
            //             const Padding(padding: EdgeInsets.only(left: 4)),
            //             Expanded(
            //               child: InkWell(
            //                 onTap: channelProvider.castModeLocked
            //                     ? null
            //                     : () {
            //                         EasyThrottle.throttle(
            //                           'changeCastMode',
            //                           const Duration(milliseconds: 1500),
            //                           () async {
            //                             final appSettings =
            //                                 context.read<AppSettings>();
            //                             final useMulticast =
            //                                 appSettings.useMulticast;
            //                             await channelProvider
            //                                 .setAndRestartRemoteScreen(
            //                               appSettings: appSettings,
            //                               multicast: !useMulticast,
            //                             );
            //                           },
            //                         );
            //                       },
            //                 child: Container(
            //                   alignment: Alignment.centerLeft,
            //                   constraints: const BoxConstraints(minHeight: 48),
            //                   child: AutoSizeText(
            //                     S.of(context).v3_broadcast_multicast_checkbox,
            //                     style: TextStyle(
            //                       fontSize: 12,
            //                       fontWeight: FontWeight.w400,
            //                       color: context
            //                           .tokens.color.vsdslColorOnSurfaceInverse,
            //                     ),
            //                   ),
            //                 ),
            //               ),
            //             ),
            //           ],
            //         ),
            //         Padding(
            //           padding: EdgeInsets.only(
            //             left: 25,
            //             top: context.tokens.spacing.vsdslSpacingSm.top,
            //             bottom: context.tokens.spacing.vsdslSpacingSm.bottom,
            //           ),
            //           child: Row(
            //             children: [
            //               SvgPicture.asset(
            //                 excludeFromSemantics: true,
            //                 channelProvider.castModeLocked
            //                     ? 'assets/images/ic_multicast_alert.svg'
            //                     : 'assets/images/ic_settings_info.svg',
            //                 width: 22,
            //                 height: 22,
            //               ),
            //               Gap(context.tokens.spacing.vsdslSpacingXs.right),
            //               Expanded(
            //                 child: V3AutoHyphenatingText(
            //                   channelProvider.castModeLocked
            //                       ? S.of(context).v3_broadcast_multicast_warn
            //                       : S.of(context).v3_broadcast_multicast_desc,
            //                   style: TextStyle(
            //                     fontSize: 9,
            //                     color: channelProvider.castModeLocked
            //                         ? context.tokens.color.vsdslColorWarning
            //                         : context.tokens.color
            //                             .vsdslColorOnSurfaceInverse,
            //                     fontWeight: FontWeight.w400,
            //                   ),
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ),
            //       ],
            //     );
            //   },
            // ),
            // Gap(context.tokens.spacing.vsdslSpacingXl.top),
            Container(
              decoration: BoxDecoration(
                borderRadius: context.tokens.radii.vsdslRadiusLg,
                border: Border.all(
                  color: context.tokens.color.vsdslColorOutlineVariant,
                  width: 1.0,
                ),
                color: context.tokens.color.vsdslColorSurface900,
              ),
              child: Column(
                children: [
                  V3SettingMenuSubItemFocus(
                    excludeSemantics: false,
                    child: CastToDevices(
                      settingsProvider: settingsProvider,
                      focusNode: settingsProvider.subFocusNode ?? FocusNode(),
                    ),
                  ),
                  Container(
                    height: 1,
                    margin: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: context.tokens.spacing.vsdslSpacingXs.top,
                    ),
                    color: context.tokens.color.vsdslColorOutlineVariant,
                  ),
                  V3SettingMenuSubItemFocus(
                    excludeSemantics: false,
                    child: CastToBoards(settingsProvider: settingsProvider),
                  ),
                ],
              ),
            ),
            Gap(context.tokens.spacing.vsdslSpacingXl.top),
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
      constraints: const BoxConstraints(minHeight: 88),
      decoration:
          BoxDecoration(borderRadius: context.tokens.radii.vsdslRadiusLg),
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
          Gap(
            context.tokens.spacing.vsdslSpacingXl.left,
          ),
          Expanded(
            child: Column(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 27),
                  child: Row(
                    children: [
                      Expanded(
                        child: V3AutoHyphenatingText(
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
                Gap(context.tokens.spacing.vsdslSpacingSm.top),
                AutoSizeText(
                  S.of(context).v3_shortcuts_cast_device_desc,
                  minFontSize: 8,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    color: context.tokens.color.vsdslColorOnSurfaceInverse,
                  ),
                ),
                Gap(context.tokens.spacing.vsdslSpacingMd.top),
                Selector<ChannelProvider, bool>(
                  selector: (_, p) => p.remoteScreenInProgress,
                  builder: (_, inProgress, __) {
                    if (inProgress) {
                      return Row(
                        children: [
                          SvgPicture.asset(
                            excludeFromSemantics: true,
                            'assets/images/ic_multicast_broadcast.svg',
                            width: 22,
                            height: 22,
                          ),
                          Gap(context.tokens.spacing.vsdslSpacingXs.right),
                          Expanded(
                            child: V3AutoHyphenatingText(
                              S.of(context).v3_broadcast_cast_device_on,
                              style: TextStyle(
                                fontSize: 9,
                                color: context.tokens.color.vsdslColorSuccess,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CastToBoards extends StatefulWidget {
  const CastToBoards({super.key, required this.settingsProvider});

  final SettingsProvider settingsProvider;

  @override
  State<CastToBoards> createState() => _CastToBoardsState();
}

class _CastToBoardsState extends State<CastToBoards> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final settingsProvider = widget.settingsProvider;
    return Container(
      width: 325,
      constraints: const BoxConstraints(minHeight: 88),
      decoration:
          BoxDecoration(borderRadius: context.tokens.radii.vsdslRadiusLg),
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
          Gap(context.tokens.spacing.vsdslSpacingXl.left),
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  child: Row(
                    children: [
                      Expanded(
                        child: V3AutoHyphenatingText(
                          S.of(context).v3_settings_broadcast_boards,
                          style: TextStyle(
                            color:
                                context.tokens.color.vsdslColorOnSurfaceInverse,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Consumer<ChannelProvider>(
                        builder: (_, channelProvider, __) {
                          final ref =
                              riverpod.ProviderScope.containerOf(context);
                          return SizedBox(
                            width: 41,
                            height: 25,
                            child: V3Focus(
                              label: S
                                  .of(context)
                                  .v3_lbl_settings_broadcast_to_display_group,
                              identifier:
                                  "v3_qa_settings_broadcast_to_display_group",
                              child: IconButton(
                                focusNode:
                                    Provider.of<SettingsProvider>(context)
                                        .subFocusNode,
                                icon: SvgPicture.asset(
                                  channelProvider.isGroupMode
                                      ? 'assets/images/ic_switch_on.svg'
                                      : 'assets/images/ic_switch_off.svg',
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: (settingsProvider.isBroadcastLock ||
                                        _isLoading)
                                    ? null
                                    : () async {
                                        // Prevent repeated clicks
                                        if (_isLoading) return;

                                        setState(() => _isLoading = true);

                                        try {
                                          final groupNotifier =
                                              ref.read(groupProvider.notifier);
                                          bool state =
                                              !groupNotifier.broadcastToGroup;

                                          trackEvent(
                                            'click_cast_to_board',
                                            EventCategory.setting,
                                            target: state ? 'on' : 'off',
                                          );

                                          if (state) {
                                            // Try to start remote screen
                                            final success =
                                                await channelProvider
                                                    .startRemoteScreen(
                                                        fromGroup: true);

                                            // Sync state based on actual result
                                            groupNotifier
                                                .setBroadcastToGroup(success);

                                            if (!success) {
                                              // Show error feedback to user
                                              unawaited(GlobalToast.show(
                                                  'Failed to start broadcast'));
                                            }
                                          } else {
                                            GroupListModel discoveryModel = ref
                                                .read(discoveryModelProvider);
                                            await discoveryModel.stop();
                                            channelProvider.stopDisplayGroup();
                                            groupNotifier
                                                .setBroadcastToGroup(false);
                                          }
                                        } catch (e) {
                                          // Handle unexpected errors
                                          log.warning(
                                              'Failed to toggle broadcast: $e');
                                          // Ensure state is consistent
                                          final groupNotifier =
                                              ref.read(groupProvider.notifier);
                                          groupNotifier.setBroadcastToGroup(
                                              channelProvider.isGroupMode);

                                          unawaited(GlobalToast.show(
                                              'Operation failed, please try again'));
                                        } finally {
                                          // Always reset loading state
                                          if (mounted) {
                                            setState(() => _isLoading = false);
                                          }
                                        }
                                      },
                              ),
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
                Gap(context.tokens.spacing.vsdslSpacingSm.top),
                Selector<ChannelProvider, bool>(
                  selector: (_, p) => p.isGroupMode,
                  builder: (_, isGroupMode, __) {
                    return Opacity(
                      opacity: isGroupMode ? 1.0 : 0.3,
                      child: Row(
                        children: [
                          Expanded(
                            child: AutoSizeText(
                              S
                                  .of(context)
                                  .v3_settings_broadcast_cast_boards_desc,
                              minFontSize: 8,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w400,
                                color: context
                                    .tokens.color.vsdslColorOnSurfaceInverse,
                              ),
                            ),
                          ),
                          SizedBox(
                            child: Semantics(
                              label: S
                                  .of(context)
                                  .v3_lbl_settings_broadcast_boards,
                              identifier: 'v3_qa_settings_broadcast_boards',
                              child: InkWell(
                                onTap: settingsProvider.isBroadcastLock ||
                                        !isGroupMode
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
                    );
                  },
                ),
                Gap(context.tokens.spacing.vsdslSpacingMd.top),
                Selector<ChannelProvider, bool>(
                  selector: (_, p) => p.castToBoardInProgress,
                  builder: (_, inProgress, __) {
                    if (inProgress) {
                      return Row(
                        children: [
                          SvgPicture.asset(
                            excludeFromSemantics: true,
                            'assets/images/ic_multicast_broadcast.svg',
                            width: 22,
                            height: 22,
                          ),
                          Gap(context.tokens.spacing.vsdslSpacingXs.right),
                          Expanded(
                            child: V3AutoHyphenatingText(
                              S.of(context).v3_broadcast_cast_board_on,
                              style: TextStyle(
                                fontSize: 9,
                                color: context.tokens.color.vsdslColorSuccess,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
