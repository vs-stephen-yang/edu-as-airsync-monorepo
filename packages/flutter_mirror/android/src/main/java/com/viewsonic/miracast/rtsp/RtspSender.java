package com.viewsonic.miracast.rtsp;

public interface RtspSender {
  void sendResponse(RtspResponseMessage response);

  void sendRequest(RtspRequestMessage request);
}
