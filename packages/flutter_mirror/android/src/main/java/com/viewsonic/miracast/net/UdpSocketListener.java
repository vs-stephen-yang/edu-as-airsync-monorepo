package com.viewsonic.miracast.net;

public interface UdpSocketListener {
  void onReadable(UdpSocket socket);
}
