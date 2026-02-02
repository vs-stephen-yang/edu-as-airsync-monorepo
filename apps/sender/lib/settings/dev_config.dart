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
  String appAmplitudeKey = '594b44808b184ee9dc7a4b91ad8520e3';

  @override
  String appUpdateVersionEndpoint =
      'https://appconfig.dev.airsync.net/airsync-sender/supported-versions.json';

  @override
  String appStoreUrl = 'https://www.dev.airsync.net/download';

  @override
  String appUpdateMacAppcastUrl =
      'https://appconfig.dev.airsync.net/airsync-sender/mac_appcast_d.xml';

  @override
  String storeMobileUrl = 'https://dev.airsync.net/app/download';

  @override
  bool appA11yDebug = true;

  @override
  String amplifyRegion = 'ap-southeast-1';

  @override
  String amplifyIdentityPoolId =
      'ap-southeast-1:c5eebe5a-f6cf-4cd3-9aa3-a98e85c01e3d';

  @override
  String firehoseStreamName = 'airsync-encoder-firehose-delivery-stream';
}
