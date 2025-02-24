#!/bin/bash

openssl x509 -help

CERT_DIR="certs"
JSON_FILE="$CERT_DIR/webtransport_certs_list.json"
DAYS_VALID=14

# Ensure CERT_DIR exists
mkdir -p "$CERT_DIR"

# Remove previous files
rm -f "$CERT_DIR"/*.pem "$JSON_FILE"

# Read start and end date arguments
if [ $# -ne 2 ]; then
    echo "Usage: $0 <START_DATE> <END_DATE>"
    echo "Example: $0 20250201 20260201"
    exit 1
fi

START_DATE="$1"
END_DATE="$2"

# Validate input format (must be strictly YYYYMMDD)
if ! [[ "$START_DATE" =~ ^[0-9]{8}$ ]] || ! [[ "$END_DATE" =~ ^[0-9]{8}$ ]]; then
    echo "❌ Error: Dates must be in YYYYMMDD format (e.g., 20250201)"
    exit 1
fi

# Generate weekly certificate dates
CERT_DATES=()
CURRENT_DATE="$START_DATE"

while [[ "$CURRENT_DATE" -le "$END_DATE" ]]; do
    CERT_DATES+=("$CURRENT_DATE")

    # Generate NEXT_DATE in YYYYMMDD format
    if [[ "$OSTYPE" == "darwin"* ]]; then
        NEXT_DATE=$(date -j -v+7d -f "%Y%m%d" "$CURRENT_DATE" +"%Y%m%d" 2>/dev/null)
    else
        NEXT_DATE=$(date -u -d "$CURRENT_DATE +7 days" +"%Y%m%d" 2>/dev/null)
    fi

    # Ensure NEXT_DATE is valid
    if ! [[ "$NEXT_DATE" =~ ^[0-9]{8}$ ]]; then
        echo "❌ ERROR: NEXT_DATE ($NEXT_DATE) is not in YYYYMMDD format."
        exit 1
    fi

    CURRENT_DATE="$NEXT_DATE"
done

# Start JSON output
echo "{" > "$JSON_FILE"
echo "  \"certs\": [" >> "$JSON_FILE"

FIRST=true
for DATE in "${CERT_DATES[@]}"; do
    # Convert to human-readable format
    HUMAN_DATE=$(date -u -d "$DATE" +"%Y-%m-%d" 2>/dev/null || date -j -u -f "%Y%m%d" "$DATE" +"%Y-%m-%d")

    CERT_FILE="$CERT_DIR/cert_${DATE}.pem"
    KEY_FILE="$CERT_DIR/key_${DATE}.pem"
    CSR_FILE="$CERT_DIR/csr_${DATE}.csr"

    # Generate a new EC Private Key for each cert
    openssl ecparam -name prime256v1 -genkey -noout -out "$KEY_FILE"

    # Generate CSR using the new EC Key
    openssl req -new -key "$KEY_FILE" -out "$CSR_FILE" \
        -subj "/CN=127.0.0.1" \
        -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"

    # ✅ Convert `YYYYMMDD` to `YYYYMMDDHHMMSSZ` format
    NOT_BEFORE="${DATE}000000Z"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        NOT_AFTER=$(date -j -v +"$DAYS_VALID"d -f "%Y%m%d" "$DATE" +"%Y%m%d000000Z")
    else
        NOT_AFTER=$(date -u -d "$DATE +$DAYS_VALID days" +"%Y%m%d000000Z" 2>/dev/null)
    fi

    # ✅ Check that NOT_AFTER is in the correct format
    if ! [[ "$NOT_AFTER" =~ ^[0-9]{14}Z$ ]]; then
        echo "❌ ERROR: NOT_AFTER ($NOT_AFTER) is not in YYYYMMDDHHMMSSZ format."
        exit 1
    fi

    # Sign Certificate
    openssl x509 -req -in "$CSR_FILE" -signkey "$KEY_FILE" -out "$CERT_FILE" \
        -not_before "$NOT_BEFORE" \
        -not_after "$NOT_AFTER"

    # Convert certificate & key to JSON-friendly format
    CERT_LINES=$(awk '{print "    \""$0"\","}' "$CERT_FILE" | sed '$ s/,$//')
    KEY_LINES=$(awk '{print "    \""$0"\","}' "$KEY_FILE" | sed '$ s/,$//')

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

echo "  ]" >> "$JSON_FILE"
echo "}" >> "$JSON_FILE"

echo "✅ EC Certificates and JSON list generated in $CERT_DIR"
