import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_virtual_display/flutter_virtual_display.dart';
import 'package:flutter_virtual_display/flutter_virtual_display_platform_interface.dart';
import 'package:flutter_virtual_display/flutter_virtual_display_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterVirtualDisplayPlatform
    with MockPlatformInterfaceMixin
    implements FlutterVirtualDisplayPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterVirtualDisplayPlatform initialPlatform = FlutterVirtualDisplayPlatform.instance;

  test('$MethodChannelFlutterVirtualDisplay is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterVirtualDisplay>());
  });

  test('getPlatformVersion', () async {
    FlutterVirtualDisplay flutterVirtualDisplayPlugin = FlutterVirtualDisplay();
    MockFlutterVirtualDisplayPlatform fakePlatform = MockFlutterVirtualDisplayPlatform();
    FlutterVirtualDisplayPlatform.instance = fakePlatform;

    expect(await flutterVirtualDisplayPlugin.getPlatformVersion(), '42');
  });
}
