package com.viewsonic.flutter_mirror;

import android.util.Log;
import android.view.Surface;

import io.flutter.view.TextureRegistry;

public class SurfaceCallbackHandler implements TextureRegistry.SurfaceProducer.Callback {
  private static final String TAG = "SurfaceCallbackHandler";

  public interface SurfaceLifecycleListener {
    void onSurfaceReady(String mirrorId, Surface surface);

    void onSurfaceDestroyed(String mirrorId);
  }

  private final TextureRegistry.SurfaceProducer producer;
  private final SurfaceLifecycleListener listener;
  private boolean isActive = false;

  private String mirrorId;

  public SurfaceCallbackHandler(TextureRegistry.SurfaceProducer producer,
                                SurfaceLifecycleListener listener) {
    this.producer = producer;
    this.listener = listener;
    this.producer.setCallback(this);
  }

  public void setActive(boolean active) {
    this.isActive = active;
  }

  public void setMirrorId(String id) {
    mirrorId = id;
  }

  public boolean isActive() {
    return isActive;
  }

  public long getTextureId() {
    return producer.id();
  }

  public Surface getSurface() {
    return producer.getSurface();
  }

  public void release() {
    if (producer != null) {
      producer.release();
    }
  }

  @Override
  public void onSurfaceAvailable() {
    Log.d(TAG, "Surface available");
    if (isActive && listener != null) {
      Surface newSurface = producer.getSurface();
      listener.onSurfaceReady(mirrorId, newSurface);
    }
  }

  @Override
  public void onSurfaceDestroyed() {
    Log.d(TAG, "Surface destroyed");
    if (isActive && listener != null) {
      listener.onSurfaceDestroyed(mirrorId);
    }
  }
}
