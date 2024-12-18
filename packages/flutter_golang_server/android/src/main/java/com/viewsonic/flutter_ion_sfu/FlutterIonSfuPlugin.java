package com.viewsonic.flutter_ion_sfu;

import androidx.annotation.NonNull;

import android.util.Log;
import android.os.Handler;
import android.os.Looper;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.FutureTask;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** FlutterIonSfuPlugin */
public class FlutterIonSfuPlugin implements FlutterPlugin, MethodCallHandler, IonSfuServerListener {
  /// The MethodChannel that will the communication between Flutter and native
  /// Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine
  /// and unregister it
  /// when the Flutter Engine is detached from the Activity
  private static final String TAG = "FlutterIonSfuPlugin";
  private MethodChannel channel;
  private Handler handler_ = new Handler(Looper.getMainLooper());
  private IonSfuServer ionSfuServer_;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_ion_sfu");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("initialize")) {
      ionSfuServer_ = new IonSfuServer(this);
      ionSfuServer_.initialize();

      Map<String, Long> reply = new HashMap<>();
      result.success(reply);
    } else if (call.method.equals("start")) {
      Map<String, Object> configuration = call.argument("configuration");
      if (configuration == null) {
        result.error("InvalidArgument", "configuration is null", null);
        return;
      }

      ionSfuServer_.start(configuration);

      Map<String, Long> reply = new HashMap<>();
      result.success(reply);
    } else if (call.method.equals("stop")) {
      ionSfuServer_.stop();

      Map<String, Long> reply = new HashMap<>();
      result.success(reply);
    } else if (call.method.equals("createSignalChannel")) {

      long channelId = ionSfuServer_.createSignalChannel();

      result.success(channelId);
    } else if (call.method.equals("closeSignalChannel")) {
      int channelId = call.argument("channelId");

      ionSfuServer_.closeSignalChannel(channelId);

      Map<String, Long> reply = new HashMap<>();
      result.success(reply);
    } else if (call.method.equals("processSignalMessage")) {
      int channelId = call.argument("channelId");
      String message = call.argument("message");

      ionSfuServer_.processSignalMessage(channelId, message);

      Map<String, Long> reply = new HashMap<>();
      result.success(reply);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onError(String error, String msg) {
    Log.d(TAG, "FlutterIonSfuPlugin::onError(): '" + error + "' " + msg);

    post(() -> {
      Map<String, Object> arguments = new HashMap<>();
      arguments.put("error", error);
      arguments.put("msg", msg);

      channel.invokeMethod("onError", arguments);
    });
  }

  @Override
  public void onSignalMessage(long channelId, String message) {
    Log.d(TAG, "FlutterIonSfuPlugin::onSignalMessage() " + channelId + " " + message);

    post(() -> {
      Map<String, Object> arguments = new HashMap<>();
      arguments.put("channelId", channelId);
      arguments.put("message", message);

      channel.invokeMethod("onSignalMessage", arguments);
    });
  }

  @Override
  public void onIceConnectionState(long channelId, long state) {
    Log.d(TAG, "FlutterIonSfuPlugin::onIceConnectionState() " + channelId + " " + state);

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
}
