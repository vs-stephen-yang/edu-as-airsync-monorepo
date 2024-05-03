import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/utilities/app_constants.dart';
import 'package:display_cast_flutter/widgets/remote_screen_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';

class RemoteScreenWidget extends StatelessWidget {
  const RemoteScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.expand(),
      child: OrientationBuilder(
        builder: (_, __) {
          return Stack(
            children: [
              Center(
                child: Consumer<ChannelProvider>(
                  builder: (context, channelProvider, _) {
                    return channelProvider.remoteScreenClient != null &&
                            channelProvider.remoteScreenClient
                                    ?.remoteScreenRenderer.textureId !=
                                null
                        ? NotificationListener<SizeChangedLayoutNotification>(
                            onNotification: (notification) {
                              channelProvider.remoteScreenClient!
                                  .onVideoSizeChanged();
                              return true;
                            },
                            child: Listener(
                              onPointerDown: channelProvider
                                  .remoteScreenClient!.onTouchStart,
                              onPointerMove: channelProvider
                                  .remoteScreenClient!.onTouchMove,
                              onPointerUp: channelProvider
                                  .remoteScreenClient!.onTouchEnd,
                              child: RTCVideoView(
                                  channelProvider
                                      .remoteScreenClient!.remoteScreenRenderer,
                                  key: channelProvider
                                      .remoteScreenClient!.rtcWidgetKey),
                            ),
                          )
                        : SizedBox(
                            child: Text(S.of(context).remote_screen_wait,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: AppConstants.fontSizeNormal)));
                  },
                ),
              ),
              RemoteScreenTool(key: GlobalKey()),
            ],
          );
        },
      ),
    );
  }
}
