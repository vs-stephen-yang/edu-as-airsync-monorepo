package com.viewsonic.miracast.rtsp;

public interface RtspSender {
  public void sendResponse(RtspResponseMessage response);

  public void sendRequest(RtspRequestMessage request);
}
