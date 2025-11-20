#!/bin/bash

# Ref by POEditor API https://poeditor.com/docs/api#projects_export

langArr=(zh-TW da en et fi fr de ja lv lt no pl pt es sv tr)

for i in "${langArr[@]}"
do
    GET_DATA=$(curl -s -X POST https://api.poeditor.com/v2/projects/export \
         -d api_token="763946f7152a8db8beec75f9ca902985" \
         -d id="546651" \
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


echo "=================================="
echo "CHECKING PLACEHOLDERS FOR v3_settings_version"
echo "=================================="

# 檢查佔位符函數
check_placeholders() {
    local file_path="$1"
    local lang="$2"
    local has_error=false

    # 檢查 v3_settings_version 欄位
    local field_value=$(jq -r '.["v3_settings_version"] // empty' "$file_path")
    if [[ -n "$field_value" ]]; then
        # 檢查是否包含必要的 {year}
        if [[ "$field_value" != *"{year}"* ]]; then
            echo "❌ ERROR: Missing required placeholder '{year}' in field 'v3_settings_version' for language '$lang'"
            echo "   Current value: $field_value"
            has_error=true
        fi

        # 檢查 v3_setting_app_version_independent 欄位 是否有不允許的佔位符
        field_value=$(jq -r '.["v3_setting_app_version_independent"] // empty' "$file_path")
        if [[ -n "$field_value" ]]; then
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
    fi

    if [[ "$has_error" == true ]]; then
        echo "❌ VALIDATION FAILED for language: $lang"
        return 1
    else
        return 0
    fi
}

validation_errors=()

# 檢查所有最終的語言檔案
# shellcheck disable=SC1010
final_langs=(zh da en et fi fr de ja lv lt no pl es sv)
for lang in "${final_langs[@]}"; do
    if [[ -f "../lib/l10n/intl_$lang.arb" ]]; then
        if ! check_placeholders "../lib/l10n/intl_$lang.arb" "$lang"; then
            validation_errors+=("$lang")
        fi
    else
        echo "⚠️  Warning: File intl_$lang.arb not found"
    fi
done

if [[ ${#validation_errors[@]} -eq 0 ]]; then
    echo "🎉 ALL LANGUAGES PASSED VALIDATION!"
else
    echo "❌ VALIDATION FAILED FOR THE FOLLOWING LANGUAGES:"
    for lang in "${validation_errors[@]}"; do
        echo "   - $lang"
    done
    echo ""
    echo "Please check the translation files and fix the placeholder issues before proceeding."
fi

echo "=================================="
printf "CHECKING \\\n \n"
echo "=================================="

newline_keys=()
for lang in "${final_langs[@]}"; do
    arb_file="../lib/l10n/intl_$lang.arb"
    if [[ -f "$arb_file" ]]; then
        # Step 1: 找出哪些 key 是 \n 開頭
        keys_with_newline=()
        while IFS= read -r key; do
            keys_with_newline+=("$key")
        done < <(jq -r 'to_entries[] | select((.value | type == "string") and (.value | test("^\n"))) | .key' "$arb_file")

        # Step 2: 印出發現的 key
        if (( ${#keys_with_newline[@]} )); then
            printf "⚠️  以下 key 在語言 %s 中以 \\\n 開頭，已自動移除開頭換行：\n" "$lang"
            for k in "${keys_with_newline[@]}"; do
                printf "   - %s\n" "$k"
                newline_keys+=("$lang:$k")
            done
        fi

        # Step 3: 替換掉開頭的 \n
        tmpfile=$(mktemp)
        jq 'to_entries | map(if (type == "object" and (.value | type == "string") and (.value | startswith("\n"))) then .value |= sub("^\n"; "") else . end) | from_entries' "$arb_file" > "$tmpfile" && mv "$tmpfile" "$arb_file"
    fi
done

exit 0
