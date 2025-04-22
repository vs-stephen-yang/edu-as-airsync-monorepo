import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mirror/airplay_config.dart';
import 'package:flutter_mirror/bluetooth_touchback_status.dart';
import 'package:flutter_mirror/flutter_mirror_config.dart';
import 'package:flutter_mirror/googlecast_config.dart';
import 'package:flutter_mirror/mirror_type.dart';

import 'bluetooth_touchback_listener.dart';
import 'flutter_mirror_platform_interface.dart';
import 'flutter_mirror_listener.dart';
import 'package:flutter_mirror/credential_store.dart';
import 'credentials.dart';

/// An implementation of [FlutterMirrorPlatform] that uses method channels.
class MethodChannelFlutterMirror extends FlutterMirrorPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_mirror');
  FlutterMirrorListener? _mirrorListener;
  BluetoothTouchbackListener? _bluetoothTouchbackListener;

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
  Future<void> initialize(FlutterMirrorConfig config) async {
    await CredentialsStore.init();
    await methodChannel.invokeMethod('initialize', {
      "additionalCodecParams": config.additionalCodecParams,
    });
  }

  @override
  Future<void> enableDump(String? dumpPath) async {
    await methodChannel.invokeMethod('enableDump', {
      "dumpPath": dumpPath,
    });
  }

  @override
  Future<void> startMirrorReplay(
      String mirrorId, String videoCodec, String videoPath) async {
    await methodChannel.invokeMethod('startMirrorReplay', {
      'mirrorId': mirrorId,
      'videoCodec': videoCodec,
      'videoPath': videoPath,
    });
  }

  @override
  Future<void> startAirplay(AirplayConfig config) async {
    await methodChannel.invokeMethod('startAirplay', {
      "name": config.name,
      "security": config.security.name,
    });
  }

  @override
  Future<void> stopAirplay() async {
    await methodChannel.invokeMethod('stopAirplay', {});
  }

  @override
  Future<void> startGooglecast(GooglecastConfig config) async {
    // load today's credentials
    final credentials = await CredentialsStore.loadToday();

    await methodChannel.invokeMethod('startGooglecast', {
      "name": config.name,
      "uniqueId": config.uniqueId,
      "credentials": credentialToMap(credentials),
    });
  }

  @override
  Future<void> stopGooglecast() async {
    await methodChannel.invokeMethod('stopGooglecast', {});
  }

  @override
  Future<void> startMiracast(String name) async {
    await methodChannel.invokeMethod('startMiracast', {
      "name": name,
    });
  }

  @override
  Future<void> stopMiracast() async {
    await methodChannel.invokeMethod('stopMiracast', {});
  }

  @override
  Future<void> stopMirror(String mirrorId) async {
    await methodChannel.invokeMethod('stopMirror', {
      "mirrorId": mirrorId,
    });
  }

  @override
  Future<void> enableAudio(String mirrorId, bool enable) async {
    await methodChannel.invokeMethod('enableAudio', {
      "mirrorId": mirrorId,
      "enable": enable,
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

  Future<void> updateCredentials(Credentials credentials) async {
    await methodChannel.invokeMethod('updateCredentials', {
      "credentials": credentialToMap(credentials),
    });
  }

  @override
  void registerListener(FlutterMirrorListener listener) {
    _mirrorListener = listener;
  }

  @override
  void registerBluetoothTouchBackListener(BluetoothTouchbackListener listener) {
    _bluetoothTouchbackListener = listener;
  }

  // Handle method calls from the native side
  Future<dynamic> onMethodCallFromNative(MethodCall call) async {
    try {
      if (call.method == 'onMirrorStart') {
        String mirrorId = call.arguments["mirrorId"];
        int textureId = call.arguments["textureId"];
        String deviceName = call.arguments["deviceName"];
        String mirrorType = call.arguments["mirrorType"];

        _mirrorListener?.onMirrorStart(
          mirrorId,
          textureId,
          deviceName,
          MirrorType.values.byName(mirrorType),
        );
      } else if (call.method == 'onMirrorStop') {
        String mirrorId = call.arguments["mirrorId"];

        _mirrorListener?.onMirrorStop(mirrorId);
      } else if (call.method == 'onMirrorVideoResize') {
        String mirrorId = call.arguments["mirrorId"];
        int width = call.arguments["width"];
        int height = call.arguments["height"];

        _mirrorListener?.onMirrorVideoResize(mirrorId, width, height);
      } else if (call.method == 'onMirrorVideoFrameRate') {
        String mirrorId = call.arguments["mirrorId"];
        int fps = call.arguments["fps"];

        _mirrorListener?.onMirrorVideoFrameRate(mirrorId, fps);
      } else if (call.method == 'onMirrorAuth') {
        String pin = call.arguments["pin"];
        int timeoutSec = call.arguments["timeoutSec"];

        _mirrorListener?.onMirrorAuth(pin, timeoutSec);
      } else if (call.method == 'onCredentialsRequest') {
        int year = call.arguments["year"];
        int month = call.arguments["month"];
        int day = call.arguments["day"];

        final credentials = await CredentialsStore.load(year, month, day);
        await updateCredentials(credentials);
      } else if (call.method == 'onBluetoothTouchbackStatusChanged') {
        int statusCode = call.arguments["status"];
        BluetoothTouchbackStatus? status = BluetoothTouchbackStatus.values[statusCode];
        if (status != null) {
          _bluetoothTouchbackListener?.onBluetoothTouchbackStatusChanged(status);
        } else {
          log("Unknown BluetoothTouchbackStatus: $statusCode");
        }
      } else {
        log("Unknown method call from native: ${call.method}");
      }
    } catch (e) {
      log("Malformed method call from native: ${call.method}. $e");
    }
  }
}
