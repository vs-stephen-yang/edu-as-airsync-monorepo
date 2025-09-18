import 'dart:async';
import 'dart:io';

import 'package:accessibility_tools/accessibility_tools.dart';
import 'package:device_info_vs/device_info_vs.dart';
import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/app_manager_config.dart';
import 'package:display_flutter/app_overlay_tab.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/app_update_helper.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/providers/appSettings.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/connectivity_provider.dart';
import 'package:display_flutter/providers/instance_info_provider.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/providers/multi_window_provider.dart';
import 'package:display_flutter/providers/pref_language_provider.dart';
import 'package:display_flutter/providers/settings_provider.dart';
import 'package:display_flutter/screens/v3_eula.dart';
import 'package:display_flutter/screens/v3_home.dart';
import 'package:display_flutter/services/display_service_broadcast.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/settings/theme_config.dart';
import 'package:display_flutter/utility/client_device_info.dart';
import 'package:display_flutter/utility/device_feature_adapter.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:display_flutter/utility/sentry_util.dart';
import 'package:display_flutter/utility/user_timer_manager.dart';
import 'package:display_flutter/utility/v3_toast.dart';
import 'package:display_flutter/widgets/app_ota_dialog.dart';
import 'package:display_flutter/widgets/focus_aware_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:uuid/uuid.dart';

Future<void> commonEntry(ConfigSettings settings) async {
  await runZonedGuarded<Future<void>>(() async {
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

    // 顯示原生啟動畫面
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

    if (settings.sentry != null) {
      initSentry(settings.sentry!);
    }

    await AppOverlayTab().ensureInitialized();

    initLogger();
    enableLogToMemory(true);

    await DeviceFeatureAdapter.ensureInitialized();

    await AppPreferences.ensureInitialized();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    await AppInstanceCreate.ensureInitialized(settings, packageInfo);
    await HybridConnectionList.ensureInitialized();
    await AppManagerConfig().ensureInitialized();

    var configureApp = AppConfig(
      settings: settings,
      appName: packageInfo.appName,
      appVersion: packageInfo.version,
      child: Tokens(
        tokens: DefaultTokens(),
        child: const riverpod.ProviderScope(child: MyApp()),
      ),
    );

    final instanceInfoProvider = InstanceInfoProvider();

    DisplayServiceBroadcast.ensureInitialized(
      directChannelPort: 5100,
      broadcastServiceType: '_vs-airsync._tcp',
      appVersion: configureApp.appVersion,
      instanceInfoProvider: instanceInfoProvider,
      invitedToGroupOption: AppPreferences().invitedToGroup,
    );

    // Initialize the instance name
    instanceInfoProvider.instanceName = AppPreferences().instanceName;

    await AppAnalytics.initializeApp(
      instrumentationKey: settings.instrumentationKey,
      ingestionEndpoint: settings.ingestionEndpoint,
      applicationVersion: packageInfo.version,
      userId: AppInstanceCreate().instanceID,
      sessionId: const Uuid().v4(),
      deviceInfo: await ClientDeviceInfo.fetch(),
      serialNumber: await DeviceInfoVs.getVSApiSerialNumber,
      macAddress: await DeviceInfoVs.getVSApiEthernetMacAddress,
    );

    setSentryUser(AppInstanceCreate().displayInstanceID);

    final appUpdateHelper = AppUpdateHelper();

    if (Platform.isAndroid) {
      await appUpdateHelper.ensureInitialized(settings);
    }

    runApp(
      MultiProvider(
        providers: [
          Provider<UserTimerManager>(
            create: (context) => UserTimerManager(),
          ),
          Provider<AppUpdateHelper>.value(
            value: appUpdateHelper,
          ),
          ChangeNotifierProvider<InstanceInfoProvider>.value(
            value: instanceInfoProvider,
          ),
          Provider<V3Toast>.value(
            value: V3Toast(),
          ),
        ],
        child: configureApp,
      ),
    );
  }, (error, stackTrace) async {
    await Sentry.captureException(error, stackTrace: stackTrace);

    log.warning('Unhandled exception', error, stackTrace);
  });
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  const MyApp({super.key});

  @override
  State createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    trackEvent('launch', EventCategory.system);

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
    //debugPaintSizeEnabled = true;

    final instanceInfoProvider = context.read<InstanceInfoProvider>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppSettings()),
        ChangeNotifierProvider.value(value: PrefLanguageProvider()),
        ChangeNotifierProxyProvider<AppSettings, ChannelProvider>(
          create: (_) => ChannelProvider(
            AppConfig.of(context)!,
            instanceInfoProvider,
          ),
          update: (_, settings, model) => model!..bindSettings(settings),
        ),
        ChangeNotifierProvider.value(
          value: MirrorStateProvider(
            instanceInfoProvider,
          ),
        ),
        ChangeNotifierProvider.value(
          value: SettingsProvider(),
        ),
        ChangeNotifierProvider.value(
          value: ConnectivityProvider(),
        ),
        ChangeNotifierProvider.value(
          value: MultiWindowProvider(),
        ),
      ],
      child: Consumer<PrefLanguageProvider>(
        builder: (_, prefLanguageProvider, __) {
          return MaterialApp(
              localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                DefaultMaterialLocalizations.delegate,
              ],
              //add
              supportedLocales: S.delegate.supportedLocales,
              locale: prefLanguageProvider.locale,
              title: 'AirSync',
              debugShowCheckedModeBanner: false,
              theme: createThemeData(context),
              initialRoute: AppPreferences().showEULA &&
                      !AppInstanceCreate().isInstalledInVBS100
                  ? '/v3Eula'
                  : '/v3Home',
              navigatorKey: NavigationService.navigationKey,
              routes: {
                // for "navService.popUntil('/v3Home')"
                '/v3Home': (context) => const AppOTADialog(child: V3Home()),
                '/v3Eula': (context) => AppOTADialog(
                    child: FocusAwareBuilder(
                        builder: (primaryFocusNode) =>
                            V3Eula(primaryFocusNode: primaryFocusNode))),
              },
              builder: (context, child) {
                return ValueListenableBuilder(
                  valueListenable: AppPreferences().textSizeOptionNotifier,
                  builder: (context, _, __) {
                    Widget c = MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                            textScaler:
                                TextScaler.linear(AppPreferences().textScale)),
                        child: child!);
                    if (AppConfig.of(context)!.settings.appA11yDebug == true) {
                      c = AccessibilityTools(child: c);
                    }
                    return c;
                  },
                );
              });
        },
      ),
    );
  }
}
