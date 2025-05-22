package com.viewsonic.flutter_mirror;

import androidx.annotation.Keep;
import android.app.Activity;
import android.content.Context;

import com.viewsonic.miracast.MiraMgr;
import com.viewsonic.miracast.MiraMgrListener;
import com.viewsonic.miracast.MiraMgrProxy;

import android.util.Log;

@Keep
public class MiracastReceiver implements
    MiraMgrListener {

  private static final String TAG = "MiracastReceiver";
  private long instance_;

  MiracastReceiverListener listener_;

  public MiracastReceiver(
      MiracastReceiverListener listener,
      long mirrorListenerInstance) {

    listener_ = listener;

    // create a C++ MiracastReceiver object
    instance_ = createInstanceNative(
        mirrorListenerInstance);

    assert (instance_ != 0);
  }

  public void start(
      String name,
      Context context,
      Activity activity) {
    assert instance_ != 0;
    assert context != null;
    assert activity != null;

    Log.d(TAG, "MiracastReceiver.start()");
    MiraMgrProxy.getInstance().start(
        context,
        activity,
        this,
        name);
  }

  public void stop() {
    Log.d(TAG, "MiracastReceiver.stop()");
    MiraMgrProxy.getInstance().stop();
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

  // implements MiraMgrListener
  @Override
  public void onSessionBegin(
      String mirrorId,
      String deviceName) {
    assert instance_ != 0;

    Log.d(TAG, String.format("MiracastReceiver.onSessionBegin(%s, %s)", mirrorId, deviceName));

    onSessionBeginNative(instance_, mirrorId, deviceName);
  }

  @Override
  public void onSessionEnd(String mirrorId) {
    assert instance_ != 0;

    Log.d(TAG, String.format("MiracastReceiver.onSessionEnd(%s)", mirrorId));

    onSessionEndNative(instance_, mirrorId);
  }

  @Override
  public void onMirrorData(
      String mirrorId,
      long seqNum,
      long lastRTPSeqNum,
      byte[] data,
      int size) throws Exception {
    assert instance_ != 0;
    assert data.length >= size;

    long seqDelta = seqNum - lastRTPSeqNum;

    if (lastRTPSeqNum < 0) {
      // first packet
    } else if (seqDelta <= 0 && seqDelta > -1000) {
      Log.w(TAG,
          "Drop RTP packet. seqNum:" + seqNum + " is not greater than lastRTPSeqNum:" + lastRTPSeqNum + " -> Drop!");
      return;
    } else if (seqDelta > 1) {
      Log.i(TAG, "RTP Packet loss. seqNum:" + seqNum + " > lastRTPSeqNum:" + lastRTPSeqNum + " + 1");
    }

    onPacketNative(
        instance_,
        mirrorId,
        data,
        size);
  }

  @Override
  public void onAudioFormatUpdate(
      String mirrorId,
      String codecName,
      int sampleRate,
      int channelCount) {
    assert instance_ != 0;

    onAudioFormatUpdateNative(
        instance_,
        mirrorId,
        codecName,
        sampleRate,
        channelCount);
  }

  @Override
  public void onMiracastError(String errorMessage) {
    listener_.onMiracastError(errorMessage);
  }

  // Native methods
  private native long createInstanceNative(
      long mirrorListenerInstance);

  private native void destroyInstanceNative(
      long instance);

  private native void onSessionBeginNative(
      long instance,
      String mirrorId,
      String deviceName);

  private native void onSessionEndNative(
      long instance,
      String mirrorId);

  private native void onPacketNative(
      long instance,
      String mirrorId,
      byte[] data,
      int size);

  private native void onAudioFormatUpdateNative(
      long instance,
      String mirrorId,
      String codecName,
      int sampleRate,
      int channelCount);
}
