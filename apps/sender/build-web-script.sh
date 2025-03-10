#!/bin/bash

# Script to build Flutter web app for specific environment and generate custom service worker
# This version removes leading slashes from resource paths EXCEPT for the root path "/"

# Default configuration
BUILD_DIR="build/web"
TEMPLATE_FILE="web/service-worker-template.js"
OUTPUT_FILE="${BUILD_DIR}/service-worker.js"
ENVIRONMENT="dev"  # Default environment

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --env=*)
      ENVIRONMENT="${1#*=}"
      shift
      ;;
    --env)
      ENVIRONMENT="$2"
      shift 2
      ;;
    *)
      echo "Unknown parameter: $1"
      exit 1
      ;;
  esac
done

# Set environment-specific build commands
case $ENVIRONMENT in
  dev)
    BUILD_CMD="flutter build web -t ./lib/main_dev.dart --source-maps --pwa-strategy=none"
    ;;
  stage)
    BUILD_CMD="flutter build web --release -t ./lib/main_stage.dart --source-maps --pwa-strategy=none"
    ;;
  prod|production)
    BUILD_CMD="flutter build web --release -t ./lib/main_production.dart --source-maps --pwa-strategy=none"
    ENVIRONMENT="production"  # Normalize the name
    ;;
  *)
    echo "❌ Unknown environment: $ENVIRONMENT"
    echo "Valid environments: dev, stage, prod, production"
    exit 1
    ;;
esac

echo "🔨 Building Flutter web app for $ENVIRONMENT environment with custom service worker"
echo "Build command: $BUILD_CMD"

# Step 1: Build Flutter web with environment-specific parameters
echo "Building Flutter web app..."
eval $BUILD_CMD

# Check if Flutter build was successful
if [ $? -ne 0 ]; then
  echo "❌ Flutter build failed. Aborting."
  exit 1
fi

echo "✅ Flutter build completed successfully"

# Step 2: Check if build directory exists
if [ ! -d "$BUILD_DIR" ]; then
  echo "❌ Error: Build directory $BUILD_DIR does not exist after build."
  exit 1
fi

# Step 3: Check if template file exists
if [ ! -f "$TEMPLATE_FILE" ]; then
  echo "❌ Error: Service worker template file $TEMPLATE_FILE does not exist."
  exit 1
fi

# Step 4: Generate the service worker
echo "Generating service worker..."

# Create a new assets array file
ASSETS_FILE=$(mktemp)

# Start building the assets array
echo "const RESOURCES = [" > "$ASSETS_FILE"

# Find all files in the build directory and add to assets list
echo "Scanning for assets in $BUILD_DIR..."
ASSET_COUNT=0
find "$BUILD_DIR" -type f | sort | while read -r file; do
  # Get the path relative to the build directory
  relative_path=$(echo "$file" | sed "s|^${BUILD_DIR}||")

  # Remove the leading slash if present, except for the root path "/"
  if [[ "$relative_path" == /* ]] && [[ "$relative_path" != "/" ]]; then
    relative_path="${relative_path:1}"
  fi

  # Skip the service worker itself to avoid a circular reference
  if [[ "$relative_path" != "service-worker.js" ]] && [[ "$relative_path" != "/service-worker.js" ]]; then
    # Add to assets array with comma
    echo "  \"$relative_path\"," >> "$ASSETS_FILE"
    ASSET_COUNT=$((ASSET_COUNT + 1))
  fi
done

# Add the root path as "/" - keep the leading slash for this special case
echo "  \"/\"" >> "$ASSETS_FILE"

# Close the array
echo "];" >> "$ASSETS_FILE"

# Report the number of assets found
echo "Found $ASSET_COUNT assets to cache (plus root path)"

# FIX: Better placeholder replacement that preserves all content
PLACEHOLDER_TEXT="ASSETS_PLACEHOLDER"
PLACEHOLDER_LINE_NUM=$(grep -n "$PLACEHOLDER_TEXT" "$TEMPLATE_FILE" | cut -d: -f1)

if [ -z "$PLACEHOLDER_LINE_NUM" ]; then
  echo "❌ Error: Could not find placeholder in template."
  echo "Please ensure '/* ASSETS_PLACEHOLDER */' exists in your template file."
  echo "Looking in: $TEMPLATE_FILE"
  echo "Searching for: $PLACEHOLDER_TEXT"
  exit 1
fi

# Split the template and preserve all content
head -n $(($PLACEHOLDER_LINE_NUM - 1)) "$TEMPLATE_FILE" > "$OUTPUT_FILE"
cat "$ASSETS_FILE" >> "$OUTPUT_FILE"
tail -n +$(($PLACEHOLDER_LINE_NUM + 1)) "$TEMPLATE_FILE" >> "$OUTPUT_FILE"

# Clean up the temporary file
rm "$ASSETS_FILE"

# Verify the JavaScript syntax in the output file
echo "Verifying JavaScript syntax..."
if command -v node >/dev/null 2>&1; then
  node --check "$OUTPUT_FILE" && echo "✅ JavaScript syntax is valid" || echo "⚠️ Warning: JavaScript syntax may contain errors"
else
  echo "⚠️ Node.js not found - skipping syntax verification"
fi

# Step 5: Verify the service worker was created
if [ -f "$OUTPUT_FILE" ]; then
  echo "✅ Service worker generated successfully at $OUTPUT_FILE"

  # Check if the resource array is properly formatted
  if grep -q "\"/\"" "$OUTPUT_FILE" && grep -q "const RESOURCES = \[" "$OUTPUT_FILE" && grep -q "\];" "$OUTPUT_FILE"; then
    echo "✅ Resource array structure verified"
  else
    echo "⚠️ Warning: Resource array might be malformed"
  fi
else
  echo "❌ Service worker generation failed."
  exit 1
fi

echo "🚀 Your Flutter web app for $ENVIRONMENT environment with custom service worker is ready in $BUILD_DIR"