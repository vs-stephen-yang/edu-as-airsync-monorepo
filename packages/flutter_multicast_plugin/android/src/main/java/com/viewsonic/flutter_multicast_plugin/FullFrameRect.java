package com.viewsonic.flutter_multicast_plugin;

import android.opengl.GLES20;

import androidx.annotation.Keep;

import java.nio.FloatBuffer;

@Keep
public class FullFrameRect {
    private Texture2dProgram program;
    private Drawable2d drawable;

    public FullFrameRect(Texture2dProgram program) {
        this.program = program;
        this.drawable = new Drawable2d(Drawable2d.Prefab.FULL_RECTANGLE);
    }

    public void release() {
        program.release();
    }

    public void drawFrame(int textureId, float[] texMatrix) {
        program.draw(
                GLES20.GL_TRIANGLE_STRIP,
                drawable.getVertexArray(), 0,
                drawable.getVertexCount(),
                drawable.getCoordsPerVertex(),
                drawable.getTexCoordArray(),
                texMatrix,
                textureId
        );
    }
}