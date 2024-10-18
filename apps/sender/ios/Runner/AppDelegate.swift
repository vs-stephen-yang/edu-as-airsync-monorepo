import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  // set supported orientation to portrait for splash screen display
  // after flutter started, MyApp widget will restore to all orientation
  var supportedOrientation: UIInterfaceOrientationMask = .portrait

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "com.viewsonic.display.cast/supportedOrientation", binaryMessenger: controller.binaryMessenger)

    channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: FlutterResult) in
        if call.method == "setSupportedOrientationAll" {
           self?.supportedOrientation = .all
        }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

    // override supported interface orientations
    override func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return supportedOrientation
    }
}
