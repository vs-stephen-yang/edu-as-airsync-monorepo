import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_auto_enroll.dart';
import 'package:display_flutter/app_exception_report.dart';
import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/bean/display_message.dart';
import 'package:display_flutter/model/control_socket.dart';
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
      child: const MyApp());

  if (AppInstanceCreate().isRegistered && AppPreferences().entityId.isEmpty) {
    String entityId = await AppAutoEnroll()
        .getEnrollInformation(settings, AppInstanceCreate().displayInstanceID);
    if (entityId.isNotEmpty) {
      AppPreferences().set(entityId: entityId);
    }
  }

  await AppExceptionReport().ensureInitialized(settings, packageInfo);
  await AppAnalytics().ensureInitialized(settings);
  AppAnalytics().setEventProperties(
      entityId: AppPreferences().entityId,
      instanceId: AppInstanceCreate().displayInstanceID);

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
  const MyApp({Key? key}) : super(key: key);
  static ValueNotifier<bool> updatedLocale = ValueNotifier(false);

  static void setNewLocale(BuildContext context, int index) async {
    String newLanguage = AppPreferences.localeMap.keys.elementAt(index);
    AppPreferences().set(language: newLanguage);

    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLanguage(AppPreferences().locale);

    updatedLocale.value = !updatedLocale.value;
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Locale? _locale = AppPreferences().locale;

  changeLanguage(Locale? locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    AppAnalytics().trackEventAppStarted();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    log('AppLifecycleState: $state');
    if (state == AppLifecycleState.inactive) {
      ControlSocket().updateAllAudioEnableState(false);
    } else if (state == AppLifecycleState.resumed) {
      ControlSocket().updateAllAudioEnableState(true);
    }
  }

  @override
  Future<bool> didPopRoute() async {
    if (!Platform.isAndroid) {
      NavigatorState? navigatorState =
          NavigationService.navigationKey.currentState;
      if (navigatorState != null && !navigatorState.canPop()) {
        ControlSocket().disconnectControlSocket();
        AppAnalytics().trackEventAppTerminated();

        Moderator? moderator = ControlSocket().moderator;
        if (moderator != null) {
          AppConfig? appConfig = AppConfig.of(context);
          if (appConfig != null) {
            ControlSocket()
                .unbindModerator(appConfig.settings.apiGateway, moderator);
          }
        }
        // wait one second for handle above process.
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    return Future<bool>.value(false);
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
      ],
      //add
      supportedLocales: S.delegate.supportedLocales,
      locale: _locale,
      title: 'Display',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black, // Set app background color
      ),
      initialRoute: AppPreferences().showEULA &&
              !AppInstanceCreate().isInstalledInVBS100 &&
              !AppInstanceCreate().isNoneTouchModel
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
