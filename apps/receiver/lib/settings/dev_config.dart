import 'package:display_flutter/settings/app_config.dart';

class DevConfig implements ConfigSettings {
  @override
  bool isDevelopEnvironment = true;

  @override
  SentryConfig sentry = SentryConfig(
    dsn:
        'https://ba656caa9f9170e1edc009cd46a54421@o4508005887442944.ingest.us.sentry.io/4508159114346496',
    environment: 'dev',
  );

  @override
  String baseApiUrl = 'https://api2.gateway.dev.airsync.net/';

  @override
  String getIceServer = 'https://getice.stage.myviewboard.cloud';

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
  String icarUpdateUrl =
      'https://devapi.myviewboard.com/api/v1/application/extension/register/uid?key=';

  @override
  String icarExceptionUrl =
      'https://devapi.myviewboard.com/api/v1/application/extension/exception?key=';

  @override
  String icarExceptionFileUrl =
      'https://devapi.myviewboard.com/api/v1/application/extension/exception/uid/file?folder=DisplayExceptionLog';

  @override
  String airSyncUrl = 'dev.airsync.net';

  @override
  String appStoreUrl = 'https://www.dev.airsync.net/download';
}
