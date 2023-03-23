import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_mirror_method_channel.dart';

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

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
