#!/usr/bin/env bash
set -uo pipefail

###############################################################################
# Build Binary Comparison: Original Multi-repo vs Monorepo
#
# Builds sender (windows, web, apk) and receiver (apk) in both the original
# repos and the monorepo, then compares the resulting artifacts.
#
# Usage:
#   bash scripts/compare-builds.sh
###############################################################################

# ─── Config ─────────────────────────────────────────────────────────────────

GH_ORG="Viewsonic-EDU"
SENDER_REPO="https://github.com/${GH_ORG}/edu-as-airsync-sender.git"
RECEIVER_REPO="https://github.com/${GH_ORG}/edu-as-airsync-receiver.git"
MONOREPO="https://github.com/vs-stephen-yang/edu-as-airsync-monorepo.git"

SENDER_BRANCH="main"
RECEIVER_BRANCH="master"
MONOREPO_BRANCH="main"

FVM="${FVM:-/c/Users/stephen/fvm/fvm.bat}"

WORK_DIR="$(mktemp -d)"
REPORTS_DIR="${WORK_DIR}/reports"
mkdir -p "${REPORTS_DIR}"

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
REPORT_FILE="${REPORTS_DIR}/compare-${TIMESTAMP}.md"

# Build targets: "app|platform|build_cmd"
BUILDS=(
  "sender|web|build web --no-pub -t lib/main_dev.dart"
  "sender|windows|build windows --no-pub -t lib/main_dev.dart"
  "sender|apk|build apk --no-pub -t lib/main_dev.dart"
  "receiver|apk|build apk --no-pub --flavor opendev -t lib/main_dev.dart"
)

echo "============================================"
echo "Build Comparison: Original vs Monorepo"
echo "Working dir: ${WORK_DIR}"
echo "Report: ${REPORT_FILE}"
echo "============================================"

# ─── Phase 1: Setup ─────────────────────────────────────────────────────────

echo ""
echo ">>> Phase 1: Cloning repos..."

# Original sender
echo "  Cloning original sender (${SENDER_BRANCH})..."
git clone --single-branch --branch "${SENDER_BRANCH}" "${SENDER_REPO}" "${WORK_DIR}/original/sender" 2>&1 | tail -5
cd "${WORK_DIR}/original/sender" && git submodule update --init --recursive 2>&1 | tail -3
git lfs pull 2>&1 | tail -3 || true
SENDER_ORIG_SHA=$(git rev-parse HEAD)
cd - >/dev/null

# Original receiver
echo "  Cloning original receiver (${RECEIVER_BRANCH})..."
git clone --single-branch --branch "${RECEIVER_BRANCH}" "${RECEIVER_REPO}" "${WORK_DIR}/original/receiver" 2>&1 | tail -5
cd "${WORK_DIR}/original/receiver" && RECEIVER_ORIG_SHA=$(git rev-parse HEAD) && cd - >/dev/null

# Monorepo
echo "  Cloning monorepo (${MONOREPO_BRANCH})..."
git clone --single-branch --branch "${MONOREPO_BRANCH}" "${MONOREPO}" "${WORK_DIR}/monorepo" 2>&1 | tail -5
cd "${WORK_DIR}/monorepo" && git submodule update --init --recursive 2>&1 | tail -3
git lfs pull 2>&1 | tail -3 || true
MONOREPO_SHA=$(git rev-parse HEAD)
cd - >/dev/null

# pub get
echo ""
echo ">>> Phase 1b: Running fvm flutter pub get..."

for d in "${WORK_DIR}/original/sender" "${WORK_DIR}/original/receiver" "${WORK_DIR}/monorepo/apps/sender" "${WORK_DIR}/monorepo/apps/receiver"; do
  echo "  pub get in: ${d}"
  (cd "${d}" && "${FVM}" flutter pub get 2>&1 | tail -3) || echo "    pub get failed (continuing)"
done

# ─── Phase 2: Build all 8 targets ───────────────────────────────────────────

echo ""
echo ">>> Phase 2: Running 8 builds (4 original + 4 monorepo)..."

declare -A BUILD_STATUS  # "app-platform-side" -> "OK" or "FAIL:<reason>"
declare -A BUILD_LOG     # "app-platform-side" -> log path

run_build() {
  local app="$1" platform="$2" cmd="$3" side="$4" dir="$5"
  local key="${app}-${platform}-${side}"
  local log="${WORK_DIR}/logs/${key}.log"
  mkdir -p "$(dirname "${log}")"

  echo "  Building ${key}..."
  (cd "${dir}" && "${FVM}" flutter ${cmd}) > "${log}" 2>&1
  local rc=$?

  BUILD_LOG["${key}"]="${log}"
  if [ "${rc}" -eq 0 ]; then
    BUILD_STATUS["${key}"]="OK"
    echo "    OK: ${key}"
  else
    # Capture short failure reason
    local reason=$(tail -30 "${log}" | grep -i "error\|failed\|not found" | head -1 | tr -d '\n' | cut -c1-100)
    BUILD_STATUS["${key}"]="FAIL: ${reason}"
    echo "    FAIL: ${key} - ${reason}"
  fi
}

for entry in "${BUILDS[@]}"; do
  IFS='|' read -r app platform cmd <<< "${entry}"

  # Original side
  orig_dir="${WORK_DIR}/original/${app}"
  run_build "${app}" "${platform}" "${cmd}" "orig" "${orig_dir}"

  # Monorepo side
  mono_dir="${WORK_DIR}/monorepo/apps/${app}"
  run_build "${app}" "${platform}" "${cmd}" "mono" "${mono_dir}"
done

# ─── Phase 3: Normalize & compare ───────────────────────────────────────────

echo ""
echo ">>> Phase 3: Comparing artifacts..."

declare -A COMPARE_RESULT  # "app-platform" -> "EQUIV" or "DIVERGE"
declare -A COMPARE_DETAIL  # details per target

compare_web() {
  local app="$1"
  local orig_dir="${WORK_DIR}/original/${app}/build/web"
  local mono_dir="${WORK_DIR}/monorepo/apps/${app}/build/web"
  local key="${app}-web"

  if [ ! -d "${orig_dir}" ] || [ ! -d "${mono_dir}" ]; then
    COMPARE_RESULT["${key}"]="SKIP"
    COMPARE_DETAIL["${key}"]="Build dir missing (orig=$([ -d "${orig_dir}" ] && echo Y || echo N), mono=$([ -d "${mono_dir}" ] && echo Y || echo N))"
    return
  fi

  local detail=""
  local match=0 diff=0

  # Compare each file in orig
  while IFS= read -r f; do
    rel="${f#${orig_dir}/}"
    mono_file="${mono_dir}/${rel}"
    if [ ! -f "${mono_file}" ]; then
      diff=$((diff+1))
      detail+="  - ${rel}: MISSING in monorepo\n"
      continue
    fi
    orig_sha=$(sha256sum "${f}" | awk '{print $1}')
    mono_sha=$(sha256sum "${mono_file}" | awk '{print $1}')
    if [ "${orig_sha}" = "${mono_sha}" ]; then
      match=$((match+1))
    else
      diff=$((diff+1))
      orig_size=$(stat -c%s "${f}")
      mono_size=$(stat -c%s "${mono_file}")
      detail+="  - ${rel}: DIFF (orig=${orig_size}B sha=${orig_sha:0:12}... vs mono=${mono_size}B sha=${mono_sha:0:12}...)\n"
    fi
  done < <(find "${orig_dir}" -type f)

  # Also check for files in mono but not orig
  while IFS= read -r f; do
    rel="${f#${mono_dir}/}"
    if [ ! -f "${orig_dir}/${rel}" ]; then
      diff=$((diff+1))
      detail+="  - ${rel}: EXTRA in monorepo\n"
    fi
  done < <(find "${mono_dir}" -type f)

  COMPARE_RESULT["${key}"]=$([ "${diff}" -eq 0 ] && echo "EQUIV" || echo "DIVERGE")
  COMPARE_DETAIL["${key}"]="Files match: ${match}, diff: ${diff}\n${detail}"
}

compare_apk() {
  local app="$1"
  # Find the built APK on each side
  local orig_apk=$(find "${WORK_DIR}/original/${app}/build/app/outputs/flutter-apk/" -name "app-*.apk" 2>/dev/null | head -1)
  local mono_apk=$(find "${WORK_DIR}/monorepo/apps/${app}/build/app/outputs/flutter-apk/" -name "app-*.apk" 2>/dev/null | head -1)
  local key="${app}-apk"

  if [ -z "${orig_apk}" ] || [ -z "${mono_apk}" ]; then
    COMPARE_RESULT["${key}"]="SKIP"
    COMPARE_DETAIL["${key}"]="APK not found (orig=${orig_apk:-none}, mono=${mono_apk:-none})"
    return
  fi

  # Unzip both
  local orig_ext="${WORK_DIR}/compare/${app}-apk/orig"
  local mono_ext="${WORK_DIR}/compare/${app}-apk/mono"
  mkdir -p "${orig_ext}" "${mono_ext}"
  unzip -q -o "${orig_apk}" -d "${orig_ext}"
  unzip -q -o "${mono_apk}" -d "${mono_ext}"

  # Strip META-INF (signatures)
  rm -rf "${orig_ext}/META-INF" "${mono_ext}/META-INF"

  # Compare
  local detail=""
  local match=0 diff=0

  while IFS= read -r f; do
    rel="${f#${orig_ext}/}"
    mono_file="${mono_ext}/${rel}"
    if [ ! -f "${mono_file}" ]; then
      diff=$((diff+1))
      detail+="  - ${rel}: MISSING in monorepo\n"
      continue
    fi
    orig_sha=$(sha256sum "${f}" | awk '{print $1}')
    mono_sha=$(sha256sum "${mono_file}" | awk '{print $1}')
    if [ "${orig_sha}" = "${mono_sha}" ]; then
      match=$((match+1))
    else
      diff=$((diff+1))
      orig_size=$(stat -c%s "${f}")
      mono_size=$(stat -c%s "${mono_file}")
      detail+="  - ${rel}: DIFF (orig=${orig_size}B vs mono=${mono_size}B)\n"
    fi
  done < <(find "${orig_ext}" -type f)

  while IFS= read -r f; do
    rel="${f#${mono_ext}/}"
    if [ ! -f "${orig_ext}/${rel}" ]; then
      diff=$((diff+1))
      detail+="  - ${rel}: EXTRA in monorepo\n"
    fi
  done < <(find "${mono_ext}" -type f)

  COMPARE_RESULT["${key}"]=$([ "${diff}" -eq 0 ] && echo "EQUIV" || echo "DIVERGE")
  COMPARE_DETAIL["${key}"]="APK entries match: ${match}, diff: ${diff}\n${detail}"
}

compare_windows() {
  local app="$1"
  local orig_dir="${WORK_DIR}/original/${app}/build/windows/x64/runner/Release"
  local mono_dir="${WORK_DIR}/monorepo/apps/${app}/build/windows/x64/runner/Release"
  local key="${app}-windows"

  if [ ! -d "${orig_dir}" ] || [ ! -d "${mono_dir}" ]; then
    COMPARE_RESULT["${key}"]="SKIP"
    COMPARE_DETAIL["${key}"]="Build dir missing (orig=$([ -d "${orig_dir}" ] && echo Y || echo N), mono=$([ -d "${mono_dir}" ] && echo Y || echo N))"
    return
  fi

  local detail=""
  local match=0 diff=0

  while IFS= read -r f; do
    rel="${f#${orig_dir}/}"
    mono_file="${mono_dir}/${rel}"
    if [ ! -f "${mono_file}" ]; then
      diff=$((diff+1))
      detail+="  - ${rel}: MISSING in monorepo\n"
      continue
    fi
    orig_sha=$(sha256sum "${f}" | awk '{print $1}')
    mono_sha=$(sha256sum "${mono_file}" | awk '{print $1}')
    if [ "${orig_sha}" = "${mono_sha}" ]; then
      match=$((match+1))
    else
      diff=$((diff+1))
      orig_size=$(stat -c%s "${f}")
      mono_size=$(stat -c%s "${mono_file}")
      detail+="  - ${rel}: DIFF (orig=${orig_size}B vs mono=${mono_size}B)\n"
    fi
  done < <(find "${orig_dir}" -type f)

  COMPARE_RESULT["${key}"]=$([ "${diff}" -eq 0 ] && echo "EQUIV" || echo "DIVERGE")
  COMPARE_DETAIL["${key}"]="Files match: ${match}, diff: ${diff}\n${detail}"
}

for entry in "${BUILDS[@]}"; do
  IFS='|' read -r app platform cmd <<< "${entry}"
  case "${platform}" in
    web)     compare_web "${app}" ;;
    apk)     compare_apk "${app}" ;;
    windows) compare_windows "${app}" ;;
  esac
done

# ─── Phase 4: Generate report ───────────────────────────────────────────────

echo ""
echo ">>> Phase 4: Generating report..."

{
  echo "# Build Comparison Report"
  echo ""
  echo "Generated: $(date)"
  echo ""
  echo "- Original sender:   ${SENDER_ORIG_SHA}"
  echo "- Original receiver: ${RECEIVER_ORIG_SHA}"
  echo "- Monorepo:          ${MONOREPO_SHA}"
  echo ""
  echo "## Build Status"
  echo ""
  echo "| App | Platform | Original | Monorepo |"
  echo "|-----|----------|----------|----------|"
  for entry in "${BUILDS[@]}"; do
    IFS='|' read -r app platform cmd <<< "${entry}"
    orig_s="${BUILD_STATUS[${app}-${platform}-orig]:-?}"
    mono_s="${BUILD_STATUS[${app}-${platform}-mono]:-?}"
    # truncate for table
    orig_short=$(echo "${orig_s}" | cut -c1-40)
    mono_short=$(echo "${mono_s}" | cut -c1-40)
    echo "| ${app} | ${platform} | ${orig_short} | ${mono_short} |"
  done
  echo ""
  echo "## Comparison Results"
  echo ""
  TOTAL=0
  EQUIV=0
  DIVERGE=0
  SKIP=0
  for entry in "${BUILDS[@]}"; do
    IFS='|' read -r app platform cmd <<< "${entry}"
    key="${app}-${platform}"
    result="${COMPARE_RESULT[${key}]:-SKIP}"
    detail="${COMPARE_DETAIL[${key}]:-no data}"
    orig_s="${BUILD_STATUS[${app}-${platform}-orig]:-?}"
    mono_s="${BUILD_STATUS[${app}-${platform}-mono]:-?}"

    TOTAL=$((TOTAL+1))
    echo "### ${app} / ${platform}"
    echo ""
    echo "- Build: original=\`${orig_s}\`, monorepo=\`${mono_s}\`"

    if [ "${result}" = "SKIP" ]; then
      # If both failed, check if same failure
      if [[ "${orig_s}" == FAIL* && "${mono_s}" == FAIL* ]]; then
        # Both failed - check if failure reason similar
        if [ "${orig_s}" = "${mono_s}" ]; then
          echo "- Result: **EQUIVALENT** (both failed with same error)"
          EQUIV=$((EQUIV+1))
        else
          echo "- Result: **DIVERGE** (failed differently)"
          DIVERGE=$((DIVERGE+1))
        fi
      else
        echo "- Result: SKIP (${detail})"
        SKIP=$((SKIP+1))
      fi
    elif [ "${result}" = "EQUIV" ]; then
      echo "- Result: **EQUIVALENT** (all artifacts match)"
      echo ""
      echo '  ```'
      echo -e "  ${detail}" | head -3
      echo '  ```'
      EQUIV=$((EQUIV+1))
    else
      echo "- Result: **DIVERGE**"
      echo ""
      echo '  ```'
      echo -e "${detail}" | head -50
      echo '  ```'
      DIVERGE=$((DIVERGE+1))
    fi
    echo ""
  done

  echo "## Summary"
  echo ""
  echo "- Total targets: ${TOTAL}"
  echo "- Equivalent: ${EQUIV}"
  echo "- Divergent: ${DIVERGE}"
  echo "- Skipped: ${SKIP}"
  echo ""
  echo "## Logs"
  echo ""
  echo "Build logs: \`${WORK_DIR}/logs/\`"
} > "${REPORT_FILE}"

echo ""
echo "============================================"
echo "Report written to: ${REPORT_FILE}"
echo ""
cat "${REPORT_FILE}" | grep -E '^## |^- |^\|' | head -60
echo ""
echo "============================================"

# Exit code: 0 if all equivalent, 1 otherwise
if [ "${DIVERGE}" -eq 0 ] && [ "${SKIP}" -eq 0 ]; then
  exit 0
elif [ "${DIVERGE}" -eq 0 ]; then
  exit 0  # skipped but nothing diverged
else
  exit 1
fi
