import 'package:flutter/services.dart';

import 'flutter_input_injection_platform_interface.dart';

/// An implementation of [FlutterInputInjectionPlatform] that uses method channels.
class MethodChannelFlutterInputInjection extends FlutterInputInjectionPlatform {
  /// The method channel used to interact with the native platform.
  final methodChannel = const MethodChannel('flutter_input_injection');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> initialize({
    InputInjectionMethod inputInjectionMethod = InputInjectionMethod.auto,
  }) async {
    await methodChannel.invokeMethod<void>('initialize', {
      'inputInjectionMethod': inputInjectionMethod.name,
    });
  }

  @override
  Future<bool> isAccessibilityServiceEnabled() async {
    final enabled =
        await methodChannel.invokeMethod<bool>('isAccessibilityEnabled') ??
            false;
    return enabled;
  }

  @override
  Future<void> openAccessibilitySettings() async {
    try {
      await methodChannel.invokeMethod('openAccessibilitySettings');
    } on PlatformException catch (e) {
      print("Failed to open accessibility settings: ${e.message}");
    }
  }

  @override
  Future<void> sendTouch(int action, int id, int x, int y) async {
    await methodChannel.invokeMethod<void>('sendTouch', {
      'action': action,
      'id': id,
      'x': x,
      'y': y,
    });
  }

  @override
  Future<void> sendNormalizedTouch(int screenId, bool autoVirtualDisplay,
      int action, int id, double x, double y) async {
    await methodChannel.invokeMethod<void>('sendNormalizedTouch', {
      'action': action,
      'id': id,
      'x': x,
      'y': y,
      'screenId': screenId,
      'autoVirtualDisplay': autoVirtualDisplay,
    });
  }

  @override
  Future<void> setLongPressDelay(int delayMs) async {
    await methodChannel.invokeMethod<void>('setLongPressDelay', {
      'delayMs': delayMs,
    });
  }

  @override
  Future<void> sendKey(int usbKeyCode, bool pressed) async {
    await methodChannel.invokeMethod<void>('sendKey', {
      'usbKeyCode': usbKeyCode,
      'pressed': pressed,
    });
  }
}
