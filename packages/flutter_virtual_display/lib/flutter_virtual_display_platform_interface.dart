import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_virtual_display_method_channel.dart';

abstract class FlutterVirtualDisplayPlatform extends PlatformInterface {
  /// Constructs a FlutterVirtualDisplayPlatform.
  FlutterVirtualDisplayPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterVirtualDisplayPlatform _instance = MethodChannelFlutterVirtualDisplay();

  /// The default instance of [FlutterVirtualDisplayPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterVirtualDisplay].
  static FlutterVirtualDisplayPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterVirtualDisplayPlatform] when
  /// they register themselves.
  static set instance(FlutterVirtualDisplayPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
