import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_mirror_platform_interface.dart';

/// An implementation of [FlutterMirrorPlatform] that uses method channels.
class MethodChannelFlutterMirror extends FlutterMirrorPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_mirror');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
