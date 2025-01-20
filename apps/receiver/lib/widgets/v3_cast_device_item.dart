import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/remote_screen_connector.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:gap/gap.dart';
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

    String status = S.of(context).v3_cast_to_device_Receiving;
    if (remoteScreenConnector.isTouchEnabled) {
      status += ' + ';
      status += S.of(context).v3_cast_to_device_touch_enabled;
    }
    return Container(
      alignment: Alignment.center,
      height: 37,
      child: Row(
        children: [
          const Image(
            width: 32,
            height: 32,
            image: Svg('assets/images/ic_cast_device.svg'),
          ),
          const Gap(5),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  remoteScreenConnector.senderName ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.tokens.color.vsdslColorOnSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(width: context.tokens.spacing.vsdslSpacingXs.top),
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
                    status,
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
          ),
          const Gap(16),
          // 以下按鈕部分，做個分類
          ...[
            V3Focus(
              child: SizedBox(
                width: (remoteScreenConnector.isTouchEnabled) ? 83 : 104,
                height: 27,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (remoteScreenConnector.isTouchEnabled) {
                      remoteScreenConnector.isTouchEnabled = false;
                    } else {
                      remoteScreenConnector.isTouchEnabled = true;
                    }
                    channelProvider.remoteScreenServe
                        .enableRemoteControlBySessionId(
                            remoteScreenConnector.sessionId!,
                            remoteScreenConnector.isTouchEnabled);
                    setState(() {});
                  },
                  icon: SizedBox(
                    width: 16,
                    height: 16,
                    child: Image(
                      image: Svg(remoteScreenConnector.isTouchEnabled
                          ? 'assets/images/ic_finger_disable.svg'
                          : 'assets/images/ic_finger_touch.svg'),
                    ),
                  ),
                  label: Text(
                    remoteScreenConnector.isTouchEnabled
                        ? S.of(context).v3_cast_to_device_touch_back_disable
                        : S.of(context).v3_cast_to_device_touch_back,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: remoteScreenConnector.isTouchEnabled
                          ? context.tokens.color.vsdslColorError
                          : context.tokens.color.vsdslColorOnSurface,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 5,
                    backgroundColor:
                        context.tokens.color.vsdslColorOnSurfaceInverse,
                    shape: RoundedRectangleBorder(
                      borderRadius: context.tokens.radii.vsdslRadiusFull,
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: context.tokens.spacing.vsdslSpacingSm.left),
                    shadowColor: context.tokens.color.vsdslColorNeutral,
                  ),
                ),
              ),
            ),
            SizedBox(width: context.tokens.spacing.vsdslSpacingSm.top),
            V3Focus(
              child: SizedBox(
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
                        fromSender: true,
                        remoteScreenConnector: remoteScreenConnector,
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
