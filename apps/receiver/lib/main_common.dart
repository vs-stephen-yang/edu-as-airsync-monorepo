import 'dart:async';
import 'dart:io';

import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_exception_report.dart';
import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/app_update_helper.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/screens/eula.dart';
import 'package:display_flutter/screens/home.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/widgets/app_ota_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

Future<void> commonEntry(ConfigSettings settings) async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // TODO Setup maxHardwareDecodeSession based on device.
    await WebRTC.initialize(options: {"maxHardwareDecodeSession": 1});

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

  static void setNewLocale(BuildContext context, int index) async {
    String newLanguage = AppPreferences.localeMap.keys.elementAt(index);
    AppPreferences().set(language: newLanguage);

    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLanguage(AppPreferences().locale);

    updatedLocale.value = !updatedLocale.value;
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
  Future<bool> didPopRoute() async {
    if (!Platform.isAndroid) {
      NavigatorState? navigatorState =
          NavigationService.navigationKey.currentState;
      if (navigatorState != null && !navigatorState.canPop()) {
        AppAnalytics().trackEventAppTerminated();
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
        ChangeNotifierProvider.value(value: ChannelProvider(AppConfig.of(context)!)),
        ChangeNotifierProvider.value(value: MirrorStateProvider(context)),
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
        title: 'AirSync',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          // Set App background color
          scaffoldBackgroundColor: Colors.black,
          // Set Text default body color
          textTheme: Theme.of(context).textTheme.apply(bodyColor: Colors.white),
          // Set ElevatedButton default foreground color
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(foregroundColor: Colors.white),
          ),
          // Set TextButton default foreground color
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
          ),
          // Set IconButton default foreground color
          iconButtonTheme: IconButtonThemeData(
            style: IconButton.styleFrom(foregroundColor: Colors.white),
          ),
          // Set Icon default color
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
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
