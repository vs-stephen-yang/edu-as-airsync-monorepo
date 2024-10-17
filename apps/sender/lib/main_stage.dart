import 'package:display_cast_flutter/main_common.dart';
import 'package:display_cast_flutter/settings/stage_config.dart';
import 'package:flutter/material.dart';

import 'annotation/canvas_widget.dart';

@pragma('vm:entry-point')
void androidWindow() {
  runApp(const CanvasWidget());
}

void main(List<String> args) {
  commonEntry(args, StageConfig());
}
