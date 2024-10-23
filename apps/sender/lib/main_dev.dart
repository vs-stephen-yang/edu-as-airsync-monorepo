import 'package:display_cast_flutter/main_common.dart';
import 'package:display_cast_flutter/annotation_common.dart';
import 'package:display_cast_flutter/settings/dev_config.dart';

@pragma('vm:entry-point')
void androidWindow() {
  annotationCommonEntry(DevConfig());
}

void main(List<String> args) {
  commonEntry(args, DevConfig());
}
