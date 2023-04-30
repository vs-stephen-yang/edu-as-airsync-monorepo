
import 'flutter_input_injection_platform_interface.dart';

class FlutterInputInjection {
  Future<String?> getPlatformVersion() {
    return FlutterInputInjectionPlatform.instance.getPlatformVersion();
  }

  Future<void> sendTouch(int action, int id, int x, int y) {
    return FlutterInputInjectionPlatform.instance.sendTouch(action, id, x, y);
  }
}
