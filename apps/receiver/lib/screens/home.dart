
import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/model/connect_timer.dart';
import 'package:display_flutter/model/control_socket.dart';
import 'package:display_flutter/model/webrtc_Info.dart';
import 'package:display_flutter/native_view/webrtc.dart';
import 'package:display_flutter/screens/split_screen.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/widgets/bottom_bar.dart';
import 'package:display_flutter/widgets/stream_function.dart';
import 'package:display_flutter/widgets/main_info.dart';
import 'package:display_flutter/widgets/tittle_bar.dart';
import 'package:display_flutter/widgets/vbs_ota.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late WebRTCNativeViewController controller;
  bool viewCreated = false;

  double _fullWidth = 0, _fullHeight = 0, _halfWidth = 0, _halfHeight = 0;
  final List<Widget> _webRtcWidget = <Widget>[];
  final List<bool> _isSelectedList = List.filled(4, false, growable: false);

  @override
  void initState() {
    super.initState();
    _webRtcWidget.add(WebRTCNativeView(
      onWebRTCNativeViewCreatedCallback: _webRTCNativeViewCreatedCallback,
    ));
    // todo: design other native view.
    _webRtcWidget.add(Container(color: Colors.red));
    _webRtcWidget.add(Container(color: Colors.green));
    _webRtcWidget.add(Container(color: Colors.blue));

    _initControlSocketListener(this.context);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _fullWidth = size.width;
    _fullHeight = size.height;
    _halfWidth = size.width / 2;
    _halfHeight = size.height / 2;
    return Scaffold(
      body: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: Stack(
          children: <Widget>[
            ValueListenableBuilder(
              valueListenable: SplitScreen.splitScreenEnabled,
              builder: (BuildContext context, bool value, Widget? child) {
                _updateSizeForSelected(int selection) {
                  setState(() {
                    if (value) {
                      for (int i = 0; i < _isSelectedList.length; i++) {
                        if (i == selection) {
                          _isSelectedList[i] = !_isSelectedList[i];
                        } else {
                          _isSelectedList[i] = false;
                        }
                      }
                    } else {
                      _isSelectedList.fillRange(
                          0, _isSelectedList.length, false);
                      _isSelectedList[0] = true;
                    }
                  });
                }

                List<Widget> webrtcWidgets =
                List.generate(value ? 4 : 1, (index) {
                  double? left, top, right, bottom;
                  if (index == 1) {
                    right = 0;
                    top = 0;
                  } else if (index == 2) {
                    left = 0;
                    bottom = 0;
                  } else if (index == 3) {
                    right = 0;
                    bottom = 0;
                  } else {
                    // index 0 and default.
                    left = 0;
                    top = 0;
                  }

                  return Positioned(
                    left: left,
                    top: top,
                    right: right,
                    bottom: bottom,
                    child: GestureDetector(
                      onDoubleTap: () => _updateSizeForSelected(index),
                      child: AnimatedContainer(
                        width: _isSelectedList[index]
                            ? _fullWidth
                            : !_isSelectedList.contains(true)
                                ? _halfWidth
                                : 0,
                        height: _isSelectedList[index]
                            ? _fullHeight
                            : !_isSelectedList.contains(true)
                                ? _halfHeight
                                : 0,
                        alignment: _isSelectedList[index]
                            ? Alignment.center
                            : Alignment.topLeft,
                        curve: Curves.linear,
                        duration:
                            Duration(seconds: _isSelectedList[index] ? 1 : 0),
                        child: _webRtcWidget[index],
                      ),
                    ),
                  );
                });

                return Stack(
                  children: webrtcWidgets,
                );
              },
            ),
            ConstrainedBox(
              constraints: const BoxConstraints.expand(),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  const Positioned(
                    left: 0,
                    top: 0,
                    right: 0,
                    child: TitleBar(),
                  ),
                  Positioned(
                      child: viewCreated
                          ? MainInfo(
                              controller: controller,
                              isEnrolled: false, // todo: Moderator mode switch
                            )
                          : const Text(' ')),
                  const Positioned(
                      left: 20, bottom: 140, child: StreamFunction()),
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: BottomBar(),
                  ),
                  Visibility(
                    visible: AppInstanceCreate().isInstalledInVBS100,
                    child: const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: VbsOTA(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _webRTCNativeViewCreatedCallback(WebRTCNativeViewController controller) {
    this.controller = controller;
    setState(() {
      // todo: Temporary solution: wait move control socket mechanism to Dart level.
      viewCreated = true;
    });
    controller.channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == ("connectP2PClientResult")) {
        bool result = call.arguments;
        ControlSocket.getInstance().handleP2PClientResult(result);
      }

      return;
    });
  }

  void _initControlSocketListener(BuildContext context) {
    ControlSocket.getInstance().socketResponse.getResponse.listen((event) {
      String action = event['action'];
      switch (action) {
        case "set-moderator":
          ConnectionTimer.getInstance().startRemainingTimeTimer(
              ControlSocket.getInstance().mWebRTCInfo.remainingTime,
              () => controller.channel.invokeMethod('disconnectP2pClient'));
          break;
        case "unset-moderator":
          ConnectionTimer.getInstance().stopRemainingTimeTimer();
          break;
        case "control":
          Map<String, dynamic> status = event['status'];
          String statusAction = status['action'];
          switch (statusAction) {
            case 'setClient':
              WebRTCInfo mWebRTCInfo = ControlSocket.getInstance().mWebRTCInfo;
              if (!mWebRTCInfo.moderatorMode) {
                ConnectionTimer.getInstance().startConnectionTimeoutTimer(
                    AppConfig.of(context)?.appVersion,
                    mWebRTCInfo.displayCode,
                    mWebRTCInfo.allowId,
                    () => controller.channel.invokeMethod("disconnectP2pClient"));
              }
              var arg = {
                'clientId': mWebRTCInfo.clientId,
                'allowId': mWebRTCInfo.allowId,
                'response': event,
              };
              controller.channel.invokeMethod('connectP2pClient', arg);
              break;
            case "play":
              break;
            case "stop":
              ConnectionTimer.getInstance().stopConnectionTimeoutTimer();
              break;
          }
          break;
        case "pauseVideo":
          break;
        case "resumeVideo":
          break;
      }
    });
  }
}
