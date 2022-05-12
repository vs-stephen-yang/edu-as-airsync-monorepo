import 'dart:async';
import 'dart:developer';

import 'package:display_flutter/model/control_socket.dart';
import 'package:display_flutter/native_view/webrtc.dart';
import 'package:flutter/material.dart';

class ConnectionTimer {

  late Timer mConnectionTimeoutTimer, mRemainingTimeTimer;
  StreamController<int> mConnectionTimeTimeout = StreamController<int>();
  StreamController<int> mRemainingTimeTimeout = StreamController<int>();

  static ConnectionTimer _instance = ConnectionTimer.internal();

  static ConnectionTimer getInstance() {
    return _instance;
  }

  ConnectionTimer.internal();

  void startConnectionTimeoutTimer(WebRTCNativeViewController controller,
      BuildContext context, String _displayCode, String allow) {
    stopConnectionTimeoutTimer();

    var count = 30;
    mConnectionTimeoutTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timer.tick < 30) {
        // onTick
        count = 30 - timer.tick;
        mConnectionTimeTimeout.add(count);
      } else if (timer.tick == 30) {
        // onFinish
        timer.cancel();
        controller.channel
            .invokeMethod('setStateMachine', "ConnectionTimeout onFinish");

        // AppCenterAnalyticsHelper.getInstance().EventStreamTimeout();

        ControlSocket.getInstance().sendMessageToControlSocket(
            context, _displayCode,
            allow: allow, action: 'timeout');

        controller.channel.invokeMethod('disconnectP2pClient');
        // UtilityHelper.myToast(mActivityRef.get(), R.string.connection_connect_timeout);
      }
    });
  }

  void stopConnectionTimeoutTimer() {
    mConnectionTimeoutTimer.cancel();
    mConnectionTimeTimeout.add(0);
  }

  void startRemainingTimeTimer(
      WebRTCNativeViewController controller, int seconds) {
    stopRemainingTimeTimer();

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

        controller.channel.invokeMethod('offModeratorMode');
      }
    });
  }

  void stopRemainingTimeTimer() {
    mRemainingTimeTimer.cancel();
    mRemainingTimeTimeout.add(0);
  }
}
