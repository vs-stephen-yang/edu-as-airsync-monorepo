import 'package:display_cast_flutter/main_common.dart';
import 'package:display_cast_flutter/settings/production_config.dart';
import 'package:flutter/material.dart';

import 'annotation/canvas_widget_android.dart';

@pragma('vm:entry-point')
void androidWindow() {
  runApp(const CanvasWidgetAndroid());
}

void main(List<String> args) {
  commonEntry(args, ProductionConfig());
}
