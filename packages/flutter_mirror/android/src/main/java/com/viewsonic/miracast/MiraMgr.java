package com.viewsonic.miracast;

import android.util.Log;

import com.viewsonic.miracast.net.EventBase;
import com.viewsonic.miracast.wifidirect.WiFiDirectListener;

import java.util.HashMap;
import java.util.Map;

public class MiraMgr
    implements WiFiDirectListener, MiraSessionListener {
  private MiraMgrListener listener_;
  private int mirror_increment_seq_ = 0;
  private static final String kMirrorIdPrefix_ = "miracast-";
  private final Map<String, MiraSession> mirror_sessions_ = new HashMap<>();

  private final EventBase eventBase_;

  static String formatMirrorId(int seq) {
    return kMirrorIdPrefix_ + seq;
  }

  public MiraSession createSession(String peerName, String peerIp, int peerPort, String receiverName) {
    mirror_increment_seq_++;
    MiraSession session = new MiraSession(
        formatMirrorId(mirror_increment_seq_),
        peerIp,
        peerPort,
        peerName,
        receiverName,
        eventBase_,
        this);
    mirror_sessions_.put(formatMirrorId(mirror_increment_seq_), session);
    return session;
  }

  public String removeSessionByIp(String ip) {
    for (Map.Entry<String, MiraSession> entry : mirror_sessions_.entrySet()) {
      if (entry.getValue().getIp().equals(ip)) {
        String sessionId = entry.getKey();
        mirror_sessions_.remove(sessionId);

        Log.d(TAG, String.format("Remaining mira sessions = %d", mirror_sessions_.size()));
        return sessionId;
      }
    }
    return null;
  }

  private String receiverName_;

  private static final String TAG = "MiraMgr";

  MiraMgr(EventBase eventBase) {
    assert eventBase != null;

    eventBase_ = eventBase;
  }

  public void start(MiraMgrListener listener, String receiverName) {
    receiverName_ = receiverName;

    if (listener != null) {
      listener_ = listener;
    }
  }

  public void stop() {
    for (Map.Entry<String, MiraSession> entry : mirror_sessions_.entrySet()) {
      entry.getValue().stop();
      mirror_sessions_.remove(entry.getKey());
      if (listener_ != null) {
        listener_.onSessionEnd(entry.getKey());
      }
    }
  }

  public void rtspRequestIdr(String mirrorId) {
    MiraSession session = mirror_sessions_.get(mirrorId);
    if (session != null) {
      session.requestIdr();
    }
  }

  public void stopMirror(String mirrorId) {
    Log.d(TAG, String.format("MiraMgr.stopMirror(%s)", mirrorId));

    MiraSession session = mirror_sessions_.get(mirrorId);
    if (session != null) {
      session.stop();
    }
  }

  public void onTouchEvent(String mirrorId_, int touchId, boolean touch, double x, double y) {
    MiraSession session = mirror_sessions_.get(mirrorId_);
    if (session != null) {
      session.onTouchEvent(touchId, touch, x, y);
    }
  }

  private void connectionPrompt(String peerName, String peerIp, int peerPort) {
    MiraSession session = createSession(peerName, peerIp, peerPort, receiverName_);
    session.startRtsp();
  }

  @Override
  public void onPeerConnected(String name, String ip, int port) {
    Log.d(TAG, "onPeerConnected.");
    connectionPrompt(name, ip, port);

  }

  @Override
  public void onPeerDisconnected(String ip) {
    Log.d(TAG, "onPeerDisconnected:" + ip);
    String removeSessionId = removeSessionByIp(ip);
    if (removeSessionId != null) {
      if (listener_ != null) {
        listener_.onSessionEnd(removeSessionId);
      }
    }
  }

  @Override
  public void onRtspConnected(String mirrorId, String deviceName) {
    if (listener_ != null) {
      listener_.onSessionBegin(mirrorId, deviceName);
    }
  }

  @Override
  public void onMirrorData(String mirrorId, long seqNum, long lastSeqNum, byte[] data, int size) {
    if (listener_ != null) {
      try {
        listener_.onMirrorData(mirrorId, seqNum, lastSeqNum, data, size);
      } catch (Exception e) {
        Log.e(TAG, "Failed to onMirrorData() ", e);
      }
    }
  }

  @Override
  public void onAudioFormatUpdate(String mirrorId, String codecName, int sampleRate, int channelCount) {
    if (listener_ != null) {
      try {
        listener_.onAudioFormatUpdate(mirrorId, codecName, sampleRate, channelCount);
      } catch (Exception e) {
        Log.e(TAG, "Failed to onAudioFormatUpdate() ", e);
      }
    }
  }
}
