package com.viewsonic.miracast.rtp;

public interface OnReceiveRTPListener {
  void onRtpData(long seqNum, byte[] data, int size);
}
