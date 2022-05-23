import 'dart:async';

import 'package:display_flutter/app_exception_report.dart';
import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/screens/eula.dart';
import 'package:display_flutter/screens/home.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<void> commonEntry(ConfigSettings settings) async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppPreferences.ensureInitialized();
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  await AppInstanceCreate.ensureInitialized(settings, packageInfo);

  var configureApp = AppConfig(
      settings: settings,
      appName: packageInfo.appName,
      appVersion: packageInfo.version,
      child: MyApp());

  await AppExceptionReport().ensureInitialized(settings, packageInfo);

  FlutterError.onError = (FlutterErrorDetails details) {
    // Report errors to a service
    AppExceptionReport().sendToServer(settings, packageInfo,
        details.exceptionAsString(), details.stack.toString());
  };

  runZonedGuarded(() => runApp(configureApp), (error, stack) {
    // Report errors to a service
    AppExceptionReport().sendToServer(
        settings, packageInfo, error.toString(), stack.toString());
  });
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.

  static void setLocale(BuildContext context, Locale newLocale) async {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLanguage(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();

}

class _MyAppState extends State<MyApp> {
  Locale? _locale = AppPreferences().locale;

  changeLanguage(Locale locale) {
    setState(() {
      _locale = AppPreferences().locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    // hide the Android Status Bar
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom],
    );

    return MaterialApp(
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ], //add
      supportedLocales: S.delegate.supportedLocales,
      locale: _locale,
      title: 'Display',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black, // Set app background color
      ),
      initialRoute:
          AppPreferences().showEULA && !AppInstanceCreate().isInstalledInVBS100
              ? '/eula'
              : '/home',
      navigatorKey: NavigationService.navigationKey,
      onGenerateRoute: (routeSettings) {
        switch (routeSettings.name) {
          case '/eula':
            return MaterialPageRoute<String>(
                builder: (context) => const Eula());
          case '/home':
            return MaterialPageRoute<String>(
                builder: (context) => const Home());
        }
        return null;
      },
      // home: const Home(),
    );
  }
}
