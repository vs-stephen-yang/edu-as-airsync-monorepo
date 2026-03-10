# Cast to Board 設備列表排序規則與場景說明

## 📌 文件資訊

- **功能名稱**: Cast to Board 手動輸入 IP 功能與設備列表排序
- **相關 Commit**: fbcd9f6d (Part 1), 0e8124d2 (Part 2)
- **文件版本**: 2.0
- **最後更新**: 2025-12-17
- **本次更新**: 新增勾選狀態排序規則（優先級 0）

---

## 🎯 排序優先級（由上往下）

```
優先級 0: 手動輸入後找不到的設備（最優先，需用戶注意）
         ↓
優先級 1: 已勾選的設備（依勾選順序由新到舊）
         ↓
優先級 2: 收藏且顯示上線的設備（未勾選，依收藏時間由新到舊）
         ↓
優先級 3: 收藏但顯示未上線的設備（未勾選，依收藏時間由新到舊）
         ↓
優先級 4: 手動輸入但尚未收藏、已上線的設備（未勾選，依添加時間由新到舊）
         ↓
優先級 5: 自動發現的設備（未勾選，依發現時間由新到舊）
```

### 🔖 排序規則說明

- **找不到最優先**: 手動輸入找不到的設備（ipNotFind=true）永遠在最上方，提醒用戶處理
- **勾選次優先**: 已勾選的可用設備排在第二位，最新勾選的在上面
- **收藏優先**: 收藏的設備（無論上線或離線）都排在未收藏設備之前
- **收藏排序**:
  - 收藏且上線：依收藏時間由新到舊（最近收藏的在上）
  - 收藏但未上線：依收藏時間由新到舊（最近收藏的在上）
- **勾選順序**: 最新勾選的設備在最上面（後勾選的排在先勾選的前面）
- **自動勾選**: 手動輸入 IP 後，若成功找到設備，會自動勾選該設備
- **取消勾選**: 取消勾選後，設備會回到其原本的排列位置（根據優先級 2-5）
- **勾選上限**: 最多可勾選 10 個設備，達到上限後會自動移除最早勾選的設備
- **找不到無法勾選**: ipNotFind=true 的設備 Checkbox 被禁用，無法勾選

---

## 📋 設備狀態關鍵屬性說明

### 核心屬性

| 屬性名稱                   | 類型     | 說明                                       | 來源             |
|------------------------|--------|------------------------------------------|----------------|
| `viaIp`                | bool   | 是否透過手動輸入 IP 添加                           | GroupBean      |
| `favorite`             | bool   | 是否已收藏                                    | GroupBean      |
| `ipNotFind`            | bool   | IP 是否找不到（連線失敗）                           | GroupBean      |
| `invitedState`         | String | 被邀請加入群組的設定<br>0=通知我, 1=自動接受, 2=忽略        | GroupBean      |
| `unsupportedMulticast` | bool   | 是否不支援 Multicast<br>(mc != '1')           | GroupBean      |
| `timestamp`            | int    | 設備被添加/發現的時間戳                             | GroupBean      |
| `favoriteTimestamp`    | int    | 設備被收藏的時間戳<br>⚠️ **需要新增**                 | GroupBean      |
| **`selected`**         | bool   | **是否已勾選**<br>⚠️ **透過 selectedList 判斷**   | **GroupState** |
| **`selectedOrder`**    | int    | **勾選順序索引**<br>⚠️ **在 selectedList 中的位置** | **GroupState** |

### 計算屬性

| 屬性名稱          | 類型   | 計算邏輯                                                                                   | 說明                    |
|---------------|------|----------------------------------------------------------------------------------------|-----------------------|
| `unavailable` | bool | `invitedState==2` \|\|<br>`(unsupportedMulticast && useMulticast)` \|\|<br>`ipNotFind` | 設備是否不可用<br>（在 UI 層計算） |

### 系統設定

| 設定名稱           | 類型   | 說明                  | 來源          |
|----------------|------|---------------------|-------------|
| `useMulticast` | bool | 系統是否開啟 Multicast 模式 | AppSettings |

---

## 📝 勾選狀態相關場景

### 場景 A：手動輸入 IP 後自動勾選

**操作流程**:

1. 用戶在 Cast to Board 頁面點擊「手動輸入 IP」
2. 輸入 IP 位址（例如：192.168.1.103）
3. UDP 查詢成功，找到設備

**系統行為**:

```dart
// v3_settings_cast_to_boards.dart:759-766
final bean = GroupBean.fromJson(
        await UdpResponder.askPeerViaUdp(ipAddress),
        viaIp: true
,
);
groupNotifier.addClient
(
bean
);
groupNotifier
.
addToSelectedList
(
bean
); // 🔑 自動勾選
```

**結果**:

- 設備被添加到 `state.selectedList`
- 設備顯示在列表最上方（優先級 0）
- Checkbox 自動被勾選 ✅

---

### 場景 B：手動勾選已存在的設備

**操作流程**:

1. 用戶點擊某個設備的 Checkbox
2. 該設備從 `state.clients` 移動到 `state.selectedList`

**系統行為**:

```dart
// group_provider.dart:124-136
void addToSelectedList(GroupListItem client) {
  if (!state.selectedList.contains(client)) {
    if (state.selectedList.length >= 10) {
      state.selectedList.removeAt(0); // 🔑 移除最早勾選的
    }
    state.clients.removeWhere((foundService) => foundService.id() == client.id());
    final newSelectedList = [...state.selectedList, client];
    _addToHistorySelectedList(client);
    state = state.copyWith(
            selectedList: newSelectedList, clients: state.clients.toList());
  }
}
```

**結果**:

- 設備被添加到 `state.selectedList` 尾部（最新勾選）
- 如果已有 10 個勾選設備，會移除最早勾選的（索引 0）
- 設備顯示在列表最上方區域

---

### 場景 C：取消勾選設備

**操作流程**:

1. 用戶點擊已勾選設備的 Checkbox，取消勾選
2. 該設備從 `state.selectedList` 移動回 `state.clients`

**系統行為**:

```dart
// group_provider.dart:138-148
void removeFromSelectedList(GroupListItem client) {
  state.selectedList.removeWhere((foundService) => foundService.id() == client.id());
  final newSelectedList = state.selectedList.toList();
  _removeFromHistorySelectedList(client.id());
  final updatedClients = _sortClientsByPriority([...state.clients, client]); // 🔑 重新排序
  state = state.copyWith(
    selectedList: newSelectedList,
    clients: updatedClients,
  );
}
```

**結果**:

- 設備從 `state.selectedList` 移除
- 設備被添加回 `state.clients` 並重新排序
- 設備根據其屬性（收藏、viaIp、unavailable 等）回到對應的優先級

**排序示例**:

- 若該設備是收藏且上線 → 移動到優先級 2
- 若該設備是手動輸入未收藏 → 移動到優先級 3
- 若該設備是自動發現未收藏 → 移動到優先級 5

---

### 場景 D：勾選數量達到上限（10 個）

**操作流程**:

1. 已有 10 個設備被勾選
2. 用戶勾選第 11 個設備

**系統行為**:

```dart
if (state.selectedList.length >= 10) {
state.selectedList.removeAt(0); // 移除最早勾選的設備（索引 0）
}
```

**結果**:

- 最早勾選的設備（索引 0）被自動取消勾選
- 該設備回到 `state.clients` 並重新排序
- 新勾選的設備被添加到 `state.selectedList` 尾部

**視覺效果**:

```
勾選前（已有 10 個）:
☑️ 設備 1 (最早)
☑️ 設備 2
...
☑️ 設備 10 (最新)
───────────
☐ 設備 11

勾選第 11 個後:
☑️ 設備 2
☑️ 設備 3
...
☑️ 設備 10
☑️ 設備 11 (最新)
───────────
☐ 設備 1 (被擠出，回到原位置)
```

---

## 🔍 完整場景列表（20 個場景）

### 🔴 優先級 0：手動輸入後找不到的設備

> **排序規則**: 顯示在最上方，提醒用戶有設備連線失敗
> **組內排序**: 按時間戳降序（最新失敗的在上）

#### 場景 13：手動添加 + 未收藏 + 找不到

```yaml
viaIp: true
favorite: false
ipNotFind: true
unavailable: true
```

**UI 顯示**:

- 設備名稱: `192.168.1.100`
- 右側: 🔴 "not find" + 紅色移除按鈕
- Checkbox: 🚫 灰色禁用
- 無收藏按鈕

---

#### 場景 14：手動添加 + 已收藏 + 找不到

```yaml
viaIp: true
favorite: true  # 但不顯示收藏按鈕
ipNotFind: true
unavailable: true
```

**UI 顯示**:

- 設備名稱: `192.168.1.100`
- 右側: 🔴 "not find" + 紅色移除按鈕
- Checkbox: 🚫 灰色禁用
- 無收藏按鈕（雖然 favorite=true）

**備註**: `ipNotFind` 優先級最高，不顯示收藏狀態

---

#### 場景 17：手動添加 + 已收藏 + 離線（保存時就失敗）⚠️

```yaml
來源: favoriteList 快取加載
viaIp: true
favorite: true
ipNotFind: true  # 保存時就找不到
unavailable: true
```

**UI 顯示**:

- 設備名稱: `192.168.1.100`
- 右側: 🔴 "not find" + 紅色移除按鈕
- Checkbox: 🚫 灰色禁用
- 無收藏按鈕（雖然 favorite=true）

**說明**:

- 保持 "not find" 狀態直到用戶手動重試
- 雖然已收藏，但因 ipNotFind=true，歸類到優先級 0

---

### ✅ 優先級 1：已勾選的設備

> **排序規則**: 按勾選順序排列（最新勾選的在上）
> **組內排序**: 按 selectedList 索引，尾部（最新勾選）排在前面
> **備註**: 此優先級的設備會從 `state.selectedList` 直接讀取，不會出現在 `state.clients` 中

---

### 🥈 優先級 2：收藏且顯示上線的設備

> **排序規則**: 按收藏時間降序（最近收藏的在最上方）
> **組內排序**: `favoriteTimestamp` 降序

#### 場景 2：自動發現 + 已收藏 + 正常

```yaml
viaIp: false
favorite: true
ipNotFind: false
invitedState: 1
unsupportedMulticast: false
unavailable: false
```

**UI 顯示**:

- 設備名稱: `會議室 Display`（友好名稱）
- 右側: Display Code `A1B2` + ⭐ 實心星星
- Checkbox: ✅ 可勾選

---

#### 場景 4：手動添加 + 已收藏 + 正常

```yaml
viaIp: true
favorite: true
ipNotFind: false
invitedState: 1
unsupportedMulticast: false
unavailable: false
```

**UI 顯示**:

- 設備名稱: `192.168.1.100`（顯示 IP）
- 右側: Display Code `A1B2` + ⭐ 實心星星
- Checkbox: ✅ 可勾選

---

#### 場景 7：舊設備 + 已收藏 + MC 關閉（可用）

```yaml
viaIp: false
favorite: true
ipNotFind: false
invitedState: 1
unsupportedMulticast: true  # mc != '1'
useMulticast: false  # 🔑 系統關閉 MC
unavailable: false   # 因 MC 關閉而可用
```

**UI 顯示**:

- 設備名稱: `舊版 Display`
- 右側: Display Code `A1B2` + ⭐ 實心星星
- Checkbox: ✅ 可勾選

**說明**: 雖然設備不支援 Multicast，但系統未開啟 MC 模式，設備仍可正常使用

---

#### 場景 15：自動發現 + 已收藏 + 離線（假在線）⚠️

```yaml
來源: favoriteList 快取加載
viaIp: false
favorite: true
ipNotFind: false  # ⚠️ 保存時的舊值
unavailable: false  # ⚠️ 保存時的舊值
實際狀態: 設備已離線
```

**UI 顯示**:

- 設備名稱: `會議室 Display`（保存的名稱）
- 右側: Display Code `A1B2`（保存的舊值）+ ⭐ 實心星星
- Checkbox: ✅ 可勾選（**誤導用戶！**）

**⚠️ 嚴重問題**:

- 看起來完全正常，但實際設備已離線
- 用戶無法區分真正在線和假在線
- 點擊投屏時才會發現連線失敗
- **目前會被歸類到優先級 2，因為 unavailable=false**

**排序位置**: 依收藏時間 `favoriteTimestamp` 降序排列

---

#### 場景 16：手動添加 + 已收藏 + 離線（假在線）⚠️

```yaml
來源: favoriteList 快取加載
viaIp: true
favorite: true
ipNotFind: false  # ⚠️ 保存時查詢成功
unavailable: false  # ⚠️ 保存時的舊值
實際狀態: 設備已離線
```

**UI 顯示**:

- 設備名稱: `192.168.1.100`
- 右側: Display Code `A1B2`（保存的舊值）+ ⭐ 實心星星
- Checkbox: ✅ 可勾選（**誤導用戶！**）

**⚠️ 問題同場景 15**:

- 實際設備已離線，但顯示狀態為可用
- **目前會被歸類到優先級 2，因為 unavailable=false**

**排序位置**: 依收藏時間 `favoriteTimestamp` 降序排列

---

### 🥉 優先級 3：收藏但顯示未上線的設備

> **排序規則**: 按收藏時間降序（最近收藏的在最上方）
> **組內排序**: `favoriteTimestamp` 降序

#### 場景 8：舊設備 + 已收藏 + MC 開啟（不可用）

```yaml
viaIp: false
favorite: true
ipNotFind: false
invitedState: 1
unsupportedMulticast: true
useMulticast: true  # 🔑 系統開啟 MC
unavailable: true   # 因不支援 MC 而不可用
```

**UI 顯示**:

- 設備名稱: `舊版 Display`
- 右側: ⚠️ 警告圖標 + "Device version is not supported" + ⭐ 實心星星（灰色禁用）
- Checkbox: 🚫 灰色禁用

---

#### 場景 11：自動發現 + 已收藏 + 被忽略 + MC 關閉

```yaml
viaIp: false
favorite: true
ipNotFind: false
invitedState: 2  # ignore
useMulticast: false  # 🔑
unavailable: true
```

**UI 顯示**:

- 設備名稱: `會議室 Display`
- 右側: ⚠️ 警告圖標 + "unavailable" + ⭐ 實心星星（灰色禁用）
- Checkbox: 🚫 灰色禁用

**說明**: 用戶設定為「忽略」，即使系統未開啟 MC，仍顯示 "unavailable"

---

#### 場景 12：自動發現 + 已收藏 + 被忽略 + MC 開啟

```yaml
viaIp: false
favorite: true
ipNotFind: false
invitedState: 2  # ignore
useMulticast: true  # 🔑
unavailable: true
```

**UI 顯示**:

- 設備名稱: `會議室 Display`
- 右側: ⚠️ 警告圖標 + "Device version is not supported" + ⭐ 實心星星（灰色禁用）
- Checkbox: 🚫 灰色禁用

**說明**: 用戶設定為「忽略」，且系統開啟 MC，顯示 "Device version is not supported"

---

#### 場景 20：舊設備 + 已收藏 + 被忽略 + MC 開啟（複合狀態）

```yaml
viaIp: false
favorite: true
ipNotFind: false
invitedState: 2  # ignore
unsupportedMulticast: true
useMulticast: true  # 🔑
unavailable: true  # 兩個條件都觸發
```

**UI 顯示**:

- 設備名稱: `舊版 Display`
- 右側: ⚠️ 警告圖標 + "Device version is not supported" + ⭐ 實心星星（灰色禁用）
- Checkbox: 🚫 灰色禁用

**說明**: 同時滿足「被忽略」和「不支援 MC」兩個不可用條件

---

### 4️⃣ 優先級 4：手動輸入但尚未收藏、已上線的設備

> **排序規則**: 按添加時間降序（最新添加的在上）
> **組內排序**: `timestamp` 降序

#### 場景 3：手動添加 + 未收藏 + 正常

```yaml
viaIp: true
favorite: false
ipNotFind: false
invitedState: 1
unsupportedMulticast: false
unavailable: false
```

**UI 顯示**:

- 設備名稱: `192.168.1.100`
- 右側: Display Code `A1B2` + ☆ 空心星星
- Checkbox: ✅ 可勾選

---

### 5️⃣ 優先級 5：自動發現的設備

> **排序規則**: 按發現時間降序（最新發現的在最上方）
> **組內排序**: `timestamp` 降序

#### 場景 1：自動發現 + 未收藏 + 正常

```yaml
viaIp: false
favorite: false
ipNotFind: false
invitedState: 1
unsupportedMulticast: false
unavailable: false
```

**UI 顯示**:

- 設備名稱: `會議室 Display`
- 右側: Display Code `A1B2` + ☆ 空心星星
- Checkbox: ✅ 可勾選

---

#### 場景 5：舊設備 + 未收藏 + MC 關閉（可用）

```yaml
viaIp: false
favorite: false
ipNotFind: false
invitedState: 1
unsupportedMulticast: true
useMulticast: false  # 🔑
unavailable: false
```

**UI 顯示**:

- 設備名稱: `舊版 Display`
- 右側: Display Code `A1B2` + ☆ 空心星星
- Checkbox: ✅ 可勾選

---

#### 場景 6：舊設備 + 未收藏 + MC 開啟（不可用）

```yaml
viaIp: false
favorite: false
ipNotFind: false
invitedState: 1
unsupportedMulticast: true
useMulticast: true  # 🔑
unavailable: true
```

**UI 顯示**:

- 設備名稱: `舊版 Display`
- 右側: ⚠️ 警告圖標 + "Device version is not supported" + ☆ 空心星星（灰色禁用）
- Checkbox: 🚫 灰色禁用

---

#### 場景 9：自動發現 + 未收藏 + 被忽略 + MC 關閉

```yaml
viaIp: false
favorite: false
ipNotFind: false
invitedState: 2  # ignore
useMulticast: false  # 🔑
unavailable: true
```

**UI 顯示**:

- 設備名稱: `會議室 Display`
- 右側: ⚠️ 警告圖標 + "unavailable" + ☆ 空心星星（灰色禁用）
- Checkbox: 🚫 灰色禁用

---

#### 場景 10：自動發現 + 未收藏 + 被忽略 + MC 開啟

```yaml
viaIp: false
favorite: false
ipNotFind: false
invitedState: 2  # ignore
useMulticast: true  # 🔑
unavailable: true
```

**UI 顯示**:

- 設備名稱: `會議室 Display`
- 右側: ⚠️ 警告圖標 + "Device version is not supported" + ☆ 空心星星（灰色禁用）
- Checkbox: 🚫 灰色禁用

---

#### 場景 18：舊設備 + 未收藏 + 被忽略 + MC 關閉

```yaml
viaIp: false
favorite: false
ipNotFind: false
invitedState: 2  # ignore，優先觸發
unsupportedMulticast: true
useMulticast: false  # 🔑
unavailable: true  # 因 ignore
```

**UI 顯示**:

- 設備名稱: `舊版 Display`
- 右側: ⚠️ 警告圖標 + "unavailable" + ☆ 空心星星（灰色禁用）
- Checkbox: 🚫 灰色禁用

**說明**: 即使 MC 關閉，仍因「被忽略」而不可用

---

#### 場景 19：舊設備 + 未收藏 + 被忽略 + MC 開啟

```yaml
viaIp: false
favorite: false
ipNotFind: false
invitedState: 2  # ignore
unsupportedMulticast: true  # 也觸發
useMulticast: true  # 🔑
unavailable: true  # 兩個條件都觸發
```

**UI 顯示**:

- 設備名稱: `舊版 Display`
- 右側: ⚠️ 警告圖標 + "Device version is not supported" + ☆ 空心星星（灰色禁用）
- Checkbox: 🚫 灰色禁用

---

## 📊 排序結果範例

假設有以下設備：

| 設備            | 類型 | 狀態          | 勾選狀態          | 收藏時間  | 添加/發現時間 | 場景 | 備註                |
|---------------|----|-------------|---------------|-------|---------|----|-------------------|
| 會議室 A         | 自動 | 收藏 + 上線     | ✅ 已勾選 (16:30) | 12:00 | 09:00   | 2  | mDNS 實時在線         |
| 192.168.1.103 | 手動 | 收藏 + 上線     | ✅ 已勾選 (16:20) | 15:00 | 15:00   | 4  | UDP 查詢成功，手動輸入自動勾選 |
| 教室 A          | 自動 | 正常          | ✅ 已勾選 (16:10) | -     | 11:00   | 1  | 手動勾選              |
| 192.168.1.101 | 手動 | 找不到         | ❌ 未勾選         | -     | 14:00   | 13 |                   |
| 192.168.1.102 | 手動 | 找不到         | ❌ 未勾選         | -     | 13:00   | 13 |                   |
| 192.168.1.104 | 手動 | 正常          | ❌ 未勾選         | -     | 16:00   | 3  |                   |
| 大廳 Display    | 自動 | **收藏 + 離線** | ❌ 未勾選         | 11:00 | -       | 8  | MC 開啟不可用          |
| 會議室 B         | 自動 | 收藏 + 離線     | ❌ 未勾選         | 10:00 | -       | 8  | MC 開啟不可用          |
| 教室 B          | 自動 | 正常          | ❌ 未勾選         | -     | 10:00   | 1  |                   |

### 排序後結果（由上往下）

```
┌────────────────────────────────────────────────────────┐
│ 🔴 優先級 0: 手動輸入找不到（最優先）                       │
├────────────────────────────────────────────────────────┤
│ 1. 192.168.1.101 🔴 not find                           │ 場景 13｜14:00 最新
│ 2. 192.168.1.102 🔴 not find                           │ 場景 13｜13:00
├────────────────────────────────────────────────────────┤
│ ✅ 優先級 1: 已勾選的設備                                 │
├────────────────────────────────────────────────────────┤
│ 3. ☑️ 會議室 A ⭐ Code: A1B2                            │ 場景  2｜勾選 16:30 最新
│ 4. ☑️ 192.168.1.103 ⭐ Code: A1B2                       │ 場景  4｜勾選 16:20
│ 5. ☑️ 教室 A ☆ Code: A1B2                               │ 場景  1｜勾選 16:10
├────────────────────────────────────────────────────────┤
│ 🥈 優先級 2: 收藏且上線（未勾選）                          │
├────────────────────────────────────────────────────────┤
│ （無設備，因為收藏且上線的設備都已被勾選）                    │
├────────────────────────────────────────────────────────┤
│ 🥉 優先級 3: 收藏但未上線（未勾選）                        │
├────────────────────────────────────────────────────────┤
│ 6. 大廳 Display ⭐（灰色禁用）                           │ 場景 15｜收藏 11:00（MC 開啟不可用）
│ 7. 會議室 B ⭐（灰色禁用）                               │ 場景  8｜收藏 10:00（MC 開啟不可用）
├────────────────────────────────────────────────────────┤
│ 4️⃣ 優先級 4: 手動輸入未收藏（未勾選）                       │
├────────────────────────────────────────────────────────┤
│ 8. 192.168.1.104 ☆ Code: A1B2                          │ 場景  3｜添加 16:00
├────────────────────────────────────────────────────────┤
│ 5️⃣ 優先級 5: 自動發現（未勾選）                           │
├────────────────────────────────────────────────────────┤
│ 9. 教室 B ☆ Code: A1B2                                  │ 場景  1｜發現 10:00
└────────────────────────────────────────────────────────┘
```

### ⚠️ 排序結果說明

#### 各優先級設備分布

| 優先級       | 設備編號 | 場景      | 數量 | 說明                   |
|-----------|------|---------|----|----------------------|
| 🔴 優先級 0  | 1-2  | 13, 13  | 2  | 手動輸入找不到（最優先，需用戶注意）   |
| ✅ 優先級 1   | 3-5  | 2, 4, 1 | 3  | 已勾選（依勾選順序，最新勾選的在上）   |
| 🥈 優先級 2  | -    | -       | 0  | 收藏且上線（未勾選）- 本例中已全部勾選 |
| 🥉 優先級 3  | 6-7  | 15, 8   | 2  | 收藏但未上線（未勾選）          |
| 4️⃣ 優先級 4 | 8    | 3       | 1  | 手動未收藏已上線（未勾選）        |
| 5️⃣ 優先級 5 | 9    | 1       | 1  | 自動發現未收藏（未勾選）         |

#### 設備歸類詳細說明

**✅ 正確歸類的設備**:

- **第 1-2 項**：手動輸入找不到（優先級 0）
    - 觸發條件：`viaIp=true && ipNotFind=true`
  - 排序：按 timestamp 降序（最新失敗的在上）
  - **第 1 項**（192.168.1.101）：場景 13，14:00 失敗（最新）
  - **第 2 項**（192.168.1.102）：場景 13，13:00 失敗
  - **重要**：這些設備永遠在最上方，Checkbox 被禁用，無法勾選

- **第 3-5 項**：已勾選的設備（優先級 1）
  - 觸發條件：設備在 `state.selectedList` 中（且不是 ipNotFind）
  - 排序：按勾選順序，最新勾選的在上（列表尾部 = 最新）
  - **第 3 項**（會議室 A）：場景 2，16:30 勾選（最新）
  - **第 4 項**（192.168.1.103）：場景 4，16:20 勾選，手動輸入自動勾選
  - **第 5 項**（教室 A）：場景 1，16:10 勾選（最早）
  - **重要**：勾選狀態僅次於 ipNotFind，優先於收藏、上線等狀態

- **第 6-7 項**：收藏但未上線（優先級 3）
  - 觸發條件：`favorite=true && unavailable=true && !ipNotFind`（且未勾選）
  - 排序：按 favoriteTimestamp 降序（最近收藏的在上）
  - **第 6 項**（大廳 Display）：場景 15，假在線設備，收藏 11:00（最近）
  - **第 7 項**（會議室 B）：場景 8，舊設備 MC 開啟不可用，收藏 10:00
  - **重要**：收藏的設備（無論上線或離線）都排在未收藏設備之前

- **第 8 項**：手動輸入未收藏（優先級 4）
  - 觸發條件：`viaIp=true && favorite=false && unavailable=false && !ipNotFind`（且未勾選）

- **第 9 項**：自動發現未收藏（優先級 5）
  - 觸發條件：`viaIp=false && favorite=false`（且未勾選）
    - 排序：按 timestamp 降序

---


**文件結束**
