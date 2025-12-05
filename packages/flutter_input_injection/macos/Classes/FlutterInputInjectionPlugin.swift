import Cocoa
import CoreGraphics
import FlutterMacOS

let VIEWSONIC_VID: UInt16 = 0x0543
let VIEWSONIC_PID: UInt16 = 0x1234

public class FlutterInputInjectionPlugin: NSObject, FlutterPlugin {
  private var targetScreen: NSScreen? = nil
  private let screenStateQueue = DispatchQueue(label: "flutter_input_injection.screenStateQueue", attributes: .concurrent)
  private var isScreenConfigChanged: Bool = false

  // 新增：目前正在處理的 touch id（只處理這個 id 的 move / up）
  private var activeTouchId: Int? = nil

  // ===== 手勢模式判斷 =====
  private var mouseDown: Bool = false

  /// down 之後停多久才算「長按」→ 用來分辨 drag（長按）vs scroll（立即移動）
  /// 由上層透過 setLongPressDelay 設定，單位：秒（預設 80ms）
  private var longPressDelay: TimeInterval = 0.08    // 80ms

  /// 單指點一下（tap）最大時間（down → up）
  private let tapMaxDuration: TimeInterval = 0.25     // 250ms

  /// 單指點一下（tap）允許的最大移動距離
  private let tapMoveThreshold: CGFloat = 5.0

  /// 在判斷 scroll / drag 之前，允許的「小抖動」距離
  private let jitterThreshold: CGFloat = 5.0

  /// 用於 double-click 的距離閾值（沿用你原本的 distanceThreshold）
  private let distanceThreshold: CGFloat = 25.0

  /// 本次手勢（down→up）的起始時間
  private var gestureStartTime: TimeInterval? = nil

  /// 本次手勢模式是否已決定（scroll 或 drag）
  private var gestureModeDecided: Bool = false

  /// 本次手勢是否為拖曳模式（true = drag, false = scroll）
  private var isDragMode: Bool = false

  /// 本次手勢的 down 位置（用來決定 click / drag 起點）
  private var gestureDownPoint: CGPoint? = nil

  /// 拖曳模式下，有沒有送過 leftMouseDown（避免重複送）
  private var didSendMouseDownForDrag: Bool = false

  /// 上一次 move 的座標（用來算 scroll delta & 移動距離）
  private var lastMovePoint: CGPoint? = nil

  // ===== 雙擊判斷用 =====
  private var lastClickTime: TimeInterval? = nil
  private var lastClickPoint: CGPoint? = nil

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

    case "setLongPressDelay":
      // 由上層決定 longPressDelay（單位：毫秒）
      guard let arguments = call.arguments as? [String: Any],
            let delayMs = arguments["delayMs"] as? Int else {
        result(false)
        return
      }
      // 轉成秒
      longPressDelay = TimeInterval(delayMs) / 1000.0
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
      // 如果目前沒有正在追蹤的 id，就從這個 id 開始
      if activeTouchId == nil {
        activeTouchId = event.id
        handleMouseDown(event)  // convert touch down to mouse down
      }
      // 如果 activeTouchId 已經有值，就忽略其它 finger 的 down
      break

    case 1:  // touch move
      // 只處理跟 activeTouchId 相同的 id
      guard let activeId = activeTouchId, activeId == event.id else {
        return
      }
      handleMouseMove(event)  // convert touch move to mouse move
      break

    case 2:  // touch up
      // 只處理跟 activeTouchId 相同的 id
      guard let activeId = activeTouchId, activeId == event.id else {
        return
      }
      handleMouseUp(event)  // convert touch up to mouse up
      // 對應的 finger 抬起後，把 activeTouchId 清掉，下一個 down 才能接手
      activeTouchId = nil
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
    mouseDown = true

    let now = Date().timeIntervalSince1970
    gestureStartTime = now
    gestureModeDecided = false
    isDragMode = false

    gestureDownPoint = CGPoint(x: event.x, y: event.y)
    didSendMouseDownForDrag = false
    lastMovePoint = nil

    // 這裡不送任何滑鼠事件，真正的 click / drag / scroll 之後再決定
  }

  private func handleMouseMove(_ event: (action: Int, id: Int, x: Int, y: Int)) {
    // Ignore move events if the mouse is not currently presse or if events are being
    // skipped until a mouse-up occurs.
    if !mouseDown {
      return
    }

    let now = Date().timeIntervalSince1970
    let currentPoint = CGPoint(x: event.x, y: event.y)
    let downPoint = gestureDownPoint ?? currentPoint

    let elapsedFromDown = now - (gestureStartTime ?? now)
    let distanceFromDown = distanceBetweenPoints(downPoint, currentPoint)

    // 第一次 move（或模式尚未決定）時，先處理「抖動」與模式判斷
    if !gestureModeDecided {
      // 情況 1：時間 < longPressDelay 且 距離 < jitterThreshold → 視為抖動，不決定模式、不送 scroll/drag
      if elapsedFromDown < longPressDelay && distanceFromDown < jitterThreshold {
        // 目前選擇：不送任何滑鼠事件，只更新 lastMovePoint。
        lastMovePoint = currentPoint
        return
      }

      // 情況 2：需要決定模式
      // - 如果已經超過 longPressDelay（不管距離） → 視為長按 → drag
      // - 如果還沒超過 longPressDelay 但移動距離已經 > jitterThreshold → 視為快速滑動 → scroll
      if elapsedFromDown >= longPressDelay {
        // down 後先停 ≥ longPressDelay 才開始動 → 長按 → 本次手勢用拖曳模式
        isDragMode = true
      } else {
        // down 完馬上開始動 → 本次手勢用滾動模式
        isDragMode = false
      }
      gestureModeDecided = true
    }

    // scroll 用的 delta（沒前一點就當 0）
    let previousPoint = lastMovePoint ?? currentPoint
    let deltaY = Int32(currentPoint.y - previousPoint.y)

    if isDragMode {
      // 拖曳模式：第一次需要補送 leftMouseDown，之後送 leftMouseDragged
      if !didSendMouseDownForDrag, let downPoint = gestureDownPoint {
        simulateMouseEvent(.leftMouseDown, at: downPoint)
        didSendMouseDownForDrag = true
      }
      simulateMouseEvent(.leftMouseDragged, at: currentPoint)
    } else {
      // 滾動模式：完全沒有 down/up，只送 mouseMoved + scrollWheel
      simulateMouseEvent(.mouseMoved, at: currentPoint)
      if deltaY != 0 {
        simulateScrollEvent(.scrollWheel, deltaY: deltaY)
      }
    }

    lastMovePoint = currentPoint
  }

  private func handleMouseUp(_ event: (action: Int, id: Int, x: Int, y: Int)) {
    // Ignore mouse-up events if the mouse is not currently pressed.
    if !mouseDown {
      return
    }

    let now = Date().timeIntervalSince1970
    let upPoint = CGPoint(x: event.x, y: event.y)
    let downPoint = gestureDownPoint ?? upPoint

    if !gestureModeDecided {
      // 沒有 move → 這是一個 tap 手勢（可能是單擊或雙擊）
      let startTime = gestureStartTime ?? now
      let duration = now - startTime

      // 移動距離
      let movedDistance: CGFloat
      if let lastMove = lastMovePoint {
        movedDistance = distanceBetweenPoints(downPoint, lastMove)
      } else {
        movedDistance = 0
      }

      if duration <= tapMaxDuration && movedDistance <= tapMoveThreshold {
        // 一次有效 tap，判斷是單擊還是雙擊
        if let lastTime = lastClickTime,
           let lastPoint = lastClickPoint,
           isWithinSystemDoubleClickTimeInterval(lastTime, now: now),
           isWithinDistanceThreshold(lastPoint, downPoint) {

          // 雙擊：送 double-click event
          simulateMouseLeftDoubleClickEvent(downPoint)

          // 重置「上一個 click」記錄
          lastClickTime = nil
          lastClickPoint = nil
        } else {
          // 單擊：送 leftMouseDown + leftMouseUp
          simulateMouseEvent(.leftMouseDown, at: downPoint)
          simulateMouseEvent(.leftMouseUp, at: downPoint)

          // 記錄這次 click，供之後判斷 double-click 用
          lastClickTime = now
          lastClickPoint = downPoint
        }
      }
      // 若 duration 太長或移動太遠，就當作「長按但沒移動」，目前不做任何事
    } else {
      // 已經是 scroll 或 drag 模式
      if isDragMode {
        // 拖曳模式：收尾送 leftMouseUp（如果有送過 down）
        if didSendMouseDownForDrag {
          simulateMouseEvent(.leftMouseUp, at: upPoint)
        }
      } else {
        // scroll 模式：完全不送 up → 不會觸發 click / 不會拖圖片捷徑
      }
    }

    // Reset 手勢狀態
    mouseDown = false
    gestureStartTime = nil
    gestureModeDecided = false
    isDragMode = false
    gestureDownPoint = nil
    didSendMouseDownForDrag = false
    lastMovePoint = nil
  }

  private func simulateMouseEvent(_ type: CGEventType, at location: CGPoint) {
    CGEvent(
      mouseEventSource: nil, mouseType: type, mouseCursorPosition: location, mouseButton: .left)?
      .post(tap: .cghidEventTap)
  }

  private func simulateScrollEvent(_ type: CGEventType, deltaY: Int32) {
    CGEvent(
      scrollWheelEvent2Source: nil, units: .pixel, wheelCount: 1, wheel1: deltaY, wheel2: 0, wheel3: 0)?
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

  private func getSystemDoubleClickInterval() -> TimeInterval {
    // Retrieves the system-defined double-click interval, which is the maximum
    // time allowed between two consecutive mouse down events for them to be
    // recognized as a double-click.
    // The interval is adjustable by the user in system preferences, typically
    // ranging from 0.15 seconds (faster double-click) to 5 seconds (slower double-click).
    // The default or average value is 1.4 seconds.
    return NSEvent.doubleClickInterval
  }

  private func isWithinSystemDoubleClickTimeInterval(_ previousTime: TimeInterval, now: TimeInterval) -> Bool {
    let interval = getSystemDoubleClickInterval()
    return (now - previousTime) < interval
  }

  private func isWithinDistanceThreshold(_ point1: CGPoint, _ point2: CGPoint) -> Bool {
    return distanceBetweenPoints(point1, point2) < distanceThreshold
  }

  private func distanceBetweenPoints(_ point1: CGPoint, _ point2: CGPoint) -> CGFloat {
    return sqrt(pow(point1.x - point2.x, 2) + pow(point1.y - point2.y, 2))
  }
}
