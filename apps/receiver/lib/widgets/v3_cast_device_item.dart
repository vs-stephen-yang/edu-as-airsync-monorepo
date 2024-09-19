import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/remote_screen_connector.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';

class V3CastDeviceItem extends StatefulWidget {
  const V3CastDeviceItem({super.key, required this.index});

  final int index;

  @override
  State<StatefulWidget> createState() => _V3CastDeviceItemState();
}

class _V3CastDeviceItemState extends State<V3CastDeviceItem> {
  @override
  Widget build(BuildContext context) {
    ChannelProvider channelProvider =
        Provider.of<ChannelProvider>(context, listen: false);
    RemoteScreenConnector remoteScreenConnector =
        channelProvider.remoteScreenConnectors[widget.index];
    return SizedBox(
      width: 283,
      height: remoteScreenConnector.isTouchEnabled ? 40 : 33,
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                remoteScreenConnector.senderName ?? '',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: context.tokens.color.vsdslColorOnSurface,
                ),
                maxLines: 1,
              ),
              if (remoteScreenConnector.isTouchEnabled)
                SizedBox(width: context.tokens.spacing.vsdslSpacingSm.top),
              if (remoteScreenConnector.isTouchEnabled)
                Container(
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: context.tokens.radii.vsdslRadiusSm,
                      side: BorderSide(
                        width: 1,
                        color: context.tokens.color.vsdslColorSuccess,
                      ),
                    ),
                  ),
                  padding: context.tokens.spacing.vsdslSpacingXs,
                  child: AutoSizeText(
                    S.of(context).v3_cast_to_device_touch_back_enabled,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: context.tokens.color.vsdslColorSuccess,
                    ),
                    maxLines: 1,
                    minFontSize: 8,
                  ),
                ),
            ],
          ),
          const Spacer(),
          if (!remoteScreenConnector.isTouchEnabled)
            Row(
              children: [
                SizedBox(
                  width: 104,
                  height: 27,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      remoteScreenConnector.isTouchEnabled = true;
                      channelProvider.remoteScreenServe
                          .enableRemoteControlBySessionId(
                              remoteScreenConnector.sessionId!,
                              remoteScreenConnector.isTouchEnabled);
                      setState(() {});
                    },
                    icon: const SizedBox(
                      width: 16,
                      height: 16,
                      child: Image(
                        image:
                            Svg('assets/images/ic_cast_device_touch_back.svg'),
                      ),
                    ),
                    label: Text(
                      S.of(context).v3_cast_to_device_touch_back,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.tokens.color.vsdslColorOnSurfaceInverse,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 5,
                      backgroundColor: context.tokens.color.vsdslColorSecondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: context.tokens.radii.vsdslRadiusFull,
                      ),
                      padding: EdgeInsets.zero,
                      shadowColor: context.tokens.color.vsdslColorSecondary,
                    ),
                  ),
                ),
                SizedBox(width: context.tokens.spacing.vsdslSpacingSm.top),
                SizedBox(
                  width: 27,
                  height: 27,
                  child: IconButton(
                    icon: const Image(
                      image: Svg('assets/images/ic_participant_close.svg'),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      if (remoteScreenConnector.remotePresentationState ==
                          RemotePresentationState.streaming) {
                        channelProvider.removeSender(
                            remoteScreenConnector: remoteScreenConnector);
                      }
                    },
                  ),
                ),
              ],
            ),
          if (remoteScreenConnector.isTouchEnabled)
            Row(
              children: [
                SizedBox(
                  width: 27,
                  height: 27,
                  child: IconButton(
                    icon: const Image(
                      image: Svg('assets/images/ic_participant_stop.svg'),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      remoteScreenConnector.isTouchEnabled = false;
                      channelProvider.remoteScreenServe
                          .enableRemoteControlBySessionId(
                              remoteScreenConnector.sessionId!,
                              remoteScreenConnector.isTouchEnabled);
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
