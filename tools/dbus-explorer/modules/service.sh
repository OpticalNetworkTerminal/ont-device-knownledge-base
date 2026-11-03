#!/bin/sh

# Service discovery.

dbus_list_services_raw() {
    out_file=$1
    err_file="${out_file}.err"

    if [ "$DBUS_TOOL" = "gdbus" ]; then
        run_cmd "ListNames" "$out_file" "$err_file" \
            gdbus call "$(bus_arg_gdbus)" \
            --dest org.freedesktop.DBus \
            --object-path /org/freedesktop/DBus \
            --method org.freedesktop.DBus.ListNames
        return $?
    fi

    run_cmd "ListNames" "$out_file" "$err_file" \
        dbus-send "$(bus_arg_dbus_send)" \
        --print-reply=literal \
        --dest=org.freedesktop.DBus \
        /org/freedesktop/DBus \
        org.freedesktop.DBus.ListNames
}

parse_services() {
    in_file=$1

    if grep -q "'" "$in_file" 2>/dev/null; then
        grep -o "'[^']*'" "$in_file" | tr -d "'" | sed '/^$/d'
        return 0
    fi

    if grep -q 'string "' "$in_file" 2>/dev/null; then
        sed -n 's/^[[:space:]]*string "\(.*\)"$/\1/p' "$in_file" | sed '/^$/d'
        return 0
    fi

    grep -o '"[^"]*"' "$in_file" 2>/dev/null | tr -d '"' | sed '/^$/d'
}

discover_services() {
    raw_file="${RAW_DIR}/services/ListNames.raw.txt"

    if ! dbus_list_services_raw "$raw_file"; then
        record_failure "org.freedesktop.DBus" "/org/freedesktop/DBus" "ListNames" "command failed"
        return 1
    fi

    parse_services "$raw_file" | sed '/^:/d; /^$/d' | sort -u > "$SERVICES_FILE"
    cp "$SERVICES_FILE" "${STATE_DIR}/services.txt" 2>/dev/null || :
    progress "ListNames raw output: $raw_file"

    if [ ! -s "$SERVICES_FILE" ]; then
        record_failure "org.freedesktop.DBus" "/org/freedesktop/DBus" "ListNames" "no services parsed"
        return 1
    fi

    return 0
}
