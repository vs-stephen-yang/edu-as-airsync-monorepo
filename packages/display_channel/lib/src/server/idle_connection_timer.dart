import 'dart:async';

class IdleConnectionTimer {
  final void Function() _onIdleTimeout;

  final Duration _idleDuration;

  Timer? _timer;

  IdleConnectionTimer(
    this._onIdleTimeout,
    this._idleDuration,
  ) {
    _restartTimer();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void _restartTimer() {
    _timer?.cancel();
    _timer = Timer(_idleDuration, () {
      _onIdleTimeout();
    });
  }

  void reset() {
    _restartTimer();
  }
}
