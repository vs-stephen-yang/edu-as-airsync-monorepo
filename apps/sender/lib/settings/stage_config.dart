import 'package:display_cast_flutter/settings/app_config.dart';

class StageConfig implements ConfigSettings {
  @override
  String envName = 'stage';

  @override
  String versionPostfix = '-s';

  @override
  String selectedProfile = 'video_quality_first';

  @override
  String urlGateway = 'https://api.gateway.stage.airsync.net/instances';

  @override
  String appInsightsInstrumentationKey = '6e176c9a-ecc8-443c-a1ad-7cc3954efe80';

  @override
  String appInsightsIngestionEndpoint =
      'https://eastus-8.in.applicationinsights.azure.com/v2/track';

  @override
  String appUpdateVersionEndpoint = 'https://appconfig.stage.airsync.net/airsync-sender/supported-versions.json';
}
