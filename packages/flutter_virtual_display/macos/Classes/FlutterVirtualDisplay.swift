#if AIRSYNC_OPEN
import FlutterMacOS
import CoreGraphics

class FlutterVirtualDisplay {
  private var virtualDisplay: CGVirtualDisplay?
  private var eventSink: (([String: Any]) -> Void)?

  // 定義狀態以避免重複執行
  private enum State {
    case stopped, starting, running
  }
  private var currentState: State = .stopped

  // 常數建議使用 static 以節省記憶體空間
  private static let displayName = "AirSync"
  private static let defaultDisplayWidth: UInt32 = 1920
  private static let defaultDisplayHeight: UInt32 = 1080
  private static let displaySize = CGSize(width: 1800, height: 1012.5)
  private static let vendorID: UInt32 = 0x0543 // ViewSonic
  private static let productID: UInt32 = 0x1234
  private static let serialNumber: UInt32 = 0x0001
  
  private static let retryInterval: TimeInterval = 0.1 // 100 ms
  private static let maxWaitTime: TimeInterval = 3.0
  private static var maxRetry: Int { Int(maxWaitTime / retryInterval) }
  private var retryCount = 0
  private var displayObserver: NSObjectProtocol?
  
  init(eventSink: (([String: Any]) -> Void)? = nil) {
    self.eventSink = eventSink
  }
  
  func initialize() -> Bool {
    notifyEvent(event: "virtualDisplayInitialized", success: true, errorMessage: nil)
    return true
  }
  
  func isSupported() -> Bool {
    // TODO check if CGVirtualDisplay is supported (macOS 10.14?)
    // https://source.chromium.org/chromium/chromium/src/+/main:ui/display/mac/test/virtual_display_mac_util.mm;drc=db6f1567b8caa6dacdd0d46b2a7ac60c5b5ddc82;l=339
    if #available(macOS 10.15, *) {
      return true
    }
    return false
  }

  func startVirtualDisplay(width: UInt32, height: UInt32) -> Bool {
    guard currentState == .stopped else {
      notifyEvent(event: "virtualDisplayError", success: false, errorMessage: "Virtual display already started")
      return false
    }

    currentState = .starting
    retryCount = 0

    // 監聽系統螢幕變動通知
    displayObserver = NotificationCenter.default.addObserver(
      forName: NSApplication.didChangeScreenParametersNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      // 當收到系統通知時，立即進行檢查
      self?.attemptDetectVirtualDisplay()
    }

    let pixelWidth = width > 0 ? width : Self.defaultDisplayWidth
    let pixelHeight = height > 0 ? height : Self.defaultDisplayHeight
    virtualDisplay = createDisplay(name: Self.displayName, width: pixelWidth, height: pixelHeight)

    // 主動執行第一次檢查
    self.attemptDetectVirtualDisplay()
    return true
  }
  
  func stopVirtualDisplay() -> Bool {
    virtualDisplay = nil // 釋放物件
    cleanupObserver();
    currentState = .stopped
    notifyEvent(event: "virtualDisplayStopped", success: true, errorMessage: nil)
    return true // 原程式碼回傳 false，建議改為 true 表示成功停止
  }
  
  private func createDisplay(name: String, width: UInt32, height: UInt32) -> CGVirtualDisplay {
    let desc = CGVirtualDisplayDescriptor()
    desc.setDispatchQueue(DispatchQueue.main)
    desc.terminationHandler = { [weak self] a, b in
      self?.notifyEvent(event: "virtualDisplayError",
                        success: true,
                        errorMessage: "\(String(describing: a)), \(String(describing: b))")
    }
    desc.name = name
    desc.maxPixelsWide = width
    desc.maxPixelsHigh = height
    desc.sizeInMillimeters = Self.displaySize
    desc.productID = Self.productID
    desc.vendorID = Self.vendorID
    desc.serialNum = Self.serialNumber

    let display = CGVirtualDisplay(descriptor: desc)
    let settings = CGVirtualDisplaySettings()
    settings.hiDPI = 2
    settings.modes = [
      CGVirtualDisplayMode(width: UInt(width), height: UInt(height), refreshRate: 60),
      CGVirtualDisplayMode(width: UInt(width), height: UInt(height), refreshRate: 30),
    ]
    display.apply(settings)
    return display
  }
  
  private func checkVirtualDisplayExists() -> Bool {
    var actualCount: UInt32 = 0
    CGGetOnlineDisplayList(0, nil, &actualCount) // 先取得數量

    var onlineDisplays = [CGDirectDisplayID](repeating: 0, count: Int(actualCount))
    guard CGGetOnlineDisplayList(actualCount, &onlineDisplays, &actualCount) == .success else {
      return false
    }

    return onlineDisplays.contains { displayID in
        CGDisplayVendorNumber(displayID) == Self.vendorID &&
        CGDisplayModelNumber(displayID) == Self.productID
    }
  }
  
  private func attemptDetectVirtualDisplay() {
    // 1. 檢查螢幕是否存在
    if checkVirtualDisplayExists() {
      // 只有在 starting 狀態下才發送事件，避免 running 狀態下被 Notification 重複觸發
      if currentState == .starting {
        currentState = .running
        notifyEvent(event: "virtualDisplayStarted", success: true, errorMessage: nil)
        cleanupObserver()
      }
      return
    }

    // 2. 超時處理
    guard retryCount < Self.maxRetry else {
      virtualDisplay = nil // 釋放物件
      cleanupObserver()
      currentState = .stopped
      notifyEvent(event: "virtualDisplayError", success: false, errorMessage: "Virtual display not detected after retries")
      return
    }

    // 3. 遞迴排程
    retryCount += 1

    // 確保排程不會因為 Notification 頻繁觸發而堆疊 (選擇性優化)
    NSObject.cancelPreviousPerformRequests(withTarget: self)

    DispatchQueue.main.asyncAfter(deadline: .now() + Self.retryInterval) { [weak self] in
        self?.attemptDetectVirtualDisplay()
    }
  }
  
  private func cleanupObserver() {
    if let observer = displayObserver {
      NotificationCenter.default.removeObserver(observer)
      displayObserver = nil
    }
  }
  
  private func notifyEvent(event: String, success: Bool, errorMessage: String?) {
    var eventData: [String: Any] = [
      "event": event,
      "success": success
    ]
    if let error = errorMessage {
      eventData["errorMessage"] = error
    }
    eventSink?(eventData)
  }
}
#endif //AIRSYNC_OPEN
