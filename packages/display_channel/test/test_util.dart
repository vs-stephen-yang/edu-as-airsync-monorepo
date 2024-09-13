import 'dart:async';
import 'dart:math';

import 'package:display_channel/src/util/stage_util.dart';

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

Future scheduleTasks<T>(
  List<T> items,
  Future<void> Function(T item, int index) task,
  Duration totalDuration,
) async {
  final startTime = DateTime.now();

  for (int i = 0; i < items.length; i++) {
    // Execute the task for the current item
    await task(items[i], i);

    // Calculate the elapsed time
    final elapsedTime = DateTime.now().difference(startTime);
    final nextTaskTimeMs =
        ((i + 1) * totalDuration.inMilliseconds) ~/ items.length;

    // Calculate the delay before executing the next task
    final delayMs = nextTaskTimeMs - elapsedTime.inMilliseconds;
    if (delayMs > 0) {
      await Future.delayed(Duration(milliseconds: delayMs));
    }
  }
}
