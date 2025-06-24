package com.viewsonic.flutter_multicast_plugin;

public class NativeBridge {
    static {
        System.loadLibrary("uvgrtp_android");
    }

    public static native boolean startRtpStream(String ip, int port, byte[] key, byte[] salt, int ssrc);
    public static native void sendRtpFrame(byte[] data);
    public static native void stopRtpStream();
    public static native void receiveStart(Object surface, String ip, int port, byte[] key, byte[] salt, int ssrc, long roc);
    public static native void receiveStop();
}