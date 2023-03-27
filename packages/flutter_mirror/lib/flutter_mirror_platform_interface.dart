import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_mirror_method_channel.dart';
import 'flutter_mirror_listener.dart';

abstract class FlutterMirrorPlatform extends PlatformInterface {
  /// Constructs a FlutterMirrorPlatform.
  FlutterMirrorPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterMirrorPlatform _instance = MethodChannelFlutterMirror();

  /// The default instance of [FlutterMirrorPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterMirror].
  static FlutterMirrorPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterMirrorPlatform] when
  /// they register themselves.
  static set instance(FlutterMirrorPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  void registerListener(FlutterMirrorListener listener) {
    throw UnimplementedError('registerListener() has not been implemented.');
  }

  Future<void> initialize() {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  Future<void> startAirplay(String name) async {
    throw UnimplementedError('startAirplay() has not been implemented.');
  }

  Future<void> stopMirror(String mirrorId) async {
    throw UnimplementedError('stopMirror() has not been implemented.');
  }
}
