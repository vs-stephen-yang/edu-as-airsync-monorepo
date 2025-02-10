import 'package:flutter_golang_server/flutter_ion_sfu_configuration.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_ion_sfu_method_channel.dart';
import 'flutter_ion_sfu_listener.dart';

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

  void registerListener(FlutterIonSfuListener listener) {
    throw UnimplementedError('registerListener() has not been implemented.');
  }

  Future<void> initialize() {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  Future<void> start(
    FlutterIonSfuConfiguration configuration,
  ) {
    throw UnimplementedError('start() has not been implemented.');
  }

  Future<void> stop() {
    throw UnimplementedError('stop() has not been implemented.');
  }

  Future<int> createSignalChannel() {
    throw UnimplementedError('createSignalChannel() has not been implemented.');
  }

  Future<void> closeSignalChannel(int channelId) {
    throw UnimplementedError('closeSignalChannel() has not been implemented.');
  }

  Future<void> processSignalMessage(int channelId, String message) {
    throw UnimplementedError('processSignalMessage() has not been implemented.');
  }
}
