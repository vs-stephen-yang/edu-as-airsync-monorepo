import Cocoa
import FlutterMacOS
import CoreGraphics

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
      guard let arguments = call.arguments as? [String: Any] else {
          // Handle the case when method_call.arguments is not of type [String: Any]
          // ...
          result(false)
          return
      }

      guard let action = arguments["action"] as? Int,
            let id = arguments["id"] as? Int,
            let x = arguments["x"] as? Int,
            let y = arguments["y"] as? Int else {
          // Handle the case when method_call.arguments is not of type [String: Any] or the expected keys are missing or not of type Int
          // ...
          result(false)
          return
      }
        
      let mouseLocation = CGPoint(x: x,y: y)
      /* if action==0 leftmousedown, if action==1 set mouseMoved, if action==2 set leftmouseup */
      switch action {
      case 0:
        // leftmousedown
        CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: mouseLocation, mouseButton: .left)?.post(tap: .cghidEventTap)
      case 1:
        // mouseMoved
        CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: mouseLocation, mouseButton: .left)?.post(tap: .cghidEventTap)
      case 2:
        // leftmouseup
        CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: mouseLocation, mouseButton: .left)?.post(tap: .cghidEventTap)
      default:
        result(FlutterMethodNotImplemented)
      }
      result(true);
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
