import 'package:display_flutter/utility/misc_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('getDisplayCodeVisualIdentity', () {
    test('should return original code when length is 5 or less', () {
      // Arrange & Act & Assert
      expect(getDisplayCodeVisualIdentity(''), '');
      expect(getDisplayCodeVisualIdentity('1'), '1');
      expect(getDisplayCodeVisualIdentity('12'), '12');
      expect(getDisplayCodeVisualIdentity('123'), '123');
      expect(getDisplayCodeVisualIdentity('1234'), '1234');
      expect(getDisplayCodeVisualIdentity('12345'), '12345');
    });

    test(
        'should format code with spaces every 4 characters when length > 5', () {
      // Test 6 characters
      expect(getDisplayCodeVisualIdentity('123456'), '1234 56');

      // Test 8 characters
      expect(getDisplayCodeVisualIdentity('12345678'), '1234 5678');

      // Test 9 characters
      expect(getDisplayCodeVisualIdentity('123456789'), '1234 5678 9');

      // Test 12 characters
      expect(getDisplayCodeVisualIdentity('123456789012'), '1234 5678 9012');

      // Test 13 characters
      expect(getDisplayCodeVisualIdentity('1234567890123'), '1234 5678 9012 3');
    });

    test('should not add trailing spaces', () {
      // Test that trimRight() works correctly
      expect(getDisplayCodeVisualIdentity('12345678'), '1234 5678');
      expect(getDisplayCodeVisualIdentity('123456789012'), '1234 5678 9012');

      // Verify no trailing spaces
      String result = getDisplayCodeVisualIdentity('12345678');
      expect(result.endsWith(' '), false);
    });
  });
}