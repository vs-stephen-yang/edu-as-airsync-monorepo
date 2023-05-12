import 'package:display_cast_flutter/settings/app_config.dart';

class DevConfig implements ConfigSettings {
  @override
  String envName = 'dev';

  @override
  String versionPostfix = '-d';

  @override
  String urlGateway = 'https://presentation-gateway.dev.myviewboard.cloud';

  @override
  String urlGetIce = 'https://getice.stage.myviewboard.cloud';
}
