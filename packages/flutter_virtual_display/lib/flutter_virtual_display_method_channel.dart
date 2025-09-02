import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_virtual_display_platform_interface.dart';

class MethodChannelFlutterVirtualDisplay extends FlutterVirtualDisplayPlatform {
  bool _initialized = false;

  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_virtual_display');

  @override
  Future<bool?> isSupported() async {
    return await methodChannel.invokeMethod<bool>('isSupported');
  }

  @override
  Future<bool?> initialize({Map<String, dynamic>? options}) async {
    if (!_initialized) {
      _initialized = (await methodChannel
          .invokeMethod<bool>('initialize', <String, dynamic>{
        'options': options ?? {},
      }))!;
    }
    return _initialized;
  }

  @override
  Future<bool?> startVirtualDisplay(int pixelWidth, int pixelHeight) async {
    if (_initialized) {
      return methodChannel.invokeMethod<bool>(
        'startVirtualDisplay',
        {
          'pixelWidth': pixelWidth,
          'pixelHeight': pixelHeight,
        },
      );
    }
    return false;
  }

  @override
  Future<void> stopVirtualDisplay() async {
    if (_initialized) {
      await methodChannel.invokeMethod<void>('stopVirtualDisplay');
    }
  }
}
