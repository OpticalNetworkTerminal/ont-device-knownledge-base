#!/bin/sh

# Object traversal and introspection parsing.

dbus_introspect_raw() {
    service=$1
    object_path=$2
    out_file=$3
    err_file="${out_file}.err"

    if [ "$DBUS_TOOL" = "gdbus" ]; then
        run_cmd "Introspect $service $object_path" "$out_file" "$err_file" \
            gdbus introspect "$(bus_arg_gdbus)" \
            --dest "$service" \
            --object-path "$object_path"
        return $?
    fi

    run_cmd "Introspect $service $object_path" "$out_file" "$err_file" \
        dbus-send "$(bus_arg_dbus_send)" \
        --print-reply=literal \
        --dest="$service" \
        "$object_path" \
        org.freedesktop.DBus.Introspectable.Introspect
}

extract_xml() {
    in_file=$1

    if grep -q '<node' "$in_file" 2>/dev/null; then
        sed -n '/<node/,/<\/node>/p' "$in_file"
        return 0
    fi

    sed -n 's/.*\(<node.*<\/node>\).*/\1/p' "$in_file"
}

parse_interfaces() {
    in_file=$1

    if grep -q '^[[:space:]]*interface ' "$in_file" 2>/dev/null; then
        sed -n 's/^[[:space:]]*interface[[:space:]]\([^[:space:]]*\)[[:space:]]*{.*/\1/p' "$in_file"
        return 0
    fi

    extract_xml "$in_file" | sed -n 's/.*<interface name="\([^"]*\)".*/\1/p'
}

parse_children() {
    in_file=$1

    if grep -q '^[[:space:]]*node ' "$in_file" 2>/dev/null; then
        awk '
            /^[[:space:]]*node[[:space:]]/ {
                name=$2
                if (name !~ /^\// && name != "") print name
            }
        ' "$in_file"
        return 0
    fi

    extract_xml "$in_file" | sed -n 's/.*<node name="\([^"]*\)".*/\1/p'
}

parse_methods_tsv() {
    service=$1
    object_path=$2
    in_file=$3

    if grep -q '^[[:space:]]*interface ' "$in_file" 2>/dev/null; then
        awk -v service="$service" -v object_path="$object_path" '
            /^[[:space:]]*interface / {
                iface=$2
                state=""
                next
            }
            /^[[:space:]]*methods:$/ { state="methods"; next }
            /^[[:space:]]*signals:$/ || /^[[:space:]]*properties:$/ || /^[[:space:]]*};/ { state=""; next }
            state=="methods" && $0 ~ /\(/ {
                line=$0
                sub(/^[[:space:]]*/, "", line)
                name=line
                sub(/\(.*/, "", name)
                if (iface != "" && name != "") print service "\t" object_path "\t" iface "\t" name "\t" line
            }
        ' "$in_file"
        return 0
    fi

    extract_xml "$in_file" | awk -v service="$service" -v object_path="$object_path" '
        /<interface name="/ {
            line=$0
            sub(/^.*<interface name="/, "", line)
            sub(/".*$/, "", line)
            iface=line
        }
        /<method name="/ {
            line=$0
            sub(/^.*<method name="/, "", line)
            sub(/".*$/, "", line)
            if (iface != "" && line != "") print service "\t" object_path "\t" iface "\t" line "\t" line
        }
    '
}

parse_signals_tsv() {
    service=$1
    object_path=$2
    in_file=$3

    if grep -q '^[[:space:]]*interface ' "$in_file" 2>/dev/null; then
        awk -v service="$service" -v object_path="$object_path" '
            /^[[:space:]]*interface / {
                iface=$2
                state=""
                next
            }
            /^[[:space:]]*signals:$/ { state="signals"; next }
            /^[[:space:]]*methods:$/ || /^[[:space:]]*properties:$/ || /^[[:space:]]*};/ { state=""; next }
            state=="signals" && $0 ~ /\(/ {
                line=$0
                sub(/^[[:space:]]*/, "", line)
                name=line
                sub(/\(.*/, "", name)
                if (iface != "" && name != "") print service "\t" object_path "\t" iface "\t" name "\t" line
            }
        ' "$in_file"
        return 0
    fi

    extract_xml "$in_file" | awk -v service="$service" -v object_path="$object_path" '
        /<interface name="/ {
            line=$0
            sub(/^.*<interface name="/, "", line)
            sub(/".*$/, "", line)
            iface=line
        }
        /<signal name="/ {
            line=$0
            sub(/^.*<signal name="/, "", line)
            sub(/".*$/, "", line)
            if (iface != "" && line != "") print service "\t" object_path "\t" iface "\t" line "\t" line
        }
    '
}

detect_properties_iface() {
    in_file=$1
    parse_interfaces "$in_file" | awk '
        /\.Properties$/ && $0 != "org.freedesktop.DBus.Properties" { print; found=1; exit }
        $0 == "org.freedesktop.DBus.Properties" { standard=$0 }
        END { if (!found && standard != "") print standard }
    '
}

detect_objectmanager_iface() {
    in_file=$1
    parse_interfaces "$in_file" | awk '
        /\.ObjectManager$/ && $0 != "org.freedesktop.DBus.ObjectManager" { print; found=1; exit }
        $0 == "org.freedesktop.DBus.ObjectManager" { standard=$0 }
        END { if (!found && standard != "") print standard }
    '
}

is_standard_iface() {
    case "$1" in
        org.freedesktop.DBus.Introspectable|org.freedesktop.DBus.Peer|*.Properties|*.ObjectManager)
            return 0
            ;;
    esac
    return 1
}

walk_service_objects() {
    service=$1
    service_slug=$(safe_name_keep_root "$service")
    queue="${STATE_DIR}/${service_slug}.queue"
    queued="${STATE_DIR}/${service_slug}.queued"
    object_index=0

    : > "$queue"
    : > "$queued"
    printf "/\n" >> "$queue"
    printf "/\n" >> "$queued"

    while :; do
        object_path=$(awk 'NR==1 { print; exit }' "$queue")
        [ -n "$object_path" ] || break
        sed '1d' "$queue" > "${queue}.tmp" && mv "${queue}.tmp" "$queue"

        visit_key="${service}|${object_path}"
        if grep -Fqx "$visit_key" "$VISITED_FILE" 2>/dev/null; then
            continue
        fi
        printf "%s\n" "$visit_key" >> "$VISITED_FILE"

        object_index=$((object_index + 1))
        progress "  Object $object_index: $service $object_path"
        collect_object "$service" "$object_path" "$queue" "$queued"
    done
}

collect_object() {
    service=$1
    object_path=$2
    queue=$3
    queued=$4

    service_slug=$(safe_name_keep_root "$service")
    object_slug=$(safe_name_keep_root "$object_path")
    object_raw_dir="${RAW_DIR}/objects/${service_slug}"
    ensure_dir "$object_raw_dir"

    raw_file="${object_raw_dir}/${object_slug}.introspect.txt"
    if ! dbus_introspect_raw "$service" "$object_path" "$raw_file"; then
        record_failure "$service" "$object_path" "Introspect" "command failed"
        printf "%s\t%s\tfailed\t%s\n" "$service" "$object_path" "$raw_file" >> "$OBJECTS_TSV"
        render_object_markdown "$service" "$object_path" "$raw_file" "" "" ""
        return 0
    fi

    printf "%s\t%s\tok\t%s\n" "$service" "$object_path" "$raw_file" >> "$OBJECTS_TSV"
    printf "%s\t%s\n" "$service" "$object_path" >> "$TREE_TSV"

    interfaces_file="${STATE_DIR}/${service_slug}.${object_slug}.interfaces"
    children_file="${STATE_DIR}/${service_slug}.${object_slug}.children"

    parse_interfaces "$raw_file" | sed '/^$/d' | sort -u > "$interfaces_file"
    parse_children "$raw_file" | sed '/^$/d' | sort -u > "$children_file"
    iface_count=$(count_lines "$interfaces_file")
    child_count=$(count_lines "$children_file")
    progress "    Introspect ok: interfaces=$iface_count children=$child_count raw=$raw_file"

    while IFS= read -r iface; do
        [ -n "$iface" ] || continue
        printf "%s\t%s\t%s\n" "$service" "$object_path" "$iface" >> "$INTERFACES_TSV"
    done < "$interfaces_file"

    parse_methods_tsv "$service" "$object_path" "$raw_file" >> "$METHODS_TSV"
    parse_signals_tsv "$service" "$object_path" "$raw_file" >> "$SIGNALS_TSV"
    parse_properties_tsv "$service" "$object_path" "$raw_file" >> "$PROPERTIES_TSV"

    props_iface=$(detect_properties_iface "$raw_file" || :)
    objmgr_iface=$(detect_objectmanager_iface "$raw_file" || :)

    collect_object_properties "$service" "$object_path" "$raw_file" "$interfaces_file" "$props_iface"
    collect_object_manager "$service" "$object_path" "$objmgr_iface"

    render_object_markdown "$service" "$object_path" "$raw_file" "$interfaces_file" "$children_file" "$props_iface"
    plugin_after_object "$service" "$object_path" "$raw_file"

    while IFS= read -r child; do
        [ -n "$child" ] || continue
        child_path=$(join_object_path "$object_path" "$child")
        if ! grep -Fqx "$child_path" "$queued" 2>/dev/null; then
            printf "%s\n" "$child_path" >> "$queue"
            printf "%s\n" "$child_path" >> "$queued"
        fi
    done < "$children_file"
}
