import 'dart:async';
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
import 'package:display_flutter/providers/instance_info_provider.dart';
import 'package:display_flutter/providers/settings_provider.dart';
import 'package:display_flutter/screens/v3_setting_menu.dart';
import 'package:display_flutter/services/display_service_broadcast.dart';
import 'package:display_flutter/utility/V3TextFieldShortcutsHandler.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:display_flutter/widgets/v3_help_center.dart';
import 'package:display_flutter/widgets/v3_menu_back_icon_button.dart';
import 'package:display_flutter/widgets/v3_setting_menu_list_item_focus.dart';
import 'package:display_flutter/widgets/v3_setting_menu_sub_item_focus.dart';
import 'package:display_flutter/widgets/v3_settings_device.dart';
import 'package:display_flutter/widgets/v3_settings_radio_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart' as provider;
import 'package:sprintf/sprintf.dart';
import 'package:uuid/uuid.dart';

class V3SettingsCastToBoards extends ConsumerStatefulWidget {
  const V3SettingsCastToBoards({super.key});

  @override
  V3SettingsCastToBoardsState createState() => V3SettingsCastToBoardsState();
}

class V3SettingsCastToBoardsState extends ConsumerState<V3SettingsCastToBoards>
    with WidgetsBindingObserver {
  OverlayEntry? _overlayEntry;

  // 追蹤正在連接的設備 ID
  final Set<String> _connectingDevices = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final isBroadcastingToGroup =
          ref.read(groupProvider.select((state) => state.broadcastToGroup));
      if (isBroadcastingToGroup) {
        ref.read(groupProvider.notifier).organizeGroupList();
        await ref.read(groupProvider.notifier).loadFavoriteDevices();
      }
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
    // Provide instance info so UDP discovery responses include name/ip/display code.
    discoveryModel.instanceInfoProvider =
        provider.Provider.of<InstanceInfoProvider>(context, listen: false);
    if (isBroadcastingToGroup) {
      discoveryModel.start(context: context);
    } else {
      discoveryModel.stop();
    }
    return Padding(
      padding: EdgeInsets.only(
        left: 13,
        right: 13,
        bottom: 13,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildContent(context, groupNotifier, isBroadcastingToGroup,
              channelProvider, settingsProvider),
          if (isBroadcastingToGroup)
            _buildHintAndActionButton(context, broadcastType, settingsProvider,
                channelProvider, groupNotifier)
        ],
      ),
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
          constraints: const BoxConstraints(minHeight: 30),
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

  Widget _buildContent(
      BuildContext context,
      GroupProvider groupNotifier,
      bool isBroadcastingToGroup,
      ChannelProvider channelProvider,
      SettingsProvider settingsProvider) {
    List<V3SettingsRadioGroupItem> radioItems = [
      V3SettingsRadioGroupItem(
        value: BroadcastGroupLaunchType.onlyWhenCasting.name,
        title: S.of(context).v3_settings_display_group_only_casting,
        divider: false,
        disabled: !isBroadcastingToGroup,
      ),
      V3SettingsRadioGroupItem(
        value: BroadcastGroupLaunchType.allTheTime.name,
        title: S.of(context).v3_settings_display_group_all_the_time,
        divider: false,
        disabled: !isBroadcastingToGroup,
      ),
    ];

    // 監聽 state 變化，然後使用 getClientList() 獲取正確排序的列表
    ref.watch(groupProvider);
    final clientList = groupNotifier.getClientList();

    return Expanded(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildTitle(settingsProvider, context),
          ),
          SliverToBoxAdapter(
            child: V3SettingsRadioGroup(
              label:
                  S.of(context).v3_lbl_settings_broadcast_to_display_group_type,
              identifier: "v3_qa_settings_broadcast_to_display_group_type",
              hasSubFocusItem: false,
              focusOnInit: false,
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
          ),
          // Divider
          SliverToBoxAdapter(
            child: _buildDivider(context,
                margin: EdgeInsets.only(
                    top: isBroadcastingToGroup ? 0 : 8,
                    bottom: context.tokens.spacing.vsdslSpacingMd.bottom)),
          ),
          SliverStickyHeader(
            // 會黏在頂端的 Header
            header: Container(
              alignment: Alignment.centerLeft,
              color: context.tokens.color.vsdslColorSurface1000,
              child: _buildListHeader(
                  context, groupNotifier, isBroadcastingToGroup),
            ),
            // Sticky Header 下方的 List
            sliver: isBroadcastingToGroup
                ? SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final client = clientList[index];
                        return Opacity(
                          opacity: isBroadcastingToGroup ? 1.0 : 0.3,
                          child: _buildListTIle(
                              client, context, groupNotifier, channelProvider),
                        );
                      },
                      childCount: clientList.length,
                    ),
                  )
                : null,
          ),
        ],
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
      if (isChecked && channelProvider.groupActivated()) {
        startDisplayGroup(groupNotifier, channelProvider);
      }
      if (!fromTouch) {
        if (!mounted) return;
        setState(() {});
      }
    }

    return Container(
      margin: const EdgeInsets.only(left: 8),
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
            // connecting 狀態：顯示 Connecting + 收藏按鈕
            if (_connectingDevices.contains(client.id())) ...[
              _buildConnectingWidget(client, context),
              _buildFavoriteButton(client, context),
            ]
            // offline 狀態：顯示 Connect 按鈕 + 收藏按鈕
            else if (client.offline()) ...[
              _buildConnectButton(client, context),
              _buildFavoriteButton(client, context),
            ]
            // notFind 狀態：顯示錯誤文本 + 刪除按鈕
            else if (client.ipNotFind())
              notFindStatusWidget(client, context)
            // 正常狀態：顯示 Display Code + 收藏按鈕
            else ...[
              displayCodeWidget(client, context),
              _buildFavoriteButton(client, context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(GroupListItem client, BuildContext context) {
    final groupNotifier = ref.read(groupProvider.notifier);
    final isFav = groupNotifier.isFavorite(client.id());
    // 只有 notFind 狀態禁用收藏，offline 狀態可以收藏
    final isDisabled = client.ipNotFind();

    return V3Focus(
      label: S.of(context).v3_lbl_settings_broadcast_device_favorite,
      identifier: 'v3_qa_settings_broadcast_device_favorite',
      child: InkWell(
        excludeFromSemantics: true,
        onTap: isDisabled
            ? null
            : () {
                if (!mounted) return;
                setState(() {
                  groupNotifier.toggleFavorite(client);
                });
              },
        child: SizedBox(
          width: 20,
          height: 20,
          child: SvgPicture.asset(
            isFav
                ? 'assets/images/ic_device_favorite.svg'
                : 'assets/images/ic_device_favorite_off.svg',
            colorFilter: isDisabled
                ? ColorFilter.mode(
                    context.tokens.color.vsdslColorOutline,
                    BlendMode.srcIn,
                  )
                : null,
          ),
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
        mainAxisAlignment: MainAxisAlignment.end,
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
          const Gap(3),
        ],
      ),
    );
  }

  // Connecting 狀態顯示 - 載入動畫 + "Connecting" 文本
  Widget _buildConnectingWidget(GroupListItem client, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(
            color: context.tokens.color.vsdslColorOnSurfaceInverse
                .withValues(alpha: 0.5),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  context.tokens.color.vsdslColorOnSurfaceInverse
                      .withValues(alpha: 0.5),
                ),
              ),
            ),
            const Gap(6),
            Text(
              S.of(context).v3_lbl_settings_broadcast_connecting,
              style: TextStyle(
                fontSize: 12,
                color: context.tokens.color.vsdslColorOnSurfaceInverse
                    .withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Connect 按鈕 - 用於 offline 狀態
  Widget _buildConnectButton(GroupListItem client, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: V3Focus(
        label: S.of(context).v3_lbl_settings_broadcast_connect,
        identifier: 'v3_qa_settings_broadcast_connect',
        child: InkWell(
          onTap: () async {
            final groupNotifier = ref.read(groupProvider.notifier);
            final ip = client.ip();

            if (ip.isEmpty) return;

            // 加入到連接中狀態
            setState(() {
              _connectingDevices.add(client.id());
            });

            // 重新嘗試連接
            try {
              final bean = GroupBean.fromJson(
                await UdpResponder.askPeerViaUdp(ip),
                viaIp: client.viaIp(),
                favorite: client.favorite(),
              );

              if (!mounted) return;

              // 移除連接中狀態
              setState(() {
                _connectingDevices.remove(client.id());
              });

              // 移除舊的 offline 設備，添加新的線上設備
              groupNotifier.removeClient(client);
              groupNotifier.addClient(bean);
              groupNotifier.addToSelectedList(bean);
            } catch (e) {
              if (!mounted) return;

              // 移除連接中狀態
              setState(() {
                _connectingDevices.remove(client.id());
              });

              // 連接失敗，保持 offline 狀態（不需要操作，因為設備還在列表中）
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                color: context.tokens.color.vsdslColorOnSurfaceInverse,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              S.of(context).v3_lbl_settings_broadcast_connect,
              style: TextStyle(
                fontSize: 12,
                color: context.tokens.color.vsdslColorOnSurfaceInverse,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // notFind 狀態顯示
  Widget notFindStatusWidget(GroupListItem client, BuildContext context) {
    final isNormal =
        AppPreferences().textSizeOption == ResizeTextSizeOption.normal;

    return Flexible(
      flex: isNormal ? 7 : 4,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: V3AutoHyphenatingText(
              S.of(context).v3_settings_broadcast_not_find,
              style: TextStyle(
                fontSize: 12,
                color: context.tokens.color.vsdslColorError,
              ),
            ),
          ),
          const Gap(3),
          V3Focus(
            label: S.of(context).v3_lbl_settings_broadcast_device_remove,
            identifier: 'v3_qa_settings_broadcast_device_remove',
            child: InkWell(
              excludeFromSemantics: true,
              child: SizedBox(
                width: 20,
                height: 20,
                child: SvgPicture.asset(
                  'assets/images/ic_ip_not_find.svg',
                ),
              ),
              onTap: () {
                final groupNotifier = ref.read(groupProvider.notifier);
                groupNotifier.removeClient(client);
              },
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
            client.unsupportedMulticast() && useMulticast ||
            client.ipNotFind() ||
            client.offline();
    return unavailable;
  }

  Widget _buildListHeader(BuildContext context, GroupProvider groupNotifier,
      bool isBroadcastingToGroup) {
    return Opacity(
      opacity: isBroadcastingToGroup ? 1.0 : 0.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 8, top: 10),
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
          const Gap(3),
          if (isBroadcastingToGroup)
            V3FindBoardsViaIP(
              onIPAdded: _onIPAddedCallback,
              groupNotifier: groupNotifier,
            ),
          _buildDivider(
            context,
            margin: EdgeInsets.only(
                top: isBroadcastingToGroup ? 0 : 8,
                bottom: context.tokens.spacing.vsdslSpacingMd.bottom),
          ),
        ],
      ),
    );
  }

  Future<void> _onIPAddedCallback(String ipAddress) async {
    final groupNotifier = ref.read(groupProvider.notifier);

    // 檢查是否已存在此 IP
    final allClients = groupNotifier.getClientList();

    // 查找匹配的設備
    GroupListItem? existingClient;
    for (var client in allClients) {
      // 情況 1: 該設備的 IP 屬性匹配（mDNS 發現的設備）
      if (client.ip() == ipAddress) {
        existingClient = client;
        break;
      }
      // 情況 2: 手動添加的設備，deviceName 就是 IP
      if (client.viaIp() && client.deviceName() == ipAddress) {
        existingClient = client;
        break;
      }
    }

    // 處理已存在的設備
    if (existingClient != null) {
      if (existingClient.ipNotFind() || existingClient.offline()) {
        // 是 "not find" 或 "offline" 狀態，允許重試
        groupNotifier.removeClient(existingClient);
      } else {
        // 設備已存在且可用
        if (!groupNotifier.selectedList.contains(existingClient)) {
          // 未選中，直接選中它
          groupNotifier.addToSelectedList(existingClient);
        }
        return;
      }
    }

    // 執行 UDP 查詢和添加邏輯
    try {
      final bean = GroupBean.fromJson(
        await UdpResponder.askPeerViaUdp(ipAddress),
        viaIp: true,
      );
      groupNotifier.addClient(bean);
      groupNotifier.addToSelectedList(bean);
    } catch (a) {
      // UDP timeout
      final att = Attributes(ip: ipAddress, id: const Uuid().v4());
      groupNotifier.addClient(
        GroupBean(
          viaIp: true,
          notFind: true,
          attributes: att,
        ),
      );
    }
  }

  Widget _buildDivider(BuildContext context, {EdgeInsetsGeometry? margin}) {
    return Container(
      height: 1,
      margin: margin,
      color: context.tokens.color.vsdslColorOutlineVariant,
    );
  }

  Widget _buildTitle(SettingsProvider settingsProvider, BuildContext context) {
    return V3MenuBackIconButton(
      onPressed: () {
        settingsProvider.setPage(SettingPageState.broadcast);
      },
      title: S.of(context).v3_settings_broadcast_cast_boards,
      padding: const EdgeInsets.only(top: 13),
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

/// Widget for finding boards via IP address input
class V3FindBoardsViaIP extends StatefulWidget {
  final Future<void> Function(String) onIPAdded;
  final GroupProvider groupNotifier;

  const V3FindBoardsViaIP({
    super.key,
    required this.onIPAdded,
    required this.groupNotifier,
  });

  @override
  State<V3FindBoardsViaIP> createState() => _V3FindBoardsViaIPState();
}

class _V3FindBoardsViaIPState extends State<V3FindBoardsViaIP> {
  final TextEditingController _ipController = TextEditingController();
  final List<String> _loadingIPs = [];
  final LayerLink _ipFieldLink = LayerLink();
  final GlobalKey _textFieldKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isValidIP = false;
  bool _hasIPInput = false;
  bool _ipAlreadyExists = false;

  @override
  void initState() {
    super.initState();
    _ipController.addListener(_validateIP);
  }

  @override
  void dispose() {
    _removeOverlay();
    _ipController.dispose();
    super.dispose();
  }

  void _validateIP() {
    final ipText = _ipController.text.trim();
    final isValid = _isValidIPAddress(ipText);
    final hasInput = _ipController.text.isNotEmpty;

    // 檢查 IP 是否已存在
    bool ipExists = false;
    if (isValid) {
      final allClients = widget.groupNotifier.getClientList();
      for (var client in allClients) {
        if (client.ip() == ipText ||
            (client.viaIp() && client.deviceName() == ipText)) {
          // 找到匹配的設備，但如果是 "not find" 狀態，視為可以重試
          if (!client.ipNotFind()) {
            ipExists = true;
          }
          break;
        }
      }
    }

    if (_isValidIP != isValid ||
        _hasIPInput != hasInput ||
        _ipAlreadyExists != ipExists) {
      if (!mounted) return;
      setState(() {
        _isValidIP = isValid;
        _hasIPInput = hasInput;
        _ipAlreadyExists = ipExists;
      });
    }

    if (hasInput && !isValid) {
      _showMessageOverlay(
          message: S.of(context).v3_settings_broadcast_ip_error);
    } else {
      _removeOverlay();
    }
  }

  bool _isValidIPAddress(String ip) {
    if (ip.isEmpty) return false;

    // 排除無效的特殊 IP 地址
    final instanceInfoProvider =
        provider.Provider.of<InstanceInfoProvider>(context, listen: false);
    final localIp = instanceInfoProvider.ipAddress;
    if (ip == '0.0.0.0' ||
        ip == '127.0.0.1' ||
        (localIp.isNotEmpty && ip == localIp)) {
      return false;
    }

    // IPv4 正則
    final ipv4Pattern = RegExp(r'^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$');

    if (ipv4Pattern.hasMatch(ip)) {
      final parts = ip.split('.');
      if (parts.length != 4) return false;

      for (var part in parts) {
        final num = int.tryParse(part);
        if (num == null || num < 0 || num > 255) {
          return false;
        }
      }
      return true;
    }

    return false;
  }

  void _showMessageOverlay({required String message, Duration? autoDismiss}) {
    if (!mounted || _overlayEntry != null) return;
    final renderBox =
        _textFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final size = renderBox.size;
    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return Positioned(
          left: 0,
          top: 0,
          child: CompositedTransformFollower(
            link: _ipFieldLink,
            showWhenUnlinked: false,
            offset: Offset(0, -size.height + 20),
            child: Material(
              color: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.tokens.color.vsdslColorSurface100,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        const BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      message,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.tokens.color.vsdslColorError,
                      ),
                    ),
                  ),
                  CustomPaint(
                    painter: TrianglePainter(
                      color: context.tokens.color.vsdslColorSurface100,
                    ),
                    child: const SizedBox(width: 10, height: 7),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context, debugRequiredFor: widget).insert(_overlayEntry!);

    if (autoDismiss != null) {
      final currentEntry = _overlayEntry;
      Future.delayed(autoDismiss, () {
        if (!mounted) return;
        if (_overlayEntry == currentEntry) {
          _removeOverlay();
        }
      });
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
  }

  Future<void> _handleAddIP() async {
    FocusScope.of(context).unfocus();
    final ipAddress = _ipController.text.trim();

    if (!mounted) return;
    // 添加到載入列表
    setState(() {
      _loadingIPs.add(ipAddress);
    });

    // 清空輸入框
    _ipController.clear();

    try {
      // 執行耗時動作
      await widget.onIPAdded(ipAddress);
    } finally {
      // 完成後從載入列表移除
      if (mounted) {
        setState(() {
          _loadingIPs.remove(ipAddress);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final SettingsProvider settingsProvider =
        provider.Provider.of<SettingsProvider>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  S.of(context).v3_settings_broadcast_ip,
                  style: TextStyle(
                    color: context.tokens.color.vsdslColorOnSurfaceInverse,
                    fontSize: 12,
                  ),
                ),
              ),
              const Gap(8),
              Expanded(
                child: V3Focus(
                  key: _textFieldKey,
                  label: S.of(context).v3_lbl_settings_broadcast_ip_hint,
                  identifier: "v3_qa_settings_broadcast_ip_hint",
                  child: () {
                    return V3TextFieldShortcutsHandler(
                      focusNode: settingsProvider.subFocusNode ?? FocusNode(),
                      child: CompositedTransformTarget(
                        link: _ipFieldLink,
                        child: TextField(
                          controller: _ipController,
                          maxLines: AppPreferences().textSizeOption !=
                                  ResizeTextSizeOption.normal
                              ? 2
                              : null,
                          style: TextStyle(
                            color:
                                context.tokens.color.vsdslColorOnSurfaceInverse,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                S.of(context).v3_settings_broadcast_ip_hint,
                            hintStyle: TextStyle(
                              color: context
                                  .tokens.color.vsdslColorOnSurfaceInverse
                                  .withValues(alpha: 0.5),
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 3),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.]')),
                          ],
                          autocorrect: false,
                        ),
                      ),
                    );
                  }(),
                ),
              ),
              if (_hasIPInput)
                V3Focus(
                  label: S.of(context).v3_lbl_settings_ip_clear,
                  identifier: "v3_qa_settings_ip_clear",
                  child: SizedBox(
                    width: 21,
                    height: 21,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      focusNode: FocusNode(),
                      icon: SvgPicture.asset(
                        'assets/images/ic_ip_clear.svg',
                      ),
                      onPressed: () {
                        _ipController.clear();
                      },
                    ),
                  ),
                ),
              const Gap(5),
              V3Focus(
                label: S.of(context).v3_lbl_settings_ip_add,
                identifier: "v3_qa_settings_ip_add",
                child: SizedBox(
                  width: 21,
                  height: 21,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    focusNode: FocusNode(),
                    icon: SvgPicture.asset(
                      'assets/images/ic_ip_add.svg',
                      colorFilter: _isValidIP
                          ? null
                          : ColorFilter.mode(
                              context.tokens.color.vsdslColorOnSurfaceVariant,
                              BlendMode.srcIn,
                            ),
                    ),
                    onPressed: !_isValidIP
                        ? null
                        : () {
                            if (widget.groupNotifier.selectedList.length >=
                                GroupProvider.groupMaximum) {
                              _showMessageOverlay(
                                message:
                                    S.of(context).v3_cast_to_device_list_msg,
                                autoDismiss: const Duration(seconds: 2),
                              );
                            } else {
                              _handleAddIP.call();
                            }
                          },
                  ),
                ),
              ),
              const Gap(5),
            ],
          ),
        ),
        // 顯示正在載入的 IP 列表
        if (_loadingIPs.isNotEmpty) ...[
          ..._loadingIPs.map((ip) => _buildLoadingIPItem(context, ip)),
        ],
      ],
    );
  }

  Widget _buildLoadingIPItem(BuildContext context, String ip) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                context.tokens.color.vsdslColorOnSurfaceInverse
                    .withValues(alpha: 0.6),
              ),
            ),
          ),
          const Gap(12),
          Text(
            ip,
            style: TextStyle(
              color: context.tokens.color.vsdslColorOnSurfaceInverse
                  .withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
