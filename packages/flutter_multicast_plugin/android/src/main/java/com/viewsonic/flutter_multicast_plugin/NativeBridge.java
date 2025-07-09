package com.viewsonic.flutter_multicast_plugin;

import androidx.annotation.Keep;

import java.util.Map;

@Keep
public class NativeBridge {
    static {
        System.loadLibrary("multicast_android");
    }

    public static native boolean startRtpStream(String[] localIps, String ip, int videoPort, int audioPort, byte[] key, byte[] salt, int ssrc);
    public static native Map<String, Object> getStreamRoc();
    public static native void sendRtpFrame(byte[] data);
    public static native void sendAudioRtpFrame(byte[] data);
    public static native void stopRtpStream();
    public static native void receiveStart(Object surface, String[] localIps, String ip, int videoPort, int audioPort, byte[] key, byte[] salt, int ssrc, long videoRoc, long audioRoc);
    public static native void receiveStop();
}