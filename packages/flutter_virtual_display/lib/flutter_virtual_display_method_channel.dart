import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_virtual_display_platform_interface.dart';

/// An implementation of [FlutterVirtualDisplayPlatform] that uses method channels.
class MethodChannelFlutterVirtualDisplay extends FlutterVirtualDisplayPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_virtual_display');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
