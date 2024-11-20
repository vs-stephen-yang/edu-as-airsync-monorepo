import Cocoa
import CoreGraphics
import FlutterMacOS

public class FlutterInputInjectionPlugin: NSObject, FlutterPlugin {
  private var eventQueue: [(action: Int, id: Int, x: Int, y: Int)] = []
  private var queueLock = NSLock()
  private var isConsuming = false
  private var lastMouseDownEvent: (action: Int, id: Int, x: Int, y: Int)? = nil
  private var skipEventsUntilMouseUp: Bool = false
  private var mouseDown: Bool = false
  private let distanceThreshold: CGFloat = 25

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "flutter_input_injection", binaryMessenger: registrar.messenger)
    let instance = FlutterInputInjectionPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
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

      queueLock.lock()
      eventQueue.append((action: action, id: id, x: x, y: y))
      queueLock.unlock()

      if !isConsuming {
        isConsuming = true
        DispatchQueue.global(qos: .default).async { [weak self] in
          self!.consumeEvents()
        }
      }
      result(true)

    case "getPlatformVersion":
      result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func consumeEvents() {
    while true {
      queueLock.lock()
      guard !eventQueue.isEmpty else {
        isConsuming = false
        queueLock.unlock()
        break
      }

      let eventsToProcess = eventQueue
      eventQueue.removeAll()
      queueLock.unlock()

      processEventBatch(events: eventsToProcess)
    }
  }

  private func processEventBatch(events: [(action: Int, id: Int, x: Int, y: Int)]) {
    for i in 0..<events.count {
      let event = events[i]
      switch event.action {
      case 0:  // mouse left down
        handleMouseDown(event)
        break

      case 1:  // mouse move
        handleMouseMove(event)
        break

      case 2:  // mouse left up
        handleMouseUp(event)
        break

      default:
        break
      }
    }
  }

  private func handleMouseDown(_ event: (action: Int, id: Int, x: Int, y: Int)) {
    if skipEventsUntilMouseUp {
      return
    }

    if lastMouseDownEvent != nil {
      if isWithinDistanceThreshold(toCGPoint(lastMouseDownEvent!), toCGPoint(event)) {

        lastMouseDownEvent = nil
        skipEventsUntilMouseUp = true
        mouseDown = true

        simulateMouseLeftDoubleClickEvent(CGPoint(x: event.x, y: event.y))
        return
      }
    }

    lastMouseDownEvent = event
    mouseDown = true

    simulateMouseEvent(.leftMouseDown, at: CGPoint(x: event.x, y: event.y))
  }

  private func handleMouseMove(_ event: (action: Int, id: Int, x: Int, y: Int)) {
    if !mouseDown || skipEventsUntilMouseUp {
      return
    }
    simulateMouseEvent(.mouseMoved, at: CGPoint(x: event.x, y: event.y))
  }

  private func handleMouseUp(_ event: (action: Int, id: Int, x: Int, y: Int)) {
    if !mouseDown {
      return
    }
    if skipEventsUntilMouseUp {
      skipEventsUntilMouseUp = false
    } else {
      simulateMouseEvent(.leftMouseUp, at: CGPoint(x: event.x, y: event.y))
    }
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

  private func isWithinDistanceThreshold(_ point1: CGPoint, _ point2: CGPoint) -> Bool {
    return distanceBetweenPoints(point1, point2) < distanceThreshold
  }

  private func distanceBetweenPoints(_ point1: CGPoint, _ point2: CGPoint) -> CGFloat {
    return sqrt(pow(point1.x - point2.x, 2) + pow(point1.y - point2.y, 2))
  }
}
