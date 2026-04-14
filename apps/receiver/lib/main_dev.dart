import 'package:display_flutter/main_common.dart';
import 'package:display_flutter/main_common_overlay_tab.dart';
import 'package:display_flutter/settings/dev_config.dart';

void main() {
  commonEntry(DevConfig());
}

@pragma('vm:entry-point')
void androidWindow() {
  commonOverlayTabEntry(DevConfig());
}
