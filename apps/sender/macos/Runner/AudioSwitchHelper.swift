import Foundation
import Cocoa
import AudioToolbox
import FlutterMacOS

public class AudioSwitchHelper {
  
  static let knownVirtualAudioDevices: [String] = [
    "VB-Cable",
    "BlackHole 2ch",
    "BlackHole 16ch",
    "BlackHole 64ch",
    "Loopback Audio"
  ]
  
  static func getOutputDevices() -> [AudioDeviceID: String]? {
    var result: [AudioDeviceID: String] = [:]
    let devices = getAllDevices()
    
    for device in devices {
      if isOutputDevice(deviceID: device) {
        result[device] = getDeviceName(deviceID: device)
      }
    }
    
    return result
  }
  
  static func getInputDevices() -> [AudioDeviceID: String]? {
    var result: [AudioDeviceID: String] = [:]
    let devices = getAllDevices()
    
    for device in devices {
      if isInputDevice(deviceID: device) {
        result[device] = getDeviceName(deviceID: device)
      }
    }
    
    return result
  }
  
  static func getPairedVirtualAudioDevice() -> (AudioDeviceID, AudioDeviceID, String)? {
    guard let outputDevices = getOutputDevices(), let inputDevices = getInputDevices() else {
      return nil
    }
    
    for virtualDeviceName in knownVirtualAudioDevices {
      if let outputDeviceID = outputDevices.first(where: { $0.value == virtualDeviceName })?.key,
         let inputDeviceID = inputDevices.first(where: { $0.value == virtualDeviceName })?.key {
        return (outputDeviceID, inputDeviceID, virtualDeviceName)
      }
    }
    
    return nil
  }
  
  static func getOutputDeviceByName(deviceName: String) -> AudioDeviceID? {
    guard let outputDevices = getOutputDevices() else {
      return nil
    }
    
    if let (deviceID, _) = outputDevices.first(where: { $0.value == deviceName }) {
      return deviceID
    }
    
    return nil
  }
  
  static func getInputDeviceByName(deviceName: String) -> AudioDeviceID? {
    guard let inputDevices = getInputDevices() else {
      return nil
    }
    
    if let (deviceID, _) = inputDevices.first(where: { $0.value == deviceName }) {
      return deviceID
    }
    
    return nil
  }
  
  static func hasInputDevice(deviceName: String) -> Bool {
    if (getInputDeviceByName(deviceName: deviceName) != nil) {
      return true
    }
    return false
  }
  
  static func hasOutputDevice(deviceName: String) -> Bool {
    if (getOutputDeviceByName(deviceName: deviceName) != nil) {
      return true
    }
    return false
  }
  
  static func isOutputDevice(deviceID: AudioDeviceID) -> Bool {
    var propertySize: UInt32 = 256
    
    var propertyAddress = AudioObjectPropertyAddress(
      mSelector: AudioObjectPropertySelector(kAudioDevicePropertyStreams),
      mScope: AudioObjectPropertyScope(kAudioDevicePropertyScopeOutput),
      mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMain))
    
    let status = AudioObjectGetPropertyDataSize(deviceID, &propertyAddress, 0, nil, &propertySize)
    
    if (status == noErr && propertySize > 0) {
      return true
    }
    
    return false
  }
  
  static func isInputDevice(deviceID: AudioDeviceID) -> Bool {
    var propertySize: UInt32 = 256
    
    var propertyAddress = AudioObjectPropertyAddress(
      mSelector: AudioObjectPropertySelector(kAudioDevicePropertyStreams),
      mScope: AudioObjectPropertyScope(kAudioDevicePropertyScopeInput),
      mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMain))
    
    let status = AudioObjectGetPropertyDataSize(deviceID, &propertyAddress, 0, nil, &propertySize)
    
    if (status == noErr && propertySize > 0) {
      return true
    }
    
    return false
  }
  
  static func setInputDevice(newDeviceID: AudioDeviceID) -> Bool {
    let propertySize = UInt32(MemoryLayout<UInt32>.size)
    var deviceID = newDeviceID
    
    var propertyAddress = AudioObjectPropertyAddress(
      mSelector: AudioObjectPropertySelector(kAudioHardwarePropertyDefaultInputDevice),
      mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
      mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMain))
    
    let status = AudioObjectSetPropertyData(AudioObjectID(kAudioObjectSystemObject), &propertyAddress, 0, nil, propertySize, &deviceID)
    
    if (status == noErr) {
      return true
    }
    
    return false
  }
  
  
  static func setOutputDevice(newDeviceID: AudioDeviceID) -> Bool {
    let propertySize = UInt32(MemoryLayout<UInt32>.size)
    var deviceID = newDeviceID
    
    var propertyAddress = AudioObjectPropertyAddress(
      mSelector: AudioObjectPropertySelector(kAudioHardwarePropertyDefaultOutputDevice),
      mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
      mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMain))
    
    let status = AudioObjectSetPropertyData(AudioObjectID(kAudioObjectSystemObject), &propertyAddress, 0, nil, propertySize, &deviceID)
    
    if (status == noErr) {
      return true
    }
    
    return false
  }
  
  static func getDefaultInputDevice() -> AudioDeviceID {
    var propertySize = UInt32(MemoryLayout<AudioDeviceID>.size)
    var deviceID = kAudioDeviceUnknown
    
    var propertyAddress = AudioObjectPropertyAddress(
      mSelector: AudioObjectPropertySelector(kAudioHardwarePropertyDefaultInputDevice),
      mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
      mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMain))
    
    AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &propertyAddress, 0, nil, &propertySize, &deviceID)
    
    return deviceID
  }
  
  static func getDefaultOutputDevice() -> AudioDeviceID {
    var propertySize = UInt32(MemoryLayout<AudioDeviceID>.size)
    var deviceID = kAudioDeviceUnknown
    
    var propertyAddress = AudioObjectPropertyAddress(
      mSelector: AudioObjectPropertySelector(kAudioHardwarePropertyDefaultOutputDevice),
      mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
      mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMain))
    
    AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &propertyAddress, 0, nil, &propertySize, &deviceID)
    
    return deviceID
  }
  
  static func getNumberOfDevices() -> UInt32 {
    var propertySize: UInt32 = 0
    
    var propertyAddress = AudioObjectPropertyAddress(
      mSelector: AudioObjectPropertySelector(kAudioHardwarePropertyDevices),
      mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
      mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMain))
    
    _ = AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &propertyAddress, 0, nil, &propertySize)
    
    return propertySize / UInt32(MemoryLayout<AudioDeviceID>.size)
  }
  
  static func getDeviceName(deviceID: AudioDeviceID) -> String {
    var propertySize = UInt32(MemoryLayout<CFString>.size)
    
    var propertyAddress = AudioObjectPropertyAddress(
      mSelector: AudioObjectPropertySelector(kAudioDevicePropertyDeviceNameCFString),
      mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
      mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMain))
    
    var result: Unmanaged<CFString>?
    
    let status = AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, nil, &propertySize, &result)
    
    if status == noErr, let cfString = result?.takeRetainedValue() {
      return cfString as String
    }
    
    return ""
  }
  
  static func getAllDevices() -> [AudioDeviceID] {
    let devicesCount = getNumberOfDevices()
    var devices = [AudioDeviceID](repeating: 0, count: Int(devicesCount))
    
    var propertyAddress = AudioObjectPropertyAddress(
      mSelector: AudioObjectPropertySelector(kAudioHardwarePropertyDevices),
      mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
      mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMain))
    
    var devicesSize = devicesCount * UInt32(MemoryLayout<UInt32>.size)
    
    _ = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &propertyAddress, 0, nil, &devicesSize, &devices)
    
    return devices
  }
  
}

