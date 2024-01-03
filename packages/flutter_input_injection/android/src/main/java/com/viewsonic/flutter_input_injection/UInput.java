package com.viewsonic.flutter_input_injection;
import androidx.annotation.Keep;

@Keep
public class UInput {
  static {
    System.loadLibrary("libuinput");
  }

  public static native boolean init(int width, int height);

  public static native void close();

  public static native void injectSingleTouch(int x, int y, int eventType);
}
