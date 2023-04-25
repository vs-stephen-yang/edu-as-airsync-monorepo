import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_input_injection/flutter_input_injection.dart';
import 'package:flutter_input_injection/flutter_input_injection_platform_interface.dart';
import 'package:flutter_input_injection/flutter_input_injection_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterInputInjectionPlatform
    with MockPlatformInterfaceMixin
    implements FlutterInputInjectionPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterInputInjectionPlatform initialPlatform = FlutterInputInjectionPlatform.instance;

  test('$MethodChannelFlutterInputInjection is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterInputInjection>());
  });

  test('getPlatformVersion', () async {
    FlutterInputInjection flutterInputInjectionPlugin = FlutterInputInjection();
    MockFlutterInputInjectionPlatform fakePlatform = MockFlutterInputInjectionPlatform();
    FlutterInputInjectionPlatform.instance = fakePlatform;

    expect(await flutterInputInjectionPlugin.getPlatformVersion(), '42');
  });
}
