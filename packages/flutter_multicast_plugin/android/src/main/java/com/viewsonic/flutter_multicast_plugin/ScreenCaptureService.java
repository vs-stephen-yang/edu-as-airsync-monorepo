package com.viewsonic.flutter_multicast_plugin;

import static android.media.MediaCodecInfo.EncoderCapabilities.BITRATE_MODE_VBR;

import android.app.Activity;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.hardware.display.DisplayManager;
import android.hardware.display.VirtualDisplay;
import android.media.AudioAttributes;
import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioPlaybackCaptureConfiguration;
import android.media.AudioRecord;
import android.media.MediaCodec;
import android.media.MediaCodecInfo;
import android.media.MediaFormat;
import android.media.projection.MediaProjection;
import android.media.projection.MediaProjectionManager;
import android.os.Build;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.IBinder;
import android.os.SystemClock;
import android.util.Log;
import android.view.Surface;
import android.opengl.GLES20;
import android.graphics.SurfaceTexture;
import android.media.AudioManager;
import android.media.AudioAttributes;
import android.media.AudioFormat;
import android.media.AudioPlaybackCaptureConfiguration;
import android.media.AudioRecord;

import androidx.annotation.Keep;
import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.atomic.AtomicLong;

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
    private EGLCore eglCore;
    private WindowSurface windowSurface;

    private int width = 1280;
    private int height = 720;
    private int dpi = 320;

    private long lastDrawNs = -1;

    private volatile boolean isEncoding = false;

    private MediaCodec audioEncoder;
    private AudioPlaybackCaptureConfiguration audioConfig;
    private AudioRecord audioRecord;
    private Thread audioCaptureThread;
    private volatile boolean isCapturingAudio = false;
    private volatile boolean isAudioEncoding = false;
    private HandlerThread audioEncoderThread;
    private Handler audioEncoderHandler;

    // OPUS 編碼參數
    private static final int OPUS_SAMPLE_RATE = 48000;
    private static final int OPUS_CHANNEL_COUNT = 2; // 立體聲
    private static final int OPUS_BITRATE = 128000;

    private int pcmLogCount = 0;

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

        audioEncoderThread = new HandlerThread("AudioEncoderThread");
        audioEncoderThread.start();
        audioEncoderHandler = new Handler(audioEncoderThread.getLooper());
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        int resultCode = intent.getIntExtra("resultCode", Activity.RESULT_CANCELED);
        Intent data = intent.getParcelableExtra("data");

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

            setupAudioCapture();
        } catch (IOException e) {
            Log.e(TAG, "Failed to set up codec", e);
            stopSelf();
        } catch (Exception e) {
            Log.e(TAG, "Failed to set up capture", e);
            stopSelf();
        }

        return START_NOT_STICKY;
    }

    private void setupMediaCodec() throws IOException {
        MediaFormat format = MediaFormat.createVideoFormat("video/avc", width, height);
        format.setInteger(MediaFormat.KEY_COLOR_FORMAT, MediaCodecInfo.CodecCapabilities.COLOR_FormatSurface);
        format.setInteger(MediaFormat.KEY_BITRATE_MODE, BITRATE_MODE_VBR);
        format.setInteger(MediaFormat.KEY_BIT_RATE, 4000_000);
        format.setInteger("max-bitrate", 8_000_000); // Peak
        format.setInteger(MediaFormat.KEY_FRAME_RATE, 30);
        format.setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, 1);

        mediaCodec = MediaCodec.createEncoderByType("video/avc");
        mediaCodec.configure(format, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE);
        encoderInputSurface = mediaCodec.createInputSurface();
        mediaCodec.start();
        startEncoding();
    }

    private void setupEGL() {
        int[] textures = new int[1];
        GLES20.glGenTextures(1, textures, 0);
        int textureId = textures[0];

        eglCore = new EGLCore();
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

                // ✅ 基於啟動時間計算理想的幀時間，避免累積誤差
                long idealFrameTime = startTimeMs + frameCount * frameIntervalMs;
                long nextFrameTime = startTimeMs + (frameCount + 1) * frameIntervalMs;

                // 執行繪製
                try {
                    surfaceTexture.updateTexImage();
                    windowSurface.drawFrame(surfaceTexture);
                    windowSurface.swapBuffers();

                    long nowNs = System.nanoTime();
                    if (lastDrawNs > 0) {
                        long deltaNs = nowNs - lastDrawNs;
                        float fps = 1_000_000_000f / deltaNs;
//                        Log.d(TAG, "[FrameLoop] delta = " + deltaNs + "ns, FPS = " + fps);
                    }
                    lastDrawNs = nowNs;

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

//                    StringBuilder sb = new StringBuilder("NAL prefix bytes: ");
//                    int printLen = Math.min(nal.length, 5);
//                    for (int i = 0; i < printLen; i++) {
//                        sb.append(String.format("%02X ", nal[i]));
//                    }
//                    Log.d(TAG, sb.toString());

                    int nalUnitType = nal[startCodeLength] & 0x1F;
//                    Log.d(TAG, "NAL startCodeLength = " + startCodeLength + ", NAL Unit Type: " + nalUnitType);

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

//                            Log.d(TAG, "STAP-A : " + Arrays.toString(stapA));
//                            Log.d(TAG, "sps.length = " + sps.length + ", pps.length = " + pps.length);

                            NativeBridge.sendRtpFrame(stapA);
                        }
                        Log.d(TAG, "Send IDR");
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
//            Log.d(TAG, "Encoded buffer is in Annex B format");
            return splitAnnexBNalus(buffer);
        }
//        Log.d(TAG, "Encoded buffer is in AVCC format, converting to Annex B...");
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

    private void setupAudioCapture() throws Exception {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            Log.w(TAG, "System audio capture requires Android 10+");
            return;
        }

        try {
            // 1. 設置 OPUS 編碼器
            setupOpusEncoder();

            // 2. 設置音訊截取 (使用 MediaProjection，不需要 RECORD_AUDIO 權限)
            audioConfig = new AudioPlaybackCaptureConfiguration.Builder(mediaProjection)
                    .addMatchingUsage(AudioAttributes.USAGE_MEDIA)           // 媒體播放
                    .addMatchingUsage(AudioAttributes.USAGE_GAME)            // 遊戲音效
                    .addMatchingUsage(AudioAttributes.USAGE_UNKNOWN)         // 其他音訊
                    .build();

            // 3. 建立 AudioRecord (使用 AudioPlaybackCaptureConfiguration，不需要麥克風權限)
            int bufferSize = AudioRecord.getMinBufferSize(
                    OPUS_SAMPLE_RATE,
                    AudioFormat.CHANNEL_IN_STEREO,
                    AudioFormat.ENCODING_PCM_16BIT
            );
            bufferSize = Math.max(bufferSize, OPUS_SAMPLE_RATE * 2);

            audioRecord = new AudioRecord.Builder()
                    .setAudioPlaybackCaptureConfig(audioConfig)  // 關鍵：使用 AudioPlaybackCaptureConfig
                    .setAudioFormat(new AudioFormat.Builder()
                            .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                            .setSampleRate(OPUS_SAMPLE_RATE)
                            .setChannelMask(AudioFormat.CHANNEL_IN_MONO)
                            .build())
                    .setBufferSizeInBytes(bufferSize)
                    .build();

            // 檢查 AudioRecord 狀態
            Log.i(TAG, "AudioRecord state: " + audioRecord.getState());
            Log.i(TAG, "AudioRecord recording state: " + audioRecord.getRecordingState());
            Log.i(TAG, "AudioRecord sample rate: " + audioRecord.getSampleRate());
            Log.i(TAG, "AudioRecord channel count: " + audioRecord.getChannelCount());
            Log.i(TAG, "AudioRecord format: " + audioRecord.getFormat());

            // 檢查系統音量
            AudioManager audioManager = (AudioManager) getSystemService(AUDIO_SERVICE);
            Log.i(TAG, "Media volume: " + audioManager.getStreamVolume(AudioManager.STREAM_MUSIC) +
                    "/" + audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC));

            if (audioRecord.getState() != AudioRecord.STATE_INITIALIZED) {
                throw new Exception("Failed to initialize AudioRecord for system audio");
            }

            // 4. 開始錄製
            audioRecord.startRecording();
            if (audioRecord.getRecordingState() != AudioRecord.RECORDSTATE_RECORDING) {
                throw new Exception("Failed to start recording system audio");
            }

            isCapturingAudio = true;

            // 5. 啟動音訊截取執行緒
            audioCaptureThread = new Thread(this::audioLoopCapture);
            audioCaptureThread.start();

            Log.i(TAG, "System audio capture started successfully");

        } catch (Exception e) {
            Log.e(TAG, "Failed to setup audio capture: " + e.getMessage());
            // 拋出異常讓上層知道音訊設定失敗
            throw new Exception("Audio setup failed: " + e.getMessage());
        }
    }

    private void setupOpusEncoder() throws IOException {
        // 建立 OPUS 編碼格式
        MediaFormat audioFormat = new MediaFormat();
        audioFormat.setString(MediaFormat.KEY_MIME, MediaFormat.MIMETYPE_AUDIO_OPUS);
        audioFormat.setInteger(MediaFormat.KEY_SAMPLE_RATE, OPUS_SAMPLE_RATE);
        audioFormat.setInteger(MediaFormat.KEY_CHANNEL_COUNT, 1);
        audioFormat.setInteger(MediaFormat.KEY_BIT_RATE, OPUS_BITRATE);
        audioFormat.setInteger(MediaFormat.KEY_COMPLEXITY, 5);  // OPUS 複雜度
        audioFormat.setInteger("frame-duration", 20);          // 20ms frame

        audioEncoder = MediaCodec.createEncoderByType(MediaFormat.MIMETYPE_AUDIO_OPUS);
        audioEncoder.configure(audioFormat, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE);
        audioEncoder.start();

        Log.i(TAG, "Creating OPUS encoder with format: " + audioFormat);

        isAudioEncoding = true;

        // 啟動編碼執行緒
        audioEncoderHandler.post(this::opusEncodingLoop);

        Log.i(TAG, "OPUS encoder started: " + OPUS_SAMPLE_RATE + "Hz, " +
                OPUS_CHANNEL_COUNT + " channels, " + OPUS_BITRATE + " bps");
    }

    private void audioLoopCapture() {
        byte[] buffer = new byte[1920]; // 立體聲 PCM buffer

        Log.i(TAG, "Audio capture loop started");
        int readCount = 0;
        int zeroCount = 0;
        while (isCapturingAudio && audioRecord != null) {
            try {
                int bytesRead = audioRecord.read(buffer, 0, buffer.length);
                readCount++;

                if (bytesRead > 0) {
                    // 檢查是否全為 0
                    boolean allZero = true;
                    int maxValue = 0;
                    int minValue = 0;

                    for (int i = 0; i < bytesRead; i++) {
                        int value = buffer[i] & 0xFF;
                        if (value != 0) {
                            allZero = false;
                        }
                        if (value > maxValue) maxValue = value;
                        if (value < minValue) minValue = value;
                    }

                    if (allZero) {
                        zeroCount++;
                    }

                    // 每 100 次讀取報告一次
                    if (readCount % 100 == 0) {
                        Log.i(TAG, String.format("Read #%d: %d bytes, all-zero: %d/%d (%.1f%%), max: %d, min: %d",
                                readCount, bytesRead, zeroCount, readCount,
                                (zeroCount * 100.0 / readCount), maxValue, minValue));

                        // 印出前 16 個 bytes
                        StringBuilder hex = new StringBuilder("Sample data: ");
                        for (int i = 0; i < Math.min(16, bytesRead); i++) {
                            hex.append(String.format("%02X ", buffer[i] & 0xFF));
                        }
                        Log.d(TAG, hex.toString());
                    }

                    feedToOpusEncoder(buffer, bytesRead);

                } else if (bytesRead < 0) {
                    Log.w(TAG, "AudioRecord read error: " + bytesRead);
                    break;
                }

            } catch (Exception e) {
                Log.e(TAG, "Error in audio capture loop", e);
                break;
            }
        }
    }

    private void feedToOpusEncoder(byte[] pcmData, int length) {
        if (!isAudioEncoding || audioEncoder == null) {
            return;
        }

        // 檢查 PCM 數據是否全為 0 (靜音)
        boolean hasAudio = false;
        for (int i = 0; i < length; i++) {
            if (pcmData[i] != 0) {
                hasAudio = true;
                break;
            }
        }

        Log.d(TAG, "PCM data has audio: " + hasAudio + ", length: " + length);

        // 每 100 個封包印一次前幾個 bytes
        if (++pcmLogCount % 100 == 0) {
            StringBuilder sb = new StringBuilder("PCM sample: ");
            for (int i = 0; i < Math.min(16, length); i++) {
                sb.append(String.format("%02X ", pcmData[i] & 0xFF));
            }
            Log.d(TAG, sb.toString());
        }

        try {
            // 取得編碼器輸入 buffer
            int inputBufferIndex = audioEncoder.dequeueInputBuffer(0); // 非阻塞
            if (inputBufferIndex >= 0) {
                ByteBuffer inputBuffer = audioEncoder.getInputBuffer(inputBufferIndex);
                if (inputBuffer != null && inputBuffer.remaining() >= length) {
                    inputBuffer.clear();
                    inputBuffer.put(pcmData, 0, length);

                    // 送入編碼器
                    audioEncoder.queueInputBuffer(
                            inputBufferIndex,
                            0,
                            length,
                            System.nanoTime() / 1000,
                            0
                    );
                    Log.d(TAG, "Fed " + length + " bytes to OPUS encoder, buffer index: " + inputBufferIndex);
                } else {
                    Log.w(TAG, "Input buffer too small or null: remaining=" +
                            (inputBuffer != null ? inputBuffer.remaining() : "null") + ", need=" + length);
                }
            }
        } catch (Exception e) {
            Log.e(TAG, "Error feeding PCM to OPUS encoder", e);
        }
    }

    private void opusEncodingLoop() {
        Log.i(TAG, "OPUS encoding loop started");
        int encodedPackets = 0;

        while (isAudioEncoding && audioEncoder != null) {
            try {
                MediaCodec.BufferInfo bufferInfo = new MediaCodec.BufferInfo();
                int outputBufferIndex = audioEncoder.dequeueOutputBuffer(bufferInfo, 10000);

                if (outputBufferIndex >= 0) {
                    ByteBuffer encodedData = audioEncoder.getOutputBuffer(outputBufferIndex);

                    if (encodedData != null && bufferInfo.size > 0) {
                        // 取得 OPUS 編碼後的數據
                        byte[] opusData = new byte[bufferInfo.size];
                        encodedData.position(bufferInfo.offset);
                        encodedData.limit(bufferInfo.offset + bufferInfo.size);
                        encodedData.get(opusData);

                        // 發送 OPUS 數據到 native layer 進行 RTP 傳輸
                        NativeBridge.sendAudioRtpFrame(opusData);

                        Log.i(TAG, "OPUS packet: " + opusData.length + " bytes, " +
                                "timestamp: " + bufferInfo.presentationTimeUs);

                        encodedPackets++;
                        Log.d(TAG, "OPUS packet #" + encodedPackets + ": " + opusData.length + " bytes");

                        if (opusData.length >= 8) {
                            StringBuilder hex = new StringBuilder("OPUS header: ");
                            for (int i = 0; i < Math.min(8, opusData.length); i++) {
                                hex.append(String.format("%02X ", opusData[i] & 0xFF));
                            }
                            Log.d(TAG, hex.toString());
                        }
                    }

                    audioEncoder.releaseOutputBuffer(outputBufferIndex, false);
                } else if (outputBufferIndex == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) {
                    MediaFormat newFormat = audioEncoder.getOutputFormat();
                    Log.i(TAG, "OPUS encoder format changed: " + newFormat);
                }


            } catch (IllegalStateException e) {
                Log.e(TAG, "OPUS encoding loop terminated", e);
                break;
            } catch (Exception e) {
                Log.e(TAG, "Error in OPUS encoding loop", e);
                break;
            }
        }

        Log.i(TAG, "OPUS encoding loop ended");
    }

    private void stopAudioCapture() {
        Log.i(TAG, "Stopping audio capture and encoding...");

        isCapturingAudio = false;
        isAudioEncoding = false;

        // 等待音訊截取執行緒結束
        if (audioCaptureThread != null) {
            try {
                audioCaptureThread.join(1000);
                if (audioCaptureThread.isAlive()) {
                    audioCaptureThread.interrupt();
                }
            } catch (InterruptedException e) {
                Log.w(TAG, "Audio capture thread join interrupted");
            }
            audioCaptureThread = null;
        }

        // 停止 AudioRecord
        if (audioRecord != null) {
            try {
                if (audioRecord.getRecordingState() == AudioRecord.RECORDSTATE_RECORDING) {
                    audioRecord.stop();
                }
                audioRecord.release();
            } catch (Exception e) {
                Log.w(TAG, "Error stopping AudioRecord", e);
            }
            audioRecord = null;
        }

        // 停止 OPUS 編碼器
        if (audioEncoder != null) {
            try {
                audioEncoder.stop();
                audioEncoder.release();
            } catch (Exception e) {
                Log.w(TAG, "Error stopping OPUS encoder", e);
            }
            audioEncoder = null;
        }

        Log.i(TAG, "Audio capture and encoding stopped");
    }

    @Override
    public void onDestroy() {
        Log.i(TAG, "Service destroying - stopping all capture...");

        stopAudioCapture();

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

        if (audioEncoderHandler != null) {
            audioEncoderHandler.removeCallbacksAndMessages(null);
        }

        if (audioEncoderThread != null) {
            audioEncoderThread.quitSafely();
            try {
                audioEncoderThread.join();
            } catch (InterruptedException e) {
                Log.w(TAG, "Audio encoder thread join interrupted");
            }
            audioEncoderThread = null;
            audioEncoderHandler = null;
        }

        super.onDestroy();
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}