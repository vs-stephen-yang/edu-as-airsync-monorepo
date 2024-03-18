import 'dart:async';
import 'dart:developer';

import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/widgets/status_bar.dart';
import 'package:flutter/material.dart';

typedef TimeOutCallback = void Function();

class ConnectionTimer {
  Timer? mConnectionTimeoutTimer, mRemainingTimeTimer, _stopServerTimer, _shareSenderTimer;
  StreamController<int> mConnectionTimeTimeout = StreamController<int>();
  StreamController<int> mRemainingTimeTimeout = StreamController<int>.broadcast();
  StreamController<int> _shareSenderTimeout = StreamController<int>.broadcast();

  static final ConnectionTimer _instance = ConnectionTimer.internal();
  int remainingTimeLimit = 10800;

  static ConnectionTimer getInstance() {
    return _instance;
  }

  ConnectionTimer.internal();

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

  void startServerTimer(VoidCallback onFinish) {
    stopServerTimer();
    _stopServerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timer.tick >= 30) {
        timer.cancel();
        // stopServerTimer();
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
    return mRemainingTimeTimer?.isActive ?? false;
  }

  void startShareSenderTimer(VoidCallback onFinish) {
    stopShareSenderTimer();

    _shareSenderTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timer.tick == remainingTimeLimit) {
        _shareSenderTimer?.cancel();
        _shareSenderTimer = null;
        _shareSenderTimeout.sink.add(0);
        log('_shareSenderTimer onFinish');
        // onFinish
        onFinish();
      }
    });
  }

  void stopShareSenderTimer() {
    _shareSenderTimer?.cancel();
    _shareSenderTimer = null;
    _shareSenderTimeout.sink.add(0);
  }
}
