
import 'flutter_input_injection_platform_interface.dart';

class FlutterInputInjection {
  /* action type of touch event */
  static const int TOUCH_POINT_START = 0;
  static const int TOUCH_POINT_MOVE = 1;
  static const int TOUCH_POINT_END = 2;
  static const int TOUCH_POINT_CANCEL = 3;

  Future<String?> getPlatformVersion() {
    return FlutterInputInjectionPlatform.instance.getPlatformVersion();
  }

  Future<void> sendTouch(int action, int id, int x, int y) {
    return FlutterInputInjectionPlatform.instance.sendTouch(action, id, x, y);
  }
}
