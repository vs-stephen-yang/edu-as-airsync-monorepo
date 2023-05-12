import 'package:display_cast_flutter/settings/app_config.dart';

class ProductionConfig implements ConfigSettings {
  @override
  String envName = 'production';

  @override
  String versionPostfix = '';

  @override
  String urlGateway = 'https://presentation-gateway.myviewboard.cloud';

  @override
  String urlGetIce = 'https://getice.myviewboard.cloud';
}
