import 'dart:async';

import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/pref_language_provider.dart';
import 'package:display_flutter/screens/overlay_tab.dart';
import 'package:display_flutter/utility/print_in_debug.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

commonOverlayTabEntry() {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (FlutterErrorDetails details) async {
      printInDebug('overlay tab details: $details');
    };

    runApp(const OverlayTabApp());
  }, (error, stack) {
    printInDebug('overlay tab error: $error, stack: $stack');
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
