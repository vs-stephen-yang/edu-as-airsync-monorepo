import 'package:display_flutter/utility/channel_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('filterValidCertificates', () {
    test('should filter out expired certificates', () {
      final now = DateTime.now().toUtc();
      final certs = [
        {"date": now.subtract(Duration(days: 20)).toIso8601String()}, // Expired
        {"date": now.subtract(Duration(days: 2)).toIso8601String()} // Valid
      ];

      final validCerts = filterValidCertificates(certs);
      expect(validCerts.length, 1);
    });

    test('should return an empty list if all certificates are expired', () {
      final now = DateTime.now().toUtc();
      final certs = [
        {"date": now.subtract(Duration(days: 30)).toIso8601String()},
        {"date": now.subtract(Duration(days: 25)).toIso8601String()}
      ];

      final validCerts = filterValidCertificates(certs);
      expect(validCerts, isEmpty);
    });
  });
}
