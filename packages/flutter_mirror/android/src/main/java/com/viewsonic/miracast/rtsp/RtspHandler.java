package com.viewsonic.miracast.rtsp;

public interface RtspHandler {
  void startUibc(String address, int port);

  void stopUibc();
}
