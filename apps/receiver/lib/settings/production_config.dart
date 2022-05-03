import 'package:display_flutter/settings/app_config.dart';

class ProductionConfig implements ConfigSettings {
  @override
  String apiGateway = 'https://presentation-gateway.myviewboard.cloud';

  @override
  String mainDisplayUrl = 'https://myviewboard.com/display';

  @override
  String prefixQRCode = 'https://myviewboarddisplay.com/enroll?device_id=';

  @override
  String vbsOtaUrl =
      'https://ubwaipq96h.execute-api.us-east-1.amazonaws.com/prod/otacheck';

  @override
  String icarHostName = 'api.myviewboard.com';

  @override
  String icarRegisterUrl =
      'https://api.myviewboard.com/api/v1/application/extension/register?key=';

  @override
  String icarUpdateUrl =
      'https://api.myviewboard.com/api/v1/application/extension/register/uid?key=';
}
