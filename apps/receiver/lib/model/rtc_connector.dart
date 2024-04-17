import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_vs/device_info_vs.dart';
import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/screens/debug_switch.dart';
import 'package:display_flutter/screens/split_screen.dart';
import 'package:display_flutter/utility/channel_util.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:display_flutter/utility/print_in_debug.dart';
import 'package:display_flutter/widgets/stream_function.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:uuid/uuid.dart';

import 'connect_timer.dart';

enum PresentationState {
  stopStreaming,
  occupied,
  waitForStream,
  streaming,
  pauseStreaming,
  resumeStreaming,
}

class RTCConnector {
  String mUid = const Uuid().v4();
  final Channel _channel;
  final ChannelMode _mode;
  Timer? _connectionTimeoutTimer;
  StreamController<int> connectionTimeTimeout = StreamController<int>();

  PresentationState presentationState = PresentationState.stopStreaming;
  String? sessionId;
  String? clientId;
  String? senderName;
  String? senderVersion;
  String? senderPlatform;
  bool isAudioEnabled = false;

  String get senderNameWithEllipsis {
    String result = senderName ?? '';
    if (result.length > 10) {
      result = '${result.substring(0, 10)}..';
    }
    return result;
  }

  static final _log = getDefaultLogger();
  String? iceServersApiUrl, host;
  final Map<String, dynamic> _configuration = {
    'sdpSemantics': 'unified-plan',
  };
  List<RtcIceServer>? _iceServers;

  // the following device should not enable webrtc prerendererSmoothing flag
  final List<String> _prerendererSmoothingExcludedDevices = [
    'IFP50_2',
    'IFP52_K',
    'IFP50_3',
    'IFP50_3_9850',
    'IFP70',
    'IFP52_1C',
  ];

  RTCPeerConnection? _pc;

  RTCPeerConnection? get pc => _pc;
  RTCDataChannel? _dc;
  RTCVideoRenderer? _remoteRenderer = RTCVideoRenderer();

  // implement in webrtc_view
  RTCVideoRenderer? get remoteRenderer => _remoteRenderer;

  Function()? onConnect;
  Function(MediaStream? stream)? onAddRemoteStream;
  Function(MediaStream stream)? onRemoveRemoteStream;
  Function()? onRefresh;
  Function({bool? showMode})? onShowMode;
  Future<void> Function()? onChannelDisconnect;

  RTCConnector(this._channel, this._mode);

  Future<void> init(JoinDisplayMessage message, isModeratorMode,
      {String? iceServersApiUrl, String? host}) async {
    _printPeerConnectionLog('init', null);
    this.iceServersApiUrl = iceServersApiUrl;
    this.host = host;
    _channel.onStateChange = (state) => _onChannelState(state);

    _onJoinDisplay(message, isModeratorMode);
  }

  Future<void> _onChannelState(ChannelState state) async {
    _log.info('[$clientId] Channel has changed state to $state');
    switch (state) {
      case ChannelState.initialized:
        break;
      case ChannelState.connecting:
        break;
      case ChannelState.connected:
        break;
      case ChannelState.closed:
        await disconnectPeerConnection();
        await disconnectChannel();
        break;
    }
  }

  Future<void> _peerConnectionConnect() async {
    if (_pc != null) return;

    String? deviceType = await DeviceInfoVs.deviceType;

    if (!_configuration.containsKey('iceServers')) {
      if (_mode == ChannelMode.tunnel) {
        final value = await _getIceServers(iceServersApiUrl);
        if (value != null) {
          _iceServers = parseIceServersFromApi(value);

          _configuration.putIfAbsent('iceServers', () => value);
        }
      } else {
        _configuration.putIfAbsent(
            'iceServers',
            () => [
                  {'url': 'stun:$host'}
                ]);
      }
    }
    if (_prerendererSmoothingExcludedDevices.contains(deviceType)) {
      _configuration['enablePrerendererSmoothing'] = false;
    }
    _pc = await createPeerConnection(_configuration);

    _pc!.onSignalingState = _onSignalingState;
    _pc!.onIceGatheringState = _onIceGatheringState;
    _pc!.onIceConnectionState = _onIceConnectionState;
    _pc!.onConnectionState = _onPeerConnectionState;
    _pc!.onIceCandidate = _onIceCandidate;
    _pc!.onRenegotiationNeeded = _onRenegotiationNeeded;
    _pc!.onAddStream = _onAddStream;
    _pc!.onTrack = _onTrack;
    _pc!.onAddTrack = _onAddTrack; // iOS, macOS did not use this event.
    _pc!.onRemoveTrack = _onRemoveTrack;
    _pc!.onDataChannel = _onDataChannel;
  }

  void startConnectionTimer(TimeOutCallback onFinish) {
    if (_connectionTimeoutTimer != null) stopConnectionTimeoutTimer();

    var count = 30;
    _connectionTimeoutTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
          if (timer.tick < 30) {
            // onTick
            count = 30 - timer.tick;
            connectionTimeTimeout.add(count);
          } else if (timer.tick == 30) {
            // onFinish
            timer.cancel();
            connectionTimeTimeout.add(0);
            log('ConnectionTimeout onFinish');
            onFinish();
          }
        });
  }

  void stopConnectionTimeoutTimer() {
    _connectionTimeoutTimer?.cancel();
    connectionTimeTimeout.add(0);
  }

  void _onJoinDisplay(JoinDisplayMessage msg, bool isModeratorMode) {
    clientId = msg.clientId;
    senderName = msg.name;
    senderVersion = msg.version;
    senderPlatform = msg.platform;
    if (isModeratorMode) {
      onRefresh?.call();
    }
  }

  Future<void> onStartPresent(
      StartPresentMessage msg, bool isModeratorMode) async {
    // Timer
    startConnectionTimer(() async {
      if (!isModeratorMode) {
        sendRejectPresent(400, 'timeout');
        await disconnectPeerConnection(sendAnalytics: true);
        await disconnectChannel();
      } else {
        sendStopPresent();
      }
    });

    await _remoteRenderer?.initialize();
    await _peerConnectionConnect();

    final message = PresentAcceptedMessage(sessionId = msg.sessionId);
    if (_iceServers != null) {
      message.iceServers.addAll(_iceServers!);
    }

    _channel.send(message);

    presentationState = PresentationState.waitForStream;
    onConnect?.call();
  }

  void onPresentAccepted() {
    AppAnalytics().trackEventPresentReadySent(clientId!, sessionId!);
  }

  void onPresentRejected(PresentRejectedMessage msg) {
    if (msg.reason?.text == 'timeout') {
      AppAnalytics().trackEventPresentRejectTimeOutSent(clientId!, sessionId!);
    } else if (msg.reason?.text == 'blocked') {
      AppAnalytics().trackEventPresentRejectBlockedSent(clientId!, sessionId!);
    }
  }

  Future<void> onChangeQuality(ChangePresentQuality msg) async {
    //TODO:
  }

  Future<void> onPausePresent() async {
    AppAnalytics().trackEventPresentPauseReceived(clientId!, sessionId!);
    presentationState = PresentationState.pauseStreaming;
    controlAudio(false, setIsAudioEnabled: false);
    onRefresh?.call();
  }

  Future<void> onResumePresent() async {
    AppAnalytics().trackEventPresentResumeReceived(clientId!, sessionId!);
    presentationState = PresentationState.resumeStreaming;
    controlAudio(isAudioEnabled & true, setIsAudioEnabled: false);
    onRefresh?.call();
  }

  Future<void> onStopPresent(
      StopPresentMessage msg, bool isModeratorMode) async {
    AppAnalytics().trackEventPresentStopReceived(clientId!, sessionId!);

    if (isModeratorMode) {
      StreamFunction.streamFunctionState.value = stateMenuOff;
      while (navService.canPop()) {
        navService.goBack();
      }
      await disconnectPeerConnection(sendAnalytics: false);
      HybridConnectionList().updateSplitScreen();
      HybridConnectionList().handleQualityUpdate();
      sessionId = null;
      onShowMode?.call();
      return;
    } else if (SplitScreen.mapSplitScreen.value[keySplitScreenCount] > 0) {
      StreamFunction.streamFunctionState.value = stateMenuOff;
      while (navService.canPop()) {
        navService.goBack();
      }
    }
    // disconnect the channel
    await disconnectPeerConnection(sendAnalytics: true);
    // clear renderer and close connection
    await disconnectChannel();
    // stop timer
    ConnectionTimer.getInstance().stopRemainingTimeTimer();
  }

  Future<void> onPresentSignal(PresentSignalMessage msg) async {
    switch (msg.signalType) {
      case SignalMessageType.offer:
        // handle offer from the peer
        final offer = RTCSessionDescription(msg.sdp, 'offer');
        await pc!.setRemoteDescription(offer);
        // create answer
        final answer = await pc!.createAnswer();
        RTCSessionDescription fixedAnswer = _fixSdp(answer);
        await pc!.setLocalDescription(fixedAnswer);
        // send answer to the peer
        final message =
            PresentSignalMessage(msg.sessionId, SignalMessageType.answer);
        message.sdp = fixedAnswer.sdp;
        message.sdpMLineIndex = 0;
        _channel.send(message);
        break;
      case SignalMessageType.candidate:
        // add candidates from the peer
        final candidate =
            RTCIceCandidate(msg.candidate, msg.sdpMid, msg.sdpMLineIndex);
        await pc!.addCandidate(candidate);
        break;
      default:
        break;
    }
  }

  Future<void> onChannelClose(ChannelClosedMessage msg) async {}

  void sendChangeQuality(bool isFullHeight, bool isFullFrameRate) async {
    var message = ChangePresentQuality(sessionId);
    message.constraints = PresentQualityConstraints(
        frameRate: isFullFrameRate ? 30 : 0, height: isFullHeight ? 1080 : 540);
    // message.constraints?.frameRate = isFullFrameRate ? 30 : 0;
    // message.constraints?.height = isFullHeight ? 1080 : 540;
    _channel.send(message);
  }

  void sendAllowPresent() {
    var message = AllowPresentMessage();
    message.sessionId = sessionId = const Uuid().v4();
    _channel.send(message);
  }

  void sendRejectPresent(int errorCode, String reason) {
    var message = PresentRejectedMessage();
    message.sessionId = sessionId;
    message.reason = Reason(errorCode, text: reason);
    _channel.send(message);
  }

  void sendStopPresent() {
    var message = StopPresentMessage();
    message.sessionId = sessionId;
    _channel.send(message);
  }

  Future<void> disconnectPeerConnection({bool sendAnalytics = false}) async {
    _printPeerConnectionLog('disconnectPeerConnection', sendAnalytics);
    if (sendAnalytics) {
      AppAnalytics().trackEventPresentStopped(sessionId ?? '', clientId!);
    }

    // clear renderer
    if (_remoteRenderer != null) {
      if (_remoteRenderer?.textureId != null && _remoteRenderer!.renderVideo) {
        _remoteRenderer?.srcObject = null;
      }
      try {
        await _remoteRenderer?.dispose();
      } catch (e) {
        _log.warning('[$clientId] Error on dispose remoteRenderer: $e');
      }
      _remoteRenderer = RTCVideoRenderer();
    }
    _log.info('[$clientId] Close PeerConnection');
    if (_pc != null) {
      await _pc?.close();
      await _pc?.dispose();
      _pc = null;
    }

    // change state
    presentationState = PresentationState.stopStreaming;
    onRefresh?.call();
  }

  Future<void> disconnectChannel() async {
    stopConnectionTimeoutTimer();
    await onChannelDisconnect?.call();
  }

  Future<void> close(ChannelCloseCode code, {String? reason}) async {
    _log.info('[$clientId] Close channel $reason');
    _channel.close(ChannelCloseReason(code, text: reason));
    _resetSetting();
  }

  void controlAudio(bool isEnable, {required bool setIsAudioEnabled}) {
    if (_remoteRenderer?.srcObject != null) {
      if (_remoteRenderer!.srcObject!.getAudioTracks().isNotEmpty) {
        _remoteRenderer?.srcObject!.getAudioTracks().first.enabled = isEnable;
        if (setIsAudioEnabled) {
          isAudioEnabled = isEnable;
        }
      }
    }
  }

  bool getAudioEnabled() {
    return isAudioEnabled;
  }

  //region PeerConnection interface
  void _onSignalingState(RTCSignalingState state) {
    _printPeerConnectionLog('_onSignalingState', state);
  }

  void _onIceGatheringState(RTCIceGatheringState state) {
    _printPeerConnectionLog('_onIceGatheringState', state);
  }

  void _onIceConnectionState(RTCIceConnectionState state) {
    _printPeerConnectionLog('_onIceConnectionState', state);
  }

  Future<void> _onPeerConnectionState(RTCPeerConnectionState state) async {
    _printPeerConnectionLog('_onPeerConnectionState', state);
    if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
      ConnectionTimer.getInstance().stopRemainingTimeTimer();
      await disconnectPeerConnection();
      await disconnectChannel();
    }
  }

  Future<void> _onIceCandidate(RTCIceCandidate candidate) async {
    _printPeerConnectionLog('_onIceCandidate', candidate.candidate.toString());

    // send candidates to the peer
    // This delay is needed to allow enough time to try an ICE candidate
    // before skipping to the next one. 1 second is just an heuristic value
    // and should be thoroughly tested in your own environment.

    await Future.delayed(const Duration(milliseconds: 1000), () {
      var message =
          PresentSignalMessage(sessionId, SignalMessageType.candidate);
      message.candidate = candidate.candidate;
      message.sdpMid = candidate.sdpMid;
      message.sdpMLineIndex = candidate.sdpMLineIndex;
      _channel.send(message);
    });
  }

  void _onRenegotiationNeeded() {
    _printPeerConnectionLog('_onRenegotiationNeeded', null);
  }

  void _onAddStream(MediaStream stream) {
    _printPeerConnectionLog('_onAddStream', stream.getTracks().first.id);
    stopConnectionTimeoutTimer();
    presentationState = PresentationState.streaming;
    controlAudio(true, setIsAudioEnabled: true);
    onAddRemoteStream?.call(_remoteRenderer?.srcObject);
    AppAnalytics().trackEventPresentStarted(sessionId!, clientId!);
  }

  void _onTrack(RTCTrackEvent event) async {
    _printPeerConnectionLog('_onTrack', event.track);
    if (event.track.kind == 'video') {
      _remoteRenderer?.srcObject = event.streams[0];
    }
  }

  /// iOS, macOS did not use this event.
  void _onAddTrack(MediaStream stream, MediaStreamTrack track) {
    _printPeerConnectionLog('_onAddTrack', track);
  }

  void _onRemoveTrack(MediaStream stream, MediaStreamTrack track) {
    _printPeerConnectionLog('_onRemoveTrack', track);
    if (_remoteRenderer?.srcObject?.id == stream.id) {
      _remoteRenderer?.srcObject = null;
    }
    // onRemoveRemoteStream?.call(stream);
  }

  void _onDataChannel(RTCDataChannel channel) {
    _printPeerConnectionLog('_onDataChannel', channel.label);
    _dc = channel;
  }

  void sendRTCData(Uint8List data) {
    if (_dc != null && _dc!.state == RTCDataChannelState.RTCDataChannelOpen) {
      _dc!.send(RTCDataChannelMessage.fromBinary(data));
    }
  }

  //endregion

  Future<List?> _getIceServers(String? iceServersApiUrl) async {
    try {
      http.Response response = await http.get(
        Uri.parse(iceServersApiUrl!),
      );

      if (response.statusCode >= HttpStatus.ok &&
          response.statusCode < HttpStatus.multiStatus) {
        Map<String, dynamic> iceServerList = jsonDecode(response.body);
        if (iceServerList.containsKey('list')) {
          List list = iceServerList['list'];
          return list;
        }
      }
    } catch (e) {
      // http.get maybe no network connection.
    }
    return null;
  }

  RTCSessionDescription _fixSdp(RTCSessionDescription s) {
    var sdp = s.sdp;
    s.sdp =
        sdp!.replaceAll('profile-level-id=640c1f', 'profile-level-id=42e032');
    return s;
  }

  void _resetSetting() {
    sessionId = null;
    clientId = null;
    senderName = null;
    senderVersion = '';
    senderPlatform = '';
  }

  void _printPeerConnectionLog(String? event, dynamic args) {
    if (kDebugMode) {
      printInDebug('PeerConnection $event ${args.toString()}', type: runtimeType);
      const DebugSwitch().write('PeerConnection $event ${args.toString()}');
    }
  }
}
