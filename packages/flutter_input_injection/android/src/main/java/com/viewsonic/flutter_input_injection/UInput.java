package com.viewsonic.flutter_input_injection;

import androidx.annotation.Keep;

@Keep
public class UInput {
  static {
    System.loadLibrary("libuinput");
  }

  public static native boolean init(
      int maxTrackingId,
      int maxSlot,
      int width,
      int height);

  public static native void close();

  public static native void injectKey(int nativeKeyCode, int pressed);

  public static native void injectTouchStart(int slot, int trackingId, int x, int y);

  public static native void injectTouchMove(int slot, int x, int y);

  public static native void injectTouchEnd(int slot);
}
