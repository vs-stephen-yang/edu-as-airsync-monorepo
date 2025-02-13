import Cocoa
import FlutterMacOS
import desktop_multi_window
import system_tray

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
    
    RegisterGeneratedPlugins(registry: flutterViewController)
    
    FlutterMultiWindowPlugin.setOnWindowCreatedCallback { controller in
      // Register the plugin which you want access from other isolate.
      SystemTrayPlugin.register(with: controller.registrar(forPlugin: "SystemTrayPlugin"))
    }
    
    super.awakeFromNib()
  }
}
