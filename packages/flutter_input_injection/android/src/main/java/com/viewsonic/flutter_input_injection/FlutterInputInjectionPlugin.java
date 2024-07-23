package com.viewsonic.flutter_input_injection;

import android.content.Context;
import android.graphics.Point;
import android.util.Log;
import android.view.Display;
import android.view.WindowManager;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** FlutterInputInjectionPlugin */
@Keep
public class FlutterInputInjectionPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native
  /// Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine
  /// and unregister it
  /// when the Flutter Engine is detached from the Activity
  private static final String TAG = "InputInjectionPlugin";

  private MethodChannel channel;
  private InputInjectUInput inputInjector;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    Log.d(TAG, "FlutterInputInjectionPlugin::onAttachedToEngine()");

    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_input_injection");
    channel.setMethodCallHandler(this);

    Context context = flutterPluginBinding.getApplicationContext();

    // display size
    WindowManager windowManager = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
    Display display = windowManager.getDefaultDisplay();

    // get real screen resolution
    Point displaySize = new Point();
    display.getRealSize(displaySize);

    Log.i(TAG, String.format("Real display size: %dx%d", displaySize.x, displaySize.y));

    // create an input injector
    inputInjector = new InputInjectUInput(displaySize.x, displaySize.y);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("sendTouch")) {
      int action = call.argument("action");
      int id = call.argument("id");
      int x = call.argument("x");
      int y = call.argument("y");

      switch (action) {
        case 0:
          inputInjector.InjectTouchStart(id, x, y);
          break;
        case 1:
          inputInjector.InjectTouchMove(id, x, y);
          break;
        case 2:
          inputInjector.InjectTouchEnd(id);
          break;
        default:
          break;
      }

      result.success(true);
    } else if (call.method.equals("sendKey")) {
      int usbKeyCode = call.argument("usbKeyCode");
      boolean pressed = call.argument("pressed");

      inputInjector.InjectKeyEvent(usbKeyCode, pressed);
      result.success(true);
    } else if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    Log.d(TAG, "FlutterInputInjectionPlugin::onDetachedFromEngine()");

    channel.setMethodCallHandler(null);
  }
}
