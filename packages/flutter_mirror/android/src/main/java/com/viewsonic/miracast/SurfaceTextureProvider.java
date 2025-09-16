package com.viewsonic.miracast;

import android.view.Surface;

public interface SurfaceTextureProvider {
  void createSurfaceTextureAsync(SurfaceTextureProviderCallback callback);

  Surface getSurfaceTexture(long textureId) throws java.lang.Exception;
}

