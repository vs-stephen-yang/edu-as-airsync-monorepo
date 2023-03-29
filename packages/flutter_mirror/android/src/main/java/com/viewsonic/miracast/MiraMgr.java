package com.viewsonic.miracast;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
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

  int mirrorId_ = 0;
  private Map<Integer, MiraSession> mirror_sessions_ = new HashMap<>();

  public MiraSession createSession(String peerName, String peerIp, int peerPort, String receiverName) {
    mirrorId_++;
    MiraSession session = new MiraSession(
        mirrorId_,
        peerIp,
        peerPort,
        peerName,
        receiverName,
        onMiraCastListener_);
    mirror_sessions_.put(mirrorId_, session);
    return session;
  }

  public int removeSessionByIp(String ip) {
    for (Map.Entry<Integer, MiraSession> entry : mirror_sessions_.entrySet()) {
      if (entry.getValue().getIp().equals(ip)) {
        int sessionId = entry.getKey();
        mirror_sessions_.remove(entry.getKey());
        return sessionId;
      }
    }
    return -1;
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
    // RTSP close
    for (Map.Entry<Integer, MiraSession> entry : mirror_sessions_.entrySet()) {
      entry.getValue().stop();
      mirror_sessions_.remove(entry.getKey());
    }

    // Close p2p discovery
    wifiDirectMgr_.stop();
    miraHandler_.removeCallbacks(wifiDirectRunnable_);
  }

  public void rtspRequestIdr(int mirrorId) {
    MiraSession session = mirror_sessions_.get(mirrorId);
    if (session != null) {
      session.requestIdr();
    }
  }

  public void stopMirror(int mirrorId) {
    MiraSession session = mirror_sessions_.get(mirrorId);
    if (session != null) {
      session.stop();
    }
  }

  public void onTouchEvent(int mirrorId_, int touchId, boolean touch, double x, double y) {
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

    AlertDialog.Builder builder = new AlertDialog.Builder(activity_);
    builder.setMessage("Do you agree " + peerName + " to share screen?");
    builder.setPositiveButton("Allow", new DialogInterface.OnClickListener() {
      @Override
      public void onClick(DialogInterface dialog, int which) {
        Log.d(TAG, "Allow");
        dialog.dismiss();
        MiraSession session = createSession(peerName, peerIp, peerPort, receiverName_);
        session.startRtsp();
        if (listener_ != null) {
          listener_.onSessionBegin(session.getId());
        }
      }
    });

    builder.setNegativeButton("Deny", new DialogInterface.OnClickListener() {
      @Override
      public void onClick(DialogInterface dialog, int which) {
        Log.d(TAG, "Deny");
        dialog.dismiss();
        // disconnect the connected p2p peer
        MiraSession session = createSession(peerName, peerIp, peerPort, receiverName_);
        session.stopAfterStartRtsp();
      }
    });

    AlertDialog alert = builder.create();
    alert.show();

    // Set a 10-seconds timeout to dismiss the dialog
    miraHandler_.postDelayed(new Runnable() {
      @Override
      public void run() {
        if (alert.isShowing()) {
          alert.dismiss();
          MiraSession session = createSession(peerName, peerIp, peerPort, receiverName_);
          session.stopAfterStartRtsp();
        }
      }
    }, 10000); // 10 seconds
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
        int removeSessionId = removeSessionByIp(ip);
        if (removeSessionId >= 0) {
          if (listener_ != null) {
            listener_.onSessionEnd(removeSessionId);
          }
        }
      }

      @Override
      public void onMirrorData(int sessionId, long seqNum, long lastSeqNum, byte[] data, int size) {
        if (listener_ != null) {
          try {
            listener_.onMirrorData(sessionId, seqNum, lastSeqNum, data, size);
          } catch (Exception e) {
            Log.e(TAG, "Failed to onMirrorData() ", e);
          }
        }
      }

      @Override
      public void onAudioFormatUpdate(int sessionId, String codecName, int sampleRate, int channelCount) {
        if (listener_ != null) {
          try {
            listener_.onAudioFormatUpdate(sessionId, codecName, sampleRate, channelCount);
          } catch (Exception e) {
            Log.e(TAG, "Failed to onAudioFormatUpdate() ", e);
          }
        }
      }
    };
  }
}
