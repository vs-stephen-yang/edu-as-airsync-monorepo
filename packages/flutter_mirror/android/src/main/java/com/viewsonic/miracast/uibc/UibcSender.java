package com.viewsonic.miracast.uibc;

public interface UibcSender {
  // return false if the sender buffer is full
  void sendUibcData(byte[] data);
}
