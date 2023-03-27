import 'flutter_mirror_platform_interface.dart';
import 'flutter_mirror_listener.dart';

class FlutterMirror {
  void registerListener(FlutterMirrorListener listener) {
    return FlutterMirrorPlatform.instance.registerListener(listener);
  }

  Future<void> initialize() {
    return FlutterMirrorPlatform.instance.initialize();
  }

  Future<void> startAirplay(String name) {
    return FlutterMirrorPlatform.instance.startAirplay(name);
  }

  Future<void> stopMirror(String mirrorId) {
    return FlutterMirrorPlatform.instance.stopMirror(mirrorId);
  }
}
