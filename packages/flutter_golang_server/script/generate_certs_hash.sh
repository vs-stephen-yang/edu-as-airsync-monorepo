#!/bin/bash

# Check if a directory is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <certificates-directory>"
  exit 1
fi

CERT_DIR="$1"
OUTPUT_FILE="$CERT_DIR/webtransport_cert_hashes.json"
OUTPUT_JSON="{ \"certs\": ["

# Loop through certificate files in the directory
for CERT_FILE in "$CERT_DIR"/cert_*.pem; do
  # Extract date from filename and convert format
  FILENAME=$(basename "$CERT_FILE")
  DATE=$(echo "$FILENAME" | sed -E 's/cert_([0-9]{4})([0-9]{2})([0-9]{2})\.pem/\1-\2-\3/')

  # Generate the SHA-256 hash
  HASH=$(openssl x509 -in "$CERT_FILE" -outform der | openssl dgst -sha256 -binary | xxd -p -c 32)

  # Format the hash into an array
  HASH_ARRAY=""
  for ((i=0; i<${#HASH}; i+=2)); do
    BYTE="0x${HASH:i:2}"
    HASH_ARRAY="$HASH_ARRAY $BYTE,"
  done
  HASH_ARRAY="${HASH_ARRAY%,}"

  # Append to JSON output
  OUTPUT_JSON="$OUTPUT_JSON { \"date\": \"$DATE\", \"hash\": \"$HASH_ARRAY\" },"
done

# Remove trailing comma and close JSON
OUTPUT_JSON="${OUTPUT_JSON%,} ] }"

# Write to output file
echo "$OUTPUT_JSON" > "$OUTPUT_FILE"

echo "Hashes saved to $OUTPUT_FILE"

