import 'dart:async';

typedef ConnectionTimerCallback = void Function();

class ConnectionTimer {
  Timer? mConnectionTimeoutTimer;

  static final ConnectionTimer _instance = ConnectionTimer.internal();

  static ConnectionTimer getInstance() {
    return _instance;
  }

  ConnectionTimer.internal();

  void startConnectionTimeoutTimer(ConnectionTimerCallback onFinish,
      {void Function(int tick)? onTick}) {
    if (mConnectionTimeoutTimer != null) stopConnectionTimeoutTimer();

    mConnectionTimeoutTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timer.tick < 30) {
        if (onTick != null) {
          onTick(timer.tick);
        }
      } else if (timer.tick == 30) {
        // onFinish
        timer.cancel();
        onFinish();
      }
    });
  }

  void stopConnectionTimeoutTimer() {
    mConnectionTimeoutTimer?.cancel();
  }
}
