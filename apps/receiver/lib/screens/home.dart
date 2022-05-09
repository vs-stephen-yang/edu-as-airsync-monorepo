import 'dart:async';
import 'dart:developer';

import 'package:display_flutter/app_instance_create.dart';

import 'package:display_flutter/blocs/display_code/display_code_bloc.dart';
import 'package:display_flutter/model/control_socket.dart';
import 'package:display_flutter/native_view/webrtc.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
                controller.channel.invokeMethod("connectControlSocket", <String, String>{
                  'id': AppInstanceCreate().instanceID,
                  'displayCode': _displayCodeBloc.displayCode,
                  'token': _displayCodeBloc.token,
                  'name': _displayCodeBloc.name,
                });
              }
              return Center(
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
                        style:
                            const TextStyle(color: Colors.blue, fontSize: 30),
                      ),
                    ),
                    FittedBox(
                      child: Text(
                        'Display Code: ${_displayCodeBloc.displayCode}',
                        style:
                            const TextStyle(color: Colors.blue, fontSize: 30),
                      ),
                    ),
                    FittedBox(
                      child: Text(
                        'OTP: ${_displayCodeBloc.otp}', //$_otpCode'
                        style:
                            const TextStyle(color: Colors.blue, fontSize: 30),
                      ),
                    ),
                    FittedBox(
                      child: Text(
                        'version: ${appConfig?.appVersion ?? ' '}',
                        style:
                            const TextStyle(color: Colors.blue, fontSize: 30),
                      ),
                    ),
                    FittedBox(
                      child: Text(
                        'InstanceId: ${AppInstanceCreate().instanceID}\n Registered: ${AppInstanceCreate().isRegistered}',
                        style:
                            const TextStyle(color: Colors.blue, fontSize: 30),
                      ),
                    ),
                  ],
                ),
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
        }
      });
      return;
    });
  }

  late Timer mConnectionTimeoutTimer, mRemainingTimeTimer;
  StreamController<int> mConnectionTimeTimeout = StreamController<int>();
  StreamController<int> mRemainingTimeTimeout = StreamController<int>();

  void _startConnectionTimeoutTimer() {
    _stopConnectionTimeoutTimer();

    var count = 30;
    mConnectionTimeoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {

      if (timer.tick < 30) {
        // onTick
        count = 30 - timer.tick;
        mConnectionTimeTimeout.add(count);
      } else if (timer.tick == 30) {
        // onFinish
        timer.cancel();
        controller.channel.invokeMethod('setStateMachine', "ConnectionTimeout onFinish");

        // AppCenterAnalyticsHelper.getInstance().EventStreamTimeout();

        // AllowId from WebRTCHelper
        ControlSocket.getInstance().sendMessageToControlSocket(context, _displayCode, allow: !mAllowId.isEmpty() ? mAllowId :
        mReconnectAllowId, action: 'timeout');

        controller.channel.invokeMethod('disconnectP2pClient');
        // UtilityHelper.myToast(mActivityRef.get(), R.string.connection_connect_timeout);
      }
    });
  }

  void _stopConnectionTimeoutTimer() {
    mConnectionTimeoutTimer.cancel();
    mConnectionTimeTimeout.add(0);
  }

  void _startRemainingTimeTimer(int seconds) {
    _stopRemainingTimeTimer();

    mRemainingTimeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      var count = 0;
      if (timer.tick < seconds) {
        // onTick
        log('RemainingTimeTimeout tick: ${timer.tick}');
        count = seconds - timer.tick;
        mRemainingTimeTimeout.add(count);
      } else if (timer.tick == seconds) {
        // onFinish
        timer.cancel();
        log('RemainingTimeTimeout onFinish');

        // TODO:SAVE WebRTCInfo
        // mWebRTCInfo.ModeratorMode = false;
        // mWebRTCInfo.IsModeratorLeave = true;
        // mWebRTCInfo.ModeratorId = "";
        // mWebRTCInfo.ModeratorName = "";

        controller.channel.invokeMethod('disconnectP2pClient');
      }
    });
  }

  void _stopRemainingTimeTimer() {
    mRemainingTimeTimer.cancel();
    mRemainingTimeTimeout.add(0);
  }



}
