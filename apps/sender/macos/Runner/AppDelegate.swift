import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
  
  override func applicationDidFinishLaunching(_ notification: Notification) {
    let controller : FlutterViewController = mainFlutterWindow!.contentViewController as! FlutterViewController
    let window = mainFlutterWindow!
    
    let windowManagerChannel = FlutterMethodChannel(
      name: "com.viewsonic.display.cast/window_manager",
      binaryMessenger: controller.engine.binaryMessenger)
    
    windowManagerChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "minimizeWindow" {
        window.miniaturize(nil) // 這行代碼實現窗口最小化
        result(nil)
      } else if call.method == "getWindowPosition" {
        if let window = self.mainFlutterWindow {
            let frame = window.frame
            if let screen = window.screen {
                let screenHeight = screen.frame.height
                // 轉換成上緣為 0 的座標
                let convertedY = screenHeight - frame.origin.y - frame.size.height
                result(["x": frame.origin.x, "y": convertedY])
            } else {
                result(FlutterError(code: "UNAVAILABLE",
                                    message: "Screen not available",
                                    details: nil))
            }
        } else {
          result(FlutterError(code: "UNAVAILABLE",
                              message: "Window not available",
                              details: nil))
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    })
    
    AudioSwitch.register(with: controller.registrar(forPlugin: "audio_switch"))
    super.applicationDidFinishLaunching(notification)
  }
}
