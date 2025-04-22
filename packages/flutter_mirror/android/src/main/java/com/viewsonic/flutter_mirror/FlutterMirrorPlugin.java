package com.viewsonic.flutter_mirror;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;
import androidx.lifecycle.Lifecycle;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.view.TextureRegistry;
import io.flutter.view.TextureRegistry.SurfaceTextureEntry;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.FutureTask;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.graphics.SurfaceTexture;
import android.os.Build;
import android.util.Log;
import android.view.Surface;
import android.os.Handler;
import android.os.Looper;


/** FlutterMirrorPlugin */
@Keep
public class FlutterMirrorPlugin implements
    FlutterPlugin,
    ActivityAware,
    TexRegistry,
    MirrorListener,
    BluetoothTouchBackListener,
    MethodCallHandler {
  private static final String TAG = "FlutterMirrorPlugin";

  // A wrapper for SurfaceTextureEntry
  class Texture {
    private SurfaceTextureEntry entry_;
    Surface surface_;

    Texture(SurfaceTextureEntry entry) {
      entry_ = entry;

      SurfaceTexture surfaceTexture = entry_.surfaceTexture();
      surface_ = new Surface(surfaceTexture);
    }

    public long id() {
      return entry_.id();
    }

    public Surface surface() {
      return surface_;
    }

    public void release() {
      entry_.release();
    }
  }

  /// The MethodChannel that will the communication between Flutter and native
  /// Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine
  /// and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel_;

  private TextureRegistry textureRegistry_;
  private BinaryMessenger messenger_;
  private Context context_;
  private Activity activity_;

  private HashMap<Long, Texture> textures_ = new HashMap<Long, Texture>();
  private Handler handler_ = new Handler(Looper.getMainLooper());

  private MirrorReceiver mirrorReceiver_;
  private BluetoothTouchBackController bluetoothTouchBackController_;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    Log.d(TAG, "FlutterMirrorPlugin::onAttachedToEngine()");

    textureRegistry_ = flutterPluginBinding.getTextureRegistry();
    messenger_ = flutterPluginBinding.getBinaryMessenger();
    context_ = flutterPluginBinding.getApplicationContext();

    assert context_ != null;

    channel_ = new MethodChannel(messenger_, "flutter_mirror");
    channel_.setMethodCallHandler(this);
  }

  @SuppressLint("NewApi")
  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding activityPluginBinding) {
    Log.d(TAG, "FlutterMirrorPlugin::onAttachedToActivity()");
    activity_ = activityPluginBinding.getActivity();

    bluetoothTouchBackController_ = new BluetoothTouchBackController(context_, activity_, this, false);
    activityPluginBinding.addActivityResultListener(bluetoothTouchBackController_.getActivityResultListener());
    activityPluginBinding.addRequestPermissionsResultListener(bluetoothTouchBackController_.getRequestPermissionsResultListener());
    activityPluginBinding.getActivity().registerActivityLifecycleCallbacks(bluetoothTouchBackController_.getActivityLifecycleCallbacks());
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding activityPluginBinding) {
    Log.d(TAG, "FlutterMirrorPlugin::onReattachedToActivityForConfigChanges()");
    onAttachedToActivity(activityPluginBinding);
  }

  @Override
  public void onDetachedFromActivity() {
    Log.d(TAG, "FlutterMirrorPlugin::onDetachedFromActivity()");
    activity_ = null;
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    Log.d(TAG, "FlutterMirrorPlugin::onDetachedFromActivityForConfigChanges()");
    onDetachedFromActivity();
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result res) {
    // onMethodCall() is called on the platform thread

    Log.v(TAG, "onMethodCall(): " + call.method);

    Result result = new AnyThreadResult(res);

    if (call.method.equals("initialize")) {
      initialize(call.argument("additionalCodecParams"));
      Map<String, Long> reply = new HashMap<>();
      result.success(reply);
    } else if (call.method.equals("onMirrorTouch")) {
      String mirrorId = call.argument("mirrorId");
      int touchId = call.argument("touchId");
      boolean touch = call.argument("touchDown");
      double x = call.argument("x");
      double y = call.argument("y");
      if (mirrorReceiver_ != null) {
        mirrorReceiver_.onMirrorTouch(
          mirrorId,
          touchId,
          touch,
          x,
          y);
      }
      if (bluetoothTouchBackController_ != null) {
        bluetoothTouchBackController_.onMirrorTouch(
          mirrorId,
          touchId,
          touch,
          x,
          y);
      }
      result.success(new HashMap<>());
    } else if (call.method.equals("startMirrorReplay")) {
      String mirrorId = call.argument("mirrorId");
      String videoCodec = call.argument("videoCodec");
      String videoPath = call.argument("videoPath");

      startMirrorReplay(mirrorId, videoCodec, videoPath);
    } else if (call.method.equals("enableDump")) {
      String dumpPath = call.argument("dumpPath");

      enableDump(dumpPath);
    } else if (call.method.equals("startAirplay")) {
      String name = call.argument("name");
      String security = call.argument("security");

      startAirplay(
          name,
          security);

      Map<String, Long> reply = new HashMap<>();
      result.success(reply);
    } else if (call.method.equals("stopAirplay")) {
      stopAirplay();

      Map<String, Long> reply = new HashMap<>();
      result.success(reply);
    } else if (call.method.equals("startGooglecast")) {
      String name = call.argument("name");
      String uniqueId = call.argument("uniqueId");

      Map<String, Object> credentials = call.argument("credentials");

      startGooglecast(
          name,
          uniqueId,
          GooglecastCredentials.fromMap(credentials));

      Map<String, Long> reply = new HashMap<>();
      result.success(reply);
    } else if (call.method.equals("stopGooglecast")) {
      stopGooglecast();

      Map<String, Long> reply = new HashMap<>();
      result.success(reply);
    } else if (call.method.equals("startMiracast")) {
      String name = call.argument("name");

      startMiracast(
          name);

      Map<String, Long> reply = new HashMap<>();
      result.success(reply);
    } else if (call.method.equals("stopMiracast")) {
      stopMiracast();

      Map<String, Long> reply = new HashMap<>();
      result.success(reply);
    } else if (call.method.equals("stopMirror")) {
      String mirrorId = call.argument("mirrorId");

      stopMirror(mirrorId);

      Map<String, Long> reply = new HashMap<>();
      result.success(reply);
    } else if (call.method.equals("enableAudio")) {
      String mirrorId = call.argument("mirrorId");
      boolean enable = call.argument("enable");

      enableAudio(mirrorId, enable);

      Map<String, Long> reply = new HashMap<>();
      result.success(reply);
    } else if (call.method.equals("updateCredentials")) {
      Map<String, Object> credentials = call.argument("credentials");

      updateCredentials(
          GooglecastCredentials.fromMap(credentials));

      Map<String, Long> reply = new HashMap<>();
      result.success(reply);
    } else {
      result.notImplemented();
    }
  }

  private void initialize(Map<String, Integer> additionalCodecParams) {
    assert context_ != null;

    if (mirrorReceiver_ != null) {
      return;
    }

    mirrorReceiver_ = new MirrorReceiver(this, this, additionalCodecParams, context_);

    // TODO ben
    //bluetoothTouchBackController_.onMirrorStart("1", "李威寬的iPad", "airplay");
    //bluetoothTouchBackController_.onMirrorTouch("1", 1, true, 0.5, 0.5);
  }

  private void enableDump(String dumpPath) {
    if (mirrorReceiver_ == null) {
      return;
    }

    mirrorReceiver_.enableDump(dumpPath);
  }

  private void startMirrorReplay(String mirrorId, String videoCodec, String videoPath) {
    if (mirrorReceiver_ == null) {
      return;
    }

    mirrorReceiver_.startMirrorReplay(mirrorId, videoCodec, videoPath);
  }

  private void startAirplay(String name, String security) {
    if (mirrorReceiver_ == null) {
      return;
    }

    mirrorReceiver_.startAirplay(name, security);
  }

  private void stopAirplay() {
    if (mirrorReceiver_ == null) {
      return;
    }

    mirrorReceiver_.stopAirplay();
  }

  private void startGooglecast(
      String name,
      String uniqueId,
      GooglecastCredentials credentials) {
    if (mirrorReceiver_ == null) {
      return;
    }

    mirrorReceiver_.startGooglecast(name, uniqueId, credentials);
  }

  private void stopGooglecast() {
    if (mirrorReceiver_ == null) {
      return;
    }

    mirrorReceiver_.stopGooglecast();
  }

  private void stopMiracast() {
    if (mirrorReceiver_ == null) {
      return;
    }

    Log.d(TAG, "stopMiracast()");
    mirrorReceiver_.stopMiracast();
  }

  private void updateCredentials(GooglecastCredentials credentials) {
    if (mirrorReceiver_ == null) {
      return;
    }

    mirrorReceiver_.updateCredentials(credentials);
  }

  private void startMiracast(String name) {
    assert context_ != null;
    assert activity_ != null;

    if (mirrorReceiver_ == null) {
      return;
    }

    mirrorReceiver_.startMiracast(
        name,
        context_,
        activity_);
  }

  private void stopMirror(String mirrorId) {
    Log.d(TAG, String.format("FlutterMirrorPlugin.stopMirror(%s)", mirrorId));

    if (mirrorReceiver_ == null) {
      return;
    }

    mirrorReceiver_.stopMirror(mirrorId);
  }

  private void enableAudio(String mirrorId, boolean enable) {
    if (mirrorReceiver_ == null) {
      return;
    }

    mirrorReceiver_.enableAudio(mirrorId, enable);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    Log.d(TAG, "FlutterMirrorPlugin.onDetachedFromEngine()");
    if (channel_ != null) {
      // stop receiving messages from the Flutter side
      channel_.setMethodCallHandler(null);
    }

    if (mirrorReceiver_ != null) {
      mirrorReceiver_.stop();
      mirrorReceiver_.dispose();
      mirrorReceiver_ = null;
    }

    // Note: set channel_ to null after mirrorReceiver_.stop() and
    // mirrorReceiver_.dispose()
    // Reason: stop() may trigger a callback to the Flutter side
    channel_ = null;
  }

  // create a surface and return its id
  @Override
  public long createSurfaceTexture() throws java.lang.Exception {
    Log.d(TAG, "FlutterMirrorPlugin.createSurfaceTexture()");

    // Must run on the platform thread
    return post(() -> {
      Texture tex = new Texture(
          textureRegistry_.createSurfaceTexture());

      textures_.put(tex.id(), tex);

      Log.d(TAG, "surface texture has been created " + tex.id());

      return tex.id();
    });
  }

  @Override
  public Surface getSurfaceTexture(long textureId) throws java.lang.Exception {
    Log.d(TAG, "FlutterMirrorPlugin.getSurfaceTexture()");

    // Must run on the platform thread
    return post(() -> {
      Texture tex = textures_.get(textureId);
      assert tex != null;

      return tex.surface();
    });
  }

  // release a surface
  @Override
  public void releaseSurfaceTexture(long textureId) throws java.lang.Exception {
    Log.d(TAG, "FlutterMirrorPlugin.releaseSurfaceTexture() " + textureId);

    // Must run on the platform thread
    post(() -> {
      Texture tex = textures_.get(textureId);
      if (tex == null) {
        Log.w(TAG, "no such surface texture " + textureId);
        return;
      }

      textures_.remove(textureId);
      tex.release();

      Log.d(TAG, "surface texture has been released " + textureId);
      Log.d(TAG, "remaining surface textures " + textures_.size());
    });
  }

  public void onMirrorAuth(String pin, int timeoutSec) {
    Log.d(TAG, "FlutterMirrorPlugin.onMirrorAuth() " + pin);

    // Must run on the platform thread
    post(() -> {
      Map<String, Object> arguments = new HashMap<>();
      arguments.put("pin", pin);
      arguments.put("timeoutSec", timeoutSec);

      channel_.invokeMethod("onMirrorAuth", arguments);
    });
  }

  public void onMirrorStart(
      String mirrorId,
      long textureId,
      String deviceName,
      String mirrorType) {
    Log.d(TAG, "FlutterMirrorPlugin.onMirrorStart() " + mirrorId);

    if (bluetoothTouchBackController_ != null) {
      bluetoothTouchBackController_.onMirrorStart(mirrorId, deviceName, mirrorType);
    }

    // Must run on the platform thread
    post(() -> {
      Map<String, Object> arguments = new HashMap<>();
      arguments.put("mirrorId", mirrorId);
      arguments.put("textureId", textureId);
      arguments.put("deviceName", deviceName);
      arguments.put("mirrorType", mirrorType);

      channel_.invokeMethod("onMirrorStart", arguments);
    });
  }

  public void onMirrorStop(String mirrorId) {
    Log.d(TAG, "FlutterMirrorPlugin.onMirrorStop() " + mirrorId);

    if (bluetoothTouchBackController_ != null) {
      bluetoothTouchBackController_.onMirrorStop(mirrorId);
    }

    // Must run on the platform thread
    post(() -> {
      Map<String, Object> arguments = new HashMap<>();
      arguments.put("mirrorId", mirrorId);

      channel_.invokeMethod("onMirrorStop", arguments);
    });
  }

  public void onMirrorVideoResize(String mirrorId, int width, int height) {
    Log.d(TAG, "FlutterMirrorPlugin.onMirrorVideoResize() " + mirrorId);

    // Must run on the platform thread
    post(() -> {
      Map<String, Object> arguments = new HashMap<>();
      arguments.put("mirrorId", mirrorId);
      arguments.put("width", width);
      arguments.put("height", height);

      channel_.invokeMethod("onMirrorVideoResize", arguments);
    });
  }

  @Override
  public void onMirrorVideoFrameRate(String mirrorId, int fps) {

    // Must run on the platform thread
    post(() -> {
      Map<String, Object> arguments = new HashMap<>();
      arguments.put("mirrorId", mirrorId);
      arguments.put("fps", fps);

      channel_.invokeMethod("onMirrorVideoFrameRate", arguments);
    });
  }

  @Override
  public void onCredentialsRequest(
      int year,
      int month,
      int day) {
    Log.d(TAG, "FlutterMirrorPlugin.onCredentialsRequest() ");

    // Must run on the platform thread
    post(() -> {
      Map<String, Object> arguments = new HashMap<>();
      arguments.put("year", year);
      arguments.put("month", month);
      arguments.put("day", day);

      channel_.invokeMethod("onCredentialsRequest", arguments);
    });
  }

  @Override
  public void onBluetoothTouchBackStatus(BluetoothTouchBackStatus status) {
    post(() -> {
      Map<String, Object> arguments = new HashMap<>();
      arguments.put("status", status.ordinal());
      channel_.invokeMethod("onBluetoothTouchbackStatusChanged", arguments);
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

  static {
    Log.d(TAG, "loading flutter_mirror library");
    System.loadLibrary("flutter_mirror");
    Log.d(TAG, "flutter_mirror library has been loaded");
  }
}
