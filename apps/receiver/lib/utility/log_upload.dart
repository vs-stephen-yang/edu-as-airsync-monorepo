import 'dart:typed_data';
import 'dart:convert';
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
