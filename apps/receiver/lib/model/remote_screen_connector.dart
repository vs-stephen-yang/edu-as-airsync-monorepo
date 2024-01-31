
import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/providers/channel_provider.dart';

class RemoteScreenConnector {

  String roomId;
  String? host;
  int port;
  Channel channel;
  PresentationState presentationState = PresentationState.stopStreaming;
  String? _sessionId;
  String? get sessionId => _sessionId;
  String? clientId;
  String? senderName;
  String? senderVersion;
  String? senderPlatform;
  bool isDeleted = false;
  bool isTouchEnabled = false;

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
      case ChannelState.closed:
        await onChannelDisconnect?.call();
        break;
    }
  }

  sendRemoteScreenState(RemoteScreenStatus status) {
    final acceptedMessage = RemoteScreenStatusMessage(_sessionId, status);
    channel.send(acceptedMessage);
  }

  onStartRemoteScreen(StartRemoteScreenMessage message) {
    _sessionId = message.sessionId;
    // accept
    sendRemoteScreenState(RemoteScreenStatus.accepted);
    presentationState = PresentationState.waitForStream;
    // info
    final remoteScreenInfoMessage = RemoteScreenInfoMessage(
      _sessionId,
      IonSfuRoom(
        "ws://$host:$port/ws",
        roomId,
      ),);
    channel.send(remoteScreenInfoMessage);
    presentationState = PresentationState.streaming;
  }
}