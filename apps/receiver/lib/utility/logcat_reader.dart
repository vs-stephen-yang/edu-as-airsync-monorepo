import 'package:display_flutter/utility/log.dart';
import 'package:flutter/services.dart';

enum LogPriority {
  verbose,
  debug,
  info,
  warning,
  error,
}

extension LogPriorityExtension on LogPriority {
  String get value {
    switch (this) {
      case LogPriority.verbose:
        return 'V';
      case LogPriority.debug:
        return 'D';
      case LogPriority.info:
        return 'I';
      case LogPriority.warning:
        return 'W';
      case LogPriority.error:
        return 'E';
    }
  }
}

class LogcatReader {
  static const _channel = MethodChannel('com.mvbcast.crosswalk/logcat');

  /// Reads logcat logs from the native Android side.
  ///
  /// [buffers]: e.g., 'main', 'main,system'
  /// [priority]: enum representing log priority (default is debug)
  /// [lines]: the number of the most recent log lines to retrieve.
  static Future<String> readLog({
    String buffers = 'main,system',
    LogPriority priority = LogPriority.debug,
    int lines = 500,
  }) async {
    try {
      final log = await _channel.invokeMethod<String>('readLog', {
        'buffers': buffers,
        'priority': priority.value,
        'lines': lines,
      });

      return log ?? '';
    } on PlatformException catch (e) {
      log.warning('Failed to get logcat output', e);
      return '';
    }
  }
}
