import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';

class V3SettingsBroadcast extends StatelessWidget {
  const V3SettingsBroadcast({super.key});

  @override
  Widget build(BuildContext context) {
    SettingsProvider settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    return Stack(
      children: [
        Positioned(
            left: 13,
            top: 57,
            right: 13,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 26,
                  child: _buildCastDevices(context),
                ),
                Padding(
                    padding: EdgeInsets.only(
                        bottom: context.tokens.spacing.vsdslSpacingSm.bottom)),
                AutoSizeText(
                  S.of(context).v3_shortcuts_cast_device_desc,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    color: context.tokens.color.vsdslColorOnSurfaceVariant,
                  ),
                ),
                Container(
                  height: 1,
                  margin: EdgeInsets.only(
                      top: context.tokens.spacing.vsdslSpacingSm.top,
                      bottom: context.tokens.spacing.vsdslSpacingSm.bottom),
                  color: context.tokens.color.vsdslColorOutlineVariant,
                ),
                SizedBox(
                  height: 26,
                  child: _buildCastBoards(context, settingsProvider),
                ),
                Padding(
                    padding: EdgeInsets.only(
                        bottom: context.tokens.spacing.vsdslSpacingSm.bottom)),
                AutoSizeText(
                  S.of(context).v3_settings_broadcast_cast_boards_desc,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    color: context.tokens.color.vsdslColorOnSurfaceVariant,
                  ),
                ),
              ],
            ))
      ],
    );
  }

  Row _buildCastBoards(
      BuildContext context, SettingsProvider settingsProvider) {
    return Row(
      children: [
        Text(
          S.of(context).v3_shortcuts_cast_device,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Image(
            image: Svg('assets/images/ic_arrow_right.svg'),
            width: 21,
            height: 21,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () {
            settingsProvider.setPage(SettingPageState.broadcastBoards);
          },
        ),
      ],
    );
  }

  Row _buildCastDevices(BuildContext context) {
    return Row(
      children: [
        Text(
          S.of(context).v3_shortcuts_cast_device,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
        const Spacer(),
        Consumer<ChannelProvider>(builder: (_, channelProvider, __) {
          return SizedBox(
            height: 21,
            child: IconButton(
              icon: Image(
                image: Svg(ChannelProvider.isSenderMode
                    ? 'assets/images/ic_switch_on.svg'
                    : 'assets/images/ic_switch_off.svg'),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                ChannelProvider.isSenderMode = !ChannelProvider.isSenderMode;
                if (!ChannelProvider.isSenderMode) {
                  channelProvider.removeSender();
                } else {
                  channelProvider.startRemoteScreen();
                }
              },
            ),
          );
        }),
      ],
    );
  }
}
