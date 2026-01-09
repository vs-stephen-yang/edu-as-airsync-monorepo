package com.viewsonic.flutter_mirror;

import androidx.annotation.Keep;
import android.content.Context;
import android.net.nsd.NsdManager;
import android.util.Log;

import java.util.Map;

@Keep
public class MirrorReceiver implements
    MirrorListener {

  private static final String TAG = "MirrorReceiver";

  private long instance_;
  private MirrorListener mirrorListener_;
  private MirrorReceiverWatchdog watchdog_;

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

    assert (instance_ != 0);

    NsdManager nsdManager = (NsdManager) context.getSystemService(Context.NSD_SERVICE);
    watchdog_ = new MirrorReceiverWatchdog(context, nsdManager, TAG, this::stopMirror);

    // Start Watchdog monitoring mechanism
    watchdog_.start();
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
    if (watchdog_ != null) {
      watchdog_.dispose();
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

  public boolean onServiceRegister(ServiceInfo info) {
    if (watchdog_ == null) {
      return false;
    }
    return watchdog_.onServiceRegister(info);
  }

  public boolean onServiceUnregister(String serviceName) {
    if (watchdog_ == null) {
      return false;
    }
    return watchdog_.onServiceUnregister(serviceName);
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
    if (watchdog_ != null) {
      watchdog_.onMirrorStart(mirrorId, mirrorType);
    }

    mirrorListener_.onMirrorStart(
        mirrorId,
        textureId,
        deviceName,
        deviceModel,
        mirrorType);

  }

  @Override
  public void onMirrorStop(String mirrorId) {
    if (watchdog_ != null) {
      watchdog_.onMirrorStop(mirrorId);
    }

    mirrorListener_.onMirrorStop(mirrorId);
  }

  @Override
  public void onMirrorVideoResize(String mirrorId, int width, int height) {
    mirrorListener_.onMirrorVideoResize(mirrorId, width, height);
    if (watchdog_ != null) {
      watchdog_.onMirrorVideoResize(mirrorId);
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
