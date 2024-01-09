
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';

class RemoteScreenWidget extends StatelessWidget {
  const RemoteScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChannelProvider>(builder: (context, channelProvider, _) {
      return channelProvider.client != null && channelProvider.client?.remoteScreenRenderer.textureId != null
          ? RTCVideoView(channelProvider.client!.remoteScreenRenderer)
          : SizedBox(child: Text(S.of(context).remote_screen_wait, style: const TextStyle(color: Colors.white, fontSize: 14)));
    });
  }
}
