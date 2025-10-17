import 'dart:convert';
import 'dart:typed_data';

import 'package:display_flutter/utility/log.dart';
import 'package:display_flutter/utility/logcat_reader.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

// Upload log using Sentry's user feedback
uploadLog(String message, String logs) async {
  final feedback = SentryFeedback(message: message, name: 'default');

  final content = Uint8List.fromList(utf8.encode(logs)).buffer.asByteData();

  await Sentry.captureFeedback(
    feedback,
    withScope: (scope) {
      // Create the attachment
      final attachment = SentryAttachment.fromByteData(
        content,
        'file.log',
        contentType: 'text/plain',
      );

      scope.addAttachment(attachment);
    },
  );
}

Future<bool> uploadSystemLog(String message) async {
  try {
    final log = await LogcatReader.readLog(lines: 1000);

    await uploadLog(message, log);
    return true;
  } catch (e) {
    log.warning('Failed to upload log', e);
    return false;
  }
}

DateTime? _lastFpsZeroUploadTime;

/// Upload system log for FPS zero detection (max once per hour)
Future<bool> uploadSystemLogForFpsZero(String message) async {
  // Check if upload is allowed (max once per hour)
  final now = DateTime.now();
  if (_lastFpsZeroUploadTime != null) {
    final timeSinceLastUpload = now.difference(_lastFpsZeroUploadTime!);
    if (timeSinceLastUpload.inHours < 1) {
      log.info(
        'FPS zero log upload skipped. Last upload was ${timeSinceLastUpload.inMinutes} minutes ago. '
        'Next upload allowed in ${60 - timeSinceLastUpload.inMinutes} minutes.',
      );
      return false;
    }
  }

  try {
    final logContent = await LogcatReader.readLog(lines: 1000);

    await uploadLog(message, logContent);
    _lastFpsZeroUploadTime = now;
    return true;
  } catch (e) {
    log.warning('Failed to upload FPS zero log', e);
    return false;
  }
}
