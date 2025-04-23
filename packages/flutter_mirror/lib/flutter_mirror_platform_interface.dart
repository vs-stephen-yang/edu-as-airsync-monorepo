import 'package:flutter_mirror/flutter_mirror_config.dart';
import 'package:flutter_mirror/googlecast_config.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'bluetooth_touchback_listener.dart';
import 'flutter_mirror_method_channel.dart';
import 'flutter_mirror_listener.dart';

import 'airplay_config.dart';

abstract class FlutterMirrorPlatform extends PlatformInterface {
  /// Constructs a FlutterMirrorPlatform.
  FlutterMirrorPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterMirrorPlatform _instance = MethodChannelFlutterMirror();

  /// The default instance of [FlutterMirrorPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterMirror].
  static FlutterMirrorPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterMirrorPlatform] when
  /// they register themselves.
  static set instance(FlutterMirrorPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  void registerListener(FlutterMirrorListener listener) {
    throw UnimplementedError('registerListener() has not been implemented.');
  }

  void registerBluetoothTouchBackListener(BluetoothTouchbackListener listener) {
    throw UnimplementedError(
        'registerBluetoothTouchBackListener() has not been implemented.');
  }

  Future<void> initialize(FlutterMirrorConfig config) async {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  Future<void> enableDump(String? dumpPath) async {
    throw UnimplementedError('enableDump() has not been implemented.');
  }

  Future<void> startMirrorReplay(
      String mirrorId, String videoCodec, String videoPath) async {
    throw UnimplementedError('startMirrorReplay() has not been implemented.');
  }

  Future<void> startAirplay(AirplayConfig config) async {
    throw UnimplementedError('startAirplay() has not been implemented.');
  }

  Future<void> stopAirplay() async {
    throw UnimplementedError('stopAirplay() has not been implemented.');
  }

  Future<void> startGooglecast(GooglecastConfig config) async {
    throw UnimplementedError('startGooglecast() has not been implemented.');
  }

  Future<void> stopGooglecast() async {
    throw UnimplementedError('stopGooglecast() has not been implemented.');
  }

  Future<void> startMiracast(String name) async {
    throw UnimplementedError('startMiracast() has not been implemented.');
  }

  Future<void> stopMiracast() async {
    throw UnimplementedError('stopMiracast() has not been implemented.');
  }

  Future<void> stopMirror(String mirrorId) async {
    throw UnimplementedError('stopMirror() has not been implemented.');
  }

  Future<void> enableAudio(String mirrorId, bool enable) async {
    throw UnimplementedError('enableAudio() has not been implemented.');
  }

  Future<bool> enableTouchback(String mirrorId, bool enable) async {
    throw UnimplementedError('enableTouchback() has not been implemented.');
  }

  Future<void> onMirrorTouch(
      String mirrorId, int touchId, bool touchDown, double x, double y) async {
    throw UnimplementedError('onMirrorTouch() has not been implemented.');
  }
}
