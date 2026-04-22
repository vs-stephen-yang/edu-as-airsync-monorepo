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

# Refs: branch name or full 40-char SHA
SENDER_REF="${SENDER_REF:-main}"
RECEIVER_REF="${RECEIVER_REF:-master}"
MONOREPO_BRANCH="main"

FVM="${FVM:-/c/Users/stephen/fvm/fvm.bat}"

WORK_DIR="${WORK_DIR:-$(mktemp -d)}"
mkdir -p "${WORK_DIR}"
REPORTS_DIR="${WORK_DIR}/reports"
mkdir -p "${REPORTS_DIR}"

# Helper: is the given ref a 40-char SHA?
is_sha() { [[ "$1" =~ ^[0-9a-f]{40}$ ]]; }

# Helper: clone repo at a ref (branch or SHA) into dst.
# For SHA mode, uses git init + fetch to avoid Windows case-collision issues.
clone_at_ref() {
  local url="$1" ref="$2" dst="$3"
  if is_sha "${ref}"; then
    git init "${dst}" 2>&1 | tail -2
    git -C "${dst}" remote add origin "${url}"
    git -C "${dst}" fetch origin "${ref}" 2>&1 | tail -5
    git -C "${dst}" checkout FETCH_HEAD 2>&1 | tail -3
  else
    git clone --single-branch --branch "${ref}" "${url}" "${dst}" 2>&1 | tail -5
  fi
}

# Known files that always differ due to build metadata (not source code changes).
# Exact relative paths; glob patterns marked with '*'.
KNOWN_METADATA=(
  # Android APK
  "assets/sentry-debug-meta.properties"
  "assets/dexopt/baseline.prof"
  "assets/dexopt/baseline.profm"
  "classes.dex"
  # Windows
  "*.pdb"
  # Web
  "flutter_bootstrap.js"
  "flutter_service_worker.js"
  "index.html"
)

# Known file-type patterns where content diffs (same size) are expected due to
# embedded timestamps / build IDs / UUIDs in the binary format itself.
# Returns "TIMESTAMP" for matches (PE/ELF timestamp non-determinism).
is_nondeterministic_binary() {
  local path="$1"
  case "${path}" in
    *.so|*.dll|*.exe|lib/*/libapp.so|data/app.so) return 0 ;;
  esac
  return 1
}

# Check if a relative path matches any KNOWN_METADATA entry (supports * glob).
is_known_metadata() {
  local path="$1" pattern
  for pattern in "${KNOWN_METADATA[@]}"; do
    if [[ "${path}" == ${pattern} ]]; then return 0; fi
    # also match basename against * patterns
    case "${pattern}" in
      \**)
        local bn="$(basename "${path}")"
        [[ "${bn}" == ${pattern} ]] && return 0
        ;;
    esac
  done
  return 1
}

# Classify a diff entry. Returns one of:
#   EXPECTED:timestamp     — same size, .so/.dll/.exe/.pdb (native binary timestamps)
#   EXPECTED:metadata      — file is in KNOWN_METADATA list
#   UNEXPECTED:size        — different file sizes
#   UNEXPECTED:content     — same size but not in known categories
classify_diff() {
  local rel="$1" orig_size="$2" mono_size="$3"
  if is_known_metadata "${rel}"; then
    echo "EXPECTED:metadata"
    return
  fi
  if [ "${orig_size}" = "${mono_size}" ]; then
    if is_nondeterministic_binary "${rel}"; then
      echo "EXPECTED:timestamp"
    else
      echo "UNEXPECTED:content"
    fi
  else
    echo "UNEXPECTED:size"
  fi
}

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

if [ -n "${SKIP_BUILDS:-}" ] && [ -d "${WORK_DIR}/original/sender" ] && [ -d "${WORK_DIR}/original/receiver" ]; then
  echo "  SKIP_BUILDS set — reusing existing clones in ${WORK_DIR}/original/"
  SENDER_ORIG_SHA=$(git -C "${WORK_DIR}/original/sender" rev-parse HEAD 2>/dev/null || echo "(unknown)")
  RECEIVER_ORIG_SHA=$(git -C "${WORK_DIR}/original/receiver" rev-parse HEAD 2>/dev/null || echo "(unknown)")
else
  # Original sender
  mkdir -p "${WORK_DIR}/original"
  echo "  Cloning original sender (${SENDER_REF})..."
  clone_at_ref "${SENDER_REPO}" "${SENDER_REF}" "${WORK_DIR}/original/sender"
  cd "${WORK_DIR}/original/sender" && git submodule update --init --recursive 2>&1 | tail -3
  git lfs pull 2>&1 | tail -3 || true
  SENDER_ORIG_SHA=$(git rev-parse HEAD)
  cd - >/dev/null

  # Original receiver
  echo "  Cloning original receiver (${RECEIVER_REF})..."
  clone_at_ref "${RECEIVER_REPO}" "${RECEIVER_REF}" "${WORK_DIR}/original/receiver"
  cd "${WORK_DIR}/original/receiver" && RECEIVER_ORIG_SHA=$(git rev-parse HEAD) && cd - >/dev/null
fi

# Monorepo: use LOCAL_MONOREPO if provided, else clone from remote
if [ -n "${LOCAL_MONOREPO:-}" ]; then
  echo "  Using local monorepo at: ${LOCAL_MONOREPO}"
  MONOREPO_DIR="${LOCAL_MONOREPO}"
else
  echo "  Cloning monorepo (${MONOREPO_BRANCH})..."
  git clone --single-branch --branch "${MONOREPO_BRANCH}" "${MONOREPO}" "${WORK_DIR}/monorepo" 2>&1 | tail -5
  MONOREPO_DIR="${WORK_DIR}/monorepo"
fi

if [ -n "${SKIP_BUILDS:-}" ]; then
  MONOREPO_SHA=$(git -C "${MONOREPO_DIR}" rev-parse HEAD 2>/dev/null || echo "(unknown)")
else
  cd "${MONOREPO_DIR}" && git submodule update --init --recursive 2>&1 | tail -3
  git lfs pull 2>&1 | tail -3 || true
  MONOREPO_SHA=$(git rev-parse HEAD)
  cd - >/dev/null
fi

# pub get
echo ""
echo ">>> Phase 1b: Running fvm flutter pub get..."

if [ -n "${SKIP_BUILDS:-}" ]; then
  echo "  SKIP_BUILDS set — skipping pub get."
else
  for d in "${WORK_DIR}/original/sender" "${WORK_DIR}/original/receiver" "${MONOREPO_DIR}/apps/sender" "${MONOREPO_DIR}/apps/receiver"; do
    echo "  pub get in: ${d}"
    (cd "${d}" && "${FVM}" flutter pub get 2>&1 | tail -3) || echo "    pub get failed (continuing)"
  done
fi

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

  if [ -n "${SKIP_BUILDS:-}" ]; then
    # Assume artifacts already exist; mark both sides OK if build dirs are present
    orig_key="${app}-${platform}-orig"
    mono_key="${app}-${platform}-mono"
    BUILD_STATUS["${orig_key}"]="OK"
    BUILD_STATUS["${mono_key}"]="OK"
    BUILD_LOG["${orig_key}"]="${WORK_DIR}/logs/${orig_key}.log"
    BUILD_LOG["${mono_key}"]="${WORK_DIR}/logs/${mono_key}.log"
    echo "  SKIP_BUILDS set — assuming ${app}-${platform} artifacts exist."
    continue
  fi

  # Original side
  orig_dir="${WORK_DIR}/original/${app}"
  run_build "${app}" "${platform}" "${cmd}" "orig" "${orig_dir}"

  # Monorepo side
  mono_dir="${MONOREPO_DIR}/apps/${app}"
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
  local mono_dir="${MONOREPO_DIR}/apps/${app}/build/web"
  local key="${app}-web"

  if [ ! -d "${orig_dir}" ] || [ ! -d "${mono_dir}" ]; then
    COMPARE_RESULT["${key}"]="SKIP"
    COMPARE_DETAIL["${key}"]="Build dir missing (orig=$([ -d "${orig_dir}" ] && echo Y || echo N), mono=$([ -d "${mono_dir}" ] && echo Y || echo N))"
    return
  fi

  local detail=""
  local match=0 expected=0 unexpected=0

  # Compare each file in orig
  while IFS= read -r f; do
    rel="${f#${orig_dir}/}"
    mono_file="${mono_dir}/${rel}"
    if [ ! -f "${mono_file}" ]; then
      unexpected=$((unexpected+1))
      detail+="  - [UNEXPECTED:missing] ${rel}: MISSING in monorepo\n"
      continue
    fi
    orig_sha=$(sha256sum "${f}" | awk '{print $1}')
    mono_sha=$(sha256sum "${mono_file}" | awk '{print $1}')
    if [ "${orig_sha}" = "${mono_sha}" ]; then
      match=$((match+1))
    else
      orig_size=$(stat -c%s "${f}")
      mono_size=$(stat -c%s "${mono_file}")
      category=$(classify_diff "${rel}" "${orig_size}" "${mono_size}")
      if [[ "${category}" == EXPECTED:* ]]; then
        expected=$((expected+1))
      else
        unexpected=$((unexpected+1))
      fi
      detail+="  - [${category}] ${rel}: orig=${orig_size}B vs mono=${mono_size}B (sha ${orig_sha:0:8}..${mono_sha:0:8})\n"
    fi
  done < <(find "${orig_dir}" -type f)

  # Also check for files in mono but not orig
  while IFS= read -r f; do
    rel="${f#${mono_dir}/}"
    if [ ! -f "${orig_dir}/${rel}" ]; then
      unexpected=$((unexpected+1))
      detail+="  - [UNEXPECTED:extra] ${rel}: EXTRA in monorepo\n"
    fi
  done < <(find "${mono_dir}" -type f)

  # Result: EQUIV if no unexpected diffs, DIVERGE only when unexpected
  if [ "${unexpected}" -eq 0 ]; then
    COMPARE_RESULT["${key}"]="EQUIV"
  else
    COMPARE_RESULT["${key}"]="DIVERGE"
  fi
  COMPARE_DETAIL["${key}"]="Match: ${match}, expected-diff: ${expected}, unexpected-diff: ${unexpected}\n${detail}"
}

compare_apk() {
  local app="$1"
  # Find the built APK on each side
  local orig_apk=$(find "${WORK_DIR}/original/${app}/build/app/outputs/flutter-apk/" -name "app-*.apk" 2>/dev/null | head -1)
  local mono_apk=$(find "${MONOREPO_DIR}/apps/${app}/build/app/outputs/flutter-apk/" -name "app-*.apk" 2>/dev/null | head -1)
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
  local match=0 expected=0 unexpected=0

  while IFS= read -r f; do
    rel="${f#${orig_ext}/}"
    mono_file="${mono_ext}/${rel}"
    if [ ! -f "${mono_file}" ]; then
      unexpected=$((unexpected+1))
      detail+="  - [UNEXPECTED:missing] ${rel}: MISSING in monorepo\n"
      continue
    fi
    orig_sha=$(sha256sum "${f}" | awk '{print $1}')
    mono_sha=$(sha256sum "${mono_file}" | awk '{print $1}')
    if [ "${orig_sha}" = "${mono_sha}" ]; then
      match=$((match+1))
    else
      orig_size=$(stat -c%s "${f}")
      mono_size=$(stat -c%s "${mono_file}")
      category=$(classify_diff "${rel}" "${orig_size}" "${mono_size}")
      if [[ "${category}" == EXPECTED:* ]]; then
        expected=$((expected+1))
      else
        unexpected=$((unexpected+1))
      fi
      detail+="  - [${category}] ${rel}: orig=${orig_size}B vs mono=${mono_size}B\n"
    fi
  done < <(find "${orig_ext}" -type f)

  while IFS= read -r f; do
    rel="${f#${mono_ext}/}"
    if [ ! -f "${orig_ext}/${rel}" ]; then
      unexpected=$((unexpected+1))
      detail+="  - [UNEXPECTED:extra] ${rel}: EXTRA in monorepo\n"
    fi
  done < <(find "${mono_ext}" -type f)

  if [ "${unexpected}" -eq 0 ]; then
    COMPARE_RESULT["${key}"]="EQUIV"
  else
    COMPARE_RESULT["${key}"]="DIVERGE"
  fi
  COMPARE_DETAIL["${key}"]="APK entries match: ${match}, expected-diff: ${expected}, unexpected-diff: ${unexpected}\n${detail}"
}

compare_windows() {
  local app="$1"
  local orig_dir="${WORK_DIR}/original/${app}/build/windows/x64/runner/Release"
  local mono_dir="${MONOREPO_DIR}/apps/${app}/build/windows/x64/runner/Release"
  local key="${app}-windows"

  if [ ! -d "${orig_dir}" ] || [ ! -d "${mono_dir}" ]; then
    COMPARE_RESULT["${key}"]="SKIP"
    COMPARE_DETAIL["${key}"]="Build dir missing (orig=$([ -d "${orig_dir}" ] && echo Y || echo N), mono=$([ -d "${mono_dir}" ] && echo Y || echo N))"
    return
  fi

  local detail=""
  local match=0 expected=0 unexpected=0

  while IFS= read -r f; do
    rel="${f#${orig_dir}/}"
    mono_file="${mono_dir}/${rel}"
    if [ ! -f "${mono_file}" ]; then
      unexpected=$((unexpected+1))
      detail+="  - [UNEXPECTED:missing] ${rel}: MISSING in monorepo\n"
      continue
    fi
    orig_sha=$(sha256sum "${f}" | awk '{print $1}')
    mono_sha=$(sha256sum "${mono_file}" | awk '{print $1}')
    if [ "${orig_sha}" = "${mono_sha}" ]; then
      match=$((match+1))
    else
      orig_size=$(stat -c%s "${f}")
      mono_size=$(stat -c%s "${mono_file}")
      category=$(classify_diff "${rel}" "${orig_size}" "${mono_size}")
      if [[ "${category}" == EXPECTED:* ]]; then
        expected=$((expected+1))
      else
        unexpected=$((unexpected+1))
      fi
      detail+="  - [${category}] ${rel}: orig=${orig_size}B vs mono=${mono_size}B\n"
    fi
  done < <(find "${orig_dir}" -type f)

  if [ "${unexpected}" -eq 0 ]; then
    COMPARE_RESULT["${key}"]="EQUIV"
  else
    COMPARE_RESULT["${key}"]="DIVERGE"
  fi
  COMPARE_DETAIL["${key}"]="Files match: ${match}, expected-diff: ${expected}, unexpected-diff: ${unexpected}\n${detail}"
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
