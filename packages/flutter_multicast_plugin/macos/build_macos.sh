#!/bin/bash

set -e
set -o pipefail

ARCHS=("arm64" "x86_64")
BUILD_DIR_BASE="build"
LIB_DIR="libs"
CLEAN_BUILD=true

if [[ -z "$LOG_LEVEL" ]]; then
  LOG_LEVEL="LOG_LEVEL_DEBUG"
  echo "⚠️  未設定 LOG_LEVEL，使用預設：$LOG_LEVEL"
else
  echo "🔔 LOG_LEVEL = $LOG_LEVEL"
fi

while [[ $# -gt 0 ]]; do
  case $1 in
    --fast|-f)
      CLEAN_BUILD=false
      shift
      ;;
    --clean|-c)
      CLEAN_BUILD=true
      shift
      ;;
    *)
      echo "❌ Unknown option: $1"
      exit 1
      ;;
  esac
done

if [ "$CLEAN_BUILD" = true ]; then
  echo "🧹 清理所有 build 資料夾與 libs/"
  rm -rf "${BUILD_DIR_BASE}-"* "$LIB_DIR"
fi

mkdir -p "$LIB_DIR"

# build 每個架構
for ARCH in "${ARCHS[@]}"; do
  BUILD_DIR="${BUILD_DIR_BASE}-${ARCH}"
  echo "🔧 編譯架構：$ARCH ➤ $BUILD_DIR"

  if [ "$CLEAN_BUILD" = true ] || [ ! -f "$BUILD_DIR/CMakeCache.txt" ]; then
    cmake -S . -B "$BUILD_DIR" \
      -DCMAKE_SYSTEM_NAME=Darwin \
      -DCMAKE_OSX_ARCHITECTURES="$ARCH" \
      -DCMAKE_OSX_DEPLOYMENT_TARGET=10.14 \
      -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
      -DCMAKE_BUILD_TYPE=Release \
      -DLOG_LEVEL="$LOG_LEVEL"
  else
    echo "⚡ 快速模式：跳過 CMake configure ($ARCH)"
  fi

  cmake --build "$BUILD_DIR" --config Release

  # 🔁 複製各個架構版本的 .a 檔（純備份用途，非 universal）
  cp "$BUILD_DIR/libcommon.a" "$LIB_DIR/libcommon_$ARCH.a"
  cp "$BUILD_DIR/uvgrtp/libuvgrtp.a" "$LIB_DIR/libuvgrtp_$ARCH.a"
  cp "$BUILD_DIR/libcryptopp.a" "$LIB_DIR/libcryptopp_$ARCH.a"
done

# 合併為 universal binary
echo "📦 合併為 universal .a"

LIBS=("libcommon.a" "libuvgrtp.a" "libcryptopp.a")

for LIB in "${LIBS[@]}"; do
  lipo -create \
    "$LIB_DIR/${LIB%.a}_arm64.a" \
    "$LIB_DIR/${LIB%.a}_x86_64.a" \
    -output "$LIB_DIR/$LIB"
  echo "✅ 合併完成：$LIB"
done

echo ""
echo "📦 所有 universal libraries 已生成到：$LIB_DIR/"
echo "🔍 可用 lipo -info libs/*.a 查看架構內容"