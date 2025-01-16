import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/widgets/resizable_draggable_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';

class V3GroupHostView extends StatefulWidget {
  const V3GroupHostView({super.key});

  @override
  State<StatefulWidget> createState() => _V3GroupHostViewState();
}

class _V3GroupHostViewState extends State<V3GroupHostView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChannelProvider>(
      builder: (context, provider, child) {
        final videoView = provider.displayGroupVideoView;
        if (!provider.isDisplayGroupVideoAvailable || videoView == null) {
          return const SizedBox.shrink();
        }

        return Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                border: Border.all(
                  color: context.tokens.color.vsdslColorSuccess,
                  width: 4.0,
                ),
                color: Colors.black,
              ),
              child: RTCVideoView(
                videoView.renderer,
                key: videoView.widgetKey,
              ),
            ),
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 4,
                    color: context.tokens.color.vsdslColorSuccess,
                  ),
                ),
              ),
            ),
            ResizableDraggableWidget(
              halfScreen: MediaQuery.of(context).size.width / 2,
              text:
                  '${S.of(context).v3_group_receive_view_status_from} ${provider.displayGroupHostName}',
              onMute: () {
                if (videoView.renderer.srcObject != null) {
                  videoView.renderer.srcObject!.getAudioTracks()[0].enabled =
                      !videoView.renderer.srcObject!
                          .getAudioTracks()[0]
                          .enabled;
                }
              },
              onStop: () {
                provider.stopReceivedFromHost(
                    closeReason: 'stop received from host');
              },
              isMute:
                  videoView.renderer.srcObject?.getAudioTracks()[0].enabled ??
                      false,
            ),
            IgnorePointer(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 4,
                        color: context.tokens.color.vsdslColorSuccess,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
