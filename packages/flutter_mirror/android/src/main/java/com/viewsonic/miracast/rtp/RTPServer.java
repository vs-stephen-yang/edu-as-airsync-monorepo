package com.viewsonic.miracast.rtp;

import android.util.Log;
import com.viewsonic.miracast.rtsp.OnReceiveRTSPListener;

import java.io.IOException;
import java.net.SocketTimeoutException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.SocketException;
import java.util.concurrent.atomic.AtomicBoolean;

public class RTPServer {
  private static final String TAG = "MiraRTPServer";

  private UDPServer rtpSession_;
  private UDPServer rtcpSession_;
  private OnReceiveRTPListener receiveRTPListener_;

  public RTPServer(OnReceiveRTPListener listener) {
    receiveRTPListener_ = listener;
  }

  public void start() {
    rtpSession_ = new UDPServer(1024 * 1024, 0, receiveRTPListener_);
    rtpSession_.start();
    Log.i(TAG, "RTP session is running on port " + rtpSession_.port_);

    rtcpSession_ = new UDPServer(0, null);
    rtcpSession_.start();
    Log.i(TAG, "RTCP session is running on port " + rtcpSession_.port_);
  }

  public void stop() {
    rtpSession_.stop();
    rtcpSession_.stop();
  }

  public int getRtpPort() {
    if (null != rtpSession_) {
      return rtpSession_.port_;
    }

    return 0;
  }

  public int getRtcpPort() {
    if (null != rtcpSession_) {
      return rtcpSession_.port_;
    }

    return 0;
  }

  public static int lastSeq = -1;

  private static long getMirrorSeqNum(byte[] data) {
    return ((data[2] & 0xFF) << 8) | (data[3] & 0xFF);
  }

  /**
   * Represents the UDP server.
   */
  static class UDPServer {
    private OnReceiveRTPListener receiveRTPListener_;

    class Worker extends Thread {
      public static final int MTU = 10 * 1024;
      private byte receiveBuffer_[] = new byte[MTU];

      public Worker() {
      }

      public void run() {
        DatagramPacket packet = new DatagramPacket(receiveBuffer_, MTU);
        while(isRunning_.get() && !socket_.isClosed()) {
          try {
            socket_.receive(packet);
            if (receiveRTPListener_ != null) {
              receiveRTPListener_.onRtpData(getMirrorSeqNum(packet.getData()), packet.getData(),
                  packet.getLength());
            }
          } catch (SocketTimeoutException e) {
            continue;
          } catch (Exception e) {
            Log.e(TAG, "Exception: " + e.toString());
            if (e.toString().contains("Socket closed")) {
              break;
            }
          }
        }

        try {
          socket_.close();
        } catch (Exception e) {
          Log.e(TAG, "Socket close - Exception: " + e.toString());
        }
      }
    }

    private int port_ = 0;
    private Worker worker_;
    private DatagramSocket socket_ = null;
    private int socketBufferSize_ = 0;
    private AtomicBoolean isRunning_ = new AtomicBoolean(false);

    UDPServer(int bufferSize, int port, OnReceiveRTPListener listener) {
      init(bufferSize, port, listener);
    }

    UDPServer(int port, OnReceiveRTPListener listener) {
      init(0, port, listener);
    }

    private void init(int bufferSize, int port, OnReceiveRTPListener listener) {
      socketBufferSize_ = bufferSize;
      receiveRTPListener_ = listener;
      try {
        socket_ = new DatagramSocket(port);
        if (socketBufferSize_ > 0) {
          socket_.setReceiveBufferSize(socketBufferSize_);
        }
        if (socket_.isBound()) {
          port_ = socket_.getLocalPort();
        }
        socket_.setSoTimeout(100);
        worker_ = new Worker();
      } catch (Exception e) {
        e.printStackTrace();
      }
    }

    public void start() {
      if(socket_ != null && isRunning_.compareAndSet(false, true)) {
        /* Ensure socket is created before starting worker thread. */
        try {
          worker_.start();
        } catch (Exception e) {
          Log.e(TAG, "udp server start Exception " + e.toString());
        }
      }
    }

    public void stop() {
      if(isRunning_.compareAndSet(true, false)) {
        try {
          worker_.join();
        } catch (Exception e) {
          Log.e(TAG, "udp server stop Exception " + e.toString());
        }
      }
    }
  }
}
