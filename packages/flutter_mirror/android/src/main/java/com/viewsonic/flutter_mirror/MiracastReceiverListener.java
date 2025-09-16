package com.viewsonic.flutter_mirror;

public interface MiracastReceiverListener {
  public void onMiracastError(String errorMessage);

  public void onSourceCapabilities(String mirrorId, boolean isUibcSupported);

  void onMiracastStart(long textureId);
}
