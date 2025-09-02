import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_virtual_display_method_channel.dart';

abstract class FlutterVirtualDisplayPlatform extends PlatformInterface {
  FlutterVirtualDisplayPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterVirtualDisplayPlatform _instance = MethodChannelFlutterVirtualDisplay();

  static FlutterVirtualDisplayPlatform get instance => _instance;

  static set instance(FlutterVirtualDisplayPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool?> isSupported() {
    throw UnimplementedError('isSupported() has not been implemented.');
  }

  Future<bool?> initialize({Map<String, dynamic>? options}) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  Future<bool?> startVirtualDisplay(int pixelWidth, int pixelHeight) {
    throw UnimplementedError('startVirtualDisplay() has not been implemented.');
  }

  Future<void> stopVirtualDisplay() {
    throw UnimplementedError('stopVirtualDisplay() has not been implemented.');
  }
}
