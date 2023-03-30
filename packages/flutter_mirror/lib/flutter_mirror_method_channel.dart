import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_mirror_platform_interface.dart';
import 'flutter_mirror_listener.dart';

import 'credentials.dart';

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

  Map<String, Object> credentialToMap(Credentials cred) {
    return {
      'year': cred.year,
      'month': cred.month,
      'day': cred.day,
      'deviceCert': cred.deviceCertDer,
      'icaCert': cred.icaCertDer,
      'tlsCert': cred.tlsCertDer,
      'tlsKey': cred.tlsKeyDer,
      'signature': cred.signature,
    };
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
  Future<void> startGooglecast(String name, Credentials credentials) async {
    await methodChannel.invokeMethod('startGooglecast', {
      "name": name,
      "credentials": credentialToMap(credentials),
    });
  }

  @override
  Future<void> startMiracast(String name) async {
    await methodChannel.invokeMethod('startMiracast', {
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
  Future<void> onMirrorTouch(
      String mirrorId, int touchId, bool touchDown, double x, double y) async {
    await methodChannel.invokeMethod('onMirrorTouch', {
      "mirrorId": mirrorId,
      "touchId": touchId,
      "touchDown": touchDown,
      "x": x,
      "y": y,
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
      } else if (call.method == 'onCredentialsUpdate') {
        int year = call.arguments["year"];
        int month = call.arguments["month"];
        int day = call.arguments["day"];

        _listener?.onCredentialsUpdate(year, month, day);
      }
    } catch (e) {
      print("Malformed method call from native: ${call.method}. $e");
    }
  }
}
