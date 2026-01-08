package com.viewsonic.flutter_mirror;

import androidx.annotation.Keep;
import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.nsd.NsdManager;
import android.net.nsd.NsdServiceInfo;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

@Keep
public class MirrorReceiver implements
    MirrorListener {

  private static final String TAG = "MirrorReceiver";
  private static final String NSD_LOG_PREFIX = "NSD";
  private static final int CCAST_BLANK_TIMEOUT = 12000;  // 12 second timeout, similar to vCast
  private static final long SERVICE_CHECK_INTERVAL = 6000L;  // 6 second health check, similar to vCast
  private static final long SERVICE_RETRY_BASE_MS = 2000L;
  private static final long SERVICE_RETRY_MAX_MS = 30000L;
  private static final int SERVICE_RETRY_MAX_ATTEMPTS = 5;
  // Short burst of refresh after network becomes ready (boot-time visibility).
  private static final int SERVICE_BOOTSTRAP_REFRESH_COUNT = 3;
  private static final long SERVICE_BOOTSTRAP_REFRESH_INTERVAL_MS = 1500L;

  private long instance_;
  private MirrorListener mirrorListener_;
  private Context context_;

  // dns-sd services
  NsdManager nsdManager_;
  Map<String, NsdManager.RegistrationListener> services_ = new HashMap<>();
  Map<String, ServiceInfo> serviceInfos_ = new HashMap<>();  // Store ServiceInfo for MDNS refresh
  // Defer service register until network is connected.
  private final Map<String, ServiceInfo> pendingServices_ = new ConcurrentHashMap<>();
  // Track retry attempts and scheduled tasks per service.
  private final Map<String, Integer> serviceRetryCounts_ = new ConcurrentHashMap<>();
  private final Map<String, Runnable> serviceRetryRunnables_ = new ConcurrentHashMap<>();

  // Timeout mechanism - automatic disconnect after 12 seconds without video
  private final Handler mTimeoutHandler = new Handler(Looper.getMainLooper());
  private final Map<String, Runnable> mTimeoutRunnables = new ConcurrentHashMap<>();

  // Track active mirror sessions (for MDNS refresh logic)
  private final Set<String> activeMirrorSessions_ = ConcurrentHashMap.newKeySet();

  // Watchdog health check mechanism
  private final Handler serviceHandler_ = new Handler(Looper.getMainLooper());
  private BroadcastReceiver networkStateReceiver_;
  private ConnectivityManager.NetworkCallback networkCallback_;
  // Remaining rounds for the boot-time refresh burst.
  private int bootstrapRefreshRemaining_ = 0;

  public MirrorReceiver(
      MirrorListener mirrorListener,
      TexRegistry textureRegistry,
      Map<String, Integer> additionalCodecParams,
      Context context) {
    assert mirrorListener != null;
    assert textureRegistry != null;

    context_ = context;
    mirrorListener_ = mirrorListener;

    // create C++ MirrorReceiver
    instance_ = createInstanceNative(
        textureRegistry,
        additionalCodecParams);

    assert instance_ != 0;

    assert (instance_ != 0);

    nsdManager_ = (NsdManager) context.getSystemService(Context.NSD_SERVICE);

    // Start Watchdog monitoring mechanism
    startMonitoring();
  }

  /**
   * Start Watchdog monitoring mechanism (similar to vCast's AirPlayService and ChromecastService)
   * 1. Periodic health check (every 6 seconds)
   * 2. Network state change monitoring
   */
  private void startMonitoring() {
    // Start periodic health check
    serviceHandler_.post(this::checkAndRestartService);

    // Register network state change listener
    ConnectivityManager cm =
        (ConnectivityManager) context_.getSystemService(Context.CONNECTIVITY_SERVICE);
    if (cm != null) {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
        if (networkCallback_ == null) {
          networkCallback_ =
              new ConnectivityManager.NetworkCallback() {
                @Override
                public void onAvailable(android.net.Network network) {
                  handleNetworkChange(true);
                }

                @Override
                public void onLost(android.net.Network network) {
                  handleNetworkChange(false);
                }
              };
          // API 28+ deprecates CONNECTIVITY_ACTION; broadcasts can be delayed or missed.
          // NetworkCallback provides more reliable connectivity change signals.
          cm.registerDefaultNetworkCallback(networkCallback_);
        }
      } else {
        if (networkStateReceiver_ == null) {
          networkStateReceiver_ =
              new BroadcastReceiver() {
                @Override
                public void onReceive(Context context, Intent intent) {
                  ConnectivityManager cm =
                      (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
                  NetworkInfo activeNetwork = cm.getActiveNetworkInfo();
                  boolean isConnected =
                      activeNetwork != null && activeNetwork.isConnectedOrConnecting();
                  handleNetworkChange(isConnected);
                }
              };
          IntentFilter filter = new IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION);
          context_.registerReceiver(networkStateReceiver_, filter);
        }
      }
    }
  }

  /**
   * Stop Watchdog monitoring mechanism
   */
  private void stopMonitoring() {
    // Stop periodic health check
    serviceHandler_.removeCallbacksAndMessages(null);

    // Unregister network state listener
    ConnectivityManager cm =
        (ConnectivityManager) context_.getSystemService(Context.CONNECTIVITY_SERVICE);
    if (cm != null && networkCallback_ != null) {
      try {
        cm.unregisterNetworkCallback(networkCallback_);
      } catch (IllegalArgumentException e) {
        Log.w(TAG, "Network callback already unregistered", e);
      }
      networkCallback_ = null;
    }
    if (networkStateReceiver_ != null) {
      try {
        context_.unregisterReceiver(networkStateReceiver_);
      } catch (IllegalArgumentException e) {
        Log.w(TAG, "Network receiver already unregistered", e);
      }
      networkStateReceiver_ = null;
    }
  }

  private void handleNetworkChange(boolean isConnected) {
    Log.i(TAG, "Network state changed, isConnected: " + isConnected);

    // Trigger health check immediately when network changes
    serviceHandler_.removeCallbacksAndMessages(null);
    if (isConnected) {
      scheduleBootstrapRefresh();
      registerPendingServices();
    }
    serviceHandler_.post(MirrorReceiver.this::checkAndRestartService);
  }

  /**
   * Periodic service maintenance (similar to vCast's periodic check mechanism)
   * Refresh MDNS registration and retry pending services.
   */
  private void checkAndRestartService() {
    if (instance_ == 0) {
      Log.w(TAG, "checkAndRestartService: instance is 0, skipping check.");
      serviceHandler_.postDelayed(this::checkAndRestartService, SERVICE_CHECK_INTERVAL);
      return;
    }

    Log.i(TAG, "checkAndRestartService: Performing service health check.");

    // Periodic MDNS service refresh (similar to vCast's periodic re-registration)
    // This ensures service visibility even when services are running normally
    registerPendingServices();
    refreshMdnsServices();

    // Schedule next check
    serviceHandler_.postDelayed(this::checkAndRestartService, SERVICE_CHECK_INTERVAL);
  }

  // Enable video dump
  public void enableDump(String path) {
    assert instance_ != 0;

    enableDumpNative(
        instance_,
        path);

  }

  //
  public void startMirrorReplay(String mirrorId, String videoCodec, String videoPath) {
    startMirrorReplayNative(instance_,
        mirrorId,
        videoCodec,
        videoPath);
  }

  // start airplay
  public void startAirplay(String name, String security, Map<String, Map<String, Integer>> airPlayResolutionMap) {
    assert instance_ != 0;

    String deviceId = NetUtils.getRandomMacAddress();

    startAirplayNative(
        instance_,
        name,
        deviceId,
        security,
        airPlayResolutionMap);

  }

  // stop airplay
  public void stopAirplay() {
    assert instance_ != 0;

    stopAirplayNative(
        instance_);

  }

  // start googlecast
  public void startGooglecast(
      String name,
      String uniqueId,
      GooglecastCredentials credentials) {
    assert instance_ != 0;

    startGooglecastNative(
        instance_,
        name,
        uniqueId,
        credentials);

  }

  // stop googlecast
  public void stopGooglecast() {
    assert instance_ != 0;

    stopGooglecastNative(
        instance_);

  }

  public void stop() {
    stopGooglecast();
    stopAirplay();
  }

  public void dispose() {
    if (instance_ != 0) {
      destroyInstanceNative(instance_);
      instance_ = 0;
    }
    // Stop pending timeouts to avoid callbacks after shutdown.
    mTimeoutHandler.removeCallbacksAndMessages(null);
    mTimeoutRunnables.clear();
    activeMirrorSessions_.clear();
    // Stop Watchdog monitoring mechanism
    stopMonitoring();
  }

  // stop a mirror session by its Id
  public void stopMirror(String mirrorId) {
    assert instance_ != 0;

    stopMirrorNative(
        instance_,
        mirrorId);
  }

  // update googlecast's credentials
  public void updateCredentials(GooglecastCredentials credentials) {
    assert instance_ != 0;

    updateGooglecastCredentialNative(
        instance_,
        credentials);
  }

  public void enableAudio(String mirrorId, boolean enable) {
    assert instance_ != 0;

    enableAudioNative(
        instance_,
        mirrorId,
        enable);
  }

  private NsdServiceInfo toServiceInfo(ServiceInfo info) {
    NsdServiceInfo serviceInfo = new NsdServiceInfo();

    serviceInfo.setServiceName(info.serviceName);
    serviceInfo.setServiceType(info.serviceType);

    info.attributes.forEach(
        (k, v) -> serviceInfo.setAttribute(k, v));

    serviceInfo.setPort(info.port);

    return serviceInfo;
  }

  private static String nsdErrorToString(int errorCode) {
    switch (errorCode) {
      case NsdManager.FAILURE_ALREADY_ACTIVE:
        return "FAILURE_ALREADY_ACTIVE";
      case NsdManager.FAILURE_INTERNAL_ERROR:
        return "FAILURE_INTERNAL_ERROR";
      case NsdManager.FAILURE_MAX_LIMIT:
        return "FAILURE_MAX_LIMIT";
      default:
        return "UNKNOWN";
    }
  }

  // Standardize NSD logs for easier grep and error diagnosis.
  private void logNsdEvent(String level, String event, ServiceInfo info, int errorCode) {
    String message = String.format(
        "%s event=%s name=%s type=%s port=%d code=%d reason=%s",
        NSD_LOG_PREFIX,
        event,
        info != null ? info.serviceName : "null",
        info != null ? info.serviceType : "null",
        info != null ? info.port : -1,
        errorCode,
        nsdErrorToString(errorCode));
    if ("E".equals(level)) {
      Log.e(TAG, message);
    } else if ("W".equals(level)) {
      Log.w(TAG, message);
    } else {
      Log.i(TAG, message);
    }
  }

  private boolean isNetworkConnected() {
    ConnectivityManager cm = (ConnectivityManager) context_.getSystemService(Context.CONNECTIVITY_SERVICE);
    if (cm == null) {
      return false;
    }
    NetworkInfo activeNetwork = cm.getActiveNetworkInfo();
    return activeNetwork != null && activeNetwork.isConnected();
  }

  private void registerPendingServices() {
    if (pendingServices_.isEmpty()) {
      return;
    }
    if (!isNetworkConnected()) {
      return;
    }

    Log.i(TAG, "Registering pending MDNS services, count: " + pendingServices_.size());

    List<String> serviceNames = new ArrayList<>(pendingServices_.keySet());
    for (String serviceName : serviceNames) {
      ServiceInfo info = pendingServices_.remove(serviceName);
      if (info == null) {
        continue;
      }
      registerServiceInternal(info);
    }
  }

  private void scheduleServiceRetry(String serviceName) {
    ServiceInfo info = serviceInfos_.get(serviceName);
    if (info == null) {
      Log.w(TAG, "No ServiceInfo found for retry: " + serviceName);
      return;
    }

    // Exponential backoff to avoid hammering NSD when network is unstable.
    int attempt = serviceRetryCounts_.getOrDefault(serviceName, 0);
    if (attempt >= SERVICE_RETRY_MAX_ATTEMPTS) {
      Log.e(TAG, "Service register retry exceeded max attempts: " + serviceName);
      pendingServices_.put(serviceName, info);
      return;
    }

    long delay = Math.min(SERVICE_RETRY_BASE_MS << attempt, SERVICE_RETRY_MAX_MS);
    serviceRetryCounts_.put(serviceName, attempt + 1);

    Runnable existing = serviceRetryRunnables_.remove(serviceName);
    if (existing != null) {
      serviceHandler_.removeCallbacks(existing);
    }

    Runnable retry = () -> {
      serviceRetryRunnables_.remove(serviceName);
      Log.w(TAG, "Retrying MDNS register for service: " + serviceName);
      registerServiceInternal(info);
    };
    serviceRetryRunnables_.put(serviceName, retry);
    serviceHandler_.postDelayed(retry, delay);

    Log.w(TAG, "Scheduled MDNS register retry for " + serviceName + " in " + delay + "ms");
  }

  private void scheduleBootstrapRefresh() {
    if (bootstrapRefreshRemaining_ > 0) {
      return;
    }
    bootstrapRefreshRemaining_ = SERVICE_BOOTSTRAP_REFRESH_COUNT;
    Runnable refresh = new Runnable() {
      @Override
      public void run() {
        // Stop early if network drops during the bootstrap burst.
        if (!isNetworkConnected()) {
          bootstrapRefreshRemaining_ = 0;
          return;
        }
        Log.i(TAG, "Bootstrap MDNS refresh, remaining: " + bootstrapRefreshRemaining_);
        refreshMdnsServices();
        bootstrapRefreshRemaining_ -= 1;
        if (bootstrapRefreshRemaining_ > 0) {
          serviceHandler_.postDelayed(this, SERVICE_BOOTSTRAP_REFRESH_INTERVAL_MS);
        }
      }
    };
    serviceHandler_.postDelayed(refresh, SERVICE_BOOTSTRAP_REFRESH_INTERVAL_MS);
  }

  private void cancelServiceRetry(String serviceName) {
    Runnable retry = serviceRetryRunnables_.remove(serviceName);
    if (retry != null) {
      serviceHandler_.removeCallbacks(retry);
    }
    serviceRetryCounts_.remove(serviceName);
  }

  private NsdManager.RegistrationListener createServiceListener() {
    return new NsdManager.RegistrationListener() {
      @Override
      public void onServiceRegistered(NsdServiceInfo serviceInfo) {
        ServiceInfo info = serviceInfos_.get(serviceInfo.getServiceName());
        cancelServiceRetry(serviceInfo.getServiceName());
        logNsdEvent("I", "register_ok", info, 0);
      }

      @Override
      public void onRegistrationFailed(NsdServiceInfo serviceInfo, int errorCode) {
        ServiceInfo info = serviceInfos_.get(serviceInfo.getServiceName());
        logNsdEvent("E", "register_fail", info, errorCode);
        services_.remove(serviceInfo.getServiceName());
        scheduleServiceRetry(serviceInfo.getServiceName());
      }

      @Override
      public void onServiceUnregistered(NsdServiceInfo serviceInfo) {
        ServiceInfo info = serviceInfos_.get(serviceInfo.getServiceName());
        logNsdEvent("I", "unregister_ok", info, 0);
      }

      @Override
      public void onUnregistrationFailed(NsdServiceInfo serviceInfo, int errorCode) {
        ServiceInfo info = serviceInfos_.get(serviceInfo.getServiceName());
        logNsdEvent("E", "unregister_fail", info, errorCode);
      }
    };
  }

  private void registerServiceInternal(ServiceInfo info) {
    if (nsdManager_ == null) {
      return;
    }

    if (!isNetworkConnected()) {
      // Network not ready yet; defer to avoid initial boot failures.
      pendingServices_.put(info.serviceName, info);
      Log.i(TAG, "Network not connected, deferring service register: " + info.serviceName);
      return;
    }

    if (services_.containsKey(info.serviceName)) {
      // Already registered with NSD; skip re-register here.
      Log.i(TAG, "Service already registered: " + info.serviceName);
      return;
    }

    NsdServiceInfo serviceInfo = toServiceInfo(info);
    NsdManager.RegistrationListener listener = createServiceListener();

    nsdManager_.registerService(
        serviceInfo,
        NsdManager.PROTOCOL_DNS_SD,
        listener);

    services_.put(info.serviceName, listener);
  }

  public boolean onServiceRegister(ServiceInfo info) {
    assert nsdManager_ != null;

    if (nsdManager_ == null) {
      return false;
    }

    // register service
    Log.i(TAG, String.format("Registering DNS-SD service %s %s %d",
        info.serviceName,
        info.serviceType,
        info.port));
    logNsdEvent("I", "register_start", info, 0);

    serviceInfos_.put(info.serviceName, info);  // Save ServiceInfo for periodic refresh
    registerServiceInternal(info);

    return true;
  }

  public boolean onServiceUnregister(String serviceName) {
    assert nsdManager_ != null;

    if (nsdManager_ == null) {
      return false;
    }

    Log.i(TAG, String.format("Unregistering DNS-SD service %s ",
        serviceName));

    NsdManager.RegistrationListener listener = services_.remove(serviceName);
    if (listener != null) {
      // unregister service
      nsdManager_.unregisterService(listener);
    }

    // Remove stored ServiceInfo
    serviceInfos_.remove(serviceName);
    pendingServices_.remove(serviceName);
    cancelServiceRetry(serviceName);

    return listener != null;
  }

  /**
   * Check if there are active mirror sessions
   */
  private boolean hasActiveSessions() {
    return !activeMirrorSessions_.isEmpty();
  }

  /**
   * Refresh all MDNS services (similar to vCast's periodic MDNS re-registration)
   * This ensures service visibility even without network changes or service failures
   *
   * Note: Skip refresh if there are active mirror sessions to avoid connection disruption
   */
  private void refreshMdnsServices() {
    if (nsdManager_ == null || serviceInfos_.isEmpty()) {
      return;
    }

    if (!isNetworkConnected()) {
      Log.i(TAG, "Skipping MDNS refresh due to no network connection");
      return;
    }

    // Skip MDNS refresh if there are active mirror sessions
    // to avoid disrupting ongoing connections
    if (hasActiveSessions()) {
      Log.d(TAG, "Skipping MDNS refresh due to active mirror sessions");
      return;
    }

    Log.i(TAG, "Refreshing MDNS services, count: " + serviceInfos_.size());

    // Create a copy of service names to avoid concurrent modification
    List<String> serviceNames = new ArrayList<>(serviceInfos_.keySet());

    for (String serviceName : serviceNames) {
      ServiceInfo info = serviceInfos_.get(serviceName);
      if (info == null) {
        continue;
      }

      // Unregister existing service
      NsdManager.RegistrationListener oldListener = services_.get(serviceName);
      if (oldListener != null) {
        try {
          Log.i(TAG, "Unregistering MDNS service for refresh: " + serviceName);
          nsdManager_.unregisterService(oldListener);
          services_.remove(serviceName);
        } catch (Exception e) {
          Log.w(TAG, "Failed to unregister service: " + serviceName, e);
        }
      }

      // Re-register service
      try {
        Log.i(TAG, "Re-registering MDNS service: " + serviceName);
        NsdServiceInfo serviceInfo = toServiceInfo(info);
        NsdManager.RegistrationListener newListener = createServiceListener();
        nsdManager_.registerService(serviceInfo, NsdManager.PROTOCOL_DNS_SD, newListener);
        services_.put(serviceName, newListener);
      } catch (Exception e) {
        Log.e(TAG, "Failed to re-register service: " + serviceName, e);
      }
    }
  }

  @Override
  public void onMirrorAuth(String pin, int timeoutSec) {
    mirrorListener_.onMirrorAuth(pin, timeoutSec);
  }

  @Override
  public void onMirrorStart(
      String mirrorId,
      long textureId,
      String deviceName,
      String deviceModel,
      String mirrorType) {
    // Track this as an active session
    activeMirrorSessions_.add(mirrorId);

    mirrorListener_.onMirrorStart(
        mirrorId,
        textureId,
        deviceName,
        deviceModel,
        mirrorType);

    // Start 12-second timeout mechanism (only for Google Cast and AirPlay)
    // Similar to vCast's blank video timeout mechanism
    if (mirrorType.equals("google_cast") || mirrorType.equals("airplay")) {
      Runnable timeoutRunnable = () -> {
        Log.w(TAG, "Mirror session " + mirrorId + " timeout (no video for 12s), stopping.");
        stopMirror(mirrorId);
      };
      mTimeoutRunnables.put(mirrorId, timeoutRunnable);
      mTimeoutHandler.postDelayed(timeoutRunnable, CCAST_BLANK_TIMEOUT);
    }
  }

  @Override
  public void onMirrorStop(String mirrorId) {
    // Remove from active sessions tracking
    activeMirrorSessions_.remove(mirrorId);

    mirrorListener_.onMirrorStop(mirrorId);

    // Cancel any pending timeout for this session.
    Runnable timeoutRunnable = mTimeoutRunnables.remove(mirrorId);
    if (timeoutRunnable != null) {
      mTimeoutHandler.removeCallbacks(timeoutRunnable);
    }
  }

  @Override
  public void onMirrorVideoResize(String mirrorId, int width, int height) {
    mirrorListener_.onMirrorVideoResize(mirrorId, width, height);

    // Video received, cancel timeout timer
    // Similar to vCast's onCastSessionSetVideoSize canceling timer
    Runnable timeoutRunnable = mTimeoutRunnables.remove(mirrorId);
    if (timeoutRunnable != null) {
      mTimeoutHandler.removeCallbacks(timeoutRunnable);
      Log.i(TAG, "Video received for " + mirrorId + ", timeout cancelled.");
    }
  }

  @Override
  public void onMirrorVideoFrameRate(String mirrorId, int fps) {
    mirrorListener_.onMirrorVideoFrameRate(mirrorId, fps);
  }

  @Override
  public void onCredentialsRequest(
      int year,
      int month,
      int day) {
    mirrorListener_.onCredentialsRequest(year, month, day);
  }

//  @Override
//  public void onSourceCapabilities(String mirrorId, boolean isUibcSupported) {
//    mirrorListener_.onMirrorCapabilities(
//        mirrorId,
//        isUibcSupported);
//  }

  @Override
  public void onMirrorError(String mirrorType, String erroMessage) {
    mirrorListener_.onMirrorError(mirrorType, erroMessage);
  }

  @Override
  public void onMirrorCapabilities(
      String mirrorId,
      boolean isUibcSupported) {
    mirrorListener_.onMirrorCapabilities(
        mirrorId,
        isUibcSupported);
  }

  /**
   * AirPlay session ended callback
   * Similar to vCast's RTSPResponder broadcasting ACTION_AIRPLAY_DISCONNECTED
   */
  public void onAirplaySessionEnded(String mirrorId) {
    Log.i(TAG, "AirPlay session ended: " + mirrorId);

    // Remove from active sessions tracking
    activeMirrorSessions_.remove(mirrorId);

    stopMirror(mirrorId);

    // Clean up timeout timer
    Runnable timeoutRunnable = mTimeoutRunnables.remove(mirrorId);
    if (timeoutRunnable != null) {
      mTimeoutHandler.removeCallbacks(timeoutRunnable);
    }
  }

  private native long createInstanceNative(
      TexRegistry textureRegistry, Map<String, Integer> options);

  private native void destroyInstanceNative(
      long instance);

  private native void enableDumpNative(
      long instance,
      String dumpPath);

  private native void stopMirrorNative(
      long instance,
      String mirrorId);

  private native void enableAudioNative(
      long instance,
      String mirrorId,
      boolean enable);

  private native void startMirrorReplayNative(
      long instance,
      String mirrorId,
      String videoCodec,
      String videoPath);

  private native void startAirplayNative(
      long instance,
      String name,
      String deviceId,
      String security,
      Map<String, Map<String, Integer>> airPlayResolutionMap);

  private native void stopAirplayNative(
      long instance);

  public native void startGooglecastNative(
      long instance,
      String name,
      String uniqueId,
      GooglecastCredentials credentials);

  private native void stopGooglecastNative(
      long instance);

  public native void updateGooglecastCredentialNative(
      long instance,
      GooglecastCredentials credentials);

}
