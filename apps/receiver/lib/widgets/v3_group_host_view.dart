import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
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
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Center(
                child: IntrinsicWidth(
                  child: Container(
                    height: 37,
                    decoration: BoxDecoration(
                      color: context.tokens.color.vsdslColorSuccess,
                      borderRadius: context.tokens.radii.vsdslRadiusmd,
                    ),
                    padding: context.tokens.spacing.vsdslSpacingSm,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${S.of(context).v3_group_receive_view_status_from} ${provider.displayGroupHostName}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                            width: context.tokens.spacing.vsdslSpacingSm.right),
                        SizedBox(
                          width: 26,
                          height: 26,
                          child: IconButton(
                            icon: const Image(
                              image: Svg(
                                  'assets/images/ic_group_mute.svg'), //TODO:unmute
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              videoView.renderer.srcObject!
                                      .getAudioTracks()[0]
                                      .enabled =
                                  !videoView.renderer.srcObject!
                                      .getAudioTracks()[0]
                                      .enabled;
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              right:
                                  context.tokens.spacing.vsdslSpacingSm.right),
                        ),
                        SizedBox(
                          width: 80,
                          height: 26,
                          // color: Colors.green,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9999),
                              ),
                            ),
                            child: Text(
                              S.of(context).v3_group_receive_view_status_stop,
                              style: TextStyle(
                                color: context.tokens.color.vsdslColorNeutral,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
