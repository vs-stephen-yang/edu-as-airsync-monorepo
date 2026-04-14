package com.viewsonic.miracast.net;

import android.util.Log;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.ClosedChannelException;
import java.nio.channels.SelectionKey;
import java.nio.channels.SocketChannel;

public class TcpConnection
    implements ChannelListener {

  private static final String TAG = "TcpConnection";

  EventBase eventBase_;
  SocketChannel socket_;
  SelectionKey key_;
  TcpConnectionListener listener_;

  private String host_;
  private int port_;

  // socket options
  boolean tcpNoDelay_ = false;

  // reconnect
  private int reconnectionDelayMs_ = 500;// ms
  private int reconnectionMaxAttempts_ = 20;

  private Object connectTimer_;
  private int reconnectionAttempts_;

  public TcpConnection(
      EventBase eventBase,
      TcpConnectionListener listener) {
    eventBase_ = eventBase;
    listener_ = listener;
  }

  public void close() throws IOException {
    if (socket_ != null) {
      socket_.close();
      socket_ = null;
    }

    if (key_ != null) {
      key_.cancel();
      key_ = null;
    }

    if (connectTimer_ != null) {
      eventBase_.clearTimer(connectTimer_);
      connectTimer_ = null;
    }
  }

  public void setNoDelay() {
    tcpNoDelay_ = true;
  }

  public boolean isConnected() {
    if (socket_ == null) {
      return false;
    }
    return socket_.isConnected();
  }

  public void connect(String host, int port) throws IOException {
    host_ = host;
    port_ = port;

    Log.i(TAG, "Connecting");
    doConnect();
  }

  private void doConnect() throws IOException {
    close();

    socket_ = SocketChannel.open();

    // configure non-blocking
    socket_.configureBlocking(false);
    socket_.socket().setTcpNoDelay(tcpNoDelay_);

    assert host_ != null;
    assert port_ > 0;

    socket_.connect(new InetSocketAddress(host_, port_));

    key_ = eventBase_.registerChannel(socket_, SelectionKey.OP_CONNECT, this);

    connectTimer_ = eventBase_.setTimer(() -> {
      onConnectTimeout();
    }, reconnectionDelayMs_);
  }

  private void onConnectTimeout() {
    if (reconnectionAttempts_ >= reconnectionMaxAttempts_) {
      Log.w(TAG, "Connect timeout");

      listener_.onConnectTimeout(this);
      return;
    }

    Log.i(TAG, "Trying to reconnect");
    reconnectionAttempts_ += 1;
    listener_.onReconnect(this, reconnectionAttempts_);

    try {
      doConnect();
    } catch (IOException e) {
      e.printStackTrace();
      listener_.onError(this);
    }
  }

  public void setReconnectAttempts(int delayMs, int maxAttempts) {
    reconnectionDelayMs_ = delayMs;
    reconnectionMaxAttempts_ = maxAttempts;
  }

  public int read(ByteBuffer buffer) throws IOException {
    return socket_.read(buffer);
  }

  public void enableWritableEvent(boolean enable) {
    assert key_ != null;

    int oldOps = key_.interestOps();

    int newOps = enable
        ? oldOps | SelectionKey.OP_WRITE
        : oldOps & ~SelectionKey.OP_WRITE;

    key_.interestOps(newOps);
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
      listener_.onError(this);
    }
  }

  private void onConnectable(SelectionKey key) throws IOException {
    SocketChannel channel = (SocketChannel) key.channel();

    if (!channel.isConnectionPending()) {
      return;
    }

    try {
      channel.finishConnect();
    } catch (IOException e) {
      Log.w(TAG, String.format("Failed to connect. %s", e));
      return;
    }

    // cancel connect timer
    eventBase_.clearTimer(connectTimer_);
    connectTimer_ = null;

    eventBase_.registerChannel(channel, SelectionKey.OP_READ, this);

    listener_.onConnected(this);
  }

  private void onReadable(SelectionKey key) {
    listener_.onReadable(this);
  }
}
