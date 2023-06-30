
import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/control_socket.dart';
import 'package:display_flutter/model/webrtc_view_socket.dart';
import 'package:display_flutter/protoc/event.pb.dart';
import 'package:display_flutter/protoc/internal.pb.dart';
import 'package:display_flutter/screens/split_screen.dart';
import 'package:display_flutter/utility/print_in_debug.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:uuid/uuid.dart';

import 'custom_icons_icons.dart';

typedef WebRTCFlutterViewCreatedCallback = void Function(
    WebRTCFlutterViewSocket controller);

class WebRTCFlutterView extends StatefulWidget {
  const WebRTCFlutterView({Key? key, required this.callback}) : super(key: key);
  final WebRTCFlutterViewCreatedCallback callback;

  @override
  State createState() => WebRTCFlutterViewState();
}

class WebRTCFlutterViewState extends State<WebRTCFlutterView>
    with TickerProviderStateMixin {
  final WebRTCFlutterViewSocket _socket =
      WebRTCFlutterViewSocket();
  bool _showConnectionInfo = false;
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  final GlobalKey _widgetKey = GlobalKey();
  bool _textureSizeChanged = true;
  Size _textureSize = const Size(0, 0);
  Offset _textureOffset = const Offset(0, 0);
  var _remoteRenderer = RTCVideoRenderer();

  @override
  void initState() {
    super.initState();
    initSignalSocket();
    widget.callback(_socket);

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: false);
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    );
  }

  initSignalSocket() async {
    _socket.init(const Uuid().v4(), this);

    _socket.onConnect = (() async {
      await _remoteRenderer.initialize();
    });

    _socket.onAddRemoteStream = ((stream) {
     setState(() {
       _remoteRenderer.srcObject = stream;
       controlAudio(true);
     });
    });

    _socket.onRemoveRemoteStream = ((stream) {
      if (_remoteRenderer.srcObject?.id == stream.id) {
        _remoteRenderer.srcObject = null;
      }
    });

    _socket.onDisconnect = (() async {
      // clear renderer
      setState(() {
        _remoteRenderer.srcObject = null;
        _remoteRenderer.dispose();
        _remoteRenderer = RTCVideoRenderer();
      });
    });
  }

  @override
  void deactivate() {
    _remoteRenderer.dispose();
    if (_socket.socket != null && _socket.socket!.connected) {
      _socket.disconnect().then((value) {
        super.deactivate();
      });
    } else {
      _socket.socket = null;
      super.deactivate();
    }
  }

  @override
  void dispose() {
    ControlSocket().removeWebRtcController(_socket);
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

    _socket.sendData(curEventMessage.writeToBuffer());
  }

  @override
  Widget build(BuildContext context) {
    String presenterName = '';
    presenterName = _socket.presenterName;
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
              child: RTCVideoView(_remoteRenderer, key: _widgetKey),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Visibility(
            visible: _socket.presentationState ==
                    PresentationState.streaming &&
                _socket.presenterName.isNotEmpty &&
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
                          _socket.presenterName,
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

  void controlAudio(bool isEnable) {
    if (_remoteRenderer.srcObject != null) {
      if (_remoteRenderer.srcObject!.getAudioTracks().isNotEmpty) {
        _remoteRenderer.srcObject!.getAudioTracks().first.enabled = isEnable;
      }
    }
  }

  void pauseVideo() {
    if (_remoteRenderer.srcObject != null) {
      if (_remoteRenderer.srcObject!.getTracks().isNotEmpty) {
        _remoteRenderer.srcObject!.getTracks().first.enabled = false;
      }
    }
  }

  void resumeVideo() {
    if (_remoteRenderer.srcObject != null) {
      if (_remoteRenderer.srcObject!.getTracks().isNotEmpty) {
        _remoteRenderer.srcObject!.getTracks().first.enabled = true;
      }
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
