import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:display_cast_flutter/widgets/resizable_draggable_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';

class V3RemoteScreen extends StatefulWidget {
  const V3RemoteScreen({super.key, this.isModeratorShare = false});

  final bool isModeratorShare;

  @override
  State<StatefulWidget> createState() => _V3RemoteScreenState();
}

class _V3RemoteScreenState extends State<V3RemoteScreen> {
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.expand(),
      child: OrientationBuilder(
        builder: (_, __) {
          ChannelProvider channelProvider =
              Provider.of<ChannelProvider>(context, listen: false);
          return Stack(
            alignment: Alignment.center,
            children: [
              const RemoteVideoView(),
              IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 6,
                      color: context.tokens.color.vsdswColorOnSurface,
                    ),
                  ),
                ),
              ),
              ResizableDraggableWidget(
                halfScreen: MediaQuery.of(context).size.width / 2,
                text: S.current.v3_main_receive_app_receive_from
                    .replaceAll('%s', channelProvider.deviceName ?? ''),
                onStop: () {
                  trackEvent('click_exit', EventCategory.session);

                  if (widget.isModeratorShare) {
                    channelProvider.removeShareRemoteScreenClient();
                  } else {
                    channelProvider.removeRemoteScreenClient();
                  }
                },
              ),
              IgnorePointer(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 4,
                          color: context.tokens.color.vsdswColorSuccess,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class RemoteVideoView extends StatefulWidget {
  const RemoteVideoView({super.key});

  @override
  State<StatefulWidget> createState() => _RemoteVideoView();
}

class _RemoteVideoView extends State<RemoteVideoView> {
  // focus node to capture keyboard events
  final FocusNode _focusNode = FocusNode();

  bool _isVideoAvailable(ChannelProvider channelProvider) {
    return channelProvider.remoteScreenClient != null &&
        channelProvider.remoteScreenClient?.remoteScreenRenderer.textureId !=
            null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChannelProvider>(builder: (_, channelProvider, __) {
      if (_isVideoAvailable(channelProvider)) {
        return NotificationListener<SizeChangedLayoutNotification>(
          onNotification: (notification) {
            channelProvider.remoteScreenClient!.onVideoSizeChanged();
            return true;
          },
          child: KeyboardListener(
            focusNode: _focusNode,
            autofocus: true,
            onKeyEvent: (KeyEvent event) {
              channelProvider.remoteScreenClient?.onKeyDown(event);
            },
            child: Listener(
              onPointerDown: channelProvider.remoteScreenClient!.onTouchStart,
              onPointerMove: channelProvider.remoteScreenClient!.onTouchMove,
              onPointerUp: channelProvider.remoteScreenClient!.onTouchEnd,
              child: RTCVideoView(
                channelProvider.remoteScreenClient!.remoteScreenRenderer,
                key: channelProvider.remoteScreenClient!.rtcWidgetKey,
              ),
            ),
          ),
        );
      } else {
        return SizedBox(
          child: Text(
            S.of(context).remote_screen_wait,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
            ),
          ),
        );
      }
    });
  }
}
