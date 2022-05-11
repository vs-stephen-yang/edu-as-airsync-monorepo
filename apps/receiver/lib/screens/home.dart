import 'package:display_flutter/app_instance_create.dart';

import 'package:display_flutter/blocs/display_code/display_code_bloc.dart';
import 'package:display_flutter/model/connect_timer.dart';
import 'package:display_flutter/native_view/webrtc.dart';
import 'package:display_flutter/settings/app_config.dart';
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
  String _displayCode = '';
  String _otpCode = '';
  late WebRTCNativeViewController controller;
  late DisplayCodeBloc _displayCodeBloc;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _displayCodeBloc = DisplayCodeBloc(
        AppConfig.of(context)!.settings.apiGateway,
        AppInstanceCreate().displayInstanceID,
        AppConfig.of(context)!.appVersion);
    if (_displayCodeBloc.state is DisplayCodeInitial) {
      _displayCodeBloc.add(GetDisplayCode());
    }
  }

  @override
  Widget build(BuildContext context) {
    AppConfig? appConfig = AppConfig.of(context);
    return Scaffold(
        backgroundColor: Colors.black,
        body: BlocProvider(
          create: (context) => _displayCodeBloc,
          child: BlocBuilder<DisplayCodeBloc, DisplayCodeState>(
            builder: (context, state) {
              if (state is DisplayCodeSuccess) {
                controller.channel
                    .invokeMethod("connectControlSocket", <String, String>{
                  'id': AppInstanceCreate().instanceID,
                  'displayCode': _displayCodeBloc.displayCode,
                  'token': _displayCodeBloc.token,
                  'name': _displayCodeBloc.name,
                });
              }
              return Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: WebRTCNativeView(
                            onWebRTCNativeViewCreatedCallback:
                                _webRTCNativeViewCreatedCallback,
                          ),
                        ),
                        FittedBox(
                          child: Text(
                            appConfig?.settings.mainDisplayUrl ?? ' ',
                            style: const TextStyle(
                                color: Colors.blue, fontSize: 30),
                          ),
                        ),
                        FittedBox(
                          child: Text(
                            'Display Code: ${_displayCodeBloc.displayCode}',
                            style: const TextStyle(
                                color: Colors.blue, fontSize: 30),
                          ),
                        ),
                        FittedBox(
                          child: Text(
                            'OTP: ${_displayCodeBloc.otp}', //$_otpCode'
                            style: const TextStyle(
                                color: Colors.blue, fontSize: 30),
                          ),
                        ),
                        FittedBox(
                          child: Text(
                            'version: ${appConfig?.appVersion ?? ' '}',
                            style: const TextStyle(
                                color: Colors.blue, fontSize: 30),
                          ),
                        ),
                        FittedBox(
                          child: Text(
                            'InstanceId: ${AppInstanceCreate().instanceID}\n Registered: ${AppInstanceCreate().isRegistered}',
                            style: const TextStyle(
                                color: Colors.blue, fontSize: 30),
                          ),
                        ),
                      ],
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
              );
            },
          ),
        ));
  }

  _webRTCNativeViewCreatedCallback(WebRTCNativeViewController controller) {
    this.controller = controller;
    controller.channel.setMethodCallHandler((MethodCall call) async {
      setState(() {
        if (call.method == "setDisplayCode") {
          _displayCode = call.arguments as String;
        } else if (call.method == "setOtpCode") {
          _otpCode = call.arguments as String;
        } else if (call.method == "startConnectTimeOutTimer") {
          ConnectionTimer.getInstance().startConnectionTimeoutTimer(
              controller, context, _displayCode, call.arguments as String);
        } else if (call.method == "stopConnectionTimeoutTimer") {
          ConnectionTimer.getInstance().stopConnectionTimeoutTimer();
        } else if (call.method == "startRemainingTimeTimer") {
          ConnectionTimer.getInstance()
              .startRemainingTimeTimer(controller, call.arguments as int);
        } else if (call.method == "stopRemainingTimeTimer") {
          ConnectionTimer.getInstance().stopRemainingTimeTimer();
        }
      });
      return;
    });
  }

  void _controlAudio(bool enable) {
    controller.channel.invokeMethod('_controlAudio', enable);
  }

}
