package com.viewsonic.miracast.rtp;

import android.view.Surface;

public class RtpMpegTsPlayer implements AutoCloseable {
    private long handle;

  private OnPlayerListener listener_;

    public boolean start() {
        if (this.handle == 0) {
            return false;
        }
        return nativeStart(this.handle);
    }
  public RtpMpegTsPlayer(OnPlayerListener listener) {
    this.handle = nativeCreate();
    listener_ = listener;
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

  public void onVideoResolution(int width, int height) {
    listener_.onVideoResolution(width, height);
  }

    private static native void nativeDestroy(long handle);
    private static native boolean nativeStart(long handle);
    private static native void nativeStop(long handle);
    private static native void nativeSetSurface(long handle, Surface surface);
    private static native int nativeGetPort(long handle);
  private native long nativeCreate();
  private static native void nativePause(long handle);
  private static native void nativeRestart(long handle, Surface surface);
}

