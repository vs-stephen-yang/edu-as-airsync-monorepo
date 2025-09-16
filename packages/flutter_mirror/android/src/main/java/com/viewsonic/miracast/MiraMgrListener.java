package com.viewsonic.miracast;

public interface MiraMgrListener {
  public void onAudioFormatUpdate(
    String mirrorId,
    String codecName,
    int sampleRate,
    int channelCount);

  void onMiracastError(String errorMessage);

  public void onSourceCapabilities(
    String mirrorId,
    boolean isUibcSupported);

  void onMiracastStart(long textureId);
}
