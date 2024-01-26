import 'package:display_flutter/settings/app_config.dart';

class DevConfig implements ConfigSettings {
  @override
  bool isDevelopEnvironment = true;

  @override
  String apiGateway = 'https://api-us-east-1.gateway.dev.airsync.net/instances';

  @override
  String getIceServer = 'https://getice.stage.myviewboard.cloud';

  @override
  String mainDisplayUrl = 'https://dev.myviewboarddisplay.com/display';

  @override
  String prefixQRCode = 'https://dev.myviewboarddisplay.com/enroll?device_id=';

  @override
  String appSecretAndroid = '0ffc5b6e-d024-4685-b7ab-214b636d2b8b';

  @override // todo create iOS project secret
  String appSecretIOS = '0ffc5b6e-d024-4685-b7ab-214b636d2b8b';

  @override
  String icarHostName = 'devapi.myviewboard.com';

  @override
  String icarRegisterUrl =
      'https://devapi.myviewboard.com/api/v1/application/extension/register?key=';

  @override
  String icarUpdateUrl =
      'https://devapi.myviewboard.com/api/v1/application/extension/register/uid?key=';

  @override
  String icarExceptionUrl =
      'https://devapi.myviewboard.com/api/v1/application/extension/exception?key=';

  @override
  String icarExceptionFileUrl =
      'https://devapi.myviewboard.com/api/v1/application/extension/exception/uid/file?folder=DisplayExceptionLog';
}
