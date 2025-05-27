package com.viewsonic.miracast.wifidirect;

public interface WiFiDirectListener {
  void onPeerConnected(String peerMacAddress, String name, String ip, int port);

  void onPeerDisconnected(String peerMacAddress);

  void onWifiDirectError(String errorMessage);
}
