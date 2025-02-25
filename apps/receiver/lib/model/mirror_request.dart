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
}
