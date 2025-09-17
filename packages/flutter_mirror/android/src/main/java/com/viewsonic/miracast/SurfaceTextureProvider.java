package com.viewsonic.miracast;

import android.view.Surface;

public interface SurfaceTextureProvider {
  void createSurfaceTextureAsync(String mirrorId, SurfaceTextureProviderCallback callback);

  Surface getSurfaceTexture(long textureId) throws java.lang.Exception;

  void releaseSurfaceTexture(long textureId);
}

