import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_multicast_plugin/multicast_plugin.dart';
import 'package:flutter_multicast_plugin/platform_interface.dart';
import 'package:flutter_multicast_plugin/method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterMulticastPluginPlatform
    with MockPlatformInterfaceMixin
    implements FlutterMulticastPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterMulticastPluginPlatform initialPlatform = FlutterMulticastPluginPlatform.instance;

  test('$MethodChannelFlutterMulticastPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterMulticastPlugin>());
  });

  test('getPlatformVersion', () async {
    FlutterMulticastPlugin flutterMulticastPlugin = FlutterMulticastPlugin();
    MockFlutterMulticastPluginPlatform fakePlatform = MockFlutterMulticastPluginPlatform();
    FlutterMulticastPluginPlatform.instance = fakePlatform;

    expect(await flutterMulticastPlugin.getPlatformVersion(), '42');
  });
}
