#!/bin/sh

# Property and ObjectManager collection.

access_to_perm() {
    case "$1" in
        readwrite) printf "RW\n" ;;
        read) printf "RO\n" ;;
        write) printf "WO\n" ;;
        readonly) printf "RO\n" ;;
        readwrite*) printf "RW\n" ;;
        *) printf "%s\n" "$1" ;;
    esac
}

parse_properties_tsv() {
    service=$1
    object_path=$2
    in_file=$3

    if grep -q '^[[:space:]]*interface ' "$in_file" 2>/dev/null; then
        awk -v service="$service" -v object_path="$object_path" '
            function perm(access) {
                if (access == "readwrite") return "RW"
                if (access == "readonly") return "RO"
                if (access == "read") return "RO"
                if (access == "write") return "WO"
                return access
            }
            /^[[:space:]]*interface / {
                iface=$2
                state=""
                next
            }
            /^[[:space:]]*properties:$/ { state="properties"; next }
            /^[[:space:]]*methods:$/ || /^[[:space:]]*signals:$/ || /^[[:space:]]*};/ { state=""; next }
            state=="properties" {
                line=$0
                sub(/^[[:space:]]*/, "", line)
                if (line == "") next
                split(line, parts, /[[:space:]]+/)
                access=parts[1]
                type=parts[2]
                name=parts[3]
                sub(/[;=].*$/, "", name)
                if (iface != "" && name != "") print service "\t" object_path "\t" iface "\t" name "\t" type "\t" perm(access) "\t" access "\t" line
            }
        ' "$in_file"
        return 0
    fi

    extract_xml "$in_file" | awk -v service="$service" -v object_path="$object_path" '
        function attr(line, name, value) {
            value=line
            sub("^.*" name "=\"", "", value)
            sub("\".*$", "", value)
            return value
        }
        function perm(access) {
            if (access == "readwrite") return "RW"
            if (access == "read") return "RO"
            if (access == "write") return "WO"
            return access
        }
        /<interface name="/ {
            iface=attr($0, "name")
        }
        /<property / {
            name=attr($0, "name")
            type=attr($0, "type")
            access=attr($0, "access")
            if (iface != "" && name != "") print service "\t" object_path "\t" iface "\t" name "\t" type "\t" perm(access) "\t" access "\t" $0
        }
    '
}

dbus_getall_raw() {
    service=$1
    object_path=$2
    props_iface=$3
    target_iface=$4
    out_file=$5
    err_file="${out_file}.err"

    if [ "$DBUS_TOOL" = "gdbus" ]; then
        run_cmd "GetAll $service $object_path $target_iface" "$out_file" "$err_file" \
            gdbus call "$(bus_arg_gdbus)" \
            --dest "$service" \
            --object-path "$object_path" \
            --method "$props_iface.GetAll" \
            "$target_iface"
        return $?
    fi

    run_cmd "GetAll $service $object_path $target_iface" "$out_file" "$err_file" \
        dbus-send "$(bus_arg_dbus_send)" \
        --print-reply=literal \
        --dest="$service" \
        "$object_path" \
        "$props_iface.GetAll" \
        string:"$target_iface"
}

dbus_get_raw() {
    service=$1
    object_path=$2
    props_iface=$3
    target_iface=$4
    prop_name=$5
    out_file=$6
    err_file="${out_file}.err"

    if [ "$DBUS_TOOL" = "gdbus" ]; then
        run_cmd "Get $service $object_path $target_iface.$prop_name" "$out_file" "$err_file" \
            gdbus call "$(bus_arg_gdbus)" \
            --dest "$service" \
            --object-path "$object_path" \
            --method "$props_iface.Get" \
            "$target_iface" \
            "$prop_name"
        return $?
    fi

    run_cmd "Get $service $object_path $target_iface.$prop_name" "$out_file" "$err_file" \
        dbus-send "$(bus_arg_dbus_send)" \
        --print-reply=literal \
        --dest="$service" \
        "$object_path" \
        "$props_iface.Get" \
        string:"$target_iface" \
        string:"$prop_name"
}

single_line_value() {
    file=$1
    if [ -f "$file" ]; then
        tr '\n' ' ' < "$file" | sed 's/[[:space:]][[:space:]]*/ /g; s/^ //; s/ $//'
    fi
}

extract_getall_property_value() {
    file=$1
    prop=$2

    [ -f "$file" ] || return 1

    # gdbus usually prints dictionaries as: {'Name': <'value'>, 'Enable': <true>}
    value=$(tr '\n' ' ' < "$file" | sed "s/[[:space:]][[:space:]]*/ /g" | sed -n "s/.*'$(printf "%s" "$prop" | sed 's/[].[^$\\*]/\\&/g')':[[:space:]]*<\\([^>]*\\)>.*/\\1/p")
    if [ -n "$value" ]; then
        printf "%s\n" "$value"
        return 0
    fi

    # Some dbus-send outputs include a string key followed by a variant value.
    awk -v prop="$prop" '
        $0 ~ "string \"" prop "\"" { found=1; next }
        found && $0 ~ /variant/ {
            line=$0
            sub(/^[[:space:]]*variant[[:space:]]*/, "", line)
            print line
            exit
        }
    ' "$file"
}

extract_get_property_value() {
    file=$1
    [ -f "$file" ] || return 1

    value=$(single_line_value "$file")
    value=$(printf "%s" "$value" | sed 's/^(\(.*\),)$/\1/; s/^<\(.*\)>$/\1/')
    [ -n "$value" ] || return 1
    printf "%s\n" "$value"
}

record_property_value() {
    service=$1
    object_path=$2
    iface=$3
    prop_name=$4
    prop_type=$5
    perm=$6
    access=$7
    status=$8
    value=$9
    raw_file=${10}
    source=${11}

    value=$(printf "%s" "$value" | sed 's/	/ /g; s/[[:cntrl:]]/ /g')

    printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
        "$service" "$object_path" "$iface" "$prop_name" "$prop_type" "$perm" "$access" "$status" "$value" "$raw_file" "$source" >> "$PROPERTIES_VALUES_TSV"
}

collect_single_property_value() {
    service=$1
    object_path=$2
    props_iface=$3
    iface=$4
    prop_name=$5
    prop_type=$6
    perm=$7
    access=$8
    out_dir=$9
    object_slug=${10}
    iface_slug=${11}

    prop_slug=$(safe_name_keep_root "$prop_name")
    out_file="${out_dir}/${object_slug}__${iface_slug}__${prop_slug}.Get.txt"

    if dbus_get_raw "$service" "$object_path" "$props_iface" "$iface" "$prop_name" "$out_file"; then
        value=$(extract_get_property_value "$out_file" || :)
        [ -n "$value" ] || value=$(single_line_value "$out_file")
        record_property_value "$service" "$object_path" "$iface" "$prop_name" "$prop_type" "$perm" "$access" "ok" "$value" "$out_file" "Get"
        return 0
    fi

    record_property_value "$service" "$object_path" "$iface" "$prop_name" "$prop_type" "$perm" "$access" "failed" "" "$out_file" "Get"
    record_failure "$service" "$object_path" "Get:$iface.$prop_name" "command failed"
    return 1
}

dbus_getmanagedobjects_raw() {
    service=$1
    object_path=$2
    objmgr_iface=$3
    out_file=$4
    err_file="${out_file}.err"

    if [ "$DBUS_TOOL" = "gdbus" ]; then
        run_cmd "GetManagedObjects $service $object_path" "$out_file" "$err_file" \
            gdbus call "$(bus_arg_gdbus)" \
            --dest "$service" \
            --object-path "$object_path" \
            --method "$objmgr_iface.GetManagedObjects"
        return $?
    fi

    run_cmd "GetManagedObjects $service $object_path" "$out_file" "$err_file" \
        dbus-send "$(bus_arg_dbus_send)" \
        --print-reply=literal \
        --dest="$service" \
        "$object_path" \
        "$objmgr_iface.GetManagedObjects"
}

collect_object_properties() {
    service=$1
    object_path=$2
    raw_file=$3
    interfaces_file=$4
    props_iface=$5

    [ -n "$raw_file" ] || return 0
    [ -n "$props_iface" ] || return 0
    [ -s "$interfaces_file" ] || return 0

    service_slug=$(safe_name_keep_root "$service")
    object_slug=$(safe_name_keep_root "$object_path")
    out_dir="${RAW_DIR}/properties/${service_slug}"
    ensure_dir "$out_dir"

    while IFS= read -r iface; do
        [ -n "$iface" ] || continue
        if is_standard_iface "$iface"; then
            continue
        fi

        iface_slug=$(safe_name_keep_root "$iface")
        out_file="${out_dir}/${object_slug}__${iface_slug}.GetAll.txt"
        progress "    GetAll: $iface"
        if dbus_getall_raw "$service" "$object_path" "$props_iface" "$iface" "$out_file"; then
            printf "%s\t%s\t%s\tok\t%s\n" "$service" "$object_path" "$iface" "$out_file" >> "$GETALL_TSV"
            progress "    GetAll ok: $iface raw=$out_file"
            getall_ok=1
        else
            printf "%s\t%s\t%s\tfailed\t%s\n" "$service" "$object_path" "$iface" "$out_file" >> "$GETALL_TSV"
            record_failure "$service" "$object_path" "GetAll:$iface" "command failed"
            getall_ok=0
        fi

        awk -F '\t' -v s="$service" -v o="$object_path" -v i="$iface" '
            $1 == s && $2 == o && $3 == i { print $4 "\t" $5 "\t" $6 "\t" $7 }
        ' "$PROPERTIES_TSV" | while IFS='	' read -r prop_name prop_type perm access; do
            [ -n "$prop_name" ] || continue
            value=""
            if [ "$getall_ok" -eq 1 ]; then
                value=$(extract_getall_property_value "$out_file" "$prop_name" || :)
            fi
            if [ -n "$value" ]; then
                record_property_value "$service" "$object_path" "$iface" "$prop_name" "$prop_type" "$perm" "$access" "ok" "$value" "$out_file" "GetAll"
            else
                collect_single_property_value "$service" "$object_path" "$props_iface" "$iface" "$prop_name" "$prop_type" "$perm" "$access" "$out_dir" "$object_slug" "$iface_slug" || :
            fi
        done
    done < "$interfaces_file"
}

collect_object_manager() {
    service=$1
    object_path=$2
    objmgr_iface=$3

    [ -n "$objmgr_iface" ] || return 0

    service_slug=$(safe_name_keep_root "$service")
    object_slug=$(safe_name_keep_root "$object_path")
    out_dir="${RAW_DIR}/managed-objects/${service_slug}"
    ensure_dir "$out_dir"
    out_file="${out_dir}/${object_slug}.GetManagedObjects.txt"

    progress "    GetManagedObjects: $objmgr_iface"
    if dbus_getmanagedobjects_raw "$service" "$object_path" "$objmgr_iface" "$out_file"; then
        printf "%s\t%s\t%s\tok\t%s\n" "$service" "$object_path" "$objmgr_iface" "$out_file" >> "$MANAGED_TSV"
        progress "    GetManagedObjects ok: raw=$out_file"
    else
        printf "%s\t%s\t%s\tfailed\t%s\n" "$service" "$object_path" "$objmgr_iface" "$out_file" >> "$MANAGED_TSV"
        record_failure "$service" "$object_path" "GetManagedObjects" "command failed"
    fi
}
