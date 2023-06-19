import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/connect_timer.dart';
import 'package:display_flutter/model/control_socket.dart';
import 'package:display_flutter/protoc/event.pb.dart';
import 'package:display_flutter/protoc/internal.pb.dart';
import 'package:display_flutter/screens/debug_switch.dart';
import 'package:display_flutter/screens/split_screen.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/utility/print_in_debug.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as io;
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

class WebRTCFlutterViewState extends State<WebRTCFlutterView>
    with TickerProviderStateMixin {
  final WebRTCFlutterViewController _viewController =
      WebRTCFlutterViewController();
  bool _showConnectionInfo = false;
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  final GlobalKey _widgetKey = GlobalKey();
  bool _textureSizeChanged = true;
  Size _textureSize = const Size(0, 0);
  Offset _textureOffset = const Offset(0, 0);

  @override
  void initState() {
    super.initState();
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
  }

  @override
  void deactivate() {
    if (_viewController._socket != null && _viewController._socket!.connected) {
      _viewController.disconnect().then((value) {
        super.deactivate();
      });
    } else {
      _viewController._socket = null;
      super.deactivate();
    }
  }

  @override
  void dispose() {
    ControlSocket().removeWebRtcController(_viewController);
    _animationController.dispose();
    super.dispose();
  }

  void _getTextureInfo() {
    Element? textureElement;
    void textureVisitor(Element element) {
      if (textureElement != null) return;

      if (element.widget is Texture) {
        textureElement = element;
      } else {
        element.visitChildElements(textureVisitor);
      }
    }

    _widgetKey.currentContext?.visitChildElements(textureVisitor);
    if (textureElement == null) {
      printInDebug('texture widget not found');
      return;
    } else {
      final RenderBox renderBox =
          textureElement!.findRenderObject() as RenderBox;
      _textureSize = renderBox.size;
      _textureOffset = renderBox.localToGlobal(Offset.zero);
      printInDebug(
          'texture widget size: (${_textureSize.width.toStringAsFixed(2)}, ${_textureSize.height.toStringAsFixed(2)}), offset: (${_textureOffset.dx.toStringAsFixed(2)}, ${_textureOffset.dy.toStringAsFixed(2)})');
      _textureSizeChanged = false;
    }
  }

  void _onTouchStart(PointerEvent event) {
    _onTouchEvent(TouchEvent_TouchEventType.TOUCH_POINT_START, event);
  }

  void _onTouchMove(PointerEvent event) {
    _onTouchEvent(TouchEvent_TouchEventType.TOUCH_POINT_MOVE, event);
  }

  void _onTouchEnd(PointerEvent event) {
    _onTouchEvent(TouchEvent_TouchEventType.TOUCH_POINT_END, event);
  }

  void _onTouchEvent(TouchEvent_TouchEventType eventType, PointerEvent event) {
    if (_textureSizeChanged) {
      _getTextureInfo();
    }

    final curTouchEventPoint = TouchEventPoint();
    curTouchEventPoint.x =
        (event.position.dx - _textureOffset.dx) / _textureSize.width;
    /* make curTouchEventPoint.x between 0.0 ~ 1.0 */
    if (curTouchEventPoint.x < 0.0) {
      curTouchEventPoint.x = 0.0;
    } else if (curTouchEventPoint.x > 1.0) {
      curTouchEventPoint.x = 1.0;
    }
    curTouchEventPoint.y =
        (event.position.dy - _textureOffset.dy) / _textureSize.height;
    /* make curTouchEventPoint.y between 0.0 ~ 1.0 */
    if (curTouchEventPoint.y < 0.0) {
      curTouchEventPoint.y = 0.0;
    } else if (curTouchEventPoint.y > 1.0) {
      curTouchEventPoint.y = 1.0;
    }

    curTouchEventPoint.id = event.pointer;

    final curTouchEvent = TouchEvent();
    curTouchEvent.eventType = eventType;
    curTouchEvent.touchPoints.add(curTouchEventPoint);

    final curEventMessage = EventMessage();
    curEventMessage.touchEvent = curTouchEvent;

    _viewController.sendData(curEventMessage.writeToBuffer());
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
          child: NotificationListener<SizeChangedLayoutNotification>(
            onNotification: (notification) {
              printInDebug('onVideoWidgetResize');
              _textureSizeChanged = true;
              return false;
            },
            child: Listener(
              onPointerDown: _onTouchStart,
              onPointerMove: _onTouchMove,
              onPointerUp: _onTouchEnd,
              child: RTCVideoView(_viewController.renderer, key: _widgetKey),
            ),
          ),
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
  final Map<String, dynamic> _streamInfo = {};
  String? _token;
  String? _peerId;

  final Map<String, dynamic> _configuration = {
    // 'sdpSemantics': 'unified-plan',
  };

  RTCPeerConnection? _pc;
  io.Socket? _socket;
  RTCDataChannel? _dc;
  var _remoteRenderer = RTCVideoRenderer();

  RTCVideoRenderer get renderer => _remoteRenderer;

  Future<void> init(String uid, WebRTCFlutterViewState state) async {
    mUid = uid;
    mViewState = state;
    _printWebRTCViewSocketLog('init', null);
  }

  Future<void> connectClient(String token, String displayCode, String peerId,
      String url, Function(bool result) callback) async {
    _token = token;
    _peerId = peerId;
    if (_pc == null) await _peerConnectionConnect();
    _signalConnect(displayCode, url, callback);
  }

  Future<void> _peerConnectionConnect() async {
    await _remoteRenderer.initialize();
    if (!_configuration.containsKey('iceServers')) {
      await _getIceServers();
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
      String displayCode, String url, Function(bool result) callback) {
    _socket = io.io(
        url, //'https://signal.stage.myviewboard.cloud'
        io.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .enableForceNew()
            .enableForceNewConnection()
            .enableReconnection()
            .setReconnectionAttempts(5)
            .enableMultiplex()
            .setQuery({'token': _token, 'displayCode': displayCode})
            .build());

    _socket?.onConnect((_) async {
      _printWebRTCViewSocketLog('onConnect', _);
    });

    _socket?.on('owt-message', (data) async {
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

    _socket?.on('server-authenticated', (data) async {
      _printWebRTCViewSocketLog('server-authenticated', data);
      callback(true);
    });

    _socket?.onDisconnect((_) async {
      _printWebRTCViewSocketLog('onDisconnect', _);
      _socket?.clearListeners();
      _socket = null;
      ConnectionTimer.getInstance().stopConnectionTimeoutTimer();
    });

    _socket?.onConnectError((data) {
      _printWebRTCViewSocketLog('onConnectError', data);
      ConnectionTimer.getInstance().stopConnectionTimeoutTimer();
    });

    _socket?.onConnectTimeout(
        (data) => _printWebRTCViewSocketLog('onConnectTimeout', data));
    _socket?.onError((data) => _printWebRTCViewSocketLog('onError', data));
    _socket
        ?.onReconnect((data) => _printWebRTCViewSocketLog('onReconnect', data));
    _socket?.onReconnectError(
        (data) => _printWebRTCViewSocketLog('onReconnectError', data));
    _socket?.onReconnectFailed(
        (data) => _printWebRTCViewSocketLog('onReconnectFailed', data));

    _socket?.connect();
  }

  Future<void> disconnect({bool sendAnalytics = false}) async {
    _printWebRTCViewSocketLog('disconnect', sendAnalytics);
    if (sendAnalytics) {
      AppAnalytics().trackEventPresentStopped(presentId, presenterId);
    }

    // clear renderer and close connection
    if (_remoteRenderer.textureId != null && _remoteRenderer.renderVideo) {
      _remoteRenderer.srcObject = null;
      await _remoteRenderer.dispose();
      _remoteRenderer = RTCVideoRenderer();
    }
    if (_pc != null) {
      await _pc?.close();
      await _pc?.dispose();
      _pc = null;
    }
    if (_socket != null && _socket!.connected) {
      _socket?.close();
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
    if (renderer.srcObject != null) {
      if (renderer.srcObject!.getAudioTracks().isNotEmpty) {
        renderer.srcObject!.getAudioTracks().first.enabled = isEnable;
      }
    }
  }

  void pauseVideo() {
    if (renderer.srcObject != null) {
      if (renderer.srcObject!.getTracks().isNotEmpty) {
        renderer.srcObject!.getTracks().first.enabled = false;
      }
    }
  }

  void resumeVideo() {
    if (renderer.srcObject != null) {
      if (renderer.srcObject!.getTracks().isNotEmpty) {
        renderer.srcObject!.getTracks().first.enabled = true;
      }
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
      mViewState.setState(() {
        _remoteRenderer.srcObject = event.streams[0]; //stream;
      });
      _remoteRenderer.srcObject?.getTracks().first.onEnded = () {
        disconnect();
      };
      controlAudio(true);
    }
  }

  /// iOS, macOS did not use this event.
  void _onAddTrack(MediaStream stream, MediaStreamTrack track) {
    _printPeerConnectionLog('_onAddTrack', track);
  }

  void _onRemoveTrack(MediaStream stream, MediaStreamTrack track) {
    _printPeerConnectionLog('_onRemoveTrack', track);
    // stream
    if (_remoteRenderer.srcObject?.id == stream.id) {
      _remoteRenderer.srcObject = null;
    }
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
      'to': _peerId
    };
    _printWebRTCViewSocketLog('_send', data);
    _socket?.emit(OwtMessageType.owt_message.value, data); //'owt-message'
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

enum OwtMessageType {
  owt_message,
  signaling_message,
  track_add_ack,
  track_info,
  stream_info,
  chat_ua,
  chat_data_ack,
  chat_closed,
  invalid_type,
}

extension OwtMessageTypeExt on OwtMessageType {
  String get value {
    switch (this) {
      case OwtMessageType.owt_message:
        return 'owt-message';
      case OwtMessageType.signaling_message:
        return 'chat-signal';
      case OwtMessageType.track_add_ack:
        return 'chat-tracks-added';
      case OwtMessageType.track_info:
        return 'chat-track-sources';
      case OwtMessageType.stream_info:
        return 'chat-stream-info';
      case OwtMessageType.chat_ua:
        return 'chat-ua';
      case OwtMessageType.chat_data_ack:
        return 'chat-data-received';
      case OwtMessageType.chat_closed:
        return 'chat-closed';
      default:
        return '';
    }
  }
}
