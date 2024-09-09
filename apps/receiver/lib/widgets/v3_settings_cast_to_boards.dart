import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/group_provider.dart';
import 'package:display_flutter/providers/settings_provider.dart';
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
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SettingsProvider settingsProvider =
        provider.Provider.of<SettingsProvider>(context, listen: false);

    final groupNotifier = ref.read(groupProvider.notifier);
    final isBroadcastingToGroup =
        ref.watch(groupProvider.select((state) => state.broadcastToGroup));
    final broadcastType = ref
        .watch(groupProvider.select((state) => state.broadcastGroupLaunchType));

    return Stack(
      children: [
        Positioned(
            left: 0, top: 0, child: _buildTittle(settingsProvider, context)),
        Positioned(
            left: 13,
            top: 57,
            right: 13,
            child: SizedBox(
              height: 293,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 26,
                    child: Row(
                      children: [
                        Text(
                          S.of(context).v3_settings_broadcast_to_display_group,
                          style: TextStyle(
                            color:
                                context.tokens.color.vsdslColorOnSurfaceInverse,
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
                              groupNotifier
                                  .setBroadcastToGroup(!isBroadcastingToGroup);
                            },
                          ),
                        )
                      ],
                    ),
                  ),
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
                  Container(
                    height: 1,
                    margin: EdgeInsets.only(
                        bottom: context.tokens.spacing.vsdslSpacingMd.bottom),
                    color: context.tokens.color.vsdslColorOutlineVariant,
                  ),
                  Container(
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
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: groupNotifier.getListenListSize(),
                      itemBuilder: (context, index) {
                        return Container(
                          height: 26,
                          margin: EdgeInsets.only(
                              right: 8,
                              left: 8,
                              bottom:
                                  context.tokens.spacing.vsdslSpacingSm.bottom),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Checkbox(
                                    value: groupNotifier.selectedList.any(
                                        (element) =>
                                            element.id ==
                                            groupNotifier
                                                .getListenClient(index)
                                                .id),
                                    activeColor: context
                                        .tokens.color.vsdslColorSecondary,
                                    side: BorderSide(
                                        color: context
                                            .tokens.color.vsdslColorOnPrimary,
                                        width: 2),
                                    onChanged: (bool? value) {
                                      if (value != null) {
                                        if (value) {
                                          groupNotifier.addToSelectedList(
                                              groupNotifier
                                                  .getListenClient(index));
                                        } else {
                                          groupNotifier.removeFromSelectedList(
                                              groupNotifier
                                                  .getListenClient(index));
                                        }
                                      }
                                    }),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(
                                      right: context.tokens.spacing
                                          .vsdslSpacingSm.right)),
                              Text(
                                groupNotifier.getListenClient(index).name,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: context.tokens.color
                                        .vsdslColorOnSurfaceInverse),
                              ),
                              const Spacer(),
                              Text(
                                groupNotifier
                                    .getListenClient(index)
                                    .displayCode,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: context.tokens.color
                                        .vsdslColorOnSurfaceInverse),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )),
        if (isBroadcastingToGroup)
          Positioned(
            right: 13,
            bottom: 13,
            child: Align(
              alignment: Alignment.centerRight,
              child: broadcastType == BroadcastGroupLaunchType.onlyWhenCasting
                  ? _saveButton(
                      context, S.of(context).v3_settings_device_name_save,
                      onClick: () {
                      settingsProvider.setPage(SettingPageState.deviceSetting);
                    })
                  : _broadcastButton(
                      context,
                      S.of(context).v3_settings_display_group_cast,
                      onClick: () {},
                    ),
            ),
          )
      ],
    );
  }

  V3SettingsRadioGroupItem _buildRadioGroupItem(
      String text, BroadcastGroupLaunchType type, GroupProvider groupNotifier) {
    return V3SettingsRadioGroupItem(
        value: text,
        defaultSelectedState: groupNotifier.broadcastGroupLaunchType == type,
        onChange: (bool selected) {
          if (selected) {
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
    return InkWell(
      onTap: () {
        onClick();
      },
      child: Container(
        width: 80,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.tokens.color.vsdslColorSecondary,
          borderRadius:
              BorderRadius.circular(context.tokens.spacing.vsdslSpacing2xl.top),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
          maxLines: 1,
        ),
      ),
    );
  }

  Widget _broadcastButton(BuildContext context, String text,
      {required VoidCallback onClick}) {
    return InkWell(
      onTap: () {
        onClick();
      },
      child: Container(
        width: 80,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.tokens.color.vsdslColorSecondary,
          borderRadius:
              BorderRadius.circular(context.tokens.spacing.vsdslSpacing2xl.top),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Image(
                width: 16,
                height: 16,
                image: Svg('assets/images/ic_broadcast.svg')),
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
