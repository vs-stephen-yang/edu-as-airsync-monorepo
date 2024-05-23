import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart';

Logger log = Logger('airsync');

void initLogger() {
  Logger.root.level = Level.INFO; // defaults to Level.INFO

  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      print('${record.level.name} ${record.message}');
    }
  });
}
