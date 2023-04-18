package com.viewsonic.flutter_mirror;

import androidx.annotation.Keep;
import android.app.Activity;
import android.content.Context;
import android.util.Log;

@Keep
public class MirrorReceiver implements
    MirrorListener {

  private static final String TAG = "MirrorReceiver";

  private long instance_;
  private MirrorListener mirrorListener_;

  // Miracast
  private MiracastReceiver miracastReceiver_;

  public MirrorReceiver(
      MirrorListener mirrorListener,
      TexRegistry textureRegistry) {
    assert mirrorListener != null;
    assert textureRegistry != null;

    mirrorListener_ = mirrorListener;

    // create C++ MirrorReceiver
    instance_ = createInstanceNative(
        textureRegistry);

    assert instance_ != 0;

    miracastReceiver_ = new MiracastReceiver(
        instance_);

    assert (instance_ != 0);
  }

  // start airplay
  public void startAirplay(String name) {
    assert instance_ != 0;

    startAirplayNative(
        instance_,
        name);
  }

  // start googlecast
  public void startGooglecast(String name, GooglecastCredentials credentials) {
    assert instance_ != 0;

    startGooglecastNative(
        instance_,
        name,
        credentials);
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

  public void stop() {
    // TODO: stop all receivers
    miracastReceiver_.stop();
  }

  // stop a mirror session by its Id
  public void stopMirror(String mirrorId) {
    assert instance_ != 0;

    stopMirrorNative(
        instance_,
        mirrorId);
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
        Integer.parseInt(mirrorId),
        touchId,
        touch,
        x,
        y);
  }

  @Override
  public void onMirrorAuth(String pin, int timeoutSec) {
    mirrorListener_.onMirrorAuth(pin, timeoutSec);
  }

  @Override
  public void onMirrorStart(String mirrorId, long textureId) {
    mirrorListener_.onMirrorStart(mirrorId, textureId);
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
  public void onCredentialsUpdate(
      int year,
      int month,
      int day) {
    mirrorListener_.onCredentialsUpdate(year, month, day);
  }

  private native long createInstanceNative(
      TexRegistry textureRegistry);

  private native void destroyInstanceNative(
      long instance);

  private native void stopMirrorNative(
      long instance,
      String mirrorId);

  private native void enableAudioNative(
      long instance,
      String mirrorId,
      boolean enable);

  private native void startAirplayNative(
      long instance,
      String name);

  public native void startGooglecastNative(
      long instance,
      String name,
      GooglecastCredentials credentials);

  public native void updateGooglecastCredentialNative(
      long instance,
      GooglecastCredentials credentials);
}
