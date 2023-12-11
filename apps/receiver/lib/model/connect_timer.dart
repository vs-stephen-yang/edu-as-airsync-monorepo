import 'dart:async';
import 'dart:developer';

import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/model/webrtc_view_socket.dart';
import 'package:display_flutter/widgets/status_bar.dart';
import 'package:flutter/material.dart';

typedef ConnectionTimerCallback = void Function(
    WebRTCFlutterViewSocket controller, String nextId);
typedef TimeOutCallback = void Function();

class ConnectionTimer {
  Timer? mConnectionTimeoutTimer, mRemainingTimeTimer;
  StreamController<int> mConnectionTimeTimeout = StreamController<int>();
  StreamController<int> mRemainingTimeTimeout =
      StreamController<int>.broadcast();

  static final ConnectionTimer _instance = ConnectionTimer.internal();
  int remainingTimeLimit = 10800;

  static ConnectionTimer getInstance() {
    return _instance;
  }

  ConnectionTimer.internal();

  void startConnectionTimeoutTimer(WebRTCFlutterViewSocket controller,
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
        mConnectionTimeTimeout.add(0);
        log('ConnectionTimeout onFinish');
        onFinish(controller, nextId);
      }
    });
  }

  void startConnectionTimer(TimeOutCallback onFinish) {
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
            mConnectionTimeTimeout.add(0);
            log('ConnectionTimeout onFinish');
            onFinish();
          }
        });
  }

  void stopConnectionTimeoutTimer() {
    mConnectionTimeoutTimer?.cancel();
    mConnectionTimeTimeout.add(0);
  }

  void startRemainingTimeTimer(VoidCallback onFinish) {
    stopRemainingTimeTimer();

    mRemainingTimeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      log('RemainingTimeTimeout tick: ${timer.tick} // $remainingTimeLimit');

      if (remainingTimeLimit - timer.tick == 300) {
        int count = remainingTimeLimit - timer.tick;
        mRemainingTimeTimeout.sink.add(count);
        StatusBar.showReamingTime.value = true;
        AppAnalytics().trackEventSessionTimeoutNotification();
        StatusBar.showReamingTimeAlert.value = true;
      } else if (remainingTimeLimit - timer.tick < 300 &&
          timer.tick != remainingTimeLimit) {
        int count = remainingTimeLimit - timer.tick;
        mRemainingTimeTimeout.sink.add(count);
        if (remainingTimeLimit - timer.tick == 295) {
          StatusBar.showReamingTimeAlert.value = false;
        }
      } else if (timer.tick == remainingTimeLimit) {
        AppAnalytics().trackEventSessionTimeout();
        StatusBar.showReamingTime.value = false;
        mRemainingTimeTimer?.cancel();
        mRemainingTimeTimer = null;
        mRemainingTimeTimeout.sink.add(0);
        log('RemainingTimeTimeout onFinish');
        // onFinish
        onFinish();
      }
    });
  }

  void stopRemainingTimeTimer() {
    mRemainingTimeTimer?.cancel();
    mRemainingTimeTimer = null;
    StatusBar.showReamingTime.value = false;
    mRemainingTimeTimeout.sink.add(0);
  }
}
