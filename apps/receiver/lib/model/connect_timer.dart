import 'dart:async';

import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:display_flutter/widgets/v3_extend_casting_time_menu.dart';
import 'package:flutter/material.dart';

typedef TimeOutCallback = void Function();

class ConnectionTimer {
  static const threeHourTimeLimitSec = 10800;
  static const hintStartTimeSec = 300;

  static const maxExtendTime = 2;

  static final ConnectionTimer _instance = ConnectionTimer.internal();

  static ConnectionTimer getInstance() => _instance;

  ConnectionTimer.internal();

  Timer? _remainingTimeTimer, _shareSenderTimer;
  StreamController<int> remainingTimeTimeout =
      StreamController<int>.broadcast();

  StreamController<int> shareSenderTimeout = StreamController<int>.broadcast();

  int extendTimes = 0;

  int get remainExtendTime => maxExtendTime - extendTimes;

  bool get exceedMaxExtendTimes => extendTimes >= maxExtendTime;

  int elapsedSec = 0;

  ///  Buffer for safe extending (applied inside the timer loop)
  bool _remainingTimerPendingExtension = false;

  void startRemainingTimeTimer(VoidCallback onFinish) {
    remainingTimeTimeout.sink.add(hintStartTimeSec);
    _remainingTimeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Apply any pending extensions safely inside the timer, avoid race condition
      if (_remainingTimerPendingExtension) {
        elapsedSec -= threeHourTimeLimitSec;
        _remainingTimerPendingExtension = false;
      }
      elapsedSec += 1;
      int remainingSeconds = (threeHourTimeLimitSec - elapsedSec);

      if (remainingSeconds == hintStartTimeSec) {
        trackTrace('meeting_timeout_notification');
        V3ExtendCastingTimeMenu.showReamingTimeAlert.value = true;
      } else if (remainingSeconds < hintStartTimeSec) {
        remainingTimeTimeout.sink.add(remainingSeconds);
      }

      if (elapsedSec >= threeHourTimeLimitSec) {
        trackTrace('meeting_timeout');
        V3ExtendCastingTimeMenu.showReamingTimeAlert.value = false;
        _remainingTimeTimer?.cancel();
        _remainingTimeTimer = null;
        remainingTimeTimeout.sink.add(0);
        extendTimes = 0;
        log.info('RemainingTimeTimeout onFinish');
        onFinish();
      }
    });
  }

  void stopRemainingTimeTimer() {
    _remainingTimeTimer?.cancel();
    _remainingTimeTimer = null;
    remainingTimeTimeout.sink.add(-1);
    V3ExtendCastingTimeMenu.showReamingTimeAlert.value = false;
    extendTimes = 0;
    elapsedSec = 0;
  }

  bool remainingTimeTimerIsActive() {
    return _remainingTimeTimer?.isActive ?? false;
  }

  void extendRemainTimer() {
    _remainingTimerPendingExtension = true;
    extendTimes += 1;
    log.info('Extend casting time, now remain $remainExtendTime times');
  }

  void startShareSenderTimer(VoidCallback onFinish) {
    stopShareSenderTimer();

    _shareSenderTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timer.tick == threeHourTimeLimitSec * (maxExtendTime + 1)) {
        _shareSenderTimer?.cancel();
        _shareSenderTimer = null;
        shareSenderTimeout.sink.add(0);
        log.info('ShareSenderTimeout onFinish');
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
