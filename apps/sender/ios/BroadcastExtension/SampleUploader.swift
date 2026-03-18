import Foundation
import ReplayKit
import OSLog
import Darwin

private enum Constants {
    static let bufferMaxLength = 10240
    static let targetOutputWidth = 1080
    static let targetOutputHeight = 1440
    static let lowQualityCompression: Float = 0.7
    static let defaultCompression: Float = 1.0
}

private struct VideoFrameHeader {
  var width: UInt32
  var height: UInt32
  var orientation: UInt32
  var palyoadLength: UInt32
}

private struct AudioFrameHeader {
  var sampleRate: UInt32
  var format: UInt32
  var formatFlags: UInt32
  var channelsPerFrame: UInt32
  var bitsPerChannel: UInt32
  var framesPerPacket: UInt32
  var bytesPerFrame: UInt32
  var bytesPerPacket: UInt32
  var reserved: UInt32
  var palyoadLength: UInt32
}

class SampleUploader {
    private enum DeviceProfile {
        case defaultProfile
        case a10FamilyLowQuality
    }

    private enum DeviceIdentifier {
        static let a10Family: Set<String> = [
            "iPad7,5",  // iPad (6th generation) Wi-Fi
            "iPad7,6",  // iPad (6th generation) Wi-Fi + Cellular
            "iPad7,11", // iPad (7th generation) Wi-Fi
            "iPad7,12", // iPad (7th generation) Wi-Fi + Cellular
            "iPhone9,1", // iPhone 7
            "iPhone9,3", // iPhone 7
            "iPhone9,2", // iPhone 7 Plus
            "iPhone9,4", // iPhone 7 Plus
            "iPod9,1"    // iPod touch (7th generation)
        ]
        static let a12Family: Set<String> = [
            "iPhone11,2", // iPhone XS
            "iPhone11,4", // iPhone XS Max
            "iPhone11,6", // iPhone XS Max (China)
            "iPhone11,8", // iPhone XR
            "iPad11,1",   // iPad mini (5th generation) Wi-Fi
            "iPad11,2",   // iPad mini (5th generation) Wi-Fi + Cellular
            "iPad11,3",   // iPad Air (3rd generation) Wi-Fi
            "iPad11,4",   // iPad Air (3rd generation) Wi-Fi + Cellular
            "iPad11,6",   // iPad (8th generation) Wi-Fi
            "iPad11,7"    // iPad (8th generation) Wi-Fi + Cellular
        ]
    }
    
    private static var imageContext = CIContext(options: nil)
    
    @Atomic private var isReady = false
    private var isVideo: Bool
    private var connection: SocketConnection
  
    private var dataToSend: Data?
    private var byteIndex = 0
  
    private let serialQueue: DispatchQueue
    private let deviceProfile: DeviceProfile

    private var videoConstraintWidth = 0
    private var videoConstraintHeight = 0
    private var videoDecodeHeightLimit = 0

    private var currWidth: Int = 0
    private var currHeight: Int = 0
    private var currConstraintHeight: Int = 0
    private var currDecodeHeightLimit: Int = 0
    private var currScaleWidth: Double = 0.0
    private var currScaleHeight: Double = 0.0
    private var currScaleFactor: Double = -1.0
    
    init(connection: SocketConnection, isVideo: Bool) {
        self.connection = connection
        self.serialQueue = DispatchQueue(label: "org.jitsi.meet.broadcast.sampleUploader")
        self.isVideo = isVideo
        self.deviceProfile = Self.resolveDeviceProfile()
        setupConnection()
    }
  
    @discardableResult func send(sample buffer: CMSampleBuffer) -> Bool {
        guard isReady else {
            return false
        }
        
        isReady = false

        dataToSend = prepare(sample: buffer)
        byteIndex = 0

        serialQueue.async { [weak self] in
            self?.sendDataChunk()
        }
        
        return true
    }
    
    func updateConstraint(width: Int, height: Int) {
        videoConstraintWidth = width
        videoConstraintHeight = height
        NSLog("updateConstraint width: \(videoConstraintWidth) height: \(videoConstraintHeight)")
    }
    
    func updateDecodeHeightLimit(decodeHeightLimit: Int) {
        videoDecodeHeightLimit = decodeHeightLimit
        NSLog("videoDecodeHeightLimit: \(videoDecodeHeightLimit)")
    }
}

private extension SampleUploader {
    private static func resolveDeviceProfile() -> DeviceProfile {
        let identifier = currentMachineIdentifier()
        let profile: DeviceProfile = (DeviceIdentifier.a10Family.contains(identifier) || DeviceIdentifier.a12Family.contains(identifier))
            ? .a10FamilyLowQuality
            : .defaultProfile

        os_log(.debug, log: broadcastLogger, "SampleUploader device profile: %{public}s (%{public}s)",
               String(describing: profile),
               identifier)
        return profile
    }

    private static func currentMachineIdentifier() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)

        let mirror = Mirror(reflecting: systemInfo.machine)
        let identifier = mirror.children.reduce(into: "") { result, element in
            guard let value = element.value as? Int8, value != 0 else {
                return
            }
            result.append(Character(UnicodeScalar(UInt8(value))))
        }

        if identifier == "arm64" || identifier == "x86_64" {
            return ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] ?? identifier
        }

        return identifier
    }
    
    func setupConnection() {
        connection.didOpen = { [weak self] in
            self?.isReady = true
        }
        connection.streamHasSpaceAvailable = { [weak self] in
            self?.serialQueue.async {
                if let success = self?.sendDataChunk() {
                    self?.isReady = !success
                }
            }
        }
    }
    
    @discardableResult func sendDataChunk() -> Bool {
        guard let dataToSend = dataToSend else {
            return false
        }
      
        var bytesLeft = dataToSend.count - byteIndex
        var length = bytesLeft > Constants.bufferMaxLength ? Constants.bufferMaxLength : bytesLeft

        length = dataToSend[byteIndex..<(byteIndex + length)].withUnsafeBytes {
            guard let ptr = $0.bindMemory(to: UInt8.self).baseAddress else {
                return 0
            }

            return connection.writeToStream(buffer: ptr, maxLength: length)
        }

        if length > 0 {
            byteIndex += length
            bytesLeft -= length

            if bytesLeft == 0 {
                self.dataToSend = nil
                byteIndex = 0
            }
        } else {
            os_log(.debug, log: broadcastLogger, "writeBufferToStream failure")
        }
      
        return true
    }
  
    func prepare(sample buffer: CMSampleBuffer) -> Data? {
      if self.isVideo {
        return prepareVideo(sample: buffer)
      } else {
        return prepareAudio(sample: buffer)
      }
    }

    func calcScaleFactor(width : Int, height : Int, orientation: UInt, constraintWidth: Int, constraintHeight: Int) -> Double {
        var sourceWidth = width
        var sourceHeight = height
        // if orientation is left or right, width and height should be swapped
        if orientation == CGImagePropertyOrientation.left.rawValue || orientation == CGImagePropertyOrientation.right.rawValue {
            sourceWidth = height
            sourceHeight = width
        }

        let widthScaleFactor: Double
        let heightScaleFactor: Double

        if constraintWidth > 0 {
            widthScaleFactor = Double(sourceWidth) / Double(constraintWidth)
        } else {
            widthScaleFactor = 1.0
        }

        if constraintHeight > 0 {
            heightScaleFactor = Double(sourceHeight) / Double(constraintHeight)
        } else {
            heightScaleFactor = 1.0
        }
        return max(widthScaleFactor, heightScaleFactor)
    }
    
    func calcScaleFactorWithLimitHeight(width: Int, height: Int, orientation: UInt, constraintWidth: Int, constraintHeight: Int, decodeHeightLimit: Int) -> Double {
        // iOS device capture always portrait; constraint size always landscape
        let sourceWidth = width
        let sourceHeight = height
        let portraitConstraintWidth = constraintHeight
        let portraitConstraintHeight = constraintWidth
        var widthScaleFactor: Double
        var heightScaleFactor: Double

        if portraitConstraintWidth > 0 {
            widthScaleFactor = Double(sourceWidth) / Double(portraitConstraintWidth)
        } else {
            widthScaleFactor = 1.0
        }

        if portraitConstraintHeight > 0 {
            let limitHeight = (decodeHeightLimit > 0)
                ? min(constraintHeight, decodeHeightLimit)
                : portraitConstraintHeight
            heightScaleFactor = Double(sourceHeight) / Double(limitHeight)
        } else {
            heightScaleFactor = 1.0
        }
        return max(widthScaleFactor, heightScaleFactor)
    }

    func prepareVideo(sample buffer: CMSampleBuffer) -> Data? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(buffer) else {
            os_log(.debug, log: broadcastLogger, "image buffer not available")
            return nil
        }
        
        CVPixelBufferLockBaseAddress(imageBuffer, .readOnly)

        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        let orientation = CMGetAttachment(buffer, key: RPVideoSampleOrientationKey as CFString, attachmentModeOut: nil)?.uintValue ?? 0

        if deviceProfile == .a10FamilyLowQuality {
            let targetWidth = Constants.targetOutputWidth
            let targetHeight = Constants.targetOutputHeight

            if (width != currWidth || height != currHeight || currConstraintHeight != targetHeight || currDecodeHeightLimit != videoDecodeHeightLimit) {
                currScaleWidth = Double(targetWidth)
                currScaleHeight = Double(targetHeight)
                currWidth = width
                currHeight = height
                currConstraintHeight = targetHeight
                currDecodeHeightLimit = videoDecodeHeightLimit
            }

            let scaleTransform = CGAffineTransform(
                scaleX: CGFloat(Double(targetWidth) / Double(width)),
                y: CGFloat(Double(targetHeight) / Double(height))
            )
            return buildVideoPayload(
                imageBuffer: imageBuffer,
                scaleTransform: scaleTransform,
                outputWidth: targetWidth,
                outputHeight: targetHeight,
                orientation: orientation
            )
        }

        //
        // Calculate the currScaleWidth, currScaleHeight, currScaleFactor if changed
        //
        if (width != currWidth || height != currHeight || currConstraintHeight != videoConstraintHeight || currDecodeHeightLimit != videoDecodeHeightLimit) {
            currScaleFactor = calcScaleFactorWithLimitHeight(width: width, height: height, orientation: orientation, constraintWidth: videoConstraintWidth, constraintHeight: videoConstraintHeight, decodeHeightLimit: videoDecodeHeightLimit)
            currScaleWidth = Double(width)/(currScaleFactor)
            currScaleHeight = Double(height)/(currScaleFactor)

            os_log(.error, log: .default, "#### update currWidth... from %dx%d to %.3fx%.3f Scale:%.3f "
                , width, height, currScaleWidth, currScaleHeight, currScaleFactor)

            // 70703 Workaround to solve iOS WebRTC screen freeze on IFP52-1 issue
            // TODO: improve the while loop
            if (videoConstraintHeight == 720) {
                while(currScaleWidth >= 1000 || currScaleHeight >= 1000) {
                    currScaleFactor += 0.1
                    currScaleWidth = Double(width)/(currScaleFactor)
                    currScaleHeight = Double(height)/(currScaleFactor)

                    os_log(.error, log: .default, "#### update currWidth for IFP52-1 ... to %.3fx%.3f Scale:%.3f "
                    , currScaleWidth, currScaleHeight, currScaleFactor)
                }
            }

            currWidth = width
            currHeight = height
            currConstraintHeight = videoConstraintHeight
            currDecodeHeightLimit = videoDecodeHeightLimit
        }

        let scaleTransform = CGAffineTransform(scaleX: CGFloat(1.0/currScaleFactor), y: CGFloat(1.0/currScaleFactor))
        return buildVideoPayload(
            imageBuffer: imageBuffer,
            scaleTransform: scaleTransform,
            outputWidth: Int(currScaleWidth),
            outputHeight: Int(currScaleHeight),
            orientation: orientation
        )
    }
  
    func prepareAudio(sample buffer: CMSampleBuffer) -> Data? {
        guard let formatDescription = CMSampleBufferGetFormatDescription(buffer) else {
            os_log(.debug, log: broadcastLogger, "failed to get audio format description")
            return nil
        }
      
        guard let streamBasicDescription = CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription) else {
            os_log(.debug, log: broadcastLogger, "failed to get stream basic description")
            return nil
        }
      
        var audioBufferList = AudioBufferList()
        var blockBuffer: CMBlockBuffer?
        
        guard CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(
              buffer,
              bufferListSizeNeededOut: nil,
              bufferListOut: &audioBufferList,
              bufferListSize: MemoryLayout<AudioBufferList>.size,
              blockBufferAllocator: nil,
              blockBufferMemoryAllocator: nil,
              flags: 0,
              blockBufferOut: &blockBuffer) == noErr else {
          os_log(.debug, log: broadcastLogger, "CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer() failed")
          return nil
        }
          
        let buffers = UnsafeMutableAudioBufferListPointer(&audioBufferList)
        var data = Data()
        
        for audioBuffer in buffers {
            if let frame = audioBuffer.mData?.assumingMemoryBound(to: UInt8.self) {
                data.append(frame, count: Int(audioBuffer.mDataByteSize))
            }
        }
      
        var audioFrameHeader = AudioFrameHeader(
              sampleRate: UInt32(streamBasicDescription.pointee.mSampleRate),
              format: streamBasicDescription.pointee.mFormatID,
              formatFlags: streamBasicDescription.pointee.mFormatFlags,
              channelsPerFrame: streamBasicDescription.pointee.mChannelsPerFrame,
              bitsPerChannel: streamBasicDescription.pointee.mBitsPerChannel,
              framesPerPacket: streamBasicDescription.pointee.mFramesPerPacket,
              bytesPerFrame: streamBasicDescription.pointee.mBytesPerFrame,
              bytesPerPacket: streamBasicDescription.pointee.mBytesPerPacket,
              reserved: streamBasicDescription.pointee.mReserved,
              palyoadLength: UInt32(data.count))
        
        var headerData = Data()
        withUnsafeBytes(of: &audioFrameHeader) { pointer in
            headerData.append(contentsOf: pointer)
        }
        
        headerData.append(data);
        
        return headerData
    }

    func buildVideoPayload(imageBuffer: CVPixelBuffer, scaleTransform: CGAffineTransform, outputWidth: Int, outputHeight: Int, orientation: UInt) -> Data? {
        let bufferData = jpegData(from: imageBuffer, scale: scaleTransform)

        CVPixelBufferUnlockBaseAddress(imageBuffer, .readOnly)

        guard let messageData = bufferData else {
            os_log(.debug, log: broadcastLogger, "corrupted image buffer")
            return nil
        }

        var videoFrameHeader = VideoFrameHeader(
          width: UInt32(outputWidth),
          height: UInt32(outputHeight),
          orientation: UInt32(orientation),
          palyoadLength: UInt32(messageData.count))

        var headerData = Data()
        withUnsafeBytes(of: &videoFrameHeader) { pointer in
            headerData.append(contentsOf: pointer)
        }

        headerData.append(messageData)
        return headerData
    }
    
    func jpegData(from buffer: CVPixelBuffer, scale scaleTransform: CGAffineTransform) -> Data? {
        let image = CIImage(cvPixelBuffer: buffer).transformed(by: scaleTransform)
        
        guard let colorSpace = image.colorSpace else {
            return nil
        }

        let compression = (deviceProfile == .a10FamilyLowQuality)
            ? Constants.lowQualityCompression
            : Constants.defaultCompression
        let options: [CIImageRepresentationOption: Float] = [kCGImageDestinationLossyCompressionQuality as CIImageRepresentationOption: compression]

        return SampleUploader.imageContext.jpegRepresentation(of: image, colorSpace: colorSpace, options: options)
    }
}
