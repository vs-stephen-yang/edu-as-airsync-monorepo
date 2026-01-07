import 'package:display_cast_flutter/utilities/rtc_stats_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseQualityLimitationDurations', () {
    test('parses string map payload', () {
      final result =
          parseQualityLimitationDurations('{bandwidth:0,cpu:1.5,none:0.72,other:0}');

      expect(result['bandwidth'], 0);
      expect(result['cpu'], 1.5);
      expect(result['none'], 0.72);
      expect(result['other'], 0);
    });

    test('parses map input', () {
      final result = parseQualityLimitationDurations(
          {'bandwidth': 2, 'cpu': '3.1', 'none': 0.5});

      expect(result['bandwidth'], 2.0);
      expect(result['cpu'], 3.1);
      expect(result['none'], 0.5);
    });

    test('ignores invalid values', () {
      final result = parseQualityLimitationDurations('{bandwidth:abc}');

      expect(result.isEmpty, true);
    });
  });
}
