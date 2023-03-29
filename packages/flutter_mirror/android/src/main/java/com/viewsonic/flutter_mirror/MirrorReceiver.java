package com.viewsonic.flutter_mirror;

import androidx.annotation.Keep;
import android.app.Activity;
import android.content.Context;
import android.util.Log;

import com.viewsonic.miracast.MiraMgr;
import com.viewsonic.miracast.MiraMgrListener;

@Keep
public class MirrorReceiver implements
    MiraMgrListener,
    MirrorListener {

  private static final String TAG = "MirrorReceiver";

  private long instance_;
  private MirrorListener mirrorListener_;

  public MirrorReceiver(
      MirrorListener mirrorListener,
      TexRegistry textureRegistry) {
    assert mirrorListener != null;
    assert textureRegistry != null;

    mirrorListener_ = mirrorListener;

    instance_ = createInstanceNative(
        textureRegistry);

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
    assert instance_ != 0;
    assert context != null;
    assert activity != null;

    MiraMgr.getInstance().start(
        context,
        activity,
        this,
        name);
  }

  public void stop() {
    // TODO: stop all receivers
    MiraMgr.getInstance().stop();
  }

  // stop a mirror session by its Id
  public void stopMirror(String mirrorId) {
    assert instance_ != 0;

    stopMirrorNative(
        instance_,
        mirrorId);
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

  // implements MiraMgrListener
  public void onSessionBegin(int sessionId) {

  }

  public void onSessionEnd(int sessionId) {

  }

  public void onMirrorData(
      int sessionId,
      long seqNum,
      long lastRTPSeqNum,
      byte[] data,
      int size) throws Exception {

  }

  public void onAudioFormatUpdate(
      int sessionId,
      String codecName,
      int sampleRate,
      int channelCount) {

  }

  private native long createInstanceNative(
      TexRegistry textureRegistry);

  private native void DestroyInstanceNative(
      long instance);

  private native void stopMirrorNative(
      long instance,
      String mirrorId);

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
