import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_mirror_platform_interface.dart';
import 'flutter_mirror_listener.dart';

/// An implementation of [FlutterMirrorPlatform] that uses method channels.
class MethodChannelFlutterMirror extends FlutterMirrorPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_mirror');
  FlutterMirrorListener? _listener;

  MethodChannelFlutterMirror() {
    // Register the handler for the method calls from the native side
    methodChannel.setMethodCallHandler(onMethodCallFromNative);
  }

  @override
  Future<void> initialize() async {
    await methodChannel.invokeMethod('initialize');
  }

  @override
  Future<void> startAirplay(String name) async {
    await methodChannel.invokeMethod('startAirplay', {
      "name": name,
    });
  }

  @override
  Future<void> stopMirror(String mirrorId) async {
    await methodChannel.invokeMethod('stopMirror', {
      "mirrorId": mirrorId,
    });
  }

  @override
  void registerListener(FlutterMirrorListener listener) {
    _listener = listener;
  }

  // Handle method calls from the native side
  Future<dynamic> onMethodCallFromNative(MethodCall call) async {
    try {
      if (call.method == 'onMirrorStart') {
        String mirrorId = call.arguments["mirrorId"];
        int textureId = call.arguments["textureId"];

        _listener?.onMirrorStart(mirrorId, textureId);
      } else if (call.method == 'onMirrorStop') {
        String mirrorId = call.arguments["mirrorId"];

        _listener?.onMirrorStop(mirrorId);
      } else if (call.method == 'onMirrorVideoResize') {
        String mirrorId = call.arguments["mirrorId"];
        int width = call.arguments["width"];
        int height = call.arguments["height"];

        _listener?.onMirrorVideoResize(mirrorId, width, height);
      } else if (call.method == 'onMirrorAuth') {
        String pin = call.arguments["pin"];
        int timeoutSec = call.arguments["timeoutSec"];

        _listener?.onMirrorAuth(pin, timeoutSec);
      }
    } catch (e) {
      print("Malformed method call from native: ${call.method}. $e");
    }
  }
}
