import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/group_list_item.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/group_list_provider.dart';
import 'package:display_flutter/providers/group_provider.dart';
import 'package:display_flutter/providers/message_dialog_provider.dart';
import 'package:display_flutter/providers/settings_provider.dart';
import 'package:display_flutter/widgets/v3_settings_device.dart';
import 'package:display_flutter/widgets/v3_settings_radio_group_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart' as provider;

class V3SettingsCastToBoards extends ConsumerStatefulWidget {
  const V3SettingsCastToBoards({super.key});

  @override
  V3SettingsCastToBoardsState createState() => V3SettingsCastToBoardsState();
}

class V3SettingsCastToBoardsState
    extends ConsumerState<V3SettingsCastToBoards> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(groupProvider.notifier).organizeGroupList();
    });
  }

  @override
  void deactivate() {
    GroupListModel discoveryModel = ref.watch(discoveryModelProvider);
    discoveryModel.stop();
    super.deactivate();
  }

  @override
  void dispose() {
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
    final GroupListModel discoveryModel = ref.watch(discoveryModelProvider);
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
            right: 13,
            bottom: 13,
            child: _buildActionButton(context, broadcastType, settingsProvider,
                channelProvider, groupNotifier),
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

  Align _buildActionButton(
      BuildContext context,
      BroadcastGroupLaunchType broadcastType,
      SettingsProvider settingsProvider,
      ChannelProvider channelProvider,
      GroupProvider groupNotifier) {
    final selectedListEmpty = groupNotifier.selectedList.isEmpty;
    return Align(
      alignment: Alignment.centerRight,
      child: broadcastType == BroadcastGroupLaunchType.onlyWhenCasting
          ? _saveButton(context, S.of(context).v3_settings_device_name_save,
              onClick: () {
              _trackEvent('click_save_target', groupNotifier.selectedList);

              if (selectedListEmpty) {
                showDialog(
                  groupNotifier: groupNotifier,
                  onConfirm: () {
                    AppPreferences().setGroupSelectedList(
                        groupNotifier.historySelectedList);
                    settingsProvider.setPage(SettingPageState.deviceSetting);
                  },
                );
              } else {
                AppPreferences()
                    .setGroupSelectedList(groupNotifier.historySelectedList);
                settingsProvider.setPage(SettingPageState.deviceSetting);
              }
            })
          : _broadcastButton(
              context,
              S.of(context).v3_settings_display_group_cast,
              onClick: () {
                if (selectedListEmpty) {
                  showDialog(
                    groupNotifier: groupNotifier,
                    onConfirm: () {
                      startDisplayGroup(groupNotifier, channelProvider);
                    },
                  );
                } else {
                  startDisplayGroup(groupNotifier, channelProvider);
                  _trackEvent('click_broadcast', groupNotifier.selectedList);
                }
              },
            ),
    );
  }

  void startDisplayGroup(
      GroupProvider groupNotifier, ChannelProvider channelProvider) {
    AppPreferences().setGroupSelectedList(groupNotifier.historySelectedList);
    channelProvider.startDisplayGroup(groupNotifier.selectedList);
  }

  void showDialog({
    required GroupProvider groupNotifier,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    final dialog = ref.read(dialogProvider.notifier);
    dialog.showDialog(
      title: 'No device selected.',
      content: 'No device selected.',
      confirmText: S.current.moderator_confirm,
      cancelText: S.current.main_mirror_prompt_cancel,
      showIcon: false,
      width: 400,
      height: 192,
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }

  SizedBox _buildContent(BuildContext context, GroupProvider groupNotifier,
      bool isBroadcastingToGroup, ChannelProvider channelProvider) {
    return SizedBox(
      height: 293,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBroadcastGroupToggle(context, groupNotifier, channelProvider),
          if (isBroadcastingToGroup)
            _buildRadioGroupItem(
                S.of(context).v3_settings_display_group_only_casting,
                BroadcastGroupLaunchType.onlyWhenCasting,
                groupNotifier),
          if (isBroadcastingToGroup)
            _buildRadioGroupItem(
                S.of(context).v3_settings_display_group_all_the_time,
                BroadcastGroupLaunchType.allTheTime,
                groupNotifier),
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
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: groupNotifier.getListenListSize(),
        itemBuilder: (context, index) {
          final client = groupNotifier.getListenClient(index);
          return Opacity(
            opacity: isBroadcastingToGroup ? 1.0 : 0.3,
            child: Container(
              height: 26,
              margin: EdgeInsets.only(
                  right: 8,
                  left: 8,
                  bottom: context.tokens.spacing.vsdslSpacingSm.bottom),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: broadcastSelectedList
                          .any((element) => element.id() == client.id()),
                      activeColor: context.tokens.color.vsdslColorPrimary,
                      side: BorderSide(
                          color: context.tokens.color.vsdslColorOnPrimary,
                          width: 2),
                      onChanged: (bool? value) {
                        if (value != null) {
                          if (value) {
                            groupNotifier.addToSelectedList(client);
                          } else {
                            groupNotifier.removeFromSelectedList(client);
                          }
                          if (channelProvider.groupActivated()) {
                            startDisplayGroup(groupNotifier, channelProvider);
                          }
                        }
                      },
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
        },
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

  SizedBox _buildBroadcastGroupToggle(BuildContext context,
      GroupProvider groupNotifier, ChannelProvider channelProvider) {
    return SizedBox(
      height: 26,
      child: Row(
        children: [
          Text(
            S.of(context).v3_settings_broadcast_to_display_group,
            style: TextStyle(
              color: context.tokens.color.vsdslColorOnSurfaceInverse,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 21,
            child: IconButton(
              icon: Image(
                image: Svg(groupNotifier.broadcastToGroup
                    ? 'assets/images/ic_switch_on.svg'
                    : 'assets/images/ic_switch_off.svg'),
              ),
              padding: EdgeInsets.zero,
              // constraints: const BoxConstraints(),
              onPressed: () async {
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
                  GroupListModel discoveryModel =
                      ref.watch(discoveryModelProvider);
                  await discoveryModel.stop();
                  channelProvider.stopDisplayGroup();
                }
                groupNotifier.setBroadcastToGroup(state);
              },
            ),
          )
        ],
      ),
    );
  }

  V3SettingsRadioGroupItem _buildRadioGroupItem(
      String text, BroadcastGroupLaunchType type, GroupProvider groupNotifier) {
    return V3SettingsRadioGroupItem(
        value: text,
        defaultSelectedState: groupNotifier.broadcastGroupLaunchType == type,
        onChange: (bool selected) {
          if (selected) {
            trackEvent(
              'click_cast_to_board_setting',
              EventCategory.setting,
              target: type.name,
            );

            groupNotifier.setBroadcastGroupLaunchType(type);
          }
        });
  }

  Row _buildTittle(SettingsProvider settingsProvider, BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Image(
            image: Svg('assets/images/ic_arrow_left.svg'),
            width: 21,
            height: 21,
          ),
          onPressed: () {
            settingsProvider.setPage(SettingPageState.broadcast);
          },
        ),
        Padding(
            padding: EdgeInsets.only(
                right: context.tokens.spacing.vsdslSpacingXs.right)),
        Text(
          S.of(context).v3_settings_broadcast_cast_boards,
          style: TextStyle(
            color: context.tokens.color.vsdslColorOnSurfaceInverse,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _saveButton(BuildContext context, String text,
      {required VoidCallback onClick}) {
    return SizedBox(
      width: 80,
      height: 26,
      child: ElevatedButton(
        onPressed: () {
          onClick();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: context.tokens.color.vsdslColorPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                context.tokens.spacing.vsdslSpacing2xl.top),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.tokens.color.vsdslColorOnSurfaceInverse),
          maxLines: 1,
        ),
      ),
    );
  }

  Widget _broadcastButton(BuildContext context, String text,
      {required VoidCallback onClick}) {
    return SizedBox(
      height: 26,
      child: ElevatedButton(
        onPressed: () {
          onClick();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: context.tokens.color.vsdslColorPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                context.tokens.spacing.vsdslSpacing2xl.top),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: context.tokens.spacing.vsdslSpacingLg.left,
          ),
        ),
        child: Row(
          children: [
            const Image(
                width: 16,
                height: 16,
                image: Svg('assets/images/ic_broadcast.svg')),
            SizedBox(width: context.tokens.spacing.vsdslSpacingXs.left),
            Text(
              text,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: context.tokens.color.vsdslColorOnSurfaceInverse),
            ),
          ],
        ),
      ),
    );
  }
}
