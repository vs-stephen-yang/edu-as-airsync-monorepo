import 'package:display_flutter/settings/app_config.dart';

class StageConfig implements ConfigSettings {
  @override
  bool isDevelopEnvironment = true;

  @override
  SentryConfig? sentry = SentryConfig(
    dsn:
        'https://668f1dd8f7d4e911c3fdb474fc74ed63@o4508005887442944.ingest.us.sentry.io/4508159114346496',
    environment: 'stage',
    tracesSampleRate: 1,
  );

  @override
  String baseApiUrl = 'https://api.stage.airsync.net/';

  @override
  String? defaultOtp; // For development only. Keep null

  @override
  String instrumentationKey = '3633800d-9edd-4c63-9b6f-b0ab2ada5448';

  @override
  String ingestionEndpoint =
      'https://eastus-8.in.applicationinsights.azure.com/v2/track';

  @override
  String appAmplitudeKey = '594b44808b184ee9dc7a4b91ad8520e3';

  @override
  String airSyncUrl = 'stage.airsync.net';

  @override
  String appStoreUrl = 'https://www.stage.airsync.net/download';

  @override
  String storeMobileUrl = 'https://stage.airsync.net/app/download';

  @override
  bool? appA11yDebug; // For development only. Keep null
}
