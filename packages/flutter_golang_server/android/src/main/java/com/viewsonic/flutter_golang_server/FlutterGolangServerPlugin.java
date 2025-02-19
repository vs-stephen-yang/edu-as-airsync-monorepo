package com.viewsonic.flutter_golang_server;

import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.FutureTask;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * FlutterGolangPlugin
 */
public class FlutterGolangServerPlugin implements FlutterPlugin, MethodCallHandler, IonSfuServerListener, WebtransportServerListener {
    /// The MethodChannel that will the communication between Flutter and native
    /// Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine
    /// and unregister it
    /// when the Flutter Engine is detached from the Activity
    private static final String TAG = "FlutterGolangPlugin";
    private final Handler handler_ = new Handler(Looper.getMainLooper());
    private MethodChannel channel;
    private IonSfuServer ionSfuServer_;

    private WebtransportServer webtransportServer_;
    private Map<String, Object> configuration;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_golang_server");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "initialize": {
                ionSfuServer_ = new IonSfuServer(this);
                ionSfuServer_.initialize();

                Map<String, Long> reply = new HashMap<>();
                result.success(reply);
                break;
            }
            case "start": {
                Map<String, Object> configuration = call.argument("configuration");
                if (configuration == null) {
                    result.error("InvalidArgument", "configuration is null", null);
                    return;
                }

                ionSfuServer_.start(configuration);

                Map<String, Long> reply = new HashMap<>();
                result.success(reply);
                break;
            }
            case "stop": {
                ionSfuServer_.stop();

                Map<String, Long> reply = new HashMap<>();
                result.success(reply);
                break;
            }
            case "createSignalChannel": {

                long channelId = ionSfuServer_.createSignalChannel();

                result.success(channelId);
                break;
            }
            case "closeSignalChannel": {
                int channelId = call.argument("channelId");

                ionSfuServer_.closeSignalChannel(channelId);

                Map<String, Long> reply = new HashMap<>();
                result.success(reply);
                break;
            }
            case "processSignalMessage": {
                int channelId = call.argument("channelId");
                String message = call.argument("message");

                ionSfuServer_.processSignalMessage(channelId, message);

                Map<String, Long> reply = new HashMap<>();
                result.success(reply);
                break;
            }

            case "startWebTransportServer": {
                webtransportServer_ = new WebtransportServer(this);
                configuration = call.argument("configuration");
                if (configuration == null) {
                    result.error("InvalidArgument", "configuration is null", null);
                }
                try {
                    webtransportServer_.start(configuration);
                    Log.d(TAG, "onMethodCall: startWebTransportServer success");
                    result.success(true);
                } catch (Exception e) {
                    Log.e(TAG, "onMethodCall: startWebTransportServer failed " + e);
                    result.error("start server", e.getMessage(), null);
                }
                break;
            }
            case "stopWebTransportServer": {
                assert (webtransportServer_ != null);
                webtransportServer_.stop();
                Log.d(TAG, "onMethodCall: stopWebTransportServer");
                result.success(true);
                break;
            }
            case "sendWebTransportMessage": {
                assert (webtransportServer_ != null);
                String connId = call.argument("connId");
                String message = call.argument("message");
                webtransportServer_.sendMessage(connId, message);
                Log.d(TAG, "onMethodCall: sendWebTransportMessage connId: " + connId + ", message: " + message);
                break;
            }
            case "updateWebTransportCertificate": {
                assert (webtransportServer_ != null);
                configuration = call.argument("configuration");
                if (configuration == null) {
                    result.error("InvalidArgument", "configuration is null", null);
                }
                webtransportServer_.updateCertificate(configuration);
                Log.d(TAG, "onMethodCall: updateWebTransportCertificate");
                break;
            }
            case "closeWebTransportConn": {
                assert (webtransportServer_ != null);
                String connId = call.argument("connId");
                webtransportServer_.closeConn(connId);
                Log.d(TAG, "onMethodCall: closeWebTransportConn connId: " + connId);
                break;
            }
            default:
                result.notImplemented();
                break;
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onError(String error, String msg) {
        Log.d(TAG, "FlutterGolangPlugin::onError(): '" + error + "' " + msg);

        post(() -> {
            Map<String, Object> arguments = new HashMap<>();
            arguments.put("error", error);
            arguments.put("msg", msg);

            channel.invokeMethod("onError", arguments);
        });
    }

    @Override
    public void onSignalMessage(long channelId, String message) {
        Log.d(TAG, "FlutterGolangPlugin::onSignalMessage() " + channelId + " " + message);

        post(() -> {
            Map<String, Object> arguments = new HashMap<>();
            arguments.put("channelId", channelId);
            arguments.put("message", message);

            channel.invokeMethod("onSignalMessage", arguments);
        });
    }

    @Override
    public void onIceConnectionState(long channelId, long state) {
        Log.d(TAG, "FlutterGolangPlugin::onIceConnectionState() " + channelId + " " + state);

        post(() -> {
            Map<String, Object> arguments = new HashMap<>();
            arguments.put("channelId", channelId);
            arguments.put("state", state);

            channel.invokeMethod("onIceConnectionState", arguments);
        });
    }

    private boolean isOnPlatformThread() {
        return Looper.getMainLooper() == Looper.myLooper();
    }

    // make sure that the task runs on the platform thread
    private <T> T post(Callable<T> c) throws java.lang.Exception {
        if (isOnPlatformThread()) {
            return c.call();
        }

        // Run the task on the platform thread
        FutureTask<T> task = new FutureTask<T>(c);
        handler_.post(task);

        // block until the task is done
        return task.get();
    }

    // make sure that the task runs on the platform thread
    private void post(Runnable r) {
        if (isOnPlatformThread()) {
            r.run();
            return;
        }

        // Run the task on the platform thread
        handler_.post(r);
    }

    @Override
    public void onMessage(String connId, String message) {
        Log.d(TAG, "FlutterWebTransport::onMessage() " + connId + " " + message);

        post(() -> {
            Map<String, Object> arguments = new HashMap<>();
            arguments.put("connId", connId);
            arguments.put("message", message);

            channel.invokeMethod("onMessage", arguments);
        });
    }

    @Override
    public void onClose(String connId) {
        Log.d(TAG, "FlutterWebTransport::onClose() " + connId);

        post(() -> {
            Map<String, Object> arguments = new HashMap<>();
            arguments.put("connId", connId);

            channel.invokeMethod("onClose", arguments);
        });
    }

    @Override
    public void onConnect(String connId, String queryStr, String clientIp) {
        Log.d(TAG, "FlutterWebTransport::onConnect() " + connId + ", query: " + queryStr + ", clientIp: " + clientIp);

        post(() -> {
            Map<String, Object> arguments = new HashMap<>();
            arguments.put("connId", connId);
            arguments.put("queryStr", queryStr);
            arguments.put("clientIp", clientIp);

            channel.invokeMethod("onConnect", arguments);
        });
    }

    @Override
    public void onError(String connId, Exception e) {
        Log.d(TAG, "FlutterWebTransport::onError() " + connId + "error: " + e.toString());

        post(() -> {
            Map<String, Object> arguments = new HashMap<>();
            arguments.put("connId", connId);
            arguments.put("error", e.toString());

            channel.invokeMethod("onError", arguments);
        });
    }
}
