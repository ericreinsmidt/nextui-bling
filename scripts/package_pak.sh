#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DIST_DIR="$PROJECT_DIR/dist"
PAK_JSON="$PROJECT_DIR/pak.json"

APP_NAME="$(grep -E '"name"' "$PAK_JSON" | head -n1 | cut -d'"' -f4)"
RELEASE_FILENAME="$(grep -E '"release_filename"' "$PAK_JSON" | head -n1 | cut -d'"' -f4)"

PLATFORMS=("tg5040" "tg5050")

echo ""
echo "=== Packaging ${APP_NAME} ==="
echo ""

# Validate
if [ -z "$APP_NAME" ] || [ -z "$RELEASE_FILENAME" ]; then
    echo "ERROR: Failed to read name or release_filename from pak.json"
    exit 1
fi

for PLATFORM in "${PLATFORMS[@]}"; do
    PAK_DIR="$PROJECT_DIR/ports/$PLATFORM/pak"
    if [ ! -f "$PAK_DIR/bin/bling" ]; then
        echo "ERROR: Binary not found at $PAK_DIR/bin/bling — run 'make build' first"
        exit 1
    fi
done

# Create clean zip via temp dir (excludes .DS_Store)
mkdir -p "$DIST_DIR"
TMP_DIR="$DIST_DIR/tmp-package"
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

for PLATFORM in "${PLATFORMS[@]}"; do
    PAK_DIR="$PROJECT_DIR/ports/$PLATFORM/pak"
    mkdir -p "$TMP_DIR/Tools/$PLATFORM/${APP_NAME}.pak"
    rsync -a --exclude='.DS_Store' "$PAK_DIR/" "$TMP_DIR/Tools/$PLATFORM/${APP_NAME}.pak/"

    if [ ! -f "$TMP_DIR/Tools/$PLATFORM/${APP_NAME}.pak/launch.sh" ]; then
        echo "ERROR: Missing launch.sh in $PLATFORM pak directory"
        rm -rf "$TMP_DIR"
        exit 1
    fi
    echo "  Included: $PLATFORM"
done

OUTPUT_ZIP="$DIST_DIR/$RELEASE_FILENAME"
rm -f "$OUTPUT_ZIP"
cd "$TMP_DIR"
zip -r "$OUTPUT_ZIP" ./*
cd "$PROJECT_DIR"
rm -rf "$TMP_DIR"

echo ""
echo "=== Package complete ==="
echo "Output: dist/$RELEASE_FILENAME"
echo ""
