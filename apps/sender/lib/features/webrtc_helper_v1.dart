import 'dart:async';
import 'dart:convert';
import 'dart:io' show HttpStatus, Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:display_cast_flutter/features/webrtc_helper.dart';
import 'package:display_cast_flutter/utilities/debug_mode_print.dart';
import 'package:display_cast_flutter/utilities/sdp_utility.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:collection/collection.dart';
import 'package:window_size/window_size.dart';

class WebRTCHelperV1 extends WebRTCHelper {
  WebRTCHelperV1(String getIceUrl) : super(getIceUrl) {
    _getIceUrl = getIceUrl;
  }

  late final String _getIceUrl;
  final Map<String, dynamic> _configuration = {
    'sdpSemantics': 'unified-plan',
  };

  String? _displayCode;
  dynamic _deviceId;

  RTCPeerConnection? _pc;
  RTCDataChannel? _dc;
  io.Socket? _socket;

  @override
  Future<void> makeCall(
      String signalUrl, String id, String code, dynamic source) async {
    _displayCode = code;
    if (Platform.isAndroid) {
    } else if (Platform.isIOS) {
      _deviceId = 'broadcast';
    } else {
      _deviceId = {'exact': source.id};
    }

    await _signalConnect(signalUrl, id);
    await _peerConnectionConnect();
  }

  @override
  Future<void> hangUp() async {
    await _peerConnectionDisconnect();
    _signalDisconnect();
  }

  @override
  void streamStop() {
    _pc?.getLocalStreams().forEach((element) {
      element?.getTracks().first.enabled = false;
      element?.getTracks().first.stop();
    });
  }

  @override
  void streamPause() {
    _pc?.getLocalStreams().forEach((element) {
      element?.getTracks().first.enabled = false;
    });
  }

  @override
  void streamResume() {
    _pc?.getLocalStreams().forEach((element) {
      element?.getTracks().first.enabled = true;
    });
  }

  Future<void> _signalConnect(String signalUrl, String id) async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final macOsInfo = await deviceInfo.macOsInfo;
    _socket = io.io(
        'https://mrtc.myviewboard.cloud',
        io.OptionBuilder()
            .setTransports(['websocket'])
            .enableForceNew()
            .enableForceNewConnection()
            .enableReconnection()
            .setReconnectionAttempts(5)
            .setQuery({
          "clientType": 'Mac OS', // 'Web'
          "clientVersion": '${macOsInfo.majorVersion}.${macOsInfo.minorVersion}.${macOsInfo.patchVersion}', //'4.2.1',
          "token": id,
        })
            .build());

    _socket!.onConnect((_) async {
      debugModePrint('connect', type: runtimeType);
    });

    _socket!.on('server-authenticated', (data) async {
      debugModePrint("server-authenticated: ${data['uid']}", type: runtimeType);
      _send('chat-closed');
      _send('chat-ua', message: await getUserAgent());
      await _publish();
    });

    _socket!.on('owt-message', (data) async {
      debugModePrint(data, type: runtimeType);
      final msg = jsonDecode(data['data']);
      final type = msg['type'];

      if (type == 'chat-ua') {

      }

      if (type == 'chat-track-sources') {

      }

      if (type == "chat-signal") {
        await _handleSignal(msg['data']);
      }
    });

    _socket!.on('$_displayCode/disconnect', (data) {

    });

    _socket!.on('$_displayCode', (data) {

    });

    _socket!.onDisconnect((_) {
      debugModePrint('disconnect', type: runtimeType);
    });

  }

  void _signalDisconnect() {
    try {
      _socket?.disconnect();
      _socket?.dispose();
      _socket = null;
    } catch (e) {
      debugModePrint(e, type: runtimeType);
    }
  }

  Future<void> _peerConnectionConnect() async {
    if (!_configuration.containsKey('iceServers')) {
      await _getIceServers();
    }

    _pc = await createPeerConnection(_configuration);

    _pc!.onAddTrack = _onAddTrack;
    _pc!.onSignalingState = _onSignalingState;
    _pc!.onIceGatheringState = _onIceGatheringState;
    _pc!.onIceConnectionState = _onIceConnectionState;
    _pc!.onConnectionState = _onPeerConnectionState;
    _pc!.onIceCandidate = _onCandidate;
  }

  Future<void> _peerConnectionDisconnect() async {
    try {
      await _pc?.close();
      await _pc?.dispose();
      _pc = null;
    } catch (e) {
      debugModePrint(e, type: runtimeType);
    }
  }

  Future<void> _getIceServers() async {
    try {
      http.Response response = await http.get(
        Uri.parse(_getIceUrl),
      );

      if (response.statusCode >= HttpStatus.ok &&
          response.statusCode < HttpStatus.multiStatus) {
        Map<String, dynamic> iceServerList = jsonDecode(response.body);
        if (iceServerList.containsKey('list')) {
          _configuration.putIfAbsent('iceServers', () => iceServerList['list']);
        }
      }
    } catch (e) {
      // http.get maybe no network connection.
    }
  }

  @override
  Future<void> updateScreenSize() async{
    Screen? screen = await getCurrentScreen();
    if(screen != null) {
    }
  }

  Future<void> _publish() async {

    final constraints = <String, dynamic>{
      'audio': true,
      'video': !WebRTC.platformIsDesktop ? true : {
        'deviceId': _deviceId,
        'mandatory': {'frameRate': 30.0},
        'width': 1920,
        'height': 1080,
      }
    };

    var stream = await navigator.mediaDevices.getDisplayMedia(constraints);
    for (MediaStreamTrack track in stream.getTracks()) {
      debugModePrint('track: ${track.kind}', type: runtimeType);
      _pc!.addTrack(track, stream);
      _send('chat-track-sources', message: [
        {
          'id': track.id,
          'source': 'screen-cast',
        }
      ]);
      _send('chat-stream-info', message: {
        'id': stream.id,
        'tracks': [track.id],
        'source': {'audio':'screen-cast', 'video':'screen-cast'}
      });
    }

    final offerConstraints = <String, dynamic>{
      'mandatory': {
        'OfferToReceiveAudio': false,
        'OfferToReceiveVideo': false,
      },
      'optional': [],
    };

    final offer = await _pc!.createOffer(offerConstraints);

    offer.sdp = SdpUtil.removeCodec(offer.sdp!, "AV1");
    RTCSessionDescription fixedOffer = SdpUtil.fixSdp(offer);

    try {
      await _pc!.setLocalDescription(fixedOffer);

      _send('chat-signal', message: {'type': fixedOffer.type, 'sdp': fixedOffer.sdp});
    } catch (e) {
      debugModePrint(e, type: runtimeType);
      hangUp();
    }

  }

  void _send(type, {message}) {
    var data = {
      'data': message != null
          ? jsonEncode({'type': type, 'data': message})
          : jsonEncode({'type': type}),
      'to': _displayCode
    };

    _socket?.emit('owt-message', data);
  }

  Future<void> _handleSignal(msg) async {
    final type = msg['type'];

    if (type == 'offer') {
      // handle offer from the peer
      final offer = RTCSessionDescription(msg['sdp'], type);
      _pc!.setRemoteDescription(offer);

      // create answer
      final answer = await _pc!.createAnswer();
      RTCSessionDescription fixedAnswer = SdpUtil.fixSdp(answer);
      await _pc!.setLocalDescription(fixedAnswer);
      // send answer to the peer
      _send('chat-signal', message: {'type': fixedAnswer.type, 'sdp': fixedAnswer.sdp});
    } else if (type == 'answer') {
      // handle answer from the peer
      final answer = RTCSessionDescription(msg['sdp'], type);
      _pc!.setRemoteDescription(answer);
    } else if (type == 'candidates') {
      final candidate = RTCIceCandidate(
          msg['candidate'], msg['sdpMid'], msg['sdpMLineIndex']);
      // add candidates from the peer
      _pc!.addCandidate(candidate);
    }
  }

  void _onAddTrack(MediaStream stream, MediaStreamTrack track) {
    debugModePrint('onAddTrack: ${track.kind}', type: runtimeType);
  }

  void _onSignalingState(RTCSignalingState state) {
    debugModePrint(state, type: runtimeType);
  }

  void _onIceGatheringState(RTCIceGatheringState state) {
    debugModePrint(state, type: runtimeType);
  }

  void _onIceConnectionState(RTCIceConnectionState state) {
    debugModePrint(state, type: runtimeType);
  }

  void _onPeerConnectionState(RTCPeerConnectionState state) async{
    debugModePrint(state, type: runtimeType);
    if(state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
      var senders = await _pc!.getSenders();
      var sender = senders.firstWhereOrNull((sender) => sender.track?.kind == 'video');
      var params = sender!.parameters;
      params.degradationPreference = RTCDegradationPreference.DISABLED;
      await sender.setParameters(params);
    }
  }

  void _onCandidate(RTCIceCandidate candidate) {
    debugModePrint('onCandidate: ${candidate.candidate}', type: runtimeType);

    // send candidates to the peer
    _send('chat-signal', message: {
      'type': 'candidates',
      'candidate': candidate.candidate,
      'sdpMid': candidate.sdpMid,
      'sdpMLineIndex': candidate.sdpMLineIndex,
    });
  }

  Future<dynamic> getUserAgent() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String? version, type;
    if (WebRTC.platformIsMacOS) {
      final macOsInfo = await deviceInfo.macOsInfo;
      version = '${macOsInfo.majorVersion}.${macOsInfo.minorVersion}.${macOsInfo.patchVersion}';
      type = 'Mac OS';
    } else if (WebRTC.platformIsWindows) {
      final windowsInfo = await deviceInfo.windowsInfo;
      version = '${windowsInfo.productName} (Build ${windowsInfo.buildNumber})';
      type = 'Windows';
    } else {
      // other platform
    }
    return {
      'sdk': {'version': version, 'type': type},
      'capabilities': {
        'continualIceGathering': true,
        'unifiedPlan': true,
        'streamRemovable': true
      }
    };
  }
}