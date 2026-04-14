package com.viewsonic.flutter_mirror;

import android.view.Surface;

interface TexRegistry {

  // create a surface and return its id
  public long createSurfaceTexture() throws java.lang.Exception;

  public Surface getSurfaceTexture(long textureId) throws java.lang.Exception;

  // release a surface
  public void releaseSurfaceTexture(long textureId) throws java.lang.Exception;
}
