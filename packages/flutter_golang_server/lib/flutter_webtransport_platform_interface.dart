import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_webtransport_config.dart';
import 'flutter_webtransport_listener.dart';
import 'flutter_webtransport_method_channel.dart';

abstract class FlutterWebtransportPlatform extends PlatformInterface {
  /// Constructs a FlutterWebtransportPlatform.
  FlutterWebtransportPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterWebtransportPlatform _instance =
      MethodChannelFlutterWebtransport();

  /// The default instance of [FlutterWebtransportPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterWebtransport].
  static FlutterWebtransportPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterWebtransportPlatform] when
  /// they register themselves.
  static set instance(FlutterWebtransportPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  void registerListener(FlutterWebtransportListener listener) {
    throw UnimplementedError('registerListener() has not been implemented.');
  }

  Future<void> addAllowOrigin(String string) {
    throw UnimplementedError('addAllowOrigin() has not been implemented.');
  }

  Future<void> startWebTransportServer(FlutterWebtransportConfig config) {
    throw UnimplementedError(
        'startWebTransportServer() has not been implemented.');
  }

  Future<void> stopServer() {
    throw UnimplementedError('stopServer() has not been implemented.');
  }

  Future<void> sendMessage(String connId, String message) {
    throw UnimplementedError('sendMessage() has not been implemented.');
  }

  Future<void> updateCertificate(FlutterWebtransportConfig config) {
    throw UnimplementedError('updateCertificate() has not been implemented.');
  }
}
