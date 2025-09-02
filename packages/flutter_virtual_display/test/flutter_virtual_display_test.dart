import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_virtual_display/flutter_virtual_display_platform_interface.dart';
import 'package:flutter_virtual_display/flutter_virtual_display_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterVirtualDisplayPlatform
    with MockPlatformInterfaceMixin
    implements FlutterVirtualDisplayPlatform {

  @override
  Future<bool?> isSupported() {
    return Future.value(true);
  }

  @override
  Future<bool?> initialize({Map<String, dynamic>? options}) {
    return Future.value(true);
  }

  @override
  Future<bool?> startVirtualDisplay(int pixelWidth, int pixelHeight) {
    return Future.value(true);
  }

  @override
  Future<void> stopVirtualDisplay() {
    return Future.value();
  }
}

void main() {
  final FlutterVirtualDisplayPlatform initialPlatform = FlutterVirtualDisplayPlatform.instance;

  test('$MethodChannelFlutterVirtualDisplay is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterVirtualDisplay>());
  });
}
