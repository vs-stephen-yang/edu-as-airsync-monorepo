import 'package:auto_hyphenating_text/auto_hyphenating_text.dart';
import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/model/airsync_bonsoir_service.dart';
import 'package:display_cast_flutter/model/profile.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/providers/device_list_provider.dart';
import 'package:display_cast_flutter/providers/pref_text_scale_provider.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/settings/app_config.dart';
import 'package:display_cast_flutter/utilities/audio_switch_manager_factory.dart';
import 'package:display_cast_flutter/utilities/channel_util.dart';
import 'package:display_cast_flutter/utilities/webrtc_helper.dart';
import 'package:display_cast_flutter/widgets/v3_device_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Fakes ────────────────────────────────────────────────────────────────────

class _FakeConfigSettings extends ConfigSettings {
  _FakeConfigSettings() {
    envName = 'test';
    versionPostfix = '';
    sentry = null;
    baseApiUrl = '';
    appInsightsInstrumentationKey = '';
    appInsightsIngestionEndpoint = '';
    appAmplitudeKey = '';
    appUpdateVersionEndpoint = '';
    appStoreUrl = '';
    appUpdateMacAppcastUrl = '';
    storeMobileUrl = '';
    appA11yDebug = false;
    enableAmplifyFirehose = false;
    amplifyRegion = '';
    amplifyIdentityPoolId = '';
    firehoseStreamName = '';
  }
}

class _FakeDeviceListProvider extends DeviceListProvider {
  @override
  Future<void> startDiscovery(String versionPostfix) async {}

  @override
  Future<void> stopDiscovery() async {}
}

class _FakeChannelProvider extends ChannelProvider {
  _FakeChannelProvider()
      : super(
          baseApiUrl: '',
          profileStore: ProfileStore(profiles: [], selectedProfile: ''),
          platformDirectPort: 5100,
          webTransportPort: 8001,
          audioSwitchManager: AudioSwitchManagerStub(),
          webRTCHelper: WebRTCHelper(),
          userId: 'test-user',
        );

  ChannelConnectError? _fakeError;
  int connectCallCount = 0;

  @override
  ChannelConnectError? get channelConnectError => _fakeError;

  /// Simulate a connection error from the server.
  void simulateError(ChannelConnectError error) {
    _fakeError = error;
    notifyListeners();
  }

  /// Clear the error (prevents the widget's build-time loop from re-triggering).
  void clearError() {
    _fakeError = null;
    notifyListeners();
  }

  @override
  // ignore: override_on_non_overriding_member
  startDirectConnect({
    required String? otp,
    required AirSyncBonsoirService service,
    required PresentStateProvider presentStateProvider,
  }) {
    connectCallCount++;
  }

  @override
  void resetMessage() {
    _fakeError = null;
    notifyListeners();
  }
}

// ─── Test data ────────────────────────────────────────────────────────────────

final _testDevice = AirSyncBonsoirService(
  uuid: 'test-uuid',
  name: 'Conference Room',
  type: '_airsync._tcp',
  displayCode: '123456',
  ip: '192.168.1.1',
  port: 5100,
);

// ─── Helpers ──────────────────────────────────────────────────────────────────

Widget _buildTestWidget({
  required _FakeDeviceListProvider deviceListProvider,
  required _FakeChannelProvider channelProvider,
}) {
  return MultiProvider(
    providers: [
      Provider<AppConfig>(
        create: (_) => AppConfig(
          settings: _FakeConfigSettings(),
          profileStore: ProfileStore(profiles: [], selectedProfile: ''),
          appName: 'Test',
          appVersion: '1.0.0',
        ),
      ),
      ChangeNotifierProvider<DeviceListProvider>.value(value: deviceListProvider),
      ChangeNotifierProvider<ChannelProvider>.value(value: channelProvider),
      ChangeNotifierProvider<PresentStateProvider>(
          create: (_) => PresentStateProvider()),
      ChangeNotifierProvider<TextScaleProvider>(
          create: (_) => TextScaleProvider()),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: Scaffold(
        body: Tokens(
          tokens: DefaultTokens(),
          child: const V3DeviceList(),
        ),
      ),
    ),
  );
}

/// Finds the InkWell inside the V3Focus identified by [semanticsId].
Finder _inkWellBySemanticsId(String semanticsId) {
  return find.descendant(
    of: find.byWidgetPredicate(
      (w) => w is Semantics && w.properties.identifier == semanticsId,
    ),
    matching: find.byType(InkWell),
  );
}

Finder get _nextButton => _inkWellBySemanticsId('v3_qa_device_list_next');
Finder _deviceItem(int index) =>
    _inkWellBySemanticsId('v3_qa_device_list_item_$index');

bool _isEnabled(WidgetTester tester, Finder finder) {
  return tester.widget<InkWell>(finder).onTap != null;
}

// ─── Tests ────────────────────────────────────────────────────────────────────

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await initHyphenation();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('V3DeviceList - Next button', () {
    testWidgets('is disabled when no device is selected',
        (WidgetTester tester) async {
      final deviceProvider = _FakeDeviceListProvider()..addDevice(_testDevice);
      final channelProvider = _FakeChannelProvider();

      await tester.pumpWidget(_buildTestWidget(
        deviceListProvider: deviceProvider,
        channelProvider: channelProvider,
      ));
      await tester.pumpAndSettle();

      // No device selected yet → button must be disabled.
      expect(_isEnabled(tester, _nextButton), isFalse);
    });

    testWidgets('enables after a device is tapped',
        (WidgetTester tester) async {
      final deviceProvider = _FakeDeviceListProvider()..addDevice(_testDevice);
      final channelProvider = _FakeChannelProvider();

      await tester.pumpWidget(_buildTestWidget(
        deviceListProvider: deviceProvider,
        channelProvider: channelProvider,
      ));
      await tester.pumpAndSettle();

      await tester.tap(_deviceItem(0));
      await tester.pump();

      expect(_isEnabled(tester, _nextButton), isTrue);
    });

    testWidgets('disables immediately after tap to prevent double-tap',
        (WidgetTester tester) async {
      final deviceProvider = _FakeDeviceListProvider()..addDevice(_testDevice);
      final channelProvider = _FakeChannelProvider();

      await tester.pumpWidget(_buildTestWidget(
        deviceListProvider: deviceProvider,
        channelProvider: channelProvider,
      ));
      await tester.pumpAndSettle();

      // Select a device.
      await tester.tap(_deviceItem(0));
      await tester.pump();

      // First tap → connection initiated.
      await tester.tap(_nextButton);
      await tester.pump();

      expect(channelProvider.connectCallCount, 1);
      expect(_isEnabled(tester, _nextButton), isFalse,
          reason: 'Button must be disabled while connecting');

      // Second tap → should be ignored.
      await tester.tap(_nextButton, warnIfMissed: false);
      await tester.pump();

      expect(channelProvider.connectCallCount, 1,
          reason: 'Second tap must not trigger another connection');
    });

    testWidgets('re-enables after a connection error is received',
        (WidgetTester tester) async {
      final deviceProvider = _FakeDeviceListProvider()..addDevice(_testDevice);
      final channelProvider = _FakeChannelProvider();

      await tester.pumpWidget(_buildTestWidget(
        deviceListProvider: deviceProvider,
        channelProvider: channelProvider,
      ));
      await tester.pumpAndSettle();

      // Select device and tap Next.
      await tester.tap(_deviceItem(0));
      await tester.pump();
      await tester.tap(_nextButton);
      await tester.pump();

      expect(channelProvider.connectCallCount, 1);
      expect(_isEnabled(tester, _nextButton), isFalse);

      // Simulate a network error response from the server.
      // Frame 1: notifyListeners → widget rebuild → addPostFrameCallback registered.
      channelProvider.simulateError(ChannelConnectError.networkError);
      await tester.pump();
      // Frame 2: post-frame callback fires → _showConnectErrorMessage →
      //          setState(_isConnecting = false).
      await tester.pump();

      // Clear the error so the widget's post-frame guard stops re-triggering.
      channelProvider.clearError();
      await tester.pump(); // rebuild with cleared error
      await tester.pump(); // settle any remaining post-frame callbacks

      expect(_isEnabled(tester, _nextButton), isTrue,
          reason: 'Button must re-enable after an error is received');

      // Confirm the button works again.
      await tester.tap(_nextButton);
      await tester.pump();

      expect(channelProvider.connectCallCount, 2);
    });
  });
}
