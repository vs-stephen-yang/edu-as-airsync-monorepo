import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'listener.dart';
import 'platform_interface.dart';
import 'stream_roc_data.dart';

/// An implementation of [FlutterMulticastPluginPlatform] that uses method channels.
class MethodChannelFlutterMulticastPlugin extends FlutterMulticastPluginPlatform {
  final methodChannel = const MethodChannel('flutter_multicast_plugin');

  FlutterMulticastPluginListener? _listener;

  MethodChannelFlutterMulticastPlugin() {
    methodChannel.setMethodCallHandler(onMethodCallFromNative);
  }

  @override
  Future<bool> startRtpStream({
    required String ip,
    required int videoPort,
    required int audioPort,
    required int ssrc,
    required List<int> key,
    required List<int> salt,
  }) async {
    final result = await methodChannel.invokeMethod('startRtpStream', {
      'ip': ip,
      'videoPort': videoPort,
      'audioPort': audioPort,
      'ssrc': ssrc,
      'key': key,
      'salt': salt,
    });
    return result == true;
  }

  Future<StreamRocData?> getStreamRoc() async {
    try {
      final result = await methodChannel.invokeMethod('getStreamRoc');
      return StreamRocData.fromMap(Map<String, dynamic>.from(result));
    } catch (e) {
      print('Error getting ROC: $e');
      return null;
    }
  }

  @override
  Future<void> stopRtpStream() async {
    await methodChannel.invokeMethod('stopRtpStream');
  }

  @override
  Future<void> startCapture() async {
    await methodChannel.invokeMethod('startCapture');
  }

  @override
  Future<void> stopCapture() async {
    await methodChannel.invokeMethod('stopCapture');
  }

  @override
  Future<int> receiveStart({
    required String ip,
    required int videoPort,
    required int audioPort,
    required int ssrc,
    required List<int> key,
    required List<int> salt,
    required int videoRoc,
    required int audioRoc
  }) async {
    final result = await methodChannel.invokeMethod('receiveStart', {
      'ip': ip,
      'videoPort': videoPort,
      'audioPort': audioPort,
      'ssrc': ssrc,
      'key': key,
      'salt': salt,
      'videoRoc': videoRoc,
      'audioRoc': audioRoc
    });
    return result as int;
  }

  @override
  Future<void> receiveStop() async {
    await methodChannel.invokeMethod('receiveStop');
  }

  @override
  void registerListener(FlutterMulticastPluginListener listener) {
    _listener = listener;
  }

  Future<dynamic> onMethodCallFromNative(MethodCall call) async {
    try {
      print("onMethodCallFromNative: ${call.method}");
      switch (call.method) {
        case 'onVideoSize':
          _listener?.onVideoSize(
            call.arguments['width'],
            call.arguments['height'],
          );
          break;
        default:
          throw MissingPluginException();
      }
    } catch (e) {
      print("Malformed method call from native: ${call.method}. $e");
    }
  }
}
