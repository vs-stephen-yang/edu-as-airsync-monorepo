import 'package:display_channel/display_channel.dart';
import 'package:flutter_ion_sfu/flutter_ion_sfu_listener.dart';

enum RemotePresentationState {
  stopStreaming,
  waitForStream,
  streaming,
}

class RemoteScreenConnector {
  String roomId;
  String? host;
  int port;
  Channel channel;
  RemotePresentationState remotePresentationState =
      RemotePresentationState.stopStreaming;
  String? _sessionId;

  String? get sessionId => _sessionId;
  String? clientId;
  String? senderName;
  String? senderVersion;
  String? senderPlatform;
  bool isDeleted = false;
  bool isTouchEnabled = false;

  Function(String message)? _signalHandler;

  String get senderNameWithEllipsis {
    String result = senderName ?? '';
    if (result.length > 10) {
      result = '${result.substring(0, 10)}..';
    }
    return result;
  }

  Function()? onDisconnect;

  RemoteScreenConnector(
    this.channel,
    this.roomId,
    this.host,
    this.port,
    JoinDisplayMessage message,
  ) {
    clientId = message.clientId;
    senderName = message.name;
    senderVersion = message.version;
    senderPlatform = message.platform;

    channel.stateStream.listen((ChannelState state) async {
      await _onChannelState(state);
    });
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
        await onDisconnect?.call();
        break;
    }
  }

  sendRemoteScreenState(RemoteScreenStatus status) {
    final acceptedMessage = RemoteScreenStatusMessage(_sessionId, status);
    channel.send(acceptedMessage);
  }

  onStartRemoteScreen(
    StartRemoteScreenMessage message,
    List<RtcIceServer>? iceServers,
  ) {
    _sessionId = message.sessionId;
    // accept
    sendRemoteScreenState(RemoteScreenStatus.accepted);
    remotePresentationState = RemotePresentationState.waitForStream;
    // info
    final remoteScreenInfoMessage = RemoteScreenInfoMessage(
      _sessionId,
      IonSfuRoom(
        "ws://$host:$port/ws",
        roomId,
        iceServers: iceServers,
      ),
    );
    channel.send(remoteScreenInfoMessage);
    remotePresentationState = RemotePresentationState.streaming;
  }

  void registerSignalHandler(Function(String message)? handler) {
    _signalHandler = handler;
  }

  void processSignalFromPeer(String message) {
    _signalHandler?.call(message);
  }

  // send signal message to the peer
  void sendSignalToPeer(String message) {
    channel.send(
      RemoteScreenSignalMessage(_sessionId, message),
    );
  }

  void onRtcConnectionState(IceConnectionState state) {
    if (state == IceConnectionState.ICEConnectionStateFailed ||
        state == IceConnectionState.ICEConnectionStateClosed) {
      remotePresentationState = RemotePresentationState.stopStreaming;
      onDisconnect?.call();
    }
  }
}
