
import 'flutter_input_injection_platform_interface.dart';

class FlutterInputInjection {
  Future<String?> getPlatformVersion() {
    return FlutterInputInjectionPlatform.instance.getPlatformVersion();
  }
}
