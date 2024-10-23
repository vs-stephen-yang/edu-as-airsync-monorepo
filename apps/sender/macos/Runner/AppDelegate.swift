import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
    
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
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
          } else {
            result(FlutterMethodNotImplemented)
          }
        })

        super.applicationDidFinishLaunching(notification)
      }
}
