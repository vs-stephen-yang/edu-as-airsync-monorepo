#!/bin/bash

set -e
set -o pipefail

# 設定基本參數
ARCH=arm64
SDK=iphoneos
BUILD_DIR=build
CRYPTOPP_SRC=../native_libs/cryptopp
UVGRTP_SRC=../native_libs/uvgrtp

# 預設為完整 build
CLEAN_BUILD=true

if [[ -n "$LOG_LEVEL" ]]; then
  echo "📣 使用 LOG_LEVEL=$LOG_LEVEL"
else
  echo "⚠️  未設定 LOG_LEVEL，使用預設值"
  LOG_LEVEL="LOG_LEVEL_DEBUG"
fi

# 解析參數
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
      echo "Unknown option: $1"
      echo "Usage: $0 [--fast|-f] [--clean|-c]"
      echo "  --fast/-f  : 快速 build (不重新設定 CMake)"
      echo "  --clean/-c : 完整 build (預設)"
      exit 1
      ;;
  esac
done

# 條件式清理和設定
if [ "$CLEAN_BUILD" = true ]; then
    echo "🧹 執行完整 build (清理並重新設定 CMake)"
    # 清空以前的 build 資料
    rm -rf $BUILD_DIR libs
    mkdir -p $BUILD_DIR libs
    
    # 啟動 CMake 編譯
    cmake -S . -B $BUILD_DIR \
      -DCMAKE_SYSTEM_NAME=iOS \
      -DCMAKE_OSX_ARCHITECTURES=$ARCH \
      -DCMAKE_OSX_SYSROOT=$(xcrun --sdk $SDK --show-sdk-path) \
      -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
      -DCMAKE_BUILD_TYPE=Release \
      -DLOG_LEVEL=$LOG_LEVEL
else
    echo "⚡ 執行快速 build (重用現有 CMake 設定)"
    # 只確保輸出目錄存在
    mkdir -p libs
    
    # 檢查是否已經有 CMake 設定
    if [ ! -f "$BUILD_DIR/CMakeCache.txt" ]; then
        echo "❌ 錯誤：找不到現有的 CMake 設定，請先執行完整 build"
        echo "使用: $0 --clean"
        exit 1
    fi
fi

# 執行編譯
echo "🔨 開始編譯..."
cmake --build $BUILD_DIR --config Release

# 複製 .a 檔到 libs
cp $BUILD_DIR/libcryptopp.a libs/
cp $BUILD_DIR/uvgrtp/libuvgrtp.a libs/
cp $BUILD_DIR/libcommon.a libs/
cp $BUILD_DIR/libgst_ios_init.a libs/

echo ""
echo "✅ Build & export 完成！"
echo "🔹 libs 輸出位置：ios/libs/"