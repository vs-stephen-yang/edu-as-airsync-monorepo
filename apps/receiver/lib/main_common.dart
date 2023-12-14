import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_exception_report.dart';
import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/app_update_helper.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/bean/display_message.dart';
import 'package:display_flutter/model/control_socket.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/screens/eula.dart';
import 'package:display_flutter/screens/home.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/widgets/app_ota_dialog.dart';
import 'package:display_flutter/widgets/main_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

Future<void> commonEntry(ConfigSettings settings) async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await AppPreferences.ensureInitialized();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    await AppInstanceCreate.ensureInitialized(settings, packageInfo);

    var configureApp = AppConfig(
        settings: settings,
        appName: packageInfo.appName,
        appVersion: packageInfo.version,
        child: const MyApp());

    await AppExceptionReport().ensureInitialized(settings, packageInfo);
    await AppAnalytics().ensureInitialized(settings);
    AppAnalytics().setEventProperties(
        entityId: AppPreferences().entityId,
        instanceId: AppInstanceCreate().displayInstanceID);

    await AppUpdateHelper().ensureInitialized(settings);

    FlutterError.onError = (FlutterErrorDetails details) async {
      // Report errors to a service
      await AppExceptionReport().sendToServer(settings, packageInfo,
          details.exceptionAsString(), details.stack.toString());
    };

    runApp(configureApp);
  }, (error, stack) async {
    // Report errors to a service
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    await AppExceptionReport().sendToServer(
        settings, packageInfo, error.toString(), stack.toString());
  });
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  const MyApp({super.key});
  static ValueNotifier<bool> updatedLocale = ValueNotifier(false);
  static bool isInBackgroundMode = false;
  static Timer? _timerControlSocket;

  static void setNewLocale(BuildContext context, int index) async {
    String newLanguage = AppPreferences.localeMap.keys.elementAt(index);
    AppPreferences().set(language: newLanguage);

    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLanguage(AppPreferences().locale);

    updatedLocale.value = !updatedLocale.value;
  }

  static void disconnectControlSocket() {
    isInBackgroundMode = true;
    if (!ControlSocket().hasPresenterOccupied()) {
      // due to disconnectedP2pClient may call many times.
      _timerControlSocket?.cancel();
      _timerControlSocket = Timer.periodic(const Duration(seconds: 1), (timer) {
        // print('_TAG_, _timerControlSocket->tick: ${timer.tick}');
        if (timer.tick >= 30) {
          timer.cancel();
          _timerControlSocket?.cancel();
          _timerControlSocket = null;
          ControlSocket().disconnect();
        }
      });
    }
  }

  static void connectControlSocket(BuildContext context) {
    isInBackgroundMode = false;
    if (_timerControlSocket != null) {
      // print('_TAG_, _timerControlSocket->cancel');
      _timerControlSocket?.cancel();
      _timerControlSocket = null;
    }
    if (ControlSocket().isControlSocketNull()) {
      AppConfig? appConfig = AppConfig.of(context);
      if (appConfig != null) {
        ControlSocket().connect(appConfig.settings.apiGateway);
      }
    }
  }

  @override
  State createState() => _MyAppState();
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
    WidgetsBinding.instance.addObserver(this);
    AppAnalytics().trackEventAppStarted();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    log('AppLifecycleState: $state');
    if (state == AppLifecycleState.inactive) {
      MyApp.disconnectControlSocket();
      ControlSocket().updateAllAudioEnableState(false);
      MainInfo.cancelGetOTPTimer();
    } else if (state == AppLifecycleState.resumed) {
      MyApp.connectControlSocket(context);
      ControlSocket().updateAllAudioEnableState(true);
      MainInfo.addGetOTPEvent();
    }
  }

  @override
  Future<bool> didPopRoute() async {
    if (!Platform.isAndroid) {
      NavigatorState? navigatorState =
          NavigationService.navigationKey.currentState;
      if (navigatorState != null && !navigatorState.canPop()) {
        ControlSocket().disconnect();
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

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: MirrorStateProvider()),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        //add
        supportedLocales: S.delegate.supportedLocales,
        locale: _locale,
        title: 'myViewBoard Display',
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
        routes: {
          // for "navService.popUntil('/home')"
          '/home': (context) => const AppOTADialog(child: Home()),
          '/eula': (context) => const AppOTADialog(child: Eula()),
        },
      ),
    );
  }
}
