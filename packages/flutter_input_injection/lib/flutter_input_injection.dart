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

  // Injects a touch event to the system (main screen)
  Future<void> initialize({
    InputInjectionMethod inputInjectionMethod = InputInjectionMethod.auto,
  }) {
    return FlutterInputInjectionPlatform.instance.initialize(
      inputInjectionMethod: inputInjectionMethod,
    );
  }

  Future<bool> isAccessibilityServiceEnabled() {
    return FlutterInputInjectionPlatform.instance.isAccessibilityServiceEnabled();
  }

  Future<void> openAccessibilitySettings() {
    return FlutterInputInjectionPlatform.instance.openAccessibilitySettings();
  }

  // Injects a touch event to the system
  Future<void> sendTouch(int action, int id, int x, int y) {
    return FlutterInputInjectionPlatform.instance.sendTouch(action, id, x, y);
  }

  // Injects a touch event to the specified screen
  Future<void> sendNormalizedTouch(int screenId, bool autoVirtualDisplay,
      int action, int id, double x, double y) {
    return FlutterInputInjectionPlatform.instance.sendNormalizedTouch(
      screenId, autoVirtualDisplay, action, id, x, y, );
  }

  // Injects a keyboard event to the system
  Future<void> sendKey(int usbKeyCode, bool pressed) {
    return FlutterInputInjectionPlatform.instance.sendKey(usbKeyCode, pressed);
  }
}
