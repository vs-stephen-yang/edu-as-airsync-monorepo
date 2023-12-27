import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ion_sfu/flutter_ion_sfu_configuration.dart';

import 'flutter_ion_sfu_platform_interface.dart';

/// An implementation of [FlutterIonSfuPlatform] that uses method channels.
class MethodChannelFlutterIonSfu extends FlutterIonSfuPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_ion_sfu');

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
}
