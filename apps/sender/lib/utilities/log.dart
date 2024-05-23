import 'dart:io';

import 'package:display_cast_flutter/utilities/log_storage.dart';
import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart';

Logger log = Logger('airsync');

const _maxLogSize = 1000;

void initLogger() {
  Logger.root.level = Level.INFO; // defaults to Level.INFO

  Logger.root.onRecord.listen((record) {
    final msg = '${record.level.name} ${record.message}';

    if (kDebugMode) {
      print(msg);
    }

    _logStorage?.addLog(msg);
  });
}

bool isLogLevelVerbose() {
  return Logger.root.level == Level.FINEST;
}

void setLogLevelVerbose(bool isVerbose) {
  Logger.root.level = isVerbose ? Level.FINEST : Level.INFO;
}

LogStorage? _logStorage;

void enableLogToMemory(bool enable) {
  if (enable) {
    _logStorage = LogStorage(_maxLogSize);
  } else {
    _logStorage?.clearLogs();
    _logStorage = null;
  }
}

Future<void> writeLogToFile(File file) async {
  if (_logStorage == null) {
    return;
  }

  final logContent = _logStorage!.getLogs().join(Platform.lineTerminator);

  await file.writeAsString(
    logContent,
    flush: true,
  );
}
