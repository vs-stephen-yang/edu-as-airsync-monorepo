#!/bin/bash

set -e

# Default values
RELEASE_TYPE=""
CHANGELOG_PATH="CHANGELOG.md"
CHECKSUMS_PATH="checksums.md5"
OUTPUT_PATH="RELEASE_NOTE_PUBLIC.md"
S3_BASE_URL="https://myviewboardstorage.s3.us-west-2.amazonaws.com/uploads/VStreamer_Backup/"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -ReleaseType|--release-type)
            RELEASE_TYPE="$2"
            shift 2
            ;;
        -ChangelogPath|--changelog-path)
            CHANGELOG_PATH="$2"
            shift 2
            ;;
        -ChecksumsPath|--checksums-path)
            CHECKSUMS_PATH="$2"
            shift 2
            ;;
        -OutputPath|--output-path)
            OUTPUT_PATH="$2"
            shift 2
            ;;
        -S3BaseUrl|--s3-base-url)
            S3_BASE_URL="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Validate required parameters
if [ -z "$RELEASE_TYPE" ]; then
    echo "Error: -ReleaseType is required"
    echo "Usage: $0 -ReleaseType <Production|Stage|HotFix>"
    exit 1
fi

if [[ ! "$RELEASE_TYPE" =~ ^(Production|Stage|HotFix)$ ]]; then
    echo "Error: ReleaseType must be Production, Stage, or HotFix"
    exit 1
fi

# Get version from pubspec.yaml
VERSION=$(grep "^version: " pubspec.yaml | sed 's/version: //' | cut -d'+' -f1 | tr -d ' ')

if [ -z "$VERSION" ]; then
    echo "Error: Could not extract version from pubspec.yaml"
    exit 1
fi

# Get current date
DATE=$(date +%Y-%m-%d)

echo "Generating public release note..."
echo "Version: $VERSION"
echo "Release Type: $RELEASE_TYPE"
echo "Date: $DATE"
echo ""

# Define the 6 files we need to publish
FILES=(
    "myViewBoardDisplay_APK_EDLA_S_v${VERSION}.apk:EDLA Stage:ViewSonic"
    "myViewBoardDisplay_APK_EDLA_v${VERSION}.apk:EDLA Production:ViewSonic"
    "myViewBoardDisplay_APK_IFP_S_v${VERSION}.apk:IFP Stage:ViewSonic"
    "myViewBoardDisplay_APK_IFP_v${VERSION}.apk:IFP Production:ViewSonic"
    "myViewBoardDisplay_APK_OPEN_S_v${VERSION}.apk:Stage:Other"
    "myViewBoardDisplay_APK_OPEN_v${VERSION}.apk:Production:Other"
)

# Function to get MD5 for a file (take only the first match)
get_md5() {
    local filename="$1"
    grep "$filename" "$CHECKSUMS_PATH" 2>/dev/null | head -1 | awk '{print $2}' || echo ""
}

# Validate files and show summary
for file_info in "${FILES[@]}"; do
    filename=$(echo "$file_info" | cut -d':' -f1)
    md5=$(get_md5 "$filename")

    if [ -n "$md5" ]; then
        echo "  ✓ $filename - MD5: $md5"
    else
        echo "  ✗ $filename - MD5 not found!"
    fi
done

echo ""

# Generate release note content
{
    echo "$DATE (v$VERSION) AirSync (Flutter) $RELEASE_TYPE Release Notes :"
    echo ""
    echo ""

    # Add changelog (skip first 2 lines which is the header)
    tail -n +3 "$CHANGELOG_PATH" | while IFS= read -r line; do
        if [ -n "$line" ]; then
            echo "$line"
        fi
    done

    echo ""
    echo ""

    # ViewSonic products section
    echo "[Download link for ViewSonic's product]"
    echo ""

    for file_info in "${FILES[@]}"; do
        filename=$(echo "$file_info" | cut -d':' -f1)
        label=$(echo "$file_info" | cut -d':' -f2)
        section=$(echo "$file_info" | cut -d':' -f3)

        if [ "$section" = "ViewSonic" ]; then
            url="${S3_BASE_URL}${filename}"
            md5=$(get_md5 "$filename")

            # Format label with padding
            printf "%-16s\t%s\n" "$label:" "$url"
            printf "MD5:\t\t\t%s\n" "$md5"
            echo ""
        fi
    done

    # Other platforms section
    echo "[Download link for other platform]"
    echo ""

    for file_info in "${FILES[@]}"; do
        filename=$(echo "$file_info" | cut -d':' -f1)
        label=$(echo "$file_info" | cut -d':' -f2)
        section=$(echo "$file_info" | cut -d':' -f3)

        if [ "$section" = "Other" ]; then
            url="${S3_BASE_URL}${filename}"
            md5=$(get_md5 "$filename")

            # Format label with padding
            printf "%-16s\t%s\n" "$label:" "$url"
            printf "MD5:\t\t\t%s\n" "$md5"
            echo ""
        fi
    done

    echo "==============================================================================="

} > "$OUTPUT_PATH"

echo "Public release note generated: $OUTPUT_PATH"
