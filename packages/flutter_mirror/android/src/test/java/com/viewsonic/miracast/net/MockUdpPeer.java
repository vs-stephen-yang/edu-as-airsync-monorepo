package com.viewsonic.miracast.net;

import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.net.SocketException;
import java.net.UnknownHostException;

public class MockUdpPeer {
  DatagramSocket socket_;
  InetAddress remoteAddress_;
  int remotePort_;
  DatagramPacket receivePacket_;

  public void init() throws SocketException {
    socket_ = new DatagramSocket(0);

    byte[] receiveData = new byte[1024];
    receivePacket_ = new DatagramPacket(receiveData, receiveData.length);
  }

  public void setRemoteAddress(String host, int port) throws UnknownHostException {
    remoteAddress_ = InetAddress.getByName(host);
    remotePort_ = port;
  }

  public int getLocalPort() {
    return socket_.getLocalPort();
  }

  public void send(byte[] data) throws IOException {
    DatagramPacket pkt = new DatagramPacket(data, data.length, remoteAddress_, remotePort_);
    socket_.send(pkt);
  }

  public byte[] receive() throws IOException {
    socket_.receive(receivePacket_);

    byte[] data = new byte[receivePacket_.getLength()];
    System.arraycopy(receivePacket_.getData(), 0, data, 0, data.length);

    return data;
  }

}
