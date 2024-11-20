import Cocoa
import CoreGraphics
import FlutterMacOS

public class FlutterInputInjectionPlugin: NSObject, FlutterPlugin {
  private var lastMouseDownEvent: (action: Int, id: Int, x: Int, y: Int, timestamp: TimeInterval)? =
    nil
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

      processEvent((action: action, id: id, x: x, y: y))
      result(true)

    case "getPlatformVersion":
      result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func processEvent(_ event: (action: Int, id: Int, x: Int, y: Int)) {
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
