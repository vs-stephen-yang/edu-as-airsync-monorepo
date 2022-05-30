import 'dart:async';
import 'dart:developer';

import 'package:display_flutter/model/control_socket.dart';
import 'package:display_flutter/model/webrtc_Info.dart';
import 'package:flutter/material.dart';

class ConnectionTimer {

  Timer? mConnectionTimeoutTimer, mRemainingTimeTimer;
  StreamController<int> mConnectionTimeTimeout = StreamController<int>();
  StreamController<int> mRemainingTimeTimeout = StreamController<int>();

  static ConnectionTimer _instance = ConnectionTimer.internal();

  static ConnectionTimer getInstance() {
    return _instance;
  }

  ConnectionTimer.internal();

  void startConnectionTimeoutTimer(String? appVersion, String? displayCode,
      String? allow, VoidCallback onFinish) {
    if (mConnectionTimeoutTimer != null) stopConnectionTimeoutTimer();

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
        ControlSocket.getInstance()
            .setStateMachine("ConnectionTimeout onFinish");

        ControlSocket.getInstance().sendMessageToControlSocket(displayCode,
            allow: allow, action: 'timeout');

        onFinish();
        // AppCenterAnalyticsHelper.getInstance().EventStreamTimeout();
        // controller.channel.invokeMethod('disconnectP2pClient');
        // UtilityHelper.myToast(mActivityRef.get(), R.string.connection_connect_timeout);
      }
    });
  }

  void stopConnectionTimeoutTimer() {
    mConnectionTimeoutTimer?.cancel();
    mConnectionTimeTimeout.add(0);
  }

  void startRemainingTimeTimer(int seconds, VoidCallback onFinish) {
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
        WebRTCInfo mWebRTCInfo = ControlSocket.getInstance().mWebRTCInfo;
        mWebRTCInfo.moderatorMode = false;
        mWebRTCInfo.isModeratorLeave = true;
        mWebRTCInfo.moderatorId = "";
        mWebRTCInfo.moderatorName = "";
        onFinish;
      }
    });
  }

  void stopRemainingTimeTimer() {
    mRemainingTimeTimer?.cancel();
    mRemainingTimeTimeout.add(0);
  }
}
