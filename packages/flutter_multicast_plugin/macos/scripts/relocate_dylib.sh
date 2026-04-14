#!/bin/bash
# 用法：./relocate_dylibs.sh <dylib_folder>

set -e

if [ -z "$1" ]; then
  echo "❌ 請提供 dylib 目錄作為參數"
  exit 1
fi

DYLIB_DIR="$1"

if [ ! -d "$DYLIB_DIR" ]; then
  echo "❌ 找不到目錄 $DYLIB_DIR"
  exit 1
fi

echo "🔧 Patching all dylibs in: $DYLIB_DIR"
for dylib in "$DYLIB_DIR"/*.dylib; do
    [ -e "$dylib" ] || continue

    echo "📦 Processing $(basename "$dylib")"

    # 1. 改自身的 install_name
    install_name_tool -id "@loader_path/../Resources/gstreamer-frameworks/lib/$(basename "$dylib")" "$dylib"

    # 2. 找出它依賴的其他 dylib 並 patch
    otool -L "$dylib" | tail -n +2 | awk '{print $1}' | while read dep; do
        # 僅 patch以 lib 開頭，且非系統路徑的依賴
        if [[ "$dep" == lib* && "$dep" != /usr/lib/* && "$dep" != /System/* ]]; then
            new_dep="@loader_path/../Resources/gstreamer-frameworks/lib/$(basename "$dep")"
            echo "    🔁 Changing $dep → $new_dep"
            install_name_tool -change "$dep" "$new_dep" "$dylib"
        fi
    done
done

echo "✅ All dylibs patched for @loader_path/../Resources/gstreamer-frameworks/"