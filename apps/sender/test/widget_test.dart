// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:display_cast_flutter/utilities/v3_update_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('compareVersion', () {
    test('returns forceUpgrade when current version is less than min version',
        () {
      final result =
          V3UpdateManager().compareVersion('3.3.8-s', '3.3.10', '3.3.10');
      expect(result, CompareVersionResult.forceUpgrade);
    });

    test(
        'returns forceUpgrade when current version with multiple digits is less than min version',
        () {
      final result =
          V3UpdateManager().compareVersion('3.3.11', '3.4.5', '3.4.5');
      expect(result, CompareVersionResult.forceUpgrade);
    });

    test('returns userChoose when current version is less than target version',
        () {
      final result =
          V3UpdateManager().compareVersion('3.3.8-d', '3.3.11', '3.3.8');
      expect(result, CompareVersionResult.userChoose);
    });

    test('returns none when current version is equal to target version', () {
      final result =
          V3UpdateManager().compareVersion('3.3.10-s', '3.3.10', '3.3.8');
      expect(result, CompareVersionResult.noUpdate);
    });

    test('returns none when current version is greater than target version',
        () {
      final result =
          V3UpdateManager().compareVersion('3.4.5', '3.4.4', '3.3.11');
      expect(result, CompareVersionResult.noUpdate);
    });

    test('returns none when current version is equal with target version', () {
      final result =
          V3UpdateManager().compareVersion('3.4.5', '3.4.5', '3.3.11');
      expect(result, CompareVersionResult.noUpdate);
    });

    test('handles versions with multiple digits', () {
      final result =
          V3UpdateManager().compareVersion('10.0.0', '2.0.0', '1.0.0');
      expect(result, CompareVersionResult.noUpdate);
    });

    test('handles versions with multiple sections', () {
      final result =
          V3UpdateManager().compareVersion('1.0.0.1', '1.0.0.2', '1.0.0.0');
      expect(result, CompareVersionResult.userChoose);
    });
  });
}
