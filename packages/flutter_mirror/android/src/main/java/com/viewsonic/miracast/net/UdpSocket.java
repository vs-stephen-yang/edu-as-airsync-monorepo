package com.viewsonic.miracast.net;

import static java.nio.channels.SelectionKey.OP_READ;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.SocketException;
import java.nio.ByteBuffer;
import java.nio.channels.ClosedChannelException;
import java.nio.channels.DatagramChannel;
import java.nio.channels.SelectionKey;

public class UdpSocket
    implements ChannelListener {

  EventBase eventBase_;
  UdpSocketListener listener_;

  DatagramChannel channel_;
  InetSocketAddress remoteAddress_;

  public UdpSocket(
      EventBase eventBase,
      UdpSocketListener listener)
      throws IOException {
    eventBase_ = eventBase;
    listener_ = listener;

    channel_ = DatagramChannel.open();
    channel_.configureBlocking(false);
  }

  public void setReceiveBufferSize(int size) throws SocketException {
    channel_.socket().setReceiveBufferSize(size);
  }

  public void enableRead() throws ClosedChannelException {
    eventBase_.registerChannel(channel_, OP_READ, this);
  }

  public void close() throws IOException {
    channel_.close();
  }

  public void bind(int port) throws SocketException {
    channel_.socket().bind(new InetSocketAddress(port));
  }

  public int getLocalPort() {
    return channel_.socket().getLocalPort();
  }

  public void setRemoteAddress(String host, int port) {
    remoteAddress_ = new InetSocketAddress(host, port);
  }

  public void send(ByteBuffer data) throws IOException {
    assert remoteAddress_ != null;

    channel_.send(data, remoteAddress_);
  }

  public void receive(ByteBuffer data) throws IOException {
    channel_.receive(data);
  }

  public void onOpsReady(SelectionKey key) {
    if (key.isReadable()) {
      listener_.onReadable(this);
    }
  }
}
