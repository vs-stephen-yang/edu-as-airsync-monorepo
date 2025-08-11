package com.viewsonic.flutter_multicast_plugin;

import android.app.Activity;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.hardware.display.DisplayManager;
import android.hardware.display.VirtualDisplay;
import android.media.MediaCodec;
import android.media.MediaCodecInfo;
import android.media.MediaFormat;
import android.media.projection.MediaProjection;
import android.media.projection.MediaProjectionManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.IBinder;
import android.os.SystemClock;
import android.util.Log;
import android.view.Surface;
import android.opengl.GLES20;
import android.graphics.SurfaceTexture;

import androidx.annotation.Keep;
import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@Keep
public class ScreenCaptureService extends Service {
    private static final String TAG = "ScreenCaptureService";
    private static final String CHANNEL_ID = "screen_capture_channel";

    private volatile boolean isRunningFrameLoop = false;

    private MediaProjection mediaProjection;
    private VirtualDisplay virtualDisplay;
    private MediaCodec mediaCodec;
    private HandlerThread encoderThread;
    private Handler encoderHandler;

    private SurfaceTexture surfaceTexture;
    private Surface surfaceTextureSurface;
    private Surface encoderInputSurface;
    private WindowSurface windowSurface;

    private int width = 1280;
    private int height = 720;
    private int dpi = 320;
    private int bitrate = 4_000_000;
    private int maxBitrate = 8_000_000;
    private int frameRate = 30;
    private int bitrateMode = MediaCodecInfo.EncoderCapabilities.BITRATE_MODE_CBR;

    private volatile boolean isEncoding = false;

    private AudioCaptureManager audioManager;

    @Override
    public void onCreate() {
        super.onCreate();
        createNotificationChannel();
        Notification notification = new NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle("Screen Capture Running")
                .setContentText("Capturing screen for RTP")
                .setSmallIcon(android.R.drawable.ic_btn_speak_now)
                .build();
        startForeground(1, notification);
        encoderThread = new HandlerThread("EncoderThread");
        encoderThread.start();
        encoderHandler = new Handler(encoderThread.getLooper());

        audioManager = new AudioCaptureManager(this);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        int resultCode = intent.getIntExtra("resultCode", Activity.RESULT_CANCELED);
        Intent data = intent.getParcelableExtra("data");

        Bundle cfg = intent.getBundleExtra("config");
        if (cfg != null) {
            this.width  = cfg.getInt("width", this.width);
            this.height = cfg.getInt("height", this.height);

            this.bitrate    = cfg.getInt("bitrate", this.bitrate);
            this.maxBitrate = cfg.getInt("maxBitrate", this.maxBitrate);
            this.frameRate  = cfg.getInt("frameRate", this.frameRate);
            String bm  = cfg.getString("bitrateMode", "CBR");
            bitrateMode = parseBitrateMode(bm); // 轉成對應常數
        }

        if (data == null) {
            Log.e(TAG, "onStartCommand: data Intent is null");
            stopSelf();
            return START_NOT_STICKY;
        }

        MediaProjectionManager projectionManager = (MediaProjectionManager) getSystemService(Context.MEDIA_PROJECTION_SERVICE);
        mediaProjection = projectionManager.getMediaProjection(resultCode, data);

        if (mediaProjection == null) {
            Log.e(TAG, "MediaProjection is null");
            stopSelf();
            return START_NOT_STICKY;
        }

        mediaProjection.registerCallback(new MediaProjection.Callback() {
            @Override
            public void onStop() {
                super.onStop();
                Log.i(TAG, "MediaProjection stopped");
                stopSelf();
            }
        }, null);

        try {
            setupMediaCodec();
            setupEGL();
            createVirtualDisplay();
            startFrameLoop();

            audioManager.init(mediaProjection);
        } catch (IOException e) {
            Log.e(TAG, "Failed to set up codec", e);
            stopSelf();
        } catch (Exception e) {
            Log.e(TAG, "Failed to set up capture", e);
            stopSelf();
        }

        return START_NOT_STICKY;
    }

    private int parseBitrateMode(String mode) {
        if (mode == null) return MediaCodecInfo.EncoderCapabilities.BITRATE_MODE_CBR;
        switch (mode.toUpperCase()) {
            case "VBR": return MediaCodecInfo.EncoderCapabilities.BITRATE_MODE_VBR;
            case "CQ":  return MediaCodecInfo.EncoderCapabilities.BITRATE_MODE_CQ;
            default:    return MediaCodecInfo.EncoderCapabilities.BITRATE_MODE_CBR;
        }
    }

    private void setupMediaCodec() throws IOException {
        MediaFormat format = MediaFormat.createVideoFormat(MediaFormat.MIMETYPE_VIDEO_AVC, width, height);
        format.setInteger(MediaFormat.KEY_COLOR_FORMAT, MediaCodecInfo.CodecCapabilities.COLOR_FormatSurface);

        format.setInteger(MediaFormat.KEY_BITRATE_MODE, bitrateMode);
        format.setInteger(MediaFormat.KEY_BIT_RATE, bitrate);
        format.setInteger("max-bitrate", maxBitrate); // Peak
        format.setInteger(MediaFormat.KEY_FRAME_RATE, frameRate);
        format.setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, 1);

        mediaCodec = MediaCodec.createEncoderByType(MediaFormat.MIMETYPE_VIDEO_AVC);
        mediaCodec.configure(format, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE);
        encoderInputSurface = mediaCodec.createInputSurface();
        mediaCodec.start();
        startEncoding();
    }

    private void setupEGL() {
        int[] textures = new int[1];
        GLES20.glGenTextures(1, textures, 0);
        int textureId = textures[0];

        EGLCore eglCore = new EGLCore();
        windowSurface = new WindowSurface(eglCore, encoderInputSurface, textureId);

        surfaceTexture = new SurfaceTexture(textureId);
        surfaceTexture.setDefaultBufferSize(width, height);
        surfaceTextureSurface = new Surface(surfaceTexture);
    }

    private void createVirtualDisplay() {
        virtualDisplay = mediaProjection.createVirtualDisplay(
                "ScreenCapture",
                width,
                height,
                dpi,
                DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
                surfaceTextureSurface,
                null,
                encoderHandler
        );
    }

    private void startFrameLoop() {
        isRunningFrameLoop = true;
        final long frameIntervalMs = 33;

        Runnable frameRunnable = new Runnable() {
            private boolean initialized = false;
            private long startTimeMs = 0;
            private int frameCount = 0;

            @Override
            public void run() {
                if (!isRunningFrameLoop) return;

                if (!initialized) {
                    try {
                        // ✅ 在 encoderThread 上 makeCurrent 並建立 shader/program
                        windowSurface.makeCurrentAndInitGLObjects();
                        initialized = true;
                        startTimeMs = SystemClock.uptimeMillis(); // 記錄啟動時間
                        frameCount = 0;
                        Log.d(TAG, "GL context initialized and program created");

                        // 排程第一幀
                        long firstFrameTime = startTimeMs + frameIntervalMs;
                        encoderHandler.postAtTime(this, firstFrameTime);
                        return;
                    } catch (Exception e) {
                        Log.e(TAG, "GL init error", e);
                        return;
                    }
                }

                frameCount++;

                long nextFrameTime = startTimeMs + (frameCount + 1) * frameIntervalMs;

                // 執行繪製
                try {
                    surfaceTexture.updateTexImage();
                    windowSurface.drawFrame(surfaceTexture);
                    windowSurface.swapBuffers();
                } catch (Exception e) {
                    Log.e(TAG, "GL frame loop error", e);
                }

                // 排程下一幀
                long nowMs = SystemClock.uptimeMillis();
                if (nextFrameTime < nowMs) {
                    // 如果已經落後，重新計算幀計數以追上進度
                    long elapsedMs = nowMs - startTimeMs;
                    frameCount = (int) (elapsedMs / frameIntervalMs);
                    nextFrameTime = startTimeMs + (frameCount + 1) * frameIntervalMs;
                    Log.d(TAG, "Frame dropped, adjusting to frame " + frameCount);
                }

                encoderHandler.postAtTime(this, nextFrameTime);
            }
        };

        encoderHandler.post(frameRunnable);
    }

    private void startEncoding() {
        isEncoding = true;
        encoderHandler.post(this::encodeNextFrame);
    }

    private void encodeNextFrame() {
        if (!isEncoding) return;
        MediaCodec.BufferInfo bufferInfo = new MediaCodec.BufferInfo();
        try {
            int outputBufferIndex = mediaCodec.dequeueOutputBuffer(bufferInfo, 10_000);
            if (outputBufferIndex >= 0) {
                ByteBuffer encodedData = mediaCodec.getOutputBuffer(outputBufferIndex);

                List<byte[]> nalUnits = processEncodedBuffer(encodedData, bufferInfo.offset, bufferInfo.size);
                for (byte[] nal : nalUnits) {
                    int startCodeLength = detectStartCodeLength(nal);
                    if (startCodeLength == -1) continue;

                    int nalUnitType = nal[startCodeLength] & 0x1F;

                    // Check if this is an IDR frame (NAL unit type 5)
                    if (nalUnitType == 5) {
                        MediaFormat format = mediaCodec.getOutputFormat();
                        ByteBuffer spsBuf = format.getByteBuffer("csd-0");
                        ByteBuffer ppsBuf = format.getByteBuffer("csd-1");
                        if (spsBuf != null && ppsBuf != null) {
                            byte[] sps = new byte[spsBuf.remaining()];
                            byte[] pps = new byte[ppsBuf.remaining()];
                            spsBuf.rewind();
                            spsBuf.get(sps);
                            ppsBuf.rewind();
                            ppsBuf.get(pps);

                            int totalLength = 1 + 2 + sps.length + 2 + pps.length;
                            byte[] stapA = new byte[totalLength];
                            int stapAoffset = 0;
                            stapA[stapAoffset++] = 24; // STAP-A NAL unit type

                            stapA[stapAoffset++] = (byte) ((sps.length >> 8) & 0xFF);
                            stapA[stapAoffset++] = (byte) (sps.length & 0xFF);
                            System.arraycopy(sps, 0, stapA, stapAoffset, sps.length);
                            stapAoffset += sps.length;

                            stapA[stapAoffset++] = (byte) ((pps.length >> 8) & 0xFF);
                            stapA[stapAoffset++] = (byte) (pps.length & 0xFF);
                            System.arraycopy(pps, 0, stapA, stapAoffset, pps.length);

                            NativeBridge.sendRtpFrame(stapA);
                        }
                    }

                    NativeBridge.sendRtpFrame(nal);
                }
                mediaCodec.releaseOutputBuffer(outputBufferIndex, false);
            }
        } catch (IllegalStateException e) {
            Log.e(TAG, "Encoder loop terminated due to codec stop", e);
            return;
        }

        encoderHandler.post(this::encodeNextFrame);
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID,
                    "Screen Capture",
                    NotificationManager.IMPORTANCE_LOW
            );
            NotificationManager manager = getSystemService(NotificationManager.class);
            if (manager != null) {
                manager.createNotificationChannel(channel);
            }
        }
    }

    List<byte[]> processEncodedBuffer(ByteBuffer encodedData, int offset, int size) {
        if (encodedData == null || size <= 0) return new ArrayList<>();

        // 1. 將 ByteBuffer 轉為 byte[]
        byte[] buffer = new byte[size];
        encodedData.position(offset);
        encodedData.limit(offset + size);
        encodedData.get(buffer);

        // 2. 檢查是否為 Annex B
        List<byte[]> nalUnits;
        if (isActuallyAnnexB(buffer)) {
            return splitAnnexBNalus(buffer);
        }
        return convertAvccToAnnexB(buffer);
    }

    boolean isActuallyAnnexB(byte[] buffer) {
        return isAnnexB(buffer) && !looksLikeAvcc(buffer);
    }

    public static boolean isAnnexB(byte[] buffer) {
        if (buffer == null || buffer.length < 6) return false;

        int startCodeCount = 0;
        int i = 0;

        while (i < buffer.length - 4) {
            if (buffer[i] == 0x00 && buffer[i + 1] == 0x00) {
                if (buffer[i + 2] == 0x00 && buffer[i + 3] == 0x01) {
                    startCodeCount++;
                    i += 4;
                    continue;
                } else if (buffer[i + 2] == 0x01) {
                    startCodeCount++;
                    i += 3;
                    continue;
                }
            }
            i++;
        }

        // 若有至少 1 個 start code 且它在開頭，就視為合法的 Annex B
        if (startCodeCount >= 1 &&
                buffer[0] == 0x00 && buffer[1] == 0x00 &&
                ((buffer[2] == 0x00 && buffer[3] == 0x01) || buffer[2] == 0x01)) {
            return true;
        }
        return false;
    }

    boolean looksLikeAvcc(byte[] buffer) {
        int offset = 0;
        while (offset + 4 <= buffer.length) {
            int length = ((buffer[offset] & 0xFF) << 24) |
                    ((buffer[offset + 1] & 0xFF) << 16) |
                    ((buffer[offset + 2] & 0xFF) << 8) |
                    (buffer[offset + 3] & 0xFF);
            offset += 4;
            if (length <= 0 || offset + length > buffer.length)
                return false;
            offset += length;
        }
        return offset == buffer.length; // 所有 NALU 完整對齊
    }

    public static List<byte[]> convertAvccToAnnexB(byte[] avccBuffer) {
        List<byte[]> nalUnits = new ArrayList<>();
        int offset = 0;

        while (offset + 4 <= avccBuffer.length) {
            int length = ((avccBuffer[offset] & 0xFF) << 24) |
                    ((avccBuffer[offset + 1] & 0xFF) << 16) |
                    ((avccBuffer[offset + 2] & 0xFF) << 8) |
                    (avccBuffer[offset + 3] & 0xFF);
            offset += 4;
            if (length <= 0 || offset + length > avccBuffer.length) break;

            byte[] nalUnit = new byte[length + 4];
            nalUnit[0] = 0x00;
            nalUnit[1] = 0x00;
            nalUnit[2] = 0x00;
            nalUnit[3] = 0x01;
            System.arraycopy(avccBuffer, offset, nalUnit, 4, length);
            nalUnits.add(nalUnit);
            offset += length;
        }

        return nalUnits;
    }

    public static List<byte[]> splitAnnexBNalus(byte[] buffer) {
        List<byte[]> nalUnits = new ArrayList<>();
        int start = -1;
        int i = 0;

        while (i < buffer.length - 3) {
            boolean found = false;
            int prefixLength = 0;

            // 找 start code
            if (buffer[i] == 0x00 && buffer[i + 1] == 0x00) {
                if (buffer[i + 2] == 0x01) {
                    found = true;
                    prefixLength = 3;
                } else if (i + 3 < buffer.length && buffer[i + 2] == 0x00 && buffer[i + 3] == 0x01) {
                    found = true;
                    prefixLength = 4;
                }
            }

            if (found) {
                if (start >= 0) {
                    // 上一段 NALU 結束，取出
                    nalUnits.add(Arrays.copyOfRange(buffer, start, i));
                }
                start = i;
                i += prefixLength;
            } else {
                i++;
            }
        }

        // 加入最後一段 NALU（結尾）
        if (start >= 0 && start < buffer.length) {
            nalUnits.add(Arrays.copyOfRange(buffer, start, buffer.length));
        }

        return nalUnits;
    }

    public static int detectStartCodeLength(byte[] nal) {
        if (nal.length >= 4 &&
                nal[0] == 0x00 && nal[1] == 0x00 &&
                nal[2] == 0x00 && nal[3] == 0x01) return 4;
        if (nal.length >= 3 &&
                nal[0] == 0x00 && nal[1] == 0x00 &&
                nal[2] == 0x01) return 3;
        return -1; // Invalid
    }

    @Override
    public void onDestroy() {
        Log.i(TAG, "Service destroying - stopping all capture...");

        if (audioManager != null) audioManager.stop();

        isEncoding = false;
        isRunningFrameLoop = false;
        if (encoderHandler != null) {
            encoderHandler.removeCallbacksAndMessages(null); // 移除所有 message
        }
        if (virtualDisplay != null) virtualDisplay.release();

        if (mediaCodec != null) {
            try {
                mediaCodec.stop();
            } catch (IllegalStateException e) {
                Log.w(TAG, "MediaCodec stop failed", e);
            }
            mediaCodec.release();
        }

        if (mediaProjection != null) mediaProjection.stop();

        if (encoderThread != null) {
            encoderThread.quitSafely();
            try {
                encoderThread.join(); // 等待 thread 完全結束
            } catch (InterruptedException e) {
                Log.w(TAG, "Encoder thread join interrupted", e);
            }
            encoderThread = null;
            encoderHandler = null;
        }

        super.onDestroy();
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}