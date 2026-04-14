# Cast to Boards - Troubleshooting Guide

> 本文件以 **log 為導向**，協助從 log 快速定位問題點。
> 閱讀 log 時請先確認 Role（HOST / MEMBER），再對照下方場景。

---

## 目錄

1. [連線建立失敗](#1-連線建立失敗)
2. [畫面黑屏 / 無畫面](#2-畫面黑屏--無畫面)
3. [畫面凍結 / FPS 為零](#3-畫面凍結--fps-為零)
4. [信令異常斷開](#4-信令異常斷開)
5. [WebRTC 連線中斷](#5-webrtc-連線中斷)
6. [觸控回傳失效](#6-觸控回傳失效)
7. [快速定位 Checklist](#7-快速定位-checklist)
8. [正常連線 Log 參考範本](#8-正常連線-log-參考範本)

---

## 1. 連線建立失敗

Member 接受邀請後無法看到畫面，或畫面完全不出現。

### 1.1 Member 沒收到邀請

| 要找的 log | 位置 | 說明 |
|-----------|------|------|
| **有**：`DisplayGroupMember [...]: Member accepted invitation` | HOST :115 | HOST 這邊正常，問題在 MEMBER 側 |
| **沒有**：任何 `DisplayGroupMember` log | HOST | HOST 從未建立 Member 物件，檢查 WebSocket 連線 |
| `DisplayGroupMember [...]: Channel closed, reason=...` | HOST :86 | WebSocket 通道提早關閉，MEMBER 沒收到邀請 |

**診斷路徑**：
```
HOST: DisplayGroupHost: Adding member ...          ← Member 有被加入嗎？
HOST: DisplayGroupMember [...]: Sending invite     ← 邀請有發出去嗎？
HOST: DisplayGroupMember [...]: Member accepted    ← Member 有回應嗎？
```

若 `Adding member` 沒出現 → 檢查 WebSocket 連線是否成功建立。
若 `Sending invite` 沒出現 → `DisplayGroupMember` 初始化問題。
若 `Member accepted` 沒出現 → MEMBER 端用戶未接受，或 WebSocket 通道中斷。

---

### 1.2 Signaling 階段失敗（SFU 連線建不起來）

| 要找的 log | 位置 | 說明 |
|-----------|------|------|
| `DisplayGroupSession: Sending StartRemoteScreen, sessionId=...` | MEMBER :122 | MEMBER 發出請求 |
| `RtcScreenConnector: Received StartRemoteScreen, sessionId=...` | HOST :98 | HOST 收到請求 |
| `RtcScreenConnector: Sending RemoteScreenInfo, roomId=..., signalUrl=...` | HOST :113 | HOST 回傳 SFU 資訊 |
| `DisplayGroupSession: Received RemoteScreenInfo, roomId=...` | MEMBER :129 | MEMBER 收到 SFU 資訊 |
| `Remote screen: Create client, roomId=..., iceServers count=N` | MEMBER :263 | WebRTC client 建立 |

**診斷路徑**：

```
MEMBER: Sending StartRemoteScreen       ← MEMBER 發出了嗎？
HOST:   Received StartRemoteScreen      ← HOST 收到了嗎？
HOST:   Sending RemoteScreenInfo        ← HOST 回傳了嗎？
MEMBER: Received RemoteScreenInfo       ← MEMBER 收到了嗎？
MEMBER: Create client, iceServers=N     ← WebRTC client 建立了嗎？
```

**常見卡點**：

| 卡在哪裡 | 可能原因 |
|---------|---------|
| HOST 沒收到 `StartRemoteScreen` | WebSocket channel 斷線（見 `Channel closed` log） |
| MEMBER 沒收到 `RemoteScreenInfo` | HOST 處理邏輯問題 |
| `iceServers count=0` | TURN/STUN 配置問題，NAT 穿透可能失敗 |

---

### 1.3 Direct Mode 7000 Port 不通

**信令模式判斷**：
```
MEMBER: RtcScreenClient: Using Direct signaling mode, url=ws://...  ← Direct Mode（預設）
MEMBER: RtcScreenClient: Using Proxy (channel) signaling mode       ← Proxy Mode
```

**Direct Mode 失敗特徵**：
- `signalUrl` 有值，但 WebRTC 連線一直停在 `checking` 或 `disconnected`
- 沒有 `Remote screen: ontrack fired` log 出現
- **解法**：確認 Host 的 7000 Port 未被防火牆封鎖，或切換至 Proxy Mode

---

### 1.4 Publisher 啟動失敗

| 要找的 log | 位置 | 說明 |
|-----------|------|------|
| `RemoteScreenServer: Starting publisher for room $roomId` | HOST :141 | Publisher 開始啟動 |
| `SfuPublisher: Started successfully` | HOST :421 | 啟動成功 |
| ⚠️ `RemoteScreenServer: Failed to start publisher` | HOST :162 | **啟動失敗** |
| ⚠️ `Capture permission denied` | HOST :395 | 螢幕擷取權限被拒 |
| ⚠️ `Background permission denied` | HOST :401 | 背景執行權限被拒 |
| ⚠️ `SfuPublisher: No video tracks in local stream` | HOST :411 | 本地串流無影像 |

若看到 `Failed to start publisher`，往上找權限拒絕相關 log。

---

## 2. 畫面黑屏 / 無畫面

連線建立成功（WebRTC connected），但畫面是黑的。

### 2.1 Track 未送達 MEMBER

| 要找的 log | 位置 | 說明 |
|-----------|------|------|
| `Remote screen: WebRTC connected, ontrack fired=true` | MEMBER :336 | `ontrack fired=false` 表示 track 沒來 |
| `Remote screen: ontrack fired, kind=video, trackId=...` | MEMBER :278 | Video track 到了 |
| `Remote screen: Video track added, total tracks: N` | MEMBER :296 | VideoTrackManager 加入 track |
| `Remote screen: srcObject set, streamId=..., videoTracks=N` | MEMBER :304 | 渲染器綁定 stream |

若 `WebRTC connected, ontrack fired=false`：
- HOST 端 SfuPublisher 是否有成功推流？（找 `SfuPublisher: Stream published to SFU`）
- SFU 本身是否正常運作？

若 `ontrack fired` 觸發但 `srcObject set` 沒出現：
- `VideoTrackManager` 的 track 管理邏輯可能出現問題

---

### 2.2 HOST 端推流異常

在 HOST 端找 **每秒一次** 的 Stats log：
```
SfuPublisher: Stats - FPS=0, bitrate=0, ...    ← FPS=0 表示沒有畫面送出
SfuPublisher: Stats - FPS=30, bitrate=...      ← 正常
```

若 `FPS=0` 持續出現，HOST 端的 `ZeroFpsDetector` 會觸發自動重建：
```
RemoteScreenServer: Recreating entire SfuPublisher    ← 開始重建
RemoteScreenServer: SfuPublisher recreated successfully ← 重建成功
```

若重建失敗（出現 3 次後）：
```
RemoteScreenServer: Failed to recreate publisher    ← 重建失敗
RemoteScreenServer: Notifying UI that recreate failed, shutting down  ← 上傳 log ⬆️
```

---

### 2.3 MEMBER 端 Renderer 問題

| 要找的 log | 位置 | 說明 |
|-----------|------|------|
| `Remote screen: Renderer initialized, textureId=...` | MEMBER :302 | Renderer 有建立 |
| ⚠️ `texture widget not found` | MEMBER :428 | Widget 未渲染在畫面上 |

若 `Renderer initialized` 有但看不到畫面：
- 確認 `RTCVideoView` Widget 是否正確掛載到 Widget Tree

---

## 3. 畫面凍結 / FPS 為零

畫面曾經正常，後來凍結不動。

### 3.1 MEMBER 端偵測到 FPS 為零

**偵測流程 log**：
```
VideoTrackManager: Track stats - trackId: FPS=0, ...    ← 每秒更新
VideoTrackManager: Track trackId has zero FPS (count: N) ← 連續 N 秒為零
RtcFpsZeroDetector: Start collecting FPS data            ← 開始收集 FPS 樣本
RtcFpsZeroDetector: All FPS values are zero! Sample count: N, Duration: ...  ← 確認為零 ⬆️
Remote screen FPS is zero! Sample count: ..., Duration: ...                   ← 最終確認，上傳 log ⬆️
```

若看到 `Not enough samples (N/min)`：
- `onVideoInboundStats` 被呼叫次數不足，可能是 active track 設定問題

---

### 3.2 HOST 收到 MEMBER FPS 零通報

```
Host received FPS zero notification from Display Group member: ...  ← HOST 收到通報 ⬆️
RemoteScreenServer: Recreating entire SfuPublisher                  ← HOST 嘗試重建
```

---

### 3.3 Track 切換造成畫面中斷

```
Remote screen: Switching active track from ... to ...       ← track 切換
VideoTrackManager: Switching active track from ... to ...   ← VideoTrackManager 層切換
VideoTrackManager: No valid tracks, falling back to first track  ← 無有效 track，fallback
VideoTrackManager: No tracks available                           ← 完全沒有 track
```

若頻繁出現 track 切換，可能是多個 track 互相競爭，或 track 快速加入又移除。

---

## 4. 信令異常斷開

### Signal Closed 診斷

| 找到的 log | 說明 |
|-----------|------|
| `Remote screen: signal closed, code=1000, reason=Normal Closure` | 正常關閉 |
| `Remote screen: signal closed, code=1006, reason=...` | **異常中斷（網路問題）**，上傳 log ⬆️ |
| `Remote screen: signal closed, code=1001, reason=Going Away` | 遠端主動斷開 |

**code 參考**：

| Code | 意義 | 常見原因 |
|------|------|---------|
| 1000 | 正常關閉 | 用戶主動結束 |
| 1001 | Going Away | HOST 端應用背景化或關閉 |
| 1006 | 異常斷開 | 網路中斷、防火牆切斷 |
| 1011 | Internal Error | HOST 端 SFU server 異常 |

---

### Host 端 WebSocket Channel 問題

```
DisplayGroupMember [...]: Channel connected    ← 正常
DisplayGroupMember [...]: Channel closed, reason=...  ← 通道斷線，MEMBER 無法收到指令
DisplayGroupMember [...]: Reconnecting...             ← 嘗試重連
```

若 `Reconnecting` 之後沒有 `Channel connected`，表示重連失敗。

---

## 5. WebRTC 連線中斷

### ICE/Connection State 追蹤

**HOST 端**（RtcScreenConnector）：
```
RtcScreenConnector: ICE connection state=checking, sessionId=...    ← 開始 ICE
RtcScreenConnector: ICE connection state=connected, sessionId=...   ← ICE 成功
RtcScreenConnector: ICE connection state=disconnected, sessionId=... ← 中斷
RtcScreenConnector: ICE connection state=failed, sessionId=...      ← 徹底失敗
```

**MEMBER 端**（RtcScreenClient）：
```
Remote screen: Connection state new
Remote screen: Connection state connecting
Remote screen: Connection state connected      ← WebRTC 建立成功
Remote screen: WebRTC connected, ontrack fired=true/false
Remote screen: WebRTC disconnected             ← 中斷 ⚠️
```

**上傳觸發**：`Remote screen: WebRTC disconnected` 出現時，log 自動上傳。

**常見原因**：
- ICE 停在 `checking` 不動 → NAT/防火牆問題，TURN server 不可用
- `connected` 後又 `disconnected` → 網路不穩定，丟包嚴重

---

## 6. 觸控回傳失效

### 觸控通道檢查

```
SfuPublisher: New data channel: sessionId ...   ← Data channel 建立（HOST）
Remote screen: Data channel added sessionId     ← Data channel 建立（MEMBER）
SfuPublisher: Enable remote control for sessionId enable  ← 遠端控制開啟（HOST）
```

若沒有 `Enable remote control`：
- 確認 Host 設備的 `flavor` 是否為 `ifp` 或 `edla`
- 觸控回傳功能僅在特定型號啟用

若 Data channel 未建立：
- WebRTC 連線本身可能有問題，先確認 WebRTC 連線狀態正常

---

## 7. 快速定位 Checklist

拿到 log 後，依序確認以下節點是否都出現：

### HOST 端關鍵節點（按時序）

```
[ ] DisplayGroupHost: Adding member ...
[ ] DisplayGroupMember [...]: Sending invite
[ ] DisplayGroupMember [...]: Member accepted invitation
[ ] RtcScreenConnector: Received StartRemoteScreen, sessionId=...
[ ] RtcScreenConnector: Sending RemoteScreenInfo, roomId=..., sessionId=...
[ ] RemoteScreenServer: Starting publisher for room ...
[ ] SfuPublisher: Local stream acquired, videoTracks=N      ← N > 0 才正常
[ ] SfuPublisher: Stream published to SFU
[ ] SfuPublisher: Started successfully
[ ] RtcScreenConnector: ICE connection state=connected
```

### MEMBER 端關鍵節點（按時序）

```
[ ] DisplayGroupSession: User accepted invitation from ...
[ ] DisplayGroupSession: Sending StartRemoteScreen, sessionId=...
[ ] DisplayGroupSession: Received RemoteScreenInfo, roomId=...
[ ] RtcScreenClient: Using Direct/Proxy signaling mode
[ ] Remote screen: Create client, roomId=..., iceServers count=N
[ ] Remote screen: ontrack fired, kind=video, trackId=...
[ ] Remote screen: Video track added, total tracks: N
[ ] Remote screen: Connection state connected
[ ] Remote screen: WebRTC connected, ontrack fired=true
[ ] Remote screen: Renderer initialized, textureId=...
[ ] Remote screen: srcObject set, streamId=..., videoTracks=N
[ ] VideoTrackManager: Track stats - FPS=N (N > 0)
```

第一個**缺失**的節點就是問題所在。

---

## 8. 正常連線 Log 參考範本

以下為一次完整正常連線的 log 時序（僅列關鍵行）：

```
[HOST]   DisplayGroupHost: Adding member member-123
[HOST]   DisplayGroupMember [member-123]: Sending invite
[HOST]   DisplayGroupMember [member-123]: Member accepted invitation
[MEMBER] DisplayGroupSession: User accepted invitation from HostName
[MEMBER] DisplayGroupSession: Sending StartRemoteScreen, sessionId=sess-abc
[HOST]   RtcScreenConnector: Received StartRemoteScreen, sessionId=sess-abc
[HOST]   RtcScreenConnector: Sending accepted status, sessionId=sess-abc
[HOST]   RemoteScreenServer: Starting publisher for room room-xyz
[HOST]   SfuPublisher: Starting for room room-xyz
[HOST]   SfuPublisher: Local stream acquired, videoTracks=1
[HOST]   SfuPublisher: Stream published to SFU
[HOST]   SfuPublisher: Started successfully
[HOST]   RtcScreenConnector: Sending RemoteScreenInfo, roomId=room-xyz, sessionId=sess-abc
[MEMBER] DisplayGroupSession: Received RemoteScreenInfo, roomId=room-xyz
[MEMBER] RtcScreenClient: Using Direct signaling mode, url=ws://192.168.x.x:7000/ws
[MEMBER] Remote screen: Create client, roomId=room-xyz, iceServers count=2
[HOST]   RtcScreenConnector: ICE connection state=checking, sessionId=sess-abc
[HOST]   RtcScreenConnector: ICE connection state=connected, sessionId=sess-abc
[MEMBER] Remote screen: ontrack fired, kind=video, trackId=track-001
[MEMBER] Remote screen: Video track added, total tracks: 1
[MEMBER] Remote screen: Single track mode - rendering immediately
[MEMBER] Remote screen: Renderer initialized, textureId=42
[MEMBER] Remote screen: srcObject set, streamId=stream-001, videoTracks=1
[MEMBER] Remote screen: Connection state connected
[MEMBER] Remote screen: WebRTC connected, ontrack fired=true
[MEMBER] VideoTrackManager: Track stats - track-001: FPS=30, loss=0%, jitter=2ms, ...
[HOST]   SfuPublisher: Stats - FPS=30, bitrate=2500kbps, ...
```

---

## Upload 觸發一覽（快速確認是否有異常）

| Sentry Upload Reason | 對應問題 |
|---------------------|---------|
| `Member FPS zero: sampleCount=...` | MEMBER 端 FPS 為零 |
| `WebRTC connection failed` | WebRTC 連線失敗 |
| `Signal closed abnormally: code=..., reason=...` | 信令異常斷開 |
| `Member reported FPS zero, displayCode=...` | HOST 收到 MEMBER 的 FPS 零通報 |
| `Host recreate failed after max attempts` | HOST Publisher 重建失敗（最嚴重） |

看到 Sentry 上傳記錄時，先確認 `reason` 字串，再對照上方對應章節深入分析。
