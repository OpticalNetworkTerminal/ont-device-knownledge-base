#!/bin/sh

# DBus operations and parsers.

dbus_detect_tool() {
    if has_cmd gdbus; then
        DBUS_TOOL="gdbus"
        return 0
    fi

    if has_cmd dbus-send; then
        DBUS_TOOL="dbus-send"
        return 0
    fi

    DBUS_TOOL=""
    return 1
}

dbus_extract_xml() {
    in_file="$1"

    if grep -q '<node' "$in_file" 2>/dev/null; then
        sed -n '/<node/,/<\/node>/p' "$in_file"
        return 0
    fi

    # Fallback for outputs where the XML is quoted on a single line.
    sed -n 's/.*\(<node.*<\/node>\).*/\1/p' "$in_file"
}

dbus_list_services_raw() {
    out_file="$1"

    if [ "$DBUS_TOOL" = "gdbus" ]; then
        run_capture "$out_file" \
            gdbus call \
            --system \
            --dest org.freedesktop.DBus \
            --object-path /org/freedesktop/DBus \
            --method org.freedesktop.DBus.ListNames
        return $?
    fi

    run_capture "$out_file" \
        dbus-send \
        --system \
        --print-reply=literal \
        --dest=org.freedesktop.DBus \
        /org/freedesktop/DBus \
        org.freedesktop.DBus.ListNames
}

dbus_parse_services() {
    in_file="$1"

    if grep -q "'" "$in_file" 2>/dev/null; then
        grep -o "'[^']*'" "$in_file" | tr -d "'" | sed '/^$/d'
        return 0
    fi

    if grep -q 'string "' "$in_file" 2>/dev/null; then
        sed -n 's/^[[:space:]]*string "\(.*\)"$/\1/p' "$in_file"
        return 0
    fi

    grep -o '"[^"]*"' "$in_file" 2>/dev/null | tr -d '"' | sed '/^$/d'
}

dbus_introspect_raw() {
    service="$1"
    object_path="$2"
    out_file="$3"

    if [ "$DBUS_TOOL" = "gdbus" ]; then
        run_capture "$out_file" \
            gdbus introspect \
            --system \
            --dest "$service" \
            --object-path "$object_path"
        return $?
    fi

    run_capture "$out_file" \
        dbus-send \
        --system \
        --print-reply=literal \
        --dest="$service" \
        "$object_path" \
        org.freedesktop.DBus.Introspectable.Introspect
}

dbus_parse_interfaces() {
    in_file="$1"

    if grep -q '^[[:space:]]*interface ' "$in_file" 2>/dev/null; then
        sed -n 's/^[[:space:]]*interface[[:space:]]\([^[:space:]]*\)[[:space:]]*{.*/\1/p' "$in_file"
        return 0
    fi

    dbus_extract_xml "$in_file" | sed -n 's/.*<interface name="\([^"]*\)".*/\1/p'
}

dbus_parse_children() {
    in_file="$1"

    if grep -q '^[[:space:]]*node ' "$in_file" 2>/dev/null; then
        sed -n 's/^[[:space:]]*node[[:space:]]\([^[:space:]]*\)[[:space:]]*{.*/\1/p' "$in_file"
        return 0
    fi

    dbus_extract_xml "$in_file" | sed -n 's/.*<node name="\([^"]*\)".*/\1/p'
}

dbus_parse_methods() {
    in_file="$1"

    if grep -q '^[[:space:]]*methods:' "$in_file" 2>/dev/null; then
        awk '
            /^[[:space:]]*methods:$/ {state="methods"; next}
            /^[[:space:]]*signals:$/ {state=""; next}
            /^[[:space:]]*properties:$/ {state=""; next}
            /^[[:space:]]*interface / {state=""; next}
            /^[[:space:]]*node / {state=""; next}
            state=="methods" && $0 ~ /\(/ {
                line=$0
                sub(/^[[:space:]]*/, "", line)
                sub(/\(.*/, "", line)
                if (line != "") print line
            }
        ' "$in_file"
        return 0
    fi

    dbus_extract_xml "$in_file" | sed -n 's/.*<method name="\([^"]*\)".*/\1/p'
}

dbus_parse_signals() {
    in_file="$1"

    if grep -q '^[[:space:]]*signals:' "$in_file" 2>/dev/null; then
        awk '
            /^[[:space:]]*signals:$/ {state="signals"; next}
            /^[[:space:]]*properties:$/ {state=""; next}
            /^[[:space:]]*methods:$/ {state=""; next}
            /^[[:space:]]*interface / {state=""; next}
            /^[[:space:]]*node / {state=""; next}
            state=="signals" && $0 ~ /\(/ {
                line=$0
                sub(/^[[:space:]]*/, "", line)
                sub(/\(.*/, "", line)
                if (line != "") print line
            }
        ' "$in_file"
        return 0
    fi

    dbus_extract_xml "$in_file" | sed -n 's/.*<signal name="\([^"]*\)".*/\1/p'
}

dbus_parse_properties() {
    in_file="$1"

    if grep -q '^[[:space:]]*properties:' "$in_file" 2>/dev/null; then
        awk '
            /^[[:space:]]*properties:$/ {state="properties"; next}
            /^[[:space:]]*methods:$/ {state=""; next}
            /^[[:space:]]*signals:$/ {state=""; next}
            /^[[:space:]]*interface / {state=""; next}
            /^[[:space:]]*node / {state=""; next}
            state=="properties" {
                line=$0
                sub(/^[[:space:]]*/, "", line)
                if (line != "") print line
            }
        ' "$in_file"
        return 0
    fi

    dbus_extract_xml "$in_file" | sed -n 's/.*<property name="\([^"]*\)".*/\1/p'
}

dbus_detect_properties_iface() {
    in_file="$1"
    dbus_parse_interfaces "$in_file" | awk '
        /(^|[.])Properties$/ { print; exit }
        $0 == "org.freedesktop.DBus.Properties" { print; exit }
    '
}

dbus_detect_objectmanager_iface() {
    in_file="$1"
    dbus_parse_interfaces "$in_file" | awk '
        /(^|[.])ObjectManager$/ { print; exit }
        $0 == "org.freedesktop.DBus.ObjectManager" { print; exit }
    '
}

dbus_should_skip_getall_iface() {
    iface="$1"
    props_iface="$2"
    objmgr_iface="$3"

    case "$iface" in
        "$props_iface"|"$objmgr_iface"|org.freedesktop.DBus.Introspectable|org.freedesktop.DBus.Peer)
            return 0
            ;;
    esac

    return 1
}

dbus_getall_raw() {
    service="$1"
    object_path="$2"
    props_iface="$3"
    target_iface="$4"
    out_file="$5"

    if [ "$DBUS_TOOL" = "gdbus" ]; then
        run_capture "$out_file" \
            gdbus call \
            --system \
            --dest "$service" \
            --object-path "$object_path" \
            --method "$props_iface.GetAll" \
            "$target_iface"
        return $?
    fi

    run_capture "$out_file" \
        dbus-send \
        --system \
        --print-reply=literal \
        --dest="$service" \
        "$object_path" \
        "$props_iface.GetAll" \
        string:"$target_iface"
}

dbus_getmanagedobjects_raw() {
    service="$1"
    object_path="$2"
    objmgr_iface="$3"
    out_file="$4"

    if [ "$DBUS_TOOL" = "gdbus" ]; then
        run_capture "$out_file" \
            gdbus call \
            --system \
            --dest "$service" \
            --object-path "$object_path" \
            --method "$objmgr_iface.GetManagedObjects"
        return $?
    fi

    run_capture "$out_file" \
        dbus-send \
        --system \
        --print-reply=literal \
        --dest="$service" \
        "$object_path" \
        "$objmgr_iface.GetManagedObjects"
}
