import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:display_cast_flutter/utilities/log.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// share logs to another App for troubleshooting
Future<bool> shareLogs() async {
  try {
    // write logs to file
    Directory directory = await getApplicationDocumentsDirectory();
    String filePath = path.join(directory.path, 'airsync-logs.txt');

    log.info('Writing logs to $filePath');

    await writeLogToFile(File(filePath));

    // share logs to another App
    log.info('Sharing log file');

    final result = await Share.shareXFiles(
      [XFile(filePath)],
      text: 'AirSync logs',
    );

    log.info('Finish sharing the log file. ${result.status}');

    return true;
  } catch (e, stackTrace) {
    log.severe('Failed to share logs', e, stackTrace);
    return false;
  }
}
