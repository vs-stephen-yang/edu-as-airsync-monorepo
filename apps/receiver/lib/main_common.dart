import 'dart:async';

import 'package:display_flutter/app_exception_report.dart';
import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/screens/eula.dart';
import 'package:display_flutter/screens/home.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<void> commonEntry(ConfigSettings settings) async {
  WidgetsFlutterBinding.ensureInitialized();

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  await AppInstanceCreate.ensureInitialized(settings, packageInfo);

  var configureApp = AppConfig(
      settings: settings,
      appName: packageInfo.appName,
      appVersion: packageInfo.version,
      child: const MyApp());

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

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // hide the Android Status Bar
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom],
    );

    return MaterialApp(
      title: 'Display',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/home',
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
