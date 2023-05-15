import 'dart:async';
import 'dart:convert';
import 'dart:io' show HttpStatus, Platform;

import 'package:display_cast_flutter/utilities/debug_mode_print.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as io;

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
  io.Socket? _socket;

  Timer? _statsTimer;

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

  Future<void> _publish() async {
    final constraints = <String, dynamic>{
      'audio': true,
      'video': {
        'deviceId': _deviceId,
        'mandatory': {'frameRate': 30.0}
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

    try {
      await _pc!.setLocalDescription(offer);

      _send('chat-signal', {'type': offer.type, 'sdp': offer.sdp});
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
      await _pc!.setLocalDescription(answer);
      // send answer to the peer
      _send('chat-signal', {'type': answer.type, 'sdp': answer.sdp});
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

  void _startReportStats() {
    _statsTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      var stats = await _pc?.getStats(null);
      stats?.forEach((st) {
        //debugModePrint('${st.id} ${st.type}', type: runtimeType);
        if (st.type.contains('ssrc')) {
          debugModePrint(
              '${st.values['ssrc']},Decoded,${st.values['googFrameRateDecoded']}, Received,${st.values['googFrameRateReceived']},Output,${st.values['googFrameRateOutput']},Decode,${st.values['googDecodeMs']},Delay,${st.values['googCurrentDelayMs']}',
              type: runtimeType);
        }
      });
    });
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

  void _onPeerConnectionState(RTCPeerConnectionState state) {
    debugModePrint(state, type: runtimeType);
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

    return parts[0].contains(payloadType);
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
