package com.viewsonic.miracast;

public interface SurfaceTextureProviderCallback {
  void onResult(long textureId);
  default void onError(Exception e) { }
}

