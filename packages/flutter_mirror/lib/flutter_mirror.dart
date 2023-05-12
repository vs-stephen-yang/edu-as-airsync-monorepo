import 'package:flutter_mirror/airplay_config.dart';
import 'package:flutter_mirror/mirror_type.dart';
import 'package:flutter_mirror/credentials.dart';

import 'flutter_mirror_platform_interface.dart';
import 'flutter_mirror_listener.dart';

class FlutterMirror {
  void registerListener(FlutterMirrorListener listener) {
    return FlutterMirrorPlatform.instance.registerListener(listener);
  }

  Future<void> initialize() {
    return FlutterMirrorPlatform.instance.initialize();
  }

  Future<void> startAirplay(AirplayConfig config) {
    return FlutterMirrorPlatform.instance.startAirplay(config);
  }

  Future<void> stopAirplay() {
    return FlutterMirrorPlatform.instance.stopAirplay();
  }

  Future<void> startGooglecast(String name) {
    return FlutterMirrorPlatform.instance.startGooglecast(name);
  }

  Future<void> stopGooglecast() {
    return FlutterMirrorPlatform.instance.stopGooglecast();
  }

  Future<void> startMiracast(String name) {
    return FlutterMirrorPlatform.instance.startMiracast(name);
  }

  Future<void> stopMiracast() {
    return FlutterMirrorPlatform.instance.stopMiracast();
  }

  Future<void> stopMirror(String mirrorId) {
    return FlutterMirrorPlatform.instance.stopMirror(mirrorId);
  }

  Future<void> enableAudio(String mirrorId, bool enable) {
    return FlutterMirrorPlatform.instance.enableAudio(mirrorId, enable);
  }

  Future<void> onMirrorTouch(
      String mirrorId, int touchId, bool touchDown, double x, double y) async {
    return FlutterMirrorPlatform.instance
        .onMirrorTouch(mirrorId, touchId, touchDown, x, y);
  }
}
