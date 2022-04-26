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
}
