import 'package:logging/logging.dart';

Logger? defaultLogger;

Logger log() {
  if (defaultLogger == null) {
    Logger.root.onRecord.listen((record) {
      // ignore: avoid_print
      print('${record.time} ${record.level.name} ${record.message}');
    });

    defaultLogger ??= Logger('display-channel');
  }

  return defaultLogger!;
}
