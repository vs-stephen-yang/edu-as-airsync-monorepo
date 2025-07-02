import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_multicast_plugin_method_channel.dart';
import 'stream_roc_data.dart';

abstract class FlutterMulticastPluginPlatform extends PlatformInterface {
  FlutterMulticastPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterMulticastPluginPlatform _instance = MethodChannelFlutterMulticastPlugin();

  static FlutterMulticastPluginPlatform get instance => _instance;

  static set instance(FlutterMulticastPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool> startRtpStream({
    required String ip,
    required int videoPort,
    required int audioPort,
    required int ssrc,
    required List<int> key,
    required List<int> salt,
  }) {
    throw UnimplementedError('startRtpStream() has not been implemented.');
  }

  Future<StreamRocData?> getStreamRoc() {
    throw UnimplementedError('getStreamRoc() has not been implemented.');
  }

  Future<void> stopRtpStream() {
    throw UnimplementedError('stopRtpStream() has not been implemented.');
  }

  Future<void> startCapture() {
    throw UnimplementedError('startCapture() has not been implemented.');
  }

  Future<void> stopCapture() {
    throw UnimplementedError('stopCapture() has not been implemented.');
  }

  Future<int> receiveStart({
    required String ip,
    required int videoPort,
    required int audioPort,
    required int ssrc,
    required List<int> key,
    required List<int> salt,
    required int videoRoc,
    required int audioRoc
  }) {
    throw UnimplementedError('receiveStart() has not been implemented.');
  }

  Future<void> receiveStop() {
    throw UnimplementedError('receiveStop() has not been implemented.');
  }
}
