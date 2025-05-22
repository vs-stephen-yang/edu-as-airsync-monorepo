package com.viewsonic.flutter_mirror;

import androidx.annotation.Keep;
import android.app.Activity;
import android.content.Context;
import android.net.nsd.NsdManager;
import android.net.nsd.NsdServiceInfo;
import android.util.Log;

import java.util.HashMap;
import java.util.Map;

@Keep
public class MirrorReceiver implements
    MiracastReceiverListener,
    MirrorListener {

  private static final String TAG = "MirrorReceiver";

  private long instance_;
  private MirrorListener mirrorListener_;

  // dns-sd services
  NsdManager nsdManager_;
  Map<String, NsdManager.RegistrationListener> services_ = new HashMap<>();

  // Miracast
  private MiracastReceiver miracastReceiver_;

  public MirrorReceiver(
      MirrorListener mirrorListener,
      TexRegistry textureRegistry,
      Map<String, Integer> additionalCodecParams,
      Context context) {
    assert mirrorListener != null;
    assert textureRegistry != null;

    mirrorListener_ = mirrorListener;

    // create C++ MirrorReceiver
    instance_ = createInstanceNative(
        textureRegistry,
        additionalCodecParams);

    assert instance_ != 0;

    miracastReceiver_ = new MiracastReceiver(
        this,
        instance_);

    assert (instance_ != 0);

    nsdManager_ = (NsdManager) context.getSystemService(Context.NSD_SERVICE);
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
  public void startAirplay(String name, String security) {
    assert instance_ != 0;

    String deviceId = NetUtils.getRandomMacAddress();

    startAirplayNative(
        instance_,
        name,
        deviceId,
        security);
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

  // start miracast
  public void startMiracast(
      String name,
      Context context,
      Activity activity) {
    assert context != null;
    assert activity != null;

    miracastReceiver_.start(
        name,
        context,
        activity);
  }

  // stop miracast
  public void stopMiracast() {
    if (miracastReceiver_ != null) {
      miracastReceiver_.stop();
    }
  }

  public void stop() {
    miracastReceiver_.stop();

    stopGooglecast();
    stopAirplay();
  }

  public void dispose() {
    if (instance_ != 0) {
      destroyInstanceNative(instance_);
      instance_ = 0;
    }
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

  public void onMirrorTouch(
      String mirrorId,
      int touchId,
      boolean touch,
      double x,
      double y) {
    miracastReceiver_.onMirrorTouch(
        mirrorId,
        touchId,
        touch,
        x,
        y);
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

  private NsdManager.RegistrationListener createServiceListener() {
    return new NsdManager.RegistrationListener() {
      @Override
      public void onServiceRegistered(NsdServiceInfo serviceInfo) {
        Log.i(TAG, String.format("onServiceRegistered %s",
            serviceInfo.getServiceName()));
      }

      @Override
      public void onRegistrationFailed(NsdServiceInfo serviceInfo, int errorCode) {
        Log.e(TAG, "onRegistrationFailed");
        Log.e(TAG, String.format("onRegistrationFailed %s %d",
            serviceInfo.getServiceName(),
            errorCode));
      }

      @Override
      public void onServiceUnregistered(NsdServiceInfo serviceInfo) {
        Log.i(TAG, String.format("onServiceUnregistered %s",
            serviceInfo.getServiceName()));
      }

      @Override
      public void onUnregistrationFailed(NsdServiceInfo serviceInfo, int errorCode) {
        Log.e(TAG, String.format("onUnregistrationFailed %s %d",
            serviceInfo.getServiceName(),
            errorCode));
      }
    };
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

    NsdServiceInfo serviceInfo = toServiceInfo(info);

    NsdManager.RegistrationListener listener = createServiceListener();

    nsdManager_.registerService(
        serviceInfo,
        NsdManager.PROTOCOL_DNS_SD,
        listener);

    // store the listener
    if (services_.put(info.serviceName, listener) != null) {
      Log.w(TAG, "The previous listener is not unregistered");
    }

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
    if (listener == null) {
      return false;
    }

    // unregister service
    nsdManager_.unregisterService(listener);

    return true;
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
      String mirrorType) {
    mirrorListener_.onMirrorStart(
        mirrorId,
        textureId,
        deviceName,
        mirrorType);
  }

  @Override
  public void onMirrorStop(String mirrorId) {
    mirrorListener_.onMirrorStop(mirrorId);
  }

  @Override
  public void onMirrorVideoResize(String mirrorId, int width, int height) {
    mirrorListener_.onMirrorVideoResize(mirrorId, width, height);
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

  @Override
  public void onMiracastError(String erroMessage) {
    mirrorListener_.onMirrorError("miracast", erroMessage);
  }
  @Override
  public void onMirrorError(String mirrorType, String erroMessage) {
    mirrorListener_.onMirrorError(mirrorType, erroMessage);
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
      String security);

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
