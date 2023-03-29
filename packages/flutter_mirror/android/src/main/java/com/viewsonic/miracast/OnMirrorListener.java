package com.viewsonic.miracast;

public interface OnMirrorListener {
  void onPeerConnected(String name, String ip, int port);

  void onPeerDisconnected(String ip);

  void onMirrorData(int sessionId, long seqNum, long lastSeqNum, byte[] data, int size);

  void onAudioFormatUpdate(int sessionId, String codecName, int sampleRate, int channelCount);
}
