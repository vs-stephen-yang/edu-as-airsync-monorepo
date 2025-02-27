import 'package:display_cast_flutter/settings/app_config.dart';

class ProductionConfig implements ConfigSettings {
  @override
  String envName = 'production';

  @override
  SentryConfig? sentry = SentryConfig(
    dsn:
        'https://f01a15d5882dea692efb6b89eae31508@o4508005887442944.ingest.us.sentry.io/4508159112380416',
    environment: 'prod',
    tracesSampleRate: 0.01,
  );

  @override
  String versionPostfix = '';

  @override
  String baseApiUrl = 'https://api.airsync.net/';

  @override
  String appInsightsInstrumentationKey = 'c38c02f2-1bb1-4da1-8011-1e592a1e8c11';

  @override
  String appInsightsIngestionEndpoint =
      'https://eastus-8.in.applicationinsights.azure.com/v2/track';

  @override
  String appUpdateVersionEndpoint =
      'https://appconfig.airsync.net/airsync-sender/supported-versions.json';

  @override
  String appStoreUrl = 'https://www.airsync.net/download';
}
