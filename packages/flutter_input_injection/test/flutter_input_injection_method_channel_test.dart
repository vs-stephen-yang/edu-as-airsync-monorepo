import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_input_injection/flutter_input_injection_method_channel.dart';

void main() {
  MethodChannelFlutterInputInjection platform = MethodChannelFlutterInputInjection();
  const MethodChannel channel = MethodChannel('flutter_input_injection');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
