import 'platform_interface.dart';
import 'stream_roc_data.dart';

class FlutterMulticastPlugin {
  static Future<bool> startRtpStream({
    required String ip,
    required int videoPort,
    required int audioPort,
    required int ssrc,
    required List<int> key,
    required List<int> salt,
  }) {
    return FlutterMulticastPluginPlatform.instance.startRtpStream(
      ip: ip,
      videoPort: videoPort,
      audioPort: audioPort,
      ssrc: ssrc,
      key: key,
      salt: salt,
    );
  }

  static Future<StreamRocData?> getStreamRoc() {
    return FlutterMulticastPluginPlatform.instance.getStreamRoc();
  }

  static Future<void> stopRtpStream() {
    return FlutterMulticastPluginPlatform.instance.stopRtpStream();
  }

  static Future<void> startCapture() {
    return FlutterMulticastPluginPlatform.instance.startCapture();
  }

  static Future<void> stopCapture() {
    return FlutterMulticastPluginPlatform.instance.stopCapture();
  }

  static Future<int> receiveStart({
    required String ip,
    required int videoPort,
    required int audioPort,
    required int ssrc,
    required List<int> key,
    required List<int> salt,
    required int videoRoc,
    required int audioRoc
  }) {
    return FlutterMulticastPluginPlatform.instance.receiveStart(
        ip: ip,
        videoPort: videoPort,
        audioPort: audioPort,
        ssrc: ssrc,
        key: key,
        salt: salt,
        videoRoc: videoRoc,
        audioRoc: audioRoc
    );
  }

  static Future<void> receiveStop() {
    return FlutterMulticastPluginPlatform.instance.receiveStop();
  }
}
