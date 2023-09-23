package com.viewsonic.miracast.net;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.SelectionKey;
import java.nio.channels.SocketChannel;

public class TcpConnection
    implements ChannelListener {

  private static final String TAG = "TcpConnection";

  EventBase eventBase_;
  SocketChannel socket_;
  TcpConnectionListener listener_;

  public TcpConnection(
      EventBase eventBase,
      TcpConnectionListener listener)
      throws IOException {
    eventBase_ = eventBase;
    listener_ = listener;

    socket_ = SocketChannel.open();
  }

  public void close() throws IOException {
    socket_.close();
  }

  public void setNoDelay() throws IOException {
    socket_.socket().setTcpNoDelay(true);
  }

  public void connect(String host, int port) throws IOException {

    // configure non-blocking
    socket_.configureBlocking(false);

    socket_.connect(new InetSocketAddress(host, port));

    eventBase_.registerChannel(socket_, SelectionKey.OP_CONNECT, this);
  }

  public int read(ByteBuffer buffer) throws IOException {
    return socket_.read(buffer);
  }

  public int write(ByteBuffer buffer) throws IOException {
    return socket_.write(buffer);
  }

  public void onOpsReady(SelectionKey key) {
    try {
      if (key.isConnectable()) {
        onConnectable(key);
      } else if (key.isReadable()) {
        onReadable(key);
      }
    } catch (IOException e) {
      // TODO:
    }
  }

  private void onConnectable(SelectionKey key) throws IOException {
    SocketChannel channel = (SocketChannel) key.channel();

    if (!channel.isConnectionPending()) {
      return;
    }

    channel.finishConnect();

    eventBase_.registerChannel(channel, SelectionKey.OP_READ, this);

    listener_.onConnected(this);
  }

  private void onReadable(SelectionKey key) {
    listener_.onReadable(this);
  }
}
