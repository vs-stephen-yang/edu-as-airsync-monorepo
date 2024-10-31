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
    return Stack(
      children: [
        Positioned(
          left: context.tokens.spacing.vsdslSpacingXl.left,
          top: 57,
          right: context.tokens.spacing.vsdslSpacingXl.right,
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
              const CastToDevices(),
              SizedBox(height: context.tokens.spacing.vsdslSpacingMd.top),
              const CastToBoards(),
            ],
          ),
        ),
      ],
    );
  }
}

class CastToDevices extends StatelessWidget {
  const CastToDevices({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 325,
      height: 88,
      decoration: BoxDecoration(
        borderRadius: context.tokens.radii.vsdslRadiusLg,
        color: context.tokens.color.vsdslColorSurface900,
      ),
      padding: context.tokens.spacing.vsdslSpacingXl,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 43,
            height: 43,
            child: Image(
              image: Svg('assets/images/ic_cast_to_devices.svg'),
            ),
          ),
          SizedBox(
            width: context.tokens.spacing.vsdslSpacingXl.left,
          ),
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: 27,
                  child: Row(
                    children: [
                      AutoSizeText(
                        S.of(context).v3_settings_broadcast_devices,
                        style: TextStyle(
                          color:
                              context.tokens.color.vsdslColorOnSurfaceInverse,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Consumer<ChannelProvider>(
                        builder: (_, channelProvider, __) {
                          return SizedBox(
                            width: 36,
                            height: 21,
                            child: IconButton(
                              icon: Image(
                                image: Svg(channelProvider.isSenderMode
                                    ? 'assets/images/ic_switch_on.svg'
                                    : 'assets/images/ic_switch_off.svg'),
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () async {
                                if (channelProvider.isSenderMode) {
                                  await channelProvider.removeSender(
                                      fromSender: true);
                                } else {
                                  await channelProvider.startRemoteScreen(
                                      fromSender: true);
                                }
                              },
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
                    color: context.tokens.color.vsdslColorOnSurfaceVariant,
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
  const CastToBoards({super.key});

  @override
  Widget build(BuildContext context) {
    SettingsProvider settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    return Container(
      width: 325,
      height: 88,
      decoration: BoxDecoration(
        borderRadius: context.tokens.radii.vsdslRadiusLg,
        color: context.tokens.color.vsdslColorSurface900,
      ),
      padding: context.tokens.spacing.vsdslSpacingXl,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 43,
            height: 43,
            child: Image(
              image: Svg('assets/images/ic_cast_to_boards.svg'),
            ),
          ),
          SizedBox(
            width: context.tokens.spacing.vsdslSpacingXl.left,
          ),
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: 27,
                  child: Row(
                    children: [
                      AutoSizeText(
                        S.of(context).v3_settings_broadcast_boards,
                        style: TextStyle(
                          color:
                              context.tokens.color.vsdslColorOnSurfaceInverse,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 21,
                        height: 21,
                        child: IconButton(
                          icon: const Image(
                            image: Svg('assets/images/ic_arrow_right.svg'),
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            settingsProvider
                                .setPage(SettingPageState.broadcastBoards);
                          },
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
                    color: context.tokens.color.vsdslColorOnSurfaceVariant,
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
