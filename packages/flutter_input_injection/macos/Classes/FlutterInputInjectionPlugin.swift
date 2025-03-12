import Cocoa
import CoreGraphics
import FlutterMacOS

let VIEWSONIC_VID: UInt16 = 0x0543
let VIEWSONIC_PID: UInt16 = 0x1234

public class FlutterInputInjectionPlugin: NSObject, FlutterPlugin {
  private var lastMouseDownEvent: (action: Int, id: Int, x: Int, y: Int, timestamp: TimeInterval)? =
    nil
  private var skipEventsUntilMouseUp: Bool = false
  private var mouseDown: Bool = false
  private let distanceThreshold: CGFloat = 25
  private var targetScreen: NSScreen? = nil
  private let screenStateQueue = DispatchQueue(label: "flutter_input_injection.screenStateQueue", attributes: .concurrent)
  private var isScreenConfigChanged: Bool = false

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "flutter_input_injection", binaryMessenger: registrar.messenger)
    let instance = FlutterInputInjectionPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
  
  public override init() {
    super.init()
    // registered
    NotificationCenter.default.addObserver(
        self,
        selector: #selector(handleScreenConfigurationChanged),
        name: NSApplication.didChangeScreenParametersNotification,
        object: nil
    )
  }
  
  deinit {
      NotificationCenter.default.removeObserver(self, name: NSApplication.didChangeScreenParametersNotification, object: nil)
  }

  @objc private func handleScreenConfigurationChanged() {
    screenStateQueue.async(flags: .barrier) {
      self.isScreenConfigChanged = true
    }
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "sendTouch":
      guard let arguments = call.arguments as? [String: Any] else {
        result(false)
        return
      }

      guard let action = arguments["action"] as? Int,
        let id = arguments["id"] as? Int,
        let x = arguments["x"] as? Int,
        let y = arguments["y"] as? Int
      else {
        result(false)
        return
      }
      
      processTouchEvent((action: action, id: id, x: x, y: y))
      result(true)
      
    case "sendNormalizedTouch":
      guard let arguments = call.arguments as? [String: Any] else {
        result(false)
        return
      }

      guard let action = arguments["action"] as? Int,
        let id = arguments["id"] as? Int,
        let normalizedX = arguments["x"] as? Double,
        let normalizedY = arguments["y"] as? Double,
        let screenId = arguments["screenId"] as? Int,
        let autoVirtualDisplay = arguments["autoVirtualDisplay"] as? Bool
      else {
        result(false)
        return
      }

      processNormalizedTouchEvent(
        (action: action,
         id: id,
         x: normalizedX,
         y: normalizedY,
         screenId: screenId,
         autoVirtualDisplay: autoVirtualDisplay))
      
      result(true)
      
    case "getPlatformVersion":
      result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func processTouchEvent(_ event: (action: Int, id: Int, x: Int, y: Int)) {
    switch event.action {
    case 0:  // touch down
      handleMouseDown(event)  // convert touch down to mouse down
      break

    case 1:  // touch move
      handleMouseMove(event)  // convert touch move to mouse move
      break

    case 2:  // touch up
      handleMouseUp(event)  // convert touch up to mouse up
      break

    default:
      break
    }
  }

  private func findVirtualScreen() -> CGDirectDisplayID? {
    let maxDisplays: UInt32 = 10 // Reasonable upper limit for the number of displays
    var onlineDisplays = [CGDirectDisplayID](repeating: 0, count: Int(maxDisplays))
    var displayCount: UInt32 = 0
    let result = CGGetOnlineDisplayList(maxDisplays, &onlineDisplays, &displayCount)
    if result != .success {
      return nil
    }
    for i in 0..<displayCount {
      let displayID = onlineDisplays[Int(i)]
      guard displayID != kCGNullDirectDisplay else { continue }
      let vendorId = CGDisplayVendorNumber(displayID)
      let productId = CGDisplayModelNumber(displayID)
      let isVirtual = vendorId == VIEWSONIC_VID && productId == VIEWSONIC_PID
      let mirroredToDisplay = CGDisplayMirrorsDisplay(displayID)
      if isVirtual {
        if mirroredToDisplay == kCGNullDirectDisplay {
          return displayID
        } else {
          return mirroredToDisplay
        }
      }
    }
    return nil
  }
  
  private func findScreenBySceenNumber(_ target: CGDirectDisplayID) -> NSScreen? {
    let screens = NSScreen.screens
    for screen in screens {
      let screenNumber = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? Int
      if Int(target) == screenNumber {
        return screen
      }
    }
    return nil
  }
  
  private func findVirtualDisplayScreen() -> NSScreen? {
    guard let virtualScreenDisplayId = findVirtualScreen() else {
      return nil
    }
    return findScreenBySceenNumber(virtualScreenDisplayId)
  }
  
  private func findTargetScreen(autoVirtualDisplay: Bool, screenId: Int) -> NSScreen? {
    let shouldReset = screenStateQueue.sync { isScreenConfigChanged }
    
    if shouldReset {
      print("Screen configuration changed, resetting target screen.")
    }

    if targetScreen == nil || shouldReset {
      guard let screen = autoVirtualDisplay
              ? findVirtualDisplayScreen()
              : findScreenBySceenNumber(CGDirectDisplayID(screenId))
      else {
        return nil
      }
      self.targetScreen = screen
      screenStateQueue.async(flags: .barrier) {
        self.isScreenConfigChanged = false
      }
    }
    return targetScreen
  }
  
  private func processNormalizedTouchEvent(_ event: (
    action: Int, id: Int, x: Double, y: Double, screenId: Int, autoVirtualDisplay: Bool)) {
    
    guard let screen = findTargetScreen(autoVirtualDisplay: event.autoVirtualDisplay, screenId: event.screenId) else {
      return
    }

    let frame = screen.frame
    let actualX = frame.minX + CGFloat(event.x) * frame.width
      
    // Compute flippedY to match macOS coordinate system
    // In macOS, the origin (0,0) is at the bottom-left, while normalizedY ranges from [0,1],
    // where 1.0 represents the top of the screen.
    // To convert normalizedY to the actual macOS coordinate, we need to flip the Y-axis.
    //
    // normalizedY follows a top-down system where 1.0 is at the top and 0.0 is at the bottom.
    // However, macOS uses a bottom-up system where (0,0) is at the bottom-left.
    // Therefore, we use (1.0 - normalizedY) to invert the Y coordinate before scaling it.
    let flippedY = NSScreen.screens[0].frame.maxY - (frame.minY + (1.0 - CGFloat(event.y)) * frame.height)

    processTouchEvent((action: event.action, id: event.id, x: Int(actualX), y: Int(flippedY)))
  }

  private func handleMouseDown(_ event: (action: Int, id: Int, x: Int, y: Int)) {
    // If events are being skipped until a mouse-up event, ignore this event.
    if skipEventsUntilMouseUp {
      return
    }

    // Check for a potential double-click by comparing the time and distance between
    // this mouse down event and the last one.
    if lastMouseDownEvent != nil {
      if isWithinSystemDoubleClickTimeInterval(lastMouseDownEvent!.timestamp) {
        if isWithinDistanceThreshold(
          CGPoint(x: lastMouseDownEvent!.x, y: lastMouseDownEvent!.y), toCGPoint(event))
        {
          // If the event qualifies as a double-click, reset tracking variables,
          // skip further events until a mouse-up occurs, and simulate a double-click.
          lastMouseDownEvent = nil
          skipEventsUntilMouseUp = true
          mouseDown = true

          simulateMouseLeftDoubleClickEvent(CGPoint(x: event.x, y: event.y))
          return
        }
      }
    }

    // Otherwise, update the last mouse down event timestamp and simulate a mouse down.
    let now = Date().timeIntervalSince1970
    lastMouseDownEvent = (
      action: event.action, id: event.id, x: event.x, y: event.y,
      timestamp: now
    )
    mouseDown = true

    simulateMouseEvent(.leftMouseDown, at: CGPoint(x: event.x, y: event.y))
  }

  private func handleMouseMove(_ event: (action: Int, id: Int, x: Int, y: Int)) {
    // Ignore move events if the mouse is not currently presse or if events are being
    // skipped until a mouse-up occurs.
    if !mouseDown || skipEventsUntilMouseUp {
      return
    }

    simulateMouseEvent(.mouseMoved, at: CGPoint(x: event.x, y: event.y))
  }

  private func handleMouseUp(_ event: (action: Int, id: Int, x: Int, y: Int)) {
    // Ignore mouse-up events if the mouse is not currently pressed.
    if !mouseDown {
      return
    }

    // Reset skipping events until mouse-up if it was a previous yet.
    if skipEventsUntilMouseUp {
      skipEventsUntilMouseUp = false
    } else {
      simulateMouseEvent(.leftMouseUp, at: CGPoint(x: event.x, y: event.y))
    }

    // Reset the mouse down state.
    mouseDown = false
  }

  private func simulateMouseEvent(_ type: CGEventType, at location: CGPoint) {
    CGEvent(
      mouseEventSource: nil, mouseType: type, mouseCursorPosition: location, mouseButton: .left)?
      .post(tap: .cghidEventTap)
  }

  private func simulateMouseLeftDoubleClickEvent(_ location: CGPoint) {
    if let event = CGEvent(
      mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: location,
      mouseButton: .left)
    {
      event.setIntegerValueField(.mouseEventClickState, value: Int64(2))
      event.post(tap: .cghidEventTap)
      event.type = .leftMouseUp
      event.post(tap: .cghidEventTap)
      event.type = .leftMouseDown
      event.post(tap: .cghidEventTap)
      event.type = .leftMouseUp
      event.post(tap: .cghidEventTap)
    }
  }

  private func toCGPoint(_ event: (action: Int, id: Int, x: Int, y: Int)) -> CGPoint {
    return CGPoint(x: event.x, y: event.y)
  }

  private func getSystemDoubleClickInterval() -> Double {
    // Retrieves the system-defined double-click interval, which is the maximum
    // time allowed between two consecutive mouse down events for them to be
    // recognized as a double-click.
    // The interval is adjustable by the user in system preferences, typically
    // ranging from 0.15 seconds (faster double-click) to 5 seconds (slower double-click).
    // The default or average value is 1.4 seconds.
    return NSEvent.doubleClickInterval
  }

  private func isWithinSystemDoubleClickTimeInterval(_ time: TimeInterval) -> Bool {
    let now = Date().timeIntervalSince1970
    let systemDoubleClickInterval = getSystemDoubleClickInterval()
    return (now - time) < systemDoubleClickInterval
  }

  private func isWithinDistanceThreshold(_ point1: CGPoint, _ point2: CGPoint) -> Bool {
    return distanceBetweenPoints(point1, point2) < distanceThreshold
  }

  private func distanceBetweenPoints(_ point1: CGPoint, _ point2: CGPoint) -> CGFloat {
    return sqrt(pow(point1.x - point2.x, 2) + pow(point1.y - point2.y, 2))
  }
}
