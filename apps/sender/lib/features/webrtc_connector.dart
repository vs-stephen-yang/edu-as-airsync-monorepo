import 'dart:async';
import 'dart:io' show Platform;

import 'package:collection/collection.dart';
import 'package:display_cast_flutter/features/protoc/event.pb.dart';
import 'package:display_cast_flutter/features/protoc/internal.pb.dart';
import 'package:display_cast_flutter/model/message.dart';
import 'package:display_cast_flutter/utilities/debug_mode_print.dart';
import 'package:display_cast_flutter/utilities/sdp_utility.dart';
import 'package:display_cast_flutter/utilities/webrtc_util.dart';
import 'package:display_cast_flutter/widgets/toast.dart';
import 'package:display_channel/display_channel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_input_injection/flutter_input_injection.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:window_size/window_size.dart';
import 'package:ion_sdk_flutter/src/utils.dart' as sdpFormatUtils;

class WebRTCConnector {
  WebRTCConnector(
      {this.touchBack = false,
      bool systemAudio = false,
      required this.sendSignalMessage}) {
    _systemAudio = systemAudio;
  }

  final List<StreamSubscription> _subscriptions = [];

  void Function(PresentSignalMessage message) sendSignalMessage;


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
  static const double _defaultFrameRate = 30.0;
  double _trackFrameRate = _defaultFrameRate;

  // disable webrtc audio processing
  // Note: the audio constraints in webrtc-flutter only works on web platform
  static const _audioConstraints = {
    'autoGainControl': false,
    'echoCancellation': false,
    'gooAutoGainControl': false,
    'noiseSuppression': false
  };

  bool touchBack = false;
  bool isMainSource = false;
  final int _defaultMaxBitrateBps = 5000000;
  final int _defaultMinBitrateBps = 0;
  final List<String> _codecPreferences = ['h264', 'vp8', 'vp9'];
  final String _macMainScreenOrder = '1';
  final String _windowsMainScreenOrder = '0';
  bool _isSourceTypeScreen = false;
  bool _systemAudio = false;

  int get trackHeight => _trackHeight;
  final _flutterInputInjectionPlugin = FlutterInputInjection();
  Future<void> Function()? onStreamInterrupted;

  Timer? _statsTimer;
  final _statsTimerInterval = const Duration(seconds: 1);
  int? _outboundVideoWidth;
  int? _outboundVideoHeight;
  int _outboundVideoCount = 0;

  Future<bool> makeCall(
      dynamic source, List<RtcIceServer>? iceServerList) async {
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
        DesktopCapturerSource s = source;
        _subscriptions.add(s.onCaptureError.stream.listen((event) async {
          await hangUp();
          await onStreamInterrupted?.call();
        }));
        isMainSource =
            _isSourceTypeScreen ? source.id == _macMainScreenOrder : false;
      } else if (Platform.isWindows) {
        isMainSource =
            _isSourceTypeScreen ? source.id == _windowsMainScreenOrder : false;
      }
    }

    _deviceId = deviceId;
    return await _peerConnectionConnect(iceServerList);
  }

  Future<void> hangUp() async {
    stopStatsTimer();

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

        for (var element in _subscriptions) {
          element.cancel();
        }
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

    if (msg.height > _maxTrackHeight) {
      // make sure the width/height is not greater than the max width
      _trackWidth = _maxTrackWidth;
      _trackHeight = _maxTrackHeight;
    } else {
      _trackWidth = _maxTrackWidth ~/ (_maxTrackHeight / msg.height);
      _trackHeight = msg.height;
    }
    _trackFrameRate = msg.frameRate.toDouble();

    if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
      final constraints = <String, dynamic>{
        'frameRate': _trackFrameRate,
        'width': _trackWidth,
        'height': _trackHeight,
      };

      final videoTrack = _localStream?.getVideoTracks().first;
      await videoTrack?.applyConstraints(constraints);
    } else {
      _localStream = await getDisplayMedia();

      for (MediaStreamTrack track in _localStream!.getTracks()) {
        _pc?.getSenders().then((value) async {
          await value.first.replaceTrack(track);
        });
      }
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

  Future<bool> _peerConnectionConnect(List<RtcIceServer>? iceServers) async {
    final configuration = buildWebRtcConfiguration(iceServers);

    _pc = await createPeerConnection(configuration);

    _pc!.onAddTrack = _onAddTrack;
    _pc!.onSignalingState = _onSignalingState;
    _pc!.onIceGatheringState = _onIceGatheringState;
    _pc!.onIceConnectionState = _onIceConnectionState;
    _pc!.onConnectionState = _onPeerConnectionState;
    _pc!.onIceCandidate = _onIceCandidate;

    return await _publish();
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

  Future<bool> _setCodecPreferences() async {
    try {
      final List<String> desiredOrder = _codecPreferences.map((codec) {
        return 'video/${codec.toUpperCase()}';
      }).toList();

      RTCRtpCapabilities capabilities = await getRtpSenderCapabilities("video");
      final modifiedCapabilities = capabilities.codecs!
          .where((codec) => desiredOrder.contains(codec.mimeType))
          .toList()
        ..sort((a, b) => desiredOrder
            .indexOf(a.mimeType)
            .compareTo(desiredOrder.indexOf(b.mimeType)));

      List<RTCRtpTransceiver> transceivers = await _pc!.transceivers;
      for (var transceiver in transceivers) {
        if (transceiver.sender.track!.kind == 'video') {
          await transceiver.setCodecPreferences(modifiedCapabilities);
        }
      }
      debugModePrint('succeeded to set codec preferences');
    } catch (e) {
      debugModePrint('failed to set codec preferences');
      return false;
    }
    return true;
  }

  void _modifySDPForCodecPreferences(RTCSessionDescription description) {
    var capSel = sdpFormatUtils.CodecCapabilitySelector(description.sdp!);
    var acaps = capSel.getCapabilities('audio');
    if (acaps != null) {
      acaps.codecs = acaps.codecs
          .where((e) => (e['codec'] as String).toLowerCase() == 'opus')
          .toList();
      acaps.setCodecPreferences('audio', acaps.codecs);
      capSel.setCapabilities(acaps);
    }

    var vcaps = capSel.getCapabilities('video');
    if (vcaps != null) {
      vcaps.codecs = vcaps.codecs
          .where((e) =>
              (e['codec'] as String).toLowerCase() == _codecPreferences[0])
          .toList();
      vcaps.setCodecPreferences('video', vcaps.codecs);
      capSel.setCapabilities(vcaps);
    }
    description.sdp = capSel.sdp();

    debugModePrint(
        'modifySDPForCodecPreferences vcodec:${_codecPreferences[0]}');
  }

  Future<bool> _publish() async {
    _dc = await _pc?.createDataChannel('pc-dc', RTCDataChannelInit()..id = 1);
    _setDataChannelListeners(_dc!);

    _trackFrameRate = _defaultFrameRate;
    _trackWidth = _maxTrackWidth;
    _trackHeight = _maxTrackHeight;

    _localStream = await getDisplayMedia();
    if (_localStream == null || _pc == null) {
      // GetDisplayMedia method will using different UI UX (control by system)
      // to prompt the user to select screen in Web, Android, iOS.
      // Therefore we did not implement timeout mechanism in those sender,
      // it may disconnect (_pc will be null) due to receiver's timeout.
      // Web: popup a system dialog
      // Android: MediaProjection
      // iOS: Broadcast extension
        await hangUp();
        // return false to run makeCall's failure process.
        return false;
    }
    _localStream?.getTracks().forEach((element) {
      element.onEnded = () async {
        await hangUp();
        await onStreamInterrupted?.call();
      };
    });
    for (MediaStreamTrack track in _localStream!.getTracks()) {
      debugModePrint('track: ${track.kind}', type: runtimeType);
      await _pc!.addTrack(track, _localStream!);
    }

    final bool setCodecPreferencesResult = await _setCodecPreferences();

    final offerConstraints = <String, dynamic>{
      'mandatory': {
        'OfferToReceiveAudio': false,
        'OfferToReceiveVideo': false,
      },
      'optional': [],
    };

    final offer = await _pc!.createOffer(offerConstraints);
    RTCSessionDescription fixedOffer = SdpUtil.fixSdp(offer);

    if (!setCodecPreferencesResult) {
      // Due to incomplete implementation of `setCodecPreferences`
      // in flutter-webrtc, there are issues on certain devices. As a workaround,
      // we have opted to modify the SDP. However, this workaround currently only
      // supports selecting a single codec."
      _modifySDPForCodecPreferences(fixedOffer);
    }

    try {
      await _pc!.setLocalDescription(fixedOffer);

      var message = PresentSignalMessage(null, SignalMessageType.offer);
      message.sdp = fixedOffer.sdp;
      sendSignalMessage(message);

      startStatsTimer();
      return true;
    } catch (e) {
      debugModePrint(e, type: runtimeType);
      return false;
    }
  }

  Future<MediaStream?> getDisplayMedia() async {
    try {
      final constraints = <String, dynamic>{
        'audio': _isAudioCaptureAllowed() ? _audioConstraints : false,
        'video': !WebRTC.platformIsDesktop && !WebRTC.platformIsMobile
            ? true
            : {
          'deviceId': _deviceId,
          'mandatory': {
            'frameRate': _trackFrameRate,
          },
          'width': _trackWidth,
          'height': _trackHeight,
        }
      };

      return await navigator.mediaDevices.getDisplayMedia(constraints);
    } catch (e) {
      return null;
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
      if (params.encodings != null) {
        for (var encoding in params.encodings!) {
          encoding.maxBitrate = _defaultMaxBitrateBps;
          encoding.minBitrate = _defaultMinBitrateBps;
        }
      }
      await sender.setParameters(params);
    } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
      Toast.makeToast('Unstable network connection.');
    }
  }

  void _onIceCandidate(RTCIceCandidate candidate) {
    debugModePrint('onCandidate: ${candidate.candidate}', type: runtimeType);
    var message = PresentSignalMessage(null, SignalMessageType.candidate);
    message.candidate = candidate.candidate;
    message.sdpMid = candidate.sdpMid;
    message.sdpMLineIndex = candidate.sdpMLineIndex;
    sendSignalMessage(message);
  }

  void stopStatsTimer() {
    _statsTimer?.cancel();
    _statsTimer = null;
  }

  void startStatsTimer() {
    _statsTimer?.cancel();

    _statsTimer = Timer.periodic(
      _statsTimerInterval,
      (timer) async {
        final reports = await _pc?.getStats(null);
        if (reports != null) {
          onStatsReports(reports);
        }
      },
    );
  }

  void onStatsReports(List<StatsReport> reports) {
    final outboundRtps = reports
        .where((StatsReport report) => report.type == 'outbound-rtp')
        .toList();

    final videoOutboundRtps = outboundRtps
        .where((StatsReport report) => report.values['kind'] == 'video')
        .toList();

    onVideoStatsReports(videoOutboundRtps);
  }

  void onVideoStatsReports(List<StatsReport> reports) {
    if (reports.length != _outboundVideoCount) {
      _outboundVideoCount = reports.length;
      print('The number of outbound videos has changed to ${reports.length}');
    }

    if (reports.isEmpty) {
      _outboundVideoWidth = null;
      _outboundVideoHeight = null;
    }

    final videoOutboundRtp = reports.first;

    final width = videoOutboundRtp.values['frameWidth'];
    final height = videoOutboundRtp.values['frameHeight'];

    if (_outboundVideoWidth != width || _outboundVideoHeight != height) {
      _outboundVideoWidth = width;
      _outboundVideoHeight = height;

      print('Outbound video size has changed to ${width}x$height');
    }
  }
}
