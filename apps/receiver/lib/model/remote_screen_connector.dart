import 'dart:async';

import 'package:display_channel/display_channel.dart';
import 'package:flutter_golang_server/flutter_ion_sfu_listener.dart';

enum RemotePresentationState {
  stopStreaming,
  waitForStream,
  streaming,
}

abstract class RemoteScreenConnector {
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

  Future<void> onStartRemoteScreen(
      StartRemoteScreenMessage message, List<RtcIceServer>? iceServers);

  void processSignalFromPeer(String message);

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
    final remoteStatusMsg = RemoteScreenStatusMessage(_sessionId, status);
    channel.send(remoteStatusMsg);
  }
}

class RtcScreenConnector extends RemoteScreenConnector {
  String roomId;
  String? host;
  int port;

  Function(String message)? _signalHandler;
  final Completer _signalHandlerCompleter = Completer();

  RtcScreenConnector(
    Channel channel,
    this.roomId,
    this.host,
    this.port,
    JoinDisplayMessage message,
  ) : super(channel, message);

  @override
  onStartRemoteScreen(
    StartRemoteScreenMessage message,
    List<RtcIceServer>? iceServers,
  ) async {
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
    await _signalHandlerCompleter.future;
    channel.send(remoteScreenInfoMessage);
    remotePresentationState = RemotePresentationState.streaming;
  }

  void registerSignalHandler(Function(String message)? handler) {
    _signalHandler = handler;
    if (!_signalHandlerCompleter.isCompleted) {
      _signalHandlerCompleter.complete();
    }
  }

  @override
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

class MulticastScreenConnector extends RemoteScreenConnector {
  MulticastScreenConnector(super.channel, super.msg);

  @override
  Future<void> onStartRemoteScreen(
      StartRemoteScreenMessage message, List<RtcIceServer>? iceServers) {
    // TODO: implement onStartRemoteScreen
    throw UnimplementedError();
  }

  @override
  void processSignalFromPeer(String message) {}
}
