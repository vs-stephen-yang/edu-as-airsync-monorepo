#!/bin/bash

set -e  # Exit on error
set -o pipefail  # Exit if any command in a pipeline fails

if [ -z "$1" ]; then
  echo "❌ Usage: $0 <certificates-directory>"
  exit 1
fi

CERT_DIR="$1"
OUTPUT_FILE="$CERT_DIR/webtransport_cert_hashes.json"
OUTPUT_JSON="{ \"certs\": ["

if [ ! -d "$CERT_DIR" ]; then
  echo "❌ ERROR: Directory $CERT_DIR does not exist."
  exit 1
fi

for CERT_FILE in "$CERT_DIR"/cert_*.pem; do
  if [ ! -f "$CERT_FILE" ]; then
    echo "⚠️ Warning: No certificate files found in $CERT_DIR"
    continue
  fi

  FILENAME=$(basename "$CERT_FILE")
  DATE=$(echo "$FILENAME" | sed -E 's/cert_([0-9]{4})([0-9]{2})([0-9]{2})\.pem/\1-\2-\3/') || { echo "❌ ERROR: Failed to extract date from $CERT_FILE"; exit 1; }

  HASH=$(openssl x509 -in "$CERT_FILE" -outform der | openssl dgst -sha256 -binary | xxd -p -c 32) || { echo "❌ ERROR: Failed to generate hash for $CERT_FILE"; exit 1; }

  HASH_ARRAY=""
  for ((i=0; i<${#HASH}; i+=2)); do
    BYTE="0x${HASH:i:2}"
    HASH_ARRAY="$HASH_ARRAY $BYTE,"
  done
  HASH_ARRAY="${HASH_ARRAY%,}"

  OUTPUT_JSON="$OUTPUT_JSON { \"date\": \"$DATE\", \"hash\": \"$HASH_ARRAY\" },"
done

OUTPUT_JSON="${OUTPUT_JSON%,} ] }"

echo "$OUTPUT_JSON" > "$OUTPUT_FILE" || { echo "❌ ERROR: Failed to write JSON to $OUTPUT_FILE"; exit 1; }

echo "✅ Hashes saved to $OUTPUT_FILE"
