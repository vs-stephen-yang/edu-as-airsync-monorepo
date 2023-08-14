import 'package:desktop_window/desktop_window.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/pref_language_provider.dart';
import 'package:display_cast_flutter/screens/home.dart';
import 'package:display_cast_flutter/settings/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

void commonEntry(ConfigSettings settings) async {
  WidgetsFlutterBinding.ensureInitialized();
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  await DesktopWindow.setWindowSize(const Size(1280,720));
  await DesktopWindow.setMinWindowSize(const Size(1280,720));

  runApp(AppConfig(
    settings: settings,
    appName: packageInfo.appName,
    appVersion: packageInfo.version,
    appVersionCode: int.parse(packageInfo.buildNumber),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // hide the Android Status Bar
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom],
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: PrefLanguageProvider()),
      ],
      child: Consumer<PrefLanguageProvider>(
        builder: (context, languageModel, child) {
          return MaterialApp(
            title: 'AirSync Sender',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            locale: languageModel.locale,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: Colors.black, // Set app background color
            ),
            initialRoute: '/home',
            navigatorKey: NavigationService.navigationKey,
            routes: {
              // for 'navService.popUntil('/home')'
              '/home': (context) => const Home(),
            },
            onGenerateRoute: (routeSettings) {
              switch (routeSettings.name) {
                case '/home':
                  return MaterialPageRoute<String>(
                      builder: (context) => const Home());
              }
              return null;
            },
            // home: const Home(),
          );
        },
      ),
    );
  }
}
