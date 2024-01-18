import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ion_sfu/flutter_ion_sfu_configuration.dart';

import 'flutter_ion_sfu_platform_interface.dart';
import 'flutter_ion_sfu_listener.dart';

/// An implementation of [FlutterIonSfuPlatform] that uses method channels.
class MethodChannelFlutterIonSfu extends FlutterIonSfuPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_ion_sfu');
  FlutterIonSfuListener? _listener;

  MethodChannelFlutterIonSfu() {
    // Register the handler for the method calls from the native side
    methodChannel.setMethodCallHandler(onMethodCallFromNative);
  }

  @override
  Future<void> initialize() async {
    await methodChannel.invokeMethod('initialize');
  }

  @override
  Future<void> start(
    FlutterIonSfuConfiguration configuration,
  ) async {
    await methodChannel.invokeMethod('start', <String, dynamic>{
      'configuration': configuration.toMap(),
    });
  }

  @override
  Future<void> stop() async {
    await methodChannel.invokeMethod('stop');
  }

  @override
  void registerListener(FlutterIonSfuListener listener) {
    _listener = listener;
  }

  // Handle method calls from the native side
  Future<dynamic> onMethodCallFromNative(MethodCall call) async {
    try {
      print("onMethodCallFromNative: ${call.method}");
      switch (call.method) {
        case 'onError':
          _listener?.onError(call.arguments['error'], call.arguments['msg']);
          break;
        default:
          throw MissingPluginException();
      }
    } catch (e) {
      print("Malformed method call from native: ${call.method}. $e");
    }
  }
}
