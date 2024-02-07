import 'package:display_flutter/settings/app_config.dart';

class ProductionConfig implements ConfigSettings {
  @override
  bool isDevelopEnvironment = false;

  @override
  String apiGateway = 'https://presentation-gateway.myviewboard.cloud';

  @override
  String getIceServer = 'https://getice.myviewboard.cloud';

  @override
  String mainDisplayUrl = 'https://myviewboard.com/display';

  @override
  String prefixQRCode = 'https://myviewboarddisplay.com/enroll?device_id=';

  @override
  String? defaultOtp; // For development only. Keep null

  @override
  String appSecretAndroid = '6027dbdc-c4ad-41fb-8dc2-9b9d2cbbce23';

  @override // todo create iOS project secret
  String appSecretIOS = '6027dbdc-c4ad-41fb-8dc2-9b9d2cbbce23';

  @override
  String icarHostName = 'api.myviewboard.com';

  @override
  String icarRegisterUrl =
      'https://api.myviewboard.com/api/v1/application/extension/register?key=';

  @override
  String icarUpdateUrl =
      'https://api.myviewboard.com/api/v1/application/extension/register/uid?key=';

  @override
  String icarExceptionUrl =
      'https://api.myviewboard.com/api/v1/application/extension/exception?key=';

  @override
  String icarExceptionFileUrl =
      'https://api.myviewboard.com/api/v1/application/extension/exception/uid/file?folder=DisplayExceptionLog';

  @override
  String airSyncUrl = 'www.airsync.net';
}
