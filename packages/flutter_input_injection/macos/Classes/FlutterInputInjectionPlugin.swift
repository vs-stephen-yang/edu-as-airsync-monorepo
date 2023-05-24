import Cocoa
import FlutterMacOS

public class FlutterInputInjectionPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_input_injection", binaryMessenger: registrar.messenger)
    let instance = FlutterInputInjectionPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
    case "sendTouch":
      result("Todo: implement sendTouch()");
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
