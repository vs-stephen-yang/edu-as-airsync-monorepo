import 'package:display_flutter/settings/app_config.dart';

class StageConfig implements ConfigSettings {
  @override
  String apiGateway = 'https://presentation-gateway.stage.myviewboard.cloud';

  @override
  String mainDisplayUrl = 'https://stage.myviewboarddisplay.com/display';

  @override
  String prefixQRCode =
      'https://stage.myviewboarddisplay.com/enroll?device_id=';

  @override
  String vbsOtaUrl =
      'https://jqi0t9ku01.execute-api.us-east-1.amazonaws.com/dev/otacheck';
}
