package com.viewsonic.miracast;

public interface OnMirrorListener {
  void onPeerConnected(String name, String ip, int port);

  void onPeerDisconnected(String ip);

  void onMirrorData(String mirrorId, long seqNum, long lastSeqNum, byte[] data, int size);

  void onAudioFormatUpdate(String mirrorId, String codecName, int sampleRate, int channelCount);
}
