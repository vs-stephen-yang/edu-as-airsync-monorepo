package com.viewsonic.flutter_mirror;

public interface MirrorListener {

  public void onMirrorAuth(String pin, int timeoutSec);

  public void onMirrorStart(String mirrorId, long textureId);

  public void onMirrorStop(String mirrorId);

  public void onMirrorVideoResize(String mirrorId, int width, int height);
}
