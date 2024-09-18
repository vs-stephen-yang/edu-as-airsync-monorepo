import 'dart:async';
import 'dart:math';

import 'package:display_channel/src/util/stage_util.dart';

class CounterCondition {
  final _completer = Completer();
  int _counter = 0;

  Future<void> get future => _completer.future;

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

const maxInstanceGroupId = 16777216 - 1;

int randomGroupId() {
  final seed = DateTime.now().millisecondsSinceEpoch;
  return Random(seed).nextInt(maxInstanceGroupId);
}

String getApiOriginFromEnv() {
  const environment = String.fromEnvironment('ENV', defaultValue: 'dev');

  return getStageApiUrl(parseStage(environment));
}

Future waitForAllCompleted(List<Completer<void>> completers) async {
  final futures = completers
      .map(
        (e) => e.future,
      )
      .toList();

  await Future.wait(futures);
}

Future<void> scheduleTasks<T>(
  List<T> items,
  Future<void> Function(T item, int index) task,
  Duration duration,
) async {
  final startTime = DateTime.now();
  final futures = <Future<void>>[];

  for (var i = 0; i < items.length; i++) {
    final item = items[i];

    // Start the task and add it to the futures list.
    futures.add(task(item, i));

    // Calculate elapsed time since the start.
    final elapsed = DateTime.now().difference(startTime);

    // Calculate the expected time for the next task to maintain evenly spaced execution.
    final expectedNextTimeMs =
        ((i + 1) * duration.inMilliseconds) ~/ items.length;

    // Calculate the delay required to keep the tasks evenly spaced.
    final delayMs = expectedNextTimeMs - elapsed.inMilliseconds;

    // If delay is positive, wait for that duration to maintain interval.
    if (delayMs > 0) {
      await Future.delayed(Duration(milliseconds: delayMs));
    }
  }

  // Wait for all tasks to complete.
  await Future.wait(futures);
}
