#!/bin/bash

# macOS App 建置腳本
# 用法：./build_airsync_macos.sh <env> <version_name> <version_code> <output_dir>
# 例如：./build_airsync_macos.sh stage 1.2.3 456 /path/to/output

set -euo pipefail

# ============================================
# 參數解析
# ============================================
ENV_NAME="${1:-stage}"
VERSION_NAME="${2:-}"
VERSION_CODE="${3:-}"
OUTPUT_DIR="${4:-./build_output}"

if [ -z "$VERSION_NAME" ] || [ -z "$VERSION_CODE" ]; then
  echo "❌ 使用方式錯誤"
  echo ""
  echo "用法："
  echo "  $0 <env> <version_name> <version_code> <output_dir>"
  echo ""
  echo "例如："
  echo "  $0 stage 1.2.3 456 ./build_output"
  echo ""
  echo "參數："
  echo "  env           : dev, stage, 或 production"
  echo "  version_name  : 版本號，例如 1.2.3"
  echo "  version_code  : Build number，例如 456"
  echo "  output_dir    : 輸出目錄"
  exit 1
fi

# ============================================
# 環境變數檢查
# ============================================
echo "=================================================="
echo "🚀 macOS App 建置腳本"
echo "=================================================="
echo "Environment    : $ENV_NAME"
echo "Version Name   : $VERSION_NAME"
echo "Version Code   : $VERSION_CODE"
echo "Output Dir     : $OUTPUT_DIR"
echo "=================================================="
echo ""

# 確定 Flutter 命令
if command -v fvm &> /dev/null; then
  FLUTTER_CMD="fvm flutter"
  echo "✅ 使用 FVM Flutter"
else
  FLUTTER_CMD="flutter"
  echo "✅ 使用系統 Flutter"
fi

echo "Flutter: $($FLUTTER_CMD --version | head -n1)"
echo ""

# ============================================
# 準備輸出目錄與檔案名稱
# ============================================
echo "📁 準備輸出目錄..."

# 決定檔案名稱與入口點
case "$ENV_NAME" in
  dev)
    ENV_MARK="D"
    MAIN_ENTRY="lib/main_dev.dart"
    ENTITLEMENTS="macos/Runner/StoreDebugProfile.entitlements"
    ;;
  stage)
    ENV_MARK="S"
    MAIN_ENTRY="lib/main_stage.dart"
    ENTITLEMENTS="macos/Runner/StoreDebugProfile.entitlements"
    ;;
  production)
    ENV_MARK=""
    MAIN_ENTRY="lib/main_production.dart"
    ENTITLEMENTS="macos/Runner/StoreRelease.entitlements"
    ;;
  *)
    echo "❌ 不支援的環境: $ENV_NAME"
    echo "   支援的環境: dev, stage, production"
    exit 1
    ;;
esac

if [ -n "$ENV_MARK" ]; then
  APP_NAME="MacOS_${ENV_MARK}_v${VERSION_NAME}.app"
  ARCHIVE_NAME="MacOS_Store_${ENV_MARK}_v${VERSION_NAME}.xcarchive"
  PKG_NAME="MacOS_Store_${ENV_MARK}_v${VERSION_NAME}.pkg"
else
  APP_NAME="MacOS_v${VERSION_NAME}.app"
  ARCHIVE_NAME="MacOS_Store_v${VERSION_NAME}.xcarchive"
  PKG_NAME="MacOS_Store_v${VERSION_NAME}.pkg"
fi

DEBUG_INFO_DIR="${APP_NAME}.debug_info"

echo "App 名稱      : $APP_NAME"
echo "Archive 名稱  : $ARCHIVE_NAME"
echo "PKG 名稱      : $PKG_NAME"
echo "Debug Info    : $DEBUG_INFO_DIR"
echo "Entry Point   : $MAIN_ENTRY"
echo "Entitlements  : $ENTITLEMENTS"
echo ""

# 建立目錄
mkdir -p "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/$DEBUG_INFO_DIR"

# ============================================
# 清理與準備
# ============================================
echo "🧹 清理舊建置..."
$FLUTTER_CMD clean

echo "📦 下載相依套件..."
$FLUTTER_CMD pub get

echo ""

# ============================================
# 建置 macOS App
# ============================================
echo "=================================================="
echo "🔨 開始建置 macOS App"
echo "=================================================="
echo ""

$FLUTTER_CMD build macos \
  --flavor Store \
  -t "$MAIN_ENTRY" \
  --obfuscate \
  --split-debug-info="$OUTPUT_DIR/$DEBUG_INFO_DIR/" \
  --build-name="$VERSION_NAME" \
  --build-number="$VERSION_CODE" \
  --verbose

echo ""
echo "✅ Flutter build 完成"
echo ""

# ============================================
# 複製 .app 產物（透過 tar.gz 保留完整結構）
# ============================================
echo "📦 複製 .app 檔案（打包→複製→解壓）..."

BUILD_APP_PATH="./build/macos/Build/Products/Release-Store/AirSync Sender.app"
TEMP_TAR="/tmp/airsync_temp_app_$$.tar.gz"

# 先在原地打包（保留符號連結和所有屬性）
echo "  🗜️  打包原始 .app..."
tar -czf "$TEMP_TAR" -C "./build/macos/Build/Products/Release-Store" "AirSync Sender.app"

# 複製 tar.gz 到目的地
echo "  📤 複製到目的地..."
cp "$TEMP_TAR" "$OUTPUT_DIR/"

# 在目的地解壓
echo "  📦 解壓縮..."
cd "$OUTPUT_DIR"
tar -xzf "$(basename "$TEMP_TAR")"

# 重新命名為目標名稱
if [ "AirSync Sender.app" != "$APP_NAME" ]; then
  mv "AirSync Sender.app" "$APP_NAME"
fi

# 清理臨時檔案
rm -f "$(basename "$TEMP_TAR")" "$TEMP_TAR"

cd - > /dev/null

echo "✅ .app 已複製（透過 tar.gz）"
echo ""

# ============================================
# 移除 quarantine 屬性
# ============================================
echo "🧹 移除 quarantine 擴展屬性..."
xattr -dr com.apple.quarantine "$OUTPUT_DIR/$APP_NAME" 2>/dev/null || true
echo "✅ Quarantine 屬性已移除"
echo ""

# ============================================
# Sparkle Framework Codesigning
# ============================================
echo "=================================================="
echo "✍️  對 Sparkle Framework 進行 Codesign"
echo "=================================================="
echo ""

# 定義簽章身份
SIGNING_IDENTITY="Developer ID Application: ViewSonic International Corp. (AVR9NC3MVW)"

echo "Signing Identity: $SIGNING_IDENTITY"
echo "Entitlements: $ENTITLEMENTS"
echo ""

# 檢查 entitlements 檔案是否存在
if [ ! -f "$ENTITLEMENTS" ]; then
  echo "❌ Entitlements 檔案不存在: $ENTITLEMENTS"
  exit 1
fi

# 對 Sparkle Framework 的各個元件進行簽章
SPARKLE_BASE="macos/Pods/Sparkle/Sparkle.framework/Versions/B"

echo "🔐 簽署 Downloader.xpc..."
codesign --force --entitlements "$ENTITLEMENTS" -s "$SIGNING_IDENTITY" \
  "$SPARKLE_BASE/XPCServices/Downloader.xpc/Contents/MacOS/Downloader"

echo "🔐 簽署 Installer.xpc..."
codesign --force --entitlements "$ENTITLEMENTS" -s "$SIGNING_IDENTITY" \
  "$SPARKLE_BASE/XPCServices/Installer.xpc/Contents/MacOS/Installer"

echo "🔐 簽署 Updater.app..."
codesign --force --entitlements "$ENTITLEMENTS" -s "$SIGNING_IDENTITY" \
  "$SPARKLE_BASE/Updater.app/Contents/MacOS/Updater"

echo "🔐 簽署 Autoupdate..."
codesign --force --entitlements "$ENTITLEMENTS" -s "$SIGNING_IDENTITY" \
  "$SPARKLE_BASE/Autoupdate"

echo ""
echo "✅ Sparkle Framework 簽章完成"
echo ""

# ============================================
# 建立 xcarchive
# ============================================
echo "=================================================="
echo "📦 建立 xcarchive"
echo "=================================================="
echo ""

xcodebuild archive \
  -workspace ./macos/Runner.xcworkspace \
  -scheme Store \
  -archivePath "$OUTPUT_DIR/$ARCHIVE_NAME" \
  -destination "generic/platform=macOS,variant=macos" \
  ARCHS="x86_64 arm64" \
  ONLY_ACTIVE_ARCH=NO

echo ""
echo "✅ xcarchive 建立完成"
echo ""

# ============================================
# 移除 xcarchive 內的 quarantine 屬性
# ============================================
echo "🧹 移除 xcarchive 內的 quarantine 擴展屬性..."
xattr -dr com.apple.quarantine "$OUTPUT_DIR/$ARCHIVE_NAME" 2>/dev/null || true
echo "✅ Quarantine 屬性已移除"
echo ""

# ============================================
# 從 xcarchive 匯出 pkg（用於上傳至 TestFlight）
# ============================================
echo "=================================================="
echo "📦 從 xcarchive 匯出 pkg 檔案"
echo "=================================================="
echo ""

EXPORT_OPTIONS_PLIST="scripts/macos/ExportOptions.plist"
EXPORT_TEMP_DIR="$OUTPUT_DIR/export_temp"

# 檢查 ExportOptions.plist 是否存在
if [ ! -f "$EXPORT_OPTIONS_PLIST" ]; then
  echo "❌ ExportOptions.plist 不存在: $EXPORT_OPTIONS_PLIST"
  exit 1
fi

echo "Export Options: $EXPORT_OPTIONS_PLIST"
echo "Export Temp Dir: $EXPORT_TEMP_DIR"
echo ""

# 使用 xcodebuild -exportArchive 匯出 pkg
xcodebuild -exportArchive \
  -archivePath "$OUTPUT_DIR/$ARCHIVE_NAME" \
  -exportPath "$EXPORT_TEMP_DIR" \
  -exportOptionsPlist "$EXPORT_OPTIONS_PLIST"

echo ""

# 尋找匯出的 pkg 檔案並移動到輸出目錄
if [ -d "$EXPORT_TEMP_DIR" ]; then
  # 找到 pkg 檔案（xcodebuild 會自動命名）
  EXPORTED_PKG=$(find "$EXPORT_TEMP_DIR" -name "*.pkg" -type f | head -n 1)

  if [ -n "$EXPORTED_PKG" ] && [ -f "$EXPORTED_PKG" ]; then
    echo "✅ 找到匯出的 pkg: $(basename "$EXPORTED_PKG")"

    # 重新命名並移動到輸出目錄
    mv "$EXPORTED_PKG" "$OUTPUT_DIR/$PKG_NAME"
    echo "✅ PKG 已重新命名為: $PKG_NAME"

    PKG_SIZE=$(du -sh "$OUTPUT_DIR/$PKG_NAME" | cut -f1)
    echo "📦 PKG 大小: $PKG_SIZE"
  else
    echo "⚠️  找不到匯出的 pkg 檔案"
  fi

  # 清理暫存目錄
  rm -rf "$EXPORT_TEMP_DIR"
  echo "🗑️  已清理暫存目錄"
else
  echo "❌ 匯出目錄不存在: $EXPORT_TEMP_DIR"
fi

echo ""
echo "✅ PKG 匯出完成"
echo ""

# ============================================
# 打包 xcarchive 為 tar.gz（保留符號連結）
# ============================================
echo "=================================================="
echo "📦 打包 xcarchive（保留符號連結）"
echo "=================================================="
echo ""

# Azure Pipeline 的 PublishPipelineArtifact 會破壞符號連結
# 所以我們需要先打包成 tar.gz 來保留符號連結結構

ARCHIVE_TAR_NAME="${ARCHIVE_NAME}.tar.gz"

cd "$OUTPUT_DIR"

if [ -d "$ARCHIVE_NAME" ]; then
  echo "🗜️  打包: $ARCHIVE_NAME -> $ARCHIVE_TAR_NAME"
  tar -czf "$ARCHIVE_TAR_NAME" "$ARCHIVE_NAME"

  ARCHIVE_TAR_SIZE=$(du -sh "$ARCHIVE_TAR_NAME" | cut -f1)
  echo "✅ 打包完成，大小: $ARCHIVE_TAR_SIZE"

  # 移除原始目錄以節省空間
  echo "🗑️  移除原始 xcarchive 目錄"
  rm -rf "$ARCHIVE_NAME"
  echo ""
else
  echo "⚠️  找不到 xcarchive: $ARCHIVE_NAME"
  echo ""
fi

cd - > /dev/null

# ============================================
# 顯示建置資訊
# ============================================
echo "=================================================="
echo "📦 建置產物摘要"
echo "=================================================="
echo ""

echo "檔案清單："
echo "  - $OUTPUT_DIR/$APP_NAME"
echo "  - $OUTPUT_DIR/$PKG_NAME"
echo "  - $OUTPUT_DIR/$ARCHIVE_TAR_NAME"
echo "  - $OUTPUT_DIR/$DEBUG_INFO_DIR/"
echo ""

if [ -d "$OUTPUT_DIR/$APP_NAME" ]; then
  APP_SIZE=$(du -sh "$OUTPUT_DIR/$APP_NAME" | cut -f1)
  echo "📱 App 大小: $APP_SIZE"
fi

if [ -f "$OUTPUT_DIR/$PKG_NAME" ]; then
  PKG_SIZE=$(du -sh "$OUTPUT_DIR/$PKG_NAME" | cut -f1)
  echo "📦 PKG 大小: $PKG_SIZE"
fi

if [ -f "$OUTPUT_DIR/$ARCHIVE_TAR_NAME" ]; then
  ARCHIVE_SIZE=$(du -sh "$OUTPUT_DIR/$ARCHIVE_TAR_NAME" | cut -f1)
  echo "📦 Archive (tar.gz) 大小: $ARCHIVE_SIZE"
fi

if [ -d "$OUTPUT_DIR/$DEBUG_INFO_DIR" ]; then
  DEBUG_SIZE=$(du -sh "$OUTPUT_DIR/$DEBUG_INFO_DIR" | cut -f1)
  echo "🐛 Debug Info 大小: $DEBUG_SIZE"
fi

echo ""
echo "=================================================="
echo "🎉 建置成功完成！"
echo "=================================================="
