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

    // 2️⃣ EventChannel：推送前景 App 變化
    let eventChannel = FlutterEventChannel(
      name: "com.viewsonic.display.cast/foreground_app_events",
      binaryMessenger: controller.engine.binaryMessenger
    )
    eventChannel.setStreamHandler(ForegroundAppStreamHandler())

    // === PowerPoint Slideshow EventChannel ===
    let pptEventChannel = FlutterEventChannel(
      name: "com.viewsonic.display.cast/ppt_slideshow_events",
      binaryMessenger: controller.engine.binaryMessenger
    )
    pptEventChannel.setStreamHandler(PowerPointSlideshowStreamHandler())

    super.applicationDidFinishLaunching(notification)
  }

  // EventChannel 的 StreamHandler
  class ForegroundAppStreamHandler: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var observer: Any?

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
      self.eventSink = events

      // 監聽「某個 App 被啟用（成為 frontmost / focused）」的通知
      observer = NSWorkspace.shared.notificationCenter.addObserver(
        forName: NSWorkspace.didActivateApplicationNotification,
        object: nil,
        queue: OperationQueue.main
      ) { [weak self] notification in
        guard let self = self else { return }

        if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
          let bundleId = app.bundleIdentifier ?? ""
          // 推給 Flutter
          self.eventSink?(bundleId)
        }
      }

      // 一開始主動推一次目前前景 app（可有可無；這裡選擇推）
      if let app = NSWorkspace.shared.frontmostApplication,
         let bundleId = app.bundleIdentifier {
        events(bundleId)
      }

      return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
      if let observer = observer {
        NSWorkspace.shared.notificationCenter.removeObserver(observer)
        self.observer = nil
      }
      eventSink = nil
      return nil
    }
  }

  class PowerPointSlideshowStreamHandler: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var timer: Timer?
    private var lastValue: Bool?

    private func isPowerPointFullscreenLikelySlideshow() -> Bool {
      // 1. 找 PowerPoint process
      let pptBundleId = "com.microsoft.Powerpoint"
      guard let pptApp = NSRunningApplication.runningApplications(withBundleIdentifier: pptBundleId).first else {
        return false
      }
      let pptPid = pptApp.processIdentifier

      // 2. 列出所有在螢幕上的視窗
      let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
      guard let windowList = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: AnyObject]] else {
        return false
      }

      // 3. 取出所有螢幕 frame（考慮多螢幕）
      let screens = NSScreen.screens
      let screenFrames = screens.map { $0.frame }

      for window in windowList {
        let ownerPid = window[kCGWindowOwnerPID as String] as? pid_t ?? 0
        if ownerPid != pptPid {
          continue
        }

        // 取得視窗 bounds
        guard let boundsDict = window[kCGWindowBounds as String] as? [String: CGFloat] else {
          continue
        }
        let bounds = CGRect(
          x: boundsDict["X"] ?? 0,
          y: boundsDict["Y"] ?? 0,
          width: boundsDict["Width"] ?? 0,
          height: boundsDict["Height"] ?? 0
        )

        let layer = window[kCGWindowLayer as String] as? Int ?? 0

        // 4. 判斷是否幾乎等於某個螢幕大小且在一般 layer（0）
        guard layer == 0 else { continue }

        let tolerance: CGFloat = 2.0
        let isFullscreenOnAnyScreen = screenFrames.contains { screenFrame in
          abs(bounds.width - screenFrame.width) < tolerance &&
          abs(bounds.height - screenFrame.height) < tolerance
        }

        if isFullscreenOnAnyScreen {
          // 很大機率是 Slide Show 視窗
          return true
        }
      }

      return false
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
      self.eventSink = events

      // 每 1 秒檢查一次，但只在狀態改變時發 event
      timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
        guard let self = self else { return }
        let value = isPowerPointFullscreenLikelySlideshow()

        if self.lastValue == nil || self.lastValue != value {
          self.lastValue = value
          events(value)  // 丟 true/false 給 Flutter
        }
      }

      // 推一次初始值
      let initial = isPowerPointFullscreenLikelySlideshow()
      lastValue = initial
      events(initial)

      return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
      timer?.invalidate()
      timer = nil
      eventSink = nil
      lastValue = nil
      return nil
    }
  }
}
