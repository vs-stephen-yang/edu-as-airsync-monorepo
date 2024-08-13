
import 'flutter_virtual_display_platform_interface.dart';

class FlutterVirtualDisplay {
  Future<String?> getPlatformVersion() {
    return FlutterVirtualDisplayPlatform.instance.getPlatformVersion();
  }
}
