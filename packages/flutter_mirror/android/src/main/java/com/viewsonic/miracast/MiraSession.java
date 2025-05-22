package com.viewsonic.miracast;

import android.util.Log;

import com.viewsonic.miracast.net.EventBase;
import com.viewsonic.miracast.net.TcpConnection;
import com.viewsonic.miracast.net.TcpConnectionListener;
import com.viewsonic.miracast.rtp.OnReceiveRTPListener;
import com.viewsonic.miracast.rtp.RTPServer;
import com.viewsonic.miracast.rtsp.RtspClient;
import com.viewsonic.miracast.rtsp.RtspHandler;
import com.viewsonic.miracast.rtsp.RtspMessage;
import com.viewsonic.miracast.rtsp.RtspParser;
import com.viewsonic.miracast.rtsp.RtspRequestMessage;
import com.viewsonic.miracast.rtsp.RtspResponseMessage;
import com.viewsonic.miracast.rtsp.RtspSender;
import com.viewsonic.miracast.uibc.UibcClient;
import com.viewsonic.miracast.uibc.UibcSender;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.List;

public class MiraSession
    implements RtspHandler, RtspSender, UibcSender {
  private static final String TAG = "MiraSession";
  private static final int RTSP_BUFFER_CAPACITY = 1024 * 16;
  private static final int UIBC_BUFFER_CAPACITY = 1024 * 2;
  private static final int kRequestIdrMinIntervalMs_ = 1000; // ms

  private String id_;
  private String ip_;
  private int port_;
  private String peerName_;
  private String receiverName_;

  // RTSP
  private RtspClient rtspClient_;
  private TcpConnection rtspConnection_;
  private final ByteBuffer rtspReadBuffer_ = ByteBuffer.allocate(RTSP_BUFFER_CAPACITY);
  private final ByteBuffer rtspWriteBuffer_ = ByteBuffer.allocate(RTSP_BUFFER_CAPACITY);
  private RtspParser rtspParser_;

  // IDR request
  long lastRequestIdrTime_;
  boolean isRequestIdrQueued_ = false;

  private MiraSessionListener mirrorListener_;
  private long lastRTPSeqNum_ = -1;

  private RTPServer rtpServer_;

  // UIBC
  private UibcClient uibcClient_;
  private TcpConnection uibcConnection_;
  private boolean uibcConnected_ = false;
  private final ByteBuffer uibcWriteBuffer_ = ByteBuffer.allocate(UIBC_BUFFER_CAPACITY);
  private byte[] pendingUibiData_;

  private final EventBase eventBase_;

  public MiraSession(
      String id,
      String ip,
      int port,
      String peerName,
      String receiverName,
      EventBase eventBase,
      MiraSessionListener listener) {
    id_ = id;
    ip_ = ip;
    port_ = port;
    peerName_ = peerName;
    receiverName_ = receiverName;
    rtspClient_ = new RtspClient("rtsp://" + ip_ + "/", port_);
    mirrorListener_ = listener;
    eventBase_ = eventBase;

    rtspClient_.setRtspHandler(this);
    rtspClient_.setRtspSender(this);
    rtspClient_.setReceiverName(receiverName_);
    rtspClient_.setAudioFormatListener(new RtspClient.AudioFormatListener() {
      @Override
      public void onAudioFormatUpdate(String name, int sampleRate, int channelCount) {
        if (mirrorListener_ != null) {
          mirrorListener_.onAudioFormatUpdate(id_, name, sampleRate, channelCount);
        }
      }
    });
    Log.d(TAG, "#" + id_ + " rtsp client->" + "rtsp://" + ip_ + ":" + port_);
  }

  public String getIp() {
    return ip_;
  }

  public String getId() {
    return id_;
  }

  public void requestIdr() {
    if (rtspClient_ == null) {
      return;
    }

    long now = System.currentTimeMillis();

    if (now - lastRequestIdrTime_ >= kRequestIdrMinIntervalMs_) {
      lastRequestIdrTime_ = now;

      rtspClient_.requestIdr();
      return;
    }

    // Request IDR too frequently, delay it
    if (!isRequestIdrQueued_) {
      long delayMs = kRequestIdrMinIntervalMs_ - (now - lastRequestIdrTime_);

      isRequestIdrQueued_ = true;

      eventBase_.setTimer(() -> {
        isRequestIdrQueued_ = false;
        lastRequestIdrTime_ = System.currentTimeMillis();

        rtspClient_.requestIdr();
      }, delayMs);
    }
  }

  public void stop() {
    if (rtspClient_ != null) {
      rtspClient_.requestTeardown();
      rtspClient_ = null;
    }

    if (rtspConnection_ != null) {
      try {
        rtspConnection_.close();
      } catch (IOException e) {
        e.printStackTrace();
      }
    }

    if (rtpServer_ != null) {
      Log.d(TAG, "stop RTP&RTCP socket.");
      rtpServer_.stop();
      rtpServer_ = null;
    }

    stopUibc();
  }

  public void onTouchEvent(int touchId, boolean touchDown, double x, double y) {
    if (uibcClient_ != null) {
      uibcClient_.onTouchEvent(touchId, touchDown, x, y);
    }
  }

  public void startRtsp() {
    try {
      rtspConnection_ = new TcpConnection(eventBase_, buildRtspConnectionListener());
      rtspConnection_.setNoDelay();
      rtspConnection_.connect(ip_, port_);
    } catch (IOException e) {
      // TODO
      e.printStackTrace();
    }
  }

  private OnReceiveRTPListener initialOnReceiveRTPListener() {
    return new OnReceiveRTPListener() {
      @Override
      public void onRtpData(long seqNum, byte[] data, int size) {
        if (mirrorListener_ != null) {
          mirrorListener_.onMirrorData(id_, seqNum, lastRTPSeqNum_, data, size);
          lastRTPSeqNum_ = seqNum;
        }
      }
    };
  }

  @Override
  public int startRTPReceiver() {
    try {
      rtpServer_ = new RTPServer(eventBase_, initialOnReceiveRTPListener());
      rtpServer_.start();
      int port = rtpServer_.getRtpPort();
      Log.d(TAG, "Start to connect the RTP Server. RTP Port is: " + port);
      return port;
    } catch (Exception e) {
      // TODO
      return 0;
    }
  }

  @Override
  public void startUibc(String host, int port) {
    try {
      uibcClient_ = new UibcClient(this);

      uibcConnection_ = new TcpConnection(eventBase_, buildUibcConnectionListener());
      uibcConnection_.setNoDelay();
      uibcConnection_.connect(host, port);
    } catch (IOException e) {
      // TODO
      e.printStackTrace();
    }
  }

  @Override
  public void stopUibc() {
    try {
      if (uibcConnection_ != null) {
        uibcConnection_.close();
        uibcConnection_ = null;
      }
      uibcClient_ = null;
    } catch (IOException e) {
      // TODO
      e.printStackTrace();
    }
  }

  private TcpConnectionListener buildRtspConnectionListener() {
    return new TcpConnectionListener() {
      @Override
      public void onConnected(TcpConnection connection) {
        onRtspConnected();
      }

      @Override
      public void onDisconnected(TcpConnection connection) {

      }

      @Override
      public void onConnectTimeout(TcpConnection connection) {
        mirrorListener_.onMiracastSessionError(id_, "RTSP connection failed to establish");
      }

      @Override
      public void onReadable(TcpConnection connection) {
        onRtspReadable();
      }

      @Override
      public void onWritable(TcpConnection connection) {
        // TODO
      }

      @Override
      public void onError(TcpConnection connection) {

      }

      @Override
      public void onReconnect(TcpConnection connection, int attempts) {

      }
    };
  }

  private void onRtspConnected() {
    Log.i(TAG, "RTSP connected");
    rtspParser_ = new RtspParser();

    if (mirrorListener_ != null) {
      mirrorListener_.onRtspConnected(id_, peerName_);
    }
  }

  private void onRtspReadable() {
    assert rtspParser_ != null;

    try {
      // read some data from rtsp connection
      rtspConnection_.read(rtspReadBuffer_);
      rtspReadBuffer_.flip(); // switch to read mode

      // parse rtsp messages
      List<RtspMessage> messages = rtspParser_.parse(rtspReadBuffer_);

      assert !rtspReadBuffer_.hasRemaining();

      rtspReadBuffer_.clear(); // switch to write mode

      // handle rtsp messages
      for (RtspMessage message : messages) {
        onRtspMessage(message);
      }
    } catch (Exception e) {
      // TODO
      e.printStackTrace();
    }
  }

  // handle rtsp message
  private void onRtspMessage(RtspMessage message) {
    Log.d(TAG, ">>>>>>>>>> RTSP Receive Message:\r\n" +
        message.toStringMsg(true) +
        "<<<<<<<<<<");

    if (message instanceof RtspRequestMessage) {
      // handle rtsp request
      rtspClient_.onRtspRequest((RtspRequestMessage) message);
    } else {
      // handle rtsp response
      rtspClient_.onRtspResponse((RtspResponseMessage) message);
    }
  }

  // send rtsp response
  @Override
  public void sendResponse(RtspResponseMessage response) {
    Log.d(TAG, ">>>>>>>>>> RTSP Send Message:\r\n" +
        response.toStringMsg(false) +
        "<<<<<<<<<<");

    sendRtspMessage(response);
  }

  // send rtsp request
  @Override
  public void sendRequest(RtspRequestMessage request) {
    Log.d(TAG, ">>>>>>>>>> RTSP Send Message:\r\n" +
        request.toStringMsg(false) +
        "<<<<<<<<<<");

    sendRtspMessage(request);
  }

  private void sendRtspMessage(RtspMessage message) {
    try {
      byte[] data = message.toByteArray(false);

      rtspWriteBuffer_.put(data);

      rtspWriteBuffer_.flip(); // switch to read mode

      rtspConnection_.write(rtspWriteBuffer_);

      rtspWriteBuffer_.compact(); // In case of partial write
    } catch (Exception e) {
      // TODO
      e.printStackTrace();
    }
  }

  private TcpConnectionListener buildUibcConnectionListener() {
    return new TcpConnectionListener() {
      @Override
      public void onConnected(TcpConnection connection) {
        onUibcConnected();
      }

      @Override
      public void onDisconnected(TcpConnection connection) {

      }

      @Override
      public void onConnectTimeout(TcpConnection connection) {

      }

      @Override
      public void onReadable(TcpConnection connection) {
      }

      @Override
      public void onWritable(TcpConnection connection) {
        onUibcWritable();
      }

      @Override
      public void onError(TcpConnection connection) {

      }

      @Override
      public void onReconnect(TcpConnection connection, int attempts) {

      }
    };
  }

  private void onUibcConnected() {
    Log.i(TAG, "UIBC connected");
    uibcConnected_ = true;

    uibcClient_.start();
  }

  @Override
  public void sendUibcData(byte[] data) {
    assert uibcConnection_ != null;
    assert pendingUibiData_ == null;

    if (!uibcConnected_) {
      // TODO
      return;
    }

    boolean sent = doSendUibcData(data);

    if (!sent) {
      Log.d(TAG, "Pause uibc");
      uibcClient_.pause();
      // send it later
      pendingUibiData_ = data.clone();
      // enable writable event
      uibcConnection_.enableWritableEvent(true);
    }
  }

  private void onUibcWritable() {
    assert pendingUibiData_ != null;

    if (doSendUibcData(pendingUibiData_)) {
      pendingUibiData_ = null;
      // disable writable event
      uibcConnection_.enableWritableEvent(false);

      Log.d(TAG, "Resume uibc");
      uibcClient_.resume();
    }
  }

  private boolean doSendUibcData(byte[] data) {
    try {
      if (uibcWriteBuffer_.remaining() < data.length) {
        // buffer is full
        return false;
      }
      uibcWriteBuffer_.put(data);

      uibcWriteBuffer_.flip(); // switch to read mode

      uibcConnection_.write(uibcWriteBuffer_);
      uibcWriteBuffer_.compact(); // In case of partial write

      return true;
    } catch (Exception e) {
      // TODO
      e.printStackTrace();
      return false;
    }
  }
}
