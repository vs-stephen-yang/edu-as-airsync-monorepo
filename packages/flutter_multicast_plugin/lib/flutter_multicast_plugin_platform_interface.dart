import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_multicast_plugin_method_channel.dart';

abstract class FlutterMulticastPluginPlatform extends PlatformInterface {
  /// Constructs a FlutterMulticastPluginPlatform.
  FlutterMulticastPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterMulticastPluginPlatform _instance = MethodChannelFlutterMulticastPlugin();

  /// The default instance of [FlutterMulticastPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterMulticastPlugin].
  static FlutterMulticastPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterMulticastPluginPlatform] when
  /// they register themselves.
  static set instance(FlutterMulticastPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
