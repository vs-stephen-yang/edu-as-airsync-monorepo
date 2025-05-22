package com.viewsonic.miracast.wifidirect;

public interface WiFiDirectListener {
  void onPeerConnected(String name, String ip, int port);

  void onPeerDisconnected(String ip);

  void onWifiDirectError(String errorMessage);
}
