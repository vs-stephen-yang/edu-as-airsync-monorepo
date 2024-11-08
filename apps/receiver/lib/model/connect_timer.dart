import 'dart:async';

import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:display_flutter/widgets/status_bar.dart';
import 'package:flutter/material.dart';

typedef TimeOutCallback = void Function();

class ConnectionTimer {
  Timer? _remainingTimeTimer, _stopServerTimer, _shareSenderTimer;
  StreamController<int> remainingTimeTimeout =
      StreamController<int>.broadcast();
  StreamController<int> shareSenderTimeout = StreamController<int>.broadcast();

  static final ConnectionTimer _instance = ConnectionTimer.internal();
  int threeHourTimeLimit = 10800; // seconds

  static ConnectionTimer getInstance() {
    return _instance;
  }

  ConnectionTimer.internal();

  void startRemainingTimeTimer(VoidCallback onFinish) {
    stopRemainingTimeTimer();

    _remainingTimeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      //log('RemainingTimeTimeout tick: ${timer.tick} // $threeHourTimeLimit');

      if (threeHourTimeLimit - timer.tick == 300) {
        int count = threeHourTimeLimit - timer.tick;
        remainingTimeTimeout.sink.add(count);
        StatusBar.showReamingTime.value = true;
        trackTrace('meeting_timeout_notification');

        StatusBar.showReamingTimeAlert.value = true;
      } else if (threeHourTimeLimit - timer.tick < 300 &&
          timer.tick != threeHourTimeLimit) {
        int count = threeHourTimeLimit - timer.tick;
        remainingTimeTimeout.sink.add(count);
        if (threeHourTimeLimit - timer.tick == 295) {
          StatusBar.showReamingTimeAlert.value = false;
        }
      } else if (timer.tick == threeHourTimeLimit) {
        trackTrace('meeting_timeout');

        StatusBar.showReamingTime.value = false;
        _remainingTimeTimer?.cancel();
        _remainingTimeTimer = null;
        remainingTimeTimeout.sink.add(0);
        log.info('RemainingTimeTimeout onFinish');
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
        log.info('ShareSenderTimeout onFinish');
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
