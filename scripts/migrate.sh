#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# AirSync Monorepo Migration Script
#
# Migrates sender + receiver apps and 7 dependency repos into a single
# monorepo using git filter-repo, then configures melos 6.3.2.
#
# Prerequisites:
#   - git >= 2.36
#   - git-filter-repo (pip install git-filter-repo)
#   - GitHub CLI (gh) authenticated
#
# Usage:
#   bash scripts/migrate.sh
###############################################################################

# ─── Configuration ───────────────────────────────────────────────────────────

GH_ORG="Viewsonic-EDU"
MONOREPO_REMOTE="https://github.com/vs-stephen-yang/edu-as-airsync-monorepo.git"

SENDER_REPO="https://github.com/${GH_ORG}/edu-as-airsync-sender.git"
SENDER_BRANCH="main"

RECEIVER_REPO="https://github.com/${GH_ORG}/edu-as-airsync-receiver.git"
RECEIVER_BRANCH="master"

# Dependencies: "repo_name|ref|target_dir"
DEPS=(
  "edu-as-display-channel|release-3.9.4|packages/display_channel"
  "edu-as-ion-sdk-flutter|release-3.9.3|packages/ion_sdk_flutter"
  "edu-as-golang-server|release-3.9.0|packages/flutter_golang_server"
  "edu-as-multicast-plugin|release-3.8.5|packages/flutter_multicast_plugin"
  "edu-as-input-injection|release-0.15.0|packages/flutter_input_injection"
  "edu-as-virtual-display|release-1.0.6|packages/flutter_virtual_display"
  "edu-as-mirror|release-3.9.4|packages/flutter_mirror"
)

WORK_DIR="$(mktemp -d)"
MONOREPO_DIR="${WORK_DIR}/monorepo"

echo "============================================"
echo "AirSync Monorepo Migration"
echo "Working directory: ${WORK_DIR}"
echo "============================================"

# ─── Phase 0: Prerequisites ─────────────────────────────────────────────────

echo ""
echo ">>> Phase 0: Checking prerequisites..."

command -v git >/dev/null 2>&1 || { echo "ERROR: git not found"; exit 1; }
git filter-repo --version >/dev/null 2>&1 || { echo "ERROR: git-filter-repo not found. Install: pip install git-filter-repo"; exit 1; }

echo "  git: $(git --version)"
echo "  git-filter-repo: $(git filter-repo --version)"

# ─── Phase 1: Clone & rewrite SENDER ────────────────────────────────────────

echo ""
echo ">>> Phase 1: Cloning and rewriting sender..."

git clone --single-branch --branch "${SENDER_BRANCH}" "${SENDER_REPO}" "${WORK_DIR}/sender"
cd "${WORK_DIR}/sender"

echo "  Pass 1: Moving all files under apps/sender/..."
git filter-repo --to-subdirectory-filter apps/sender/ \
  --tag-rename ':sender-' \
  --force

echo "  Pass 2: Extracting CI files to ci/sender/..."
git filter-repo \
  --path-rename 'apps/sender/azure-pipelines.yml:ci/sender/azure-pipelines.yml' \
  --path-rename 'apps/sender/azure-pipelines-android.yml:ci/sender/azure-pipelines-android.yml' \
  --path-rename 'apps/sender/azure-pipelines-ios.yml:ci/sender/azure-pipelines-ios.yml' \
  --path-rename 'apps/sender/azure-pipelines-macos.yml:ci/sender/azure-pipelines-macos.yml' \
  --path-rename 'apps/sender/azure-pipelines-web.yml:ci/sender/azure-pipelines-web.yml' \
  --path-rename 'apps/sender/azure-pipelines-windows.yml:ci/sender/azure-pipelines-windows.yml' \
  --path-rename 'apps/sender/azure-pipelines-release-note.yml:ci/sender/azure-pipelines-release-note.yml' \
  --path-rename 'apps/sender/ci/upload-to-dropbox.yml:ci/sender/upload-to-dropbox.yml' \
  --path-rename 'apps/sender/ci/scripts/:ci/sender/scripts/' \
  --force

echo "  Sender rewrite complete."

# ─── Phase 2: Clone & rewrite RECEIVER ──────────────────────────────────────

echo ""
echo ">>> Phase 2: Cloning and rewriting receiver..."

git clone --single-branch --branch "${RECEIVER_BRANCH}" "${RECEIVER_REPO}" "${WORK_DIR}/receiver"
cd "${WORK_DIR}/receiver"

echo "  Pass 1: Moving all files under apps/receiver/..."
git filter-repo --to-subdirectory-filter apps/receiver/ \
  --tag-rename ':receiver-' \
  --force

echo "  Pass 2: Extracting CI files to ci/receiver/..."
git filter-repo \
  --path-rename 'apps/receiver/ci/azure-pipelines.yml:ci/receiver/azure-pipelines.yml' \
  --path-rename 'apps/receiver/ci/azure-pipelines-build.yml:ci/receiver/azure-pipelines-build.yml' \
  --path-rename 'apps/receiver/ci/azure-pipelines-upload-archive.yml:ci/receiver/azure-pipelines-upload-archive.yml' \
  --path-rename 'apps/receiver/ci/cleanup-agent.yml:ci/receiver/cleanup-agent.yml' \
  --path-rename 'apps/receiver/ci/upload-to-dropbox.yml:ci/receiver/upload-to-dropbox.yml' \
  --path-rename 'apps/receiver/ci/scripts/:ci/receiver/scripts/' \
  --force

echo "  Receiver rewrite complete."

# ─── Phase 3: Clone & rewrite DEPENDENCIES ──────────────────────────────────

echo ""
echo ">>> Phase 3: Cloning and rewriting ${#DEPS[@]} dependencies..."

for entry in "${DEPS[@]}"; do
  IFS='|' read -r repo_name ref target_dir <<< "${entry}"
  echo ""
  echo "  Processing: ${repo_name} @ ${ref} -> ${target_dir}/"

  git clone --single-branch --branch "${ref}" "https://github.com/${GH_ORG}/${repo_name}.git" "${WORK_DIR}/${repo_name}"
  cd "${WORK_DIR}/${repo_name}"

  git filter-repo \
    --to-subdirectory-filter "${target_dir}/" \
    --tag-rename ":${repo_name}-" \
    --force

  # Create a named branch from detached HEAD (refs may be tags, not branches)
  git checkout -b filtered 2>/dev/null || true

  echo "  Done: ${repo_name}"
done

echo ""
echo "  All dependencies rewritten."

# ─── Phase 4: Create monorepo & merge all ────────────────────────────────────

echo ""
echo ">>> Phase 4: Creating monorepo and merging..."

mkdir -p "${MONOREPO_DIR}"
cd "${MONOREPO_DIR}"
git init
git checkout -b main

# Create an initial empty commit so we have a base
git commit --allow-empty -m "chore: initialize monorepo"

# Merge sender
echo "  Merging sender..."
git remote add sender "${WORK_DIR}/sender"
git fetch sender
git merge sender/${SENDER_BRANCH} --allow-unrelated-histories \
  -m "feat: import sender (display_cast_flutter) with full history"
git remote remove sender

# Merge receiver
echo "  Merging receiver..."
git remote add receiver "${WORK_DIR}/receiver"
git fetch receiver
git merge receiver/${RECEIVER_BRANCH} --allow-unrelated-histories \
  -m "feat: import receiver (display_flutter) with full history"
git remote remove receiver

# Merge each dependency
for entry in "${DEPS[@]}"; do
  IFS='|' read -r repo_name ref target_dir <<< "${entry}"
  echo "  Merging ${repo_name}..."

  git remote add "${repo_name}" "${WORK_DIR}/${repo_name}"
  git fetch "${repo_name}"

  git merge "${repo_name}/filtered" --allow-unrelated-histories \
    -m "feat: import ${repo_name} into ${target_dir}/"
  git remote remove "${repo_name}"
done

echo "  All repos merged."

# ─── Phase 5: Post-merge configuration ──────────────────────────────────────

echo ""
echo ">>> Phase 5: Generating monorepo configuration files..."

cd "${MONOREPO_DIR}"

# --- melos.yaml ---
cat > melos.yaml << 'EOF'
name: airsync_workspace

packages:
  - apps/*
  - apps/sender/packages/*
  - packages/*

sdkPath: .fvm/flutter_sdk

command:
  bootstrap:
    runPubGetInParallel: true

scripts:
  analyze:
    description: Analyze all packages
    run: melos exec -- dart analyze . --no-fatal-infos

  test:
    description: Run all tests
    exec: flutter test -j 4 --no-pub --coverage --branch-coverage
    packageFilters:
      dirExists: test

  test:sender:
    description: Run sender tests
    exec: flutter test -j 4 --no-pub --coverage --branch-coverage
    packageFilters:
      scope: display_cast_flutter

  test:receiver:
    description: Run receiver tests
    exec: flutter test -j 4 --no-pub --coverage --branch-coverage
    packageFilters:
      scope: display_flutter

  format:
    description: Format all Dart files
    run: dart format .

  clean:
    description: Clean all packages
    run: melos exec -- flutter clean
EOF

# --- Root pubspec.yaml ---
cat > pubspec.yaml << 'EOF'
name: airsync_workspace
publish_to: none

environment:
  sdk: ^3.6.2

dev_dependencies:
  melos: ^6.3.2
EOF

# --- .fvmrc ---
cat > .fvmrc << 'EOF'
{
  "flutter": "3.27.4"
}
EOF

# --- Root .gitignore ---
cat > .gitignore << 'EOF'
# Miscellaneous
*.class
*.log
*.pyc
*.swp
.DS_Store
.atom/
.build/
.buildlog/
.history
.svn/
.swiftpm/
migrate_working_dir/

# IntelliJ related
*.ipr
*.iws
**/.idea/*
!.idea/runConfigurations/
!.idea/modules.xml

# Flutter/Dart/Pub related
**/doc/api/
**/ios/Flutter/.last_build_id
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
**/build/
lib/generated_plugin_registrant.dart

# Symbolication related
app.*.symbols

# Obfuscation related
app.*.map.json

# Android Studio will place build artifacts here
**/android/app/debug
**/android/app/profile
**/android/app/release

# FVM Version Cache
.fvm/

# Melos
.melos/
pubspec_overrides.yaml
EOF

# --- Root analysis_options.yaml ---
cat > analysis_options.yaml << 'EOF'
include: package:flutter_lints/flutter.yaml

analyzer:
  errors:
    unawaited_futures: warning

linter:
  rules:
    - unawaited_futures
EOF

# --- lefthook.yml ---
cat > lefthook.yml << 'EOF'
pre-commit:
  parallel: true
  commands:
    format:
      run: |
        files=$(git diff --cached --name-only --diff-filter=ACM \
        | grep '\.dart$' \
        | grep -v '/generated/')

        # If any files remain, format them
        if [ -n "$files" ]; then
          dart format $files
          git add $files
        fi
EOF

# --- Fix .gitmodules ---
cat > .gitmodules << 'EOF'
[submodule "apps/sender/windows/prebuilt/virtual-audio-cable-binaries"]
	path = apps/sender/windows/prebuilt/virtual-audio-cable-binaries
	url = https://github.com/Viewsonic-EDU/edu-as-virtual-audio-cable-binaries.git
EOF

# --- Remove duplicate files from app dirs ---
echo "  Removing duplicate root-level files from app dirs..."
git rm -f apps/sender/lefthook.yml 2>/dev/null || true
git rm -f apps/sender/.fvmrc 2>/dev/null || true
git rm -f apps/sender/.gitignore 2>/dev/null || true
git rm -f apps/receiver/lefthook.yml 2>/dev/null || true
git rm -f apps/receiver/.fvmrc 2>/dev/null || true
git rm -f apps/receiver/.gitignore 2>/dev/null || true

# Remove sender's CI files that were already extracted (if remnants exist)
rm -rf apps/sender/ci/ 2>/dev/null || true
git rm -rf apps/sender/ci/ 2>/dev/null || true

# Remove receiver's CI dir (already extracted)
rm -rf apps/receiver/ci/ 2>/dev/null || true
git rm -rf apps/receiver/ci/ 2>/dev/null || true

# Move receiver's .azuredevops to root level
if [ -d "apps/receiver/.azuredevops" ]; then
  mkdir -p .azuredevops
  cp -r apps/receiver/.azuredevops/* .azuredevops/
  git rm -rf apps/receiver/.azuredevops/
  git add .azuredevops/
fi

# --- Patch sender pubspec.yaml: convert git deps to path deps ---
echo "  Patching sender pubspec.yaml..."

SENDER_PUBSPEC="apps/sender/pubspec.yaml"
if [ -f "${SENDER_PUBSPEC}" ]; then
  # display_channel: git -> path
  python -c "
import re, sys
with open('${SENDER_PUBSPEC}', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace display_channel git dep
content = re.sub(
    r'display_channel:\s*\n\s*git:\s*\n\s*url:.*edu-as-display-channel.*\n\s*ref:.*\n',
    'display_channel:\n    path: ../../packages/display_channel\n',
    content
)

# Replace ion_sdk_flutter git dep
content = re.sub(
    r'ion_sdk_flutter:\s*\n\s*git:\s*\n\s*url:.*edu-as-ion-sdk-flutter.*\n\s*ref:.*\n',
    'ion_sdk_flutter:\n    path: ../../packages/ion_sdk_flutter\n',
    content
)

# Replace flutter_input_injection git dep
content = re.sub(
    r'flutter_input_injection:\s*\n\s*git:\s*\n\s*url:.*edu-as-input-injection.*\n\s*ref:.*\n',
    'flutter_input_injection:\n    path: ../../packages/flutter_input_injection\n',
    content
)

# Replace flutter_virtual_display git dep
content = re.sub(
    r'flutter_virtual_display:\s*\n\s*git:\s*\n\s*url:.*edu-as-virtual-display.*\n\s*ref:.*\n',
    'flutter_virtual_display:\n    path: ../../packages/flutter_virtual_display\n',
    content
)

# Replace flutter_multicast_plugin git dep
content = re.sub(
    r'flutter_multicast_plugin:\s*\n\s*git:\s*\n\s*url:.*edu-as-multicast-plugin.*\n\s*ref:.*\n',
    'flutter_multicast_plugin:\n    path: ../../packages/flutter_multicast_plugin\n',
    content
)

# Replace flutter_golang_server git override
content = re.sub(
    r'(flutter_golang_server:\s*\n)\s*git:\s*\n\s*url:.*edu-as-golang-server.*\n\s*ref:.*\n',
    r'\1    path: ../../packages/flutter_golang_server\n',
    content
)

with open('${SENDER_PUBSPEC}', 'w', encoding='utf-8') as f:
    f.write(content)

print('  Sender pubspec patched.')
"
fi

# --- Patch receiver pubspec.yaml: convert git deps to path deps ---
echo "  Patching receiver pubspec.yaml..."

RECEIVER_PUBSPEC="apps/receiver/pubspec.yaml"
if [ -f "${RECEIVER_PUBSPEC}" ]; then
  python -c "
import re, sys
with open('${RECEIVER_PUBSPEC}', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace display_channel git dep
content = re.sub(
    r'display_channel:\s*\n\s*git:\s*\n\s*url:.*edu-as-display-channel.*\n\s*ref:.*\n',
    'display_channel:\n    path: ../../packages/display_channel\n',
    content
)

# Replace ion_sdk_flutter git dep
content = re.sub(
    r'ion_sdk_flutter:\s*\n\s*git:\s*\n\s*url:.*edu-as-ion-sdk-flutter.*\n\s*ref:.*\n',
    'ion_sdk_flutter:\n    path: ../../packages/ion_sdk_flutter\n',
    content
)

# Replace flutter_input_injection git dep
content = re.sub(
    r'flutter_input_injection:\s*\n\s*git:\s*\n\s*url:.*edu-as-input-injection.*\n\s*ref:.*\n',
    'flutter_input_injection:\n    path: ../../packages/flutter_input_injection\n',
    content
)

# Replace flutter_mirror git dep
content = re.sub(
    r'flutter_mirror:\s*\n\s*git:\s*\n\s*url:.*edu-as-mirror.*\n\s*ref:.*\n',
    'flutter_mirror:\n    path: ../../packages/flutter_mirror\n',
    content
)

# Replace flutter_multicast_plugin git dep
content = re.sub(
    r'flutter_multicast_plugin:\s*\n\s*git:\s*\n\s*url:.*edu-as-multicast-plugin.*\n\s*ref:.*\n',
    'flutter_multicast_plugin:\n    path: ../../packages/flutter_multicast_plugin\n',
    content
)

# Replace flutter_golang_server: any to path dep
content = re.sub(
    r'flutter_golang_server:\s*any\n',
    'flutter_golang_server:\n    path: ../../packages/flutter_golang_server\n',
    content
)

# Replace flutter_golang_server git override
content = re.sub(
    r'(flutter_golang_server:\s*\n)\s*git:\s*\n\s*url:.*edu-as-golang-server.*\n\s*ref:.*\n',
    r'\1    path: ../../packages/flutter_golang_server\n',
    content
)

with open('${RECEIVER_PUBSPEC}', 'w', encoding='utf-8') as f:
    f.write(content)

print('  Receiver pubspec patched.')
"
fi

# --- Generate PR pipeline ---
echo "  Generating PR pipeline..."
mkdir -p ci

cat > ci/azure-pipelines-pr.yml << 'PIPELINE_EOF'
trigger: none

pr:
  branches:
    include:
      - main

variables:
  - group: "github-secrets"
  - name: Flutter.Bin
    value: fvm flutter

stages:
  # ── Stage 1: Detect affected packages using melos ──
  - stage: Detect
    jobs:
      - job: DetectChanges
        pool:
          name: "AirSync macOS Pool"
        steps:
          - checkout: self
            fetchDepth: 0
            persistCredentials: "true"

          - script: |
              git config --global url."https://$(GITHUB_PAT)@github.com/".insteadOf "https://github.com/"
            displayName: Configure GitHub credentials

          - script: dart pub global activate melos 6.3.2
            displayName: Install melos

          - script: melos bootstrap
            displayName: Bootstrap workspace

          - bash: |
              CHANGED_PKGS=$(melos list --since=origin/main --parsable 2>/dev/null || echo "")

              SENDER_AFFECTED=false
              RECEIVER_AFFECTED=false

              if echo "$CHANGED_PKGS" | grep -q "display_cast_flutter"; then
                SENDER_AFFECTED=true
              fi

              if echo "$CHANGED_PKGS" | grep -q "display_flutter"; then
                RECEIVER_AFFECTED=true
              fi

              echo "Changed packages:"
              echo "$CHANGED_PKGS"
              echo ""
              echo "Sender affected: $SENDER_AFFECTED"
              echo "Receiver affected: $RECEIVER_AFFECTED"

              echo "##vso[task.setvariable variable=senderAffected;isOutput=true]$SENDER_AFFECTED"
              echo "##vso[task.setvariable variable=receiverAffected;isOutput=true]$RECEIVER_AFFECTED"
            name: changes
            displayName: Detect affected packages via melos

  # ── Stage 2: Quality check — lint + test on ALL affected packages ──
  - stage: QualityCheck
    dependsOn: Detect
    jobs:
      - job: LintAndTest
        pool:
          name: "AirSync macOS Pool"
        steps:
          - checkout: self
            fetchDepth: 0
            persistCredentials: "true"
            submodules: "recursive"

          - script: |
              git config --global url."https://$(GITHUB_PAT)@github.com/".insteadOf "https://github.com/"
            displayName: Configure GitHub credentials

          - script: dart pub global activate melos 6.3.2
            displayName: Install melos

          - script: melos bootstrap
            displayName: Bootstrap workspace

          - script: melos exec --since=origin/main -- dart analyze . --no-fatal-infos
            displayName: Analyze affected packages

          - script: melos exec --since=origin/main --dir-exists=test -- $(Flutter.Bin) test -j 4 --no-pub --coverage --branch-coverage
            displayName: Test affected packages

  # ── Stage 3: Build affected apps ──
  - stage: Build
    dependsOn:
      - Detect
      - QualityCheck
    variables:
      senderAffected: $[stageDependencies.Detect.DetectChanges.outputs['changes.senderAffected']]
      receiverAffected: $[stageDependencies.Detect.DetectChanges.outputs['changes.receiverAffected']]
    jobs:
      # Sender: build all platforms
      - job: BuildSender
        condition: eq(variables.senderAffected, 'true')
        strategy:
          matrix:
            mac:
              poolName: "AirSync macOS Pool"
              buildCommand: "macos"
              extraBuildOptions: "--flavor Store"
            windows:
              poolName: "AirSync Windows Pool"
              buildCommand: "windows"
              extraBuildOptions: ""
            web:
              poolName: "AirSync macOS Pool"
              buildCommand: "web"
              extraBuildOptions: ""
            android:
              poolName: "AirSync macOS Pool"
              buildCommand: "apk"
              extraBuildOptions: ""
            ios:
              poolName: "AirSync macOS Pool"
              buildCommand: "ipa"
              extraBuildOptions: ""
        pool:
          name: $(poolName)
        steps:
          - checkout: self
            persistCredentials: "true"
            lfs: "true"
            submodules: "recursive"

          - script: |
              git config --global url."https://$(GITHUB_PAT)@github.com/".insteadOf "https://github.com/"
            displayName: Configure GitHub credentials

          - script: $(Flutter.Bin) pub get
            displayName: Download packages
            workingDirectory: "$(Build.SourcesDirectory)/apps/sender"

          - bash: |
              POSSIBLE_PATHS=(
                "/Users/agent/Library/Developer/GStreamer/iPhone.sdk/GStreamer.framework"
                "/Library/Frameworks/GStreamer.framework"
                "$HOME/Library/Developer/GStreamer/iPhone.sdk/GStreamer.framework"
              )
              for path in "${POSSIBLE_PATHS[@]}"; do
                if [ -d "$path" ]; then
                  echo "Found GStreamer at $path"
                  echo "##vso[task.setvariable variable=GSTREAMER_SDK_IOS]$path"
                  exit 0
                fi
              done
              echo "##vso[task.logissue type=warning]GStreamer SDK not found."
            displayName: Set GSTREAMER_SDK_IOS
            condition: eq(variables['buildCommand'], 'ipa')

          - script: $(Flutter.Bin) build $(buildCommand) --no-pub $(extraBuildOptions) -t ./lib/main_production.dart
            displayName: Build $(buildCommand)
            workingDirectory: "$(Build.SourcesDirectory)/apps/sender"
            env:
              CMAKE_BUILD_PARALLEL_LEVEL: 8

      # Receiver: build APK
      - job: BuildReceiver
        condition: eq(variables.receiverAffected, 'true')
        pool:
          name: "AirSync macOS Pool"
        steps:
          - checkout: self
            persistCredentials: "true"
            lfs: "true"

          - task: PowerShell@2
            displayName: Configure Azure DevOps credentials
            inputs:
              targetType: "inline"
              script: |
                $header = "AUTHORIZATION: bearer $(System.AccessToken)"
                git config --global http.https://viewsonic-ssi.visualstudio.com/Display%20App/.extraheader $header

          - script: |
              git config --global url."https://$(GITHUB_PAT)@github.com/".insteadOf "https://github.com/"
            displayName: Configure GitHub credentials

          - task: MavenAuthenticate@0
            displayName: Provides maven credentials for Azure Artifacts
            inputs:
              artifactsFeeds: "myViewBoard_Artifacts"

          - task: PowerShell@2
            displayName: Extract Azure Artifacts credentials
            inputs:
              targetType: "inline"
              script: |
                [xml]$doc = Get-Content -path ~/.m2/settings.xml
                $username=$doc.settings.servers.server.username
                $password=$doc.settings.servers.server.password
                Write-Host "##vso[task.setvariable variable=ORG_GRADLE_PROJECT_AZURE_ARTIFACTS_USERNAME]$username"
                Write-Host "##vso[task.setvariable variable=ORG_GRADLE_PROJECT_AZURE_ARTIFACTS_PASSWORD]$password"

          - script: $(Flutter.Bin) pub get
            displayName: Download packages
            workingDirectory: "$(Build.SourcesDirectory)/apps/receiver"

          - script: $(Flutter.Bin) build apk --flavor openproduction -t lib/main_production.dart
            displayName: Build receiver APK
            workingDirectory: "$(Build.SourcesDirectory)/apps/receiver"
            env:
              ORG_GRADLE_PROJECT_AZURE_ARTIFACTS_USERNAME: $(ORG_GRADLE_PROJECT_AZURE_ARTIFACTS_USERNAME)
              ORG_GRADLE_PROJECT_AZURE_ARTIFACTS_PASSWORD: $(ORG_GRADLE_PROJECT_AZURE_ARTIFACTS_PASSWORD)
PIPELINE_EOF

# --- Generate consolidated GitHub Actions workflows ---
echo "  Generating GitHub Actions workflows..."
mkdir -p .github/workflows

cat > .github/workflows/workflow-scan-full.yml << 'GHA_EOF'
name: 'Security Scan - Full'

on:
  push:
    branches:
      - main
  schedule:
    - cron: '0 10 * * *'
  workflow_dispatch:

jobs:
  scan-sender:
    uses: Viewsonic-EDU/edu-security-lab-va/.github/workflows/workflow-scan-full.yml@main
    with:
      product_name: "edu/airsync/edu-as-airsync-sender"

  scan-receiver:
    uses: Viewsonic-EDU/edu-security-lab-va/.github/workflows/workflow-scan-full.yml@main
    with:
      product_name: "edu/airsync/edu-as-airsync-receiver"
GHA_EOF

cat > .github/workflows/workflow-scan-pr.yml << 'GHA_EOF'
name: 'Security Scan - PR'

on:
  pull_request:
    branches:
      - '**'

jobs:
  scan:
    uses: Viewsonic-EDU/edu-security-lab-va/.github/workflows/workflow-scan-pr.yml@main
GHA_EOF

# --- Commit all configuration ---
echo "  Committing monorepo configuration..."
git add -A
git commit -m "chore: configure monorepo with melos 6.3.2

- Add melos.yaml workspace config
- Add root pubspec.yaml, .fvmrc, .gitignore, analysis_options.yaml, lefthook.yml
- Fix .gitmodules for sender submodule path
- Convert migrated git deps to path deps in sender/receiver pubspec.yaml
- Add PR pipeline with melos-based change detection (ci/azure-pipelines-pr.yml)
- Add consolidated GitHub Actions security scan workflows
- Remove duplicate config files from app directories"

# ─── Phase 6: Push ───────────────────────────────────────────────────────────

echo ""
echo ">>> Phase 6: Fetching LFS objects and pushing to remote..."

# Fetch LFS objects from original sender repo (has LFS-tracked DLLs)
echo "  Fetching LFS objects from sender..."
git remote add sender-lfs "${SENDER_REPO}"
git lfs fetch sender-lfs --all 2>/dev/null || true
git remote remove sender-lfs

git remote add origin "${MONOREPO_REMOTE}"
git push -u origin main --force

echo ""
echo "============================================"
echo "Migration complete!"
echo ""
echo "Monorepo: ${MONOREPO_REMOTE}"
echo "Local copy: ${MONOREPO_DIR}"
echo ""
echo "Next steps:"
echo "  1. cd ${MONOREPO_DIR}"
echo "  2. melos bootstrap"
echo "  3. melos run test:sender"
echo "  4. melos run test:receiver"
echo "  5. Verify builds:"
echo "     cd apps/sender && fvm flutter build apk -t lib/main_dev.dart"
echo "     cd apps/receiver && fvm flutter build apk --flavor opendev -t lib/main_dev.dart"
echo "============================================"
