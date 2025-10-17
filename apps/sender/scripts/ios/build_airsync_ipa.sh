#!/bin/bash

# iOS IPA 建置腳本
# 用法：./build_airsync_ipa.sh <env> <version_name> <version_code> <output_dir>
# 例如：./build_airsync_ipa.sh stage 1.2.3 456 /path/to/output

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
echo "🚀 iOS IPA 建置腳本"
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
# GStreamer SDK 檢查
# ============================================
echo "🔍 檢查 GStreamer SDK..."

if [ -z "${GSTREAMER_SDK_IOS:-}" ]; then
  # 嘗試自動偵測
  POSSIBLE_PATHS=(
    "/Users/agent/Library/Developer/GStreamer/iPhone.sdk/GStreamer.framework"
    "/Library/Frameworks/GStreamer.framework"
    "$HOME/Library/Developer/GStreamer/iPhone.sdk/GStreamer.framework"
  )

  for path in "${POSSIBLE_PATHS[@]}"; do
    if [ -d "$path" ]; then
      export GSTREAMER_SDK_IOS="$path"
      echo "✅ 自動偵測到 GSTREAMER_SDK_IOS: $GSTREAMER_SDK_IOS"
      break
    fi
  done

  if [ -z "${GSTREAMER_SDK_IOS:-}" ]; then
    echo "❌ 找不到 GStreamer SDK！"
    echo ""
    echo "嘗試過的路徑："
    for path in "${POSSIBLE_PATHS[@]}"; do
      echo "  - $path"
    done
    echo ""
    echo "請設定 GSTREAMER_SDK_IOS 環境變數"
    exit 1
  fi
else
  echo "✅ GSTREAMER_SDK_IOS: $GSTREAMER_SDK_IOS"

  if [ ! -d "$GSTREAMER_SDK_IOS" ]; then
    echo "❌ GStreamer SDK 路徑不存在: $GSTREAMER_SDK_IOS"
    exit 1
  fi
fi

echo ""

# ============================================
# 準備輸出目錄
# ============================================
echo "📁 準備輸出目錄..."

# 決定檔案名稱
case "$ENV_NAME" in
  dev)
    ENV_MARK="D"
    ;;
  stage)
    ENV_MARK="S"
    ;;
  production)
    ENV_MARK=""
    ;;
  *)
    echo "❌ 不支援的環境: $ENV_NAME"
    echo "   支援的環境: dev, stage, production"
    exit 1
    ;;
esac

if [ -n "$ENV_MARK" ]; then
  IPA_NAME="iOS_${ENV_MARK}_v${VERSION_NAME}.ipa"
  ARCHIVE_NAME="iOS_${ENV_MARK}_v${VERSION_NAME}.xcarchive"
else
  IPA_NAME="iOS_v${VERSION_NAME}.ipa"
  ARCHIVE_NAME="iOS_v${VERSION_NAME}.xcarchive"
fi

DEBUG_INFO_DIR="${IPA_NAME}.debug_info"

echo "IPA 檔名      : $IPA_NAME"
echo "Archive 檔名  : $ARCHIVE_NAME"
echo "Debug Info    : $DEBUG_INFO_DIR"
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
# 建置 IPA
# ============================================
echo "=================================================="
echo "🔨 開始建置 IPA"
echo "=================================================="
echo ""

# 完全參考本地 command 腳本的做法
# 不傳遞任何簽章參數，讓 Xcode 自動處理
$FLUTTER_CMD build ipa \
  -t "lib/main_${ENV_NAME}.dart" \
  --obfuscate \
  --split-debug-info="$OUTPUT_DIR/$DEBUG_INFO_DIR/" \
  --build-name="$VERSION_NAME" \
  --build-number="$VERSION_CODE" \
  --verbose

echo ""
echo "=================================================="
echo "✅ 建置完成！"
echo "=================================================="
echo ""

# ============================================
# 複製產物
# ============================================
echo "📦 複製建置產物..."

cp -R "build/ios/ipa/AirSync Sender.ipa" "$OUTPUT_DIR/$IPA_NAME"
cp -R "build/ios/archive/Runner.xcarchive" "$OUTPUT_DIR/$ARCHIVE_NAME"

echo ""
echo "✅ 產物已複製到: $OUTPUT_DIR"
echo ""
echo "檔案清單："
echo "  - $OUTPUT_DIR/$IPA_NAME"
echo "  - $OUTPUT_DIR/$ARCHIVE_NAME"
echo "  - $OUTPUT_DIR/$DEBUG_INFO_DIR/"
echo ""

# ============================================
# 顯示建置資訊
# ============================================
IPA_SIZE=$(du -h "$OUTPUT_DIR/$IPA_NAME" | cut -f1)
echo "IPA 大小: $IPA_SIZE"
echo ""

echo "=================================================="
echo "🎉 建置成功完成！"
echo "=================================================="
