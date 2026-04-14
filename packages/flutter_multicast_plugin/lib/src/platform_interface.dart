import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'listener.dart';
import 'method_channel.dart';
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

  void registerListener(FlutterMulticastPluginListener listener) {
    throw UnimplementedError('registerListener() has not been implemented.');
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

  Future<void> startCapture({
    required int width,
    required int height,
    required int bitrate,
    required int maxBitrate,
    required int frameRate,
    required String bitrateMode,
}) {
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
