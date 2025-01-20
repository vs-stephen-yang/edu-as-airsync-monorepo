import 'dart:developer';

import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/group_list_item.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/group_list_provider.dart';
import 'package:display_flutter/providers/group_provider.dart';
import 'package:display_flutter/providers/settings_provider.dart';
import 'package:display_flutter/screens/v3_setting_menu.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:display_flutter/widgets/v3_menu_back_icon_button.dart';
import 'package:display_flutter/widgets/v3_setting_menu_item_toggle_tile.dart';
import 'package:display_flutter/widgets/v3_setting_menu_list_item_focus.dart';
import 'package:display_flutter/widgets/v3_setting_menu_sub_item_focus.dart';
import 'package:display_flutter/widgets/v3_settings_device.dart';
import 'package:display_flutter/widgets/v3_settings_radio_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart' as provider;

class V3SettingsCastToBoards extends ConsumerStatefulWidget {
  const V3SettingsCastToBoards({super.key});

  @override
  V3SettingsCastToBoardsState createState() => V3SettingsCastToBoardsState();
}

class V3SettingsCastToBoardsState
    extends ConsumerState<V3SettingsCastToBoards> {
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(groupProvider.notifier).organizeGroupList();
    });
  }

  @override
  void deactivate() {
    GroupListModel discoveryModel = ref.read(discoveryModelProvider);
    discoveryModel.stop();
    super.deactivate();
  }

  @override
  void dispose() {
    removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SettingsProvider settingsProvider =
        provider.Provider.of<SettingsProvider>(context, listen: false);
    final ChannelProvider channelProvider =
        provider.Provider.of<ChannelProvider>(context, listen: false);
    final groupNotifier = ref.read(groupProvider.notifier);
    final isBroadcastingToGroup =
        ref.watch(groupProvider.select((state) => state.broadcastToGroup));
    final broadcastType = ref
        .watch(groupProvider.select((state) => state.broadcastGroupLaunchType));
    final GroupListModel discoveryModel = ref.read(discoveryModelProvider);
    discoveryModel.groupProvider = groupNotifier;
    if (isBroadcastingToGroup) {
      discoveryModel.start(context: context);
    } else {
      discoveryModel.stop();
    }
    return Stack(
      children: [
        Positioned(
            left: 0, top: 0, child: _buildTittle(settingsProvider, context)),
        Positioned(
            left: 13,
            top: 57,
            right: 13,
            child: _buildContent(context, groupNotifier, isBroadcastingToGroup,
                channelProvider)),
        if (isBroadcastingToGroup)
          Positioned(
            left: 13,
            right: 13,
            bottom: 13,
            child: _buildHintAndActionButton(context, broadcastType,
                settingsProvider, channelProvider, groupNotifier),
          )
      ],
    );
  }

  void _trackEvent(
    String name,
    List<GroupListItem> members,
  ) {
    // Assuming GroupListItem has a property called 'name' that you want to concatenate
    final membersString =
        members.map((member) => member.displayCode()).join(',');

    trackEvent(
      name,
      EventCategory.setting,
      target: membersString,
    );
  }

  SizedBox _buildHintAndActionButton(
      BuildContext context,
      BroadcastGroupLaunchType broadcastType,
      SettingsProvider settingsProvider,
      ChannelProvider channelProvider,
      GroupProvider groupNotifier) {
    final selectedListEmpty = groupNotifier.selectedList.isEmpty;

    final String hintText =
        broadcastType == BroadcastGroupLaunchType.onlyWhenCasting
            ? S.of(context).v3_settings_only_when_casting_info
            : S.of(context).v3_settings_all_the_time_info;

    return SizedBox(
      height: 30,
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Image(
              width: 20,
              height: 20,
              image: Svg('assets/images/ic_settings_info.svg'),
            ),
            Gap(context.tokens.spacing.vsdslSpacingSm.right),
            Expanded(
              child: Text(
                hintText,
                style: TextStyle(
                  fontSize: 9,
                  color: context.tokens.color.vsdslColorOnSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            Gap(context.tokens.spacing.vsdslSpacingSm.right),
            broadcastType == BroadcastGroupLaunchType.onlyWhenCasting
                ? _customButton(
                    context, S.of(context).v3_settings_device_name_save,
                    onClick: () {
                    _trackEvent(
                        'click_save_target', groupNotifier.selectedList);

                    if (selectedListEmpty) {
                      showDialogOverlay(
                        onConfirm: () {},
                      );
                    } else {
                      AppPreferences().setGroupSelectedList(
                          groupNotifier.historySelectedList);
                      settingsProvider.setPage(SettingPageState.deviceSetting);
                    }
                  })
                : _customButton(
                    context,
                    S.of(context).v3_settings_display_group_cast,
                    isBroadcast: true,
                    onClick: () {
                      if (selectedListEmpty) {
                        showDialogOverlay(
                          onConfirm: () {},
                        );
                      } else {
                        startDisplayGroup(groupNotifier, channelProvider);
                        _trackEvent(
                            'click_broadcast', groupNotifier.selectedList);
                      }
                    },
                  ),
          ],
        ),
      ),
    );
  }

  void startDisplayGroup(
      GroupProvider groupNotifier, ChannelProvider channelProvider) {
    AppPreferences().setGroupSelectedList(groupNotifier.historySelectedList);
    channelProvider.startDisplayGroup(groupNotifier.selectedList);
  }

  void removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
  }

  void showDialogOverlay({VoidCallback? onConfirm}) {
    removeOverlay();

    assert(_overlayEntry == null);
    final FocusNode focusNode = FocusNode(
      onKeyEvent: (node, event) {
        final enterPressedWithShift = event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.arrowUp ||
                event.logicalKey == LogicalKeyboardKey.arrowDown ||
                event.logicalKey == LogicalKeyboardKey.arrowLeft ||
                event.logicalKey == LogicalKeyboardKey.arrowRight);
        if (enterPressedWithShift) {
          return KeyEventResult.handled;
        } else {
          return KeyEventResult.ignored;
        }
      },
    );

    // When the dialog is opened with a logical key, the focus node should be focused.
    if (HardwareKeyboard.instance.logicalKeysPressed.isNotEmpty) {
      focusNode.requestFocus();
    }

    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return TapRegion(
          groupId: V3SettingMenu.settingMenuGroupId,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.3),
            alignment: Alignment.center,
            child: Container(
              width: 350,
              height: 192,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.tokens.color.vsdslColorSurface100,
                borderRadius: BorderRadius.circular(
                    context.tokens.radii.vsdslRadiusXl.topLeft.x),
                border: Border.all(
                    color: context.tokens.color.vsdslColorSurface100,
                    width: 1.0),
                boxShadow: context.tokens.shadow.vsdslShadowNeutralXl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Gap(24),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        S.current.v3_group_dialog_no_device_message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: context.tokens.color.vsdslColorNeutral,
                            ),
                      ),
                    ),
                  ),
                  const Gap(24),
                  V3Focus(
                    child: ElevatedButton(
                      focusNode: focusNode,
                      style: ButtonStyle(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.pressed)) {
                              return context.tokens.color.vsdslColorSurface300;
                            }
                            return context
                                .tokens.color.vsdslColorOnSurfaceInverse;
                          },
                        ),
                        backgroundColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.pressed)) {
                              return context
                                  .tokens.color.vsdslColorPrimaryVariant;
                            }
                            return context.tokens.color.vsdslColorPrimary;
                          },
                        ),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9999),
                          ),
                        ),
                        elevation: WidgetStateProperty.all(4.0),
                      ),
                      onPressed: () {
                        removeOverlay();
                        onConfirm?.call();
                      },
                      child: Text(S.current.v3_moderator_disable_mirror_ok),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    Overlay.of(context, debugRequiredFor: widget).insert(_overlayEntry!);
    Future.delayed(Duration.zero, () {
      final bool openedWithLogicalKey =
          HardwareKeyboard.instance.logicalKeysPressed.isNotEmpty;
      if (openedWithLogicalKey) {
        focusNode.requestFocus();
      }
    });
  }

  SizedBox _buildContent(BuildContext context, GroupProvider groupNotifier,
      bool isBroadcastingToGroup, ChannelProvider channelProvider) {
    List<V3SettingsRadioGroupItem> radioItems = [
      V3SettingsRadioGroupItem(
        value: BroadcastGroupLaunchType.onlyWhenCasting.name,
        title: S.of(context).v3_settings_display_group_only_casting,
        divider: false,
      ),
      V3SettingsRadioGroupItem(
        value: BroadcastGroupLaunchType.allTheTime.name,
        title: S.of(context).v3_settings_display_group_all_the_time,
        divider: false,
      ),
    ];
    return SizedBox(
      height: 293,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBroadcastGroupToggle(context, groupNotifier, channelProvider),
          if (isBroadcastingToGroup)
            V3SettingsRadioGroup(
              firstFocus: false,
              initSelectedValue: groupNotifier.broadcastGroupLaunchType.name,
              radioList: radioItems,
              onChanged: (value) {
                int index =
                    radioItems.indexWhere((item) => item.value == value);
                if (index != -1) {
                  BroadcastGroupLaunchType type =
                      BroadcastGroupLaunchType.values[index];
                  trackEvent(
                    'click_cast_to_board_setting',
                    EventCategory.setting,
                    target: type.name,
                  );

                  groupNotifier.setBroadcastGroupLaunchType(type);
                } else {
                  log('BroadcastGroupLaunchType not found');
                }
              },
            ),
          _buildDivider(context,
              margin: EdgeInsets.only(
                  top: isBroadcastingToGroup ? 0 : 8,
                  bottom: context.tokens.spacing.vsdslSpacingMd.bottom)),
          _buildListHeader(context, groupNotifier, isBroadcastingToGroup),
          _buildListContent(
              groupNotifier, isBroadcastingToGroup, channelProvider),
          _buildDivider(context),
        ],
      ),
    );
  }

  Expanded _buildListContent(GroupProvider groupNotifier,
      bool isBroadcastingToGroup, ChannelProvider channelProvider) {
    final broadcastSelectedList =
        ref.watch(groupProvider.select((state) => state.selectedList));
    final clientList = ref.watch(groupProvider
        .select((state) => [...state.selectedList, ...state.clients]));
    return Expanded(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: isBroadcastingToGroup ? clientList.length : 0,
        itemBuilder: (context, index) {
          final client = clientList[index];
          return Opacity(
            opacity: isBroadcastingToGroup ? 1.0 : 0.3,
            child:
                _buildListTIle(client, context, groupNotifier, channelProvider),
          );
        },
        separatorBuilder: (BuildContext context, int index) =>
            Gap(context.tokens.spacing.vsdslSpacingSm.bottom),
      ),
    );
  }

  Widget _buildListTIle(GroupListItem client, BuildContext context,
      GroupProvider groupNotifier, ChannelProvider channelProvider) {
    final broadcastSelectedList =
        ref.watch(groupProvider.select((state) => state.selectedList));
    void toggleCheckbox(client, {bool? overrideValue}) {
      final onKeyboard =
          HardwareKeyboard.instance.logicalKeysPressed.isNotEmpty;
      if (!onKeyboard && overrideValue == null) {
        return;
      }

      final isChecked = overrideValue ??
          broadcastSelectedList.any((element) => element.id() == client.id());
      if (!isChecked) {
        groupNotifier.addToSelectedList(client);
      } else {
        groupNotifier.removeFromSelectedList(client);
      }
      // 斷線裝置不用按下方按鈕生效，連線還是需要按。
      if (!isChecked == false && channelProvider.groupActivated()) {
        startDisplayGroup(groupNotifier, channelProvider);
      }
      if (overrideValue == null) setState(() {});
    }

    return Container(
      height: 26,
      margin: const EdgeInsets.only(right: 8, left: 8),
      child: V3SettingMenuListItemFocus(
        onTap: () => toggleCheckbox(client),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () => toggleCheckbox(client),
              highlightColor: Colors.transparent,
              child: SizedBox(
                height: 26,
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: ExcludeFocus(
                    child: Checkbox(
                      value: broadcastSelectedList
                          .any((element) => element.id() == client.id()),
                      activeColor: context.tokens.color.vsdslColorPrimary,
                      side: BorderSide(
                          color: context.tokens.color.vsdslColorOnPrimary,
                          width: 2),
                      onChanged: (bool? value) {
                        if (value != null) {
                          toggleCheckbox(client, overrideValue: value);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            Padding(
                padding: EdgeInsets.only(
                    right: context.tokens.spacing.vsdslSpacingSm.right)),
            Text(
              client.deviceName(),
              style: TextStyle(
                  fontSize: 12,
                  color: context.tokens.color.vsdslColorOnSurfaceInverse),
            ),
            const Spacer(),
            displayCodeWidget(client, context)
          ],
        ),
      ),
    );
  }

  Widget displayCodeWidget(GroupListItem client, BuildContext context) {
    final bool unavailable =
        client.invitedState() == InvitedToGroupOption.ignore.value.toString();
    return Row(
      children: [
        if (unavailable)
          const SizedBox(
            width: 20,
            height: 20,
            child: Image(
              image: Svg('assets/images/ic_device_unavailable.svg'),
            ),
          ),
        Text(
          unavailable
              ? S.current.v3_settings_device_unavailable
              : client.displayCode(),
          style: TextStyle(
              fontSize: 12,
              color: unavailable
                  ? context.tokens.color.vsdslColorOnSurfaceVariant
                  : context.tokens.color.vsdslColorOnSurfaceInverse),
        ),
      ],
    );
  }

  Opacity _buildListHeader(BuildContext context, GroupProvider groupNotifier,
      bool isBroadcastingToGroup) {
    return Opacity(
      opacity: isBroadcastingToGroup ? 1.0 : 0.3,
      child: Container(
        height: 26,
        padding: const EdgeInsets.only(
          left: 8,
        ),
        child: Text(
          '${S.of(context).v3_settings_display_group} (${groupNotifier.selectedList.length}/10)',
          textAlign: TextAlign.left,
          style: TextStyle(
            color: context.tokens.color.vsdslColorOnSurfaceInverse,
            fontSize: 12,
            // fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Container _buildDivider(BuildContext context, {EdgeInsetsGeometry? margin}) {
    return Container(
      height: 1,
      margin: margin,
      color: context.tokens.color.vsdslColorOutlineVariant,
    );
  }

  Widget _buildBroadcastGroupToggle(
    BuildContext context,
    GroupProvider groupNotifier,
    ChannelProvider channelProvider,
  ) {
    return V3SettingMenuItemToggleTile(
      title: S.of(context).v3_settings_broadcast_to_display_group,
      focusNode: provider.Provider.of<SettingsProvider>(context).subFocusNode,
      switchOn: groupNotifier.broadcastToGroup,
      onTap: () async {
        bool state = !groupNotifier.broadcastToGroup;

        trackEvent(
          'click_cast_to_board',
          EventCategory.setting,
          target: state ? 'on' : 'off',
        );

        if (state) {
          await channelProvider.startRemoteScreen(fromGroup: true);
        } else {
          groupNotifier.clearClients();
          GroupListModel discoveryModel = ref.read(discoveryModelProvider);
          await discoveryModel.stop();
          channelProvider.stopDisplayGroup();
        }
        groupNotifier.setBroadcastToGroup(channelProvider.isGroupMode);
      },
    );
  }

  Widget _buildTittle(SettingsProvider settingsProvider, BuildContext context) {
    return V3MenuBackIconButton(
      onPressed: () {
        settingsProvider.setPage(SettingPageState.broadcast);
      },
      title: S.of(context).v3_settings_broadcast_cast_boards,
    );
  }

  Widget _customButton(
    BuildContext context,
    String text, {
    required VoidCallback onClick,
    bool isBroadcast = false,
  }) {
    return SizedBox(
      height: 26,
      child: V3SettingMenuSubItemFocus(
        child: ElevatedButton(
          onPressed: onClick,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.tokens.color.vsdslColorPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  context.tokens.spacing.vsdslSpacing2xl.top),
            ),
            padding: isBroadcast
                ? EdgeInsets.symmetric(
                    horizontal: context.tokens.spacing.vsdslSpacingLg.left,
                  )
                : null,
          ),
          child: isBroadcast
              ? Row(
                  children: [
                    const Image(
                      width: 16,
                      height: 16,
                      image: Svg('assets/images/ic_broadcast.svg'),
                    ),
                    SizedBox(width: context.tokens.spacing.vsdslSpacingXs.left),
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.tokens.color.vsdslColorOnSurfaceInverse,
                      ),
                    ),
                  ],
                )
              : Text(
                  text,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.tokens.color.vsdslColorOnSurfaceInverse,
                  ),
                  maxLines: 1,
                ),
        ),
      ),
    );
  }
}
