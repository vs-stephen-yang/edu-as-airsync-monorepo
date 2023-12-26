import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_ion_sfu_method_channel.dart';

abstract class FlutterIonSfuPlatform extends PlatformInterface {
  /// Constructs a FlutterIonSfuPlatform.
  FlutterIonSfuPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterIonSfuPlatform _instance = MethodChannelFlutterIonSfu();

  /// The default instance of [FlutterIonSfuPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterIonSfu].
  static FlutterIonSfuPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterIonSfuPlatform] when
  /// they register themselves.
  static set instance(FlutterIonSfuPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
