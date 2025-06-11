import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:accessibility_tools/accessibility_tools.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:desktop_screenstate/desktop_screenstate.dart';
import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/model/profile.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/providers/demo_provider.dart';
import 'package:display_cast_flutter/providers/device_list_provider.dart';
import 'package:display_cast_flutter/providers/pref_language_provider.dart';
import 'package:display_cast_flutter/providers/pref_text_scale_provider.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/providers/settings_provider.dart';
import 'package:display_cast_flutter/providers/v3_demo_provider.dart';
import 'package:display_cast_flutter/screens/v3_eula.dart';
import 'package:display_cast_flutter/screens/v3_home.dart';
import 'package:display_cast_flutter/screens/v3_splash_screen.dart';
import 'package:display_cast_flutter/settings/app_config.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:display_cast_flutter/utilities/app_instance_create.dart';
import 'package:display_cast_flutter/utilities/app_preferences.dart';
import 'package:display_cast_flutter/utilities/client_device_info.dart';
import 'package:display_cast_flutter/utilities/data_display_code.dart';
import 'package:display_cast_flutter/utilities/log.dart';
import 'package:display_cast_flutter/utilities/profile_util.dart';
import 'package:display_cast_flutter/utilities/screen_state_detector.dart';
import 'package:display_cast_flutter/utilities/sentry_util.dart';
import 'package:display_cast_flutter/utilities/v3_network_status_detector.dart';
import 'package:display_cast_flutter/utilities/version_util.dart';
import 'package:display_cast_flutter/utilities/webrtc_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_virtual_display/flutter_virtual_display.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:window_manager/window_manager.dart';

import 'annotation/annotation_model.dart';
import 'annotation/canvas_widget_desktop.dart';

void commonEntry(List<String> args, ConfigSettings settings) async {
  await runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    if (settings.sentry != null) {
      initSentry(settings.sentry!);
    }

    if (!kIsWeb && (Platform.isWindows || Platform.isMacOS)) {
      if (args.firstOrNull == 'multi_window') {
        final windowId = int.parse(args[1]);
        final argument = args[2].isEmpty
            ? const {}
            : jsonDecode(args[2]) as Map<String, dynamic>;
        if (argument['mode'] == 'desktop_canvas') {
          runApp(CanvasWidgetDesktop(
            windowController: WindowController.fromWindowId(windowId),
            args: argument,
          ));
        }
        return;
      }
    }

    initLogger();
    enableLogToMemory(true);

    await AppPreferences.ensureInitialized();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    await AppInstanceCreate.ensureInitialized();

    if (WebRTC.platformIsWindows || VersionUtil.isOpenVersion) {
      await FlutterVirtualDisplay.instance.initialize();
    }

    AppAnalytics.initializeApp(
      instrumentationKey: settings.appInsightsInstrumentationKey,
      ingestionEndpoint: settings.appInsightsIngestionEndpoint,
      applicationVersion: packageInfo.version,
      userId: AppInstanceCreate().instanceId,
      sessionId: const Uuid().v4(),
      deviceInfo: await ClientDeviceInfo.fetch(),
    );
    trackEvent('launch', EventCategory.system);

    WebRTCUtil.iceGatheringContinually =
        await WebRTCUtil.loadIceGatheringContinually();
    WebRTCUtil.showDebugOverlay = await WebRTCUtil.loadShowDebugOverlay();

    await DataDisplayCode.getInstance().initialize();

    final ProfileStore profileStore = await ProfileUtil.loadProfileStore(args);

    // Due to macOS has few users, we are currently only adding the screen state detector for Windows.
    if (!kIsWeb && Platform.isWindows) {
      ScreenStateDetector.initialize();
      ScreenStateDetector.instance.onState.listen((event) {
        if (event == ScreenState.awaked) {
          log.info('screen_awaked');
          trackTrace('screen_awaked');
        } else if (event == ScreenState.sleep) {
          log.info('screen_sleep');
          trackTrace('screen_sleep');
        } else if (event == ScreenState.locked) {
          log.info('screen_locked');
          trackTrace('screen_locked');
        } else if (event == ScreenState.unlocked) {
          log.info('screen_unlocked');
          trackTrace('screen_unlocked');
        }
      });
    }
    // Detect App suspension
    // TODO: #81702 Temporarily disable the collection of app_unresponsive events due to their excessive volume.
    // AppUnresponsiveDetector.initialize();

    // AppUnresponsiveDetector.instance.addListener((suspensionDuration) {
    //   trackTrace('app_unresponsive', properties: {
    //     'target': suspensionDuration.inSeconds,
    //   });
    // });

    V3NetworkStatusDetector.ensureInitialized();

    runApp(AppConfig(
      settings: settings,
      profileStore: profileStore,
      appName: packageInfo.appName,
      appVersion: packageInfo.version,
      child: Tokens(
        tokens: DefaultTokens(),
        child: const MyApp(),
      ),
    ));
    if (kIsWeb) {
      SemanticsBinding.instance.ensureSemantics();
    }
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      await windowManager.ensureInitialized();

      WindowOptions windowOptions = const WindowOptions(
        size: Size(640, 480),
        minimumSize: Size(640, 480),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.normal,
        windowButtonVisibility: true,
      );

      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    }
  }, (error, stackTrace) async {
    await Sentry.captureException(error, stackTrace: stackTrace);

    log.warning('Unhandled exception', error, stackTrace);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const platform =
      MethodChannel('com.viewsonic.display.cast/supportedOrientation');

  static Future<void> setSupportedOrientationAll() async {
    try {
      await platform.invokeMethod('setSupportedOrientationAll', null);
    } on PlatformException catch (e) {
      log.info("Failed to set supported orientation: '${e.message}'.");
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // hide the Android Status Bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    if (!kIsWeb && Platform.isIOS) {
      setSupportedOrientationAll();
    }
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: PresentStateProvider()),
        ChangeNotifierProvider.value(value: PrefLanguageProvider()),
        ChangeNotifierProvider.value(value: DemoProvider()),
        ChangeNotifierProvider.value(value: V3DemoProvider()),
        ChangeNotifierProvider.value(value: ChannelProvider(context)),
        ChangeNotifierProvider.value(value: DeviceListProvider()),
        ChangeNotifierProvider.value(value: SettingsProvider()),
        ChangeNotifierProvider.value(value: AnnotationModel()),
        ChangeNotifierProvider(create: (_) => TextScaleProvider()),
      ],
      child: Consumer<PrefLanguageProvider>(
        builder: (context, languageModel, child) {
          final botToastBuilder = BotToastInit();
          return MaterialApp(
            title: 'AirSync Sender',
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              return Consumer<TextScaleProvider>(
                builder: (context, textSizeProvider, __) {
                  Widget c = MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                          textScaler: textSizeProvider.platformTextScale),
                      child: child!);

                  if (AppConfig.of(context)?.settings.appA11yDebug ?? false) {
                    return AccessibilityTools(child: c);
                  }

                  return c;
                },
              );
            },
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              DefaultMaterialLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            locale: languageModel.locale,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              // Set app background color
              scaffoldBackgroundColor: const Color(0xFFF0F1F7),
              unselectedWidgetColor: Colors.white,
              textTheme: Theme.of(context).textTheme.apply(
                fontFamily: 'Inter',
                bodyColor: context.tokens.color.vsdswColorOnSurface,
                fontFamilyFallback: ['NotoSansTC'],
              ),
            ),
            // BUG 87068這邊只針對Android平台做調整
            initialRoute: WebRTC.platformIsAndroid ? null : (kIsWeb ? '/v3home' : '/v3splash'),
            home: WebRTC.platformIsAndroid ? const V3SplashScreen() : null,
            navigatorKey: NavigationService.navigationKey,
            routes: {
              // for 'navService.popUntil('/v3home')'
              '/v3home': (context) => botToastBuilder(context, const V3Home()),
              '/v3eula': (context) => const V3Eula(),
              '/v3splash': (context) => const V3SplashScreen(),
            },
          );
        },
      ),
    );
  }
}
