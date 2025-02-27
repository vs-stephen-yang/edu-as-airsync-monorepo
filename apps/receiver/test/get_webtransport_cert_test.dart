import 'package:display_flutter/utility/channel_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('filterValidCertificates', () {
    test('should filter out expired certificates', () {
      // Arrange
      final now = DateTime.now().toUtc();
      final certs = [
        {"date": now.subtract(const Duration(days: 20)).toIso8601String()}, // Expired
        {"date": now.subtract(const Duration(days: 2)).toIso8601String()} // Valid
      ];

      // Act
      final validCerts = filterValidCertificates(certs);

      // Assert
      expect(validCerts.length, equals(1));
    });

    test('should return an empty list if all certificates are expired', () {
      // Arrange
      final now = DateTime.now().toUtc();
      final certs = [
        {"date": now.subtract(const Duration(days: 30)).toIso8601String()}, // Expired
        {"date": now.subtract(const Duration(days: 25)).toIso8601String()} // Expired
      ];

      // Act
      final validCerts = filterValidCertificates(certs);

      // Assert
      expect(validCerts, isEmpty);
    });
  });
}
