# Release Note 產生腳本測試指令

本文件說明如何在本機或 CI 驗證 `ci/scripts/generate-public-release-note.sh` 的輸出與行為。

## 先備條件
- 已取得完整的 Git 歷史（含 tags）或可指定起始 tag。
- 本機需可執行 bash 與 git。

## 基本用法
- 產生公開釋出說明：
  - `bash ci/scripts/generate-public-release-note.sh -ReleaseType Stage`
  - `-ReleaseType` 可為 `Production`、`Stage`、`HotFix`。

執行時會輸出：版本、日期、偵測到的 commit 範圍、範圍內的 commits；並在專案根目錄生成 `RELEASE_NOTE_PUBLIC.md`。

## 精準指定比較範圍
- 若要明確指定範圍的起點（避免抓到過多 commits），可用 `-FromTag`：
  - 範例：`bash ci/scripts/generate-public-release-note.sh -ReleaseType Production -FromTag <上一個釋出 tag>`
  - 可先查看現有 tags：`git tag -l | sort -V`

## 指定 checksum 檔與輸出位置
- 參數：
  - `-ChecksumsPath <檔案路徑>`：指定彙整後的 MD5 清單（預設為 `checksums.md5`）。
  - `-OutputPath <檔案路徑>`：指定輸出檔名（預設為 `RELEASE_NOTE_PUBLIC.md`）。
  - `-S3BaseUrl <URL>`：自訂下載連結的根網址。

- 建立本機範例 checksum（請將 `<VERSION>` 與 `<MD5>` 置換為實際值）：
  ```bash
  cat > /tmp/checksums.md5 <<'EOF'
  myViewBoardDisplay_APK_EDLA_S_v<VERSION>.apk  <MD5>
  myViewBoardDisplay_APK_EDLA_v<VERSION>.apk    <MD5>
  myViewBoardDisplay_APK_IFP_S_v<VERSION>.apk   <MD5>
  myViewBoardDisplay_APK_IFP_v<VERSION>.apk     <MD5>
  myViewBoardDisplay_APK_OPEN_S_v<VERSION>.apk  <MD5>
  myViewBoardDisplay_APK_OPEN_v<VERSION>.apk    <MD5>
  EOF
  ```

- 帶入範例 checksum 測試：
  - `bash ci/scripts/generate-public-release-note.sh -ReleaseType Stage -ChecksumsPath /tmp/checksums.md5`

## 驗證重點
- 觀察標準輸出中的範圍資訊：
  - `Using commits between ...` 應顯示兩個版本變更之間的 commit 範圍（或 `-FromTag` 指定的範圍）。
- `Extracted commits:` 僅包含該範圍的 commits，且已排除內部/測試性 chore（例如 pipeline 測試、磁碟清理等），不含版本變更 commit 本身。
- 產生的 `RELEASE_NOTE_PUBLIC.md` 應包含：
  - 版本、日期
  - 範圍內 commits 清單
  - 下載連結（依版本自動組合）
  - 若 `checksums.md5` 內有對應檔名，會列出該檔的 MD5 值

## 在 Azure Pipelines 中
- `ci/azure-pipelines-build.yml` 的 `ReleaseNote` job 已自動：
  - 下載各變體的 `checksums_*.md5` 並合併為 `checksums.md5`
  - 執行 `generate-public-release-note.sh -ReleaseType $(Release.Type)`
  - 發布名為 `ReleaseNote` 的 artifact，內含 `RELEASE_NOTE_PUBLIC.md` 與 `checksums.md5`

## 疑難排解
- Commits 太多：
  - 請用 `-FromTag` 明確指定上一個釋出的 tag。
  - 或確認是否至少有兩筆版本變更（`pubspec.yaml` 的 `version:` 變更或題名為 `chore: Change version and TAG`）。
- MD5 顯示 `not found`：
  - 確認 `checksums.md5` 是否存在且檔名需與腳本預期相同；格式為「檔名 空白 MD5」。

