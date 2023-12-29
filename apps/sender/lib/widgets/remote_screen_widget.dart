import 'dart:async';

import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';

class RemoteScreenWidget extends StatelessWidget {
  const RemoteScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChannelProvider>(
      builder: (context, channelProvider, _) =>
      RTCVideoView(channelProvider.remoteScreenRenderer)
    );
  }
}
