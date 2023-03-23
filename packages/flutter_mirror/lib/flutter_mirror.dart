
import 'flutter_mirror_platform_interface.dart';

class FlutterMirror {
  Future<String?> getPlatformVersion() {
    return FlutterMirrorPlatform.instance.getPlatformVersion();
  }
}
