import 'package:display_flutter/utility/log.dart';
import 'package:display_flutter/utility/log_upload.dart';

/// Log uploader with cooldown period to prevent excessive uploads
class LogUploaderWithCooldown {
  final String name;
  final Duration cooldownPeriod;
  DateTime? _lastUploadTime;

  LogUploaderWithCooldown({
    required this.name,
    this.cooldownPeriod = const Duration(hours: 1),
  });

  /// Upload system log with cooldown check
  Future<bool> upload(String message) async {
    // Check if upload is allowed based on cooldown period
    final now = DateTime.now();
    if (_lastUploadTime != null) {
      final timeSinceLastUpload = now.difference(_lastUploadTime!);
      if (timeSinceLastUpload < cooldownPeriod) {
        final timeUntilNext = cooldownPeriod - timeSinceLastUpload;
        log.info(
          '$name log upload skipped. Last upload was ${timeSinceLastUpload.inMinutes} minutes ago. '
          'Next upload allowed in ${timeUntilNext.inMinutes} minutes.',
        );
        return false;
      }
    }

    final result = await uploadSystemLog(message);
    if (result) {
      _lastUploadTime = now;
    }
    return result;
  }
}
