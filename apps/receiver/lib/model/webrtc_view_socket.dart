import 'dart:convert';
import 'dart:io';

import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/screens/debug_switch.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/utility/print_in_debug.dart';
import 'package:display_flutter/widgets/webrtc_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:device_info_vs/device_info_vs.dart';

import 'connect_timer.dart';
import 'control_socket.dart';

class WebRTCFlutterViewSocket {
  late String mUid;
  late WebRTCFlutterViewState mViewState;

  PresentationState presentationState = PresentationState.stopStreaming;
  String presentId = '';
  String presenterId = '';
  String presenterName = '';
  String peerToken = '';
  String peerId = '';
  String? signalURL;
  final Map<String, dynamic> _streamInfo = {};

  final Map<String, dynamic> _configuration = {
    'sdpSemantics': 'unified-plan',
  };

  // the following device should not enable webrtc prerendererSmoothing flag
  final List<String> _prerendererSmoothingExcludedDevices = [
    'IFP50_2',
    'IFP52_K',
    'IFP50_3',
    'IFP50_3_9850',
  ];

  RTCPeerConnection? _pc;
  RTCDataChannel? _dc;
  io.Socket? socket;

  // implement in webrtc_view
  Function()? onConnect;
  Function(MediaStream? stream)? onAddRemoteStream;
  Function(MediaStream stream)? onRemoveRemoteStream;
  Function()? onDisconnect;

  Future<void> init(String uid, WebRTCFlutterViewState state) async {
    mUid = uid;
    mViewState = state;
    _printWebRTCViewSocketLog('init', null);
  }

  Future<void> connectClient(String token, String displayCode, String peerId,
      String url, Function(bool result) callback) async {

    onConnect?.call();
    await _peerConnectionConnect();
    _signalConnect(token, displayCode, peerId, url, callback);
  }

  Future<void> _peerConnectionConnect() async {
    if (_pc != null) return;
    if (!_configuration.containsKey('iceServers')) {
      await _getIceServers();
    }

    String? deviceType = await DeviceInfoVs.deviceType;
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

  void _signalConnect(
      String token, String displayCode, String id, String url, Function(bool result) callback) {
    socket = io.io(
        url, //'https://signal.stage.myviewboard.cloud'
        io.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .enableForceNew()
            .enableForceNewConnection()
            .enableReconnection()
            .setReconnectionAttempts(5)
            .enableMultiplex()
            .setQuery({'token': token, 'displayCode': displayCode})
            .build());

    socket?.onConnect((_) async {
      _printWebRTCViewSocketLog('onConnect', _);
    });

    socket?.on('owt-message', (data) async {
      _printWebRTCViewSocketLog(OwtMessageType.owt_message.value, data);
      final msg = jsonDecode(data['data']);
      final type = msg['type'];

      if (type == OwtMessageType.signaling_message.value) {
        //"chat-signal"
        await _handleSignal(msg['data']);
      }
      if (type == OwtMessageType.chat_ua.value) {
        //'chat-ua'
        _send(OwtMessageType.chat_ua.value, {
          'sdk': {'type': _getPlatform(), 'version': 5},
          'capabilities': {
            'continualIceGathering': true,
            'unifiedPlan': true,
            'streamRemovable': true
          }
        });
      }
      if (type == OwtMessageType.stream_info.value) {
        //'chat-stream-info'
        var info = msg['data'];
        _streamInfo[info['id'].toString()] = info;
      }
    });

    socket?.on('server-authenticated', (data) async {
      _printWebRTCViewSocketLog('server-authenticated', data);
      peerToken = token;
      peerId = id;
      signalURL = url;
      callback(true);
    });

    socket?.onDisconnect((_) async {
      _printWebRTCViewSocketLog('onDisconnect', _);
      socket?.clearListeners();
      socket = null;
      ConnectionTimer.getInstance().stopConnectionTimeoutTimer();
    });

    socket?.onConnectError((data) {
      _printWebRTCViewSocketLog('onConnectError', data);
      ConnectionTimer.getInstance().stopConnectionTimeoutTimer();
    });

    socket?.onConnectTimeout(
            (data) => _printWebRTCViewSocketLog('onConnectTimeout', data));
    socket?.onError((data) => _printWebRTCViewSocketLog('onError', data));
    socket?.onReconnect((data) => _printWebRTCViewSocketLog('onReconnect', data));
    socket?.onReconnectError(
            (data) => _printWebRTCViewSocketLog('onReconnectError', data));
    socket?.onReconnectFailed(
            (data) => _printWebRTCViewSocketLog('onReconnectFailed', data));

    socket?.connect();
  }

  Future<void> disconnect({bool sendAnalytics = false}) async {
    _printWebRTCViewSocketLog('disconnect', sendAnalytics);
    if (sendAnalytics) {
      AppAnalytics().trackEventPresentStopped(presentId, presenterId);
    }

    // clear renderer and close connection
    onDisconnect?.call();
    if (_pc != null) {
      await _pc?.close();
      await _pc?.dispose();
      _pc = null;
    }
    if (socket != null && socket!.connected) {
      socket?.close();
    }

    // change state
    presentationState = PresentationState.stopStreaming;
    showConnectionInfo(false);
    // update Display state via presenterId
    ControlSocket().handleRtcControllerDisconnect(this);

    // finally, clear all presenter settings
    _resetSetting();
  }

  void controlAudio(bool isEnable) {
    if (mViewState.mounted) {
      mViewState.controlAudio(isEnable);
    }
  }

  void pauseVideo() {
    if (mViewState.mounted) {
      mViewState.pauseVideo();
    }
  }

  void resumeVideo() {
    if (mViewState.mounted) {
      mViewState.resumeVideo();
    }
  }

  void showConnectionInfo(bool enable) {
    if (mViewState.mounted) {
      mViewState.showConnectionInfo = enable;
    }
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
  }

  Future<void> _onIceCandidate(RTCIceCandidate candidate) async {
    _printPeerConnectionLog('_onIceCandidate', candidate);

    // send candidates to the peer
    // This delay is needed to allow enough time to try an ICE candidate
    // before skipping to the next one. 1 second is just an heuristic value
    // and should be thoroughly tested in your own environment.
    await Future.delayed(
        const Duration(milliseconds: 500),
            () => _send(OwtMessageType.signaling_message.value, {
          'type': 'candidates',
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
        }));
  }

  void _onRenegotiationNeeded() {
    _printPeerConnectionLog('_onRenegotiationNeeded', null);
  }

  void _onAddStream(MediaStream stream) {
    _printPeerConnectionLog('_onAddStream', stream);
    ConnectionTimer.getInstance().stopConnectionTimeoutTimer();
    if (MirrorStateProvider.isMirroring) {
      // check the mirror state and disconnect the webrtc connection
      ControlSocket().handleConflictWithMirror();
      return;
    }
    presentationState = PresentationState.streaming;
    showConnectionInfo(false);
    ControlSocket().handleAddStreamState(this);
    if (_streamInfo.containsKey(stream.id)) {
      _send(OwtMessageType.track_add_ack.value,
          _streamInfo[stream.id]['tracks']); //'chat-tracks-added'
    }
    AppAnalytics().trackEventPresentStarted(presentId, presenterId);
  }

  void _onTrack(RTCTrackEvent event) async {
    _printPeerConnectionLog('_onTrack', event);
    if (event.track.kind == 'video') {
      onAddRemoteStream?.call(event.streams[0]);
    }
  }

  /// iOS, macOS did not use this event.
  void _onAddTrack(MediaStream stream, MediaStreamTrack track) {
    _printPeerConnectionLog('_onAddTrack', track);
  }

  void _onRemoveTrack(MediaStream stream, MediaStreamTrack track) {
    _printPeerConnectionLog('_onRemoveTrack', track);
    onRemoveRemoteStream?.call(stream);
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

  void _send(type, message) {
    var data = {
      'data': jsonEncode({'type': type, 'data': message}),
      'to': peerId
    };
    _printWebRTCViewSocketLog('_send', data);
    socket?.emit(OwtMessageType.owt_message.value, data); //'owt-message'
  }

  Future<void> _handleSignal(msg) async {
    final type = msg['type'];
    _printWebRTCViewSocketLog('_handleSignal', type);

    if (type == 'offer') {
      // handle offer from the peer
      final offer = RTCSessionDescription(msg['sdp'], type);
      await _pc!.setRemoteDescription(offer);

      // create answer
      final answer = await _pc!.createAnswer();
      RTCSessionDescription fixedAnswer = _fixSdp(answer);
      await _pc!.setLocalDescription(fixedAnswer);
      // send answer to the peer
      _send(OwtMessageType.signaling_message.value, {'type': fixedAnswer.type, 'sdp': fixedAnswer.sdp});
    } else if (type == 'candidates') {
      // add candidates from the peer
      final candidate = RTCIceCandidate(
          msg['candidate'], msg['sdpMid'], msg['sdpMLineIndex']);
      _pc!.addCandidate(candidate);
    }
  }

  Future<void> _getIceServers() async {
    try {
      http.Response response = await http.get(
        Uri.parse(AppConfig.of(mViewState.context)!.settings.getIceServer),
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
    presentId = '';
    presenterId = '';
    presenterName = '';
    peerToken = '';
    peerId = '';
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