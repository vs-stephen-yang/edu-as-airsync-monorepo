import 'dart:developer';

import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/group_list_item.dart';
import 'package:display_flutter/model/text_scale_option.dart';
import 'package:display_flutter/providers/appSettings.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/group_list_provider.dart';
import 'package:display_flutter/providers/group_provider.dart';
import 'package:display_flutter/providers/settings_provider.dart';
import 'package:display_flutter/screens/v3_setting_menu.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:display_flutter/widgets/v3_menu_back_icon_button.dart';
import 'package:display_flutter/widgets/v3_scrollbar.dart';
import 'package:display_flutter/widgets/v3_setting_menu_item_toggle_tile.dart';
import 'package:display_flutter/widgets/v3_setting_menu_list_item_focus.dart';
import 'package:display_flutter/widgets/v3_setting_menu_sub_item_focus.dart';
import 'package:display_flutter/widgets/v3_settings_device.dart';
import 'package:display_flutter/widgets/v3_settings_radio_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart' as provider;
import 'package:sprintf/sprintf.dart';

class V3SettingsCastToBoards extends ConsumerStatefulWidget {
  const V3SettingsCastToBoards({super.key});

  @override
  V3SettingsCastToBoardsState createState() => V3SettingsCastToBoardsState();
}

class V3SettingsCastToBoardsState extends ConsumerState<V3SettingsCastToBoards>
    with WidgetsBindingObserver {
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    WidgetsBinding.instance.removeObserver(this);
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
          bottom: 13,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildContent(context, groupNotifier, isBroadcastingToGroup,
                  channelProvider),
              if (isBroadcastingToGroup)
                _buildHintAndActionButton(context, broadcastType,
                    settingsProvider, channelProvider, groupNotifier)
            ],
          ),
        ),
      ],
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      GroupListModel discoveryModel = ref.read(discoveryModelProvider);
      discoveryModel.stop();
    }
    super.didChangeAppLifecycleState(state);
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

  Widget _buildHintAndActionButton(
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

    return Column(
      children: [
        _buildDivider(context),
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: 30),
          child: IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Semantics(
                  label: S.of(context).v3_lbl_settings_only_when_casting_info,
                  identifier: "v3_qa_settings_only_when_casting_info",
                  child: SvgPicture.asset(
                    'assets/images/ic_settings_info.svg',
                    width: 20,
                    height: 20,
                  ),
                ),
                Gap(context.tokens.spacing.vsdslSpacingSm.right),
                Expanded(
                  child: Text(
                    hintText,
                    style: TextStyle(
                      fontSize: 9,
                      color: context.tokens.color.vsdslColorOnSurfaceInverse,
                    ),
                  ),
                ),
                Gap(context.tokens.spacing.vsdslSpacingSm.right),
                broadcastType == BroadcastGroupLaunchType.onlyWhenCasting
                    ? _customButton(
                        context,
                        S.of(context).v3_settings_device_name_save,
                        label: S.current
                            .v3_lbl_settings_broadcast_to_display_group_save,
                        identifier:
                            "v3_qa_settings_broadcast_to_display_group_save",
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
                            settingsProvider
                                .setPage(SettingPageState.deviceSetting);
                          }
                        },
                      )
                    : _customButton(
                        context,
                        S.of(context).v3_settings_display_group_cast,
                        isBroadcast: true,
                        label: S.current
                            .v3_lbl_settings_broadcast_to_display_group_cast,
                        identifier:
                            "v3_qa_settings_broadcast_to_display_group_cast",
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
        ),
      ],
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
            color: Colors.black.withValues(alpha: 0.3),
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
                      child: V3AutoHyphenatingText(
                        S.of(context).v3_group_dialog_no_device_message,
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
                    label: S.current
                        .v3_lbl_settings_broadcast_to_display_group_confirm,
                    identifier:
                        "v3_qa_settings_broadcast_to_display_group_confirm",
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
                      child: V3AutoHyphenatingText(
                        S.of(context).v3_moderator_disable_mirror_ok,
                      ),
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

  Widget _buildContent(BuildContext context, GroupProvider groupNotifier,
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

    final clientList = ref.watch(groupProvider
        .select((state) => [...state.selectedList, ...state.clients]));

    // 提取共同的內容部分為一個方法，返回 Widget 列表而不是單個 Widget
    List<Widget> buildContentWidgets() {
      return [
        _buildBroadcastGroupToggle(context, groupNotifier, channelProvider),
        if (isBroadcastingToGroup)
          V3SettingsRadioGroup(
            label:
                S.of(context).v3_lbl_settings_broadcast_to_display_group_type,
            identifier: "v3_qa_settings_broadcast_to_display_group_type",
            hasSubFocusItem: false,
            focusOnInit: false,
            initSelectedValue: groupNotifier.broadcastGroupLaunchType.name,
            radioList: radioItems,
            onChanged: (value) {
              int index = radioItems.indexWhere((item) => item.value == value);
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
      ];
    }

    final isNormal =
        AppPreferences().textSizeOption == ResizeTextSizeOption.normal;
    if (isNormal) {
      return SizedBox(
        height: 293,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...buildContentWidgets(),
            _buildListContent(
                groupNotifier, isBroadcastingToGroup, channelProvider),
          ],
        ),
      );
    } else {
      return Expanded(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...buildContentWidgets(),
              if (isBroadcastingToGroup)
                Column(
                  children: clientList
                      .map((client) => Opacity(
                            opacity: isBroadcastingToGroup ? 1.0 : 0.3,
                            child: _buildListTIle(client, context,
                                groupNotifier, channelProvider),
                          ))
                      .toList(),
                )
            ],
          ),
        ),
      );
    }
  }

  Expanded _buildListContent(GroupProvider groupNotifier,
      bool isBroadcastingToGroup, ChannelProvider channelProvider) {
    final clientList = ref.watch(groupProvider
        .select((state) => [...state.selectedList, ...state.clients]));
    final sc = ScrollController();
    return Expanded(
      child: V3Scrollbar(
        controller: sc,
        child: ListView.separated(
          controller: sc,
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: isBroadcastingToGroup ? clientList.length : 0,
          itemBuilder: (context, index) {
            final client = clientList[index];
            return Opacity(
              opacity: isBroadcastingToGroup ? 1.0 : 0.3,
              child: _buildListTIle(
                  client, context, groupNotifier, channelProvider),
            );
          },
          separatorBuilder: (BuildContext context, int index) =>
              Gap(context.tokens.spacing.vsdslSpacingSm.bottom),
        ),
      ),
    );
  }

  Widget _buildListTIle(GroupListItem client, BuildContext context,
      GroupProvider groupNotifier, ChannelProvider channelProvider) {
    final broadcastSelectedList =
        ref.watch(groupProvider.select((state) => state.selectedList));
    void toggleCheckbox(client, {bool fromTouch = false}) {
      final onKeyboard =
          HardwareKeyboard.instance.logicalKeysPressed.isNotEmpty;
      if (!onKeyboard && !fromTouch) {
        return;
      }

      final isChecked =
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
      if (!fromTouch) {
        if (!mounted) return;
        setState(() {});
      }
    }

    return Container(
      margin: const EdgeInsets.only(right: 8, left: 8),
      child: V3SettingMenuListItemFocus(
        label: sprintf(
            S.of(context).v3_lbl_settings_broadcast_to_display_group_item,
            [client.deviceName()]),
        identifier: sprintf("v3_qa_settings_broadcast_to_display_group_item_%s",
            [client.deviceName()]),
        onTap: () => toggleCheckbox(client),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ExcludeFocus(
              child: InkWell(
                excludeFromSemantics: true,
                onTap: () =>
                    isUnavailable(client) ? null : toggleCheckbox(client),
                highlightColor: Colors.transparent,
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Semantics(
                    label: sprintf(
                        S.current
                            .v3_lbl_settings_broadcast_to_display_group_checkbox,
                        [client.deviceName()]),
                    identifier: sprintf(
                        "v3_qa_settings_broadcast_to_display_group_checkbox_%s",
                        [client.deviceName()]),
                    child: Checkbox(
                      value: isUnavailable(client)
                          ? false
                          : broadcastSelectedList
                              .any((element) => element.id() == client.id()),
                      activeColor: context.tokens.color.vsdslColorPrimary,
                      side: BorderSide(
                          color: isUnavailable(client)
                              ? context.tokens.color.vsdslColorOutline
                              : context.tokens.color.vsdslColorOnPrimary,
                          width: 2),
                      onChanged: isUnavailable(client)
                          ? null
                          : (bool? value) {
                              if (value != null) {
                                toggleCheckbox(client, fromTouch: true);
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
            Expanded(
              flex: 11,
              // Trialling is device name, should not use - to confuse user
              child: Text(
                client.deviceName(),
                style: TextStyle(
                    fontSize: 12,
                    color: context.tokens.color.vsdslColorOnSurfaceInverse),
              ),
            ),
            displayCodeWidget(client, context)
          ],
        ),
      ),
    );
  }

  Widget displayCodeWidget(GroupListItem client, BuildContext context) {
    final unavailable = isUnavailable(client);
    final useMulticast = context.read<AppSettings>().useMulticast;
    final isNormal =
        AppPreferences().textSizeOption == ResizeTextSizeOption.normal;
    return Flexible(
      flex: isNormal ? 7 : 4,
      child: Row(
        children: [
          if (unavailable)
            SizedBox(
              width: 20,
              height: 20,
              child: SvgPicture.asset(
                'assets/images/ic_device_unavailable.svg',
              ),
            ),
          Flexible(
            // Trialling is display code, should not use - to confuse user
            child: V3AutoHyphenatingText(
              unavailable
                  ? useMulticast
                      ? S.of(context).v3_settings_device_not_supported
                      : S.of(context).v3_settings_device_unavailable
                  : client.displayCode(),
              style: TextStyle(
                fontSize: 12,
                color: context.tokens.color.vsdslColorOnSurfaceInverse,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool isUnavailable(GroupListItem client) {
    final useMulticast = context.read<AppSettings>().useMulticast;
    final bool unavailable =
        client.invitedState() == InvitedToGroupOption.ignore.value.toString() ||
            client.unsupportedMulticast() && useMulticast;
    return unavailable;
  }

  Opacity _buildListHeader(BuildContext context, GroupProvider groupNotifier,
      bool isBroadcastingToGroup) {
    return Opacity(
      opacity: isBroadcastingToGroup ? 1.0 : 0.3,
      child: Container(
        padding: const EdgeInsets.only(left: 8),
        child: V3AutoHyphenatingText(
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
      label: S.of(context).v3_lbl_settings_broadcast_to_display_group,
      identifier: "v3_qa_settings_broadcast_to_display_group",
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
    String? label,
    String? identifier,
  }) {
    return V3SettingMenuSubItemFocus(
      label: label,
      identifier: identifier,
      child: ElevatedButton(
        onPressed: onClick,
        style: ElevatedButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: const Size(0, 26),
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
                  SvgPicture.asset(
                    'assets/images/ic_broadcast.svg',
                    width: 16,
                    height: 16,
                  ),
                  SizedBox(width: context.tokens.spacing.vsdslSpacingXs.left),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.tokens.color.vsdslColorOnPrimary,
                    ),
                  ),
                ],
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: context.tokens.color.vsdslColorOnPrimary,
                ),
                maxLines: 1,
              ),
      ),
    );
  }
}
