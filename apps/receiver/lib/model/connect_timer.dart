import 'dart:async';
import 'dart:developer';

import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/native_view/webrtc.dart';
import 'package:flutter/material.dart';

typedef ConnectionTimerCallback = void Function(
    WebRTCNativeViewController controller, String nextId);

class ConnectionTimer {
  Timer? mConnectionTimeoutTimer, mRemainingTimeTimer;
  StreamController<int> mConnectionTimeTimeout = StreamController<int>();
  StreamController<int> mRemainingTimeTimeout = StreamController<int>();

  static final ConnectionTimer _instance = ConnectionTimer.internal();

  static ConnectionTimer getInstance() {
    return _instance;
  }

  ConnectionTimer.internal();

  void startConnectionTimeoutTimer(WebRTCNativeViewController controller,
      String nextId, ConnectionTimerCallback onFinish) {
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
        log('ConnectionTimeout onFinish');
        onFinish(controller, nextId);
        AppAnalytics().trackEventPresentTimeout();
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
        onFinish();
      }
    });
  }

  void stopRemainingTimeTimer() {
    mRemainingTimeTimer?.cancel();
    mRemainingTimeTimeout.add(0);
  }
}
