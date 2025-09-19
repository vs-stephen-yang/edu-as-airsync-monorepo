import 'package:display_flutter/settings/app_config.dart';

class ProductionConfig implements ConfigSettings {
  @override
  bool isDevelopEnvironment = false;

  @override
  SentryConfig? sentry = SentryConfig(
    dsn:
        'https://668f1dd8f7d4e911c3fdb474fc74ed63@o4508005887442944.ingest.us.sentry.io/4508159114346496',
    environment: 'prod',
    tracesSampleRate: 0.01,
  );

  @override
  String baseApiUrl = 'https://api.airsync.net/';

  @override
  String? defaultOtp; // For development only. Keep null

  @override
  String instrumentationKey = 'e510b3fd-38d5-46e6-973e-53e416050c98';

  @override
  String ingestionEndpoint =
      'https://eastus-8.in.applicationinsights.azure.com/v2/track';

  @override
  String airSyncUrl = 'airsync.net';

  @override
  String appStoreUrl = 'https://www.airsync.net/download';

  @override
  String storeMobileUrl = 'https://airsync.net/app/download';

  @override
  bool? appA11yDebug; // For development only. Keep null
}
