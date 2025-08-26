import 'package:display_flutter/settings/app_config.dart';

class DevConfig implements ConfigSettings {
  @override
  bool isDevelopEnvironment = true;

  @override
  SentryConfig? sentry;

  @override
  String baseApiUrl = 'https://api.dev.airsync.net/';

  @override
  String? defaultOtp = '0000';

  @override
  String appSecretAndroid = '0ffc5b6e-d024-4685-b7ab-214b636d2b8b';

  @override // todo create iOS project secret
  String appSecretIOS = '0ffc5b6e-d024-4685-b7ab-214b636d2b8b';

  @override
  String instrumentationKey = '28aec457-6961-41d2-9d92-0a89bc2c1cab';

  @override
  String ingestionEndpoint =
      'https://eastus-8.in.applicationinsights.azure.com/v2/track';

  @override
  String icarHostName = 'devapi.myviewboard.com';

  @override
  String icarRegisterUrl =
      'https://devapi.myviewboard.com/api/v1/application/extension/register?key=';

  @override
  String airSyncUrl = 'dev.airsync.net';

  @override
  String appStoreUrl = 'https://www.dev.airsync.net/download';

  @override
  bool? appA11yDebug = true;
}
