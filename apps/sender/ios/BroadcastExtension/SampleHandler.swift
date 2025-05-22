//
//  SampleHandler.swift
//  BroadcastExtension
//
//  Created by SSI ViewSonic on 2023/12/8.
//

import ReplayKit
import OSLog

let broadcastLogger = OSLog(subsystem: "com.viewsonic.display.cast", category: "Broadcast")
private enum Constants {
    // the App Group ID value that the app and the broadcast extension targets are setup with. It differs for each app.
    static let appGroupIdentifier = "group.com.viewsonic.display.cast"
}

class SampleHandler: RPBroadcastSampleHandler {

    private var videoClientConnection: SocketConnection?
    private var videoUploader: SampleUploader?
    
    private var audioClientConnection: SocketConnection?
    private var audioUploader: SampleUploader?
    
    private var frameCount: Int = 0

    func getSocketFilePath(isVideo: Bool) -> String {
      let sharedContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupIdentifier)
      if (isVideo) {
        return sharedContainer?.appendingPathComponent("rtc_SSFD_video").path ?? ""
      }
      else {
        return sharedContainer?.appendingPathComponent("rtc_SSFD_audio").path ?? ""
      }
    }

    override init() {
      super.init()
      initVideoSampler();
      initAudioSampler();
    }

    func updateVideoConstraint() {
      let defaults = UserDefaults(suiteName: Constants.appGroupIdentifier)
      let width = defaults?.integer(forKey: "constraintWidth") ?? 0
      let height = defaults?.integer(forKey: "constraintHeight") ?? 0
      let decodeHeightLimit = defaults?.integer(forKey: "decodeHeightLimit") ?? 0
      videoUploader?.updateDecodeHeightLimit(decodeHeightLimit: decodeHeightLimit)
      videoUploader?.updateConstraint(width: width, height: height)
    }
    
    func onConstraintUpadtedCB() {
      NSLog("onConstraintUpadtedCB")
      updateVideoConstraint()
    }

    func initVideoSampler() {
      let filePath = getSocketFilePath(isVideo: true);
      if let connection = SocketConnection(filePath: filePath) {
        videoClientConnection = connection
        setupConnection(videoClientConnection)
        videoUploader = SampleUploader(connection: connection, isVideo: true)
        updateVideoConstraint()
      }
      os_log(.debug, log: broadcastLogger, "initVideoSampler: %{public}s", filePath)

      // Void pointer to `self`:
      let observer = UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
      let notificationName = "constraintUpdated" as CFString
      let notificationCenter = CFNotificationCenterGetDarwinNotifyCenter()
      CFNotificationCenterAddObserver(
        notificationCenter,
        observer,
        { (_, observer, name, _, _) -> Void in
          if let observer = observer, let name = name {
            // Extract pointer to `self` from void pointer:
            let mySelf = Unmanaged<SampleHandler>.fromOpaque(observer).takeUnretainedValue()
            // Call instance method:
            mySelf.onConstraintUpadtedCB()
          }
        },
        notificationName,
        nil,
        .deliverImmediately)
    }
  
    func initAudioSampler() {
      let filePath = getSocketFilePath(isVideo: false);
      if let connection = SocketConnection(filePath: filePath) {
        audioClientConnection = connection
        setupConnection(audioClientConnection)
        audioUploader = SampleUploader(connection: connection, isVideo: false)
      }
      os_log(.debug, log: broadcastLogger, "initAudioSampler: %{public}s", filePath)
    }

    override func broadcastStarted(withSetupInfo setupInfo: [String: NSObject]?) {
        // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
        frameCount = 0

        DarwinNotificationCenter.shared.postNotification(.broadcastStarted)
        openConnection(videoClientConnection)
        openConnection(audioClientConnection)
    }
    
    override func broadcastPaused() {
        // User has requested to pause the broadcast. Samples will stop being delivered.
    }
    
    override func broadcastResumed() {
        // User has requested to resume the broadcast. Samples delivery will resume.
    }
    
    override func broadcastFinished() {
        // User has requested to finish the broadcast.
        DarwinNotificationCenter.shared.postNotification(.broadcastStopped)
        videoClientConnection?.close()
        audioClientConnection?.close()
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
        case .video:
          videoUploader?.send(sample: sampleBuffer)
        case .audioApp:
          audioUploader?.send(sample: sampleBuffer)
        default:
            break
        }
    }
}

private extension SampleHandler {

    func setupConnection(_ connection: SocketConnection?) {
      connection?.didClose = { [weak self] error in
        os_log(.debug, log: broadcastLogger, "client connection did close \(String(describing: error))")

        if let error = error {
            self?.finishBroadcastWithError(error)
        } else {
            // Gracefully finish the broadcast when the connection is closed
            if let strongSelf = self {
              finishBroadcastGracefully(strongSelf)
            }
        }
      }
    }

    func openConnection(_ connection: SocketConnection?) {
        let queue = DispatchQueue(label: "broadcast.connectTimer")
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now(), repeating: .milliseconds(100), leeway: .milliseconds(500))
        timer.setEventHandler { [] in
            guard connection?.open() == true else {
                return
            }
            timer.cancel()
        }
        timer.resume()
    }
}
