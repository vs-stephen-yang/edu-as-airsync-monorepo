package com.viewsonic.miracast;

import android.app.Activity;
import android.content.Context;
import android.os.Handler;
import android.os.HandlerThread;
import android.util.Log;

import com.viewsonic.miracast.net.EventBase;
import com.viewsonic.miracast.wifidirect.WiFiDirectMgr;
import com.viewsonic.miracast.wifidirect.WiFiDirectListener;

import java.io.IOException;

public class MiraMgrProxy
    implements WiFiDirectListener {

  private static final String TAG = "MiraMgrProxy";

  private final EventBase eventBase_ = new EventBase();

  private final MiraMgr miraMgr_;

  private final WiFiDirectMgr wifiDirectMgr_;

  private final Handler miraHandler_;
  private Runnable wifiDirectRunnable_;

  private Context context_;
  private Activity activity_;
  private String receiverName_;

  private static MiraMgrProxy instance_;

  public static MiraMgrProxy getInstance() {
    if (instance_ == null) {
      instance_ = new MiraMgrProxy();
    }
    return instance_;
  }

  MiraMgrProxy() {
    wifiDirectMgr_ = new WiFiDirectMgr(this);

    try {
      eventBase_.init();
      eventBase_.start();
    } catch (IOException e) {
      e.printStackTrace();
    }

    miraMgr_ = new MiraMgr(eventBase_);

    initWiFiDirectRunnable();

    HandlerThread mMiraHandlerThread = new HandlerThread("miraMgrThread");
    mMiraHandlerThread.start();
    miraHandler_ = new Handler(mMiraHandlerThread.getLooper());
  }

  public void start(Context context, Activity activity, MiraMgrListener listener, String receiverName) {
    eventBase_.post(() -> {
      context_ = context;
      activity_ = activity;

      receiverName_ = receiverName;

      miraMgr_.start(listener, receiverName);
      miraHandler_.post(wifiDirectRunnable_);
    });
  }

  public void stop() {
    eventBase_.post(() -> {
      miraMgr_.stop();

      // Close p2p discovery
      wifiDirectMgr_.stop();
      miraHandler_.removeCallbacks(wifiDirectRunnable_);
    });
  }

  public void rtspRequestIdr(String mirrorId) {
    eventBase_.post(
        () -> miraMgr_.rtspRequestIdr(mirrorId));
  }

  public void stopMirror(String mirrorId) {
    eventBase_.post(
        () -> miraMgr_.stopMirror(mirrorId));
  }

  public void onTouchEvent(String mirrorId_, int touchId, boolean touch, double x, double y) {
    eventBase_.post(
        () -> miraMgr_.onTouchEvent(mirrorId_, touchId, touch, x, y));
  }

  private void initWiFiDirectRunnable() {
    wifiDirectRunnable_ = () -> wifiDirectMgr_.start(context_, receiverName_);
  }

  @Override
  public void onPeerConnected(String name, String ip, int port) {
    eventBase_.post(
        () -> miraMgr_.onPeerConnected(name, ip, port));
  }

  @Override
  public void onPeerDisconnected(String ip) {
    eventBase_.post(
        () -> miraMgr_.onPeerDisconnected(ip));
  }

  @Override
  public void onWifiDirectError(String errorMessage) {
    eventBase_.post(
        () -> miraMgr_.onWifiDirectError(errorMessage));
  }
}
