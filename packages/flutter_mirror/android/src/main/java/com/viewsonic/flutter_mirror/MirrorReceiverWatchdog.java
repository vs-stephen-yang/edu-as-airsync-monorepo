package com.viewsonic.flutter_mirror;

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
import java.util.concurrent.ConcurrentHashMap;

class MirrorReceiverWatchdog {
  interface MirrorStopper {
    void stopMirror(String mirrorId);
  }

  private static final String NSD_LOG_PREFIX = "NSD";
  private static final long SERVICE_CHECK_INTERVAL = 6000L;  // 6 second health check, similar to vCast
  private static final long SERVICE_RETRY_BASE_MS = 2000L;
  private static final long SERVICE_RETRY_MAX_MS = 30000L;
  private static final int SERVICE_RETRY_MAX_ATTEMPTS = 5;
  // Short burst of refresh after network becomes ready (boot-time visibility).
  private static final int SERVICE_BOOTSTRAP_REFRESH_COUNT = 3;
  private static final long SERVICE_BOOTSTRAP_REFRESH_INTERVAL_MS = 1500L;

  private final String tag_;
  private final Context context_;
  private final NsdManager nsdManager_;
  private final MirrorStopper mirrorStopper_;

  // dns-sd services
  private final Map<String, NsdManager.RegistrationListener> services_ = new HashMap<>();
  private final Map<String, ServiceInfo> serviceInfos_ = new HashMap<>();
  // Defer service register until network is connected.
  private final Map<String, ServiceInfo> pendingServices_ = new ConcurrentHashMap<>();
  // Track retry attempts and scheduled tasks per service.
  private final Map<String, Integer> serviceRetryCounts_ = new ConcurrentHashMap<>();
  private final Map<String, Runnable> serviceRetryRunnables_ = new ConcurrentHashMap<>();

  // Watchdog health check mechanism
  private final Handler serviceHandler_ = new Handler(Looper.getMainLooper());
  private BroadcastReceiver networkStateReceiver_;
  private ConnectivityManager.NetworkCallback networkCallback_;
  // Remaining rounds for the boot-time refresh burst.
  private int bootstrapRefreshRemaining_ = 0;
  private boolean started_ = false;

  MirrorReceiverWatchdog(
      Context context,
      NsdManager nsdManager,
      String tag,
      MirrorStopper mirrorStopper) {
    context_ = context;
    nsdManager_ = nsdManager;
    tag_ = tag;
    mirrorStopper_ = mirrorStopper;
  }

  void start() {
    if (started_) {
      return;
    }
    started_ = true;
    startMonitoring();
  }

  void stop() {
    started_ = false;
    stopMonitoring();
  }

  void dispose() {
    stop();
  }

  boolean onServiceRegister(ServiceInfo info) {
    if (nsdManager_ == null) {
      return false;
    }

    // register service
    Log.i(tag_, String.format("Registering DNS-SD service %s %s %d",
        info.serviceName,
        info.serviceType,
        info.port));
    logNsdEvent("I", "register_start", info, 0);

    serviceInfos_.put(info.serviceName, info);
    registerServiceInternal(info);

    return true;
  }

  boolean onServiceUnregister(String serviceName) {
    if (nsdManager_ == null) {
      return false;
    }

    Log.i(tag_, String.format("Unregistering DNS-SD service %s ",
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
        Log.w(tag_, "Network callback already unregistered", e);
      }
      networkCallback_ = null;
    }
    if (networkStateReceiver_ != null) {
      try {
        context_.unregisterReceiver(networkStateReceiver_);
      } catch (IllegalArgumentException e) {
        Log.w(tag_, "Network receiver already unregistered", e);
      }
      networkStateReceiver_ = null;
    }
  }

  private void handleNetworkChange(boolean isConnected) {
    Log.i(tag_, "Network state changed, isConnected: " + isConnected);

    // Trigger health check immediately when network changes
    serviceHandler_.removeCallbacksAndMessages(null);
    if (isConnected) {
      scheduleBootstrapRefresh();
      registerPendingServices();
    }
    if (started_) {
      serviceHandler_.post(this::checkAndRestartService);
    }
  }

  /**
   * Periodic service maintenance (similar to vCast's periodic check mechanism)
   * Refresh MDNS registration and retry pending services.
   */
  private void checkAndRestartService() {
    if (!started_) {
      return;
    }

    Log.i(tag_, "checkAndRestartService: Performing service health check.");

    // Periodic MDNS service refresh (similar to vCast's periodic re-registration)
    // This ensures service visibility even when services are running normally
    registerPendingServices();
    refreshMdnsServices();

    // Schedule next check
    serviceHandler_.postDelayed(this::checkAndRestartService, SERVICE_CHECK_INTERVAL);
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
      Log.e(tag_, message);
    } else if ("W".equals(level)) {
      Log.w(tag_, message);
    } else {
      Log.i(tag_, message);
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

    Log.i(tag_, "Registering pending MDNS services, count: " + pendingServices_.size());

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
      Log.w(tag_, "No ServiceInfo found for retry: " + serviceName);
      return;
    }

    // Exponential backoff to avoid hammering NSD when network is unstable.
    int attempt = serviceRetryCounts_.getOrDefault(serviceName, 0);
    if (attempt >= SERVICE_RETRY_MAX_ATTEMPTS) {
      Log.e(tag_, "Service register retry exceeded max attempts: " + serviceName);
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
      Log.w(tag_, "Retrying MDNS register for service: " + serviceName);
      registerServiceInternal(info);
    };
    serviceRetryRunnables_.put(serviceName, retry);
    serviceHandler_.postDelayed(retry, delay);

    Log.w(tag_, "Scheduled MDNS register retry for " + serviceName + " in " + delay + "ms");
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
        Log.i(tag_, "Bootstrap MDNS refresh, remaining: " + bootstrapRefreshRemaining_);
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
      Log.i(tag_, "Network not connected, deferring service register: " + info.serviceName);
      return;
    }

    if (services_.containsKey(info.serviceName)) {
      // Already registered with NSD; skip re-register here.
      Log.i(tag_, "Service already registered: " + info.serviceName);
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

  /**
   * Refresh all MDNS services (similar to vCast's periodic MDNS re-registration)
   * This ensures service visibility even without network changes or service failures
   */
  private void refreshMdnsServices() {
    if (nsdManager_ == null || serviceInfos_.isEmpty()) {
      return;
    }

    if (!isNetworkConnected()) {
      Log.i(tag_, "Skipping MDNS refresh due to no network connection");
      return;
    }

    Log.i(tag_, "Refreshing MDNS services, count: " + serviceInfos_.size());

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
          Log.i(tag_, "Unregistering MDNS service for refresh: " + serviceName);
          nsdManager_.unregisterService(oldListener);
          services_.remove(serviceName);
        } catch (Exception e) {
          Log.w(tag_, "Failed to unregister service: " + serviceName, e);
        }
      }

      // Re-register service
      try {
        Log.i(tag_, "Re-registering MDNS service: " + serviceName);
        NsdServiceInfo serviceInfo = toServiceInfo(info);
        NsdManager.RegistrationListener newListener = createServiceListener();
        nsdManager_.registerService(serviceInfo, NsdManager.PROTOCOL_DNS_SD, newListener);
        services_.put(serviceName, newListener);
      } catch (Exception e) {
        Log.e(tag_, "Failed to re-register service: " + serviceName, e);
      }
    }
  }
}
