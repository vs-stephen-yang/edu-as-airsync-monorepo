#if AIRSYNC_OPEN
import FlutterMacOS

class FlutterVirtualDisplay {
  private var virtualDisplay: CGVirtualDisplay?
  private var eventSink: (([String: Any]) -> Void)?
  
  private let displayName = "AirSync"
  private let defaultDisplayWidth: UInt32 = 1920
  private let defaultDisplayHeight: UInt32 = 1080
  private let displaySize = CGSize(width: 1800, height: 1012.5)
  private let vendorID: UInt32 = 0x0543 // ViewSonic
  private let productID: UInt32 = 0x1234
  private let serialNumber: UInt32 = 0x0001
  
  private let retryInterval: TimeInterval = 0.1 // 100 ms
  private let maxWaitTime: TimeInterval = 3.0
  private var maxRetry: Int { Int(maxWaitTime / retryInterval) }
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
    return true
  }

  func startVirtualDisplay(width: UInt32, height: UInt32) -> Bool {
    if virtualDisplay != nil {
      notifyEvent(event: "virtualDisplayError", success: false, errorMessage: "Virtual display already started")
      return false
    }
    
    retryCount = 0
    
    let notificationCenter = NotificationCenter.default
    displayObserver = notificationCenter.addObserver(
      forName: NSApplication.didChangeScreenParametersNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      self?.attemptDetectVirtualDisplay()
    }

    let pixelWidth = width > 0 ? width : defaultDisplayWidth
    let pixelHeight = height > 0 ? height : defaultDisplayHeight
    virtualDisplay = createDisplay(name: displayName, width: pixelWidth, height: pixelHeight)

    return true
  }
  
  func stopVirtualDisplay() -> Bool {
    virtualDisplay = nil
    cleanupObserver();
    notifyEvent(event: "virtualDisplayStopped", success: true, errorMessage: nil)
    return false
  }
  
  func createDisplay(name: String, width: UInt32, height: UInt32) -> CGVirtualDisplay {
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
    desc.sizeInMillimeters = displaySize
    desc.productID = productID
    desc.vendorID = vendorID
    desc.serialNum = serialNumber

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
    let maxDisplays: UInt32 = 10; // Reasonable max number of displays
    var onlineDisplays = [CGDirectDisplayID](repeating: 0, count: Int(maxDisplays))
    var actualCount: UInt32 = 0
    guard CGGetOnlineDisplayList(maxDisplays, &onlineDisplays, &actualCount) == .success else {
      return false
    }
    
    for i in 0..<Int(actualCount) {
      let displayID = onlineDisplays[i]
      let vendorID = CGDisplayVendorNumber(displayID)
      let productID = CGDisplayModelNumber(displayID)
      if (vendorID == self.vendorID && productID == self.productID) {
        return true
      }
    }
    
    return false
  }
  
  private func attemptDetectVirtualDisplay() {
    guard retryCount < maxRetry else {
      notifyEvent(event: "virtualDisplayError", success: false, errorMessage: "Virtual display not detected after retries")
      cleanupObserver()
      return
    }

    retryCount += 1

    DispatchQueue.main.asyncAfter(deadline: .now() + retryInterval) { [weak self] in
      guard let self = self else { return }
      if self.checkVirtualDisplayExists() {
        self.notifyEvent(event: "virtualDisplayStarted", success: true, errorMessage: nil)
        self.cleanupObserver()
      } else {
        self.attemptDetectVirtualDisplay()
      }
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
