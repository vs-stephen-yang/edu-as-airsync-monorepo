import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/widgets/v3_present_idle_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

// ----------------- Add：Create a testable PlatformDetector implementation -----------------
class TestPlatformDetector extends PlatformDetector {
  final bool forceWindows;
  final bool forceWeb;

  const TestPlatformDetector({
    required this.forceWindows,
    required this.forceWeb,
  });

  @override
  bool get isWindows => forceWindows;

  @override
  bool get isWeb => forceWeb;

  @override
  bool get notWindowsNeitherWeb => !isWindows && !isWeb;

  @override
  bool get windowsOrWeb => isWindows || isWeb;
}
// ------------------------------------------------------------------------

enum TestPlatform {
  macos,
  windows,
  web,
  android,
  ios,
  linux,
}

/// Map the [TestPlatform] to [TestPlatformDetector]
TestPlatformDetector mapTestPlatformToDetector(TestPlatform platform) {
  switch (platform) {
    case TestPlatform.windows:
      return const TestPlatformDetector(forceWindows: true, forceWeb: false);
    case TestPlatform.web:
      return const TestPlatformDetector(forceWindows: false, forceWeb: true);
    case TestPlatform.macos:
    case TestPlatform.android:
    case TestPlatform.ios:
    case TestPlatform.linux:
      return const TestPlatformDetector(forceWindows: false, forceWeb: false);
  }
}

String getDisplayCodeVisualIdentity(String displayCode) {
  String result = displayCode;
  if (displayCode.length > 4) {
    result = displayCode
        .replaceAllMapped(RegExp(r".{4}"), (match) => "${match.group(0)} ")
        .trimRight();
  }
  return result;
}

void main() {
  final platformVariants = ValueVariant<TestPlatform>({
    TestPlatform.macos,
    TestPlatform.windows,
    TestPlatform.web,
    TestPlatform.android,
    TestPlatform.ios,
    TestPlatform.linux,
  });

  for (final platform in platformVariants.values) {
    group('Platform: $platform', () {
      late Widget testWidget;
      late String Function(V3FieldResult) onFieldChangedCallback;
      late String lastDisplayCode;
      final bool isWindows = (platform == TestPlatform.windows);
      final bool isWeb = (platform == TestPlatform.web);

      int getMaxLength(bool isWindows, bool isWeb) {
        // Windows or Web => 13
        // macOS / android / iOS / linux => 11
        if (!isWindows && !isWeb) {
          return 11;
        } else {
          return 13;
        }
      }

      setUp(() {
        lastDisplayCode = '';
        onFieldChangedCallback = (result) {
          lastDisplayCode = result.displayCode;
          return lastDisplayCode;
        };

        final platformDetector = mapTestPlatformToDetector(platform);

        testWidget = MaterialApp(
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: Scaffold(
            body: Tokens(
              tokens: DefaultTokens(),
              child: SizedBox(
                height: 200,
                child: V3PresentIdleTextField(
                  widthTextField: 300,
                  onFieldChanged: (result) => onFieldChangedCallback(result),
                  onPasswordEnterEvent: (value) {},
                  platformDetector: platformDetector,
                ),
              ),
            ),
          ),
        );
      });

      // -----------------------------------------
      // Input Validation - Apart numeric input test
      // -----------------------------------------
      group('Input Validation (Numeric Input)', () {
        if (isWindows || isWeb) {
          // Windows / Web => Error message when input alpha+num
          testWidgets('[$platform] Should show error when input alpha+num',
              (WidgetTester tester) async {
            await tester.pumpWidget(testWidget);
            await tester.pumpAndSettle();

            final textField = find.byType(TextFormField).first;
            await tester.enterText(textField, 'abc123def456');
            await tester.pump();

            // When encountering non-numeric characters, set errorMsg & do not update displayCode
            expect(lastDisplayCode, '');
            expect(find.textContaining('Only accept numbers.'), findsOneWidget);
          });
        } else {
          // Filter out non-numeric characters
          testWidgets('[$platform] Should filter alpha+num => keep only digits',
              (WidgetTester tester) async {
            await tester.pumpWidget(testWidget);
            await tester.pumpAndSettle();

            final textField = find.byType(TextFormField).first;
            await tester.enterText(textField, 'abc123def456');
            await tester.pump();

            final formattedText = getDisplayCodeVisualIdentity('123456');
            expect(find.text(formattedText), findsOneWidget);
            expect(lastDisplayCode, '123456');
          });
        }
      });

      group('Input Validation (MaxLength)', () {
        testWidgets(
            '[$platform] Should respect platform-specific maximum length - Windows / Web',
            (WidgetTester tester) async {
          if (!isWindows && !isWeb) return;

          await tester.pumpWidget(testWidget);
          await tester.pumpAndSettle();

          final textField = find.byType(TextFormField).first;
          const testInput = '12345678901';

          await tester.enterText(textField, testInput);
          await tester.pump();

          final currentMaxLength = getMaxLength(isWindows, isWeb);
          expect(lastDisplayCode.length, currentMaxLength - 2);

          final TextFormField textFormField = tester.widget(textField);
          final actualText = textFormField.controller!.text;
          expect(actualText, '1234 5678 901');
        });

        testWidgets(
            '[$platform] Should respect platform-specific maximum length - macOS/android/iOS/linux',
            (WidgetTester tester) async {
          if (isWindows || isWeb) return;

          await tester.pumpWidget(testWidget);
          await tester.pumpAndSettle();

          final textField = find.byType(TextFormField).first;
          const testInput = '12345678901';

          await tester.enterText(textField, testInput);
          await tester.pump();

          final currentMaxLength = getMaxLength(isWindows, isWeb);
          expect(lastDisplayCode.length, currentMaxLength);

          final TextFormField textFormField = tester.widget(textField);
          final actualText = textFormField.controller!.text;
          expect(actualText, '1234 5678 901');
        });
      });

      // -----------------------------------------
      // Formatting
      // -----------------------------------------
      group('Formatting', () {
        testWidgets('[$platform] should format text with spaces correctly',
            (WidgetTester tester) async {
          await tester.pumpWidget(testWidget);
          await tester.pumpAndSettle();

          final textField = find.byType(TextFormField).first;

          final testCases = [
            {'input': '1234', 'expected': '1234'},
            {'input': '12345', 'expected': '1234 5'},
            {'input': '12345678', 'expected': '1234 5678'},
            {'input': '12345678901', 'expected': '1234 5678 901'},
          ];

          for (final testCase in testCases) {
            await tester.enterText(textField, testCase['input']!);
            await tester.pump();
            expect(find.text(testCase['expected']!), findsOneWidget);
          }
        });

        testWidgets('[$platform] should maintain raw value without spaces',
            (WidgetTester tester) async {
          await tester.pumpWidget(testWidget);
          await tester.pumpAndSettle();

          final textField = find.byType(TextFormField).first;
          await tester.enterText(textField, '12345678');
          await tester.pump();

          expect(find.text('1234 5678'), findsOneWidget);
          expect(lastDisplayCode, '12345678');
        });
      });

      // -----------------------------------------
      // Cursor Position
      // -----------------------------------------
      group('Cursor Position', () {
        testWidgets(
            '[$platform] Should maintain cursor position when adding digits',
            (WidgetTester tester) async {
          await tester.pumpWidget(testWidget);
          await tester.pumpAndSettle();

          final textField = find.byType(TextFormField).first;
          await tester.enterText(textField, '1234 5678');
          await tester.pumpAndSettle();

          final edit = find.byType(EditableText);
          final EditableTextState editableTextState = tester.state(edit.first);

          editableTextState.userUpdateTextEditingValue(
            const TextEditingValue(
              text: '1234 5678',
              selection: TextSelection.collapsed(offset: 3),
            ),
            SelectionChangedCause.keyboard,
          );
          await tester.pumpAndSettle();

          final currentValue = editableTextState.textEditingValue;
          final newText = currentValue.text.replaceRange(
            currentValue.selection.baseOffset,
            currentValue.selection.baseOffset,
            '9',
          );
          editableTextState.userUpdateTextEditingValue(
            TextEditingValue(
              text: newText,
              selection: TextSelection.collapsed(
                  offset: currentValue.selection.baseOffset + 1),
            ),
            SelectionChangedCause.keyboard,
          );
          await tester.pumpAndSettle();

          expect(editableTextState.textEditingValue.text, '1239 4567 8');
          expect(editableTextState.textEditingValue.selection.baseOffset, 4);
        });

        testWidgets(
            '[$platform] Should handle deletion of space, cursor does not move',
            (WidgetTester tester) async {
          await tester.pumpWidget(testWidget);
          await tester.pumpAndSettle();

          final textField = find.byType(TextFormField).first;
          final TextFormField textFormField = tester.widget(textField);
          final controller = textFormField.controller!;

          await tester.enterText(textField, '12345678');
          await tester.pump();

          controller.selection = const TextSelection.collapsed(offset: 4);
          await tester.sendKeyEvent(LogicalKeyboardKey.delete);
          await tester.pump();

          // Delete space does not affect cursor position
          expect(controller.text, '1234 5678');
          expect(controller.selection.baseOffset, 4);
        });

        testWidgets(
            '[$platform] Should handle deletion of digit before space, cursor does not move',
            (WidgetTester tester) async {
          await tester.pumpWidget(testWidget);
          await tester.pumpAndSettle();

          final textField = find.byType(TextFormField).first;
          final TextFormField textFormField = tester.widget(textField);
          final controller = textFormField.controller!;

          await tester.enterText(textField, '12345678');
          await tester.pump();

          controller.selection = const TextSelection.collapsed(offset: 5);
          await tester.sendKeyEvent(LogicalKeyboardKey.delete);
          await tester.pump();

          expect(find.text('1234 678'), findsOneWidget);

          if (isWindows || isWeb) {
            expect(controller.selection.baseOffset, 5);
          } else {
            expect(controller.selection.baseOffset, 4);
          }
        });
      });

      // -----------------------------------------
      // MaxLength Behavior
      // -----------------------------------------
      group('MaxLength Behavior', () {
        testWidgets(
            '[$platform] Should respect maxLength for raw text (without spaces)',
            (WidgetTester tester) async {
          await tester.pumpWidget(testWidget);
          await tester.pumpAndSettle();

          final textField = find.byType(TextFormField).first;
          final currentMaxLength = getMaxLength(isWindows, isWeb);

          // 輸入比最大長度還多2碼
          await tester.enterText(textField, '1' * (currentMaxLength + 2));
          await tester.pump();

          // 最終的 raw code 長度應該被限制在 currentMaxLength
          expect(lastDisplayCode.length, currentMaxLength);
        });

        testWidgets(
            '[$platform] Should format text correctly at maxLength for macOS/android/iOS/linux',
            (WidgetTester tester) async {
          if (isWindows || isWeb) return;

          await tester.pumpWidget(testWidget);
          await tester.pumpAndSettle();

          final textField = find.byType(TextFormField).first;
          final currentMaxLength = getMaxLength(isWindows, isWeb);
          final enter = '1' * currentMaxLength;

          await tester.enterText(textField, enter);
          await tester.pump();

          final formattedText =
              tester.widget<TextFormField>(textField).controller!.text;
          // Length of formatted text = 11
          expect(formattedText.replaceAll(' ', '').length, currentMaxLength);

          final spaceCount =
              formattedText.split('').where((c) => c == ' ').length;
          expect(spaceCount, (currentMaxLength - 1) ~/ 4);
        });

        testWidgets(
            '[$platform] Should format text correctly at maxLength for Windows / Web',
            (WidgetTester tester) async {
          if (!isWindows && !isWeb) return;

          await tester.pumpWidget(testWidget);
          await tester.pumpAndSettle();

          final textField = find.byType(TextFormField).first;
          final currentMaxLength = getMaxLength(isWindows, isWeb);
          final enter = '1' * currentMaxLength;

          await tester.enterText(textField, enter);
          await tester.pump();

          final formattedText =
              tester.widget<TextFormField>(textField).controller!.text;
          expect(formattedText.replaceAll(' ', '').length, currentMaxLength);

          final spaceCount =
              formattedText.split('').where((c) => c == ' ').length;
          expect(spaceCount, currentMaxLength ~/ 4);
        });
      });

      // -----------------------------------------
      // Edge Cases
      // -----------------------------------------
      group('Edge Cases', () {
        testWidgets('[$platform] Should handle insertion at space position',
            (WidgetTester tester) async {
          await tester.pumpWidget(testWidget);
          await tester.pumpAndSettle();

          final textField = find.byType(TextFormField).first;
          final TextFormField textFormField = tester.widget(textField);
          final controller = textFormField.controller!;

          await tester.enterText(textField, '12345678');
          await tester.pump();
          expect(find.text('1234 5678'), findsOneWidget);

          controller.selection = const TextSelection.collapsed(offset: 4);
          await tester.pump();

          controller.text = '12349 5678';
          controller.selection = const TextSelection.collapsed(offset: 10);
          await tester.pump();

          expect(find.text('12349 5678'), findsOneWidget);
          expect(controller.selection.baseOffset, 10);
        });

        testWidgets('[$platform] Should handle text selection and replacement',
            (WidgetTester tester) async {
          await tester.pumpWidget(testWidget);
          await tester.pumpAndSettle();

          final textField = find.byType(TextFormField).first;
          final TextFormField textFormField = tester.widget(textField);
          final controller = textFormField.controller!;

          await tester.enterText(textField, '12345678');
          await tester.pump();
          expect(find.text('1234 5678'), findsOneWidget);

          controller.selection =
              const TextSelection(baseOffset: 3, extentOffset: 6);
          await tester.pump();

          controller.text = '1239 5678';
          controller.selection = const TextSelection.collapsed(offset: 4);
          await tester.pump();

          expect(find.text('1239 5678'), findsOneWidget);
        });

        testWidgets('[$platform] Should handle rapid input',
            (WidgetTester tester) async {
          await tester.pumpWidget(testWidget);
          await tester.pumpAndSettle();

          final textField = find.byType(TextFormField).first;

          for (int i = 1; i <= 8; i++) {
            await tester.enterText(textField, '1' * i);
            await tester.pump(const Duration(milliseconds: 1));
          }

          expect(find.text('1111 1111'), findsOneWidget);
        });
      });
    });
  }
}
