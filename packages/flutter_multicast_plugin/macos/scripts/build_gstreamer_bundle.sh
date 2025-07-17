#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

GSTREAMER_ROOT="${GSTREAMER_SDK_MACOS}"
if [ -z "$GSTREAMER_ROOT" ]; then
  echo "❌ Error: GSTREAMER_SDK_MACOS environment variable not set"
  exit 1
fi

GST_LIB_PATH="${GSTREAMER_ROOT}/lib"
GST_PLUGIN_PATH="${GST_LIB_PATH}/gstreamer-1.0"

FRAMEWORK_DIR="${ROOT_DIR}/gstreamer-frameworks"

DEST_DYLIBS_DIR="${ROOT_DIR}/gstreamer-dylibs"
DEST_CORE_PATH="${FRAMEWORK_DIR}/lib"
DEST_PLUGIN_PATH="${FRAMEWORK_DIR}/gstreamer-1.0"
DEST_HEADER_PATH="${ROOT_DIR}/gstreamer-headers"

mkdir -p ${DEST_CORE_PATH}
mkdir -p ${DEST_PLUGIN_PATH}
mkdir -p ${DEST_DYLIBS_DIR}
mkdir -p ${DEST_HEADER_PATH}

# Copy Headers
cp -R "${GSTREAMER_ROOT}/Headers/" "${DEST_HEADER_PATH}"

CORE_DYLIBS=(
    # Base system (base-system-1.0 equivalent)
    libffi.7.dylib libbz2.1.dylib libintl.8.dylib liborc-0.4.0.dylib 
    libpcre2-8.0.dylib libz.1.dylib 
    libglib-2.0.0.dylib libgobject-2.0.0.dylib libgmodule-2.0.0.dylib 
    libgthread-2.0.0.dylib libgio-2.0.0.dylib 
    
    # GStreamer core (gstreamer-1.0-core equivalent)
    libgstreamer-1.0.0.dylib libgstbase-1.0.0.dylib libgstapp-1.0.0.dylib 
    libgstvideo-1.0.0.dylib libgstaudio-1.0.0.dylib libgsttag-1.0.0.dylib 
    libgstpbutils-1.0.0.dylib libgstcontroller-1.0.0.dylib 
    
    # GStreamer codecs (gstreamer-1.0-codecs equivalent)
    libgstcodecparsers-1.0.0.dylib libavfilter.10.dylib libavformat.61.dylib 
    libavcodec.61.dylib libavutil.59.dylib libswresample.5.dylib
)

echo "📁 Copying core .dylibs..."
for dylib in "${CORE_DYLIBS[@]}"; do
  src="${GST_LIB_PATH}/${dylib}"
  dest="${DEST_CORE_PATH}/${dylib}"
  if [ -f "$src" ]; then
    cp "$src" "$dest"
    echo "✅ Copied $dylib"
  else
    echo "⚠️  Missing $dylib"
  fi
done

CORE_PLUGINS=(
    libgstcoreelements.dylib 
    libgstapp.dylib 
    libgstvideoparsersbad.dylib 
    libgstvideoconvertscale.dylib 
    libgstlibav.dylib 
    libgstopenh264.dylib
)

# ... 同理 plugin 路徑也換成 $FRAMEWORK_DIR
echo "📁 Copying plugin .dylibs..."
for dylib in "${CORE_PLUGINS[@]}"; do
  src="${GST_PLUGIN_PATH}/${dylib}"
  dest="${DEST_PLUGIN_PATH}/${dylib}"
  if [ -f "$src" ]; then
    cp "$src" "$dest"
    echo "✅ Copied $dylib"
  else
    echo "⚠️  Missing $dylib"
  fi
done

# Relocate
# Core .dylib → 依賴 core dylib 用 @loader_path/lib/
python3 "${SCRIPT_DIR}/relocator.py" "${DEST_CORE_PATH}" @loader_path .
# Plugin .dylib → 依賴 core dylib 用 @loader_path/../lib/
python3 "${SCRIPT_DIR}/relocator.py" "${DEST_PLUGIN_PATH}" @loader_path ../lib

# Copy to gstreamer-dylibs
cp "${DEST_CORE_PATH}/"*.dylib "${DEST_DYLIBS_DIR}/"

# Call relocate_dylib.sh (也要放在 scripts/)
bash "${SCRIPT_DIR}/relocate_dylib.sh" "${DEST_DYLIBS_DIR}"