import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';

class V3SettingsMirroring extends StatelessWidget {
  const V3SettingsMirroring({super.key});

  @override
  Widget build(BuildContext context) {
    ChannelProvider channelProvider =
        Provider.of<ChannelProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.only(left: 13, top: 57, right: 13),
      child: Consumer<MirrorStateProvider>(
        builder: (BuildContext context, MirrorStateProvider mirrorStateProvider,
            Widget? child) {
          return Column(
            children: [
              MirroringItem(
                  name: S.of(context).v3_shortcuts_airplay,
                  enabled: mirrorStateProvider.airplayEnabled,
                  callback: () {
                    if (mirrorStateProvider.airplayEnabled) {
                      mirrorStateProvider.stopAirPlay();
                      channelProvider.blockRtcConnection = false;
                    } else {
                      mirrorStateProvider.startAirPlay();
                      channelProvider.blockRtcConnection = true;
                    }
                  }),
              Visibility(
                  visible: mirrorStateProvider.airplayEnabled,
                  child: SizedBox(
                    height: 26,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                              value: mirrorStateProvider.airPlayCodeEnable,
                              activeColor:
                                  context.tokens.color.vsdslColorSecondary,
                              side: BorderSide(
                                  color:
                                      context.tokens.color.vsdslColorOnPrimary,
                                  width: 2),
                              onChanged: (bool? value) {
                                if (value != null) {
                                  mirrorStateProvider
                                      .setAirPlayCodeEnable(value);
                                }
                              }),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              right:
                                  context.tokens.spacing.vsdslSpacingSm.right),
                        ),
                        AutoSizeText(
                          S.of(context).v3_settings_mirroring_require_passcode,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.tokens.color.vsdslColorOnPrimary,
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  )),
              Padding(
                  padding: EdgeInsets.only(
                      bottom: context.tokens.spacing.vsdslSpacingSm.bottom)),
              MirroringItem(
                  name: S.of(context).v3_shortcuts_google_cast,
                  enabled: mirrorStateProvider.googleCastEnabled,
                  callback: () {
                    if (mirrorStateProvider.googleCastEnabled) {
                      mirrorStateProvider.stopGoogleCast();
                      channelProvider.blockRtcConnection = false;
                    } else {
                      mirrorStateProvider.startGoogleCast();
                      channelProvider.blockRtcConnection = true;
                    }
                  }),
              Padding(
                  padding: EdgeInsets.only(
                      bottom: context.tokens.spacing.vsdslSpacingSm.bottom)),
              MirroringItem(
                  name: S.of(context).v3_shortcuts_miracast,
                  enabled: mirrorStateProvider.miracastEnabled,
                  callback: () {
                    if (mirrorStateProvider.miracastEnabled) {
                      mirrorStateProvider.stopMiracast();
                      channelProvider.blockRtcConnection = false;
                    } else {
                      mirrorStateProvider.startMiracast();
                      channelProvider.blockRtcConnection = true;
                    }
                  }),
              Container(
                height: 1,
                margin: EdgeInsets.only(
                    top: context.tokens.spacing.vsdslSpacingSm.top,
                    bottom: context.tokens.spacing.vsdslSpacingSm.bottom),
                color: context.tokens.color.vsdslColorOutlineVariant,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                        value: mirrorStateProvider.isMirrorConfirmation,
                        side: BorderSide(
                            color: context.tokens.color.vsdslColorOnPrimary,
                            width: 2),
                        activeColor: context.tokens.color.vsdslColorSecondary,
                        onChanged: (bool? value) {
                          mirrorStateProvider.isMirrorConfirmation =
                              !mirrorStateProvider.isMirrorConfirmation;
                        }),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        right: context.tokens.spacing.vsdslSpacingSm.right),
                  ),
                  AutoSizeText(
                    S.of(context).v3_settings_mirroring_auto_accept,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(
                    bottom: context.tokens.spacing.vsdslSpacingSm.bottom,
                    left: 20 + context.tokens.spacing.vsdslSpacingSm.right),
                child: AutoSizeText(
                  S.of(context).v3_settings_mirroring_auto_accept_desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.tokens.color.vsdslColorOnSurfaceVariant,
                  ),
                  maxLines: 1,
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class MirroringItem extends StatelessWidget {
  const MirroringItem(
      {super.key,
      required this.name,
      required this.enabled,
      required this.callback});

  final String name;
  final bool enabled;
  final VoidCallback callback;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 26,
      child: Row(
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: callback,
            child: Image(
              width: 36,
              height: 21,
              image: Svg(enabled
                  ? 'assets/images/ic_switch_on.svg'
                  : 'assets/images/ic_switch_off.svg'),
            ),
          ),
        ],
      ),
    );
  }
}
