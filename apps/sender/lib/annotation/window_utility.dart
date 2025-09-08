import 'package:display_cast_flutter/utilities/log.dart';
import 'package:flutter/services.dart';

class WindowUtility {
  static const platform =
      MethodChannel('com.viewsonic.display.cast/window_manager');

  static Future<void> minimizeWindow() async {
    try {
      await platform.invokeMethod('minimizeWindow');
    } catch (e) {
      log.info("Failed to minimize window: '$e'.");
    }
  }

  static Future<Offset> getWindowPosition() async {
    try {
      final position = await platform.invokeMethod('getWindowPosition');
      return Offset(
          (position['x'] as num).toDouble(), (position['y'] as num).toDouble());
    } catch (e) {
      log.info("Failed to get window position: '$e'.");
      return Offset.zero;
    }
  }
}
