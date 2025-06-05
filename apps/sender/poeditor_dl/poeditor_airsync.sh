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
# 特別處理 zn 命名
mv ../lib/l10n/intl_en-us.arb ../lib/l10n/intl_en.arb
