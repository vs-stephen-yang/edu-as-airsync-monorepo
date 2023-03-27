abstract class FlutterMirrorListener {
  void onMirrorAuth(String pin, int timeoutSec);

  void onMirrorStart(String mirrorId, int textureId);
  void onMirrorStop(String mirrorId);

  void onMirrorVideoResize(String mirrorId, int width, int height);
}
