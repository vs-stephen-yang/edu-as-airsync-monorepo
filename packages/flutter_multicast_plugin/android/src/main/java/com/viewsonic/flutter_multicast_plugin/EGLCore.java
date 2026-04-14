package com.viewsonic.flutter_multicast_plugin;

import android.opengl.EGL14;
import android.opengl.EGLConfig;
import android.opengl.EGLContext;
import android.opengl.EGLDisplay;
import android.opengl.EGLSurface;
import android.opengl.EGLSurface;
import android.opengl.EGLExt;
import android.opengl.EGLSurface;
import android.util.Log;
import android.view.Surface;

import androidx.annotation.Keep;

@Keep
public class EGLCore {
    private static final String TAG = "EGLCore";

    private EGLDisplay eglDisplay = EGL14.EGL_NO_DISPLAY;
    private EGLContext eglContext = EGL14.EGL_NO_CONTEXT;
    private EGLConfig eglConfig;

    public EGLCore() {
        eglDisplay = EGL14.eglGetDisplay(EGL14.EGL_DEFAULT_DISPLAY);
        if (eglDisplay == EGL14.EGL_NO_DISPLAY) {
            throw new RuntimeException("Unable to get EGL14 display");
        }

        int[] version = new int[2];
        if (!EGL14.eglInitialize(eglDisplay, version, 0, version, 1)) {
            throw new RuntimeException("Unable to initialize EGL14");
        }

        int[] attribList = {
                EGL14.EGL_RED_SIZE, 8,
                EGL14.EGL_GREEN_SIZE, 8,
                EGL14.EGL_BLUE_SIZE, 8,
                EGL14.EGL_ALPHA_SIZE, 8,
                EGL14.EGL_RENDERABLE_TYPE, EGL14.EGL_OPENGL_ES2_BIT,
                EGL14.EGL_NONE
        };

        EGLConfig[] configs = new EGLConfig[1];
        int[] numConfigs = new int[1];
        if (!EGL14.eglChooseConfig(eglDisplay, attribList, 0, configs, 0, configs.length, numConfigs, 0)) {
            throw new RuntimeException("Unable to choose EGL config");
        }
        eglConfig = configs[0];

        int[] contextAttribs = {
                EGL14.EGL_CONTEXT_CLIENT_VERSION, 2,
                EGL14.EGL_NONE
        };
        eglContext = EGL14.eglCreateContext(eglDisplay, eglConfig, EGL14.EGL_NO_CONTEXT, contextAttribs, 0);
        if (eglContext == null || eglContext == EGL14.EGL_NO_CONTEXT) {
            throw new RuntimeException("Failed to create EGL context");
        }
    }

    public EGLSurface createWindowSurface(Surface surface) {
        int[] surfaceAttribs = {
                EGL14.EGL_NONE
        };
        return EGL14.eglCreateWindowSurface(eglDisplay, eglConfig, surface, surfaceAttribs, 0);
    }

    public boolean makeCurrent(EGLSurface eglSurface) {
        return EGL14.eglMakeCurrent(eglDisplay, eglSurface, eglSurface, eglContext);
    }

    public void swapBuffers(EGLSurface eglSurface) {
        EGL14.eglSwapBuffers(eglDisplay, eglSurface);
    }

    public void releaseSurface(EGLSurface eglSurface) {
        EGL14.eglDestroySurface(eglDisplay, eglSurface);
    }

    public EGLDisplay getEGLDisplay() {
        return eglDisplay;
    }

    public EGLContext getEGLContext() {
        return eglContext;
    }

    public int getSurfaceWidth(EGLSurface surface) {
        int[] width = new int[1];
        EGL14.eglQuerySurface(eglDisplay, surface, EGL14.EGL_WIDTH, width, 0);
        return width[0];
    }

    public int getSurfaceHeight(EGLSurface surface) {
        int[] height = new int[1];
        EGL14.eglQuerySurface(eglDisplay, surface, EGL14.EGL_HEIGHT, height, 0);
        return height[0];
    }
}