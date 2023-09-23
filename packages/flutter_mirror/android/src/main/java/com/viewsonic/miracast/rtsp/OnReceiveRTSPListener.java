package com.viewsonic.miracast.rtsp;

public interface OnReceiveRTSPListener {
  void onRtspRequest(RtspRequestMessage request);

  void onRtspResponse(RtspResponseMessage response);

}
