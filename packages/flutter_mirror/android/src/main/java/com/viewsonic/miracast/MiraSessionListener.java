package com.viewsonic.miracast;

public interface MiraSessionListener {
  void onRtspConnected(String mirrorId, String deviceName);

  void onMirrorData(String mirrorId, long seqNum, long lastSeqNum, byte[] data, int size);

  void onAudioFormatUpdate(String mirrorId, String codecName, int sampleRate, int channelCount);

  void onMiracastSessionError(String mirrorId, String errorMessage);
}
