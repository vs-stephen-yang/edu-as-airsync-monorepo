package com.viewsonic.miracast.wifidirect;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.Network;
import android.net.NetworkCapabilities;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

/**
 * Monitors the infrastructure Wi-Fi frequency and notifies a listener when
 * the channel changes or Wi-Fi connectivity is restored after a disconnect.
 *
 * Uses ConnectivityManager.NetworkCallback as the primary detection mechanism
 * and a safety-net poll for IFP firmware that may not fire callbacks on
 * channel-only switches.
 */
public class WifiChannelMonitor {

  private static final String TAG = "WifiChannelMonitor";
  private static final long DEBOUNCE_DELAY_MS = 3000L;
  private static final long POLL_INTERVAL_MS = 30_000L;

  public interface Listener {
    void onWifiChannelChanged(int oldFrequencyMHz, int newFrequencyMHz);
    void onWifiRestored(int frequencyMHz);
  }

  private final Handler handler_ = new Handler(Looper.getMainLooper());
  private WifiManager wifiManager_;
  private ConnectivityManager connectivityManager_;
  private Listener listener_;
  private int lastFrequencyMHz_ = 0;
  private boolean isWifiConnected_ = false;
  private boolean started_ = false;
  private ConnectivityManager.NetworkCallback networkCallback_;
  private Runnable pendingNotification_;

  private final Runnable pollRunnable_ = new Runnable() {
    @Override
    public void run() {
      if (!started_) return;
      checkFrequency();
      handler_.postDelayed(this, POLL_INTERVAL_MS);
    }
  };

  public void start(Context context, Listener listener) {
    if (started_) return;
    started_ = true;
    listener_ = listener;

    wifiManager_ = (WifiManager) context.getApplicationContext()
        .getSystemService(Context.WIFI_SERVICE);
    connectivityManager_ = (ConnectivityManager) context.getApplicationContext()
        .getSystemService(Context.CONNECTIVITY_SERVICE);

    // Read initial frequency
    int initialFreq = getCurrentFrequency();
    lastFrequencyMHz_ = initialFreq;
    isWifiConnected_ = initialFreq > 0;
    Log.d(TAG, "Started, initial frequency: " + initialFreq + " MHz, connected: " + isWifiConnected_);

    // Register network callback
    networkCallback_ = new ConnectivityManager.NetworkCallback() {
      @Override
      public void onCapabilitiesChanged(Network network, NetworkCapabilities capabilities) {
        handler_.post(() -> checkFrequency());
      }

      @Override
      public void onAvailable(Network network) {
        handler_.post(() -> {
          Log.d(TAG, "Network available");
          checkFrequency();
        });
      }

      @Override
      public void onLost(Network network) {
        handler_.post(() -> {
          Log.d(TAG, "Network lost, resetting frequency baseline");
          isWifiConnected_ = false;
          lastFrequencyMHz_ = 0;
          cancelPendingNotification();
        });
      }
    };
    connectivityManager_.registerDefaultNetworkCallback(networkCallback_);

    // Start safety-net polling
    handler_.postDelayed(pollRunnable_, POLL_INTERVAL_MS);
  }

  public void stop() {
    if (!started_) return;
    started_ = false;
    Log.d(TAG, "Stopped");

    if (networkCallback_ != null) {
      try {
        connectivityManager_.unregisterNetworkCallback(networkCallback_);
      } catch (IllegalArgumentException e) {
        Log.w(TAG, "NetworkCallback already unregistered", e);
      }
      networkCallback_ = null;
    }

    handler_.removeCallbacks(pollRunnable_);
    cancelPendingNotification();
  }

  private int getCurrentFrequency() {
    if (wifiManager_ == null) return 0;
    WifiInfo wifiInfo = wifiManager_.getConnectionInfo();
    if (wifiInfo == null) return 0;
    return wifiInfo.getFrequency();
  }

  private void checkFrequency() {
    if (!started_) return;

    int currentFreq = getCurrentFrequency();

    if (currentFreq <= 0) {
      // Wi-Fi disconnected or transitional state, ignore
      return;
    }

    boolean wasConnected = isWifiConnected_;
    isWifiConnected_ = true;

    if (!wasConnected) {
      // Wi-Fi was off/disconnected and is now restored
      Log.d(TAG, "Wi-Fi restored, frequency: " + currentFreq + " MHz");
      lastFrequencyMHz_ = currentFreq;
      scheduleNotification(() -> {
        Log.i(TAG, "Notifying Wi-Fi restored at " + currentFreq + " MHz");
        listener_.onWifiRestored(currentFreq);
      });
      return;
    }

    if (lastFrequencyMHz_ == 0) {
      // First valid reading after start, just record it
      lastFrequencyMHz_ = currentFreq;
      return;
    }

    if (currentFreq != lastFrequencyMHz_) {
      int oldFreq = lastFrequencyMHz_;
      lastFrequencyMHz_ = currentFreq;
      Log.d(TAG, "Wi-Fi channel change detected: " + oldFreq + " -> " + currentFreq + " MHz");
      scheduleNotification(() -> {
        Log.i(TAG, "Notifying channel change: " + oldFreq + " -> " + currentFreq + " MHz");
        listener_.onWifiChannelChanged(oldFreq, currentFreq);
      });
    }
  }

  private void scheduleNotification(Runnable notification) {
    cancelPendingNotification();
    pendingNotification_ = notification;
    handler_.postDelayed(pendingNotification_, DEBOUNCE_DELAY_MS);
    Log.d(TAG, "Notification scheduled in " + DEBOUNCE_DELAY_MS + " ms");
  }

  private void cancelPendingNotification() {
    if (pendingNotification_ != null) {
      handler_.removeCallbacks(pendingNotification_);
      pendingNotification_ = null;
    }
  }
}
