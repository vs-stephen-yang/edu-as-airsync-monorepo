import 'dart:async';
import 'dart:convert';

import 'package:device_info_vs/device_info_vs.dart';
import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/model/rtc_stats.dart';
import 'package:display_flutter/model/rtc_stats_parser.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/screens/debug_switch.dart';
import 'package:display_flutter/screens/home.dart';
import 'package:display_flutter/settings/channel_config.dart';
import 'package:display_flutter/utility/bounded_list.dart';
import 'package:display_flutter/utility/channel_util.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:display_flutter/utility/webrtc_util.dart';
import 'package:display_flutter/widgets/stream_function.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:uuid/uuid.dart';

import 'connect_timer.dart';

enum PresentationState {
  stopStreaming,
  waitForStream,
  streaming,
  pauseStreaming,
  resumeStreaming,
}

class RTCConnector {
  String mUid = const Uuid().v4();
  final Channel _channel;
  Timer? _connectionTimeoutTimer;
  StreamController<int> connectionTimeTimeout = StreamController<int>();

  PresentationState presentationState = PresentationState.stopStreaming;
  String? sessionId;
  String? clientId;
  String? senderName;
  String? senderVersion;
  String? senderPlatform;
  bool isAudioEnabled = false;
  bool isModeratorShare = false;

  ValueNotifier<ReconnectState> reconnectRtcStateNotifier =
      ValueNotifier<ReconnectState>(ReconnectState.idle);

  set reconnectRtcState(ReconnectState state) {
    reconnectRtcStateNotifier.value = state;
  }

  ReconnectState get reconnectRtcState => reconnectRtcStateNotifier.value;

  ValueNotifier<ReconnectState> reconnectChannelStateNotifier =
      ValueNotifier<ReconnectState>(ReconnectState.idle);

  set reconnectChannelState(ReconnectState state) {
    reconnectChannelStateNotifier.value = state;
  }

  ReconnectState get reconnectChannelState =>
      reconnectChannelStateNotifier.value;
  bool clickButtonWhenReconnect = false;

  Timer? _statsTimer;
  final _statsTimerInterval = const Duration(seconds: 1);

  String get senderNameWithEllipsis {
    String result = senderName ?? '';
    if (result.length > 10) {
      result = '${result.substring(0, 10)}..';
    }
    return result;
  }

  // the following device should not enable webrtc prerendererSmoothing flag
  final List<String> _prerendererSmoothingExcludedDevices = [
    'IFP50_2',
    'IFP52_K',
    'IFP50_3',
    'IFP50_3_9850',
    'IFP70',
    'IFP52_1C',
  ];

  static const List<String> _mtk9950Models = [
    'IFP52_K',
    'IFP52_1C',
  ];

  RTCPeerConnection? _pc;

  RTCPeerConnection? get pc => _pc;
  RTCDataChannel? _touchbackDataChannel;
  RTCDataChannel? _controlDataChannel;

  RTCVideoRenderer? _remoteRenderer = RTCVideoRenderer();

  RtcStatsParser? _rtcStatsParser;

  // implement in webrtc_view
  RTCVideoRenderer? get remoteRenderer => _remoteRenderer;

  Function()? onConnect;
  Function(MediaStream? stream)? onAddRemoteStream;
  Function(MediaStream stream)? onRemoveRemoteStream;
  Function()? onRefresh;
  Function(String localCandidateType, String remoteCandidateType)?
      onPairCandidateType;
  Function(RtcVideoInboundStats stats)? onVideoStatsReport;
  Function({bool? showMode})? onShowMode;
  Future<void> Function({String? reason})? onChannelDisconnect;

  Timer? _channelReconnectTimer;
  bool _isRtcFirstConnected = false;

  // rtc stats
  final _videoBitrateHistory = <int?>[];

  // keep last 20 RtcVideoInboundStats
  final _videoInboundStatsHistory = BoundedList<RtcVideoInboundStats>(20);

  String? _localCandidateType;
  String? _remoteCandidateType;
  ChannelMessage? _changeQualityMessage;
  String? _deviceType;

  RTCConnector(this._channel);

  Future<void> init(
    JoinDisplayMessage message,
    isModeratorMode,
  ) async {
    _printPeerConnectionLog('init', null);
    _channel.stateStream.listen((ChannelState state) async {
      await _onChannelState(state);
    });

    _onJoinDisplay(message, isModeratorMode);
  }

  Future<void> _onChannelState(ChannelState state) async {
    log.info('[$clientId] Channel has changed state to $state');

    _trackTrace('channel_state', target: state.name);

    switch (state) {
      case ChannelState.initialized:
        break;
      case ChannelState.connecting:
        reconnectChannelState = ReconnectState.reconnecting;
        if (!_isStreaming()) {
          // If no streaming is active, interrupt if the channel remains disconnected for an extended period
          _startChannelReconnectTimer();
        }
        break;
      case ChannelState.connected:
        if (reconnectChannelState == ReconnectState.reconnecting) {
          reconnectChannelState = ReconnectState.success;
        }

        _stopChannelReconnectTimer();

        break;
      case ChannelState.closed:
        // The channel will no longer switch its state to "closed" solely because of a disconnection.
        // This means that if a disconnection occurs, the channel will continuously attempt to reconnect without changing the state to "closed".
        // A state change to "closed" will only occur if there is an explicit close request from the peer.
        // Note: the case is the sender cancel the waiting state on moderator mode

        await disconnectChannel(reason: 'Channel closed');
        break;
    }
  }

  void stopStatsTimer() {
    _statsTimer?.cancel();
    _statsTimer = null;
  }

  void startStatsTimer() {
    _rtcStatsParser = RtcStatsParser(
      _handleVideoStatsReport,
      (String localCandidateType, String remoteCandidateType) {
        onPairCandidateType?.call(localCandidateType, remoteCandidateType);

        if (_localCandidateType != localCandidateType &&
            _remoteCandidateType != remoteCandidateType) {
          _trackTrace('pc_candidates',
              target: '$localCandidateType,$remoteCandidateType');

          _localCandidateType = localCandidateType;
          _remoteCandidateType = remoteCandidateType;
        }
      },
    );

    _statsTimer?.cancel();
    _statsTimer = Timer.periodic(
      _statsTimerInterval,
      (timer) async {
        final reports = await _pc?.getStats(null);
        if (reports != null) {
          _rtcStatsParser?.onStatsReports(reports);
        }
      },
    );
  }

  // The channel failed to reconnect within the specified timeout period
  void _onChannelReconnectTimeout() async {
    log.info('The channel failed to reconnect within the timeout period');
    _channelReconnectTimer = null;

    if (reconnectChannelState == ReconnectState.reconnecting) {
      reconnectChannelState = ReconnectState.fail;
    }

    await disconnectChannel(reason: 'Channel reconnect timeout');
  }

  void _startChannelReconnectTimer() {
    log.info('Start channel reconnect timer');

    _channelReconnectTimer = Timer(
      channelReconnectTimeoutInIdle,
      _onChannelReconnectTimeout,
    );
  }

  void _stopChannelReconnectTimer() {
    if (_channelReconnectTimer != null) {
      log.info('Stop channel reconnect timer');
      _channelReconnectTimer!.cancel();
      _channelReconnectTimer = null;
    }
  }

  bool _isStreaming() {
    return _isRtcFirstConnected;
  }

  void _handleVideoStatsReport(RtcVideoInboundStats stats) {
    _videoBitrateHistory.add(stats.bytesPerSecond);

    _videoInboundStatsHistory.add(stats);

    onVideoStatsReport?.call(stats);
  }

  Future<void> _peerConnectionConnect(
    List<RtcIceServer>? iceServers,
  ) async {
    if (_pc != null) return;

    _deviceType = await DeviceInfoVs.deviceType;

    final configuration = WebRTCUtil.createPcConfiguration(iceServers);

    if (_prerendererSmoothingExcludedDevices.contains(_deviceType)) {
      configuration['enablePrerendererSmoothing'] = false;
    }
    _pc = await createPeerConnection(configuration);

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
        log.info('ConnectionTimeout onFinish');
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
    senderVersion = msg.version;
    senderPlatform = msg.platform;
    if (isModeratorMode) {
      senderName = msg.name;
      onRefresh?.call();
    }
  }

  Future<void> onStartPresent(
    StartPresentMessage msg,
    bool isModeratorMode,
    List<RtcIceServer>? iceServers,
  ) async {
    // Timer
    startConnectionTimer(() async {
      if (!isModeratorMode) {
        sendRejectPresent(PresentRejectedReasonCode.timeout.code, 'timeout');
        await disconnectPeerConnection(sendAnalytics: true);
        await disconnectChannel(reason: 'Timeout: present rejected');
      } else {
        sendStopPresent();
      }
    });

    await _remoteRenderer?.initialize();
    await _peerConnectionConnect(iceServers);

    final message = PresentAcceptedMessage(sessionId = msg.sessionId);
    if (iceServers != null) {
      message.iceServers.addAll(iceServers);
    }

    _channel.send(message);

    presentationState = PresentationState.waitForStream;
    onConnect?.call();
  }

  void onPresentRejected(PresentRejectedMessage msg) {
    if (msg.reason?.text == 'timeout') {
    } else if (msg.reason?.text == 'blocked') {}
  }

  Future<void> onPausePresent() async {
    presentationState = PresentationState.pauseStreaming;
    controlAudio(false, setIsAudioEnabled: false);
    onRefresh?.call();
  }

  Future<void> onResumePresent() async {
    presentationState = PresentationState.resumeStreaming;
    controlAudio(isAudioEnabled & true, setIsAudioEnabled: false);
    onRefresh?.call();
  }

  Future<void> onStopPresent(
      StopPresentMessage msg, bool isModeratorMode) async {
    if (isModeratorMode) {
      StreamFunction.streamFunctionState.value = stateMenuOff;
      await disconnectPeerConnection(sendAnalytics: false);
      Home.enlargedScreenPositionIndex.value = null;
      HybridConnectionList().enlargedScreenIndex.value = null;
      HybridConnectionList().updateSplitScreen();
      sessionId = null;
      onShowMode?.call();
      return;
    } else if (HybridConnectionList.hybridSplitScreenCount.value > 0) {
      StreamFunction.streamFunctionState.value = stateMenuOff;
    }
    // disconnect the channel
    await disconnectPeerConnection(sendAnalytics: true);
    // clear renderer and close connection
    await disconnectChannel(reason: 'User stopped the present');
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

  static bool isMtk9950Model(String? deviceType) {
    return RTCConnector._mtk9950Models.contains(deviceType) ? true : false;
  }

  int getFullHeight(int attenderCount) {
    int fullHeight = 1080;

    // 70703 Workaround to solve iOS WebRTC screen freeze on IFP52-1 issue
    if (RTCConnector.isMtk9950Model(_deviceType) &&
        attenderCount > 1 &&
        senderPlatform != null &&
        senderPlatform == "ios") {
      fullHeight = 720;
    }

    return fullHeight;
  }

  void sendChangeQuality(
      bool isFullHeight, bool isFullFrameRate, int attendeeCount) {
    var message = ChangePresentQuality(sessionId);

    message.constraints = PresentQualityConstraints(
        frameRate: isFullFrameRate ? 30 : 0,
        height: isFullHeight ? getFullHeight(attendeeCount) : 540);

    log.info(
        '[$clientId] Changing present quality. height:${message.constraints?.height}');

    if (_controlDataChannel == null) {
      log.info(
          '[$clientId] Delay present quality change since data channel is not available now');

      _changeQualityMessage = message;
    } else {
      _sendControlMessage(message);
    }
  }

  void _sendControlMessage(ChannelMessage message) {
    log.info(
        '[$clientId] Sending control message via data channel ${message.toJson()}');

    _controlDataChannel?.send(
      RTCDataChannelMessage(jsonEncode(message.toJson())),
    );
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

    _sendControlMessage(message);
  }

  void sendInviteRemoteScreen() {
    var message = InviteRemoteScreenMessage();
    message.sessionId = sessionId = const Uuid().v4();
    _channel.send(message);
    isModeratorShare = true;
  }

  void sendStopRemoteScreen() {
    var message = StopRemoteScreenMessage(sessionId);
    _channel.send(message);
    isModeratorShare = false;
  }

  Future<void> disconnectPeerConnection({bool sendAnalytics = false}) async {
    _printPeerConnectionLog('disconnectPeerConnection', sendAnalytics);

    // clear renderer
    if (_remoteRenderer != null) {
      if (_remoteRenderer?.textureId != null && _remoteRenderer!.renderVideo) {
        _remoteRenderer?.srcObject = null;
      }
      try {
        await _remoteRenderer?.dispose();
      } catch (e) {
        log.warning('[$clientId] Error on dispose remoteRenderer: $e');
      }
      _remoteRenderer = RTCVideoRenderer();
    }

    if (_statsTimer != null) {
      _trackMetrics();

      stopStatsTimer();
    }

    log.info('[$clientId] Close PeerConnection');
    if (_pc != null) {
      await _pc?.close();
      await _pc?.dispose();
      _pc = null;
    }

    // change state
    presentationState = PresentationState.stopStreaming;
    onRefresh?.call();
  }

  Future<void> disconnectChannel({required String? reason}) async {
    stopConnectionTimeoutTimer();
    await onChannelDisconnect?.call(reason: reason);
  }

  _trackMetrics() {}

  Future<void> close(ChannelCloseCode code, {String? reason}) async {
    log.info('[$clientId] Close channel $reason');

    _stopChannelReconnectTimer();

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
    _trackTrace('pc_state', target: state.name);

    if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
      if (!_isRtcFirstConnected) {
        _isRtcFirstConnected = true;

        trackSessionEvent('start_cast');
      }

      // Ensure streaming remains uninterrupted even if the channel disconnects
      _stopChannelReconnectTimer();

      if (reconnectRtcState == ReconnectState.reconnecting) {
        reconnectRtcState = ReconnectState.success;
      }
    } else if (state ==
        RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
      reconnectRtcState = ReconnectState.reconnecting;
    } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
      if (reconnectRtcState == ReconnectState.reconnecting) {
        reconnectRtcState = ReconnectState.fail;
      }
      ConnectionTimer.getInstance().stopRemainingTimeTimer();
      await disconnectPeerConnection();
      await disconnectChannel(
          reason: 'RTC connection failed'); // todo: WebRTC連線fail, 不影響moderator
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
  }

  void _onTrack(RTCTrackEvent event) async {
    _printPeerConnectionLog('_onTrack', event.track);
    if (event.track.kind == 'video') {
      startStatsTimer();
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

    if (channel.label == 'pc-dc') {
      _touchbackDataChannel = channel;
    } else if (channel.label == 'pc-dc-control') {
      _controlDataChannel = channel;

      _controlDataChannel!.onMessage = _onControlMessage;
      if (_changeQualityMessage != null) {
        _sendControlMessage(_changeQualityMessage!);
        _changeQualityMessage = null;
      }
    }
  }

  void sendTouchback(Uint8List data) {
    if (_touchbackDataChannel != null &&
        _touchbackDataChannel!.state ==
            RTCDataChannelState.RTCDataChannelOpen) {
      _touchbackDataChannel!.send(RTCDataChannelMessage.fromBinary(data));
    }
  }

  void _onControlMessage(RTCDataChannelMessage data) {
    // The control message is in json (text-based format).
    if (data.isBinary) {
      // Ignore the binary message
      return;
    }

    try {
      final json = jsonDecode(data.text);
      final message = ChannelMessage.parse(json);

      if (message != null) {
        _onChannelMessageFromDataChannel(message);
      }
    } catch (e, stackTrace) {
      log.severe('_onControlMessage', e, stackTrace);
    }
  }

  // handle a channel message from the data channel
  void _onChannelMessageFromDataChannel(ChannelMessage message) {
    switch (message.messageType) {
      case ChannelMessageType.stopPresent:
        onStopPresent(
            message as StopPresentMessage, ChannelProvider.isModeratorMode);
        break;
      case ChannelMessageType.pausePresent:
        onPausePresent();
        break;
      case ChannelMessageType.resumePresent:
        onResumePresent();
        break;
      default:
        break;
    }
  }

  //endregion

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
    log.info('[$clientId] PeerConnection $event ${args.toString()}');

    if (kDebugMode) {
      const DebugSwitch().write('PeerConnection $event ${args.toString()}');
    }
  }

  bool isRtcConnectAvailable() {
    if (reconnectRtcState == ReconnectState.reconnecting ||
        reconnectRtcState == ReconnectState.fail) return false;
    return true;
  }

  bool isChannelConnectAvailable() {
    if (reconnectChannelState == ReconnectState.reconnecting ||
        reconnectChannelState == ReconnectState.fail) return false;
    return true;
  }

  bool isChannelReconnect() {
    if (reconnectChannelState == ReconnectState.reconnecting) return true;
    return false;
  }

  _trackTrace(
    String name, {
    String? target,
    Map<String, Object> properties = const <String, Object>{},
  }) {
    trackTrace(
      name,
      target: target,
      properties: {
        'participator_id': clientId ?? '',
        ...properties,
      },
    );
  }

  trackSessionEvent(String name) {
    trackEvent(
      name,
      EventCategory.session,
      mode: 'webrtc',
      participatorId: clientId ?? '',
    );
  }
}
