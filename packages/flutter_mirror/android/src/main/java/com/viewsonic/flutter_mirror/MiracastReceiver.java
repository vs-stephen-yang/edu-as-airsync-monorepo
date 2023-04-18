package com.viewsonic.flutter_mirror;

import androidx.annotation.Keep;
import android.app.Activity;
import android.content.Context;

import com.viewsonic.miracast.MiraMgr;
import com.viewsonic.miracast.MiraMgrListener;
import android.util.Log;

@Keep
public class MiracastReceiver implements
    MiraMgrListener {

  private static final String TAG = "MiracastReceiver";
  private long instance_;

  public MiracastReceiver(
      long mirrorListenerInstance) {

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

    MiraMgr.getInstance().start(
        context,
        activity,
        this,
        name);
  }

  public void stop() {

  }

  public void onMirrorTouch(
      int sessionId,
      int touchId,
      boolean touch,
      double x,
      double y) {
    MiraMgr.getInstance().onTouchEvent(
        sessionId,
        touchId,
        touch,
        x,
        y);
  }

  // Called from native
  public void sendIdrRequest(int sessionId) {
    MiraMgr.getInstance().rtspRequestIdr(sessionId);
  }

  // implements MiraMgrListener
  @Override
  public void onSessionBegin(int sessionId) {
    assert instance_ != 0;

    onSessionBeginNative(instance_, sessionId);
  }

  @Override
  public void onSessionEnd(int sessionId) {
    assert instance_ != 0;

    onSessionEndNative(instance_, sessionId);
  }

  @Override
  public void onMirrorData(
      int sessionId,
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
        sessionId,
        data,
        size);
  }

  @Override
  public void onAudioFormatUpdate(
      int sessionId,
      String codecName,
      int sampleRate,
      int channelCount) {
    assert instance_ != 0;

    onAudioFormatUpdateNative(
        instance_,
        sessionId,
        codecName,
        sampleRate,
        channelCount);
  }

  // Native methods
  private native long createInstanceNative(
      long mirrorListenerInstance);

  private native void destroyInstanceNative(
      long instance);

  private native void onSessionBeginNative(
      long instance,
      int sessionId);

  private native void onSessionEndNative(
      long instance,
      int sessionId);

  private native void onPacketNative(
      long instance,
      int sessionId,
      byte[] data,
      int size);

  private native void onAudioFormatUpdateNative(
      long instance,
      int sessionId,
      String codecName,
      int sampleRate,
      int channelCount);
}
