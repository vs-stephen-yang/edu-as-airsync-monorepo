package com.viewsonic.flutter_ion_sfu;

import androidx.annotation.NonNull;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** FlutterIonSfuPlugin */
public class FlutterIonSfuPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native
  /// Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine
  /// and unregister it
  /// when the Flutter Engine is detached from the Activity
  private static final String TAG = "FlutterIonSfuPlugin";
  private MethodChannel channel;
  private IonSfuServer ionSfuServer_;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_ion_sfu");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("initialize")) {
      ionSfuServer_ = new IonSfuServer();
      ionSfuServer_.initialize();

      Map<String, Long> reply = new HashMap<>();
      result.success(reply);
    } else if (call.method.equals("start")) {
      Map<String, Object> configuration = call.argument("configuration");

      ionSfuServer_.start(configuration);

      Map<String, Long> reply = new HashMap<>();
      result.success(reply);
    } else if (call.method.equals("stop")) {
      ionSfuServer_.stop();

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
}
