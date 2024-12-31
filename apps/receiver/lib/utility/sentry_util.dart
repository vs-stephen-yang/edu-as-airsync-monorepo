import 'package:display_flutter/settings/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sentry_logging/sentry_logging.dart';

initSentry(SentryConfig config) async {
  if (kDebugMode) {
    return;
  }

  await SentryFlutter.init(
    (options) {
      options.dsn = config.dsn;
      //options.debug = true;
      options.environment = config.environment;
      options.addIntegration(LoggingIntegration());

      options.tracesSampleRate = config.tracesSampleRate;
    },
  );
}

setSentryUser(String id) {
  final user = SentryUser(
    id: id,
  );

  Sentry.configureScope((scope) => scope.setUser(user));
}

setSentryTag(String key, String value) {
  Sentry.configureScope((scope) => scope.setTag(key, value));
}
