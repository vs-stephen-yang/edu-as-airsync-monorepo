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
import 'package:display_cast_flutter/providers/v3_demo_provider.dart';
import 'package:display_cast_flutter/widgets/touch_back_button.dart';
import 'package:display_cast_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:display_cast_flutter/widgets/v3_present_timer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class V3PresentPresentStartDemo extends StatefulWidget {
  const V3PresentPresentStartDemo({super.key});

  @override
  State<StatefulWidget> createState() => _V3PresentPresentStartDemoState();
}

class _V3PresentPresentStartDemoState extends State<V3PresentPresentStartDemo> {
  final GlobalKey<TouchBackButtonState> touchBtnKey = GlobalKey();

  bool isAnnotationImplemented = false;
  bool annotationOn = false;
  bool needRelaunchBroadcastUploadExtension = false;

  StreamSubscription? _broadcastUploadExtensionResumedSubscription;
  StreamSubscription? _broadcastUploadExtensionClosedSubscription;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();
    if (WebRTC.platformIsIOS) _initializeBroadcastUploadExtensionObserver();
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
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _broadcastUploadExtensionResumedSubscription?.cancel();
    _broadcastUploadExtensionClosedSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    V3DemoProvider demoProvider =
        Provider.of<V3DemoProvider>(context, listen: false);
    AnnotationModel annotationModel = context.read<AnnotationModel>();
    if (kIsWeb || Platform.isIOS) {
      isAnnotationImplemented = false;
    } else if (Platform.isAndroid || Platform.isMacOS) {
      isAnnotationImplemented = true;
    }
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (kIsWeb) ...[
                V3AutoHyphenatingText(
                  S.of(context).v3_main_presenting_message,
                  style: TextStyle(
                    fontSize: 16,
                    color: context.tokens.color.vsdswColorOnSurfaceVariant,
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
                          if (!context.mounted) {
                            return;
                          }
                          setState(() {
                            annotationOn = !annotationOn;
                          });
                          await Future.delayed(
                              const Duration(milliseconds: 100));
                          await _startAnnotation(annotationModel);
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
                      return CircleAvatar(
                        backgroundColor: !value
                            ? context.tokens.color.vsdswColorOnSurfaceInverse
                            : context.tokens.color.vsdswColorSurface900,
                        radius: kIsWeb ? 24 : 28,
                        child: IconButton(
                          onPressed: () {
                            bool tempState = !presentingState.value;
                            presentingState.value = tempState;
                            tempState
                                ? demoProvider.presentResume()
                                : demoProvider.presentPause();
                          },
                          icon: SvgPicture.asset(!value
                              ? 'assets/images/v3_ic_sharing_pause_on.svg'
                              : 'assets/images/v3_ic_sharing_pause_off.svg'),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: context.tokens.spacing.vsdswSpacingMd.left,
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: context.tokens.color.vsdswColorError,
                    radius: kIsWeb ? 24 : 28,
                    child: IconButton(
                      onPressed: () {
                        demoProvider.presentStop();
                      },
                      icon: Icon(
                        Icons.stop,
                        size: kIsWeb ? 24 : 28,
                        color: context.tokens.color.vsdswColorOnSurfaceInverse,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // [USER STORY 74502] Due to Web RTC QoS Setting issue, this feature is disabled temporarily.
          // if (!kIsWeb)
          //   Positioned(
          //     left: 24,
          //     bottom: 24,
          //     child: CircleAvatar(
          //       backgroundColor: context.tokens.color.vsdswColorSurface900,
          //       radius: 24,
          //       child: IconButton(
          //         icon: SvgPicture.asset('assets/images/v3_ic_options.svg'),
          //         onPressed: () {
          //           _showOptionsMenuDialog(context);
          //         },
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }

  Future<void> _startAnnotation(AnnotationModel annotationModel) async {
    if (Platform.isWindows || Platform.isMacOS) {
      final list = await DesktopMultiWindow.getAllSubWindowIds();
      if (list.isEmpty) {
        unawaited(WindowUtility.minimizeWindow());
        await Future.delayed(const Duration(milliseconds: 50));
        final window = await DesktopMultiWindow.createFullscreenWindow(
            jsonEncode({'mode': 'desktop_canvas'}),
            annotationModel.screenIndex);
        unawaited(window.show());
      } else {
        unawaited(WindowUtility.minimizeWindow());
        await Future.delayed(const Duration(milliseconds: 50));
        unawaited(WindowController.fromWindowId(list.first).show());
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
          unawaited(WindowUtility.minimizeWindow());
        } else {
          annotationOn = false;
          unawaited(Permission.systemAlertWindow.request());
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
    return CircleAvatar(
      backgroundColor: isOn
          ? context.tokens.color.vsdswColorOnSurfaceInverse
          : context.tokens.color.vsdswColorSurface900,
      radius: kIsWeb ? 24 : 28,
      child: IconButton(
        onPressed: onClick,
        icon: SvgPicture.asset(
          isOn
              ? 'assets/images/v3_ic_annotation_on.svg'
              : 'assets/images/v3_ic_sharing_pen.svg',
        ),
      ),
    );
  }
}
