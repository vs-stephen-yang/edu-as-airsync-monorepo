package com.viewsonic.miracast;

public interface MiraMgrListener {
  public void onSessionBegin(
      String mirrorId,
      String deviceName);

  public void onSessionEnd(String mirrorId);

  public void onMirrorData(
      String mirrorId,
      long seqNum,
      long lastRTPSeqNum,
      byte[] data,
      int size) throws Exception;

  public void onAudioFormatUpdate(
      String mirrorId,
      String codecName,
      int sampleRate,
      int channelCount);

  void onMiracastError(String errorMessage);
}
