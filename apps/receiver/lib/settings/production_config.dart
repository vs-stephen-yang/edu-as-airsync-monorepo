import 'package:display_flutter/settings/app_config.dart';

class ProductionConfig implements ConfigSettings {
  @override
  bool isDevelopEnvironment = false;

  @override
  SentryConfig? sentry = SentryConfig(
    dsn:
        'https://668f1dd8f7d4e911c3fdb474fc74ed63@o4508005887442944.ingest.us.sentry.io/4508159114346496',
    environment: 'prod',
    tracesSampleRate: 0.01,
  );

  @override
  String baseApiUrl = 'https://api.airsync.net/';

  @override
  String? defaultOtp; // For development only. Keep null

  @override
  String appSecretAndroid = '6027dbdc-c4ad-41fb-8dc2-9b9d2cbbce23';

  @override // todo create iOS project secret
  String appSecretIOS = '6027dbdc-c4ad-41fb-8dc2-9b9d2cbbce23';

  @override
  String instrumentationKey = 'e510b3fd-38d5-46e6-973e-53e416050c98';

  @override
  String ingestionEndpoint =
      'https://eastus-8.in.applicationinsights.azure.com/v2/track';

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
  String airSyncUrl = 'airsync.net';

  @override
  String appStoreUrl = 'https://www.airsync.net/download';
}
