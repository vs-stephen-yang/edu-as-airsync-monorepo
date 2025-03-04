package com.viewsonic.flutter_input_injection;

import static androidx.core.content.ContextCompat.startActivity;

import android.content.Context;
import android.content.Intent;
import android.graphics.Point;
import android.provider.Settings;
import android.util.Log;
import android.util.DisplayMetrics;
import android.view.Display;
import android.view.WindowManager;
import android.view.Surface;

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
  private InputStub inputInjector;
  private WindowManager windowManager;
  Context context;

  public enum InputInjectionMethod {
    UINPUT,
    ACCESSIBILITY_SERVICE
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    Log.d(TAG, "FlutterInputInjectionPlugin::onAttachedToEngine()");

    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_input_injection");
    channel.setMethodCallHandler(this);

    context = flutterPluginBinding.getApplicationContext();
  }

  void initialize(InputInjectionMethod method) {
    Log.d(TAG, String.format("Initialize with %s method", method));

    // display size
    windowManager = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
    Display display = windowManager.getDefaultDisplay();

    // get real screen resolution
    Point displaySize = new Point();
    display.getRealSize(displaySize);

    boolean isNaturalPortrait = isDeviceNaturalOrientationPortrait();
    boolean isPortrait = isDeviceOrientationPortrait(isNaturalPortrait);

    Log.i(TAG, String.format("Real display size: %dx%d isNaturalPortrait: %b isPortrait: %b",
        displaySize.x, displaySize.y, isNaturalPortrait, isPortrait));

    // create an input injector
    // TODO: need to handle the case when the device is rotated dynamically
    switch (method) {
      case UINPUT:
        if (isPortrait) {
          inputInjector = new PortraitInputStub(new InputInjectUInput(displaySize.y, displaySize.x), displaySize.x);
        } else {
          inputInjector = new InputInjectUInput(displaySize.x, displaySize.y);
        }
        break;

      case ACCESSIBILITY_SERVICE:
        inputInjector = new GestureInputStub(context);
        break;
    }

  }

  // Reference: https://gist.github.com/SammyVimes/92c0627195c4c55ea800
  private boolean isDeviceNaturalOrientationPortrait() {
    final int rotation = windowManager.getDefaultDisplay().getRotation();
    DisplayMetrics metrics = new DisplayMetrics();
    windowManager.getDefaultDisplay().getMetrics(metrics);
    int width = metrics.widthPixels;
    int height = metrics.heightPixels;
    if ((rotation == Surface.ROTATION_0 || rotation == Surface.ROTATION_180) && height > width
        || (rotation == Surface.ROTATION_90 || rotation == Surface.ROTATION_270) && width > height) {
      return true;
    }
    return false;
  }

  private boolean isDeviceOrientationPortrait(boolean isNaturalPortrait) {
    final int rotation = windowManager.getDefaultDisplay().getRotation();
    if (isNaturalPortrait) {
      return rotation == Surface.ROTATION_0 || rotation == Surface.ROTATION_180;
    } else {
      return rotation == Surface.ROTATION_90 || rotation == Surface.ROTATION_270;
    }
  }

  private static InputInjectionMethod parseInputInjectionMethod(String dartEnumValue) {
    if (dartEnumValue == null) {
      throw new IllegalArgumentException("dartEnumValue cannot be null");
    }

    switch (dartEnumValue) {
      case "uinput":
      case "auto":
        return InputInjectionMethod.UINPUT;
      case "accessibilityService":
        return InputInjectionMethod.ACCESSIBILITY_SERVICE;

      default:
        // Handle unknown values
        throw new IllegalArgumentException("Invalid Dart enum value: " + dartEnumValue);
    }
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("initialize")) {
      String inputInjectionMethod = call.argument("inputInjectionMethod");

      initialize(parseInputInjectionMethod(inputInjectionMethod));

      result.success(true);
    } else if (call.method.equals("sendTouch")) {
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
