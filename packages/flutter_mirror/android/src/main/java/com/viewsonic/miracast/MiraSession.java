package com.viewsonic.miracast;

import android.util.Log;
import android.view.Surface;

import com.viewsonic.miracast.net.EventBase;
import com.viewsonic.miracast.net.TcpConnection;
import com.viewsonic.miracast.net.TcpConnectionListener;
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

  private String peerMacAddress_;
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
      String peerMacAddress,
      String peerName,
      String receiverName,
      EventBase eventBase,
      MiraSessionListener listener) {
    id_ = id;
    ip_ = ip;
    port_ = port;
    peerName_ = peerName;
    peerMacAddress_ = peerMacAddress;
    receiverName_ = receiverName;
    rtspClient_ = new RtspClient(eventBase, "rtsp://" + ip_ + "/", port_);
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
    rtspClient_.setSourceCapabilityListener(new RtspClient.SourceCapabilityListener() {
      @Override
      public void onUibcCapability(boolean isUibcSupported) {
        if (mirrorListener_ != null) {
          mirrorListener_.onSourceCapabilities(id_, isUibcSupported);
        }
      }
    });
    Log.d(TAG, "#" + id_ + " rtsp client->" + "rtsp://" + ip_ + ":" + port_);

    rtspClient_.setVideoResolutionListener(new RtspClient.VideoResolutionListener() {
      @Override
      public void onVideoResolution(int width, int height) {
        if (mirrorListener_ != null) {
          mirrorListener_.onVideoResolution(id_, width, height);
        }
      }
    });

    rtspClient_.setPacketLostListener(new RtspClient.PacketLostListener() {
      @Override
      public void onPacketLost() {
        requestIdr();
      }
    });
  }

  public String getPeerAddress() {
    return peerMacAddress_;
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
    Log.i(TAG, "Stopping Miracast session");

    if (rtspClient_ != null) {
      rtspClient_.stopPlayer();
      rtspClient_.requestTeardown();
      rtspClient_ = null;
    }

    if (rtspConnection_ != null) {
      try {
        rtspConnection_.close();
      } catch (IOException e) {
        e.printStackTrace();
      }
      rtspConnection_ = null;
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

  public void pausePlayer() {
    if (rtspClient_ == null) {
      return;
    }

    rtspClient_.pausePlayer();
  }

  public void restartPlayer(Surface surface) {
    if (rtspClient_ == null) {
      return;
    }
    rtspClient_.restartPlayer(surface);

    lastRequestIdrTime_ = System.currentTimeMillis();
    rtspClient_.requestIdr();
  }

  public void mutePlayer(boolean mute) {
    if (rtspClient_ == null) {
      return;
    }

    rtspClient_.mutePlayer(mute);
  }

  private TcpConnectionListener buildRtspConnectionListener() {
    return new TcpConnectionListener() {
      @Override
      public void onConnected(TcpConnection connection) {
        onRtspConnected();
      }

      @Override
      public void onDisconnected(TcpConnection connection) {
        Log.w(TAG, "RTSP TCP connection disconnected");
        mirrorListener_.onMiracastSessionError(id_, "RTSP connection disconnected");
      }

      @Override
      public void onConnectTimeout(TcpConnection connection) {
        Log.e(TAG, "RTSP connection timeout");
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
        Log.e(TAG, "RTSP TCP connection error");
        mirrorListener_.onMiracastSessionError(id_, "RTSP connection error");
      }

      @Override
      public void onReconnect(TcpConnection connection, int attempts) {
        Log.d(TAG, "RTSP attempting to reconnect (attempt " + attempts + ")");
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
    } catch (IOException e) {
      Log.e(TAG, "RTSP read error", e);
    } catch (Exception e) {
      Log.e(TAG, "RTSP parse error", e);
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
    if (!rtspConnection_.isConnected()) {
      Log.w(TAG, "Cannot send RTSP message because connection is not established: " + message);
      return;
    }

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

  public void setSurface(Surface surface) {
    if (rtspClient_ != null) {
      rtspClient_.setSurface(surface);
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
