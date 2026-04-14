# Release Note Generator 使用說明

自動生成 AirSync Sender Release Note，包含版本號、日期、Git commit 記錄及各平台下載連結。

---

## 📋 目錄

- [Pipeline 自動生成（推薦）](#pipeline-自動生成推薦)
- [本地快速生成](#本地快速生成)
- [輸出格式範例](#輸出格式範例)
- [進階設定](#進階設定)

---

## Pipeline 自動生成（推薦）

### 第一次設定

1. 進入 Azure DevOps 專案 → **Pipelines**
2. 點選 **New Pipeline**
3. 選擇 **Existing Azure Pipelines YAML file**
4. 選擇路徑：`/azure-pipelines-release-note.yml`
5. 儲存 Pipeline

### 執行 Pipeline

1. 點選 **Run pipeline**
2. 填寫參數：

   | 參數 | 說明 | 範例 |
      |------|------|------|
   | **Release Type** | 發布類型 | `Production` / `Stage` / `HotFix` / `R.C.` |
   | **Android Dropbox URL** | Android 下載連結<br>（沒有則保持預設 `NONE`） | `https://www.dropbox.com/t/xxxxx`<br>或保持 `NONE` |
   | **From Tag** | 起始 Git Tag<br>（保持預設 `AUTO` 使用最新 tag） | `V3.8.10+308023_20250930`<br>或保持 `AUTO` |

3. 點選 **Run** 執行

### 取得結果

執行完成後，有兩種方式取得結果：

**方式一：下載檔案**

- 進入 Pipeline run 的 Summary 頁面
- 在 **Artifacts** 區塊找到 `ReleaseNote`
- 下載 `RELEASE_NOTE.txt`

**方式二：複製 Logs**

- 點開 **Display Release Note** step
- 直接從 logs 複製輸出的內容

---

## 本地快速生成

### 方式 1️⃣：互動式（會提示輸入下載連結）

```bash
cd /path/to/Display_Cast_Flutter
./ci/scripts/generate-sender-release-note.sh -ReleaseType Production
```

執行後會依序提示輸入：

- Windows app URL
- Mac app URL
- Android app URL
- Web URL

按 Enter 可跳過不需要的平台。

### 方式 2️⃣：一鍵生成（直接指定所有參數）

**不含 Android：**

```bash
./ci/scripts/generate-sender-release-note.sh \
  -ReleaseType Production \
  -WindowsUrl "https://store2.myviewboard.com/uploads/AirSyncSender-stage/AirSyncSender-3.9.1.309003-stage.msi" \
  -MacUrl "https://myviewboardstorage.s3.us-west-2.amazonaws.com/uploads/AirSyncSenderOsx_Stage/AirSyncSender-3.9.1.309003-s.pkg" \
  -WebUrl "https://www.stage.airsync.net/"
```

**包含 Android：**

```bash
./ci/scripts/generate-sender-release-note.sh \
  -ReleaseType Production \
  -WindowsUrl "https://store2.myviewboard.com/uploads/AirSyncSender-stage/AirSyncSender-3.9.1.309003-stage.msi" \
  -MacUrl "https://myviewboardstorage.s3.us-west-2.amazonaws.com/uploads/AirSyncSenderOsx_Stage/AirSyncSender-3.9.1.309003-s.pkg" \
  -AndroidUrl "https://www.dropbox.com/t/xxxxx" \
  -WebUrl "https://www.stage.airsync.net/"
```

**儲存到檔案：**

```bash
./ci/scripts/generate-sender-release-note.sh \
  -ReleaseType Production \
  -WindowsUrl "..." \
  -MacUrl "..." \
  -WebUrl "..." \
  -OutputPath ~/Desktop/release_note.txt
```

**指定起始 Tag：**

```bash
./ci/scripts/generate-sender-release-note.sh \
  -ReleaseType HotFix \
  -FromTag "V3.8.10+308023_20250930" \
  -WindowsUrl "..." \
  -MacUrl "..." \
  -WebUrl "..."
```

### 💡 實用技巧

**查看最近的 Git Tags：**

```bash
git tag --sort=-version:refname | head -10
```

**查看兩個 Tag 之間的 commits：**

```bash
git log V3.8.10+308023_20250930..HEAD --pretty=format:"- %s"
```

---

## 輸出格式範例

### 包含所有平台

```
2025-11-5 (v3.9.1) AirSync Sender (MacOS/ iOS/ Android/ Windows/ Web) Production Release Notes:

- fix: [BUG #97001] [Sentry][Sender] UnsupportedError: Unsupported operation: Infinity or NaN toInt
- fix: [BUG #96096] AirSync sender app更改Knowledge Base URL
- feat: [USER STORY #95008] update virtual display version

Download Windows app: https://store2.myviewboard.com/uploads/AirSyncSender-stage/AirSyncSender-3.9.1.309003-stage.msi

Download Mac app for Ind: https://myviewboardstorage.s3.us-west-2.amazonaws.com/uploads/AirSyncSenderOsx_Stage/AirSyncSender-3.9.1.309003-s.pkg

Download Android app: https://www.dropbox.com/t/xxxxx

Web: https://www.stage.airsync.net/

===============================================================================
```

### 不包含 Android

```
2025-11-5 (v3.9.1) AirSync Sender (MacOS/ iOS/ Android/ Windows/ Web) Stage Release Notes:

- fix: [BUG #97001] [Sentry][Sender] UnsupportedError

Download Windows app: https://store2.myviewboard.com/uploads/AirSyncSender-stage/AirSyncSender-3.9.1.309003-stage.msi

Download Mac app for Ind: https://myviewboardstorage.s3.us-west-2.amazonaws.com/uploads/AirSyncSenderOsx_Stage/AirSyncSender-3.9.1.309003-s.pkg

Web: https://www.stage.airsync.net/

===============================================================================
```

---

## 進階設定

### 修改 URL 模板

如需修改各平台的 URL 格式，編輯 `azure-pipelines-release-note.yml` 中的 variables：

```yaml
variables:
  # Windows URLs
  - name: Windows.Stage.UrlTemplate
    value: "https://store2.myviewboard.com/uploads/AirSyncSender-stage/AirSyncSender-{version}.{build}-stage.msi"
  - name: Windows.Production.UrlTemplate
    value: "https://store2.myviewboard.com/uploads/AirSyncSender-prod/AirSyncSender-{version}.{build}.msi"

  # Mac URLs
  - name: Mac.Stage.UrlTemplate
    value: "https://myviewboardstorage.s3.us-west-2.amazonaws.com/uploads/AirSyncSenderOsx_Stage/AirSyncSender-{version}.{build}-s.pkg"
  - name: Mac.Production.UrlTemplate
    value: "https://myviewboardstorage.s3.us-west-2.amazonaws.com/uploads/AirSyncSenderOsx/AirSyncSender-{version}.{build}.pkg"

  # Web URLs
  - name: Web.Stage.Url
    value: "https://www.stage.airsync.net/"
  - name: Web.Production.Url
    value: "https://www.airsync.net/"
```

**變數說明：**

- `{version}` - 從 `pubspec.yaml` 讀取的版本號（例如：3.9.1）
- `{build}` - 從 `pubspec.yaml` 讀取的 build number（例如：309003）

### 參數說明

| 參數             | 必填 | 預設值    | 說明                                         |
|----------------|----|--------|--------------------------------------------|
| `-ReleaseType` | ✅  | -      | `Production` / `Stage` / `HotFix` / `R.C.` |
| `-WindowsUrl`  | ❌  | -      | Windows 下載連結                               |
| `-MacUrl`      | ❌  | -      | Mac 下載連結                                   |
| `-AndroidUrl`  | ❌  | -      | Android 下載連結（不提供則不顯示）                      |
| `-WebUrl`      | ❌  | -      | Web URL                                    |
| `-FromTag`     | ❌  | 最新 tag | 起始 Git Tag                                 |
| `-OutputPath`  | ❌  | 輸出到終端  | 儲存檔案路徑                                     |

---

## 注意事項

- ✅ 版本號自動從 `pubspec.yaml` 讀取
- ✅ Commits 從指定的 Git Tag 到 HEAD 收集
- ✅ 如果沒有提供 Android URL 或設為 `NONE`，release note 不會包含 Android 下載連結
- ✅ 產生的檔案不會提交到 Git repo
- ✅ Pipeline 產生的檔案僅作為 artifact 保存
- ⚠️ 確保 Git tags 格式正確（例如：`V3.9.1+309003_20251022`）

---

## 疑難排解

**問題：沒有找到 commits**

```
解決方式：檢查是否有 Git tags，或使用 -FromTag 指定起始 tag
```

**問題：版本號讀取失敗**

```
解決方式：確認 pubspec.yaml 中的 version 格式正確（例如：3.9.1+309003）
```

**問題：Pipeline 找不到檔案**

```
解決方式：確認腳本有執行權限：chmod +x ci/scripts/generate-sender-release-note.sh
```
