package com.viewsonic.flutter_multicast_plugin;

import android.opengl.EGL14;
import android.opengl.EGLSurface;
import android.opengl.GLES20;
import android.view.Surface;

import androidx.annotation.Keep;

@Keep
public class WindowSurface {
    private static final String TAG = "WindowSurface";

    private final EGLCore eglCore;
    private final EGLSurface eglSurface;
    private final Surface surface;
    private Texture2dProgram textureProgram;
    private FullFrameRect fullFrameRect;
    private final int textureId;
    private final float[] texMatrix = new float[16];

    public WindowSurface(EGLCore core, Surface surface, int textureId) {
        this.eglCore = core;
        this.surface = surface;
        this.eglSurface = eglCore.createWindowSurface(surface);
        this.textureId = textureId;
    }

    public void makeCurrentAndInitGLObjects() {
        if (!EGL14.eglMakeCurrent(
                eglCore.getEGLDisplay(),
                eglSurface,
                eglSurface,
                eglCore.getEGLContext())) {
            throw new RuntimeException("eglMakeCurrent failed");
        }

        textureProgram = new Texture2dProgram(Texture2dProgram.TEXTURE_EXTERNAL_OES);
        fullFrameRect = new FullFrameRect(textureProgram);
    }

    public void drawFrame(android.graphics.SurfaceTexture surfaceTexture) {
        surfaceTexture.getTransformMatrix(texMatrix);
        GLES20.glViewport(0, 0, eglCore.getSurfaceWidth(eglSurface), eglCore.getSurfaceHeight(eglSurface));
        fullFrameRect.drawFrame(textureId, texMatrix);
    }

    public void swapBuffers() {
        eglCore.swapBuffers(eglSurface);
    }

    public void release() {
        eglCore.releaseSurface(eglSurface);
    }

    public EGLSurface getEGLSurface() {
        return eglSurface;
    }
}