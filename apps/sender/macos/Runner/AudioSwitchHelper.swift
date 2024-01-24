import Foundation
import Cocoa
import AudioToolbox
import FlutterMacOS

public class AudioSwitchHelper {
    
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
    
    static func getAggregateDeviceSubDeviceList(deviceID: AudioDeviceID) -> [AudioDeviceID] {
        let subDevicesCount = getNumberOfSubDevices(deviceID: deviceID)
        var subDevices = [AudioDeviceID](repeating: 0, count: Int(subDevicesCount))
        
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioAggregateDevicePropertyActiveSubDeviceList),
            mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMain))
        
        var subDevicesSize = subDevicesCount * UInt32(MemoryLayout<UInt32>.size)
        
        AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, nil, &subDevicesSize, &subDevices)
        
        return subDevices
    }
    
    static func isAggregateDevice(deviceID: AudioDeviceID) -> Bool {
        let deviceType = getDeviceTransportType(deviceID: deviceID)
        return deviceType == kAudioDeviceTransportTypeAggregate
    }
    
    static func setDeviceVolume(deviceID: AudioDeviceID, leftChannelLevel: Float, rightChannelLevel: Float) {
        let channelsCount = 2
        var channels = [UInt32](repeating: 0, count: channelsCount)
        var propertySize = UInt32(MemoryLayout<UInt32>.size * channelsCount)
        var leftLevel = leftChannelLevel
        var rightLevel = rightChannelLevel
        
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioDevicePropertyPreferredChannelsForStereo),
            mScope: AudioObjectPropertyScope(kAudioDevicePropertyScopeOutput),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMain))
        
        let status = AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, nil, &propertySize, &channels)
        
        if status != noErr { return }
        
        propertyAddress.mSelector = kAudioDevicePropertyVolumeScalar
        propertySize = UInt32(MemoryLayout<Float32>.size)
        propertyAddress.mElement = channels[0]
        
        AudioObjectSetPropertyData(deviceID, &propertyAddress, 0, nil, propertySize, &leftLevel)
        
        propertyAddress.mElement = channels[1]
        
        AudioObjectSetPropertyData(deviceID, &propertyAddress, 0, nil, propertySize, &rightLevel)
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
    
    static func getDeviceVolume(deviceID: AudioDeviceID) -> [Float] {
        let channelsCount = 2
        var channels = [UInt32](repeating: 0, count: channelsCount)
        var propertySize = UInt32(MemoryLayout<UInt32>.size * channelsCount)
        var leftLevel = Float32(-1)
        var rightLevel = Float32(-1)
        
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioDevicePropertyPreferredChannelsForStereo),
            mScope: AudioObjectPropertyScope(kAudioDevicePropertyScopeOutput),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMain))
        
        let status = AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, nil, &propertySize, &channels)
        
        if status != noErr { return [-1] }
        
        propertyAddress.mSelector = kAudioDevicePropertyVolumeScalar
        propertySize = UInt32(MemoryLayout<Float32>.size)
        propertyAddress.mElement = channels[0]
        
        AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, nil, &propertySize, &leftLevel)
        
        propertyAddress.mElement = channels[1]
        
        AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, nil, &propertySize, &rightLevel)
        
        return [leftLevel, rightLevel]
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
    
    private static func getDeviceTransportType(deviceID: AudioDeviceID) -> AudioDevicePropertyID {
        var deviceTransportType = AudioDevicePropertyID()
        var propertySize = UInt32(MemoryLayout<AudioDevicePropertyID>.size)
        
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioDevicePropertyTransportType),
            mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMain))
        
        AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, nil, &propertySize, &deviceTransportType)
        
        return deviceTransportType
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
    
    static func getNumberOfSubDevices(deviceID: AudioDeviceID) -> UInt32 {
        var propertySize: UInt32 = 0
        
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioAggregateDevicePropertyActiveSubDeviceList),
            mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMain))
        
        _ = AudioObjectGetPropertyDataSize(deviceID, &propertyAddress, 0, nil, &propertySize)
        
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
