import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mirror/flutter_mirror.dart';
import 'package:flutter_mirror/flutter_mirror_platform_interface.dart';
import 'package:flutter_mirror/flutter_mirror_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterMirrorPlatform
    with MockPlatformInterfaceMixin
    implements FlutterMirrorPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterMirrorPlatform initialPlatform = FlutterMirrorPlatform.instance;

  test('$MethodChannelFlutterMirror is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterMirror>());
  });

  test('getPlatformVersion', () async {
    FlutterMirror flutterMirrorPlugin = FlutterMirror();
    MockFlutterMirrorPlatform fakePlatform = MockFlutterMirrorPlatform();
    FlutterMirrorPlatform.instance = fakePlatform;

    expect(await flutterMirrorPlugin.getPlatformVersion(), '42');
  });
}
