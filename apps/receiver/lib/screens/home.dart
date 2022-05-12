import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/native_view/webrtc.dart';
import 'package:display_flutter/widgets/bottom_bar.dart';
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
      return;
    });
  }
}
