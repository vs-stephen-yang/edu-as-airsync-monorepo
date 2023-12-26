
import 'flutter_ion_sfu_platform_interface.dart';

class FlutterIonSfu {
  Future<String?> getPlatformVersion() {
    return FlutterIonSfuPlatform.instance.getPlatformVersion();
  }
}
