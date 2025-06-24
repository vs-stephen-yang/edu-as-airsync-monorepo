package com.viewsonic.flutter_multicast_plugin;

import android.app.Activity;
import android.content.Intent;
import android.content.Context;
import android.graphics.SurfaceTexture;
import android.media.projection.MediaProjectionManager;
import android.util.Log;
import android.view.Surface;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;

import org.freedesktop.gstreamer.GStreamer;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.view.TextureRegistry;

/** FlutterMulticastPlugin */
public class FlutterMulticastPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
    private MethodChannel channel;

    private TextureRegistry textureRegistry;

    private Surface surface;
    private TextureRegistry.SurfaceTextureEntry entry;
    private Activity activity;
    private static final int REQUEST_CODE_MEDIA_PROJECTION = 1001;

    private static final String TAG = "FlutterMulticastPlugin";

    static {
        System.loadLibrary("gstreamer_android");
        System.loadLibrary("uvgrtp_android");
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_multicast_plugin");
        channel.setMethodCallHandler(this);

        textureRegistry = flutterPluginBinding.getTextureRegistry();
        try {
            GStreamer.init(flutterPluginBinding.getApplicationContext());
        } catch (Exception e) {
            Log.e(TAG, e.getMessage());
        }
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "startRtpStream": {
                String ip = call.argument("ip");
                Integer port = call.argument("port");
                Integer ssrc = call.argument("ssrc");
                byte[] key = call.argument("key");
                byte[] salt = call.argument("salt");
                if (ip == null || port == null || key == null || salt == null || ssrc == null) {
                    result.error("MISSING_ARGUMENT", "One or more arguments are missing or null", null);
                    return;
                }
                boolean success = NativeBridge.startRtpStream(ip, port, key, salt, ssrc);
                result.success(success);
                break;
            }
            case "stopRtpStream": {
                NativeBridge.stopRtpStream();
                result.success(null);
                break;
            }
            case "startCapture": {
                if (activity != null) {
                    MediaProjectionManager projectionManager = (MediaProjectionManager) activity.getSystemService(Context.MEDIA_PROJECTION_SERVICE);
                    Intent captureIntent = projectionManager.createScreenCaptureIntent();
                    activity.startActivityForResult(captureIntent, REQUEST_CODE_MEDIA_PROJECTION);
                    result.success(null);
                } else {
                    result.error("NO_ACTIVITY", "Activity is null", null);
                }
                break;
            }
            case "stopCapture": {
                if (activity != null) {
                    activity.stopService(new Intent(activity, ScreenCaptureService.class));
                    result.success(null);
                } else {
                    result.error("NO_ACTIVITY", "Activity is null", null);
                }
                break;
            }
            case "receiveStart": {
                String ip = call.argument("ip");
                Integer port = call.argument("port");
                Integer ssrc = call.argument("ssrc");
                byte[] key = call.argument("key");
                byte[] salt = call.argument("salt");
                Number rocNumber = call.argument("roc");

                if (ip == null || port == null || key == null || salt == null || ssrc == null || rocNumber == null) {
                    result.error("MISSING_ARGUMENT", "One or more arguments are missing or null", null);
                    return;
                }

                long roc = rocNumber.longValue();

                entry = textureRegistry.createSurfaceTexture();
                SurfaceTexture surfaceTexture = entry.surfaceTexture();
                surfaceTexture.setDefaultBufferSize(1920, 1080);
                long textureId = entry.id();
                surface = new Surface(surfaceTexture);

                NativeBridge.receiveStart(surface, ip, port, key, salt, ssrc, roc);
                result.success(textureId);
                break;
            }
            case "receiveStop": {
                NativeBridge.receiveStop();
                result.success(null);
                break;
            }
            default:
                result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        this.activity = binding.getActivity();
        binding.addActivityResultListener(this);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        this.activity = null;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        this.activity = binding.getActivity();
        binding.addActivityResultListener(this);
    }

    @Override
    public void onDetachedFromActivity() {
        this.activity = null;
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_CODE_MEDIA_PROJECTION && resultCode == Activity.RESULT_OK) {
            Intent serviceIntent = new Intent(activity, ScreenCaptureService.class);
            serviceIntent.putExtra("resultCode", resultCode);
            serviceIntent.putExtra("data", data);
            ContextCompat.startForegroundService(activity, serviceIntent);
            return true;
        }
        return false;
    }
}
