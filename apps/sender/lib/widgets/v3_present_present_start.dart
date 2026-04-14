import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:android_window/main.dart' as android_window;
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:display_cast_flutter/annotation/annotation_model.dart';
import 'package:display_cast_flutter/annotation/window_utility.dart';
import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:display_cast_flutter/utilities/channel_util.dart';
import 'package:display_cast_flutter/utilities/webrtc_helper.dart';
import 'package:display_cast_flutter/utilities/webrtc_util.dart';
import 'package:display_cast_flutter/widgets/V3_focus.dart';
import 'package:display_cast_flutter/widgets/toast.dart';
import 'package:display_cast_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:display_cast_flutter/widgets/v3_present_timer.dart';
import 'package:display_cast_flutter/widgets/v3_touch_back_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart';

class V3PresentPresentStart extends StatefulWidget {
  const V3PresentPresentStart({super.key, required this.isModeratorMode});

  final bool isModeratorMode;

  @override
  State<StatefulWidget> createState() => _V3PresentPresentStartState();
}

class _V3PresentPresentStartState extends State<V3PresentPresentStart>
    with WindowListener {
  static const MethodChannel _channel =
      MethodChannel('com.viewsonic.display.cast/system_ui_insets');
  final GlobalKey pauseButtonKey = GlobalKey(); // 添加用于暂停按钮的GlobalKey
  final GlobalKey stopButtonKey = GlobalKey(); // 添加用于暂停按钮的GlobalKey

  bool isAnnotationImplemented = false;
  bool annotationOn = false;
  bool needRelaunchBroadcastUploadExtension = false;

  StreamSubscription? _broadcastUploadExtensionResumedSubscription;
  StreamSubscription? _broadcastUploadExtensionClosedSubscription;
  Timer? _annotationCheckTimer;

  String debugOverlayText = '';

  void sendReconnectStateToast(
      BuildContext context, ChannelReconnectState state) {
    Toast.makeFeatureReconnectToast(
        state,
        state == ChannelReconnectState.reconnecting
            ? S.of(context).main_feature_reconnecting_toast
            : S.of(context).main_feature_reconnect_fail_toast);
  }

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    if (!kIsWeb && (Platform.isWindows || Platform.isMacOS)) {
      // 用來判斷視窗被縮小或放大
      // 啟動定時器，每秒檢查註釋窗口狀態
      _startAnnotationCheckTimer();
    }
    super.initState();
    if (WebRTC.platformIsIOS) _initializeBroadcastUploadExtensionObserver();
    if (!kIsWeb && Platform.isAndroid) {
      unawaited(_ensureAndroidStealthWindow());
    }

    if (!kIsWeb && !Platform.isMacOS) {
      windowManager.addListener(this); // 監聽視窗事件
    }
  }

  void _initializeBroadcastUploadExtensionObserver() {
    _broadcastUploadExtensionResumedSubscription =
        BroadcastUploadExtensionObserver
            .instance.onBroadcastUploadExtensionResumed.stream
            .listen((message) {
      needRelaunchBroadcastUploadExtension = false;
      // Update state
      presentingState.value = !presentingState.value;
    });
    _broadcastUploadExtensionClosedSubscription =
        BroadcastUploadExtensionObserver
            .instance.onBroadcastUploadExtensionClosed.stream
            .listen((message) {
      presentingState.value = false;
      needRelaunchBroadcastUploadExtension = true;
    });
  }

  void _startAnnotationCheckTimer() {
    _annotationCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      DesktopMultiWindow.getAllSubWindowIds().then((list) {
        if (annotationOn != list.isNotEmpty) {
          if (mounted) {
            setState(() {
              annotationOn = list.isNotEmpty;
            });
          }
        }
      });
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    AnnotationModel.closeAnnotation();
    _broadcastUploadExtensionResumedSubscription?.cancel();
    _broadcastUploadExtensionClosedSubscription?.cancel();
    _annotationCheckTimer?.cancel();
    if (!kIsWeb && !Platform.isMacOS) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ChannelProvider channelProvider =
        Provider.of<ChannelProvider>(context, listen: false);

    final webrtcHelper = context.read<WebRTCHelper>();

    AnnotationModel annotationModel = context.read<AnnotationModel>();
    if (kIsWeb) {
      isAnnotationImplemented = false;
    } else if (annotationModel.presentSourceType == SourceType.Screen) {
      isAnnotationImplemented = true;
    } else if (Platform.isAndroid) {
      isAnnotationImplemented = true;
    }

    setDebugText(webrtcHelper);

    return Container(
      color: context.tokens.color.vsdswColorNeutral,
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          LayoutBuilder(builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (kIsWeb) ...[
                      V3AutoHyphenatingText(
                        S.of(context).v3_main_presenting_message,
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              context.tokens.color.vsdswColorOnSurfaceInverse,
                        ),
                      ),
                      SizedBox(
                          height: context.tokens.spacing.vsdswSpacingMd.top),
                    ],
                    const V3PresentTimer(),
                    SizedBox(height: context.tokens.spacing.vsdswSpacingLg.top),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isAnnotationImplemented) ...[
                          StatefulBuilder(builder: (context, setState) {
                            return AnnotationButton(
                              isOn: annotationOn,
                              onClick: () async {
                                // desktop annotation在didChangeAppLifecycleState去檢查是否開啟
                                if (Platform.isAndroid) {
                                  if (!context.mounted) {
                                    return;
                                  }

                                  setState(() {
                                    annotationOn = !annotationOn;
                                  });
                                }
                                await Future.delayed(
                                    const Duration(milliseconds: 100));
                                await _startAnnotation(annotationModel);
                                trackEvent('click_annotation',
                                    EventCategory.annotation);
                              },
                            );
                          }),
                          Padding(
                            padding: EdgeInsets.only(
                              right: context.tokens.spacing.vsdswSpacingMd.left,
                            ),
                          ),
                        ],
                        ValueListenableBuilder(
                          valueListenable: presentingState,
                          builder:
                              (BuildContext context, value, Widget? child) {
                            return V3Focus(
                              label: !value
                                  ? S.current.v3_lbl_sharing_pause_on
                                  : S.current.v3_lbl_sharing_pause_off,
                              identifier:
                                  'v3_qa_sharing_pause_${!value ? 'on' : 'off'}',
                              button: true,
                              child: CircleAvatar(
                                key: pauseButtonKey, // 使用之前添加的 GlobalKey
                                backgroundColor: !value
                                    ? context
                                        .tokens.color.vsdswColorOnSurfaceInverse
                                    : context.tokens.color.vsdswColorSurface900,
                                radius: kIsWeb ? 24 : 28,
                                child: InkWell(
                                  onTap: () async {
                                    if (needRelaunchBroadcastUploadExtension) {
                                      unawaited(webrtcHelper
                                          .launchBroadcastUploadExtension());
                                    } else {
                                      // Toggle current state
                                      bool tempState = !presentingState.value;
                                      trackEvent(
                                          tempState
                                              ? 'click_resume'
                                              : 'click_pause',
                                          EventCategory.session);

                                      Rect? pauseBtnRec =
                                          await getBtnRect(pauseButtonKey);
                                      Rect? stopBtnRect =
                                          await getBtnRect(stopButtonKey);

                                      // Update state
                                      presentingState.value = tempState;
                                      unawaited(tempState
                                          ? channelProvider.presentResume()
                                          : channelProvider.presentPause(
                                              pauseBtnRect: pauseBtnRec,
                                              stopBtnRect: stopBtnRect));
                                    }
                                  },
                                  child: ExcludeSemantics(
                                    child: SvgPicture.asset(!value
                                        ? 'assets/images/v3_ic_sharing_pause_on.svg'
                                        : 'assets/images/v3_ic_sharing_pause_off.svg'),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            right: context.tokens.spacing.vsdswSpacingMd.left,
                          ),
                        ),
                        V3Focus(
                          label: S.current.v3_lbl_sharing_stop,
                          identifier: 'v3_qa_sharing_stop',
                          button: true,
                          child: CircleAvatar(
                            backgroundColor:
                                context.tokens.color.vsdswColorError,
                            radius: kIsWeb ? 24 : 28,
                            child: InkWell(
                              key: stopButtonKey,
                              onTap: () {
                                trackEvent('click_stop', EventCategory.session);

                                channelProvider.presentStop();
                                if (widget.isModeratorMode) {
                                  Provider.of<PresentStateProvider>(context,
                                          listen: false)
                                      .presentModeratorWaitPage();
                                } else {
                                  channelProvider.presentEnd();
                                }
                              },
                              child: ExcludeSemantics(
                                child: Icon(
                                  Icons.stop,
                                  size: kIsWeb ? 24 : 28,
                                  color: context
                                      .tokens.color.vsdswColorOnSurfaceInverse,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          if (WebRTCUtil.showDebugOverlay)
            Positioned(
              top: 30,
              left: 30,
              child: IgnorePointer(
                ignoring: true,
                // To avoid misinterpreting the hyphen (“-”), use plain text instead.
                child: Text(
                  debugOverlayText,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 28,
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 100,
            child: ValueListenableBuilder(
                valueListenable: webrtcHelper.reconnectStateNotifier,
                builder: (BuildContext context, ChannelReconnectState state,
                    Widget? child) {
                  if (state == ChannelReconnectState.reconnecting) {
                    Toast.makeFeatureReconnectToast(
                        state, S.of(context).main_webrtc_reconnecting_toast);
                  } else if (state == ChannelReconnectState.success) {
                    Toast.makeFeatureReconnectToast(state,
                        S.of(context).main_webrtc_reconnect_success_toast);
                    webrtcHelper.setReconnectState(ChannelReconnectState.idle);
                  } else if (state == ChannelReconnectState.fail) {
                    Toast.makeFeatureReconnectToast(
                        state, S.of(context).main_webrtc_reconnect_fail_toast);
                    webrtcHelper.setReconnectState(ChannelReconnectState.idle);
                  }
                  return Container();
                }),
          ),
          // [USER STORY 74502] Due to Web RTC QoS Setting issue, this feature is disabled temporarily.
          // if (!kIsWeb)
          // Positioned(
          //   left: 24,
          //   bottom: 24,
          //   child: CircleAvatar(
          //     backgroundColor: context.tokens.color.vsdswColorSurface900,
          //     radius: 24,
          //     child: IconButton(
          //       icon: SvgPicture.asset('assets/images/v3_ic_options.svg'),
          //       onPressed: () {
          //         _showOptionsMenuDialog(context);
          //       },
          //     ),
          //   ),
          // ),
          if (webrtcHelper.showTouchBack())
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: V3TouchBackButton(),
              ),
            ),
        ],
      ),
    );
  }

  Future<Rect?> getBtnRect(GlobalKey widgetKey) async {
    if (kIsWeb) return null;

    Rect? widgetRect;
    final RenderBox? renderBox =
        widgetKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox != null) {
      Offset widgetPositionInApp = renderBox.localToGlobal(Offset.zero);

      if (Platform.isWindows || Platform.isMacOS) {
        final window = await getCurrentScreen();
        double windowBar = 0;

        if (window != null) {
          if (Platform.isMacOS) {
            windowBar = window.visibleFrame.top - window.frame.top;
          } else {
            windowBar = window.frame.bottom - window.visibleFrame.bottom;
          }
        }

        Offset windowPosition = Offset.zero;
        if (Platform.isMacOS) {
          windowPosition = await WindowUtility.getWindowPosition();
        } else {
          final Rect windowBounds = await windowManager.getBounds();
          windowPosition = Offset(windowBounds.left, windowBounds.top);
        }

        Offset widgetPositionInScreen = widgetPositionInApp + windowPosition;
        widgetRect = Rect.fromLTWH(
          widgetPositionInScreen.dx * (window?.scaleFactor ?? 1),
          widgetPositionInScreen.dy * (window?.scaleFactor ?? 1),
          renderBox.size.width,
          renderBox.size.height + windowBar / 2,
        );
      } else if (Platform.isAndroid) {
        double insetLeft =
            await _channel.invokeMethod('getNavigationBarLeftInset');
        insetLeft /=
            PlatformDispatcher.instance.displays.first.devicePixelRatio;
        final Offset offsetNavigation = Offset(insetLeft, 0);
        Offset widgetPositionInScreen = widgetPositionInApp + offsetNavigation;
        widgetRect = widgetPositionInScreen & renderBox.size;
      }
    }
    return widgetRect;
  }

  void setDebugText(WebRTCHelper webRTCHelper) {
    webRTCHelper.webRTCConnector?.onVideoStatsReport = (stats) {
      if (!WebRTCUtil.showDebugOverlay) {
        _clearDebugOverlay();
        return;
      }

      final fpsInfo = 'FPS(Sent,Encoded,Captured): '
          '${stats.framesSentPerSecond?.toStringAsFixed(0)},'
          '${stats.framesEncodedPerSecond?.toStringAsFixed(0)},'
          '${stats.mediaSourceFramesPerSecond?.toStringAsFixed(0)}';

      final targetBitrateKbps = stats.targetBitrate != null
          ? (stats.targetBitrate! / 1000).toStringAsFixed(0)
          : null;

      final availableOutgoingBitrateKbps =
          stats.availableOutgoingBitrate != null
              ? (stats.availableOutgoingBitrate! / 1000).toStringAsFixed(0)
              : null;

      final rttMs = stats.currentRoundTripTime != null
          ? (stats.currentRoundTripTime! * 1000).toStringAsFixed(0)
          : null;

      final bytesSentPerSecondKbps = stats.bytesSentPerSecond != null
          ? (stats.bytesSentPerSecond! * 8 / 1000).toStringAsFixed(0)
          : null;

      final videoInfo = 'Res ${stats.frameWidth}x${stats.frameHeight} '
          'Bitrate: $bytesSentPerSecondKbps Kbps\n'
          '$fpsInfo\n'
          'TargetBitrate: $targetBitrateKbps Kbps\n'
          'AvailableOutgoingBitrate: $availableOutgoingBitrateKbps Kbps\n'
          'QualityLimitationReason: ${stats.qualityLimitationReason}\n'
          'RTT: $rttMs ms pliCount: ${stats.pliCount} nackCount: ${stats.nackCount}\n'
          'PacketSendDelay: ${stats.packetSendDelayAvgMs?.toStringAsFixed(0)} ms\n'
          'EncodeTime: ${stats.encodeTimeAvgMs?.toStringAsFixed(2)} ms\n'
          'Encoder: ${stats.encoderImplementation}\n'
          'ContentType: ${stats.contentType}\n';

      if (!mounted) return;
      setState(() {
        debugOverlayText = videoInfo;
      });
    };
  }

  void _clearDebugOverlay() {
    if (debugOverlayText != '') {
      if (!mounted) return;
      setState(() {
        debugOverlayText = '';
      });
    }
  }

  Future<void> _ensureAndroidStealthWindow() async {
    if (!Platform.isAndroid || kIsWeb || annotationOn) return;
    if (!await Permission.systemAlertWindow.isGranted) return;
    if (annotationOn) return;
    await _setAndroidWindowMode(annotation: false);
  }

  Future<void> _setAndroidWindowMode({required bool annotation}) async {
    if (!Platform.isAndroid || kIsWeb) return;

    final isRunning = await android_window.isRunning();
    final Size targetSize = annotation
        ? WidgetsBinding.instance.platformDispatcher.views.first.physicalSize
        : const Size(1, 1);

    if (!isRunning) {
      android_window.open(
        size: Size(targetSize.width, targetSize.height),
        position: const Offset(0, 0),
      );
      await Future.delayed(const Duration(milliseconds: 100));
    } else {
      await android_window.resize(
        targetSize.width.toInt(),
        targetSize.height.toInt(),
      );
      await android_window.setPosition(0, 0);
    }

    await android_window.post('setMode', annotation ? 'annotation' : 'stealth');
  }

  Future<void> _startAnnotation(AnnotationModel annotationModel) async {
    if (Platform.isWindows || Platform.isMacOS) {
      final list = await DesktopMultiWindow.getAllSubWindowIds();
      if (list.isEmpty) {
        await WindowUtility.minimizeWindow();
        await Future.delayed(const Duration(milliseconds: 50));
        final window = await DesktopMultiWindow.createFullscreenWindow(
            jsonEncode({'mode': 'desktop_canvas'}),
            annotationModel.screenIndex);
        await window.show();
      } else {
        await WindowUtility.minimizeWindow();
        await Future.delayed(const Duration(milliseconds: 50));
        await WindowController.fromWindowId(list.first).show();
      }
    } else if (Platform.isAndroid) {
      if (!annotationOn) {
        await _ensureAndroidStealthWindow();
        return;
      }

      if (!await Permission.systemAlertWindow.isGranted) {
        annotationOn = false;
        await Permission.systemAlertWindow.request();
        return;
      }

      await _setAndroidWindowMode(annotation: true);
      await WindowUtility.minimizeWindow();
    }
  }
}

class AnnotationButton extends StatelessWidget {
  const AnnotationButton(
      {super.key, required this.onClick, required this.isOn});

  final VoidCallback onClick;
  final bool isOn;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = !Platform.isAndroid
        ? context.tokens.color.vsdswColorSurface900
        : isOn
            ? context.tokens.color.vsdswColorOnSurfaceInverse
            : context.tokens.color.vsdswColorSurface900;

    final iconPath = isOn
        ? 'assets/images/${Platform.isAndroid ? 'v3_ic_annotation_on' : 'v3_ic_annotation_expand'}.svg'
        : 'assets/images/v3_ic_sharing_pen.svg';
    return V3Focus(
      label: isOn
          ? S.current.v3_lbl_sharing_annotation_start
          : S.current.v3_lbl_sharing_annotation_stop,
      identifier: 'v3_qa_enable_sharing_annotation',
      button: true,
      child: CircleAvatar(
        backgroundColor: backgroundColor,
        radius: 28,
        child: InkWell(
          onTap: onClick,
          child: ExcludeSemantics(
            child: SvgPicture.asset(iconPath),
          ),
        ),
      ),
    );
  }
}
