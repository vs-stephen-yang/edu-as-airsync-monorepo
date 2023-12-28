import 'package:display_cast_flutter/settings/app_config.dart';

class StageConfig implements ConfigSettings {
  @override
  String envName = 'stage';

  @override
  String versionPostfix = '-s';

  @override
  String urlGateway = 'https://api-us-east-1.gateway.stage.airsync.net/instances';

  @override
  String urlGetIce = 'https://getice.stage.myviewboard.cloud';
}
