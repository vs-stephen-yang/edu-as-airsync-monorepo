import 'package:display_flutter/settings/app_config.dart';

class DevConfig implements ConfigSettings {
  @override
  String apiGateway = 'https://presentation-gateway.dev.myviewboard.cloud';

  @override
  String mainDisplayUrl = 'https://dev.myviewboarddisplay.com/display';

  @override
  String prefixQRCode = 'https://dev.myviewboarddisplay.com/enroll?device_id=';

  @override
  String vbsOtaUrl =
      'https://jqi0t9ku01.execute-api.us-east-1.amazonaws.com/dev/otacheck';
}
