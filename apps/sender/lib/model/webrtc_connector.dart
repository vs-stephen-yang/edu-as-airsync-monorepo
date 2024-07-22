import 'dart:async';
import 'dart:io' show Platform;

import 'package:collection/collection.dart';
import 'package:display_cast_flutter/features/protoc/event.pb.dart';
import 'package:display_cast_flutter/features/protoc/internal.pb.dart';
import 'package:display_cast_flutter/model/message.dart';
import 'package:display_cast_flutter/model/profile.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:display_cast_flutter/utilities/channel_util.dart';
import 'package:display_cast_flutter/utilities/log.dart';
import 'package:display_cast_flutter/utilities/sdp_utility.dart';
import 'package:display_cast_flutter/utilities/webrtc_util.dart';
import 'package:display_channel/display_channel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_input_injection/flutter_input_injection.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:ion_sdk_flutter/src/utils.dart' as sdp_format_utils;
import 'package:window_size/window_size.dart';

class WebRTCConnector {
  WebRTCConnector({
    required this.preset,
    required this.systemAudio,
    required this.sendSignalMessage,
    required this.onConnectionState,
  });

  final List<StreamSubscription> subscriptions = [];

  void Function(PresentSignalMessage message) sendSignalMessage;
  void Function(RTCPeerConnectionState state) onConnectionState;

  dynamic _deviceId;
  RTCPeerConnection? _pc;
  RTCDataChannel? _dc;
  MediaStream? _localStream;
  List<RTCIceCandidate> remoteCandidates = [];

  bool get isFirstConnected {
    return _isRtcFirstConnected;
  }
  bool _isRtcFirstConnected = false;

  // change present quality
  bool _streamPublished = false;
  Map<String, dynamic>? _pendingChangePresentQuality;

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

  Preset preset;
  bool touchBack = false;
  bool systemAudio = false;
  final List<String> _codecPreferences = ['h264', 'vp8', 'vp9'];
  bool _isScreenType = false;

  int get trackHeight => _trackHeight;
  final _flutterInputInjectionPlugin = FlutterInputInjection();
  Future<void> Function()? onStreamInterrupted;

  Timer? _statsTimer;
  final _statsTimerInterval = const Duration(seconds: 1);
  int? _outboundVideoWidth;
  int? _outboundVideoHeight;
  int _outboundVideoCount = 0;

  ValueNotifier<ChannelReconnectState> reconnectStateNotifier =
      ValueNotifier<ChannelReconnectState>(ChannelReconnectState.idle);

  set reconnectState(ChannelReconnectState state) {
    reconnectStateNotifier.value = state;
  }

  ChannelReconnectState get reconnectState => reconnectStateNotifier.value;

  Future<bool> makeCall(
      {required dynamic deviceId,
      required bool isScreenType,
      required List<RtcIceServer>? iceServerList}) async {
    _deviceId = deviceId;
    _isScreenType = isScreenType;
    return await _peerConnectionConnect(iceServerList);
  }

  Future<void> hangUp() async {
    print('zz hangUp s');
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

        for (var element in subscriptions) {
          element.cancel();
        }
      }
    } catch (e, stackTrace) {
      log.severe('_disposeStream', e, stackTrace);
    }
    _streamPublished = false;
  }

  void streamStop() {
    if (kIsWeb) return;
    _pc?.getLocalStreams().forEach((element) {
      element?.getTracks().first.enabled = false;
      element?.getTracks().first.stop();
    });
    print('zz streamStop end');
  }

  Future changePresentQuality(Map<String, dynamic> json) async {
    if (!_streamPublished) {
      _pendingChangePresentQuality = json;
      return;
    }

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
        (Platform.isAndroid || _isScreenType) &&
        touchBack &&
        _localStream!.getTracks().first.enabled;
  }

  bool _isAudioCaptureAllowed() {
    if (WebRTC.platformIsWindows) {
      return _isScreenType && systemAudio;
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

    _streamPublished = await _publish();
    if (_streamPublished && _pendingChangePresentQuality != null) {
      await changePresentQuality(_pendingChangePresentQuality!);
      _pendingChangePresentQuality = null;
    }
    return _streamPublished;
  }

  Future<void> _peerConnectionDisconnect() async {
    if (reconnectState == ChannelReconnectState.reconnecting) {
      reconnectState = ChannelReconnectState.fail;
    }
    try {
      await _pc?.close();
      await _pc?.dispose();
      _pc = null;
    } catch (e, stackTrace) {
      log.warning('_peerConnectionDisconnect', e, stackTrace);
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
      log.info('succeeded to set codec preferences');
    } catch (e, stackTrace) {
      log.severe('failed to set codec preferences', e, stackTrace);
      return false;
    }
    return true;
  }

  void _modifySDPForCodecPreferences(RTCSessionDescription description) {
    var capSel = sdp_format_utils.CodecCapabilitySelector(description.sdp!);
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

    log.info(
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
      log.info('Adding track: ${track.kind}');
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
    } catch (e, stackTrace) {
      log.severe('setLocalDescription', e, stackTrace);
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
    } catch (e, stackTrace) {
      log.severe('getDisplayMedia', e, stackTrace);
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
    log.info('Data channel state: ${state.name}');
    AppAnalytics.instance.trackEvent('dc_state', properties: {
      'target': state.name,
    });
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
      log.fine(data.text);
    }
  }

  void _onAddTrack(MediaStream stream, MediaStreamTrack track) {
    log.info('onAddTrack: ${track.kind}');
  }

  void _onSignalingState(RTCSignalingState state) {
    log.info('onSignalingState: ${state.name}');
  }

  void _onIceGatheringState(RTCIceGatheringState state) {
    log.info('onIceGatheringState: ${state.name}');
  }

  void _onIceConnectionState(RTCIceConnectionState state) {
    log.info('onIceConnectionState: ${state.name}');
  }

  void _onPeerConnectionState(RTCPeerConnectionState state) async {
    log.info('Peer connection state: ${state.name}');
    AppAnalytics.instance.trackEvent('pc_state', properties: {
      'target': state.name,
    });
    onConnectionState(state);

    if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
      if (reconnectState == ChannelReconnectState.reconnecting) {
        reconnectState = ChannelReconnectState.success;
      }
      if (!_isRtcFirstConnected) {
        _isRtcFirstConnected = true;
        AppAnalytics.instance.trackEvent('cast_successfully');
      }

      bool result = await _updateEncodingParameters();
      log.info('updateEncodingParameters result: {$result}');
    } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
      reconnectState = ChannelReconnectState.reconnecting;
    } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
      if (_isRtcFirstConnected) {
        // When users lose the webrtc connection while casting
        AppAnalytics.instance.trackEvent('cast_fail');
      } else {
        // When users fail to cast their screen on the first attempt
        AppAnalytics.instance.trackEvent('cast_error');
      }

      if (reconnectState == ChannelReconnectState.reconnecting) {
        reconnectState = ChannelReconnectState.fail;
      }
      await hangUp();
      await onStreamInterrupted?.call();
    }
  }

  void _onIceCandidate(RTCIceCandidate candidate) {
    log.info('onIceCandidate: ${candidate.candidate}');
    var message = PresentSignalMessage(null, SignalMessageType.candidate);
    message.candidate = candidate.candidate;
    message.sdpMid = candidate.sdpMid;
    message.sdpMLineIndex = candidate.sdpMLineIndex;
    sendSignalMessage(message);
  }

  Future<bool> _updateEncodingParameters() async {
    if (_pc == null) {
      return false;
    }
    var senders = await _pc!.getSenders();
    var sender = senders.firstWhereOrNull((sender) => sender.track?.kind == 'video');
    if (sender == null) {
      return false;
    }
    var params = sender.parameters;
    params.degradationPreference = RTCDegradationPreference.DISABLED;
    if (params.encodings != null) {
      for (var encoding in params.encodings!) {
        encoding.maxBitrate = preset.parameters.maxBitrateKbps * 1000;
        encoding.minBitrate = preset.parameters.minBitrateKbps * 1000;
      }
    }
    return await sender.setParameters(params);
  }

  Future<bool> updateEncodingPreset(Preset preset) async {
    this.preset = preset;
    bool result = await _updateEncodingParameters();
    log.info('updateEncodingParameters result: {$result}');
    return result;
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
      log.info('The number of outbound videos has changed to ${reports.length}');
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

      log.info('Outbound video size has changed to ${width}x$height');
    }
  }
}
