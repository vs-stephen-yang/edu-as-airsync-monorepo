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
  String instrumentationKey = '28aec457-6961-41d2-9d92-0a89bc2c1cab';

  @override
  String ingestionEndpoint =
      'https://eastus-8.in.applicationinsights.azure.com/v2/track';

  @override
  String airSyncUrl = 'dev.airsync.net';

  @override
  String appStoreUrl = 'https://www.dev.airsync.net/download';

  @override
  String storeMobileUrl = 'https://dev.airsync.net/app/download';

  @override
  bool? appA11yDebug = true;
}
