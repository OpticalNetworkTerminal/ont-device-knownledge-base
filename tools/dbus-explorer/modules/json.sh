#!/bin/sh

# JSON renderers. They intentionally emit compact indexes and keep full raw
# command output in raw/*.txt files.

render_services_json() {
    out_file="${JSON_DIR}/services.json"
    {
        printf "[\n"
        first=1
        while IFS= read -r service; do
            [ -n "$service" ] || continue
            if [ "$first" -eq 0 ]; then
                printf ",\n"
            fi
            first=0
            printf "  {\"service\": "
            json_string "$service"
            printf "}"
        done < "$SERVICES_FILE"
        printf "\n]\n"
    } > "$out_file"
}

render_objects_json() {
    out_file="${JSON_DIR}/objects.json"
    {
        printf "[\n"
        awk -F '\t' '
            BEGIN { first=1 }
            {
                gsub(/\\/,"\\\\",$1); gsub(/"/,"\\\"",$1)
                gsub(/\\/,"\\\\",$2); gsub(/"/,"\\\"",$2)
                gsub(/\\/,"\\\\",$3); gsub(/"/,"\\\"",$3)
                gsub(/\\/,"\\\\",$4); gsub(/"/,"\\\"",$4)
                if (!first) printf ",\n"
                first=0
                printf "  {\"service\":\"%s\",\"object\":\"%s\",\"status\":\"%s\",\"raw_file\":\"%s\"}", $1, $2, $3, $4
            }
            END { printf "\n" }
        ' "$OBJECTS_TSV"
        printf "]\n"
    } > "$out_file"
}

render_tree_json() {
    out_file="${JSON_DIR}/tree.json"
    {
        printf "[\n"
        awk -F '\t' '
            BEGIN { first=1 }
            {
                s=$1; o=$2
                gsub(/\\/,"\\\\",s); gsub(/"/,"\\\"",s)
                gsub(/\\/,"\\\\",o); gsub(/"/,"\\\"",o)
                if (!first) printf ",\n"
                first=0
                printf "  {\"service\":\"%s\",\"object\":\"%s\"}", s, o
            }
            END { printf "\n" }
        ' "$TREE_TSV"
        printf "]\n"
    } > "$out_file"
}

render_interfaces_json() {
    out_file="${JSON_DIR}/interfaces.json"
    {
        printf "[\n"
        awk -F '\t' '
            BEGIN { first=1 }
            {
                s=$1; o=$2; i=$3
                gsub(/\\/,"\\\\",s); gsub(/"/,"\\\"",s)
                gsub(/\\/,"\\\\",o); gsub(/"/,"\\\"",o)
                gsub(/\\/,"\\\\",i); gsub(/"/,"\\\"",i)
                if (!first) printf ",\n"
                first=0
                printf "  {\"service\":\"%s\",\"object\":\"%s\",\"interface\":\"%s\"}", s, o, i
            }
            END { printf "\n" }
        ' "$INTERFACES_TSV"
        printf "]\n"
    } > "$out_file"
}

render_members_json() {
    in_file=$1
    out_file=$2
    key=$3
    {
        printf "[\n"
        awk -F '\t' -v key="$key" '
            BEGIN { first=1 }
            {
                s=$1; o=$2; i=$3; n=$4; sig=$5
                gsub(/\\/,"\\\\",s); gsub(/"/,"\\\"",s)
                gsub(/\\/,"\\\\",o); gsub(/"/,"\\\"",o)
                gsub(/\\/,"\\\\",i); gsub(/"/,"\\\"",i)
                gsub(/\\/,"\\\\",n); gsub(/"/,"\\\"",n)
                gsub(/\\/,"\\\\",sig); gsub(/"/,"\\\"",sig)
                if (!first) printf ",\n"
                first=0
                printf "  {\"service\":\"%s\",\"object\":\"%s\",\"interface\":\"%s\",\"%s\":\"%s\",\"signature\":\"%s\"}", s, o, i, key, n, sig
            }
            END { printf "\n" }
        ' "$in_file"
        printf "]\n"
    } > "$out_file"
}

render_properties_json() {
    out_file="${JSON_DIR}/properties.json"
    {
        printf "[\n"
        awk -F '\t' '
            BEGIN { first=1 }
            {
                s=$1; o=$2; i=$3; n=$4; t=$5; p=$6; a=$7; raw=$8
                gsub(/\\/,"\\\\",s); gsub(/"/,"\\\"",s)
                gsub(/\\/,"\\\\",o); gsub(/"/,"\\\"",o)
                gsub(/\\/,"\\\\",i); gsub(/"/,"\\\"",i)
                gsub(/\\/,"\\\\",n); gsub(/"/,"\\\"",n)
                gsub(/\\/,"\\\\",t); gsub(/"/,"\\\"",t)
                gsub(/\\/,"\\\\",p); gsub(/"/,"\\\"",p)
                gsub(/\\/,"\\\\",a); gsub(/"/,"\\\"",a)
                gsub(/\\/,"\\\\",raw); gsub(/"/,"\\\"",raw)
                if (!first) printf ",\n"
                first=0
                printf "  {\"service\":\"%s\",\"object\":\"%s\",\"interface\":\"%s\",\"property\":\"%s\",\"type\":\"%s\",\"permission\":\"%s\",\"access\":\"%s\",\"raw\":\"%s\"}", s, o, i, n, t, p, a, raw
            }
            END { printf "\n" }
        ' "$PROPERTIES_TSV"
        printf "]\n"
    } > "$out_file"
}

render_property_values_json() {
    out_file="${JSON_DIR}/properties-values.json"
    {
        printf "[\n"
        awk -F '\t' '
            BEGIN { first=1 }
            {
                s=$1; o=$2; i=$3; n=$4; t=$5; p=$6; a=$7; st=$8; v=$9; f=$10; src=$11
                gsub(/\\/,"\\\\",s); gsub(/"/,"\\\"",s)
                gsub(/\\/,"\\\\",o); gsub(/"/,"\\\"",o)
                gsub(/\\/,"\\\\",i); gsub(/"/,"\\\"",i)
                gsub(/\\/,"\\\\",n); gsub(/"/,"\\\"",n)
                gsub(/\\/,"\\\\",t); gsub(/"/,"\\\"",t)
                gsub(/\\/,"\\\\",p); gsub(/"/,"\\\"",p)
                gsub(/\\/,"\\\\",a); gsub(/"/,"\\\"",a)
                gsub(/\\/,"\\\\",st); gsub(/"/,"\\\"",st)
                gsub(/\\/,"\\\\",v); gsub(/"/,"\\\"",v)
                gsub(/\\/,"\\\\",f); gsub(/"/,"\\\"",f)
                gsub(/\\/,"\\\\",src); gsub(/"/,"\\\"",src)
                if (!first) printf ",\n"
                first=0
                printf "  {\"service\":\"%s\",\"object\":\"%s\",\"interface\":\"%s\",\"property\":\"%s\",\"type\":\"%s\",\"permission\":\"%s\",\"access\":\"%s\",\"status\":\"%s\",\"value\":\"%s\",\"raw_file\":\"%s\",\"source\":\"%s\"}", s, o, i, n, t, p, a, st, v, f, src
            }
            END { printf "\n" }
        ' "$PROPERTIES_VALUES_TSV"
        printf "]\n"
    } > "$out_file"
}

render_call_results_json() {
    in_file=$1
    out_file=$2
    field_name=$3
    {
        printf "[\n"
        awk -F '\t' -v field_name="$field_name" '
            BEGIN { first=1 }
            {
                s=$1; o=$2; i=$3; st=$4; f=$5
                gsub(/\\/,"\\\\",s); gsub(/"/,"\\\"",s)
                gsub(/\\/,"\\\\",o); gsub(/"/,"\\\"",o)
                gsub(/\\/,"\\\\",i); gsub(/"/,"\\\"",i)
                gsub(/\\/,"\\\\",st); gsub(/"/,"\\\"",st)
                gsub(/\\/,"\\\\",f); gsub(/"/,"\\\"",f)
                if (!first) printf ",\n"
                first=0
                printf "  {\"service\":\"%s\",\"object\":\"%s\",\"%s\":\"%s\",\"status\":\"%s\",\"raw_file\":\"%s\"}", s, o, field_name, i, st, f
            }
            END { printf "\n" }
        ' "$in_file"
        printf "]\n"
    } > "$out_file"
}

render_summary_json() {
    out_file="${JSON_DIR}/summary.json"
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
        printf "{\n"
        printf "  \"tool\": \"%s\",\n" "$(json_escape "$DBUS_TOOL")"
        printf "  \"bus\": \"%s\",\n" "$(json_escape "$BUS_TYPE")"
        printf "  \"services\": %s,\n" "$service_count"
        printf "  \"objects\": %s,\n" "$object_count"
        printf "  \"interfaces\": %s,\n" "$interface_count"
        printf "  \"methods\": %s,\n" "$method_count"
        printf "  \"properties\": %s,\n" "$property_count"
        printf "  \"signals\": %s,\n" "$signal_count"
        printf "  \"rw_properties\": %s,\n" "$rw_count"
        printf "  \"ro_properties\": %s,\n" "$ro_count"
        printf "  \"objectmanagers\": %s,\n" "$objectmanager_count"
        printf "  \"getall_success\": %s,\n" "$getall_success_count"
        printf "  \"property_values\": %s,\n" "$property_values_count"
        printf "  \"property_values_success\": %s,\n" "$property_values_success_count"
        printf "  \"failures\": %s,\n" "$failure_count"
        printf "  \"elapsed_seconds\": %s\n" "$elapsed"
        printf "}\n"
    } > "$out_file"
}

render_all_json() {
    render_services_json
    render_objects_json
    render_tree_json
    render_interfaces_json
    render_members_json "$METHODS_TSV" "${JSON_DIR}/methods.json" "method"
    render_members_json "$SIGNALS_TSV" "${JSON_DIR}/signals.json" "signal"
    render_properties_json
    render_property_values_json
    render_call_results_json "$GETALL_TSV" "${JSON_DIR}/getall.json" "interface"
    render_call_results_json "$MANAGED_TSV" "${JSON_DIR}/managed-objects.json" "interface"
    render_summary_json
}
