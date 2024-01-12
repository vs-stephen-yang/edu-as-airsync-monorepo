import 'package:display_channel/display_channel.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:ion_sdk_flutter/flutter_ion.dart' as ion;
import 'package:ion_sdk_flutter/flutter_ion.dart';
import 'package:uuid/uuid.dart';

class RemoteScreenClient {
  RemoteScreenClient(this._channel);

  DisplayChannelClient? _channel;
  final String _sessionId = const Uuid().v4();
  Client? _client;
  RTCVideoRenderer get remoteScreenRenderer =>  _remoteScreenRenderer;
  RTCVideoRenderer _remoteScreenRenderer = RTCVideoRenderer();
  RTCDataChannel? _dataChannel;

  Future handleRemoteScreenInfo(String url, String roomId, Function onTrack) async {

    JsonRPCSignal signal = JsonRPCSignal(url);

    _client = await Client.create(
      sid: roomId,
      uid: const Uuid().v4(),
      signal: signal,);

    _dataChannel = await _client!.createDataChannel(_sessionId);

    _client!.ontrack = (track, RemoteStream remoteStream) async {
      await _remoteScreenRenderer.initialize();
      _remoteScreenRenderer.srcObject = remoteStream.stream;
      onTrack();
    };

    _client!.ondatachannel = (RTCDataChannel dc) {
      if (dc.label == _sessionId) {
        _dataChannel = dc;
      }
    };
  }

  Future sendStartRemoteScreenMessage() async {
    final msg = StartRemoteScreenMessage(_sessionId);
    _channel?.send(msg);
  }

  Future sendRemoteScreenState(RemoteScreenStatus status) async {
    final stateMessage = RemoteScreenStatusMessage(_sessionId, status);
    _channel?.send(stateMessage);
  }

  Future remove() async {
    if (_remoteScreenRenderer.textureId != null) {
      _remoteScreenRenderer.srcObject = null;
    }
    await _remoteScreenRenderer.dispose();
    _remoteScreenRenderer = RTCVideoRenderer();
    _client?.close();
    _client = null;
  }
}