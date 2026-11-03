#!/bin/sh

# Markdown renderers.

md_escape_pipe() {
    printf "%s" "$1" | sed 's/|/\\|/g'
}

md_escape_cell() {
    printf "%s" "$1" | sed 's/\\/\\\\/g; s/|/\\|/g; s/`/\\`/g'
}

render_service_index_markdown() {
    out_file="${OUT_DIR}/service-index.md"
    ensure_dir "$(path_dirname "$out_file")"

    {
        printf "# DBus Service Index\n\n"
        printf "| Service |\n"
        printf "| --- |\n"
        while IFS= read -r service; do
            [ -n "$service" ] || continue
            printf "| %s |\n" "$(md_escape_pipe "$service")"
        done < "$SERVICES_FILE"
    } > "$out_file"

    cp "$out_file" "${MARKDOWN_DIR}/service-index.md" 2>/dev/null || :
}

render_object_markdown() {
    service=$1
    object_path=$2
    raw_file=$3
    interfaces_file=$4
    children_file=$5
    props_iface=$6

    out_file=$(object_markdown_path "$service" "$object_path")
    ensure_dir "$(path_dirname "$out_file")"

    {
        printf "# Object\n\n"
        printf "| Item | Value |\n"
        printf "| --- | --- |\n"
        printf '| Object Path | `%s` |\n' "$object_path"
        printf '| Service | `%s` |\n' "$service"
        printf '| Raw Introspection | `%s` |\n' "$raw_file"
        printf '| Properties Interface | `%s` |\n\n' "${props_iface:-none}"

        printf "## Interfaces\n\n"
        if [ -s "$interfaces_file" ]; then
            while IFS= read -r iface; do
                [ -n "$iface" ] || continue
                printf '%s `%s`\n' "-" "$iface"
            done < "$interfaces_file"
        else
            printf "No interfaces parsed.\n"
        fi
        printf "\n"

        printf "## Methods\n\n"
        awk -F '\t' -v s="$service" -v o="$object_path" '
            $1 == s && $2 == o { print "- `" $3 "." $4 "` - `" $5 "`" }
        ' "$METHODS_TSV"
        if ! awk -F '\t' -v s="$service" -v o="$object_path" '$1 == s && $2 == o { found=1 } END { exit !found }' "$METHODS_TSV"; then
            printf "No methods parsed.\n"
        fi
        printf "\n"

        printf "## Signals\n\n"
        awk -F '\t' -v s="$service" -v o="$object_path" '
            $1 == s && $2 == o { print "- `" $3 "." $4 "` - `" $5 "`" }
        ' "$SIGNALS_TSV"
        if ! awk -F '\t' -v s="$service" -v o="$object_path" '$1 == s && $2 == o { found=1 } END { exit !found }' "$SIGNALS_TSV"; then
            printf "No signals parsed.\n"
        fi
        printf "\n"

        printf "## Properties\n\n"
        printf "| Interface | Property | Type | Permission |\n"
        printf "| --- | --- | --- | --- |\n"
        awk -F '\t' -v s="$service" -v o="$object_path" '
            $1 == s && $2 == o { print "| `" $3 "` | `" $4 "` | `" $5 "` | `" $6 "` |" }
        ' "$PROPERTIES_TSV"
        printf "\n"

        printf "## Current Values\n\n"
        printf "| Interface | Property | Type | Access | Status | Value |\n"
        printf "| --- | --- | --- | --- | --- | --- |\n"
        awk -F '\t' -v s="$service" -v o="$object_path" '
            $1 == s && $2 == o {
                value=$9
                gsub(/\\/,"\\\\",value)
                gsub(/\|/,"\\|",value)
                gsub(/`/,"\\`",value)
                print "| `" $3 "` | `" $4 "` | `" $5 "` | `" $6 "` | " $8 " | `" value "` |"
            }
        ' "$PROPERTIES_VALUES_TSV"
        if ! awk -F '\t' -v s="$service" -v o="$object_path" '$1 == s && $2 == o { found=1 } END { exit !found }' "$PROPERTIES_VALUES_TSV"; then
            printf "| - | - | - | - | skipped | no readable Properties interface or no values collected |\n"
        fi
        printf "\n"

        printf "## GetAll\n\n"
        printf "| Interface | Status | Raw File |\n"
        printf "| --- | --- | --- |\n"
        awk -F '\t' -v s="$service" -v o="$object_path" '
            $1 == s && $2 == o { print "| `" $3 "` | " $4 " | `" $5 "` |" }
        ' "$GETALL_TSV"
        printf "\n"

        printf "## ManagedObjects\n\n"
        printf "| Interface | Status | Raw File |\n"
        printf "| --- | --- | --- |\n"
        awk -F '\t' -v s="$service" -v o="$object_path" '
            $1 == s && $2 == o { print "| `" $3 "` | " $4 " | `" $5 "` |" }
        ' "$MANAGED_TSV"
        printf "\n"

        printf "## Child Objects\n\n"
        if [ -s "$children_file" ]; then
            while IFS= read -r child; do
                [ -n "$child" ] || continue
                printf '%s `%s`\n' "-" "$child"
            done < "$children_file"
        else
            printf "No child objects parsed.\n"
        fi
    } > "$out_file"
}

render_sensitive_markdown() {
    out_file="${OUT_DIR}/SensitiveProperties.md"
    objects_file="${OUT_DIR}/SensitiveObjects.md"
    ensure_dir "$(path_dirname "$out_file")"

    {
        printf "# Sensitive Properties\n\n"
        printf "| Service | Object | Interface | Property | Access | Status | Value |\n"
        printf "| --- | --- | --- | --- | --- | --- | --- |\n"
        awk -F '\t' '
            function sensitive(text) {
                t=tolower(text)
                return t ~ /(password|pass|pwd|user|username|account|admin|auth|token|key|secret|sn|serial|loid|mac|wan|pppoe|ssid|wep|wpa|psk|enable|status|version|firmware|device|model|vendor)/
            }
            sensitive($4) {
                value=$9
                gsub(/\\/,"\\\\",value)
                gsub(/\|/,"\\|",value)
                gsub(/`/,"\\`",value)
                print "| `" $1 "` | `" $2 "` | `" $3 "` | `" $4 "` | `" $6 "` | " $8 " | `" value "` |"
            }
        ' "$PROPERTIES_VALUES_TSV"
    } > "$out_file"

    {
        printf "# Sensitive Objects\n\n"
        printf "| Service | Object | Sensitive Property Count |\n"
        printf "| --- | --- | ---: |\n"
        awk -F '\t' '
            function sensitive(text) {
                t=tolower(text)
                return t ~ /(password|pass|pwd|user|username|account|admin|auth|token|key|secret|sn|serial|loid|mac|wan|pppoe|ssid|wep|wpa|psk|enable|status|version|firmware|device|model|vendor)/
            }
            sensitive($4) { key=$1 "\t" $2; count[key]++ }
            END {
                for (key in count) {
                    split(key, parts, "\t")
                    print "| `" parts[1] "` | `" parts[2] "` | " count[key] " |"
                }
            }
        ' "$PROPERTIES_VALUES_TSV" | sort
        printf "\n## Matching Properties\n\n"
        printf "| Service | Object | Property | Access | Value |\n"
        printf "| --- | --- | --- | --- | --- |\n"
        awk -F '\t' '
            function sensitive(text) {
                t=tolower(text)
                return t ~ /(password|pass|pwd|user|username|account|admin|auth|token|key|secret|sn|serial|loid|mac|wan|pppoe|ssid|wep|wpa|psk|enable|status|version|firmware|device|model|vendor)/
            }
            sensitive($4) {
                value=$9
                gsub(/\\/,"\\\\",value)
                gsub(/\|/,"\\|",value)
                gsub(/`/,"\\`",value)
                print "| `" $1 "` | `" $2 "` | `" $4 "` | `" $6 "` | `" value "` |"
            }
        ' "$PROPERTIES_VALUES_TSV"
    } > "$objects_file"

    cp "$out_file" "${MARKDOWN_DIR}/SensitiveProperties.md" 2>/dev/null || :
    cp "$objects_file" "${MARKDOWN_DIR}/SensitiveObjects.md" 2>/dev/null || :
}

render_writable_markdown() {
    out_file="${OUT_DIR}/WritableProperties.md"
    {
        printf "# Writable Properties\n\n"
        printf "| Service | Object | Interface | Property | Type | Current Value |\n"
        printf "| --- | --- | --- | --- | --- | --- |\n"
        awk -F '\t' '$6 == "RW" {
            value=$9
            gsub(/\\/,"\\\\",value)
            gsub(/\|/,"\\|",value)
            gsub(/`/,"\\`",value)
            print "| `" $1 "` | `" $2 "` | `" $3 "` | `" $4 "` | `" $5 "` | `" value "` |"
        }' "$PROPERTIES_VALUES_TSV"
    } > "$out_file"
    cp "$out_file" "${MARKDOWN_DIR}/WritableProperties.md" 2>/dev/null || :
}

render_web_management_markdown() {
    out_file="${OUT_DIR}/WebManagement.md"
    {
        printf "# Web Management Candidates\n\n"
        printf "仅根据 Object/Method/Property/Value 导出数据匹配关键词，不做主观判断。\n\n"
        printf "关键词：HTTP, Web, Admin, Login, Account, Mng, System, User, Password, Auth。\n\n"

        printf "## Matching Objects\n\n"
        printf "| Service | Object | Status |\n"
        printf "| --- | --- | --- |\n"
        awk -F '\t' 'tolower($2) ~ /(http|web|admin|login|account|mng|system|user)/ {
            print "| `" $1 "` | `" $2 "` | " $3 " |"
        }' "$OBJECTS_TSV"
        printf "\n"

        printf "## Matching Properties\n\n"
        printf "| Service | Object | Interface | Property | Access | Value |\n"
        printf "| --- | --- | --- | --- | --- | --- |\n"
        awk -F '\t' 'tolower($2 " " $4) ~ /(http|web|admin|login|account|mng|system|user|password|auth)/ {
            value=$9
            gsub(/\\/,"\\\\",value)
            gsub(/\|/,"\\|",value)
            gsub(/`/,"\\`",value)
            print "| `" $1 "` | `" $2 "` | `" $3 "` | `" $4 "` | `" $6 "` | `" value "` |"
        }' "$PROPERTIES_VALUES_TSV"
        printf "\n"

        printf "## Matching Methods\n\n"
        printf "| Service | Object | Interface | Method | Signature |\n"
        printf "| --- | --- | --- | --- | --- |\n"
        awk -F '\t' 'tolower($2 " " $3 " " $4) ~ /(http|web|admin|login|account|mng|system|user|password|auth)/ {
            sig=$5
            gsub(/\|/,"\\|",sig)
            print "| `" $1 "` | `" $2 "` | `" $3 "` | `" $4 "` | `" sig "` |"
        }' "$METHODS_TSV"
    } > "$out_file"
    cp "$out_file" "${MARKDOWN_DIR}/WebManagement.md" 2>/dev/null || :
}

render_properties_markdown() {
    out_file="${MARKDOWN_DIR}/properties/properties.md"
    ensure_dir "$(path_dirname "$out_file")"

    {
        printf "# DBus Properties\n\n"
        printf "| Service | Object | Interface | Property | Type | Permission |\n"
        printf "| --- | --- | --- | --- | --- | --- |\n"
        awk -F '\t' '{
            print "| `" $1 "` | `" $2 "` | `" $3 "` | `" $4 "` | `" $5 "` | `" $6 "` |"
        }' "$PROPERTIES_TSV"
    } > "$out_file"
}

render_tree_text() {
    out_file="${OUT_DIR}/tree.txt"
    {
        while IFS='	' read -r service object_path; do
            [ -n "$service" ] || continue
            if [ "$object_path" = "/" ]; then
                printf "%s /\n" "$service"
            else
                depth=$(printf "%s" "$object_path" | awk -F/ '{ print NF - 2 }')
                prefix=""
                i=0
                while [ "$i" -lt "$depth" ]; do
                    prefix="${prefix}|   "
                    i=$((i + 1))
                done
                name=${object_path##*/}
                printf "%s%s+-- %s\n" "$service " "$prefix" "$name"
            fi
        done < "$TREE_TSV"
    } > "$out_file"

    cp "$out_file" "${MARKDOWN_DIR}/tree.txt" 2>/dev/null || :
}

render_summary_markdown() {
    out_file="${OUT_DIR}/summary.md"
    end=$(epoch_now)
    elapsed=$((end - START_EPOCH))

    service_count=$(count_lines "$SERVICES_FILE")
    object_count=$(count_lines "$OBJECTS_TSV")
    interface_count=$(awk -F '\t' '{ print $3 }' "$INTERFACES_TSV" | sort -u | awk 'END { print NR + 0 }')
    method_count=$(count_lines "$METHODS_TSV")
    property_count=$(count_lines "$PROPERTIES_TSV")
    signal_count=$(count_lines "$SIGNALS_TSV")
    rw_count=$(awk -F '\t' '$6 == "RW" { c++ } END { print c + 0 }' "$PROPERTIES_TSV")
    ro_count=$(awk -F '\t' '$6 == "RO" { c++ } END { print c + 0 }' "$PROPERTIES_TSV")
    objectmanager_count=$(awk -F '\t' '$4 == "ok" { c++ } END { print c + 0 }' "$MANAGED_TSV")
    getall_success_count=$(awk -F '\t' '$4 == "ok" { c++ } END { print c + 0 }' "$GETALL_TSV")
    property_values_count=$(count_lines "$PROPERTIES_VALUES_TSV")
    property_values_success_count=$(awk -F '\t' '$8 == "ok" { c++ } END { print c + 0 }' "$PROPERTIES_VALUES_TSV")
    failure_count=$(count_lines "$FAILURES_FILE")

    {
        printf "# DBus Explorer Summary\n\n"
        printf "| Item | Value |\n"
        printf "| --- | --- |\n"
        printf "| Tool | %s |\n" "$DBUS_TOOL"
        printf "| Bus | %s |\n" "$BUS_TYPE"
        printf "| Service 数量 | %s |\n" "$service_count"
        printf "| Object 数量 | %s |\n" "$object_count"
        printf "| Interface 数量 | %s |\n" "$interface_count"
        printf "| Method 数量 | %s |\n" "$method_count"
        printf "| Property 数量 | %s |\n" "$property_count"
        printf "| Signal 数量 | %s |\n" "$signal_count"
        printf "| RW Property 数量 | %s |\n" "$rw_count"
        printf "| RO Property 数量 | %s |\n" "$ro_count"
        printf "| ObjectManager 数量 | %s |\n" "$objectmanager_count"
        printf "| GetAll 成功数量 | %s |\n" "$getall_success_count"
        printf "| Property 实际值数量 | %s |\n" "$property_values_count"
        printf "| Property 实际值成功数量 | %s |\n" "$property_values_success_count"
        printf "| 采集失败数量 | %s |\n" "$failure_count"
        printf "| 总耗时 | %s seconds |\n" "$elapsed"
    } > "$out_file"

    cp "$out_file" "${MARKDOWN_DIR}/summary.md" 2>/dev/null || :
}
