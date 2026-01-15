import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/model/mirror_request.dart';
import 'package:display_flutter/model/rtc_connector.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/widgets/mirror_view.dart';
import 'package:display_flutter/widgets/v3_streaming_function.dart';
import 'package:display_flutter/widgets/v3_webrtc_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'streaming_view_config.dart';

class StreamingItem extends StatelessWidget {
  final int index;
  final int count;
  final int? enlarged;
  final Size screenSize;
  final int pageIndex;
  final LayoutPosition Function() calculatePosition;

  const StreamingItem({
    super.key,
    required this.index,
    required this.count,
    required this.enlarged,
    required this.screenSize,
    required this.pageIndex,
    required this.calculatePosition,
  });

  @override
  Widget build(BuildContext context) {
    final pos = calculatePosition();
    final smartScaling = Provider.of<ChannelProvider>(context).smartScaling &&
        (count == 1 || (count > 1 && enlarged != null));

    return Positioned(
      left: pos.left,
      top: pos.top,
      right: pos.right,
      bottom: pos.bottom,
      child: SizedBox(
        width: pos.width,
        height: pos.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (HybridConnectionList().isRTCConnector(index))
              V3WebrtcView(
                rtcConnector:
                    HybridConnectionList().getConnection<RTCConnector>(index),
                index: index,
                screenWidth: screenSize.width,
                screenHeight: screenSize.height,
                displaySmartScalingEnabled: smartScaling,
              ),
            if (HybridConnectionList().isMirrorRequest(index))
              MirrorView(
                mirrorRequest:
                    HybridConnectionList().getConnection<MirrorRequest>(index),
                screenWidth: screenSize.width,
                screenHeight: screenSize.height,
                displaySmartScalingEnabled: smartScaling,
              ),
            Consumer<ChannelProvider>(
              builder: (_, __, ___) {
                return HybridConnectionList().isPresenting(index: index) ||
                        HybridConnectionList()
                            .isRTCConnectorWaitForStream(index: index)
                    ? Positioned(
                        bottom: 0,
                        child: V3StreamingFunction(
                          index: index,
                          availableWidth: pos.width,
                        ),
                      )
                    : const SizedBox.shrink();
              },
            ),
            if (HybridConnectionList().isStopPresenting(index))
              const WaitingOverlay(),
          ],
        ),
      ),
    );
  }
}

class WaitingOverlay extends StatelessWidget {
  const WaitingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ExcludeSemantics(
          child: SvgPicture.asset(
            'assets/images/ic_split_screen_waiting.svg',
            width: 92,
            height: 80,
          ),
        ),
        AutoSizeText(
          S.of(context).v3_waiting_join,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: context.tokens.color.vsdslColorOnSurfaceInverse,
          ),
        ),
      ],
    );
  }
}
