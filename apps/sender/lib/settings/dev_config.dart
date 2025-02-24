import 'package:display_cast_flutter/settings/app_config.dart';

class DevConfig implements ConfigSettings {
  @override
  String envName = 'dev';

  @override
  SentryConfig? sentry;

  @override
  String versionPostfix = '-d';

  @override
  String baseApiUrl = 'https://api.dev.airsync.net/';

  @override
  String appInsightsInstrumentationKey = '30d6e31f-3fee-4258-af83-5474452eb932';

  @override
  String appInsightsIngestionEndpoint =
      'https://eastus-8.in.applicationinsights.azure.com/v2/track';

  @override
  String appUpdateVersionEndpoint =
      'https://appconfig.dev.airsync.net/airsync-sender/supported-versions.json';

  @override
  String appStoreUrl = 'https://www.dev.airsync.net/download';

  @override
  int platformDirectPort = 5100;

  @override
  int webTransportPort = 8001;
}
