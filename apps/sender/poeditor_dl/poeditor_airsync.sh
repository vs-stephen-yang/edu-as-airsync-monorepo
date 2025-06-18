#!/bin/bash

# Ref by POEditor API https://poeditor.com/docs/api#projects_export

langArr=(zh-TW da en-us et fi fr de ja lv lt no ru es sv)

for i in "${langArr[@]}"
do
    GET_DATA=$(curl -s -X POST https://api.poeditor.com/v2/projects/export \
         -d api_token="763946f7152a8db8beec75f9ca902985" \
         -d id="665813" \
         -d language=$i \
         -d filters="translated" \
         -d type="arb")

    read -r -d '' RESULT <<EOF
        function run() {
            var info = JSON.parse(\`$GET_DATA\`);
            return info.result.url;
        }
EOF

    LINK=$(osascript -l 'JavaScript' <<< "${RESULT}")
    echo "Downloading intl_$i.arb from ${LINK}..."

    curl -s -o ../lib/l10n/intl_$i.arb ${LINK}

    # 處理 JSON：移除空值與 @ 開頭的欄位
    tmpfile=$(mktemp)
    jq 'with_entries(select(.value != "" and (.key | startswith("@") | not)))' ../lib/l10n/intl_$i.arb > "$tmpfile" && mv "$tmpfile" ../lib/l10n/intl_$i.arb
done

# 特別處理 zh-TW 命名
mv ../lib/l10n/intl_zh-TW.arb ../lib/l10n/intl_zh.arb
# 特別處理 en-us 命名
mv ../lib/l10n/intl_en-us.arb ../lib/l10n/intl_en.arb

echo "=================================="
echo "CHECKING PLACEHOLDERS..."
echo "=================================="

# 檢查佔位符函數
check_placeholders() {
    local file_path="$1"
    local lang="$2"
    local has_error=false
    
    echo "Checking placeholders for $lang..."
    
    # 檢查 v3_main_copy_rights 欄位
    local field_value=$(jq -r '.["v3_main_copy_rights"] // empty' "$file_path")
    if [[ -n "$field_value" ]]; then
        echo "  Checking field 'v3_main_copy_rights': $field_value"
        
        # 檢查是否包含必要的 {year}
        if [[ "$field_value" != *"{year}"* ]]; then
            echo "❌ ERROR: Missing required placeholder '{year}' in field 'v3_main_copy_rights' for language '$lang'"
            echo "   Current value: $field_value"
            has_error=true
        fi
        
        # 檢查是否有不允許的佔位符
        local found_placeholders=$(echo "$field_value" | grep -oE '\{[^}]+\}' | sort -u)
        if [[ -n "$found_placeholders" ]]; then
            while IFS= read -r found_placeholder; do
                if [[ -n "$found_placeholder" ]]; then
                    local placeholder_name=${found_placeholder#\{}
                    placeholder_name=${placeholder_name%\}}
                    
                    if [[ "$placeholder_name" != "year" ]]; then
                        echo "❌ ERROR: Invalid placeholder '$found_placeholder' in field 'v3_main_copy_rights' for language '$lang'"
                        echo "   Current value: $field_value"
                        echo "   Allowed placeholders: {year}"
                        has_error=true
                    fi
                fi
            done <<< "$found_placeholders"
        fi
    fi
    
    # 檢查 v3_setting_app_version_independent 欄位
    field_value=$(jq -r '.["v3_setting_app_version_independent"] // empty' "$file_path")
    if [[ -n "$field_value" ]]; then
        echo "  Checking field 'v3_setting_app_version_independent': $field_value"
        
        # 檢查是否包含必要的 {year} 和 {version}
        if [[ "$field_value" != *"{year}"* ]]; then
            echo "❌ ERROR: Missing required placeholder '{year}' in field 'v3_setting_app_version_independent' for language '$lang'"
            echo "   Current value: $field_value"
            has_error=true
        fi
        
        if [[ "$field_value" != *"{version}"* ]]; then
            echo "❌ ERROR: Missing required placeholder '{version}' in field 'v3_setting_app_version_independent' for language '$lang'"
            echo "   Current value: $field_value"
            has_error=true
        fi
        
        # 檢查是否有不允許的佔位符
        local found_placeholders=$(echo "$field_value" | grep -oE '\{[^}]+\}' | sort -u)
        if [[ -n "$found_placeholders" ]]; then
            while IFS= read -r found_placeholder; do
                if [[ -n "$found_placeholder" ]]; then
                    local placeholder_name=${found_placeholder#\{}
                    placeholder_name=${placeholder_name%\}}
                    
                    if [[ "$placeholder_name" != "year" && "$placeholder_name" != "version" ]]; then
                        echo "❌ ERROR: Invalid placeholder '$found_placeholder' in field 'v3_setting_app_version_independent' for language '$lang'"
                        echo "   Current value: $field_value"
                        echo "   Allowed placeholders: {year} {version}"
                        has_error=true
                    fi
                fi
            done <<< "$found_placeholders"
        fi
    fi
    
    if [[ "$has_error" == true ]]; then
        echo "❌ VALIDATION FAILED for language: $lang"
        return 1
    else
        echo "✅ All placeholders validated for language: $lang"
        return 0
    fi
}

validation_errors=()

# 檢查所有最終的語言檔案
final_langs=(zh da en et fi fr de ja lv lt no ru es sv)

for lang in "${final_langs[@]}"; do
    if [[ -f "../lib/l10n/intl_$lang.arb" ]]; then
        if ! check_placeholders "../lib/l10n/intl_$lang.arb" "$lang"; then
            validation_errors+=("$lang")
        fi
        echo "---"
    else
        echo "⚠️  Warning: File intl_$lang.arb not found"
    fi
done

# 最終報告
echo "=================================="
echo "FINAL VALIDATION REPORT"
echo "=================================="

if [[ ${#validation_errors[@]} -eq 0 ]]; then
    echo "🎉 ALL LANGUAGES PASSED VALIDATION!"
    exit 0
else
    echo "❌ VALIDATION FAILED FOR THE FOLLOWING LANGUAGES:"
    for lang in "${validation_errors[@]}"; do
        echo "   - $lang"
    done
    echo ""
    echo "Please check the translation files and fix the placeholder issues before proceeding."
    exit 1
fi
