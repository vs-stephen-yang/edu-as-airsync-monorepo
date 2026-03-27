package com.viewsonic.miracast;

public interface MiraSessionListener {
  void onRtspConnected(String mirrorId, String deviceName);

  void onSourceCapabilities(String mirrorId, boolean isUibcSupported);

  void onAudioFormatUpdate(String mirrorId, String codecName, int sampleRate, int channelCount);

  void onMiracastSessionError(String mirrorId, String errorMessage);

  void onVideoResolution(String mirrorId, int width, int height);

  void onRtpPacket(String mirrorId, byte[] data, int size);
}
