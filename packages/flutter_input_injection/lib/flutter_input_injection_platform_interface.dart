import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_input_injection_method_channel.dart';

enum InputInjectionMethod {
  uinput,
  accessibilityService,
  auto, // automatically choose the default injection method
}

abstract class FlutterInputInjectionPlatform extends PlatformInterface {
  /// Constructs a FlutterInputInjectionPlatform.
  FlutterInputInjectionPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterInputInjectionPlatform _instance =
      MethodChannelFlutterInputInjection();

  /// The default instance of [FlutterInputInjectionPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterInputInjection].
  static FlutterInputInjectionPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterInputInjectionPlatform] when
  /// they register themselves.
  static set instance(FlutterInputInjectionPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> initialize({
    InputInjectionMethod inputInjectionMethod = InputInjectionMethod.auto,
  }) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  Future<bool> isAccessibilityServiceEnabled() {
    throw UnimplementedError('isAccessibilityServiceEnabled() has not been implemented.');
  }

  Future<void> openAccessibilitySettings() async {
    throw UnimplementedError('openAccessibilitySettings() has not been implemented.');
  }

  Future<void> sendTouch(int action, int id, int x, int y) {
    throw UnimplementedError('sendTouch() has not been implemented.');
  }

  Future<void> sendNormalizedTouch(int screenId, bool autoVirtualDisplay,
      int action, int id, double x, double y) {
    throw UnimplementedError('sendNormalizedTouch() has not been implemented.');
  }

  Future<void> sendKey(int usbKeyCode, bool pressed) {
    throw UnimplementedError('sendKey() has not been implemented.');
  }
}
