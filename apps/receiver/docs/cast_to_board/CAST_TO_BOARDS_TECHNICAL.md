# Cast to Boards - Technical Reference for AI

## 1. 功能核心目標 (High-Level Goal)
讓一台設備 (**Host**) 的畫面能同時廣播給多台接收設備 (**Member**)。技術路徑：**Local Screen Capture -> Local SFU (Ion) -> WebRTC -> Multiple Receivers.**

## 2. 角色與元件架構 (Roles & Components)

### Host (發送端/廣播端)
- **`DisplayGroupHost`**: 成員管理中心。持有 `DisplayGroupMember` 清單，負責處理成員的加入、移除與黑名單。
- **`DisplayGroupMember`**: 代表一個已連線的接收端。負責發送邀請 (`InviteDisplayGroupMessage`)、維護該成員的通訊通道 (`DisplayChannelClient`)。
- **`RemoteScreenServer`**: 廣播服務核心。
  - 啟動本地 **Ion SFU Server** (`flutter_ion_sfu`)。
  - 管理 **`SfuPublisher`**：負責本地螢幕擷取並推流至本地 SFU。
- **`RtcScreenConnector`**: 橋接器。負責在 `RemoteScreenServer` (SFU) 與 `DisplayGroupMember` (WebSocket Channel) 之間轉發 WebRTC 信令 (Signaling)。
- **`DisplayGroupMediator`**: 協調器 (Factory)。負責根據 `Channel` 與 `StartRemoteScreenMessage` 建立對應的 `Connector`。

### Member (接收端)
- **`DisplayGroupSession`**: 接收端 Lifecycle 管理。處理收到邀請後的 UI 反饋 (Accept/Reject)，並發起 `StartRemoteScreenMessage`。
- **`RtcScreenClient`**: 播放端核心。建立與 Host SFU 的 WebRTC 連線，並透過 `RTCVideoView` 渲染畫面。

## 3. 核心業務流程 (Signaling Sequence)

### 3.1 標準連線流程
1.  **連線建立**: Member 透過 WebSocket 連上 Host。
2.  **狀態同步**: Member 發送 `DisplayStatusMessage`。
3.  **發送邀請**: Host 收到狀態後，發送 `InviteDisplayGroupMessage` 給 Member。
4.  **接受邀請**: Member 使用者點選接受，回傳 `InviteDisplayGroupResultMessage (accept)`。
5.  **請求畫面**: Member 主動發送 `StartRemoteScreenMessage` (包含 `sessionId`)。
6.  **建立連線 (Signaling Phase)**:
    - Host 收到請求，建立 `RtcScreenConnector`。
    - Host 回傳 `RemoteScreenInfoMessage` (包含 SFU RoomID 與 WebSocket URL: `ws://host_ip:7000/ws`)。
    - 雙方交換 WebRTC SDP/ICE (詳見 3.2 信令傳輸模式)。
7.  **串流傳輸**: WebRTC Connection 建立後，Member 端的 `RTCVideoView` 開始渲染畫面。

### 3.2 信令傳輸模式 (Signaling Modes)
程式碼 (`RemoteScreenClient._createSignal`) 支援兩種模式，目前預設為 **Direct Mode**：
*   **Direct Mode (Active)**: Host 回傳的 `RemoteScreenInfoMessage` 包含 SFU URL (`ws://host_ip:7000/ws`)。Member 收到後，會建立**全新的 WebSocket 連線**直接對接 Host 的 7000 Port 進行 SDP 交換。此模式要求網路環境允許 7000 Port 通行。
*   **Proxy Mode (Fallback/Legacy)**: 若 URL 為空，Member 才會走 `RemoteScreenChannelSignal`，將 WebRTC 信令包在 `RemoteScreenSignalMessage` 內，透過原本的控制通道轉發 (`DisplayGroupMember` <-> `RtcScreenConnector`)。

### 3.3 關鍵訊息對照 (Message Mapping)
*   **邀請**: `InviteDisplayGroupMessage` (Host -> Member)
*   **同意**: `InviteDisplayGroupResultMessage` (status: 'accept') (Member -> Host)
*   **請求畫面**: `StartRemoteScreenMessage` (Member -> Host, 帶有 `sessionId`)
*   **SFU 資訊**: `RemoteScreenInfoMessage` (Host -> Member, 帶有 `roomId`, `signalUrl`)
*   **信令轉發 (Proxy Mode Only)**: `RemoteScreenSignalMessage`
*   **狀態同步**: `RemoteScreenStatusMessage` (用於交換 `fpsZero` 或 `accepted` 狀態)

## 4. 關鍵技術細節 (Implementation Notes)

### 4.1 零幀率偵測與復原機制 (Zero FPS & Auto-Recovery)
為了防止畫面靜止 (Black Screen/Freeze)，兩端皆有偵測機制：
- **Host 端 (`ZeroFpsDetector`)**: 
  - 監控 `SfuPublisher` 的 `framesSentPerSecond`。
  - 若數值為 0，會嘗試 **自動重建 Publisher** (最多重試 3 次，參考 `_recreateSfuPublisher`)。
- **Member 端 (`RtcFpsZeroDetector`)**: 
  - 監控 `RTCVideoView` 的接收幀率。
  - 若偵測到異常，會發送 `RemoteScreenStatus.fpsZero` 給 Host。
- **Host 收到通知**: `DisplayGroupMember` 收到 `fpsZero` 訊息後，會觸發 Log 上傳 (`LogUploaderWithCooldown`) 並可能觸發 UI 提示或重啟流程。

### 4.2 觸控回傳協定 (Touchback Protocol)
支援將 Member 的觸控事件回傳給 Host。
- **通道**: WebRTC Data Channel (Label: `sessionId`)。
- **格式**: Protocol Buffers (`internal.pb.dart`)。
- **流程**: `RtcScreenClient` 捕捉 Flutter PointerEvent -> 轉換為 `TouchEvent` (Protobuf) -> 序列化後發送。Host 端由 `SfuPublisher` 接收並透過 `TouchEventManager` 注入系統事件。
- **限制**: 僅當 Host 端 `flavor` 為 `ifp` 或 `edla` 時才啟用 (`RemoteControlChannel.setControlAllowed`)。

### 4.3 版本比對
- `DisplayGroupMember.isVersionGreater` 用於確保 Host 與 Member 之間的功能相容性。

## 5. 常見維護/Debug 切入點

- **信令失敗**: 
  - Direct Mode: 檢查 Member 是否能連上 Host 的 7000 Port (防火牆問題)。
  - Proxy Mode: 檢查 `DisplayGroupMember._onChannelMessage` 與 `RtcScreenConnector` 之間的信令轉發。
- **畫面黑屏**:
  - 檢查 Host 端 `SfuPublisher` 是否成功 `start()`。
  - 檢查 Member 端 `RtcScreenClient` 的 `ontrack` 是否觸發。
  - 檢查 `ZeroFpsDetector` 是否觸發了自動重建。
- **觸控失效**: 
  - 檢查 `RemoteControlChannel` 的 `setControlAllowed` 狀態。
  - 確認 Host 設備型號 (`flavor`) 是否支援。
  - 檢查 Protobuf 序列化/反序列化是否正確。

## 6. 關鍵文件目錄

- **Host Logic**: `lib/model/display_group_host.dart`, `lib/model/remote_screen_server.dart`.
- **Member Logic**: `lib/model/display_group_session.dart`, `lib/model/remote_screen_client.dart`.
- **Common Models**: `lib/model/remote_screen_connector.dart`.
