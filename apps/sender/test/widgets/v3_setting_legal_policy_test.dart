import 'package:auto_hyphenating_text/auto_hyphenating_text.dart';
import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/pref_text_scale_provider.dart';
import 'package:display_cast_flutter/providers/settings_provider.dart';
import 'package:display_cast_flutter/widgets/v3_setting_legal_policy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

Widget _buildTestWidget({TextSizeOption textSize = TextSizeOption.normal}) {
  final textScaleProvider = TextScaleProvider()..setTextSize(textSize);
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<SettingsProvider>(
        create: (_) => SettingsProvider(),
      ),
      ChangeNotifierProvider<TextScaleProvider>.value(value: textScaleProvider),
    ],
    child: MaterialApp(
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
          child: const V3SettingsLegalPolicy(),
        ),
      ),
    ),
  );
}

/// Finds the privacy policy row by its semantics identifier.
Finder get _privacyPolicyRow => find.byWidgetPredicate(
      (w) =>
          w is Semantics &&
          w.properties.identifier == 'v3_qa_setting_privacy_policy',
    );

// ─── Tests ────────────────────────────────────────────────────────────────────

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await initHyphenation();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('V3SettingsLegalPolicy - privacy policy row layout', () {
    testWidgets('IconButton is present at normal text scale',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      final iconButton = find.descendant(
        of: _privacyPolicyRow,
        matching: find.byType(IconButton),
      );
      expect(iconButton, findsOneWidget);
    });

    testWidgets('IconButton remains present at Large text scale (1.5)',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestWidget(textSize: TextSizeOption.large));
      await tester.pumpAndSettle();

      final iconButton = find.descendant(
        of: _privacyPolicyRow,
        matching: find.byType(IconButton),
      );
      expect(iconButton, findsOneWidget);
    });

    testWidgets('IconButton remains present at XLarge text scale (2.0)',
        (WidgetTester tester) async {
      // Regression test: before the fix, Spacer() pushed the IconButton
      // off-screen at large text scales. Expanded() keeps it accessible.
      await tester
          .pumpWidget(_buildTestWidget(textSize: TextSizeOption.xlarge));
      await tester.pumpAndSettle();

      final iconButton = find.descendant(
        of: _privacyPolicyRow,
        matching: find.byType(IconButton),
      );
      expect(iconButton, findsOneWidget);
    });

    testWidgets('no layout overflow at Large text scale',
        (WidgetTester tester) async {
      final List<FlutterErrorDetails> errors = [];
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) => errors.add(details);

      await tester.pumpWidget(_buildTestWidget(textSize: TextSizeOption.large));
      await tester.pumpAndSettle();

      FlutterError.onError = originalOnError;

      final overflowErrors =
          errors.where((e) => e.toString().contains('overflowed')).toList();
      expect(overflowErrors, isEmpty,
          reason: 'Privacy policy row must not overflow at Large text scale');
    });

    testWidgets('no layout overflow at XLarge text scale',
        (WidgetTester tester) async {
      final List<FlutterErrorDetails> errors = [];
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) => errors.add(details);

      await tester
          .pumpWidget(_buildTestWidget(textSize: TextSizeOption.xlarge));
      await tester.pumpAndSettle();

      FlutterError.onError = originalOnError;

      final overflowErrors =
          errors.where((e) => e.toString().contains('overflowed')).toList();
      expect(overflowErrors, isEmpty,
          reason: 'Privacy policy row must not overflow at XLarge text scale');
    });

    testWidgets(
        'IconButton in privacy policy row is within screen bounds at Large scale',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestWidget(textSize: TextSizeOption.large));
      await tester.pumpAndSettle();

      final iconButton = find.descendant(
        of: _privacyPolicyRow,
        matching: find.byType(IconButton),
      );
      expect(iconButton, findsOneWidget);

      final buttonRect = tester.getRect(iconButton);
      final screenWidth =
          tester.view.physicalSize.width / tester.view.devicePixelRatio;
      expect(
        buttonRect.right,
        lessThanOrEqualTo(screenWidth),
        reason: 'IconButton must not be pushed beyond the screen edge',
      );
    });

    testWidgets(
        'IconButton in privacy policy row is within screen bounds at XLarge scale',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(_buildTestWidget(textSize: TextSizeOption.xlarge));
      await tester.pumpAndSettle();

      final iconButton = find.descendant(
        of: _privacyPolicyRow,
        matching: find.byType(IconButton),
      );
      expect(iconButton, findsOneWidget);

      final buttonRect = tester.getRect(iconButton);
      final screenWidth =
          tester.view.physicalSize.width / tester.view.devicePixelRatio;
      expect(
        buttonRect.right,
        lessThanOrEqualTo(screenWidth),
        reason: 'IconButton must not be pushed beyond the screen edge',
      );
    });
  });
}
