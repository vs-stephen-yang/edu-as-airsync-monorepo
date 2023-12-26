import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ion_sfu/flutter_ion_sfu.dart';
import 'package:flutter_ion_sfu/flutter_ion_sfu_platform_interface.dart';
import 'package:flutter_ion_sfu/flutter_ion_sfu_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterIonSfuPlatform
    with MockPlatformInterfaceMixin
    implements FlutterIonSfuPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterIonSfuPlatform initialPlatform = FlutterIonSfuPlatform.instance;

  test('$MethodChannelFlutterIonSfu is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterIonSfu>());
  });

  test('getPlatformVersion', () async {
    FlutterIonSfu flutterIonSfuPlugin = FlutterIonSfu();
    MockFlutterIonSfuPlatform fakePlatform = MockFlutterIonSfuPlatform();
    FlutterIonSfuPlatform.instance = fakePlatform;

    expect(await flutterIonSfuPlugin.getPlatformVersion(), '42');
  });
}
