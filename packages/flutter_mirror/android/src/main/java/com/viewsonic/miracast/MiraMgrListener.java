package com.viewsonic.miracast;

public interface MiraMgrListener {
  public void onSessionBegin(int sessionId);

  public void onSessionEnd(int sessionId);

  public void onMirrorData(
    int sessionId,
    long seqNum,
    long lastRTPSeqNum,
    byte[] data,
    int size) throws Exception;

  public void onAudioFormatUpdate(
    int sessionId,
    String codecName,
    int sampleRate,
    int channelCount);
}
