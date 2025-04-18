import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:flutter_mirror/flutter_mirror.dart';
import 'package:flutter_mirror/mirror_type.dart';

class MirrorRequest {
  final FlutterMirror? _flutterMirrorPlugin;
  final String mirrorId;
  final int textureId;
  final String deviceName;
  final MirrorType mirrorType;
  double aspectRatio = 3 / 2;
  MirrorState mirrorState = MirrorState.idle;
  bool isAudioEnabled = false;
  bool _touchbackEnabled = false;

  MirrorRequest(this._flutterMirrorPlugin, this.mirrorId, this.textureId,
      this.deviceName, this.mirrorType);

  void controlAudio(bool isEnable, {required bool setIsAudioEnabled}) {
    _flutterMirrorPlugin?.enableAudio(mirrorId, isEnable);
    if (setIsAudioEnabled) {
      isAudioEnabled = isEnable;
    }
  }

  bool getAudioEnabled() {
    return isAudioEnabled;
  }

  void stopMirror() {
    _flutterMirrorPlugin?.stopMirror(mirrorId);
  }

  Future<bool> enableTouchback() async {
    bool success =
        await _flutterMirrorPlugin?.enableTouchback(mirrorId, true) ?? false;
    if (success) {
      _touchbackEnabled = true;
    }
    return success;
  }

  Future<bool> disableTouchback() async {
    bool success =
        await _flutterMirrorPlugin?.enableTouchback(mirrorId, false) ?? false;
    if (success) {
      _touchbackEnabled = false;
    }
    return success;
  }

  bool touchBackState() {
    return _touchbackEnabled;
  }

  void setTouchBackState(bool enable) {
    _touchbackEnabled = enable;
  }

  trackSessionEvent(String name) {
    trackEvent(
      name,
      EventCategory.session,
      mode: mirrorType.name,
      participatorId: mirrorId,
    );
  }
}
