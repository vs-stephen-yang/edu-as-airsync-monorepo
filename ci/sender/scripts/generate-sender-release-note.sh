#!/bin/bash

set -e

# Default values
RELEASE_TYPE=""
FROM_TAG=""
OUTPUT_PATH=""
WINDOWS_URL=""
MAC_URL=""
ANDROID_URL=""
WEB_URL=""
INTERACTIVE=true

# Color codes for better readability
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -ReleaseType|--release-type)
            RELEASE_TYPE="$2"
            shift 2
            ;;
        -FromTag|--from-tag)
            FROM_TAG="$2"
            shift 2
            ;;
        -OutputPath|--output-path)
            OUTPUT_PATH="$2"
            shift 2
            ;;
        -WindowsUrl|--windows-url)
            WINDOWS_URL="$2"
            INTERACTIVE=false
            shift 2
            ;;
        -MacUrl|--mac-url)
            MAC_URL="$2"
            INTERACTIVE=false
            shift 2
            ;;
        -AndroidUrl|--android-url)
            ANDROID_URL="$2"
            INTERACTIVE=false
            shift 2
            ;;
        -WebUrl|--web-url)
            WEB_URL="$2"
            INTERACTIVE=false
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 -ReleaseType <Production|Stage|HotFix|R.C.> [-FromTag <tag>] [-OutputPath <path>] [-WindowsUrl <url>] [-MacUrl <url>] [-AndroidUrl <url>] [-WebUrl <url>]"
            exit 1
            ;;
    esac
done

# Validate required parameters
if [ -z "$RELEASE_TYPE" ]; then
    echo "Error: -ReleaseType is required"
    echo "Usage: $0 -ReleaseType <Production|Stage|HotFix|R.C.> [-FromTag <tag>] [-OutputPath <path>]"
    exit 1
fi

if [[ ! "$RELEASE_TYPE" =~ ^(Production|Stage|HotFix|R\.C\.)$ ]]; then
    echo "Error: ReleaseType must be Production, Stage, HotFix, or R.C."
    exit 1
fi

# Get version from pubspec.yaml
VERSION=$(grep "^version: " pubspec.yaml | sed 's/version: //' | cut -d'+' -f1 | tr -d ' ')

if [ -z "$VERSION" ]; then
    echo "Error: Could not extract version from pubspec.yaml"
    exit 1
fi

# Get current date (zero-padded: YYYY-MM-DD)
DATE=$(date +%Y-%m-%d)

echo -e "${GREEN}Generating AirSync Sender Release Note${NC}"
echo -e "${BLUE}Version: v$VERSION${NC}"
echo -e "${BLUE}Release Type: $RELEASE_TYPE${NC}"
echo -e "${BLUE}Date: $DATE${NC}"
echo ""

# Determine the commit range to compare from
if [ -n "$FROM_TAG" ]; then
    # If a tag is specified, use <TAG>..HEAD directly
    COMMIT_RANGE="$FROM_TAG..HEAD"
    echo -e "${BLUE}Using commits from tag: $FROM_TAG..HEAD${NC}"
else
    # Prefer using the last two 'chore: Change version and TAG' commits on main branch (fallback to master)
    BRANCH=""
    if git show-ref --verify --quiet refs/heads/main || git show-ref --verify --quiet refs/remotes/origin/main; then
        BRANCH="main"
    elif git show-ref --verify --quiet refs/heads/master || git show-ref --verify --quiet refs/remotes/origin/master; then
        BRANCH="master"
    fi

    if [ -n "$BRANCH" ]; then
        LATEST_VERSION_COMMIT=$(git log $BRANCH --grep="^chore: Change version and TAG$" --format="%H" | head -1)
        PREV_VERSION_COMMIT=$(git log $BRANCH --grep="^chore: Change version and TAG$" --format="%H" | sed -n '2p')
    else
        # Fallback to searching across current history
        LATEST_VERSION_COMMIT=$(git log --grep="^chore: Change version and TAG$" --format="%H" | head -1)
        PREV_VERSION_COMMIT=$(git log --grep="^chore: Change version and TAG$" --format="%H" | sed -n '2p')
    fi

    if [ -n "$PREV_VERSION_COMMIT" ] && [ -n "$LATEST_VERSION_COMMIT" ]; then
        COMMIT_RANGE="$PREV_VERSION_COMMIT..$LATEST_VERSION_COMMIT"
        echo -e "${BLUE}Using commits between version changes on branch '${BRANCH:-current}':${NC}"
        echo -e "  From: $(git log -1 --oneline $PREV_VERSION_COMMIT)"
        echo -e "  To:   $(git log -1 --oneline $LATEST_VERSION_COMMIT)"
    else
        # Fallback order: latest tag..HEAD, otherwise HEAD
        FALLBACK_TAG=$(git tag --sort=-version:refname | head -1)
        if [ -n "$FALLBACK_TAG" ]; then
            COMMIT_RANGE="$FALLBACK_TAG..HEAD"
            echo -e "${YELLOW}No previous version-change pair found. Fallback to latest tag: $FALLBACK_TAG..HEAD${NC}"
        else
            COMMIT_RANGE="HEAD"
            echo -e "${YELLOW}No version-change commits or tags found. Showing all commits from HEAD.${NC}"
        fi
    fi
fi

echo -e "${BLUE}Getting commits from: $COMMIT_RANGE${NC}"
echo ""

# Get git log commits and filter out version-bump chore
COMMITS=$(git log $COMMIT_RANGE --pretty=format:"- %s" --no-merges \
    | grep -v "chore: Change version and TAG" || true)

if [ -z "$COMMITS" ]; then
    echo -e "${YELLOW}Warning: No commits found in range $COMMIT_RANGE${NC}"
    COMMITS="- No changes recorded"
fi

# Prompt user for download links only in interactive mode
if [ "$INTERACTIVE" = true ]; then
    echo -e "${GREEN}Please enter download links for each platform (press Enter to skip):${NC}"
    echo ""

    read -p "Windows app URL: " WINDOWS_URL
    read -p "Mac app URL: " MAC_URL
    read -p "Android app URL (Dropbox): " ANDROID_URL
    read -p "Web URL: " WEB_URL

    echo ""
fi

echo -e "${GREEN}Generating release note...${NC}"
echo ""

# Generate release note content
RELEASE_NOTE=$(cat <<EOF
$DATE (v$VERSION) AirSync Sender (MacOS/ iOS/ Android/ Windows/ Web) $RELEASE_TYPE Release Notes:

$COMMITS

EOF
)

# Add download links if provided
FIRST_LINK=true

if [ -n "$WINDOWS_URL" ]; then
    if [ "$FIRST_LINK" = true ]; then
        RELEASE_NOTE+=$'\n\n'"Download Windows app: $WINDOWS_URL"$'\n'
        FIRST_LINK=false
    else
        RELEASE_NOTE+=$'\n'"Download Windows app: $WINDOWS_URL"$'\n'
    fi
fi

if [ -n "$MAC_URL" ]; then
    if [ "$FIRST_LINK" = true ]; then
        RELEASE_NOTE+=$'\n\n'"Download Mac app for Ind: $MAC_URL"$'\n'
        FIRST_LINK=false
    else
        RELEASE_NOTE+=$'\n'"Download Mac app for Ind: $MAC_URL"$'\n'
    fi
fi

if [ -n "$ANDROID_URL" ]; then
    if [ "$FIRST_LINK" = true ]; then
        RELEASE_NOTE+=$'\n\n'"Download Android app: $ANDROID_URL"$'\n'
        FIRST_LINK=false
    else
        RELEASE_NOTE+=$'\n'"Download Android app: $ANDROID_URL"$'\n'
    fi
fi

if [ -n "$WEB_URL" ]; then
    if [ "$FIRST_LINK" = true ]; then
        RELEASE_NOTE+=$'\n\n'"Web: $WEB_URL"$'\n'
        FIRST_LINK=false
    else
        RELEASE_NOTE+=$'\n'"Web: $WEB_URL"$'\n'
    fi
fi

RELEASE_NOTE+="==============================================================================="$'\n'

# Output to file or terminal
if [ -n "$OUTPUT_PATH" ]; then
    echo "$RELEASE_NOTE" > "$OUTPUT_PATH"
    echo -e "${GREEN}Release note saved to: $OUTPUT_PATH${NC}"
    echo ""
    echo -e "${BLUE}Content:${NC}"
    cat "$OUTPUT_PATH"
else
    echo -e "${BLUE}========== RELEASE NOTE (Copy content below) ==========${NC}"
    echo ""
    echo "$RELEASE_NOTE"
    echo -e "${BLUE}=======================================================${NC}"
fi
