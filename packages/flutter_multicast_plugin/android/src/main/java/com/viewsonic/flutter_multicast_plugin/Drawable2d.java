package com.viewsonic.flutter_multicast_plugin;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;

public class Drawable2d {
    public enum Prefab {
        FULL_RECTANGLE
    }

    private static final int SIZEOF_FLOAT = 4;
    private static final int COORDS_PER_VERTEX = 2;

    private FloatBuffer vertexArray;
    private FloatBuffer texCoordArray;
    private int vertexCount;

    private static final float[] FULL_RECTANGLE_COORDS = {
            -1.0f, -1.0f,
            1.0f, -1.0f,
            -1.0f,  1.0f,
            1.0f,  1.0f
    };

//    private static final float[] FULL_RECTANGLE_TEX_COORDS = {
//            0.0f, 1.0f,
//            1.0f, 1.0f,
//            0.0f, 0.0f,
//            1.0f, 0.0f
//    };

    private static final float[] FULL_RECTANGLE_TEX_COORDS = {
            0.0f, 0.0f,
            1.0f, 0.0f,
            0.0f, 1.0f,
            1.0f, 1.0f
    };

    public Drawable2d(Prefab shape) {
        switch (shape) {
            case FULL_RECTANGLE:
                vertexArray = createFloatBuffer(FULL_RECTANGLE_COORDS);
                texCoordArray = createFloatBuffer(FULL_RECTANGLE_TEX_COORDS);
                vertexCount = FULL_RECTANGLE_COORDS.length / COORDS_PER_VERTEX;
                break;
            default:
                throw new RuntimeException("Unknown shape " + shape);
        }
    }

    public FloatBuffer getVertexArray() {
        return vertexArray;
    }

    public FloatBuffer getTexCoordArray() {
        return texCoordArray;
    }

    public int getVertexCount() {
        return vertexCount;
    }

    public int getCoordsPerVertex() {
        return COORDS_PER_VERTEX;
    }

    private static FloatBuffer createFloatBuffer(float[] coords) {
        FloatBuffer fb = ByteBuffer.allocateDirect(coords.length * SIZEOF_FLOAT)
                .order(ByteOrder.nativeOrder())
                .asFloatBuffer();
        fb.put(coords).position(0);
        return fb;
    }
}