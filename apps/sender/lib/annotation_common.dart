import 'dart:async';

import 'package:display_cast_flutter/settings/app_config.dart';
import 'package:display_cast_flutter/utilities/sentry_util.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'annotation/canvas_widget_android.dart';

void annotationCommonEntry(ConfigSettings settings) async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    if (settings.sentry != null) {
      initSentry(settings.sentry!);
    }

    runApp(const CanvasWidgetAndroid());
  }, (error, stackTrace) async {
    await Sentry.captureException(error, stackTrace: stackTrace);
  });
}
