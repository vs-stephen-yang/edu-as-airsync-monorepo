#!/usr/bin/env bash
set -euo pipefail

ENV_NAME="${1:-production}"
VERSION_NAME="${2:-}"
VERSION_CODE="${3:-}"
OUTPUT_DIR="${4:-./build_output}"

FLUTTER_BIN="${FLUTTER_BIN:-flutter}"
SPLIT_DEBUG_ROOT="${SPLIT_DEBUG_ROOT:-build/debug-info}"

say() { printf "\n\033[1;36m%s\033[0m\n" "$*"; }
fail() { printf "\n\033[1;31m%s\033[0m\n" "$*"; exit 1; }

case "$ENV_NAME" in
  dev|development) FLAVOR=Dev;   TARGET="lib/main_dev.dart";        CONFIG="Release-Dev" ;;
  stage|staging)   FLAVOR=Stage; TARGET="lib/main_stage.dart";      CONFIG="Release-Stage" ;;
  prod|production|store) FLAVOR=Store; TARGET="lib/main_production.dart"; CONFIG="Release-Store" ;;
  *) fail "Unknown env: $ENV_NAME (expected dev|stage|production)";;
esac

if [ -z "$VERSION_NAME" ] || [ -z "$VERSION_CODE" ]; then
  [ -f pubspec.yaml ] || fail "pubspec.yaml not found"
  raw="$(grep -E '^version:' pubspec.yaml | head -n1 | awk '{print $2}')"
  VERSION_NAME="${VERSION_NAME:-${raw%%+*}}"
  vcode="${raw#*+}"; [ "$vcode" = "$raw" ] && vcode="0"
  VERSION_CODE="${VERSION_CODE:-$vcode}"
fi

mkdir -p "$OUTPUT_DIR"

say "Environment    : $ENV_NAME"
say "Flavor/Config  : $FLAVOR / $CONFIG"
say "Target Dart    : $TARGET"
say "Version        : ${VERSION_NAME} (${VERSION_CODE})"
say "Split debug    : ${SPLIT_DEBUG_ROOT}/${FLAVOR}"

${FLUTTER_BIN} pub get
${FLUTTER_BIN} build macos --flavor "$FLAVOR" -t "$TARGET"   --release   --build-name="$VERSION_NAME" --build-number="$VERSION_CODE"   --split-debug-info="${SPLIT_DEBUG_ROOT}/${FLAVOR}" --obfuscate

PROD_DIR="build/macos/Build/Products/${CONFIG}"
APP_PATH="$(ls -1d "${PROD_DIR}"/*.app | head -n1 || true)"
[ -z "$APP_PATH" ] && fail "No .app found under ${PROD_DIR}"
APP_NAME="$(basename "$APP_PATH")"
APP_STEM="${APP_NAME%.app}"

DATE_TEXT="$(date '+%Y%m%d')"
APP_ZIP="${OUTPUT_DIR}/${APP_STEM}-${FLAVOR}-v${VERSION_NAME}(${VERSION_CODE})-${DATE_TEXT}.zip"
/usr/bin/ditto -c -k --keepParent "$APP_PATH" "$APP_ZIP"

ARCHIVE_PATH="${OUTPUT_DIR}/${APP_STEM}-${FLAVOR}-${DATE_TEXT}.xcarchive"
xcodebuild archive   -workspace ./macos/Runner.xcworkspace   -scheme Runner   -configuration "$CONFIG"   -archivePath "$ARCHIVE_PATH"   -destination 'generic/platform=macOS'   ONLY_ACTIVE_ARCH=NO

say "Artifacts:"
echo "  - $APP_ZIP"
echo "  - $ARCHIVE_PATH"
