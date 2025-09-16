package com.viewsonic.flutter_mirror;

public interface MiracastReceiverListener {
  void onMiracastError(String errorMessage);

  void onSourceCapabilities(String mirrorId, boolean isUibcSupported);

  void onMiracastStart(String mirrorId,
                       long textureId,
                       String deviceName);

  void onMiracastStop(String mirrorId);
}
