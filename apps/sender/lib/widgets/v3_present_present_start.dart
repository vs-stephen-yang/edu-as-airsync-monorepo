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

class V3PresentPresentStart extends StatefulWidget {
  const V3PresentPresentStart({super.key, required this.isModeratorMode});
  final bool isModeratorMode;

  @override
  State<StatefulWidget> createState() => _V3PresentPresentStartState();
}

class _V3PresentPresentStartState extends State<V3PresentPresentStart> {
  final GlobalKey<TouchBackButtonState> touchBtnKey = GlobalKey();

  bool isAnnotationImplemented = false;
  bool annotationOn = false;

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
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    if (!kIsWeb) {
      AnnotationModel.closeAnnotation();
    }
    super.dispose();
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
                AutoSizeText(
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
                          setState(() {
                            annotationOn = !annotationOn;
                          });
                          await Future.delayed(
                              const Duration(milliseconds: 100));
                          _startAnnotation(annotationModel);
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
                            // Toggle current state
                            bool tempState = !presentingState.value;
                            trackEvent(
                                tempState ? 'click_resume' : 'click_pause',
                                EventCategory.session);

                            // Update state
                            presentingState.value = tempState;
                            tempState
                                ? channelProvider.presentResume()
                                : channelProvider.presentPause();
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
          Positioned(
            bottom: 100,
            child: ValueListenableBuilder(
                valueListenable:
                    WebRTCHelper().webRTCConnector!.reconnectStateNotifier,
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
          if (!kIsWeb)
            Positioned(
              left: 24,
              bottom: 24,
              child: CircleAvatar(
                backgroundColor: context.tokens.color.vsdswColorSurface900,
                radius: 24,
                child: IconButton(
                  icon: SvgPicture.asset('assets/images/v3_ic_options.svg'),
                  onPressed: () {
                    _showOptionsMenuDialog(context);
                  },
                ),
              ),
            ),
          // todo: move quality to setting menu and touch back to below item!!
          if (WebRTCHelper().showTouchBack())
            const Positioned(bottom: 8, child: V3TouchBackButton()),
        ],
      ),
    );
  }

  Future<void> _startAnnotation(AnnotationModel annotationModel) async {
    if (Platform.isWindows || Platform.isMacOS) {
      final list = await DesktopMultiWindow.getAllSubWindowIds();
      if (list.isEmpty) {
        WindowUtility.minimizeWindow();
        await Future.delayed(const Duration(milliseconds: 50));
        final window = await DesktopMultiWindow.createFullscreenWindow(
            jsonEncode({'mode': 'desktop_canvas'}),
            annotationModel.screenIndex);
        window.show();
      } else {
        AnnotationModel.closeAnnotation();
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
          WindowUtility.minimizeWindow();
        } else {
          Permission.systemAlertWindow.request();
          return;
        }
      } else {
        AnnotationModel.closeAnnotation();
      }
    }
  }

  _showOptionsMenuDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return const V3OptionsMenu();
      },
    );
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
