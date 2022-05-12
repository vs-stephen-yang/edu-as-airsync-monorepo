import 'package:display_flutter/app_instance_create.dart';

import 'package:display_flutter/blocs/display_code/display_code_bloc.dart';
import 'package:display_flutter/model/connect_timer.dart';
import 'package:display_flutter/native_view/webrtc.dart';
import 'package:display_flutter/widgets/bottom_bar.dart';
import 'package:display_flutter/widgets/main_info.dart';
import 'package:display_flutter/widgets/tittle_bar.dart';
import 'package:display_flutter/widgets/vbs_ota.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late WebRTCNativeViewController controller;
  bool viewCreated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: Stack(
          children: <Widget>[
            WebRTCNativeView(
              onWebRTCNativeViewCreatedCallback:
                  _webRTCNativeViewCreatedCallback,
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
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: BottomBar(),
                  ),
                  Visibility(
                    visible: AppInstanceCreate().modelName == 'VBS100',
                    child: const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: VbsOTA(),
                    ),
                  ),
                  Positioned(
                      bottom: 0.0,
                      left: 0.0,
                      child: Column(
                        children: [
                          IconButton(
                              onPressed: () {},
                              icon: SvgPicture.asset(
                                  'assets/images/ic_moderator_off')),
                          IconButton(
                              onPressed: () {},
                              icon: SvgPicture.asset(
                                  'assets/images/ic_language')),
                          IconButton(
                              onPressed: () {},
                              icon: SvgPicture.asset(
                                  'assets/images/ic_whatsnews')),
                        ],
                      ))
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
      // if (call.method == "setDisplayCode") {
      //   _displayCode = call.arguments as String;
      // } else if (call.method == "setOtpCode") {
      //   _otpCode = call.arguments as String;
      // } else if (call.method == "startConnectTimeOutTimer") {
      //   ConnectionTimer.getInstance().startConnectionTimeoutTimer(
      //       controller, context, _displayCode, call.arguments as String);
      // } else if (call.method == "stopConnectionTimeoutTimer") {
      //   ConnectionTimer.getInstance().stopConnectionTimeoutTimer();
      // } else if (call.method == "startRemainingTimeTimer") {
      //   ConnectionTimer.getInstance()
      //       .startRemainingTimeTimer(controller, call.arguments as int);
      // } else if (call.method == "stopRemainingTimeTimer") {
      //   ConnectionTimer.getInstance().stopRemainingTimeTimer();
      // }
      return;
    });
  }
}
