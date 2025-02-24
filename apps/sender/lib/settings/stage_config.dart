import 'package:display_cast_flutter/settings/app_config.dart';

class StageConfig implements ConfigSettings {
  @override
  String envName = 'stage';

  @override
  SentryConfig? sentry = SentryConfig(
    dsn:
        'https://f01a15d5882dea692efb6b89eae31508@o4508005887442944.ingest.us.sentry.io/4508159112380416',
    environment: 'stage',
    tracesSampleRate: 1,
  );

  @override
  String versionPostfix = '-s';

  @override
  String baseApiUrl = 'https://api.stage.airsync.net/';

  @override
  String appInsightsInstrumentationKey = '6e176c9a-ecc8-443c-a1ad-7cc3954efe80';

  @override
  String appInsightsIngestionEndpoint =
      'https://eastus-8.in.applicationinsights.azure.com/v2/track';

  @override
  String appUpdateVersionEndpoint =
      'https://appconfig.stage.airsync.net/airsync-sender/supported-versions.json';

  @override
  String appStoreUrl = 'https://www.stage.airsync.net/download';

  @override
  int platformDirectPort = 5100;

  @override
  int webTransportPort = 8001;
}
