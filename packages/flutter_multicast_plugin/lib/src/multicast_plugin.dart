import 'listener.dart';
import 'platform_interface.dart';
import 'stream_roc_data.dart';
import 'video_constraints.dart';

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

  static Future<void> startCapture({required Resolution resolution}) {
    final v = videoConstraints[resolution];
    return FlutterMulticastPluginPlatform.instance.startCapture(
      width: v!.constraints.width,
      height: v.constraints.height,
      frameRate: v.constraints.frameRate,
      bitrate: v.encodings.bitrate,
      maxBitrate: v.encodings.maxBitrate,
      bitrateMode: v.encodings.bitrateMode,
    );
  }

  static Future<void> stopCapture() {
    return FlutterMulticastPluginPlatform.instance.stopCapture();
  }

  static Future<int> receiveStart(
      {required String ip,
      required int videoPort,
      required int audioPort,
      required int ssrc,
      required List<int> key,
      required List<int> salt,
      required int videoRoc,
      required int audioRoc}) {
    return FlutterMulticastPluginPlatform.instance.receiveStart(
        ip: ip,
        videoPort: videoPort,
        audioPort: audioPort,
        ssrc: ssrc,
        key: key,
        salt: salt,
        videoRoc: videoRoc,
        audioRoc: audioRoc);
  }

  static Future<void> receiveStop() {
    return FlutterMulticastPluginPlatform.instance.receiveStop();
  }

  static void registerListener(FlutterMulticastPluginListener listener) {
    return FlutterMulticastPluginPlatform.instance.registerListener(listener);
  }
}
