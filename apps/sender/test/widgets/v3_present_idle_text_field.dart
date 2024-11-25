import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/widgets/v3_present_idle_text_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

void main() {
  // Helper method to match the component's formatting logic
  String getDisplayCodeVisualIdentity(String displayCode) {
    String result = displayCode;
    if (displayCode.length > 4) {
      result = displayCode
          .replaceAllMapped(RegExp(r".{4}"), (match) => "${match.group(0)} ")
          .trimRight();
    }
    return result;
  }

  group('V3PresentIdleTextField', () {
    late Widget testWidget;
    late String Function(V3FieldResult) onFieldChangedCallback;
    late String lastDisplayCode;
    setUp(() {
      lastDisplayCode = '';
      onFieldChangedCallback = (result) {
        lastDisplayCode = result.displayCode;
        return lastDisplayCode;
      };

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
              ),
            ),
          ),
        ),
      );
    });

    group('Input Validation', () {
      testWidgets('Should handle numeric input', (WidgetTester tester) async {
        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        final textField = find.byType(TextFormField).first;

        // Try mixed input
        await tester.enterText(textField, 'abc123def456');
        await tester.pump();

        final formattedText = getDisplayCodeVisualIdentity('123456');

        expect(find.text(formattedText), findsOneWidget);
        expect(lastDisplayCode, '123456');
      });

      testWidgets(
          'Should respect platform-specific maximum length - Windows / Web',
          (WidgetTester tester) async {
        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        final textField = find.byType(TextFormField).first;
        const maxLength = 13;
        const testInput = '12345678901';

        await tester.enterText(textField, testInput);
        await tester.pump();

        expect(lastDisplayCode.length, maxLength - 2);

        final TextFormField textFormField = tester.widget(textField);
        final actualText = textFormField.controller!.text;
        expect(actualText, '1234 5678 901');
      });

      testWidgets(
          'Should respect platform-specific maximum length - android / iOS',
          (WidgetTester tester) async {
        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        final textField = find.byType(TextFormField).first;
        const maxLength = 11;
        const testInput = '12345678901';

        await tester.enterText(textField, testInput);
        await tester.pump();

        expect(lastDisplayCode.length, maxLength);

        final TextFormField textFormField = tester.widget(textField);
        final actualText = textFormField.controller!.text;
        expect(actualText, '1234 5678 901');
      });
    });

    group('Formatting', () {
      testWidgets('should format text with spaces correctly',
          (WidgetTester tester) async {
        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        final textField = find.byType(TextFormField).first;

        // Test different lengths
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

      testWidgets('should maintain raw value without spaces',
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

    group('Cursor Position', () {
      testWidgets('Should maintain cursor position when adding digits',
          (WidgetTester tester) async {
        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        final textField = find.byType(TextFormField).first;

        await tester.pumpAndSettle();
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
        expect(editableTextState.textEditingValue.selection.baseOffset,
            4); // 1239| 4567 8
      });

      testWidgets('Should handle deletion of space, cursor does not move',
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

        expect(controller.text, '1234 5678');
        expect(controller.selection.baseOffset, 4);
      });

      testWidgets(
          'Should handle deletion of digit before space, cursor does not move',
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
        expect(controller.selection.baseOffset, 4); // 1234| 678
      });
    });

    group('MaxLength Behavior', () {
      testWidgets('Should respect maxLength for raw text (without spaces)',
          (WidgetTester tester) async {
        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        final textField = find.byType(TextFormField).first;
        final maxLength = (!WebRTC.platformIsWindows && !kIsWeb) ? 11 : 13;

        await tester.enterText(textField, '1' * (maxLength + 2));
        await tester.pump();

        expect(lastDisplayCode.length, maxLength);
      });

      testWidgets('Should format text correctly at maxLength for Android / iOS',
          (WidgetTester tester) async {
        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        final textField = find.byType(TextFormField).first;
        const maxLength = 11;
        final enter = '1' * maxLength;

        await tester.enterText(textField, enter);
        await tester.pump();

        final formattedText =
            tester.widget<TextFormField>(textField).controller!.text;
        expect(formattedText.replaceAll(' ', '').length, maxLength);

        final spaceCount =
            formattedText.split('').where((c) => c == ' ').length;
        expect(spaceCount, (maxLength - 1) ~/ 4);
      });

      testWidgets('Should format text correctly at maxLength for Windows / Web',
          (WidgetTester tester) async {
        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        final textField = find.byType(TextFormField).first;
        const maxLength = 13;

        final enter = '1' * maxLength;
        await tester.enterText(textField, enter);
        await tester.pump();

        final formattedText =
            tester.widget<TextFormField>(textField).controller!.text;
        expect(formattedText.replaceAll(' ', '').length, maxLength - 2);

        final spaceCount =
            formattedText.split('').where((c) => c == ' ').length;
        expect(spaceCount, (maxLength - 2) ~/ 4);
      });
    });

    group('Edge Cases', () {
      testWidgets('Should handle insertion at space position',
          (WidgetTester tester) async {
        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        final textField = find.byType(TextFormField).first;
        final TextFormField textFormField = tester.widget(textField);
        final controller = textFormField.controller!;

        // First enter some text
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

      testWidgets('Should handle text selection and replacement',
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

      testWidgets('Should handle rapid input', (WidgetTester tester) async {
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
