import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/model/rtc_connector.dart';
import 'package:display_flutter/protoc/event.pb.dart';
import 'package:display_flutter/protoc/internal.pb.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/utility/device_feature_adapter.dart';
import 'package:display_flutter/utility/print_in_debug.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';

import 'loading_icon.dart';

class WebRTCView extends StatefulWidget {
  const WebRTCView({super.key, required this.index});

  final int index;

  @override
  State createState() => WebRTCViewState();
}

class WebRTCViewState extends State<WebRTCView> {
  final GlobalKey _widgetKey = GlobalKey();
  bool _textureSizeChanged = true;
  Size _textureSize = const Size(0, 0);
  Offset _textureOffset = const Offset(0, 0);
  GlobalKey repaintBoundaryKey = GlobalKey();
  Widget? pauseScreenImage;
  String fpsInfo = '';
  String pairCandidateInfo = '';
  String debugOverlayText = '';

  @override
  void deactivate() {
    pauseScreenImage = null;
    super.deactivate();
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

  @override
  Widget build(BuildContext context) {
    // When create widget in Home has check connection is RTCConnector.
    RTCConnector rtcConnector =
        HybridConnectionList().getConnection<RTCConnector>(widget.index);

    rtcConnector.onPairCandidateType = (localCandidateType, remoteCandidateType) {
      if (!DeviceFeatureAdapter.ShowDebugOverlay) {
        return;
      }

      pairCandidateInfo = 'Local: $localCandidateType, Remote: $remoteCandidateType';
      setState(() {
        debugOverlayText = '$fpsInfo\n$pairCandidateInfo';
      });
    };

    rtcConnector.onFPSReport = (fps) {
      if (!DeviceFeatureAdapter.ShowDebugOverlay) {
        return;
      }

      fpsInfo = 'FPS: $fps';
      setState(() {
        debugOverlayText = '$fpsInfo\n$pairCandidateInfo';
      });
    };

    onTouchEvent(TouchEvent_TouchEventType eventType, PointerEvent event) {
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

      rtcConnector.sendRTCData(curEventMessage.writeToBuffer());
    }

    return Consumer<ChannelProvider>(builder: (_, channelProvider, __) {
      // Currently rtcConnector will call channelProvider's notifyListeners
      // to update PresentationState
      if (rtcConnector.presentationState == PresentationState.pauseStreaming &&
          pauseScreenImage == null) {
        _pauseVideo();
      } else if (rtcConnector.presentationState ==
          PresentationState.resumeStreaming) {
        _resumeVideo();
        rtcConnector.presentationState = PresentationState.streaming;
      } else if (rtcConnector.presentationState ==
          PresentationState.stopStreaming) {
        _resumeVideo();
      }
      return Stack(
        fit: StackFit.expand,
        children: <Widget>[
          pauseScreenImage ??
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
                      onPointerDown: (PointerEvent event) {
                        onTouchEvent(
                            TouchEvent_TouchEventType.TOUCH_POINT_START, event);
                      },
                      onPointerMove: (PointerEvent event) {
                        onTouchEvent(
                            TouchEvent_TouchEventType.TOUCH_POINT_MOVE, event);
                      },
                      onPointerUp: (PointerEvent event) {
                        onTouchEvent(
                            TouchEvent_TouchEventType.TOUCH_POINT_END, event);
                      },
                      child: RTCVideoView(rtcConnector.remoteRenderer!,
                          key: _widgetKey),
                    ),
                  ),
                ),
              ),
          if (rtcConnector.presentationState == PresentationState.streaming &&
              rtcConnector.senderNameWithEllipsis.isNotEmpty)
            Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints.tightFor(height: 30, width: 160),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.primaryBlackA50,
                  ),
                  child: AutoSizeText(
                    rtcConnector.senderNameWithEllipsis,
                    style: const TextStyle(fontSize: 20),
                    maxLines: 1,
                  ),
                ),
              ),
            ),
          if (rtcConnector.presentationState == PresentationState.waitForStream)
            Transform.scale(
              scale: HybridConnectionList.hybridSplitScreenCount.value > 1
                  ? 0.5
                  : 1.0,
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    if (channelProvider.isModeratorMode)
                      Column(
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
                            rtcConnector.senderNameWithEllipsis,
                            style: const TextStyle(
                              color: AppColors.primary_blue,
                              fontWeight: FontWeight.w700,
                              fontSize: 30,
                            ),
                          ),
                        ],
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
            Text(debugOverlayText,
                style: const TextStyle(
                    color: Colors.red,
                    fontSize: 30,
                )
            )
        ],
      );
    });
  }

  Future<void> _pauseVideo() async {
    // screenshot RTCView
    final boundary = repaintBoundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    final image = await boundary?.toImage();
    if (image != null) {
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final imageBytes = byteData?.buffer.asUint8List();
      if (imageBytes != null) {
        if (mounted) {
          final imageProvider = MemoryImage(imageBytes);
          // prevent flicking
          await precacheImage(imageProvider, context);
          pauseScreenImage = Image(image: imageProvider);
        }
      }
    }
    setState(() {});
  }

  void _resumeVideo() {
    pauseScreenImage = null;
  }
}
