package com.viewsonic.miracast;

public interface MiraMgrListener {
  void onAudioFormatUpdate(
    String mirrorId,
    String codecName,
    int sampleRate,
    int channelCount);

  void onMiracastError(String errorMessage);

  void onSourceCapabilities(
    String mirrorId,
    boolean isUibcSupported);

  void onMiracastStart(String mirrorId,
                       long textureId,
                       String deviceName);

  void onSessionEnd(String mirrorId);
}
