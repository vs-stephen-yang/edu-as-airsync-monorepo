import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/model/rtc_connector.dart';
import 'package:display_flutter/protoc/event.pb.dart';
import 'package:display_flutter/protoc/internal.pb.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/utility/channel_util.dart';
import 'package:display_flutter/utility/device_feature_adapter.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:display_flutter/utility/v3_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class V3WebrtcView extends StatefulWidget {
  const V3WebrtcView(
      {super.key, required this.rtcConnector, required this.index, required this.fullWidth, required this.fullHeight, required this.displaySmartScalingEnabled});

  final RTCConnector rtcConnector;
  final int index;
  final double fullWidth;
  final double fullHeight;
  final bool displaySmartScalingEnabled;

  @override
  State<StatefulWidget> createState() => _V3WebrtcViewState();
}

class _V3WebrtcViewState extends State<V3WebrtcView> {
  final GlobalKey _widgetKey = GlobalKey();
  bool _textureSizeChanged = true;
  Size _textureSize = const Size(0, 0);
  Offset _textureOffset = const Offset(0, 0);
  GlobalKey repaintBoundaryKey = GlobalKey();
  Widget? pauseScreenImage;
  String videoInfo = '';
  String pairCandidateInfo = '';
  String debugOverlayText = '';

  @override
  void didUpdateWidget(V3WebrtcView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // List.generate will reuse the widget, need clear pauseScreenImage here.
    if (oldWidget.rtcConnector.clientId != widget.rtcConnector.clientId) {
      pauseScreenImage = null;
    }
  }

  @override
  void deactivate() {
    pauseScreenImage = null;
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    widget.rtcConnector.onPairCandidateType =
        (localCandidateType, remoteCandidateType) {
      if (!DeviceFeatureAdapter.showDebugOverlay) {
        _clearDebugOverlay();
        return;
      }

      pairCandidateInfo =
          'Local: $localCandidateType, Remote: $remoteCandidateType';
      setState(() {
        debugOverlayText = '$videoInfo\n$pairCandidateInfo';
      });
    };

    widget.rtcConnector.onVideoStatsReport = (stats) {
      if (!DeviceFeatureAdapter.showDebugOverlay) {
        _clearDebugOverlay();
        return;
      }

      final fpsInfo = 'FPS: '
          '${stats.framesPerSecond?.toStringAsFixed(0)},'
          '${stats.framesDecodedPerSecond},'
          '${stats.framesReceivedPerSecond} '
          'Dropped: ${stats.framesDroppedPerSecond}';

      final bytesPerSecond = stats.bytesPerSecond;
      final bitrateKbps =
          bytesPerSecond != null ? bytesPerSecond * 8 / 1024 : null;

      final decodeTimeSec = stats.decodeTime?.toStringAsFixed(3);
      final jitterSec = stats.jitterBufferDelay?.toStringAsFixed(3);

      videoInfo = 'Res ${stats.frameWidth}x${stats.frameHeight} '
          'Bitrate: ${bitrateKbps?.toStringAsFixed(0)} Kbps\n'
          '$fpsInfo\n'
          'JB: $jitterSec s PacketLost: ${stats.packetsLost}\n'
          'Decode: $decodeTimeSec s\n'
          '${stats.decoderName}';

      setState(() {
        debugOverlayText = '$videoInfo\n$pairCandidateInfo';
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

      widget.rtcConnector.sendTouchback(curEventMessage.writeToBuffer());
    }

    return Consumer<ChannelProvider>(builder: (_, channelProvider, __) {
      // Currently rtcConnector will call channelProvider's notifyListeners
      // to update PresentationState
      if (widget.rtcConnector.presentationState ==
              PresentationState.pauseStreaming &&
          pauseScreenImage == null) {
        _pauseVideo();
      } else if (widget.rtcConnector.presentationState ==
          PresentationState.resumeStreaming) {
        _resumeVideo();
        widget.rtcConnector.presentationState = PresentationState.streaming;
      } else if (widget.rtcConnector.presentationState ==
          PresentationState.stopStreaming) {
        _resumeVideo();
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
                  log.info('onVideoWidgetResize');
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
                  child: pauseScreenImage ??
                      RTCVideoView(widget.rtcConnector.remoteRenderer!,
                          key: _widgetKey,
                          fullWidth: widget.fullWidth,
                          fullHeight: widget.fullHeight,
                          displaySmartScalingEnabled: widget.displaySmartScalingEnabled),
                ),
              ),
            ),
          ),
          if (widget.rtcConnector.presentationState ==
                  PresentationState.streaming &&
              (widget.rtcConnector.senderName ?? '').isNotEmpty) ...[
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 4,
                    color: context.tokens.color.vsdslColorSurface900,
                  ),
                ),
              ),
            ),
            IgnorePointer(
              child: Align(
                alignment: Alignment.topCenter,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 24,
                      padding: const EdgeInsets.only(
                          left: 8, top: 1, right: 8, bottom: 5),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                        color: context.tokens.color.vsdslColorSurface900,
                      ),
                      child: AutoSizeText(
                        widget.rtcConnector.senderName ?? '',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: context
                                .tokens.color.vsdslColorOnSurfaceInverse),
                        maxLines: 1,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
          if (widget.rtcConnector.presentationState ==
              PresentationState.waitForStream)
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
                    if (ChannelProvider.isModeratorMode)
                      Column(
                        children: <Widget>[
                          AutoSizeText(
                            S.of(context).v3_waiting_up_next,
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w600,
                              color: context.tokens.color.vsdslColorPrimary,
                            ),
                          ),
                          const SizedBox(
                            height: 13,
                          ),
                          AutoSizeText(
                            widget.rtcConnector.senderName ?? '',
                            style: TextStyle(
                              fontSize: 45,
                              fontWeight: FontWeight.w600,
                              color: context
                                  .tokens.color.vsdslColorOnSurfaceInverse,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(
                      height: 20,
                    ),
                    AutoSizeText(
                      S.of(context).v3_waiting_desc,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: context.tokens.color.vsdslColorOnSurfaceVariant,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: 76,
                      height: 76,
                      child: Lottie.asset(
                          'assets/lottie_files/vsdsl-spinner-sty1.json'),
                    ),
                  ],
                ),
              ),
            ),
          IgnorePointer(
            ignoring: true,
            child: AutoSizeText(
              debugOverlayText,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 30,
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: widget.rtcConnector.reconnectChannelStateNotifier,
            builder: (context, ReconnectState reconnectState, child) {
              if (widget.rtcConnector.clickButtonWhenReconnect) {
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  if (widget.rtcConnector.reconnectChannelState ==
                      ReconnectState.success) {
                    widget.rtcConnector.clickButtonWhenReconnect = false;
                    V3Toast().makeSplitScreenReconnectToast(
                        context,
                        S.of(context).main_feature_reconnect_success_toast,
                        widget.index,
                        isWebRTC: false,
                        state: ReconnectState.success);
                    widget.rtcConnector.reconnectChannelState =
                        ReconnectState.idle;
                  } else if (widget.rtcConnector.reconnectChannelState ==
                      ReconnectState.fail) {
                    widget.rtcConnector.clickButtonWhenReconnect = false;
                    V3Toast().makeSplitScreenReconnectToast(
                        context,
                        S.of(context).main_feature_reconnect_fail_toast,
                        widget.index,
                        isWebRTC: false,
                        state: ReconnectState.fail);
                    widget.rtcConnector.reconnectChannelState =
                        ReconnectState.idle;
                  }
                });
              }
              return Container();
            },
          ),
          ValueListenableBuilder(
            valueListenable: widget.rtcConnector.reconnectRtcStateNotifier,
            builder: (context, ReconnectState reconnectState, child) {
              String message = S.of(context).main_webrtc_reconnecting_toast;
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                if (widget.rtcConnector.reconnectRtcState ==
                    ReconnectState.reconnecting) {
                  V3Toast().makeSplitScreenReconnectToast(
                      context, message, widget.index);
                } else if (widget.rtcConnector.reconnectRtcState ==
                    ReconnectState.success) {
                  message = S.of(context).main_webrtc_reconnect_success_toast;
                  V3Toast().makeSplitScreenReconnectToast(
                      context, message, widget.index);
                  widget.rtcConnector.reconnectRtcState = ReconnectState.idle;
                } else if (widget.rtcConnector.reconnectRtcState ==
                    ReconnectState.fail) {
                  message = S.of(context).main_webrtc_reconnect_fail_toast;
                  V3Toast().makeSplitScreenReconnectToast(
                      context, message, widget.index);
                  widget.rtcConnector.reconnectRtcState = ReconnectState.idle;
                }
              });

              return Container();
            },
          ),
        ],
      );
    });
  }

  void _clearDebugOverlay() {
    if (debugOverlayText != '') {
      setState(() {
        debugOverlayText = '';
      });
    }
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
      log.warning('texture widget not found');
      return;
    } else {
      final RenderBox renderBox =
          textureElement!.findRenderObject() as RenderBox;
      bool isSameDirection = (widget.fullWidth > widget.fullHeight && renderBox.size.width > renderBox.size.height ) || (widget.fullHeight > widget.fullWidth && renderBox.size.height > renderBox.size.width );
      _textureSize = (widget.displaySmartScalingEnabled && isSameDirection)? Size(widget.fullWidth, widget.fullHeight) : renderBox.size;
      _textureOffset = renderBox.localToGlobal(Offset.zero);
      log.info(
          'texture widget size: (${_textureSize.width.toStringAsFixed(2)}, ${_textureSize.height.toStringAsFixed(2)}), offset: (${_textureOffset.dx.toStringAsFixed(2)}, ${_textureOffset.dy.toStringAsFixed(2)})');
      _textureSizeChanged = false;
    }
  }

  Future<void> _pauseVideo() async {
    // Add delay before taking screenshot
    await Future.delayed(const Duration(milliseconds: 300));

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
