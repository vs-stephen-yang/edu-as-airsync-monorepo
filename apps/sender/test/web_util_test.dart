import 'package:display_cast_flutter/utilities/web_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WebTransportUtils.filterValidHashes', () {
    test('should return valid hashes within the date range', () {
      // Arrange
      final now = DateTime.now().toUtc();
      final certs = [
        {
          "date": now.subtract(const Duration(days: 3)).toIso8601String(),
          "hash": "ABC123 "
        },
        {
          "date": now.subtract(const Duration(days: 1)).toIso8601String(),
          "hash": " DEF456"
        }
      ];

      // Act
      final result = filterValidHashes(certs, now);

      // Assert
      expect(result, contains("ABC123"));
      expect(result, contains("DEF456"));
    });

    test('should return an empty list if all certificates are expired', () {
      // Arrange
      final now = DateTime.now().toUtc();
      final certs = [
        {
          "date": now.subtract(const Duration(days: 20)).toIso8601String(),
          "hash": "XYZ789"
        }
      ];

      // Act
      final result = filterValidHashes(certs, now);

      // Assert
      expect(result, isEmpty);
    });

    test('should return an empty list if all certificates are in the future', () {
      // Arrange
      final now = DateTime.now().toUtc();
      final certs = [
        {
          "date": now.add(const Duration(days: 5)).toIso8601String(),
          "hash": "FUTURE123"
        }
      ];

      // Act
      final result = filterValidHashes(certs, now);

      // Assert
      expect(result, isEmpty);
    });

    test('should handle trimmed and formatted hashes correctly', () {
      // Arrange
      final now = DateTime.now().toUtc();
      final certs = [
        {
          "date": now.subtract(const Duration(days: 5)).toIso8601String(),
          "hash": "  A1 B2 C3  "
        }
      ];

      // Act
      final result = filterValidHashes(certs, now);

      // Assert
      expect(result, contains("A1B2C3"));
    });

    test('should return multiple valid hashes when within the date range', () {
      // Arrange
      final now = DateTime.now().toUtc();
      final certs = [
        {
          "date": now.subtract(const Duration(days: 2)).toIso8601String(),
          "hash": "HASH1"
        },
        {
          "date": now.subtract(const Duration(days: 10)).toIso8601String(),
          "hash": "HASH2"
        },
        {
          "date": now.subtract(const Duration(days: 15)).toIso8601String(), // Expired
          "hash": "EXPIRED"
        }
      ];

      // Act
      final result = filterValidHashes(certs, now);

      // Assert
      expect(result.length, equals(2));
      expect(result, contains("HASH1"));
      expect(result, contains("HASH2"));
      expect(result, isNot(contains("EXPIRED")));
    });
  });
}
