import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:android_window/main.dart' as android_window;
import 'package:auto_size_text/auto_size_text.dart';
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
import 'package:display_cast_flutter/widgets/touch_back_button.dart';
import 'package:display_cast_flutter/widgets/v3_options_menu.dart';
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
    with WidgetsBindingObserver, WindowListener {
  final GlobalKey<TouchBackButtonState> touchBtnKey = GlobalKey();
  final GlobalKey pauseButtonKey = GlobalKey(); // 添加用于暂停按钮的GlobalKey
  final GlobalKey stopButtonKey = GlobalKey(); // 添加用于暂停按钮的GlobalKey

  bool isAnnotationImplemented = false;
  bool annotationOn = false;
  bool needRelaunchBroadcastUploadExtension = false;

  StreamSubscription? _broadcastUploadExtensionResumedSubscription;
  StreamSubscription? _broadcastUploadExtensionClosedSubscription;

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
      WidgetsBinding.instance.addObserver(this);
    }
    super.initState();
    if (WebRTC.platformIsIOS) _initializeBroadcastUploadExtensionObserver();

    windowManager.addListener(this); // 監聽視窗事件
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

  @override
  didChangeAppLifecycleState(AppLifecycleState state) {
    DesktopMultiWindow.getAllSubWindowIds().then((list) {
      if (annotationOn != list.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              annotationOn = list.isNotEmpty;
            });
          }
        });
      }
    });
    super.didChangeAppLifecycleState(state);
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
    if (!kIsWeb && (Platform.isWindows || Platform.isMacOS)) {
      WidgetsBinding.instance.removeObserver(this);
    }
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Future<void> onWindowMove() async {
    // 當視窗移動時，可以強制刷新位置
  }

  @override
  Widget build(BuildContext context) {
    ChannelProvider channelProvider =
        Provider.of<ChannelProvider>(context, listen: false);
    AnnotationModel annotationModel = context.read<AnnotationModel>();
    if (kIsWeb) {
      isAnnotationImplemented = false;
    } else if (annotationModel.presentSourceType == SourceType.Screen) {
      isAnnotationImplemented = true;
    } else if (Platform.isAndroid) {
      isAnnotationImplemented = true;
    }

    setDebugText();

    return Container(
      color: context.tokens.color.vsdswColorNeutral,
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (kIsWeb) ...[
                AutoSizeText(
                  S.of(context).v3_main_presenting_message,
                  style: TextStyle(
                    fontSize: 16,
                    color: context.tokens.color.vsdswColorOnSurfaceInverse,
                  ),
                ),
                SizedBox(height: context.tokens.spacing.vsdswSpacingMd.top),
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
                            setState(() {
                              annotationOn = !annotationOn;
                            });
                          }
                          await Future.delayed(
                              const Duration(milliseconds: 100));
                          await _startAnnotation(annotationModel);
                          trackEvent(
                              'click_annotation', EventCategory.annotation);
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
                    builder: (BuildContext context, value, Widget? child) {
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
                              ? context.tokens.color.vsdswColorOnSurfaceInverse
                              : context.tokens.color.vsdswColorSurface900,
                          radius: kIsWeb ? 24 : 28,
                          child: InkWell(
                            onTap: () async {
                              if (needRelaunchBroadcastUploadExtension) {
                                unawaited(WebRTCHelper()
                                    .launchBroadcastUploadExtension());
                              } else {
                                // Toggle current state
                                bool tempState = !presentingState.value;
                                trackEvent(
                                    tempState ? 'click_resume' : 'click_pause',
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
                      backgroundColor: context.tokens.color.vsdswColorError,
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
                            color:
                                context.tokens.color.vsdswColorOnSurfaceInverse,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (WebRTCUtil.showDebugOverlay)
            Positioned(
              top: 30,
              left: 30,
              child: IgnorePointer(
                ignoring: true,
                child: AutoSizeText(
                  debugOverlayText,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 30,
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 100,
            child: ValueListenableBuilder(
                valueListenable: WebRTCHelper().reconnectStateNotifier,
                builder: (BuildContext context, ChannelReconnectState state,
                    Widget? child) {
                  if (state == ChannelReconnectState.reconnecting) {
                    Toast.makeFeatureReconnectToast(
                        state, S.of(context).main_webrtc_reconnecting_toast);
                  } else if (state == ChannelReconnectState.success) {
                    Toast.makeFeatureReconnectToast(state,
                        S.of(context).main_webrtc_reconnect_success_toast);
                    WebRTCHelper()
                        .setReconnectState(ChannelReconnectState.idle);
                  } else if (state == ChannelReconnectState.fail) {
                    Toast.makeFeatureReconnectToast(
                        state, S.of(context).main_webrtc_reconnect_fail_toast);
                    WebRTCHelper()
                        .setReconnectState(ChannelReconnectState.idle);
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
          // todo: move quality to setting menu and touch back to below item!!
          if (WebRTCHelper().showTouchBack())
            const Positioned(bottom: 8, child: V3TouchBackButton()),
        ],
      ),
    );
  }

  Future<Rect?> getBtnRect(GlobalKey widgetKey) async {
    Offset? widgetPositionInScreen, widgetPositionInApp;
    double windowBar = 0;
    Rect? widgetRect;

    final RenderBox? renderBox =
        widgetKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox != null) {
      widgetPositionInApp = renderBox.localToGlobal(Offset.zero);

      if (!kIsWeb && (Platform.isWindows || Platform.isMacOS)) {
        final window = await getCurrentScreen();

        if (window != null) {
          if (Platform.isMacOS) {
            windowBar = window.visibleFrame.top - window.frame.top;
          } else {
            windowBar = window.frame.bottom - window.visibleFrame.bottom;
          }
        }

        final Rect windowBounds = await windowManager.getBounds();
        final Offset windowPosition =
            Offset(windowBounds.left, windowBounds.top);

        widgetPositionInScreen = widgetPositionInApp + windowPosition;
        widgetRect = Rect.fromLTWH(
          widgetPositionInScreen.dx * (window?.scaleFactor ?? 1),
          widgetPositionInScreen.dy * (window?.scaleFactor ?? 1),
          renderBox.size.width,
          renderBox.size.height + windowBar / 2,
        );
      }
    }
    return widgetRect;
  }

  void setDebugText() {
    WebRTCHelper().webRTCConnector?.onVideoStatsReport = (stats) {
      if (!WebRTCUtil.showDebugOverlay) {
        _clearDebugOverlay();
        return;
      }

      final fpsInfo = 'FPS: '
          '${stats.framesPerSecond?.toStringAsFixed(0)}';

      final videoInfo = 'Res ${stats.frameWidth}x${stats.frameHeight} '
          '$fpsInfo\n'
          'TargetBitrate: ${stats.targetBitrate?.toStringAsFixed(0)}\n'
          'ContentType: ${stats.contentType}\n'
          'QualityLimitationReason: ${stats.qualityLimitationReason}\n'
          'pliCount: ${stats.pliCount}\n'
          'Encoder: ${stats.encoderImplementation}\n'
          'EncodeTime: ${stats.encodeTime?.toStringAsFixed(2)}\n';

      setState(() {
        debugOverlayText = videoInfo;
      });
    };
  }

  void _clearDebugOverlay() {
    if (debugOverlayText != '') {
      setState(() {
        debugOverlayText = '';
      });
    }
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
      if (!await android_window.isRunning()) {
        if (await Permission.systemAlertWindow.isGranted) {
          final Size physicalSize = WidgetsBinding
              .instance.platformDispatcher.views.first.physicalSize;
          android_window.open(
            size: Size(physicalSize.width, physicalSize.height),
            position: const Offset(0, 0),
          );
          await Future.delayed(const Duration(milliseconds: 100));
          await WindowUtility.minimizeWindow();
        } else {
          annotationOn = false;
          await Permission.systemAlertWindow.request();
          return;
        }
      } else {
        AnnotationModel.closeAnnotation();
      }
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
      label: S.current.v3_lbl_sharing_stop,
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
