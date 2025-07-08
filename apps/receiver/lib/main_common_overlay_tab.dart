import 'dart:async';

import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/pref_language_provider.dart';
import 'package:display_flutter/screens/overlay_tab.dart';
import 'package:display_flutter/screens/v3_overlay_tab.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/settings/theme_config.dart';
import 'package:display_flutter/utility/device_feature_adapter.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:display_flutter/utility/sentry_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

commonOverlayTabEntry(ConfigSettings settings) {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    if (settings.sentry != null) {
      initSentry(settings.sentry!);
    }

    await DeviceFeatureAdapter.ensureInitialized();

    await AppPreferences.ensureInitialized();

    FlutterError.onError = (FlutterErrorDetails details) async {
      log.severe('overlay tab details: $details');
    };

    runApp(Tokens(tokens: DefaultTokens(), child: const OverlayTabApp()));
  }, (error, stack) async {
    await Sentry.captureException(error, stackTrace: stack);
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
            theme: createThemeData(context),
            home: !DeviceFeatureAdapter.showOldUI
                ? const V3OverlayTab()
                : const OverlayTab(),
            builder: (context, child) {
              return ValueListenableBuilder(
                valueListenable: AppPreferences().textSizeOptionNotifier,
                builder: (context, _, __) {
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                        textScaler:
                            TextScaler.linear(AppPreferences().textScale)),
                    child: child!,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
