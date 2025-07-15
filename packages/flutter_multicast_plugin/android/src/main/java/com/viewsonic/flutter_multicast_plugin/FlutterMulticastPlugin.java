package com.viewsonic.flutter_multicast_plugin;

import android.app.Activity;
import android.content.Intent;
import android.content.Context;
import android.graphics.SurfaceTexture;
import android.media.projection.MediaProjectionManager;
import android.util.Log;
import android.view.Surface;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import android.content.pm.PackageManager;
import android.Manifest;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.view.TextureRegistry;


import java.util.List;
import java.util.Map;

/** FlutterMulticastPlugin */
@Keep
public class FlutterMulticastPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener, SurfaceCallbackHandler.SurfaceLifecycleListener {
    private MethodChannel channel;

    private TextureRegistry textureRegistry;

    private Surface surface;
    private Activity activity;
    private SurfaceCallbackHandler surfaceHandler;
    private static final int REQUEST_CODE_MEDIA_PROJECTION = 1001;

    private static final String TAG = "FlutterMulticastPlugin";

    static {
        try {
          System.loadLibrary("gstreamer_android");
          System.loadLibrary("multicast_android");
          Log.d(TAG, "Native libraries loaded successfully");
        } catch (UnsatisfiedLinkError e) {
          Log.e(TAG, "Failed to load native library", e);
          throw e;
        }
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_multicast_plugin");
        channel.setMethodCallHandler(this);

        textureRegistry = flutterPluginBinding.getTextureRegistry();

        // 使用反射來初始化 GStreamer，避免編譯時依賴
        initializeGStreamerIfAvailable(flutterPluginBinding.getApplicationContext());
    }

    private void initializeGStreamerIfAvailable(android.content.Context context) {
        try {
            Class<?> gstreamerClass = Class.forName("org.freedesktop.gstreamer.GStreamer");
            java.lang.reflect.Method initMethod = gstreamerClass.getMethod("init", android.content.Context.class);
            initMethod.invoke(null, context);
            Log.d(TAG, "GStreamer initialized successfully via reflection");
        } catch (ClassNotFoundException e) {
            Log.w(TAG, "GStreamer Java class not found, will initialize in native layer");
        } catch (Exception e) {
            Log.e(TAG, "Failed to initialize GStreamer via reflection", e);
        }
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "startRtpStream": {
                String multicastIp = call.argument("ip");
                Integer videoPort = call.argument("videoPort");
                Integer audioPort = call.argument("audioPort");
                Integer ssrc = call.argument("ssrc");
                byte[] key = call.argument("key");
                byte[] salt = call.argument("salt");

                if (multicastIp == null || videoPort == null || audioPort == null || key == null || salt == null || ssrc == null) {
                    result.error("MISSING_ARGUMENT", "One or more arguments are missing or null", null);
                    return;
                }

                List<String> localIps = NetworkUtils.getAllLocalIPv4s();
                String[] ipArray = localIps.toArray(new String[0]);
                boolean success = NativeBridge.startRtpStream(ipArray, multicastIp, videoPort, audioPort, key, salt, ssrc);
                result.success(success);
                break;
            }
            case "getStreamRoc": {
                try {
                    // 調用 native 方法
                    Map<String, Object> rocData = NativeBridge.getStreamRoc();

                    if (rocData != null && !rocData.isEmpty()) {
                        result.success(rocData);
                    } else {
                        result.error("NO_STREAMS", "No streams available", null);
                    }
                } catch (Exception e) {
                    result.error("ROC_ERROR", "Failed to get ROC data", e.getMessage());
                }
                break;
            }
            case "stopRtpStream": {
                NativeBridge.stopRtpStream();
                result.success(null);
                break;
            }
            case "startCapture": {
                if (ContextCompat.checkSelfPermission(activity, Manifest.permission.RECORD_AUDIO)
                        != PackageManager.PERMISSION_GRANTED) {
                    result.error("PERMISSION_DENIED", "Audio recording permission required for system audio capture", null);
                    return;
                }

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
                String multicastIp = call.argument("ip");
                Integer videoPort = call.argument("videoPort");
                Integer audioPort = call.argument("audioPort");
                Integer ssrc = call.argument("ssrc");
                byte[] key = call.argument("key");
                byte[] salt = call.argument("salt");
                Number videorocNumber = call.argument("videoRoc");
                Number audioRocNumber = call.argument("audioRoc");

                if (multicastIp == null || videoPort == null || audioPort == null || key == null || salt == null || ssrc == null || videorocNumber == null || audioRocNumber == null) {
                    result.error("MISSING_ARGUMENT", "One or more arguments are missing or null", null);
                    return;
                }

                long videoRoc = videorocNumber.longValue();
                long audioRoc = audioRocNumber.longValue();

                TextureRegistry.SurfaceProducer producer = textureRegistry.createSurfaceProducer();
                producer.setSize(1920, 1080);
                surfaceHandler = new SurfaceCallbackHandler(producer, this);
                Surface surface = surfaceHandler.getSurface();
                long textureId = surfaceHandler.getTextureId();

                List<String> localIps = NetworkUtils.getAllLocalIPv4s();
                String[] ipArray = localIps.toArray(new String[0]);
                NativeBridge.receiveStart(surface, ipArray, multicastIp, videoPort, audioPort, key, salt, ssrc, videoRoc, audioRoc);

                surfaceHandler.setActive(true);

                result.success(textureId);
                break;
            }
            case "receiveStop": {
                if (surfaceHandler != null) {
                    surfaceHandler.setActive(false);
                }

                NativeBridge.receiveStop();

                if (surfaceHandler != null) {
                    surfaceHandler.release();
                    surfaceHandler = null;
                }

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

    @Override
    public void onSurfaceReady(Surface surface) {
        Log.d(TAG, "Surface ready - reinitializing video pipeline");
        NativeBridge.reinitializeVideoPipeline(surface);
    }

    @Override
    public void onSurfaceDestroyed() {
        Log.d(TAG, "Surface destroyed - pausing video pipeline");
        if (surfaceHandler != null && surfaceHandler.isActive()) {
            NativeBridge.pauseVideoPipeline();
        }
    }
}
