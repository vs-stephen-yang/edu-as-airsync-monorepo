import 'package:display_flutter/settings/app_config.dart';

class StageConfig implements ConfigSettings {
  @override
  bool isDevelopEnvironment = true;

  @override
  String apiGateway = 'https://api-us-east-1.gateway.stage.airsync.net/instances';

  @override
  String getIceServer = 'https://getice.stage.myviewboard.cloud';

  @override
  String mainDisplayUrl = 'https://stage.myviewboarddisplay.com/display';

  @override
  String prefixQRCode =
      'https://stage.myviewboarddisplay.com/enroll?device_id=';

  @override
  String appSecretAndroid = '0ffc5b6e-d024-4685-b7ab-214b636d2b8b';

  @override // todo create iOS project secret
  String appSecretIOS = '0ffc5b6e-d024-4685-b7ab-214b636d2b8b';

  @override
  String icarHostName = 'stageapi.myviewboard.com';

  @override
  String icarRegisterUrl =
      'https://stageapi.myviewboard.com/api/v1/application/extension/register?key=';

  @override
  String icarUpdateUrl =
      'https://stageapi.myviewboard.com/api/v1/application/extension/register/uid?key=';

  @override
  String icarExceptionUrl =
      'https://stageapi.myviewboard.com/api/v1/application/extension/exception?key=';

  @override
  String icarExceptionFileUrl =
      'https://stageapi.myviewboard.com/api/v1/application/extension/exception/uid/file?folder=DisplayExceptionLog';
}
