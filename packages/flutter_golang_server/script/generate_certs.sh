#!/bin/bash

set -e  # Exit on error
set -o pipefail  # Exit if any command in a pipeline fails

# Set CERT_DIR using an environment variable (default: "certs")
CERT_DIR="${CERT_DIR:-certs}"
JSON_FILE="$CERT_DIR/webtransport_certs_list.json"
DAYS_VALID=14

# Ensure CERT_DIR exists
mkdir -p "$CERT_DIR"

# Remove previous files
rm -f "$CERT_DIR"/*.pem "$JSON_FILE"

# Read start and end date arguments
if [ $# -ne 2 ]; then
    echo "❌ Usage: $0 <START_DATE> <END_DATE>"
    exit 1
fi

START_DATE="$1"
END_DATE="$2"

# Validate input format
if ! [[ "$START_DATE" =~ ^[0-9]{8}$ ]] || ! [[ "$END_DATE" =~ ^[0-9]{8}$ ]]; then
    echo "❌ Error: Dates must be in YYYYMMDD format (e.g., 20250201)"
    exit 1
fi

# Generate weekly certificate dates
CERT_DATES=()
CURRENT_DATE="$START_DATE"

while [[ "$CURRENT_DATE" -le "$END_DATE" ]]; do
    CERT_DATES+=("$CURRENT_DATE")

    if [[ "$OSTYPE" == "darwin"* ]]; then
        NEXT_DATE=$(date -j -v+7d -f "%Y%m%d" "$CURRENT_DATE" +"%Y%m%d" 2>/dev/null) || { echo "❌ ERROR: Failed to compute NEXT_DATE"; exit 1; }
    else
        NEXT_DATE=$(date -u -d "$CURRENT_DATE +7 days" +"%Y%m%d" 2>/dev/null) || { echo "❌ ERROR: Failed to compute NEXT_DATE"; exit 1; }
    fi

    if ! [[ "$NEXT_DATE" =~ ^[0-9]{8}$ ]]; then
        echo "❌ ERROR: NEXT_DATE ($NEXT_DATE) is not in YYYYMMDD format."
        exit 1
    fi

    CURRENT_DATE="$NEXT_DATE"
done

# Start JSON output correctly
echo "{" > "$JSON_FILE"
echo "  \"certs\": [" >> "$JSON_FILE"

FIRST=true
for DATE in "${CERT_DATES[@]}"; do
    HUMAN_DATE=$(date -u -d "$DATE" +"%Y-%m-%d" 2>/dev/null || date -j -u -f "%Y%m%d" "$DATE" +"%Y-%m-%d") || { echo "❌ ERROR: Failed to convert DATE"; exit 1; }

    CERT_FILE="$CERT_DIR/cert_${DATE}.pem"
    KEY_FILE="$CERT_DIR/key_${DATE}.pem"
    CSR_FILE="$CERT_DIR/csr_${DATE}.csr"

    openssl ecparam -name prime256v1 -genkey -noout -out "$KEY_FILE" || { echo "❌ ERROR: Failed to generate EC key"; exit 1; }

    openssl req -new -key "$KEY_FILE" -out "$CSR_FILE" \
        -subj "/CN=127.0.0.1" \
        -addext "subjectAltName=DNS:localhost,IP:127.0.0.1" || { echo "❌ ERROR: Failed to generate CSR"; exit 1; }

    NOT_BEFORE="${DATE}000000Z"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        NOT_AFTER=$(date -j -v +"$DAYS_VALID"d -f "%Y%m%d" "$DATE" +"%Y%m%d000000Z") || { echo "❌ ERROR: Failed to compute NOT_AFTER"; exit 1; }
    else
        NOT_AFTER=$(date -u -d "$DATE +$DAYS_VALID days" +"%Y%m%d000000Z" 2>/dev/null) || { echo "❌ ERROR: Failed to compute NOT_AFTER"; exit 1; }
    fi

    if ! [[ "$NOT_AFTER" =~ ^[0-9]{14}Z$ ]]; then
        echo "❌ ERROR: NOT_AFTER ($NOT_AFTER) is not in YYYYMMDDHHMMSSZ format."
        exit 1
    fi

    openssl x509 -req -in "$CSR_FILE" -signkey "$KEY_FILE" -out "$CERT_FILE" \
        -not_before "$NOT_BEFORE" -not_after "$NOT_AFTER" || { echo "❌ ERROR: Failed to sign certificate"; exit 1; }

    # Convert certificate & key to JSON-friendly format
    CERT_LINES=$(awk '{print "    \""$0"\","}' "$CERT_FILE" | sed '$ s/,$//')
    KEY_LINES=$(awk '{print "    \""$0"\","}' "$KEY_FILE" | sed '$ s/,$//')

    # ✅ Fix JSON Formatting (Remove trailing commas)
    if [ "$FIRST" = true ]; then
        FIRST=false
    else
        echo "    ," >> "$JSON_FILE"
    fi

    echo "    {" >> "$JSON_FILE"
    echo "      \"date\": \"$HUMAN_DATE\"," >> "$JSON_FILE"
    echo "      \"certPem\": [" >> "$JSON_FILE"
    echo "$CERT_LINES" >> "$JSON_FILE"
    echo "      ]," >> "$JSON_FILE"
    echo "      \"keyPem\": [" >> "$JSON_FILE"
    echo "$KEY_LINES" >> "$JSON_FILE"
    echo "      ]" >> "$JSON_FILE"
    echo "    }" >> "$JSON_FILE"
done

# ✅ Remove trailing comma and close JSON array properly
echo "  ]" >> "$JSON_FILE"
echo "}" >> "$JSON_FILE"

echo "✅ EC Certificates and JSON list generated in $CERT_DIR"
