import 'dart:async';
import 'dart:developer';

import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/widgets/status_bar.dart';
import 'package:flutter/material.dart';

typedef TimeOutCallback = void Function();

class ConnectionTimer {
  Timer? _connectionTimeoutTimer, _remainingTimeTimer, _stopServerTimer, _shareSenderTimer;
  StreamController<int> connectionTimeTimeout = StreamController<int>();
  StreamController<int> remainingTimeTimeout = StreamController<int>.broadcast();
  StreamController<int> shareSenderTimeout = StreamController<int>.broadcast();

  static final ConnectionTimer _instance = ConnectionTimer.internal();
  int threeHourTimeLimit = 10800; // seconds

  static ConnectionTimer getInstance() {
    return _instance;
  }

  ConnectionTimer.internal();

  void startConnectionTimer(TimeOutCallback onFinish) {
    if (_connectionTimeoutTimer != null) stopConnectionTimeoutTimer();

    var count = 30;
    _connectionTimeoutTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
          if (timer.tick < 30) {
            // onTick
            count = 30 - timer.tick;
            connectionTimeTimeout.add(count);
          } else if (timer.tick == 30) {
            // onFinish
            timer.cancel();
            connectionTimeTimeout.add(0);
            log('ConnectionTimeout onFinish');
            onFinish();
          }
        });
  }

  void stopConnectionTimeoutTimer() {
    _connectionTimeoutTimer?.cancel();
    connectionTimeTimeout.add(0);
  }

  void startRemainingTimeTimer(VoidCallback onFinish) {
    stopRemainingTimeTimer();

    _remainingTimeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      log('RemainingTimeTimeout tick: ${timer.tick} // $threeHourTimeLimit');

      if (threeHourTimeLimit - timer.tick == 300) {
        int count = threeHourTimeLimit - timer.tick;
        remainingTimeTimeout.sink.add(count);
        StatusBar.showReamingTime.value = true;
        AppAnalytics().trackEventSessionTimeoutNotification();
        StatusBar.showReamingTimeAlert.value = true;
      } else if (threeHourTimeLimit - timer.tick < 300 &&
          timer.tick != threeHourTimeLimit) {
        int count = threeHourTimeLimit - timer.tick;
        remainingTimeTimeout.sink.add(count);
        if (threeHourTimeLimit - timer.tick == 295) {
          StatusBar.showReamingTimeAlert.value = false;
        }
      } else if (timer.tick == threeHourTimeLimit) {
        AppAnalytics().trackEventSessionTimeout();
        StatusBar.showReamingTime.value = false;
        _remainingTimeTimer?.cancel();
        _remainingTimeTimer = null;
        remainingTimeTimeout.sink.add(0);
        log('RemainingTimeTimeout onFinish');
        // onFinish
        onFinish();
      }
    });
  }

  void stopRemainingTimeTimer() {
    _remainingTimeTimer?.cancel();
    _remainingTimeTimer = null;
    StatusBar.showReamingTime.value = false;
    remainingTimeTimeout.sink.add(0);
  }

  void startServerTimer(VoidCallback onFinish) {
    stopServerTimer();
    _stopServerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timer.tick >= 30) {
        timer.cancel();
        onFinish();
      }
    });
  }

  void stopServerTimer() {
    if (_stopServerTimer != null) {
      _stopServerTimer?.cancel();
      _stopServerTimer = null;
    }
  }

  bool remainingTimeTimerIsActive() {
    return _remainingTimeTimer?.isActive ?? false;
  }

  void startShareSenderTimer(VoidCallback onFinish) {
    stopShareSenderTimer();

    _shareSenderTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timer.tick == threeHourTimeLimit) {
        _shareSenderTimer?.cancel();
        _shareSenderTimer = null;
        shareSenderTimeout.sink.add(0);
        log('ShareSenderTimeout onFinish');
        // onFinish
        onFinish();
      }
    });
  }

  void stopShareSenderTimer() {
    _shareSenderTimer?.cancel();
    _shareSenderTimer = null;
    shareSenderTimeout.sink.add(0);
  }
}
