package com.viewsonic.flutter_multicast_plugin;

import android.opengl.GLES11Ext;
import android.opengl.GLES20;

import androidx.annotation.Keep;

import java.nio.FloatBuffer;

@Keep
public class Texture2dProgram {
    public static final int TEXTURE_EXTERNAL_OES = 0;

    private int programHandle;
    private int textureTarget;
    private int uMatrixLocation;
    private int uTexMatrixLocation;
    private int aPositionLocation;
    private int aTextureCoordLocation;
    private int uTextureSamplerLocation;

    public Texture2dProgram(int programType) {
        if (programType != TEXTURE_EXTERNAL_OES) {
            throw new RuntimeException("Unsupported type");
        }
        textureTarget = GLES11Ext.GL_TEXTURE_EXTERNAL_OES;
        String vertexShader = "uniform mat4 uMVPMatrix;\n" +
                "uniform mat4 uTexMatrix;\n" +
                "attribute vec4 aPosition;\n" +
                "attribute vec4 aTextureCoord;\n" +
                "varying vec2 vTexCoord;\n" +
                "void main() {\n" +
                "  gl_Position = uMVPMatrix * aPosition;\n" +
                "  vTexCoord = (uTexMatrix * aTextureCoord).xy;\n" +
                "}";

        String fragmentShader = "#extension GL_OES_EGL_image_external : require\n" +
                "precision mediump float;\n" +
                "varying vec2 vTexCoord;\n" +
                "uniform samplerExternalOES sTexture;\n" +
                "void main() {\n" +
                "  gl_FragColor = texture2D(sTexture, vTexCoord);\n" +
                "}";

        programHandle = GlUtil.createProgram(vertexShader, fragmentShader);
        if (programHandle == 0) {
            throw new RuntimeException("Unable to create shader program");
        }

        uMatrixLocation = GLES20.glGetUniformLocation(programHandle, "uMVPMatrix");
        uTexMatrixLocation = GLES20.glGetUniformLocation(programHandle, "uTexMatrix");
        aPositionLocation = GLES20.glGetAttribLocation(programHandle, "aPosition");
        aTextureCoordLocation = GLES20.glGetAttribLocation(programHandle, "aTextureCoord");
        uTextureSamplerLocation = GLES20.glGetUniformLocation(programHandle, "sTexture");
    }

    public void draw(int primitiveMode, FloatBuffer vertexBuffer, int firstVertex, int vertexCount,
                     int coordsPerVertex, FloatBuffer texBuffer, float[] texMatrix, int textureId) {
        GLES20.glUseProgram(programHandle);

        // 設定 MVP 和 Tex 矩陣
        GLES20.glUniformMatrix4fv(uMatrixLocation, 1, false, GlUtil.IDENTITY_MATRIX, 0);
        GLES20.glUniformMatrix4fv(uTexMatrixLocation, 1, false, texMatrix, 0);  // 🔥 這行很重要

        GLES20.glEnableVertexAttribArray(aPositionLocation);
        GLES20.glVertexAttribPointer(aPositionLocation, coordsPerVertex, GLES20.GL_FLOAT,
                false, 0, vertexBuffer);

        GLES20.glEnableVertexAttribArray(aTextureCoordLocation);
        GLES20.glVertexAttribPointer(aTextureCoordLocation, 2, GLES20.GL_FLOAT,
                false, 0, texBuffer);

        GLES20.glActiveTexture(GLES20.GL_TEXTURE0);
        GLES20.glBindTexture(textureTarget, textureId);
        GLES20.glUniform1i(uTextureSamplerLocation, 0);

        GLES20.glDrawArrays(primitiveMode, firstVertex, vertexCount);

        GLES20.glDisableVertexAttribArray(aPositionLocation);
        GLES20.glDisableVertexAttribArray(aTextureCoordLocation);
        GLES20.glBindTexture(textureTarget, 0);
        GLES20.glUseProgram(0);
    }

    public void release() {
        GLES20.glDeleteProgram(programHandle);
        programHandle = -1;
    }
}