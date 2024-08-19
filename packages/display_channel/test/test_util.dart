import 'dart:async';

class CounterCondition {
  final _completer = Completer();
  int _counter = 0;

  final int _expectedCount;

  CounterCondition(this._expectedCount);

  call() {
    _counter++;

    if (_counter >= _expectedCount) {
      _completer.complete();
    }
  }

  // wait until the counter reaches the expected value
  wait() async {
    await _completer.future;
  }
}
