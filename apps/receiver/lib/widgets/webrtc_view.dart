import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/connect_timer.dart';
import 'package:display_flutter/model/control_socket.dart';
import 'package:display_flutter/screens/split_screen.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:uuid/uuid.dart';

import 'custom_icons_icons.dart';

typedef WebRTCFlutterViewCreatedCallback = void Function(
    WebRTCFlutterViewController controller);

class WebRTCFlutterView extends StatefulWidget {
  const WebRTCFlutterView({Key? key, required this.callback}) : super(key: key);
  final WebRTCFlutterViewCreatedCallback callback;

  @override
  State createState() => WebRTCFlutterViewState();
}

class WebRTCFlutterViewState extends State<WebRTCFlutterView> with TickerProviderStateMixin {
  final WebRTCFlutterViewController _viewController = WebRTCFlutterViewController();
  bool _showConnectionInfo = false;
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    print('zz initState');
    _viewController.init(const Uuid().v4(), this);
    widget.callback(_viewController);

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: false);
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    );
    // init logger
    Logger.root.level = Level.ALL; // defaults to Level.INFO
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  @override
  void deactivate() {
    print('zz deactivate');
    if (_viewController._socket != null && _viewController._socket!.connected) {
      _viewController.disconnect().then((value) {
        ControlSocket().removeWebRtcController(_viewController);
        super.deactivate();
      });
    } else {
      super.deactivate();
    }
  }

  @override
  void dispose() {
    print('zz dispose');
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String presenterName = '';
    presenterName = _viewController.presenterName;
    if (presenterName.length > 10) {
      presenterName = '${presenterName.substring(0, 10)}..';
    }
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Focus(
          descendantsAreFocusable: false,
          canRequestFocus: false,
          child: RTCVideoView(_viewController.renderer),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Visibility(
            visible: _viewController.presentationState ==
                PresentationState.streaming &&
                _viewController.presenterName.isNotEmpty &&
                SplitScreen.mapSplitScreen.value[keySplitScreenEnable],
            child: Container(
              width: 120,
              height: 30,
              padding: const EdgeInsets.all(5),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.primaryBlackA50,
              ),
              child: AutoSizeText(
                presenterName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
                maxLines: 1,
              ),
            ),
          ),
        ),
        Visibility(
          visible: showConnectionInfo,
          child: Transform.scale(
            scale: SplitScreen.mapSplitScreen.value[keySplitScreenEnable] &&
                SplitScreen.mapSplitScreen.value[keySplitScreenCount] > 1
                ? 0.5
                : 1.0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Visibility(
                    visible: ControlSocket().moderator != null,
                    child: Column(
                      children: <Widget>[
                        Text(
                          S.of(context).main_wait_up_next,
                          style: const TextStyle(
                            color: AppColors.primary_white,
                            fontWeight: FontWeight.w700,
                            fontSize: 25,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          _viewController.presenterName,
                          style: const TextStyle(
                            color: AppColors.primary_blue,
                            fontWeight: FontWeight.w700,
                            fontSize: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: RotationTransition(
                      turns: _animation,
                      child: const Icon(
                        CustomIcons.loading,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    S.of(context).main_wait_title,
                    style: const TextStyle(
                      color: AppColors.primary_blue,
                      fontWeight: FontWeight.w700,
                      fontSize: 25,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool get showConnectionInfo => _showConnectionInfo;

  set showConnectionInfo(bool value) {
      setState(() {
        _showConnectionInfo = value;
      });
  }
}

class WebRTCFlutterViewController {
  late String mUid;
  late WebRTCFlutterViewState mViewState;

  PresentationState presentationState = PresentationState.stopStreaming;
  String presentId = '';
  String presenterId = '';
  String presenterName = '';
  String peerToken = '';
  String peerId = '';
  String? signalURL;

  String? _token;
  String? _peerId;

  RTCPeerConnection? _pc;
  IO.Socket? _socket;
  var _remoteRenderer = RTCVideoRenderer();

  RTCVideoRenderer get renderer => _remoteRenderer;

  String get sdpSemantics => 'unified-plan';

  Future<void> init(String uid, WebRTCFlutterViewState state) async {
    mUid = uid;
    mViewState = state;
  }

  Future<void> initPeerConnection() async {
    await _remoteRenderer.initialize();
    Map<String, dynamic> iceServerList = await _getIceServer();
    var configuration = <String, dynamic>{
      'iceServers': [
        {
          'url': '${iceServerList['list'][0]['url']}',  //'stun:ice.stage.myviewboard.cloud:3478'
        },
        {
          'url': '${iceServerList['list'][1]['url']}', //'turn:ice.stage.myviewboard.cloud:3478?transport=udp',
          'username': '${iceServerList['list'][1]['username']}', //'turn_stage_user',
          'credential': '${iceServerList['list'][1]['credential']}', //'2riBFYDuyqO3v3QGxgu2H3uQEf4='
        },
        {
          'url': '${iceServerList['list'][2]['url']}', //'turn:ice.stage.myviewboard.cloud:443?transport=tcp',
          'username': '${iceServerList['list'][2]['username']}', //'turn_stage_user',
          'credential': '${iceServerList['list'][2]['credential']}', //'2riBFYDuyqO3v3QGxgu2H3uQEf4='
        },
        {
          'url': '${iceServerList['list'][3]['url']}', //'turns:ice.stage.myviewboard.cloud:443?transport=tcp',
          'username': '${iceServerList['list'][3]['username']}', //'turn_stage_user',
          'credential': '${iceServerList['list'][3]['credential']}', //'2riBFYDuyqO3v3QGxgu2H3uQEf4='
        },
      ],
      // 'sdpSemantics': 'unified-plan'
    };

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
  }

  Future<void> connectClient(String token, String displayCode, String peerId, String url, Function(bool result) callback) async {
    log('zz connectClient 1');
    if (_pc == null) await initPeerConnection();

    _token = token;
    _peerId = peerId;
    _socket = IO.io(
        url, //'https://signal.stage.myviewboard.cloud'
        IO.OptionBuilder()
            // .enableForceNew()
            .enableForceNewConnection()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .disableReconnection()
            .setTimeout(2000)
            // .enableReconnection()
            // .setReconnectionAttempts(5)
            .setQuery({
          'token': _token,
          'displayCode': displayCode
        })
            .build());

    _socket?.onConnect((_) async {
      print('zz connect');
    });

    _socket?.on('owt-message', (data) async {
      print('zz owt-message $data');
      final msg = jsonDecode(data['data']);
      final type = msg['type'];

      if (type == "chat-signal") {
        await _handleSignal(msg['data']);
      }
    });

    _socket?.on('server-authenticated', (data) async {
      print('zz server-authenticated: ${data.toString()}');
      callback(true);
    });

    _socket?.onDisconnect((_) async {
      print('zz _socket onDisconnect ${_socket?.disconnected}');
      await Future.delayed(const Duration(seconds: 1)).then((value) {

        print('zz zz _socket onDisconnect 2');
        // unbinds a specific event listeners
        // _socket?.clearListeners(); // unbinds all the listeners
        IO.cache.forEach((key, value) {
          print('zz key $key $value');
        });
        IO.cache.clear();
        _socket?.io.destroy(_socket);
        _socket?.io.destroy(_socket?.io.engine);
        _socket?.io.disconnect();
        _socket?.io.engine.close();
        _socket?.io.engine.flush();
        _socket = null;
        ConnectionTimer.getInstance().stopConnectionTimeoutTimer();
      });
    });

    _socket?.onConnectError((data) {
      print('zz ConnectError: $data');
      // onServerDisconnected
      ConnectionTimer.getInstance().stopConnectionTimeoutTimer();
    });

    _socket?.on('server-disconnect', (data) {
      print('zz server-disconnect: $data');
      // onServerDisconnected
      ConnectionTimer.getInstance().stopConnectionTimeoutTimer();
    });

    _socket?.onConnecting((data) => print('zz onConnecting: $data'));
    _socket?.onConnectTimeout((data) => print('zz onConnectTimeout: $data'));
    _socket?.onError((data) => print('zz onError: $data'));
    _socket?.onReconnect((data) => print('zz onReconnect: $data'));
    _socket?.onReconnectAttempt((data) => print('zz onReconnectAttempt: $data'));
    _socket?.onReconnectError((data) => print('zz onReconnectError: $data'));
    _socket?.onReconnectFailed((data) => print('zz onReconnectFailed: $data'));
    _socket?.onReconnecting((data) => print('zz onReconnecting: $data'));
    _socket?.onPing((data) => print('zz onPing: $data'));
    _socket?.onPong((data) => print('zz onPong: $data'));
    _socket?.on('error', (data) => print("zz error $data"));

    _socket?.connect();
  }

  Future<void> disconnect({bool sendAnalytics = false}) async {
    print('zz disconnect process ');
    if (sendAnalytics) {
      AppAnalytics().trackEventPresentStopped(presentId, presenterId);
    }

    // close connection
    if (_remoteRenderer.textureId != null && _remoteRenderer.renderVideo) {
      _remoteRenderer.srcObject = null;
      await _remoteRenderer.dispose();
      _remoteRenderer = RTCVideoRenderer();
    }
    await _pc?.close();
    await _pc?.dispose();
    _pc = null;
    if (_socket != null && _socket!.connected) {
      print('zz disconnect _socket');
      _socket?.disconnect();
      _socket?.close();
      _socket?.destroy();
    }

    // change state
    presentationState = PresentationState.stopStreaming;
    showConnectionInfo(false);
    // update Display state via presenterId
    ControlSocket().handleRtcControllerDisconnect(this);

    // finally, clear all presenter settings
    presentId = '';
    presenterId = '';
    presenterName = '';
    peerToken = '';
    peerId = '';
  }

  void controlAudio(bool isEnable) {
    renderer.srcObject?.getAudioTracks().first.enabled = isEnable;
  }

  void pauseVideo() {
    renderer.srcObject?.getTracks().first.enabled = false;
  }

  void resumeVideo() {
    renderer.srcObject?.getTracks().first.enabled = true;
  }

  void showConnectionInfo(bool enable) {
    if (mViewState.mounted) {
      mViewState.showConnectionInfo = enable;
    }
  }

  //region PeerConnection interface
  void _onSignalingState(RTCSignalingState state) {
    print('zz _onSignalingState ${state.name}');
  }

  void _onIceGatheringState(RTCIceGatheringState state) {
    print('zz _onIceGatheringState ${state.name}');
  }

  void _onIceConnectionState(RTCIceConnectionState state) {
    print('zz _onIceConnectionState ${state.name}');
  }

  void _onPeerConnectionState(RTCPeerConnectionState state) {
    print('zz _onPeerConnectionState ${state.name}');
  }

  Future<void> _onIceCandidate(RTCIceCandidate candidate) async {
    print('zz _onIceCandidate: ${candidate.candidate}');

    // _pc?.addCandidate(candidate);
    // send candidates to the peer
    // This delay is needed to allow enough time to try an ICE candidate
    // before skipping to the next one. 1 second is just an heuristic value
    // and should be thoroughly tested in your own environment.
    await Future.delayed(
        const Duration(milliseconds: 500),
            () => _send('chat-signal', {
          'type': 'candidates',
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
        }));
  }

  void _onRenegotiationNeeded() {
    print('!!!! RenegotiationNeeded');
  }

  void _onAddStream(MediaStream stream) {
    print('zz _onAddStream');
    ConnectionTimer.getInstance().stopConnectionTimeoutTimer();
    presentationState = PresentationState.streaming;
    showConnectionInfo(false);
    ControlSocket().handleAddStreamState(this);

    AppAnalytics().trackEventPresentStarted(presentId, presenterId);
  }

  void _onTrack(RTCTrackEvent event) async {
    print('zz onTrack ${event.track.id}');
    if (event.track.kind == 'video') {
      mViewState.setState(() {
        _remoteRenderer.srcObject = event.streams[0]; //stream;
      });
      _remoteRenderer.srcObject?.getTracks().first.onEnded = () {
        print('zz ended');
        disconnect();
      };
      // _startReportStats();
    }
  }

  /// iOS, macOS did not use this event.
  void _onAddTrack(MediaStream stream, MediaStreamTrack track) {
    print('zz _onAddTrack ${track.id}');
    // if (track.kind == 'video') {
    //   _remoteRenderer.srcObject = stream;
    // }
  }

  void _onRemoveTrack(MediaStream stream, MediaStreamTrack track) {
    print('zz _onRemoveTrack');
    // stream
    if (_remoteRenderer.srcObject?.id == stream.id) {
      _remoteRenderer.srcObject = null;
    }
  }

  //endregion

  // void _startReportStats() {
  //   _statsTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
  //     var stats = await _pc?.getStats(null);
  //     stats?.forEach((st) {
  //       //print('!!!! ${st.id} ${st.type}');
  //       if (st.type.contains('ssrc')) {
  //         print(
  //             '!!!! ${st.values['ssrc']},Decoded,${st.values['googFrameRateDecoded']}, Received,${st.values['googFrameRateReceived']},Output,${st.values['googFrameRateOutput']},Decode,${st.values['googDecodeMs']},Delay,${st.values['googCurrentDelayMs']}');
  //       }
  //     });
  //     mViewState.setState(() {});
  //   });
  // }

  void _send(type, message) {
    print('zz _send $type');
    var data = {
      'data': jsonEncode({'type': type, 'data': message}),
      'to': _peerId
    };

    _socket?.emit('owt-message', data);
  }

  Future<void> _handleSignal(msg) async {
    final type = msg['type'];
    print('zz _handleSignal $type');

    if (type == 'offer') {
      // handle offer from the peer
      final offer = RTCSessionDescription(msg['sdp'], type);
      await _pc!.setRemoteDescription(offer);

      // create answer
      final answer = await _pc!.createAnswer();
      await _pc!.setLocalDescription(answer);
      // send answer to the peer
      _send('chat-signal', {'type': answer.type, 'sdp': answer.sdp});

    } else if (type == 'candidates') {
      // add candidates from the peer
      final candidate = RTCIceCandidate(
          msg['candidate'], msg['sdpMid'], msg['sdpMLineIndex']);
      _pc!.addCandidate(candidate);
    }
  }

  Future<Map<String, dynamic>> _getIceServer() async {
    try {
      http.Response response = await http.get(
        Uri.parse(AppConfig.of(mViewState.context)!.settings.getIceServer), //'https://getice.stage.myviewboard.cloud' AppConfig.of(context)!.settings.getIceServer
      );

      if (response.statusCode >= HttpStatus.ok &&
          response.statusCode < HttpStatus.multiStatus) {
        Map<String, dynamic> json = jsonDecode(response.body);
        return json;
      } else {
        return {};
      }
    } catch (e) {
      // http.get maybe no network connection.
      return {};
    }
  }
}
