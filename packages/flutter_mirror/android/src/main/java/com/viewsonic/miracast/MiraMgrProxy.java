package com.viewsonic.miracast;

import android.app.Activity;
import android.content.Context;
import android.os.Handler;
import android.os.HandlerThread;
import android.util.Log;
import android.view.Surface;

import com.viewsonic.miracast.net.EventBase;
import com.viewsonic.miracast.wifidirect.WifiChannelMonitor;
import com.viewsonic.miracast.wifidirect.WiFiDirectMgr;
import com.viewsonic.miracast.wifidirect.WiFiDirectListener;

import java.io.IOException;

public class MiraMgrProxy
  implements WiFiDirectListener, WifiChannelMonitor.Listener {

  private static final String TAG = "MiraMgrProxy";

  private final EventBase eventBase_ = new EventBase();

  private final MiraMgr miraMgr_;

  private final WiFiDirectMgr wifiDirectMgr_;

  private final Handler miraHandler_;
  private Runnable wifiDirectRunnable_;
  private Runnable restartRunnable_;

  private Context context_;
  private Activity activity_;
  private String receiverName_;
  private MiraMgrListener listener_;
  private SurfaceTextureProvider surfaceProvider_;
  private WifiChannelMonitor wifiChannelMonitor_;
  private boolean isRestarting_ = false;

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

  public void start(
    Context context,
    Activity activity,
    MiraMgrListener listener,
    String receiverName,
    SurfaceTextureProvider surfaceTextureProvider
  ) {
    eventBase_.post(() -> {
      context_ = context;
      activity_ = activity;
      receiverName_ = receiverName;
      listener_ = listener;
      surfaceProvider_ = surfaceTextureProvider;

      miraMgr_.start(listener, receiverName, surfaceTextureProvider);
      miraHandler_.post(wifiDirectRunnable_);

      if (wifiChannelMonitor_ != null) {
        wifiChannelMonitor_.stop();
      }
      wifiChannelMonitor_ = new WifiChannelMonitor();
      wifiChannelMonitor_.start(context_, MiraMgrProxy.this);
    });
  }

  public void stop() {
    eventBase_.post(() -> {
      if (wifiChannelMonitor_ != null) {
        wifiChannelMonitor_.stop();
        wifiChannelMonitor_ = null;
      }

      miraMgr_.stop();

      // Close p2p discovery
      wifiDirectMgr_.stop();
      miraHandler_.removeCallbacks(wifiDirectRunnable_);
      miraHandler_.removeCallbacks(restartRunnable_);
      isRestarting_ = false;
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
  public void onPeerConnected(String peerMacAddress, String name, String ip, int port) {
    eventBase_.post(
      () -> miraMgr_.onPeerConnected(peerMacAddress, name, ip, port));
  }

  @Override
  public void onPeerDisconnected(String peerMacAddress) {
    eventBase_.post(
      () -> miraMgr_.onPeerDisconnected(peerMacAddress));
  }

  @Override
  public void onWifiDirectError(String errorMessage) {
    eventBase_.post(
      () -> miraMgr_.onWifiDirectError(errorMessage));
  }

  public void pausePlayer(String mirrorId) {
    eventBase_.post(
      () -> miraMgr_.pausePlayer(mirrorId));
  }

  public void restartPlayer(String mirrorId, Surface surface) {
    eventBase_.post(
      () -> miraMgr_.restartPlayer(mirrorId, surface));
  }

  public void mutePlayer(String mirrorId, boolean mute) {
    eventBase_.post(
      () -> miraMgr_.mutePlayer(mirrorId, mute));
  }

  @Override
  public void onWifiChannelChanged(int oldFrequencyMHz, int newFrequencyMHz) {
    Log.w(TAG, "Wi-Fi channel changed: " + oldFrequencyMHz + " -> " + newFrequencyMHz + " MHz, restarting Miracast");
    restartMiracast();
  }

  @Override
  public void onWifiRestored(int frequencyMHz) {
    Log.w(TAG, "Wi-Fi restored at " + frequencyMHz + " MHz, restarting Miracast");
    restartMiracast();
  }

  private void restartMiracast() {
    eventBase_.post(() -> {
      if (isRestarting_) {
        Log.d(TAG, "Miracast restart already in progress, skipping");
        return;
      }
      isRestarting_ = true;

      Log.i(TAG, "Miracast restart: stopping...");
      miraMgr_.stop();
      wifiDirectMgr_.stop();
      miraHandler_.removeCallbacks(wifiDirectRunnable_);

      // 1-second stabilization delay before re-start
      restartRunnable_ = () -> {
        eventBase_.post(() -> {
          if (!isRestarting_) {
            Log.d(TAG, "Miracast restart cancelled (stop was called)");
            return;
          }
          Log.i(TAG, "Miracast restart: re-starting...");
          miraMgr_.start(listener_, receiverName_, surfaceProvider_);
          miraHandler_.post(wifiDirectRunnable_);
          isRestarting_ = false;
        });
      };
      miraHandler_.postDelayed(restartRunnable_, 1000);
    });
  }
}
