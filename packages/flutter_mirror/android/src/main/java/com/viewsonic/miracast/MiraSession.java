package com.viewsonic.miracast;

import android.util.Log;

import com.viewsonic.miracast.rtp.OnReceiveRTPListener;
import com.viewsonic.miracast.rtsp.RtspClient;

public class MiraSession {
  private static final String TAG = "MiraSession";
  private String id_;
  private String ip_;
  private int port_;
  private String peerName_;
  private String receiverName_;
  private RtspClient rtspClient_;
  private OnMirrorListener mirrorListener_;
  private long lastRTPSeqNum_ = -1;

  public MiraSession(String id, String ip, int port, String peerName, String receiverName, OnMirrorListener listener) {
    id_ = id;
    ip_ = ip;
    port_ = port;
    peerName_ = peerName;
    receiverName_ = receiverName;
    rtspClient_ = new RtspClient("rtsp://" + ip_ + "/", port_);
    mirrorListener_ = listener;
    rtspClient_.setRtpListener(initialOnReceiveRTPListener());
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
    if (rtspClient_ != null) {
      rtspClient_.requestIdr();
    }
  }

  public void stop() {
    if (rtspClient_ != null) {
      rtspClient_.requestTeardown();
      rtspClient_.stop();
      rtspClient_ = null;
    }
  }

  public void onTouchEvent(int touchId, boolean touchDown, double x, double y) {
    if (rtspClient_ != null) {
      rtspClient_.onTouchEvent(touchId, touchDown, x, y);
    }
  }

  public void startRtsp() {
    if (rtspClient_ != null) {
      rtspClient_.start();
    }
  }

  public void stopAfterStartRtsp() {
    if (rtspClient_ != null) {
      rtspClient_.stopAfterStart();
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
}
