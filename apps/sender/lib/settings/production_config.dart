import 'package:display_cast_flutter/settings/app_config.dart';

class ProductionConfig implements ConfigSettings {
  @override
  String envName = 'production';

  @override
  String versionPostfix = '';

  @override
  String urlGateway = 'https://api.gateway.airsync.net/instances';

  @override
  String urlGetIce = 'https://getice.myviewboard.cloud';

  @override
  String appInsightsInstrumentationKey = 'c38c02f2-1bb1-4da1-8011-1e592a1e8c11';
}
