import 'package:display_flutter/settings/app_config.dart';

class ProductionConfig implements ConfigSettings {
  @override
  String apiGateway = 'https://presentation-gateway.myviewboard.cloud';

  @override
  String mainDisplayUrl = 'https://myviewboard.com/display';

  @override
  String prefixQRCode = 'https://myviewboarddisplay.com/enroll?device_id=';

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
}
