import Foundation
import FlutterMacOS

public class AudioSwitch {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel.init(name: "audio_switch_channel", binaryMessenger: registrar.messenger)
    channel.setMethodCallHandler({(_ call: FlutterMethodCall, _ result: FlutterResult) -> Void in
      handleMethodCall(call: call, result: result)
    });
  }
  
  private static func handleMethodCall(call: FlutterMethodCall, result: FlutterResult) -> Void {
    switch call.method {
    case "getDefaultInputDevice":
      result(AudioSwitchHelper.getDefaultInputDevice())
      
    case "getDefaultOutputDevice":
      result(AudioSwitchHelper.getDefaultOutputDevice())
      
    case "getInputDeviceByName":
      result(AudioSwitchHelper.getInputDeviceByName(deviceName: call.arguments as! String))
      
    case "getOutputDeviceByName":
      result(AudioSwitchHelper.getOutputDeviceByName(deviceName: call.arguments as! String))
      
    case "hasInputDevice":
      result(AudioSwitchHelper.hasInputDevice(deviceName: call.arguments as! String))
      
    case "hasOutputDevice":
      result(AudioSwitchHelper.hasOutputDevice(deviceName: call.arguments as! String))
      
    case "setInputDevice":
      result(AudioSwitchHelper.setInputDevice(newDeviceID: call.arguments as! AudioDeviceID))
      
    case "setOutputDevice":
      result(AudioSwitchHelper.setOutputDevice(newDeviceID: call.arguments as! AudioDeviceID))
      
    case "getPairedVirtualAudioDevice":
      if let virtualDevice = AudioSwitchHelper.getPairedVirtualAudioDevice() {
        result([
          "outputDeviceID": virtualDevice.0,
          "inputDeviceID": virtualDevice.1,
          "deviceName": virtualDevice.2
        ])
      } else {
        result(nil)
      }
      
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
