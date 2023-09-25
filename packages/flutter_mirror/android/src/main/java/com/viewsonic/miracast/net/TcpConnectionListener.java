package com.viewsonic.miracast.net;

public interface TcpConnectionListener {
  void onConnected(TcpConnection connection);

  void onDisconnected(TcpConnection connection);

  void onConnectTimeout(TcpConnection connection);

  void onReadable(TcpConnection connection);

  void onWritable(TcpConnection connection);

  void onError(TcpConnection connection);

  void onReconnect(TcpConnection connection, int attempts);
}
