# `Cast to Boards` - Log 盤點

> **圖例**
> - 頻率：`once` = 只觸發一次 / `per-s` = 每秒 / `on-event` = 事件驅動
> - ⬆️ Upload：同時觸發 `castToBoardsSessionLogger.upload()` 上傳到 Sentry

---

## HOST 端

### display_group_host.dart

| Level   | 行號 | 訊息                                                          | 頻率     |
|---------|------|---------------------------------------------------------------|----------|
| info    | :24  | `DisplayGroupHost: Removing member $memberId`                 | on-event |
| info    | :33  | `DisplayGroupHost: Member ... is in reject list, skip adding` | on-event |
| info    | :62  | `DisplayGroupHost: Adding member ...`                         | on-event |
| info    | :68  | `DisplayGroupHost: Stopping all N members`                    | once     |

---

### display_group_mediator.dart

| Level | 行號 | 訊息                                                           | 頻率     |
|-------|------|----------------------------------------------------------------|----------|
| info  | :23  | `DisplayGroupMediator: Creating connector for sessionId=...`  | on-event |
| info  | :34  | `DisplayGroupMediator: Connector created, type=...`           | on-event |

---

### display_group_member.dart

| Level       | 行號 | 訊息                                                                   | 頻率     |
|-------------|------|------------------------------------------------------------------------|----------|
| info        | :74  | WebSocket 連線事件（`$url $message`，WebSocketClientConnectionConfig） | on-event |
| info        | :83  | `DisplayGroupMember [...]: Channel connected`                          | on-event |
| info        | :86  | `DisplayGroupMember [...]: Channel closed, reason=...`                 | on-event |
| info        | :93  | `DisplayGroupMember [...]: Reconnecting...`                            | on-event |
| info        | :115 | `DisplayGroupMember [...]: Member accepted invitation`                 | on-event |
| info        | :118 | `DisplayGroupMember [...]: Member rejected invitation`                 | on-event |
| **warning** | :144 | `Host received FPS zero notification from Display Group member: ...`   | on-event |
| info        | :164 | `DisplayGroupMember [...]: Sending invite`                             | on-event |
| info        | :174 | `DisplayGroupMember [...]: Stopping`                                   | on-event |

---

### remote_screen_connector.dart（Host 端 Connector）

| Level | 行號 | 訊息                                                                     | 頻率     |
|-------|------|--------------------------------------------------------------------------|----------|
| info  | :98  | `RtcScreenConnector: Received StartRemoteScreen, sessionId=...`          | once     |
| info  | :100 | `RtcScreenConnector: Sending accepted status, sessionId=...`             | once     |
| info  | :113 | `RtcScreenConnector: Sending RemoteScreenInfo, roomId=..., sessionId=...`| once     |
| info  | :121 | `RtcScreenConnector: Signal handler registered, sessionId=...`           | once     |
| info  | :139 | `RtcScreenConnector: ICE connection state=..., sessionId=...`            | on-event |

---

### remote_screen_server.dart — RemoteScreenServer

| Level       | 行號 | 訊息                                                                    | 頻率     |        |
|-------------|------|-------------------------------------------------------------------------|----------|--------|
| info        | :134 | `RemoteScreenServer: Publisher already started`                         | on-event |        |
| info        | :141 | `RemoteScreenServer: Starting publisher for room $roomId`               | once     |        |
| **warning** | :162 | `RemoteScreenServer: Failed to start publisher`                         | on-event |        |
| info        | :177 | `RemoteScreenServer: Stopping publisher for room $roomId`               | once     |        |
| info        | :198 | `RemoteScreenServer: Shutting down, skip recreate`                      | on-event |        |
| info        | :202 | `RemoteScreenServer: Recreating entire SfuPublisher`                    | on-event |        |
| **severe**  | :218 | `RemoteScreenServer: Failed to recreate publisher`                      | on-event |        |
| info        | :222 | `RemoteScreenServer: SfuPublisher recreated successfully`               | on-event |        |
| info        | :230 | `RemoteScreenServer: Notifying UI to show zero FPS prompt`              | on-event |        |
| info        | :235 | `RemoteScreenServer: Notifying UI that recreate succeeded`              | on-event |        |
| info        | :240 | `RemoteScreenServer: Notifying UI that recreate failed, shutting down`  | on-event | ⬆️     |
| **warning** | :253 | `RemoteScreenServer: Channel already exists for connector`              | on-event |        |
| **warning** | :267 | exception `e`                                                           | on-event |        |
| **warning** | :284 | `RemoteScreenServer: No channel is found for connector`                 | on-event |        |
| **warning** | :286 | exception `e`                                                           | on-event |        |
| fine        | :291 | `Received message: ${data.text}`                                        | on-event |        |
| **warning** | :326 | exception `e`                                                           | on-event |        |

---

### remote_screen_server.dart — SfuPublisher

| Level       | 行號 | 訊息                                                                           | 頻率     |
|-------------|------|--------------------------------------------------------------------------------|----------|
| **warning** | :380 | `SfuPublisher: Already started`                                                | on-event |
| info        | :384 | `SfuPublisher: Starting for room $_roomId`                                     | once     |
| **warning** | :395 | `Capture permission denied`                                                    | on-event |
| **warning** | :401 | `Background permission denied`                                                 | on-event |
| info        | :409 | `SfuPublisher: Local stream acquired, videoTracks=N`                           | once     |
| **warning** | :411 | `SfuPublisher: No video tracks in local stream, publish will have no video`    | on-event |
| info        | :416 | `SfuPublisher: Stream published to SFU`                                        | once     |
| info        | :421 | `SfuPublisher: Started successfully`                                           | once     |
| **warning** | :430 | `SfuPublisher: No client to recreate`                                          | on-event |
| info        | :434 | `SfuPublisher: Recreating ionSfuClient`                                        | on-event |
| info        | :445 | `SfuPublisher: ionSfuClient recreated successfully`                            | on-event |
| **warning** | :447 | `SfuPublisher: No local stream available, closing new client`                  | on-event |
| info        | :455 | `SfuPublisher: Creating ionSfuClient, uuid=...`                                | on-event |
| info        | :466 | `SfuPublisher: New data channel: label id`                                     | on-event |
| **warning** | :469 | `SfuPublisher: Data channel has no label`                                      | on-event |
| info        | :477 | `SfuPublisher: ionSfuClient uuid Connection state: ...`                        | on-event |
| info        | :527 | `SfuPublisher: Set capture resolution ... for WxH deviceType`                  | once     |
| **severe**  | :565 | `requestBackgroundPermission` + exception + stackTrace                         | on-event |
| info        | :602 | `SfuPublisher: Stats - FPS=..., bitrate=..., available=..., limit=..., ...`    | **per-s**|
| info        | :621 | `Stopping SfuPublisher`                                                        | once     |
| info        | :637 | `SfuPublisher stopped`                                                         | once     |
| info        | :642 | `SfuPublisher: Enable remote control for sessionId enable`                     | on-event |

---

## MEMBER 端

### display_group_session.dart

| Level | 行號 | 訊息                                                           | 頻率 |
|-------|------|----------------------------------------------------------------|------|
| info  | :52  | `DisplayGroupSession: User accepted invitation from $hostName` | once |
| info  | :59  | `DisplayGroupSession: User rejected invitation`                | once |
| info  | :64  | `DisplayGroupSession: Stopping, reason=...`                    | once |
| info  | :122 | `DisplayGroupSession: Sending StartRemoteScreen, sessionId=...`| once |
| info  | :129 | `DisplayGroupSession: Received RemoteScreenInfo, roomId=...`   | once |

---

### remote_screen_client.dart — RtcScreenClient

| Level       | 行號 | 訊息                                                              | 頻率     |    |
|-------------|------|-------------------------------------------------------------------|----------|----|
| info        | :154 | `Remote screen: Stats monitoring started`                         | once     |    |
| info        | :169 | `Remote screen: Stats monitoring stopped`                         | once     |    |
| info        | :192 | `Remote screen: Track monitoring started`                         | once     |    |
| info        | :201 | `Remote screen: Switching active track from ... to ...`           | on-event |    |
| info        | :208 | `Remote screen: Track ... removed: reason`                        | on-event |    |
| info        | :215 | `Remote screen: Checking FPS before close`                        | once     |    |
| info        | :220 | `Remote screen: Data channel state ...`                           | on-event |    |
| info        | :245 | `RtcScreenClient: Using Proxy (channel) signaling mode`           | once     |    |
| info        | :249 | `RtcScreenClient: Using Direct signaling mode, url=...`           | once     |    |
| info        | :263 | `Remote screen: Create client, roomId=..., iceServers count=N`    | once     |    |
| info        | :278 | `Remote screen: ontrack fired, kind=..., trackId=...`             | once     |    |
| info        | :296 | `Remote screen: Video track added, total tracks: N`               | on-event |    |
| info        | :300 | `Remote screen: Single track mode - rendering immediately`        | once     |    |
| info        | :302 | `Remote screen: Renderer initialized, textureId=...`              | once     |    |
| info        | :304 | `Remote screen: srcObject set, streamId=..., videoTracks=N`       | once     |    |
| info        | :311 | `Remote screen: Now in multi-track mode`                          | on-event |    |
| info        | :318 | `Remote screen: Connection state ...`                             | on-event |    |
| **warning** | :328 | `Remote screen: WebRTC disconnected`                              | on-event |    |
| info        | :336 | `Remote screen: WebRTC connected, ontrack fired=...`              | once     |    |
| info        | :346 | `Remote screen: Data channel added label`                         | on-event |    |
| **warning** | :354 | `Remote screen: signal closed, code=..., reason=...`              | on-event | ⬆️ |
| **warning** | :364 | `Remote screen FPS is zero! Sample count: ..., Duration: ...`     | on-event | ⬆️ |
| fine        | :392 | `RtcScreenClient: Signal received via proxy channel`              | on-event |    |
| info        | :409 | `Remote screen: Closing client`                                   | once     |    |
| **warning** | :428 | `texture widget not found`                                        | on-event |    |
| info        | :435 | `texture widget size: (W, H), offset: (X, Y)`                    | on-event |    |

---

### video_track_manager.dart

| Level       | 行號 | 訊息                                                                          | 頻率      |
|-------------|------|-------------------------------------------------------------------------------|-----------|
| info        | :69  | `VideoTrackManager: Track added trackId, total tracks: N`                     | on-event  |
| info        | :84  | `VideoTrackManager: Track trackId removed, remaining: N`                      | on-event  |
| info        | :105 | `VideoTrackManager: Creating stats parser and reporter for track trackId`     | once/track|
| info        | :114 | `VideoTrackManager: Track stats - trackId: FPS=..., loss=..., jitter=..., ...`| **per-s** |
| **warning** | :148 | `VideoTrackManager: Failed to get stats for track trackId: e`                 | on-event  |
| info        | :174 | `VideoTrackManager: Track trackId has null FPS (count: N)`                    | **per-s** |
| info        | :180 | `VideoTrackManager: Removing track trackId, reason: ...`                      | on-event  |
| info        | :190 | `VideoTrackManager: Track trackId has zero FPS (count: N)`                    | **per-s** |
| info        | :195 | `VideoTrackManager: Removing track trackId, reason: ...`                      | on-event  |
| info        | :226 | `VideoTrackManager: No valid tracks, keeping active track ... for monitoring` | **per-s** |
| info        | :233 | `VideoTrackManager: No valid tracks, falling back to first track ...`         | on-event  |
| info        | :237 | `VideoTrackManager: No tracks available`                                      | on-event  |
| info        | :252 | `VideoTrackManager: Switching active track from ... to ..., FPS: N`           | on-event  |
| info        | :288 | `VideoTrackManager: Disposed`                                                 | once      |

---

### rtc_fps_zero_detector.dart

| Level       | 行號 | 訊息                                                                          | 頻率 |
|-------------|------|-------------------------------------------------------------------------------|------|
| info        | :100 | `RtcFpsZeroDetector: Start collecting FPS data`                               | once |
| info        | :137 | `RtcFpsZeroDetector: Not enough samples (N/min). Skipping check. Reason: ...` | once |
| **warning** | :152 | `RtcFpsZeroDetector: All FPS values are zero! Sample count: N, Duration: ...` | once |
| info        | :163 | `RtcFpsZeroDetector: FPS check passed. Non-zero samples (N total). Reason: ...`| once |

---

## 共用

### cast_to_boards_session_logger.dart

| Level       | 行號 | 訊息                                                           | 頻率     |
|-------------|------|----------------------------------------------------------------|----------|
| info        | :61  | `CastToBoardsSessionLogger: Session started, role=...`         | once     |
| info        | :66  | `CastToBoardsSessionLogger: Session stopped, collected N lines`| once     |
| **warning** | :86  | `CastToBoardsSessionLogger: Upload skipped, no active session` | on-event |
| info        | :91  | `CastToBoardsSessionLogger: Uploading session log, reason=...` | on-event |

---

## Upload 觸發點一覽

| 觸發條件                        | 觸發位置                                | Upload reason 字串                                   |
|---------------------------------|-----------------------------------------|------------------------------------------------------|
| Member FPS zero（定時 check）   | `RtcScreenClient._onFpsZero`            | `Member FPS zero: sampleCount=..., ...`              |
| WebRTC connection failed        | `RtcScreenClient.onConnectionState`     | `WebRTC connection failed`                           |
| Signal closed abnormally        | `RtcScreenClient.onSignalClose`         | `Signal closed abnormally: code=..., reason=...`     |
| Host 收到 Member 回報 FPS zero  | `DisplayGroupMember._onChannelMessage`  | `Member reported FPS zero, displayCode=...`          |
| Host recreate max 失敗          | `RemoteScreenServer._handleRecreateFailure` | `Host recreate failed after max attempts`        |

---

## 每秒觸發的 log（噪音提示）

| 檔案                              | 訊息前綴                         | 說明                          |
|-----------------------------------|----------------------------------|-------------------------------|
| `video_track_manager.dart` :114   | `VideoTrackManager: Track stats -` | 每個 track 每秒一筆，含 9 欄位 |
| `video_track_manager.dart` :174/190/226 | null/zero/no-valid FPS  | 異常狀態下每秒打              |
| `remote_screen_server.dart` :602  | `SfuPublisher: Stats -`          | 每秒一筆，含 6 欄位           |
