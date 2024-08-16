import 'dart:async';

import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/pref_language_provider.dart';
import 'package:display_flutter/screens/overlay_tab.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

commonOverlayTabEntry() {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (FlutterErrorDetails details) async {
      log.severe('overlay tab details: $details');
    };

    runApp(Tokens(tokens: DefaultTokens(), child: const OverlayTabApp()));
  }, (error, stack) {
    log.severe('overlay tab error', error, stack);
  });
}

class OverlayTabApp extends StatelessWidget {
  const OverlayTabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: PrefLanguageProvider()),
      ],
      child: Consumer<PrefLanguageProvider>(
        builder: (_, prefLanguageProvider, __) {
          return MaterialApp(
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            //add
            supportedLocales: S.delegate.supportedLocales,
            locale: prefLanguageProvider.locale,
            title: 'AirSync Overlay Tab',
            debugShowCheckedModeBanner: false,
            home: const OverlayTab(),
          );
        },
      ),
    );
  }
}
