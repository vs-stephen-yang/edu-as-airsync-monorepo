import 'package:display_cast_flutter/utilities/web_util.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
    group('WebTransportUtils.filterValidHashes', () {
      test('should return valid hashes within the date range', () {
        final now = DateTime.now().toUtc();
        final certs = [
          {
            "date": now.subtract(Duration(days: 3)).toIso8601String(),
            "hash": "ABC123 "
          },
          {
            "date": now.subtract(Duration(days: 1)).toIso8601String(),
            "hash": " DEF456"
          }
        ];

        final result = filterValidHashes(certs, now);

        expect(result, contains("ABC123"));
        expect(result, contains("DEF456"));
      });

      test('should return an empty list if all certificates are expired', () {
        final now = DateTime.now().toUtc();
        final certs = [
          {
            "date": now.subtract(Duration(days: 20)).toIso8601String(),
            "hash": "XYZ789"
          }
        ];

        final result = filterValidHashes(certs, now);

        expect(result, isEmpty);
      });

      test('should return an empty list if all certificates are in the future', () {
        final now = DateTime.now().toUtc();
        final certs = [
          {
            "date": now.add(Duration(days: 5)).toIso8601String(),
            "hash": "FUTURE123"
          }
        ];

        final result = filterValidHashes(certs, now);

        expect(result, isEmpty);
      });

      test('should handle trimmed and formatted hashes correctly', () {
        final now = DateTime.now().toUtc();
        final certs = [
          {
            "date": now.subtract(Duration(days: 5)).toIso8601String(),
            "hash": "  A1 B2 C3  "
          }
        ];

        final result = filterValidHashes(certs, now);

        expect(result, contains("A1B2C3"));
      });

      test('should return multiple valid hashes when within the date range', () {
        final now = DateTime.now().toUtc();
        final certs = [
          {
            "date": now.subtract(Duration(days: 2)).toIso8601String(),
            "hash": "HASH1"
          },
          {
            "date": now.subtract(Duration(days: 10)).toIso8601String(),
            "hash": "HASH2"
          },
          {
            "date": now.subtract(Duration(days: 15)).toIso8601String(), // Expired
            "hash": "EXPIRED"
          }
        ];

        final result = filterValidHashes(certs, now);

        expect(result.length, equals(2));
        expect(result, contains("HASH1"));
        expect(result, contains("HASH2"));
        expect(result, isNot(contains("EXPIRED")));
      });
    });
}