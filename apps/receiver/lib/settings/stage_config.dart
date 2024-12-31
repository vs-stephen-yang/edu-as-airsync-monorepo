import 'package:display_flutter/settings/app_config.dart';

class StageConfig implements ConfigSettings {
  @override
  bool isDevelopEnvironment = true;

  @override
  SentryConfig? sentry = SentryConfig(
    dsn:
        'https://ba656caa9f9170e1edc009cd46a54421@o4508005887442944.ingest.us.sentry.io/4508159114346496',
    environment: 'stage',
    tracesSampleRate: 1,
  );

  @override
  String baseApiUrl = 'https://api.stage.airsync.net/';

  @override
  String? defaultOtp; // For development only. Keep null

  @override
  String appSecretAndroid = '0ffc5b6e-d024-4685-b7ab-214b636d2b8b';

  @override // todo create iOS project secret
  String appSecretIOS = '0ffc5b6e-d024-4685-b7ab-214b636d2b8b';

  @override
  String instrumentationKey = '3633800d-9edd-4c63-9b6f-b0ab2ada5448';

  @override
  String ingestionEndpoint =
      'https://eastus-8.in.applicationinsights.azure.com/v2/track';

  @override
  String icarHostName = 'stageapi.myviewboard.com';

  @override
  String icarRegisterUrl =
      'https://stageapi.myviewboard.com/api/v1/application/extension/register?key=';

  @override
  String icarUpdateUrl =
      'https://stageapi.myviewboard.com/api/v1/application/extension/register/uid?key=';

  @override
  String icarExceptionUrl =
      'https://stageapi.myviewboard.com/api/v1/application/extension/exception?key=';

  @override
  String icarExceptionFileUrl =
      'https://stageapi.myviewboard.com/api/v1/application/extension/exception/uid/file?folder=DisplayExceptionLog';

  @override
  String airSyncUrl = 'stage.airsync.net';

  @override
  String appStoreUrl = 'https://www.stage.airsync.net/download';
}
