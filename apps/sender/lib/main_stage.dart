import 'package:display_cast_flutter/main_common.dart';
import 'package:display_cast_flutter/annotation_common.dart';
import 'package:display_cast_flutter/settings/stage_config.dart';

@pragma('vm:entry-point')
void androidWindow() {
  annotationCommonEntry(StageConfig());
}

void main(List<String> args) {
  commonEntry(args, StageConfig());
}
