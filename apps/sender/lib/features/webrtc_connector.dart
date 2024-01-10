import 'dart:async';
import 'dart:convert';
import 'dart:io' show HttpStatus, Platform;

import 'package:collection/collection.dart';
import 'package:display_cast_flutter/features/protoc/event.pb.dart';
import 'package:display_cast_flutter/features/protoc/internal.pb.dart';
import 'package:display_cast_flutter/model/message.dart';
import 'package:display_cast_flutter/utilities/debug_mode_print.dart';
import 'package:display_cast_flutter/utilities/sdp_utility.dart';
import 'package:display_channel/display_channel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_input_injection/flutter_input_injection.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import 'package:window_size/window_size.dart';

class WebRTCConnector {
  WebRTCConnector(this._urlIce,
      {this.touchBack = false,
      bool systemAudio = false,
      required this.sendSignalMessage}) {
    _systemAudio = systemAudio;
  }

  final String _urlIce;
  void Function(PresentSignalMessage message) sendSignalMessage;

  final Map<String, dynamic> _configuration = {
    'sdpSemantics': 'unified-plan',
  };

  dynamic _deviceId;
  RTCPeerConnection? _pc;
  RTCDataChannel? _dc;
  MediaStream? _localStream;
  List<RTCIceCandidate> remoteCandidates = [];

  // io.Socket? _socket;
  double _screenWidth = 1920.0;
  double _screenHeight = 1080.0;
  static const int _maxTrackWidth = 1920;
  static const int _maxTrackHeight = 1080;
  int _trackWidth = _maxTrackWidth;
  int _trackHeight = _maxTrackHeight;
  bool touchBack = false;
  bool isMainSource = false;
  final String _macMainScreenOrder = '1';
  final String _windowsMainScreenOrder = '0';
  bool _isSourceTypeScreen = false;
  bool _systemAudio = false;

  int get trackHeight => _trackHeight;
  final _flutterInputInjectionPlugin = FlutterInputInjection();

  Future<void> makeCall(
      String peerId, dynamic source, List<RtcIceServer>? iceServerList) async {
    dynamic deviceId;

    if (kIsWeb) {
    } else if (Platform.isAndroid) {
      isMainSource = true;
    } else if (Platform.isIOS) {
      deviceId = 'broadcast';
      isMainSource = true;
    } else {
      deviceId = {'exact': source.id};
      _isSourceTypeScreen = (source.type == SourceType.Screen);
      if (Platform.isMacOS) {
        isMainSource =
            _isSourceTypeScreen ? source.id == _macMainScreenOrder : false;
      } else if (Platform.isWindows) {
        isMainSource =
            _isSourceTypeScreen ? source.id == _windowsMainScreenOrder : false;
      }
    }

    _deviceId = deviceId;
    await _peerConnectionConnect(iceServerList);
  }

  Future<void> hangUp() async {
    await _disposeStream();
    await _peerConnectionDisconnect();
  }

  Future<void> _disposeStream() async {
    try {
      if (_localStream != null) {
        if (kIsWeb) {
          _localStream?.getTracks().forEach((track) => track.stop());
        }
        var stream = _localStream!;
        _localStream = null;
        await stream.dispose();
      }
    } catch (e) {
      debugModePrint(e, type: runtimeType);
    }
  }

  void streamStop() {
    if (kIsWeb) return;
    _pc?.getLocalStreams().forEach((element) {
      element?.getTracks().first.enabled = false;
      element?.getTracks().first.stop();
    });
  }

  Future<void> changeStreamFrameRate(Map<String, dynamic> json) async {
    final msg = PresentChangeQualityMessage.fromJson(json);

    if (msg.height == _trackHeight) return;

    if (msg.height < _maxTrackHeight) {
      // make sure the width/height is not greater than the max width
      _trackWidth = _maxTrackWidth ~/ (_maxTrackHeight / msg.height);
      _trackHeight = msg.height;
    }
    final constraints = <String, dynamic>{
      'audio': _isAudioCaptureAllowed(),
      'video': !WebRTC.platformIsDesktop && !WebRTC.platformIsMobile
          ? true
          : {
              'deviceId': _deviceId,
              'mandatory': {
                'frameRate': msg.frameRate,
              },
              'width': _trackWidth.toString(),
              'height': _trackHeight.toString(),
            }
    };

    _localStream = await navigator.mediaDevices.getDisplayMedia(constraints);
    for (MediaStreamTrack track in _localStream!.getTracks()) {
      _pc?.getSenders().then((value) async {
        await value.first.replaceTrack(track);
      });
    }
  }

  bool _isTouchBackAllowed() {
    return !kIsWeb &&
        (Platform.isAndroid || _isSourceTypeScreen) &&
        touchBack &&
        _localStream!.getTracks().first.enabled;
  }

  bool _isAudioCaptureAllowed() {
    if (WebRTC.platformIsWindows) {
      return _isSourceTypeScreen && _systemAudio;
    }
    return true;
  }

  Future<void> _peerConnectionConnect(List<RtcIceServer>? iceServerList) async {
    if (!_configuration.containsKey('iceServers')) {
      await _getIceServers();
    }
    _pc = await createPeerConnection(_configuration);

    _pc!.onAddTrack = _onAddTrack;
    _pc!.onSignalingState = _onSignalingState;
    _pc!.onIceGatheringState = _onIceGatheringState;
    _pc!.onIceConnectionState = _onIceConnectionState;
    _pc!.onConnectionState = _onPeerConnectionState;
    _pc!.onIceCandidate = _onIceCandidate;

    await _publish();
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
        Uri.parse(_urlIce),
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

  Future<void> _updateScreenSize() async {
    if (!kIsWeb && Platform.isWindows) {
      // PlatformDispatcher did not support get windows width and height yet.
      // Using window_size for workaround.
      // https://github.com/flutter/flutter/issues/125938
      // https://github.com/flutter/flutter/issues/125939
      // todo: tracking issue status to remove this workaround.
      Screen? screen = await getCurrentScreen();
      if (screen != null) {
        _screenWidth = screen.frame.width;
        _screenHeight = screen.frame.height;
      }
    } else {
      _screenWidth = PlatformDispatcher.instance.displays.first.size.width;
      _screenHeight = PlatformDispatcher.instance.displays.first.size.height;
    }
  }

  Future<void> _publish() async {
    _dc = await _pc!.createDataChannel('pc-dc', RTCDataChannelInit()..id = 1);
    _setDataChannelListeners(_dc!);

    final constraints = <String, dynamic>{
      'audio': _isAudioCaptureAllowed(),
      'video': !WebRTC.platformIsDesktop && !WebRTC.platformIsMobile
          ? true
          : {
              'deviceId': _deviceId,
              'mandatory': {'frameRate': 30.0},
              'width': _trackWidth = _maxTrackWidth,
              'height': _trackHeight = _maxTrackHeight,
            }
    };

    _localStream = await navigator.mediaDevices.getDisplayMedia(constraints);
    for (MediaStreamTrack track in _localStream!.getTracks()) {
      debugModePrint('track: ${track.kind}', type: runtimeType);
      await _pc!.addTrack(track, _localStream!);
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

      var message = PresentSignalMessage(null, SignalMessageType.offer);
      message.sdp = fixedOffer.sdp;
      sendSignalMessage(message);
    } catch (e) {
      debugModePrint(e, type: runtimeType);
    }
  }

  /// handle signal message from Display, ex. offer, answer, candidates
  Future<void> handleSignal(PresentSignalMessage msg) async {
    final type = msg.signalType.toString(); //msg['type'];

    switch (msg.signalType) {
      case SignalMessageType.offer:
        // handle offer from the peer
        final offer = RTCSessionDescription(msg.sdp, type);
        _pc!.setRemoteDescription(offer);
        // create answer
        final answer = await _pc!.createAnswer();
        RTCSessionDescription fixedAnswer = SdpUtil.fixSdp(answer);
        await _pc!.setLocalDescription(fixedAnswer);
        break;
      case SignalMessageType.answer:
        // handle answer from the peer
        final answer = RTCSessionDescription(msg.sdp, 'answer');
        _pc!.setRemoteDescription(answer);
        break;
      case SignalMessageType.candidate:
        final candidate =
            RTCIceCandidate(msg.candidate, msg.sdpMid, msg.sdpMLineIndex);
        if (_pc != null) {
          // add candidates from the peer
          await _pc?.addCandidate(candidate);
        } else {
          remoteCandidates.add(candidate);
        }
        break;
      case null:
        break;
    }
  }

  void _setDataChannelListeners(RTCDataChannel dc) {
    dc.onDataChannelState = _onDataChannelState;
    dc.onMessage = _onMessage;
  }

  void _onDataChannelState(RTCDataChannelState state) {
    debugModePrint('onDataChannelState: $state');
  }

  void _onMessage(RTCDataChannelMessage data) async {
    if (data.isBinary) {
      // touch event data
      if (_isTouchBackAllowed()) {
        EventMessage eventMessage = EventMessage.fromBuffer(data.binary);
        if (eventMessage.hasTouchEvent()) {
          int action = FlutterInputInjection.TOUCH_POINT_START;
          if (eventMessage.touchEvent.eventType ==
              TouchEvent_TouchEventType.TOUCH_POINT_START) {
            action = FlutterInputInjection.TOUCH_POINT_START;
          } else if (eventMessage.touchEvent.eventType ==
              TouchEvent_TouchEventType.TOUCH_POINT_MOVE) {
            action = FlutterInputInjection.TOUCH_POINT_MOVE;
          } else if (eventMessage.touchEvent.eventType ==
              TouchEvent_TouchEventType.TOUCH_POINT_END) {
            action = FlutterInputInjection.TOUCH_POINT_END;
          }
          int id = eventMessage.touchEvent.touchPoints[0].id;
          double remoteX = eventMessage.touchEvent.touchPoints[0].x;
          double remoteY = eventMessage.touchEvent.touchPoints[0].y;
          await _updateScreenSize();
          int injectX = (remoteX * _screenWidth).toInt();
          if (injectX < 0) {
            injectX = 0;
          } else if (injectX > _screenWidth.toInt() - 1) {
            injectX = _screenWidth.toInt() - 1;
          }
          int injectY = (remoteY * _screenHeight).toInt();
          if (injectY < 0) {
            injectY = 0;
          } else if (injectY > _screenHeight.toInt() - 1) {
            injectY = _screenHeight.toInt() - 1;
          }
          _flutterInputInjectionPlugin.sendTouch(action, id, injectX, injectY);
        }
      }
    } else {
      // text message
      debugModePrint(data.text);
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

  void _onPeerConnectionState(RTCPeerConnectionState state) async {
    debugModePrint(state, type: runtimeType);
    if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
      var senders = await _pc!.getSenders();
      var sender =
          senders.firstWhereOrNull((sender) => sender.track?.kind == 'video');
      var params = sender!.parameters;
      params.degradationPreference = RTCDegradationPreference.DISABLED;
      await sender.setParameters(params);
    }
  }

  void _onIceCandidate(RTCIceCandidate candidate) {
    debugModePrint('onCandidate: ${candidate.candidate}', type: runtimeType);

    // send candidates to the peer
    // Map<String, dynamic> json = {
    //   'type': 'candidate',
    //   'sdp': '',
    //   'candidate': candidate.candidate,
    //   'sdpMid': candidate.sdpMid,
    //   'sdpMLineIndex': candidate.sdpMLineIndex,
    // };
    var message = PresentSignalMessage(null, SignalMessageType.candidate);
    message.candidate = candidate.candidate;
    message.sdpMid = candidate.sdpMid;
    message.sdpMLineIndex = candidate.sdpMLineIndex;
    sendSignalMessage(message);
  }
}
