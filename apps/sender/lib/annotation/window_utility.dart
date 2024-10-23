
import 'package:flutter/services.dart';

class WindowUtility {
  static const platform = MethodChannel('com.viewsonic.display.cast/window_manager');

  static Future<void> minimizeWindow() async {
    try {
      await platform.invokeMethod('minimizeWindow');
    } catch (e) {
      print("Failed to minimize window: '$e'.");
    }
  }
}