package com.viewsonic.flutter_mirror;

public interface MirrorListener {

  public void onMirrorAuth(String pin, int timeoutSec);

  public void onMirrorStart(
      String mirrorId,
      long textureId,
      String deviceName,
      String mirrorType);

  public void onMirrorStop(String mirrorId);

  public void onMirrorVideoResize(String mirrorId, int width, int height);

  public void onMirrorVideoFrameRate(String mirrorId, int fps);

  public void onCredentialsRequest(
      int year,
      int month,
      int day);

  public void onMirrorError(String mirrorType, String errorMessage);
}
