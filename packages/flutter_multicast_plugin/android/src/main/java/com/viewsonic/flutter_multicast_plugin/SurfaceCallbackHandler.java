package com.viewsonic.flutter_multicast_plugin;

import android.util.Log;
import android.view.Surface;
import io.flutter.view.TextureRegistry;


public class SurfaceCallbackHandler implements TextureRegistry.SurfaceProducer.Callback {
    private static final String TAG = "SurfaceCallbackHandler";

    public interface SurfaceLifecycleListener {
        void onSurfaceReady(Surface surface);
        void onSurfaceDestroyed();
    }

    private final TextureRegistry.SurfaceProducer producer;
    private final SurfaceLifecycleListener listener;
    private boolean isActive = false;

    public SurfaceCallbackHandler(TextureRegistry.SurfaceProducer producer,
                                  SurfaceLifecycleListener listener) {
        this.producer = producer;
        this.listener = listener;
        this.producer.setCallback(this);
    }

    public void setActive(boolean active) {
        this.isActive = active;
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
            listener.onSurfaceReady(newSurface);
        }
    }

    @Override
    public void onSurfaceDestroyed() {
        Log.d(TAG, "Surface destroyed");
        if (isActive && listener != null) {
            listener.onSurfaceDestroyed();
        }
    }
}
