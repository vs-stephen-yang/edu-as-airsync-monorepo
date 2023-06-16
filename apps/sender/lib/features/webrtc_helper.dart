import 'dart:async';
import 'dart:convert';
import 'dart:io' show HttpStatus, Platform;

import 'package:display_cast_flutter/utilities/debug_mode_print.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:collection/collection.dart';

import 'protoc/internal.pb.dart';
import 'protoc/event.pb.dart';
import 'package:flutter_input_injection/flutter_input_injection.dart';
import 'package:window_size/window_size.dart';

class WebRTCHelper {
  WebRTCHelper(String getIceUrl) {
    _getIceUrl = getIceUrl;
  }

  late final String _getIceUrl;
  final Map<String, dynamic> _configuration = {
    'sdpSemantics': 'unified-plan',
  };

  String? _token;
  String? _peerId;
  dynamic _deviceId;

  RTCPeerConnection? _pc;
  RTCDataChannel? _dc;
  io.Socket? _socket;
  double _screenWidth = 1920.0;
  double _screenHeight = 1080.0;

  final _flutterInputInjectionPlugin = FlutterInputInjection();

  Future<void> makeCall(
      String signalUrl, String token, String peerId, dynamic source) async {
    _token = token;
    _peerId = peerId;
    dynamic deviceId;

    if (Platform.isAndroid) {
    } else if (Platform.isIOS) {
      deviceId = 'broadcast';
    } else {
      deviceId = {'exact': source.id};
    }

    _deviceId = deviceId;
    _signalConnect(signalUrl);
    await _peerConnectionConnect();
  }

  Future<void> hangUp() async {
    await _peerConnectionDisconnect();
    _signalDisconnect();
  }

  void _signalConnect(String signalUrl) {
    _socket = io.io(
        signalUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .enableForceNew()
            .setQuery({
              "token": _token,
            })
            .build());

    _socket!.onConnect((_) async {
      debugModePrint('connect', type: runtimeType);
      await _publish();
    });

    _socket!.on('server-authenticated', (data) {
      debugModePrint("server-authenticated: ${data['uid']}", type: runtimeType);
    });

    _socket!.on('owt-message', (data) async {
      debugModePrint(data, type: runtimeType);
      final msg = jsonDecode(data['data']);
      final type = msg['type'];

      if (type == "chat-signal") {
        await _handleSignal(msg['data']);
      }
    });

    _socket!
        .onDisconnect((_) => debugModePrint('disconnect', type: runtimeType));
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

  Future<void> updateScreenSize() async{
    Screen? screen = await getCurrentScreen();
    if(screen != null) {
      _screenWidth = screen.frame.width;
      _screenHeight = screen.frame.height;
    }
  }

  Future<void> _publish() async {
    _dc = await _pc!.createDataChannel('pc-dc', RTCDataChannelInit()..id = 1);
    _setDataChannelListeners(_dc!);

    final constraints = <String, dynamic>{
      'audio': true,
      'video': {
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
    RTCSessionDescription fixedOffer = SdpUtil._fixSdp(offer);

    try {
      await _pc!.setLocalDescription(fixedOffer);

      _send('chat-signal', {'type': fixedOffer.type, 'sdp': fixedOffer.sdp});
    } catch (e) {
      debugModePrint(e, type: runtimeType);
      hangUp(); //todo: message?
    }
  }

  void _send(type, message) {
    var data = {
      'data': jsonEncode({'type': type, 'data': message}),
      'to': _peerId
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
      RTCSessionDescription fixedAnswer = SdpUtil._fixSdp(answer);
      await _pc!.setLocalDescription(fixedAnswer);
      // send answer to the peer
      _send('chat-signal', {'type': fixedAnswer.type, 'sdp': fixedAnswer.sdp});
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

  void _setDataChannelListeners(RTCDataChannel dc) {
    dc.onDataChannelState = _onDataChannelState;
    dc.onMessage = _onMessage;
  }

  void _onDataChannelState(RTCDataChannelState state) {
    debugModePrint('onDataChannelState: $state');
  }

  void _onMessage(RTCDataChannelMessage data) async {
    if(data.isBinary) {
      EventMessage eventMessage = EventMessage.fromBuffer(data.binary);
      if(eventMessage.hasTouchEvent()) {
        int action = FlutterInputInjection.TOUCH_POINT_START;
        if(eventMessage.touchEvent.eventType == TouchEvent_TouchEventType.TOUCH_POINT_START){
          action = FlutterInputInjection.TOUCH_POINT_START;
        } else if(eventMessage.touchEvent.eventType == TouchEvent_TouchEventType.TOUCH_POINT_MOVE){
          action = FlutterInputInjection.TOUCH_POINT_MOVE;
        } else if(eventMessage.touchEvent.eventType == TouchEvent_TouchEventType.TOUCH_POINT_END){
          action = FlutterInputInjection.TOUCH_POINT_END;
        }
        int id = eventMessage.touchEvent.touchPoints[0].id;
        double remoteX = eventMessage.touchEvent.touchPoints[0].x;
        double remoteY = eventMessage.touchEvent.touchPoints[0].y;
        await updateScreenSize();
        int injectX = (remoteX * _screenWidth).toInt();
        if(injectX < 0) {
          injectX = 0;
        } else if(injectX > _screenWidth.toInt() - 1) {
          injectX = _screenWidth.toInt() - 1;
        }
        int injectY = (remoteY * _screenHeight).toInt();
        if(injectY < 0) {
          injectY = 0;
        } else if(injectY > _screenHeight.toInt() - 1) {
          injectY = _screenHeight.toInt() - 1;
        }
        _flutterInputInjectionPlugin.sendTouch(action, id, injectX, injectY);
      }
    } else {
      debugModePrint(data.text);
    }
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
    _send('chat-signal', {
      'type': 'candidates',
      'candidate': candidate.candidate,
      'sdpMid': candidate.sdpMid,
      'sdpMLineIndex': candidate.sdpMLineIndex,
    });
  }
}

class SdpUtil {
  static bool isAttributeOfPayloadType(String line, String payloadType) {
    //a=rtpmap:35 H264/90000
    final parts = line.split(' ');

    return parts[0].contains(payloadType) && (parts[0].contains('rtpmap') || parts[0].contains('rtcp') || parts[0].contains('fmtp'));
  }

  static String? removeCodec(String sdp, String encodingName) {
    final lines = sdp.split("\r\n");

    List<String> payloadTypes = findPayloadTypes(lines, encodingName);
    if (payloadTypes.isEmpty) {
      return sdp;
    }

    // remove payload types
    for (var payloadType in payloadTypes) {
      //a=rtpmap:35 H264/90000
      lines.removeWhere((line) =>
          line.startsWith('a=') && isAttributeOfPayloadType(line, payloadType));
    }

    sdp = lines.join('\r\n');

    // remove payload types from m= line
    final videoLine =
        lines.where((line) => line.startsWith("m=video")).toList()[0];

    final newVideoLine = removePayloadTypesFromM(videoLine, payloadTypes);

    sdp = sdp.replaceFirst(videoLine, newVideoLine);
    return sdp;
  }

  static RTCSessionDescription _fixSdp(RTCSessionDescription s) {
    var sdp = s.sdp;
    s.sdp =
        sdp!.replaceAll('profile-level-id=640c1f', 'profile-level-id=42e032');
    return s;
  }

  // remove payload types from m= line
  static String removePayloadTypesFromM(
      String line, List<String> payloadTypes) {
    //m=video 9 UDP/TLS/RTP/SAVPF 96 97 125 120 124 107

    for (var payloadType in payloadTypes) {
      // must remove leading space
      line = line.replaceFirst(' $payloadType', '');
    }
    return line;
  }

  // find payload type numbers that matche encodingName
  static List<String> findPayloadTypes(
    List<String> sdpLines,
    String encodingName,
  ) {
    final payloadTypes = sdpLines
        .where((line) => line.startsWith("a=rtpmap:"))
        .where((line) => line.contains(encodingName))
        .map((line) => line.split(' ')) //a=rtpmap:41, AV1/90000
        .map((parts) => parts[0]) //a=rtpmap:41
        .map(
          (part) => part.substring("a=rtpmap:".length), //41
        )
        .toList();

    // find apt (associated payload type)
    var associatedPayloadTypes = <String>[];

    for (var payloadType in payloadTypes) {
      //a=fmtp:97 apt=96
      associatedPayloadTypes += sdpLines
          .where((line) => line.startsWith("a=fmtp:"))
          .where((line) => line.contains("apt=$payloadType"))
          .map((line) => line.split(' ')) //a=fmtp:97 apt=96
          .map((parts) => parts[0]) //a=fmtp:97
          .map(
            (part) => part.substring("a=fmtp:".length), //97
          )
          .toList();
    }

    return payloadTypes + associatedPayloadTypes;
  }
}
