import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_ion_sfu_platform_interface.dart';

/// An implementation of [FlutterIonSfuPlatform] that uses method channels.
class MethodChannelFlutterIonSfu extends FlutterIonSfuPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_ion_sfu');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
