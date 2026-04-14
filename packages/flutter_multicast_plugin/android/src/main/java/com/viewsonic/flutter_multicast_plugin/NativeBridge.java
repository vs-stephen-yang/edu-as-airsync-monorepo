package com.viewsonic.flutter_multicast_plugin;

import androidx.annotation.Keep;

import java.util.Map;

@Keep
public class NativeBridge {
    private final NativeListener listener_;

    public NativeBridge(NativeListener listener_) {
        this.listener_ = listener_;
    }

    public native boolean startRtpStream(String[] localIps, String ip, int videoPort, int audioPort, byte[] key, byte[] salt, int ssrc);
    public native Map<String, Object> getStreamRoc();
    public static native void sendRtpFrame(byte[] data);
    public static native void sendAudioRtpFrame(byte[] data);
    public native void stopRtpStream();
    public native void receiveStart(Object surface, String[] localIps, String ip, int videoPort, int audioPort, byte[] key, byte[] salt, int ssrc, long videoRoc, long audioRoc);
    public native void receiveStop();
    public native void pauseVideoPipeline();
    public native void reinitializeVideoPipeline(Object surface);

    public void onNativeResolution(int width, int height) {
        if (listener_ != null) {
            listener_.onNativeResolution(width, height);
        }
    }
}