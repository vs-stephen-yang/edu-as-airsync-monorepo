import Cocoa
import FlutterMacOS

public class FlutterVirtualDisplayPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_virtual_display", binaryMessenger: registrar.messenger)
    let eventChannel = FlutterEventChannel(name: "FlutterVirtualDisplay.Event", binaryMessenger: registrar.messenger)
    let instance = FlutterVirtualDisplayPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    eventChannel.setStreamHandler(instance)
  }

#if AIRSYNC_OPEN
  private var virtualDisplay: FlutterVirtualDisplay?
#endif //AIRSYNC_OPEN
  private var eventSink: FlutterEventSink?

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    return nil
  }
  
  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initialize":
#if AIRSYNC_OPEN
      virtualDisplay = FlutterVirtualDisplay(eventSink: { [weak self] event in
        self?.eventSink?(event)
      })
      result(true)
#else //!OPEN
      result(false)
#endif //AIRSYNC_OPEN

    case "isSupported":
#if AIRSYNC_OPEN
      if virtualDisplay != nil {
        result(virtualDisplay?.isSupported())
      } else {
        result(false)
      }
#endif //AIRSYNC_OPEN
      result(false)

    case "startVirtualDisplay":
#if AIRSYNC_OPEN
    if let args = call.arguments as? [String: Any],
       let pixelWidth = args["pixelWidth"] as? Int,
       let pixelHeight = args["pixelHeight"] as? Int {

       let success = virtualDisplay?.startVirtualDisplay(width: UInt32(pixelWidth),
                                                         height: UInt32(pixelHeight))
       result(success)
    } else {
       result(false)
    }
#else //!OPEN
        result(false)
#endif //AIRSYNC_OPEN

    case "stopVirtualDisplay":
#if AIRSYNC_OPEN
      if virtualDisplay != nil {
        let success = virtualDisplay?.stopVirtualDisplay()
        result(success)
      } else {
        result(false)
      }
#else //!OPEN
      result(false)
#endif //AIRSYNC_OPEN

    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
