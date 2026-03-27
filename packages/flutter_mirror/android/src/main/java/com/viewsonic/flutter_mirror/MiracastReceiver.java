package com.viewsonic.flutter_mirror;

import androidx.annotation.Keep;

import android.app.Activity;
import android.content.Context;

import com.viewsonic.miracast.MiraMgrListener;
import com.viewsonic.miracast.MiraMgrProxy;
import com.viewsonic.miracast.MiraSession;
import com.viewsonic.miracast.SurfaceTextureProvider;

import android.util.Log;
import android.view.Surface;

@Keep
public class MiracastReceiver implements
  MiraMgrListener {

  private static final String TAG = "MiracastReceiver";

  private final MiracastReceiverListener listener_;
  private final MirrorReceiver mirrorReceiver_;
  private long instance_;


  public MiracastReceiver(
    MiracastReceiverListener listener,
    MirrorReceiver mirrorReceiver
  ) {
    listener_ = listener;
    mirrorReceiver_ = mirrorReceiver;
    instance_ = createInstanceNative(mirrorReceiver_.getNativeInstance());
  }

  public void start(
    String name,
    Context context,
    Activity activity,
    SurfaceTextureProvider surfaceTextureProvider
  ) {
    assert context != null;
    assert activity != null;

    Log.d(TAG, "MiracastReceiver.start()");
    MiraMgrProxy.getInstance().start(
      context,
      activity,
      this,
      name,
      surfaceTextureProvider
    );
  }

  public void stop() {
    Log.d(TAG, "MiracastReceiver.stop()");
    MiraMgrProxy.getInstance().stop();
  }

  public void dispose() {
    if (instance_ == 0) {
      return;
    }

    destroyInstanceNative(instance_);
    instance_ = 0;
  }

  // Called from native
  public void stopMirror(String mirrorId) {
    Log.d(TAG, String.format("MiracastReceiver.stopMirror(%s)", mirrorId));

    MiraMgrProxy.getInstance().stopMirror(mirrorId);
  }

  public void onMirrorTouch(
    String mirrorId,
    int touchId,
    boolean touch,
    double x,
    double y) {
    MiraMgrProxy.getInstance().onTouchEvent(
      mirrorId,
      touchId,
      touch,
      x,
      y);
  }

  // Called from native
  public void sendIdrRequest(String mirrorId) {
    MiraMgrProxy.getInstance().rtspRequestIdr(mirrorId);
  }

  public void pausePlayer(String mirrorId) {
    MiraMgrProxy.getInstance().pausePlayer(mirrorId);
  }

  public void restartPlayer(String mirrorId, Surface surface) {
    MiraMgrProxy.getInstance().restartPlayer(mirrorId, surface);
  }

  public void mutePlayer(String mirrorId, boolean mute) {
    MiraMgrProxy.getInstance().mutePlayer(mirrorId, mute);
  }

  // implements MiraMgrListener
  @Override
  public void onAudioFormatUpdate(
    String mirrorId,
    String codecName,
    int sampleRate,
    int channelCount) {
    if (instance_ == 0) {
      return;
    }

    onAudioFormatUpdateNative(instance_, mirrorId, codecName, sampleRate, channelCount);
  }

  @Override
  public void onMiracastError(String errorMessage) {
    listener_.onMiracastError(errorMessage);
  }

  @Override
  public void onSourceCapabilities(
    String mirrorId,
    boolean isUibcSupported) {
    listener_.onSourceCapabilities(
      mirrorId,
      isUibcSupported);
  }

  @Override
  public void onMiracastStart(String mirrorId,
                              long textureId,
                              String deviceName) {
    if (instance_ == 0) {
      return;
    }

    onSessionBeginNative(instance_, mirrorId, deviceName);
  }

  @Override
  public void onSessionEnd(String mirrorId) {
    if (instance_ == 0) {
      return;
    }

    onSessionEndNative(instance_, mirrorId);
  }

  @Override
  public void onVideoResolution(String mirrorId, int width, int height) {
  }

  @Override
  public void onRtpPacket(String mirrorId, byte[] data, int size) {
    if (instance_ == 0) {
      return;
    }

    onPacketNative(instance_, mirrorId, data, size);
  }

  private native long createInstanceNative(long mirrorListenerInstance);

  private native void destroyInstanceNative(long instance);

  private native void onSessionBeginNative(long instance, String mirrorId, String deviceName);

  private native void onSessionEndNative(long instance, String mirrorId);

  private native void onPacketNative(long instance, String mirrorId, byte[] data, int size);

  private native void onAudioFormatUpdateNative(
    long instance,
    String mirrorId,
    String codecName,
    int sampleRate,
    int channelCount);
}
