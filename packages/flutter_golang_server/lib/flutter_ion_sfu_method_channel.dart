import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_golang_server/flutter_ion_sfu_configuration.dart';

import 'flutter_ion_sfu_platform_interface.dart';
import 'flutter_ion_sfu_listener.dart';

IceConnectionState iceConnectionStateFromInt(int value) {
  if (value >= 0 && value < IceConnectionState.values.length) {
    return IceConnectionState.values[value];
  } else {
    throw ArgumentError('Invalid value for IceConnectionState: $value');
  }
}

/// An implementation of [FlutterIonSfuPlatform] that uses method channels.
class MethodChannelFlutterIonSfu extends FlutterIonSfuPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_golang_server');
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
  Future<int> createSignalChannel() async {
    return await methodChannel.invokeMethod(
      'createSignalChannel',
      <String, dynamic>{},
    );
  }

  @override
  Future<void> closeSignalChannel(int channelId) async {
    await methodChannel.invokeMethod(
      'closeSignalChannel',
      <String, dynamic>{
        'channelId': channelId,
      },
    );
  }

  @override
  Future<void> processSignalMessage(int channelId, String message) async {
    await methodChannel.invokeMethod('processSignalMessage', <String, dynamic>{
      'channelId': channelId,
      'message': message,
    });
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
        case 'onSignalMessage':
          _listener?.onSignalMessage(
            call.arguments['channelId'],
            call.arguments['message'],
          );
          break;

        case 'onIceConnectionState':
          final state = call.arguments['state'];

          _listener?.onIceConnectionState(
            call.arguments['channelId'],
            iceConnectionStateFromInt(state),
          );
          break;

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
