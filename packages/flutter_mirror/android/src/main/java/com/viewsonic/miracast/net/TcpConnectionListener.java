package com.viewsonic.miracast.net;

public interface TcpConnectionListener {
  void onConnected(TcpConnection connection);

  void onConnectFailed(TcpConnection connection);

  void onReadable(TcpConnection connection);

  void onWritable(TcpConnection connection);
}
