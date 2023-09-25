package com.viewsonic.miracast.rtp;

import android.util.Log;

import com.viewsonic.miracast.net.EventBase;
import com.viewsonic.miracast.net.UdpSocket;

import java.io.IOException;
import java.nio.ByteBuffer;

public class RTPServer {
  private static final String TAG = "MiraRTPServer";
  private static final int kRTPBufferSize = 1024 * 1024;
  private static final int MTU = 10 * 1024;

  private UdpSocket rtpSession_;
  private UdpSocket rtcpSession_;

  private final ByteBuffer rtpReadBuffer_ = ByteBuffer.allocate(MTU);
  private final OnReceiveRTPListener receiveRTPListener_;

  private final EventBase eventBase_;

  public RTPServer(
      EventBase eventBase,
      OnReceiveRTPListener listener) {
    receiveRTPListener_ = listener;
    eventBase_ = eventBase;
  }

  public void start() throws IOException {
    // RTP
    rtpSession_ = new UdpSocket(eventBase_, socket -> onRtpPacket());
    rtpSession_.setReceiveBufferSize(kRTPBufferSize);
    rtpSession_.enableRead();
    rtpSession_.bind(0);
    Log.i(TAG, "RTP session is running on port " + rtpSession_.getLocalPort());

    // RTCP
    rtcpSession_ = new UdpSocket(eventBase_, socket -> onRtcpPacket());
    rtcpSession_.setReceiveBufferSize(kRTPBufferSize);
    rtcpSession_.enableRead();
    rtcpSession_.bind(0);
    Log.i(TAG, "RTCP session is running on port " + rtcpSession_.getLocalPort());
  }

  private void onRtcpPacket() {
  }

  private void onRtpPacket() {
    try {
      rtpSession_.receive(rtpReadBuffer_);
      rtpReadBuffer_.flip();
      byte[] data = rtpReadBuffer_.array();

      receiveRTPListener_.onRtpData(getMirrorSeqNum(data), data, rtpReadBuffer_.remaining());
      rtpReadBuffer_.clear();
    } catch (IOException e) {
      // TODO
      e.printStackTrace();
    }
  }

  private static long getMirrorSeqNum(byte[] data) {
    return ((data[2] & 0xFF) << 8) | (data[3] & 0xFF);
  }

  public void stop() {
    try {
      rtpSession_.close();
      rtcpSession_.close();
    } catch (IOException e) {
      e.printStackTrace();
    }
  }

  public int getRtpPort() {
    if (null != rtpSession_) {
      return rtpSession_.getLocalPort();
    }

    return 0;
  }
}
