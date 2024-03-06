
import 'dart:typed_data';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/model/rtc_connector.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/screens/split_screen.dart';
import 'package:display_flutter/utility/print_in_debug.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:display_flutter/protoc/event.pb.dart';
import 'package:display_flutter/protoc/internal.pb.dart';
import 'package:provider/provider.dart';

import 'loading_icon.dart';

class WebRTCView extends StatefulWidget {
  const WebRTCView({super.key, required this.index});

  final int index;

  @override
  State createState() => WebRTCViewState();
}

class WebRTCViewState extends State<WebRTCView> {
  bool _showConnectionInfo = false;
  final GlobalKey _widgetKey = GlobalKey();
  bool _textureSizeChanged = true;
  Size _textureSize = const Size(0, 0);
  Offset _textureOffset = const Offset(0, 0);
  RTCConnector? _rtcConnector;
  GlobalKey repaintBoundaryKey = GlobalKey();
  GlobalKey<PauseScreenImageState> pauseScreenImageKey = GlobalKey();
  late ChannelProvider channelProvider;
  Widget? pauseScreenImage;

  @override
  void initState() {
    super.initState();
  }

  @override
  void deactivate() {
    pauseScreenImageKey.currentState?.clearImage();
    _rtcConnector = null;
    super.deactivate();
  }

  @override
  void dispose() {
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

    _rtcConnector?.sendRTCData(curEventMessage.writeToBuffer());
  }

  @override
  Widget build(BuildContext context) {
    channelProvider = Provider.of<ChannelProvider>(context);
    var rtcConnectorMap = HybridConnectionList().getRtcConnectorAndMirrorMap(ConnectionType.rtcConnector);
    if (rtcConnectorMap[widget.index] != null) {
      _rtcConnector = rtcConnectorMap[widget.index];
      if (_rtcConnector?.presentationState == PresentationState.pauseStreaming && pauseScreenImage == null) {
        pauseVideo();
      } else if (_rtcConnector?.presentationState == PresentationState.resumeStreaming) {
        resumeVideo();
        _rtcConnector?.presentationState = PresentationState.streaming;
      }
    }

    String presenterName = _rtcConnector?.senderName ?? '';
    if (presenterName.length > 10) {
      presenterName = '${presenterName.substring(0, 10)}..';
    }
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        RepaintBoundary(
          key: repaintBoundaryKey,
          child: Focus(
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
                child: _rtcConnector != null? RTCVideoView(_rtcConnector!.remoteRenderer!, key: _widgetKey) : const SizedBox(),
              ),
            ),
          ),
        ),
        if (_rtcConnector != null && _rtcConnector?.presentationState == PresentationState.pauseStreaming)
          pauseScreenImage = pauseScreenImage ?? PauseScreenImage(key: pauseScreenImageKey),
        Align(
          alignment: Alignment.topCenter,
          child: Visibility(
            visible: _rtcConnector?.presentationState == PresentationState.streaming &&
                presenterName.isNotEmpty,
            child: ConstrainedBox(
              constraints: const BoxConstraints.tightFor(height: 30,width: 160),
              child: Container(
                padding: const EdgeInsets.all(5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.primaryBlackA50,
                ),
                child: AutoSizeText(
                  presenterName,
                  style: const TextStyle(fontSize: 20),
                  maxLines: 1,
                ),
              ),
            ),
          ),
        ),
        if (_rtcConnector != null && _rtcConnector?.presentationState == PresentationState.waitForStream)
          Transform.scale(
            scale: SplitScreen.mapSplitScreen.value[keySplitScreenCount] > 1
                ? 0.5
                : 1.0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Visibility(
                    visible: ChannelProvider.isModeratorMode,
                    child: Column(
                      children: <Widget>[
                        Text(
                          S.of(context).main_wait_up_next,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 25,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          presenterName,
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
                  const SizedBox(
                    width: 32,
                    height: 32,
                    child: LoadingIcon(),
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
      ],
    );
  }

  bool get showConnectionInfo => _showConnectionInfo;

  set showConnectionInfo(bool value) {
    setState(() {
      _showConnectionInfo = value;
    });
  }

  Future<void> pauseVideo() async {
    // screenshot RTCView
    final boundary = repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    final image = await boundary?.toImage();
    final byteData = await image?.toByteData(format: ImageByteFormat.png);
    final imageBytes = byteData?.buffer.asUint8List();
    pauseScreenImageKey.currentState?.refresh(imageBytes);
    HybridConnectionList().updateAudioEnableStateByIndex(widget.index, false);
  }

  void resumeVideo() {
    pauseScreenImageKey.currentState?.remove();
    pauseScreenImage = null;
    HybridConnectionList().updateAudioEnableStateByIndex(widget.index, true);
  }
}

class PauseScreenImage extends StatefulWidget {
  const PauseScreenImage({super.key});

  @override
  PauseScreenImageState createState() => PauseScreenImageState();
}

class PauseScreenImageState extends State<PauseScreenImage> {
  Uint8List? _capturedImage;

  // 一个用于刷新小部件的方法
  void refresh(Uint8List? imageBytes) {
    if (mounted) {
      setState(() {
        _capturedImage = imageBytes;
      });
    }
  }

  void remove() {
    if (mounted) {
      setState(() {
        _capturedImage = null;
      });
    }
  }

  void clearImage() {
    _capturedImage = null;
  }

  @override
  Widget build(BuildContext context) {
    return _capturedImage != null? Image.memory(_capturedImage!, fit:BoxFit.fill): const SizedBox();
  }
}