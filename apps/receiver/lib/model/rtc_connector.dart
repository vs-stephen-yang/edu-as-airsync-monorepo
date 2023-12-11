
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_vs/device_info_vs.dart';
import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/screens/debug_switch.dart';
import 'package:display_flutter/utility/print_in_debug.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

import 'connect_timer.dart';

class RTCConnector {
  String mUid = const Uuid().v4();
  final int index;
  final Channel _channel;
  final Mode _mode;
  String? _pin;

  PresentationState presentationState = PresentationState.stopStreaming;
  String? _sessionId;
  String? clientId;
  String? senderName;
  String? senderVersion;
  String? senderPlatform;

  final Map<String, dynamic> _configuration = {
    'sdpSemantics': 'unified-plan',
  };

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
  RTCVideoRenderer? get remoteRenderer => _remoteRenderer; // implement in webrtc_view

  Function()? onConnect;
  Function(MediaStream? stream)? onAddRemoteStream;
  Function(MediaStream stream)? onRemoveRemoteStream;
  Function()? onRefresh;
  Function()? onDisconnect;

  RTCConnector(this.index, this._channel, this._mode, {String? iceServersApiUrl, String? host}) {
    _printWebRTCViewSocketLog('init', null);

    _channel.onChannelMessage = (message) => _onMessages(message);
    final connectedMessage = ChannelConnectedMessage(5000, '');
    // print('zz connectedMessage ${connectedMessage.toJson().toString()}'); //zz connectedMessage {action: channel-connected, seq: null, data: {heartbeatInterval: 5000, reconnectionToken: }}
    _channel.send(connectedMessage);

    if (!_configuration.containsKey('iceServers')) {
      if (_mode == Mode.internet) {
        _getIceServers(iceServersApiUrl).then((value) {
          print('zz value $value');
          _configuration.putIfAbsent('iceServers', () => value);
          print('zz check 1');
          sendDisplayStatus();
        });
      } else {
        _configuration.putIfAbsent('iceServers', () => [{'url': 'stun:$host'}]);
        print('zz check 1-1');
        sendDisplayStatus();
      }
    }
  }

  void _onMessages(ChannelMessage message) {
    print('zz Received ${message.messageType} ${message.toJson().toString()}');

    switch (message.messageType) {
      case ChannelMessageType.joinDisplay:
        onJoinDisplay(message as JoinDisplayMessage);
        break;
      case ChannelMessageType.startPresent:
        onStartPresent(message as StartPresentMessage);
        break;
      case ChannelMessageType.presentAccepted:
        onPresentAccepted();
        break;
      case ChannelMessageType.presentRejected:
        onPresentRejected(message as PresentRejectedMessage);
        break;
      case ChannelMessageType.changePresentQuality:
        onChangeQuality(message as ChangePresentQuality);
      case ChannelMessageType.pausePresent:
        onPausePresent();
        break;
      case ChannelMessageType.resumePresent:
        onResumePresent();
        break;
      case ChannelMessageType.stopPresent:
        onStopPresent(message as StopPresentMessage);
      case ChannelMessageType.presentSignal:
        onPresentSignal(message as PresentSignalMessage);
      default:
        break;
    }
  }

  void sendDisplayStatus() {
    final displayStatusMessage = DisplayStatusMessage();
    displayStatusMessage.platform = _getPlatform();
    displayStatusMessage.status = DisplayStatus.fromJson({'moderator':false}); //TODO:moderator status
    _channel.send(displayStatusMessage);
  }

  void onJoinDisplay(JoinDisplayMessage msg) {
    clientId = msg.clientId;
    senderName = msg.name;
    senderVersion = msg.version;
    senderPlatform = msg.platform;
  }

  Future<void> onStartPresent(StartPresentMessage msg) async {
    // Timer
    ConnectionTimer.getInstance().startConnectionTimer(() {
      var message = PresentRejectedMessage();
      message.sessionId = _sessionId;
      message.reason = PresentRejectReason(400, 'timeout');
      _channel.send(message);
      disconnect(sendAnalytics: true);
      // NativeView will invokeMethod disconnectedP2pClient to switch UI.
    });

    await _remoteRenderer?.initialize();
    await _peerConnectionConnect();
    final message = PresentAcceptedMessage(_sessionId = msg.sessionId);
    _channel.send(message);
    // await connectClient((result) => null);

    presentationState = PresentationState.waitForStream;
    onConnect?.call();
    // Send wait for stream
  }

  void onPresentAccepted() {
    AppAnalytics().trackEventPresentReadySent(clientId!, _sessionId!);
  }

  void onPresentRejected(PresentRejectedMessage msg) {
    if (msg.reason?.text == 'timeout') {
      AppAnalytics().trackEventPresentRejectTimeOutSent(clientId!, _sessionId!);
    } else if (msg.reason?.text == 'blocked') {
      AppAnalytics().trackEventPresentRejectBlockedSent(clientId!, _sessionId!);
    }
  }

  Future<void> onChangeQuality(ChangePresentQuality msg) async {

  }

  Future<void> onPausePresent() async {
    print('zz onPausePresent');
    AppAnalytics().trackEventPresentPauseReceived(clientId!, _sessionId!);
    presentationState = PresentationState.pauseStreaming;
    onRefresh?.call();
  }

  Future<void> onResumePresent() async {
    print('zz onResumePresent');
    AppAnalytics().trackEventPresentResumeReceived(clientId!, _sessionId!);
    presentationState = PresentationState.resumeStreaming;
    onRefresh?.call();
  }

  Future<void> onStopPresent(StopPresentMessage msg) async {
    AppAnalytics().trackEventPresentStopReceived(
        clientId!, _sessionId!);
    disconnect(sendAnalytics: true);

    //TODO:
    // if (moderator == null &&
    //     !SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
    //   ConnectionTimer.getInstance().stopRemainingTimeTimer();
    // } else if (SplitScreen.mapSplitScreen.value[keySplitScreenCount] > 0) {
    //   StreamFunction.streamFunctionState.value = stateMenuOff;
    // }
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
        final message = PresentSignalMessage(msg.sessionId, SignalMessageType.answer);
        message.sdp = fixedAnswer.sdp;
        message.sdpMLineIndex = 0;
        // print('zz send ${message.toJson().toString()}');
        _channel.send(message);
        break;
      case SignalMessageType.candidate:
        // add candidates from the peer
        final candidate = RTCIceCandidate(msg.candidate, msg.sdpMid, msg.sdpMLineIndex);
        await pc!.addCandidate(candidate);
        break;
      default:
        break;
    }
  }

  Future<void> _peerConnectionConnect() async {
    if (_pc != null) return;

    String? deviceType = await DeviceInfoVs.deviceType;
    if (_prerendererSmoothingExcludedDevices.contains(deviceType)) {
      _configuration['enablePrerendererSmoothing'] = false;
    }
    // print('zz_peerConnectionConnect ${_configuration.toString()}');
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

  Future<void> disconnect({bool sendAnalytics = false}) async {
    _printWebRTCViewSocketLog('zz disconnect', sendAnalytics);
    if (sendAnalytics) {
      AppAnalytics().trackEventPresentStopped(_sessionId!, clientId!);
    }

    // clear renderer
    if (_remoteRenderer?.textureId != null && _remoteRenderer!.renderVideo) {
      // onDisconnect may come-in many times, need check textureId first.
      _remoteRenderer?.srcObject = null;
      await _remoteRenderer?.dispose();
      _remoteRenderer = RTCVideoRenderer();
    }
    if (_pc != null) {
      await _pc?.close();
      await _pc?.dispose();
      _pc = null;
    }
    _channel.close();

    // change state
    presentationState = PresentationState.stopStreaming;
    // clear renderer and close connection
    onDisconnect?.call();
    // showConnectionInfo(false);
    // update Display state via presenterId
    // ControlSocket().handleRtcControllerDisconnect(this); //TODO: disconnect

    // finally, clear all presenter settings
    _resetSetting();
  }

  void controlAudio(bool isEnable) {
    // if (mViewState.mounted) {
    //   mViewState.controlAudio(isEnable);
    // }
  }

  void showConnectionInfo(bool enable) {
    // if (mViewState.mounted) {
    //   mViewState.showConnectionInfo = enable;
    // }
  }

  void changeQuality(bool isFullHeight, bool isFullFrameRate) async {
    var message = ChangePresentQuality(_sessionId);
    message.constraints?.frameRate = isFullFrameRate ? 30 : 0;
    message.constraints?.height = isFullHeight ? 1080 : 540;
    _channel.send(message);
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

  void _onPeerConnectionState(RTCPeerConnectionState state) {
    _printPeerConnectionLog('_onPeerConnectionState', state);
    if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
      ConnectionTimer.getInstance().stopConnectionTimeoutTimer();
      ConnectionTimer.getInstance().stopRemainingTimeTimer();
      disconnect();
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
      PresentSignalMessage(_sessionId, SignalMessageType.candidate);
      message.candidate = candidate.candidate;
      message.sdpMid = candidate.sdpMid;
      message.sdpMLineIndex = candidate.sdpMLineIndex;
      // print('zz send candidate ${message.toJson().toString()}');
      _channel.send(message);
    });
  }

  void _onRenegotiationNeeded() {
    _printPeerConnectionLog('_onRenegotiationNeeded', null);
  }

  void _onAddStream(MediaStream stream) {
    _printPeerConnectionLog('_onAddStream', stream.getTracks().first.id);
    ConnectionTimer.getInstance().stopConnectionTimeoutTimer();
    if (MirrorStateProvider.isMirroring) {
      // check the mirror state and disconnect the webrtc connection
      // ControlSocket().handleConflictWithMirror(); //TODO:
      return;
    }
    presentationState = PresentationState.streaming;
    // showConnectionInfo(false);
    // ControlSocket().handleAddStreamState(this); //TODO:
    // navService.popUntil('/home');
    // _remoteRenderer?.srcObject = stream;
    onAddRemoteStream?.call(_remoteRenderer?.srcObject);
    AppAnalytics().trackEventPresentStarted(_sessionId!, clientId!);
  }

  void _onTrack(RTCTrackEvent event) async {
    _printPeerConnectionLog('_onTrack', event.track);
    if (event.track.kind == 'video') {
      print('zz _onTrack $index 0 ${_remoteRenderer==null}');
      _remoteRenderer?.srcObject = event.streams[0];
      print('zz _onTrack $index 1 ${_remoteRenderer?.srcObject ==null}');
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
    printInDebug('_onDataChannel: ${channel.label}');
    _dc = channel;
  }

  void sendData(Uint8List data) {
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

      // print('zz _getIceServers ${response.statusCode} ${response.body}');
      if (response.statusCode >= HttpStatus.ok &&
          response.statusCode < HttpStatus.multiStatus) {
        Map<String, dynamic> iceServerList = jsonDecode(response.body);
        if (iceServerList.containsKey('list')) {
          List list = iceServerList['list'];
          // _configuration.putIfAbsent('iceServers', () => list);
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

  String _getPlatform() {
    String platform;
    if (kIsWeb) {
      platform = 'Web';
    } else {
      if (Platform.isIOS) {
        platform = 'iOS';
      } else if (Platform.isAndroid) {
        platform = 'Android';
      } else {
        platform = ''; // todo: support other platform.
      }
    }
    return platform;
  }

  void _resetSetting() {
    _sessionId = null;
    clientId = null;
    senderName = null;
    senderVersion = '';
    senderPlatform = '';
  }

  void _printWebRTCViewSocketLog(String? event, dynamic args) {
    if (kDebugMode) {
      printInDebug(
          '$runtimeType,  mWebRTCViewSocket{$mUid}: $event ${args.toString()}');
      const DebugSwitch()
          .write('mWebRTCViewSocket{$mUid}: $event ${args.toString()}');
    }
  }

  void _printPeerConnectionLog(String? event, dynamic args) {
    if (kDebugMode) {
      printInDebug('$runtimeType, mPeerConnect{$event ${args.toString()}');
      const DebugSwitch().write('mPeerConnect{$event ${args.toString()}');
    }
  }
}