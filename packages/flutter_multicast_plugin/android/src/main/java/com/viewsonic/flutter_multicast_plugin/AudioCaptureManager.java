package com.viewsonic.flutter_multicast_plugin;


import android.media.AudioAttributes;
import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioPlaybackCaptureConfiguration;
import android.media.AudioRecord;
import android.media.MediaCodec;
import android.media.MediaFormat;
import android.media.projection.MediaProjection;
import android.content.Context;
import android.os.Build;
import android.os.Handler;
import android.os.HandlerThread;
import android.util.Log;

import androidx.annotation.Keep;

import java.io.IOException;
import java.nio.ByteBuffer;

@Keep
public class AudioCaptureManager {
    private static final String TAG = "AudioCaptureManager";
    private final Context context;
    private HandlerThread audioEncoderThread;
    private Handler audioEncoderHandler;

    private MediaCodec audioEncoder;
    private AudioRecord audioRecord;
    private Thread audioCaptureThread;
    private volatile boolean isCapturingAudio = false;
    private volatile boolean isAudioEncoding = false;

    // OPUS 編碼參數
    private static final int OPUS_SAMPLE_RATE = 48000;
    private static final int OPUS_CHANNEL_COUNT = 2; // 立體聲
    private static final int OPUS_BITRATE = 128000;

    public AudioCaptureManager(Context context) {
        this.context = context.getApplicationContext();
    }

    public void init(MediaProjection projection) throws Exception {
        // 原本 setupAudioCapture() 的內容搬到這裡
        audioEncoderThread = new HandlerThread("AudioEncoderThread");
        audioEncoderThread.start();
        audioEncoderHandler = new Handler(audioEncoderThread.getLooper());

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            Log.w(TAG, "System audio capture requires Android 10+");
            return;
        }

        try {
            // 1. 設置 OPUS 編碼器
            setupOpusEncoder();

            // 2. 設置音訊截取 (使用 MediaProjection，不需要 RECORD_AUDIO 權限)
            // 媒體播放
            // 遊戲音效
            // 其他音訊
            AudioPlaybackCaptureConfiguration audioConfig = new AudioPlaybackCaptureConfiguration.Builder(projection)
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
            Log.d(TAG, "AudioRecord state: " + audioRecord.getState());
            Log.d(TAG, "AudioRecord recording state: " + audioRecord.getRecordingState());
            Log.d(TAG, "AudioRecord sample rate: " + audioRecord.getSampleRate());
            Log.d(TAG, "AudioRecord channel count: " + audioRecord.getChannelCount());
            Log.d(TAG, "AudioRecord format: " + audioRecord.getFormat());

            // 檢查系統音量
            AudioManager audioManager = (AudioManager) context.getSystemService(Context.AUDIO_SERVICE);
            Log.d(TAG, "Media volume: " + audioManager.getStreamVolume(AudioManager.STREAM_MUSIC) +
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

            Log.d(TAG, "System audio capture started successfully");

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

        Log.d(TAG, "Creating OPUS encoder with format: " + audioFormat);

        isAudioEncoding = true;

        // 啟動編碼執行緒
        audioEncoderHandler.post(this::opusEncodingLoop);

        Log.d(TAG, "OPUS encoder started: " + OPUS_SAMPLE_RATE + "Hz, " +
                OPUS_CHANNEL_COUNT + " channels, " + OPUS_BITRATE + " bps");
    }

    private void audioLoopCapture() {
        byte[] buffer = new byte[1920]; // 立體聲 PCM buffer
        while (isCapturingAudio && audioRecord != null) {
            try {
                int bytesRead = audioRecord.read(buffer, 0, buffer.length);

                if (bytesRead > 0) {
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
    }

    public void stop() {
        Log.d(TAG, "Stopping audio capture and encoding...");

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
    }
}
