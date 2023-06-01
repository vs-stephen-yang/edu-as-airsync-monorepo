package com.viewsonic.miracast;

import android.app.Activity;
import android.content.Context;
import android.os.Handler;
import android.os.HandlerThread;
import android.util.Log;

import com.viewsonic.miracast.wifidirect.WiFiDirectMgr;

import java.util.HashMap;
import java.util.Map;

public class MiraMgr {
  private WiFiDirectMgr wifiDirectMgr_;
  private OnMirrorListener onMiraCastListener_;
  private MiraMgrListener listener_;
  private Handler miraHandler_;
  private int mirror_increment_seq_ = 0;
  private static final String kMirrorIdPrefix_ = "miracast-";
  private Map<String, MiraSession> mirror_sessions_ = new HashMap<>();

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
        onMiraCastListener_);
    mirror_sessions_.put(formatMirrorId(mirror_increment_seq_), session);
    return session;
  }

  public String removeSessionByIp(String ip) {
    for (Map.Entry<String, MiraSession> entry : mirror_sessions_.entrySet()) {
      if (entry.getValue().getIp().equals(ip)) {
        String sessionId = entry.getKey();
        mirror_sessions_.remove(sessionId);
        return sessionId;
      }
    }
    return null;
  }

  private Runnable wifiDirectRunnable_;

  private Context context_;
  private Activity activity_;
  private String receiverName_;

  private static final String TAG = "MiraMgr";

  private static MiraMgr instance_ = null;

  public static MiraMgr getInstance() {
    if (instance_ == null) {
      instance_ = new MiraMgr();
    }
    return instance_;
  }

  private MiraMgr() {
    initMiraListener();

    if (wifiDirectMgr_ == null) {
      wifiDirectMgr_ = new WiFiDirectMgr(onMiraCastListener_);
    }

    initWiFiDirectRunnable();

    HandlerThread mMiraHandlerThread = new HandlerThread("miraMgrThread");
    mMiraHandlerThread.start();
    miraHandler_ = new Handler(mMiraHandlerThread.getLooper());
  }

  public void start(Context context, Activity activity, MiraMgrListener listener, String receiverName) {
    context_ = context;
    activity_ = activity;
    receiverName_ = receiverName;
    if (miraHandler_ != null) {
      miraHandler_.post(wifiDirectRunnable_);
    }

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

    // Close p2p discovery
    wifiDirectMgr_.stop();
    miraHandler_.removeCallbacks(wifiDirectRunnable_);
  }

  public void rtspRequestIdr(String mirrorId) {
    MiraSession session = mirror_sessions_.get(mirrorId);
    if (session != null) {
      session.requestIdr();
    }
  }

  public void stopMirror(String mirrorId) {
    MiraSession session = mirror_sessions_.get(mirrorId);
    if (session != null) {
      session.stop();
      mirror_sessions_.remove(mirrorId);
      if (listener_ != null) {
        listener_.onSessionEnd(mirrorId);
      }
    }
  }

  public void onTouchEvent(String mirrorId_, int touchId, boolean touch, double x, double y) {
    MiraSession session = mirror_sessions_.get(mirrorId_);
    if (session != null) {
      session.onTouchEvent(touchId, touch, x, y);
    }
  }

  private void initWiFiDirectRunnable() {
    wifiDirectRunnable_ = new Runnable() {
      @Override
      public void run() {
        if (wifiDirectMgr_ == null) {
          Log.e(TAG, "WiFiDirectMgr is null.");
          return;
        }
        wifiDirectMgr_.start(context_, receiverName_);
      }
    };
  }

  private void connectionPrompt(String peerName, String peerIp, int peerPort) {
    MiraSession session = createSession(peerName, peerIp, peerPort, receiverName_);
    session.startRtsp();
    if (listener_ != null) {
      listener_.onSessionBegin(session.getId());
    }
  }

  private void initMiraListener() {
    onMiraCastListener_ = new OnMirrorListener() {
      @Override
      public void onPeerConnected(String name, String ip, int port) {
        Log.d(TAG, "onPeerConnected.");
        connectionPrompt(name, ip, port);
      }

      @Override
      public void onPeerDisconnected(String ip) {
        Log.d(TAG, "onPeerDisconnected:" + ip);
        String removeSessionId = removeSessionByIp(ip);
        if(removeSessionId != null) {
          if (listener_ != null) {
            listener_.onSessionEnd(removeSessionId);
          }
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
    };
  }
}
