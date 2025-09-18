package com.viewsonic.miracast.rtp;

import android.view.Surface;

import com.viewsonic.miracast.net.EventBase;

public class RtpMpegTsPlayer implements AutoCloseable {
  private long handle;

  private OnPlayerListener listener_;

  private final EventBase eventBase_;

  public boolean start() {
    if (this.handle == 0) {
      return false;
    }
    return nativeStart(this.handle);
  }

  public RtpMpegTsPlayer(OnPlayerListener listener, EventBase eventBase) {
    this.handle = nativeCreate();
    listener_ = listener;
    eventBase_ = eventBase;
  }

  public void stop() {
    if (this.handle == 0) {
      return;
    }
    nativeStop(this.handle);
  }

  public void setSurface(Surface surface) {
    if (this.handle == 0) {
      return;
    }
    nativeSetSurface(this.handle, surface);
  }

  public int getPort() {
    if (this.handle == 0) {
      return 0;
    }
    return nativeGetPort(this.handle);
  }

  public void release() {
    if (this.handle == 0) {
      return;
    }
    nativeDestroy(this.handle);
    this.handle = 0;
  }

  @Override
  public void close() {
    release();
  }

  public void pause() {
    if (this.handle == 0) {
      return;
    }
    nativePause(this.handle);
  }

  @Override
  protected void finalize() throws Throwable {
    try {
      release();
    } finally {
      super.finalize();
    }
  }

  public void restart(Surface surface) {
    if (this.handle == 0) {
      return;
    }
    nativeRestart(this.handle, surface);
  }

  public void setMute(boolean mute) {
    if (this.handle == 0) {
      return;
    }
    nativeSetMute(this.handle, mute);
  }

  public void onVideoResolution(int width, int height) {
    eventBase_.post(() -> listener_.onVideoResolution(width, height));
  }

  public void onPacketLost() {
    eventBase_.post(() -> listener_.onPacketLost());
  }

  private static native void nativeDestroy(long handle);

  private static native boolean nativeStart(long handle);

  private static native void nativeStop(long handle);

  private static native void nativeSetSurface(long handle, Surface surface);

  private static native int nativeGetPort(long handle);

  private native long nativeCreate();

  private static native void nativePause(long handle);

  private static native void nativeRestart(long handle, Surface surface);

  private static native void nativeSetMute(long handle, boolean mute);
}
