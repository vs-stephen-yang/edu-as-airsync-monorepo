
import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/providers/channel_provider.dart';

class RemoteScreenConnector {

  String roomId;
  String? host;
  int port;
  Channel channel;
  PresentationState presentationState = PresentationState.stopStreaming;
  String? sessionId;
  String? clientId;
  String? senderName;
  String? senderVersion;
  String? senderPlatform;
  bool isDeleted = false;

  Function()? onChannelDisconnect;

  RemoteScreenConnector(this.channel, this.roomId, this.host, this.port, JoinDisplayMessage message) {
    clientId = message.clientId;
    senderName = message.name;
    senderVersion = message.version;
    senderPlatform = message.platform;

    channel.onStateChange = (state) => _onChannelState(state);
  }

  Future<void> _onChannelState(ChannelState state) async {
    switch (state) {
      case ChannelState.initialized:
        break;
      case ChannelState.connecting:
        break;
      case ChannelState.connected:
        break;
      case ChannelState.disconnected:
        await onChannelDisconnect?.call();
        break;
      case ChannelState.closed:
        await onChannelDisconnect?.call();
        break;
    }
  }

  sendRemoteScreenState(RemoteScreenStatus status) {
    final acceptedMessage = RemoteScreenStatusMessage(sessionId, status);
    channel.send(acceptedMessage);
  }

  onStartRemoteScreen(StartRemoteScreenMessage message) {
    sessionId = message.sessionId;
    // accept
    sendRemoteScreenState(RemoteScreenStatus.accepted);
    presentationState = PresentationState.waitForStream;
    // info
    final remoteScreenInfoMessage = RemoteScreenInfoMessage(
      sessionId,
      IonSfuRoom(
        "ws://$host:$port/ws",
        roomId,
      ),);
    channel.send(remoteScreenInfoMessage);
    presentationState = PresentationState.streaming;
  }

}