import 'mirror_type.dart';

abstract class FlutterMirrorListener {
  void onMirrorAuth(String pin, int timeoutSec);

  void onMirrorStart(
    String mirrorId,
    int textureId,
    String deviceName,
    MirrorType mirrorType,
    String deviceModel,
  );

  void onMirrorStop(String mirrorId);

  void onMirrorVideoResize(String mirrorId, int width, int height);

  void onMirrorVideoFrameRate(String mirrorId, int fps);

  void onMirrorError(String mirrorType, String errorMessage);

  void onMirrorCapabilities(
    String mirrorId,
    bool? isUibcSupported,
  );
}
