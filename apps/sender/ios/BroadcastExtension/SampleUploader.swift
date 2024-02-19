import Foundation
import ReplayKit
import OSLog

private enum Constants {
    static let bufferMaxLength = 10240
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
    
    private static var imageContext = CIContext(options: nil)
    
    @Atomic private var isReady = false
    private var isVideo: Bool
    private var connection: SocketConnection
  
    private var dataToSend: Data?
    private var byteIndex = 0
  
    private let serialQueue: DispatchQueue
    
    init(connection: SocketConnection, isVideo: Bool) {
        self.connection = connection
        self.serialQueue = DispatchQueue(label: "org.jitsi.meet.broadcast.sampleUploader")
        self.isVideo = isVideo
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
}

private extension SampleUploader {
    
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
    
    func prepareVideo(sample buffer: CMSampleBuffer) -> Data? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(buffer) else {
            os_log(.debug, log: broadcastLogger, "image buffer not available")
            return nil
        }
        
        CVPixelBufferLockBaseAddress(imageBuffer, .readOnly)
        
        let scaleFactor = 1.0
        let width = CVPixelBufferGetWidth(imageBuffer)/Int(scaleFactor)
        let height = CVPixelBufferGetHeight(imageBuffer)/Int(scaleFactor)
        let orientation = CMGetAttachment(buffer, key: RPVideoSampleOrientationKey as CFString, attachmentModeOut: nil)?.uintValue ?? 0
                                    
        let scaleTransform = CGAffineTransform(scaleX: CGFloat(1.0/scaleFactor), y: CGFloat(1.0/scaleFactor))
        let bufferData = self.jpegData(from: imageBuffer, scale: scaleTransform)
        
        CVPixelBufferUnlockBaseAddress(imageBuffer, .readOnly)
        
        guard let messageData = bufferData else {
            os_log(.debug, log: broadcastLogger, "corrupted image buffer")
            return nil
        }
        
        var videoFrameHeader = VideoFrameHeader(
          width: UInt32(width), 
          height: UInt32(height), 
          orientation: UInt32(orientation),
          palyoadLength: UInt32(messageData.count))
      
        var headerData = Data()
        withUnsafeBytes(of: &videoFrameHeader) { pointer in
            headerData.append(contentsOf: pointer)
        }
        
        headerData.append(messageData);
        
        return headerData
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
    
    func jpegData(from buffer: CVPixelBuffer, scale scaleTransform: CGAffineTransform) -> Data? {
        let image = CIImage(cvPixelBuffer: buffer).transformed(by: scaleTransform)
        
        guard let colorSpace = image.colorSpace else {
            return nil
        }
      
        let options: [CIImageRepresentationOption: Float] = [kCGImageDestinationLossyCompressionQuality as CIImageRepresentationOption: 1.0]

        return SampleUploader.imageContext.jpegRepresentation(of: image, colorSpace: colorSpace, options: options)
    }
}
