package com.viewsonic.miracast.rtsp;

public interface RtspHandler {

  // return rtp port
  int startRTPReceiver();

  void startUibc(String address, int port);

  void stopUibc();
}
