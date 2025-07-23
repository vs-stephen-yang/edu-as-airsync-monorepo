import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/utilities/app_constants.dart';
import 'package:display_cast_flutter/widgets/remote_screen_tool.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ModeratorPresentShare extends StatefulWidget {
  const ModeratorPresentShare({super.key});

  @override
  State createState() => _ModeratorPresentShareStates();
}

class _ModeratorPresentShareStates extends State<ModeratorPresentShare> {
  // focus node to capture keyboard events
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  bool _isVideoAvailable(ChannelProvider channelProvider) {
    return channelProvider.remoteScreenClient != null &&
        channelProvider.remoteScreenClient!.isVideoAvailable;
  }

  Widget _buildVideoView(ChannelProvider channelProvider) {
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (notification) {
        channelProvider.remoteScreenClient!.onVideoSizeChanged();
        return true;
      },
      child: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (KeyEvent event) {
          channelProvider.remoteScreenClient!.onKeyDown(event);
        },
        child: Listener(
          onPointerDown: channelProvider.remoteScreenClient!.onTouchStart,
          onPointerMove: channelProvider.remoteScreenClient!.onTouchMove,
          onPointerUp: channelProvider.remoteScreenClient!.onTouchEnd,
          child: channelProvider.remoteScreenClient!.createVideoView,
        ),
      ),
    );
  }

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
                    return _isVideoAvailable(channelProvider)
                        ? _buildVideoView(channelProvider)
                        : SizedBox(
                            child: Text(S.of(context).remote_screen_wait,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: AppConstants.fontSizeNormal)));
                  },
                ),
              ),
              RemoteScreenTool(
                key: GlobalKey(),
                isModeratorShare: true,
              ),
            ],
          );
        },
      ),
    );
  }
}
