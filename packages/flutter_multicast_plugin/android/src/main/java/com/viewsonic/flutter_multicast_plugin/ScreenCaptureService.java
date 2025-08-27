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

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

@Keep
public class ScreenCaptureService extends Service {
    private static final String TAG = "ScreenCaptureService";
    private static final String CHANNEL_ID = "screen_capture_channel";
    private static final byte[] START_CODE = new byte[]{0x00, 0x00, 0x00, 0x01};
    private final int dpi = 320;
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
    private int bitrate = 4_000_000;
    private int maxBitrate = 8_000_000;
    private int frameRate = 30;
    private int bitrateMode = MediaCodecInfo.EncoderCapabilities.BITRATE_MODE_CBR;
    private volatile boolean isEncoding = false;
    private AudioCaptureManager audioManager;
    private ByteBuffer h26xConfig;

    private static boolean isAnnexB(byte[] buffer) {
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
        return startCodeCount >= 1 &&
                buffer[0] == 0x00 && buffer[1] == 0x00 &&
                ((buffer[2] == 0x00 && buffer[3] == 0x01) || buffer[2] == 0x01);
    }

    private static List<byte[]> convertAvccToAnnexB(byte[] avccBuffer) {
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

    /** 回傳：每顆 NAL 都已經「含 start code」的 Annex-B 片段 */
    private static List<byte[]> extractAnnexBNalsFromConfig(ByteBuffer csd) {
        if (csd == null) return Collections.emptyList();

        // 只取有效區間（不要用 clear()）
        ByteBuffer buf = csd.duplicate();
        // 若外面已設 position/limit，保持不變；否則預設就是 0..limit
        byte[] data = new byte[buf.remaining()];
        buf.get(data);

        if (isAnnexB(data)) {
            // 切出每顆 NAL，但「保留」各自的 start code
            return splitAnnexBKeepingStartCodes(data);
        } else {
            // 解析 avcC，將每顆 SPS/PPS 轉成 Annex-B（前面加 00 00 00 01）
            return parseAvcCToAnnexBNalList(data);
        }
    }

    /** Annex-B：保留各自的 start code（3 或 4 byte 都可） */
    private static List<byte[]> splitAnnexBKeepingStartCodes(byte[] b) {
        List<byte[]> out = new ArrayList<>();
        int i = 0, start = -1, scLen = 0;

        while (i + 3 < b.length) {
            int s = i;
            int len = 0;
            if (b[i] == 0 && b[i+1] == 0 && b[i+2] == 1) { len = 3; }
            else if (i + 3 < b.length && b[i] == 0 && b[i+1] == 0 && b[i+2] == 0 && b[i+3] == 1) { len = 4; }

            if (len != 0) {
                if (start >= 0) {
                    // 上一顆 NAL [含它自己的 start code] 切出
                    out.add(Arrays.copyOfRange(b, start, s));
                }
                start = s;
                scLen = len;
                i += len;
            } else {
                i++;
            }
        }
        if (start >= 0) {
            out.add(Arrays.copyOfRange(b, start, b.length));
        }
        return out;
    }

    /** avcC：取出 SPS/PPS，對每段前面補 0x00000001，回傳 Annex-B 片段（含 start code） */
    private static List<byte[]> parseAvcCToAnnexBNalList(byte[] avcc) {
        List<byte[]> out = new ArrayList<>();
        if (avcc.length < 7) return out;

        int idx = 0;
        int configurationVersion = avcc[idx++] & 0xFF;    // 1
        int profile              = avcc[idx++] & 0xFF;
        int compat               = avcc[idx++] & 0xFF;
        int level                = avcc[idx++] & 0xFF;

        int lengthSizeMinusOne   = avcc[idx++] & 0x03;     // 低 2 bit
        int nalLenSize           = (lengthSizeMinusOne + 1); // 1/2/4，幾乎一定是 4

        int numSps = avcc[idx++] & 0x1F; // 低 5 bit
        for (int n = 0; n < numSps; n++) {
            if (idx + 2 > avcc.length) return out;
            int spsLen = ((avcc[idx] & 0xFF) << 8) | (avcc[idx+1] & 0xFF);
            idx += 2;
            if (idx + spsLen > avcc.length) return out;

            byte[] nal = new byte[START_CODE.length + spsLen];
            System.arraycopy(START_CODE, 0, nal, 0, START_CODE.length);
            System.arraycopy(avcc, idx, nal, START_CODE.length, spsLen);
            out.add(nal);
            idx += spsLen;
        }

        if (idx >= avcc.length) return out;

        int numPps = avcc[idx++] & 0xFF;
        for (int n = 0; n < numPps; n++) {
            if (idx + 2 > avcc.length) return out;
            int ppsLen = ((avcc[idx] & 0xFF) << 8) | (avcc[idx+1] & 0xFF);
            idx += 2;
            if (idx + ppsLen > avcc.length) return out;

            byte[] nal = new byte[START_CODE.length + ppsLen];
            System.arraycopy(START_CODE, 0, nal, 0, START_CODE.length);
            System.arraycopy(avcc, idx, nal, START_CODE.length, ppsLen);
            out.add(nal);
            idx += ppsLen;
        }

        return out;
    }

    // 把多顆 Annex-B NAL 串回成一段 bytes（每顆已含 start code）
    private static byte[] joinBytes(List<byte[]> parts) {
        int total = 0; for (byte[] p: parts) total += p.length;
        ByteArrayOutputStream bo = new ByteArrayOutputStream(total);
        for (byte[] p: parts) try { bo.write(p); } catch (IOException ignored) {}
        return bo.toByteArray();
    }

    private static boolean isActuallyAnnexB(byte[] buffer) {
        return isAnnexB(buffer) && !looksLikeAvcc(buffer);
    }

    private static boolean looksLikeAvcc(byte[] buffer) {
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

    // 拆 Annex-B stream 成「raw payload」（不含 start code），只用來判斷 IDR
    private static List<byte[]> splitAnnexBToRawSegments(byte[] annexb) {
        List<byte[]> out = new ArrayList<>();
        int n = annexb.length, i = 0;
        while (i + 3 < n) {
            int sc = (annexb[i]==0 && annexb[i+1]==0 && annexb[i+2]==1) ? 3 :
                    (i+3<n && annexb[i]==0 && annexb[i+1]==0 && annexb[i+2]==0 && annexb[i+3]==1) ? 4 : 0;
            if (sc==0) { i++; continue; }
            int payload = i + sc, j = payload;
            while (j + 3 < n) {
                if (annexb[j]==0 && annexb[j+1]==0 && (annexb[j+2]==1 || (j+3<n && annexb[j+2]==0 && annexb[j+3]==1))) break;
                j++;
            }
            int end = (j + 3 < n) ? j : n;
            if (payload < end) out.add(Arrays.copyOfRange(annexb, payload, end));
            i = end;
        }
        return out;
    }

    private static int nalTypeWithStartCode(byte[] nalWithSc) {
        int i = (nalWithSc[2]==1) ? 3 : 4;
        return nalWithSc.length > i ? (nalWithSc[i] & 0x1F) : -1;
    }

    private static byte[] buildAnnexBAu(ByteBuffer frameBuf, @Nullable ByteBuffer configBuf) {
        try {
            // 取出本幀位元組
            byte[] frameBytes = new byte[frameBuf.remaining()];
            frameBuf.get(frameBytes);

            // 若本幀是 AVCC，先轉 Annex-B；Annex-B 就直接用原 bytes
            byte[] annexbFrame = isActuallyAnnexB(frameBytes)
                    ? frameBytes
                    : joinBytes(convertAvccToAnnexB(frameBytes)); // 每顆 NAL 皆含 00 00 00 01

            // 掃描本幀是否包含 IDR
            boolean hasIdr = false;
            for (byte[] seg : splitAnnexBToRawSegments(annexbFrame)) {
                int t = seg[0] & 0x1F;
                if (t == 5) { hasIdr = true; break; }
            }

            ByteArrayOutputStream out = new ByteArrayOutputStream();

            // 若是 keyframe 且有 CSD，從 CSD 取「Annex-B 的 SPS/PPS（各自含 start code）」前置
            if (hasIdr && configBuf != null && configBuf.hasRemaining()) {
                for (byte[] nalWithSc : extractAnnexBNalsFromConfig(configBuf.slice())) {
                    int t = nalTypeWithStartCode(nalWithSc);
                    if (t == 7 || t == 8) out.write(nalWithSc); // 直接寫入 Annex-B 的 SPS/PPS
                }
            }

            // 再把本幀 Annex-B 原樣寫入（不要移除任何 slice；SPS/PPS 即使重複也沒關係）
            out.write(annexbFrame);

            return out.toByteArray();
        } catch (Exception e) {
            Log.e(TAG, "buildAnnexBAu failed", e);
            return new byte[0];
        }
    }

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
        final long T = Math.round(1_000_000_000.0 / frameRate);
        // 建立「兩個時鐘」的對齊點
        final long baseUpMs = SystemClock.uptimeMillis();
        final long baseErNs = SystemClock.elapsedRealtimeNanos();

        Runnable frameRunnable = new Runnable() {
            long nextErNs; // 以 elapsedRealtimeNanos 為基準的下一個理想節點
            private boolean initialized = false;

            @Override
            public void run() {
                if (!isRunningFrameLoop) return;

                if (!initialized) {
                    try {
                        // ✅ 在 encoderThread 上 makeCurrent 並建立 shader/program
                        windowSurface.makeCurrentAndInitGLObjects();
                        initialized = true;
                        Log.d(TAG, "GL context initialized and program created");

                        long nowEr = SystemClock.elapsedRealtimeNanos();
                        nextErNs = nowEr + T;
                        long targetUpMs = baseUpMs + (nextErNs - baseErNs) / 1_000_000L;
                        encoderHandler.postAtTime(this, targetUpMs); // ← 絕對時間（uptime）對齊
                        return;
                    } catch (Exception e) {
                        Log.e(TAG, "GL init error", e);
                        return;
                    }
                }

                // 執行繪製
                try {
                    surfaceTexture.updateTexImage();
                    windowSurface.drawFrame(surfaceTexture);
                    windowSurface.swapBuffers();
                } catch (Exception e) {
                    Log.e(TAG, "GL frame loop error", e);
                }

                // 排程下一幀
                nextErNs += T;
                long nowEr = SystemClock.elapsedRealtimeNanos();
                if (nowEr > nextErNs) {
                    long behind = nowEr - nextErNs;
                    long missed = 1 + (behind / T);
                    nextErNs += missed * T;
                    Log.d(TAG, "Dropped, catch up " + missed + " intervals");
                }

                long targetUpMs = baseUpMs + (nextErNs - baseErNs) / 1_000_000L;
                encoderHandler.postAtTime(this, targetUpMs); // ← 絕對排程，不會累積
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
                // 先用 offset/size 縮出有效視窗
                if (encodedData == null) {
                    return;
                }
                encodedData.position(bufferInfo.offset);
                encodedData.limit(bufferInfo.offset + bufferInfo.size);

                // 1) CONFIG buffer：保存 exact-size 副本（避免尾端垃圾/容量過大）
                if ((bufferInfo.flags & MediaCodec.BUFFER_FLAG_CODEC_CONFIG) != 0) {
                    if (bufferInfo.size > 0) {
                        // 只分配剛好的大小
                        h26xConfig = ByteBuffer.allocateDirect(bufferInfo.size);
                        // 拷貝「目前 position..limit」的有效資料
                        h26xConfig.put(encodedData.slice());
                        h26xConfig.rewind();
                        Log.d(TAG, "Saved CONFIG (CSD) size=" + h26xConfig.capacity());
                    }
                    mediaCodec.releaseOutputBuffer(outputBufferIndex, false);
                    return;
                }

                boolean isKey = (bufferInfo.flags & MediaCodec.BUFFER_FLAG_KEY_FRAME) != 0;

                // 2) 把「本幀」轉成 Annex-B 的「整個 AU」
                byte[] auBytes = buildAnnexBAu(encodedData.slice(), isKey ? h26xConfig : null);

                // 3) 一次送整個 AU 給 uvgRTP（內部走 h26x::push_media_frame）
                NativeBridge.sendRtpFrame(auBytes);
                mediaCodec.releaseOutputBuffer(outputBufferIndex, false);
            }
        } catch (IllegalStateException e) {
            Log.e(TAG, "Encoder loop terminated due to codec stop", e);
        } finally {
            if (isEncoding) {
                encoderHandler.post(this::encodeNextFrame);
            }
        }
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