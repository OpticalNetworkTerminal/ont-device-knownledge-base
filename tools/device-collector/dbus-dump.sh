#!/bin/sh

set -u

case "$0" in
    */*) _script_path=${0%/*} ;;
    *) _script_path=. ;;
esac
SCRIPT_DIR=$(CDPATH= cd -- "$_script_path" 2>/dev/null && pwd)
unset _script_path

. "$SCRIPT_DIR/lib/common.sh"
. "$SCRIPT_DIR/lib/dbus.sh"
. "$SCRIPT_DIR/lib/output.sh"

OUT_DIR="dbus"
SERVICE_FILTER=""
DBUS_DUMP_TIMEOUT="${DBUS_DUMP_TIMEOUT:-3}"

usage() {
    cat <<EOF
Usage: sh ./dbus-dump.sh [-o output_dir] [-s service1,service2]

Options:
  -o DIR     Output directory. Default: dbus
  -s LIST    Comma-separated service filter
  -h         Show this help
EOF
}

while getopts "o:s:h" opt; do
    case "$opt" in
        o) OUT_DIR="$OPTARG" ;;
        s) SERVICE_FILTER="$OPTARG" ;;
        h)
            usage
            exit 0
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done

ensure_dir "$OUT_DIR"
ensure_dir "$OUT_DIR/logs"
ensure_dir "$OUT_DIR/services"
ensure_dir "$OUT_DIR/.state"

RUN_LOG="$OUT_DIR/logs/run.log"
ERROR_LOG="$OUT_DIR/logs/error.log"
: >"$RUN_LOG"
: >"$ERROR_LOG"

if has_cmd timeout; then
    TIMEOUT_CMD="timeout"
else
    TIMEOUT_CMD=""
fi

SERVICES_FILE="$OUT_DIR/services.txt"
VISITED_FILE="$OUT_DIR/.state/visited.txt"
SERVICE_LIST_FILE="$OUT_DIR/.state/services-collected.txt"
INTERFACES_GLOBAL="$OUT_DIR/.state/interfaces.txt"
METHODS_GLOBAL="$OUT_DIR/.state/methods.txt"
SIGNALS_GLOBAL="$OUT_DIR/.state/signals.txt"
PROPERTIES_GLOBAL="$OUT_DIR/.state/properties.txt"
OBJECTMANAGER_GLOBAL="$OUT_DIR/.state/objectmanagers.txt"
GETALL_GLOBAL="$OUT_DIR/.state/getall.txt"

: >"$SERVICES_FILE"
: >"$VISITED_FILE"
: >"$SERVICE_LIST_FILE"
: >"$INTERFACES_GLOBAL"
: >"$METHODS_GLOBAL"
: >"$SIGNALS_GLOBAL"
: >"$PROPERTIES_GLOBAL"
: >"$OBJECTMANAGER_GLOBAL"
: >"$GETALL_GLOBAL"

render_collector_readme "$OUT_DIR"

if ! dbus_detect_tool; then
    log_error "Neither gdbus nor dbus-send was found"
    render_summary_md "$OUT_DIR/summary.md" "none" 0 0 0 0 0 0 0 0 1
    echo "No usable DBus client found. See $ERROR_LOG"
    exit 0
fi

log_run "Using DBus tool: $DBUS_TOOL"

join_path() {
    parent="$1"
    child="$2"

    case "$parent" in
        /) echo "/$child" ;;
        *) echo "$parent/$child" ;;
    esac
}

should_collect_service() {
    service="$1"

    if [ -z "$SERVICE_FILTER" ]; then
        return 0
    fi

    echo ",$SERVICE_FILTER," | grep -F ",$service," >/dev/null 2>&1
}

record_parsed_items() {
    service="$1"
    object_path="$2"
    list_file="$3"
    global_file="$4"

    if [ -s "$list_file" ]; then
        while IFS= read -r item; do
            [ -n "$item" ] || continue
            append_unique_line "$global_file" "$service|$object_path|$item"
        done <"$list_file"
    fi
}

walk_object() {
    service="$1"
    object_path="$2"

    visit_key="$service|$object_path"
    if grep -Fqx "$visit_key" "$VISITED_FILE" 2>/dev/null; then
        return 0
    fi
    printf '%s\n' "$visit_key" >>"$VISITED_FILE"

    service_slug=$(safe_name "$service")
    object_slug=$(safe_name "$object_path")

    service_dir="$OUT_DIR/services/$service_slug"
    raw_dir="$service_dir/raw"
    objects_dir="$service_dir/objects"
    interfaces_dir="$service_dir/interfaces"
    properties_dir="$service_dir/properties"
    managed_dir="$service_dir/managed-objects"
    state_dir="$service_dir/.state"

    ensure_dir "$raw_dir"
    ensure_dir "$objects_dir"
    ensure_dir "$interfaces_dir"
    ensure_dir "$properties_dir"
    ensure_dir "$managed_dir"
    ensure_dir "$state_dir"

    tree_file="$service_dir/tree.txt"
    append_unique_line "$tree_file" "$object_path"
    append_unique_line "$SERVICE_LIST_FILE" "$service"

    introspect_raw="$raw_dir/${object_slug}.introspect.txt"
    interfaces_file="$interfaces_dir/${object_slug}.interfaces.txt"
    methods_file="$interfaces_dir/${object_slug}.methods.txt"
    signals_file="$interfaces_dir/${object_slug}.signals.txt"
    properties_file="$interfaces_dir/${object_slug}.properties.txt"
    children_file="$state_dir/${object_slug}.children.txt"
    getall_index="$state_dir/${object_slug}.getall-index.txt"
    managed_index="$state_dir/${object_slug}.managed-index.txt"
    object_md="$objects_dir/${object_slug}.md"

    : >"$interfaces_file"
    : >"$methods_file"
    : >"$signals_file"
    : >"$properties_file"
    : >"$children_file"
    : >"$getall_index"
    : >"$managed_index"

    if ! dbus_introspect_raw "$service" "$object_path" "$introspect_raw"; then
        render_object_md \
            "$object_md" "$service" "$object_path" "$introspect_raw" \
            "$interfaces_file" "$methods_file" "$signals_file" "$properties_file" \
            "$children_file" "$getall_index" "$managed_index"
        return 0
    fi

    dbus_parse_interfaces "$introspect_raw" | sed '/^$/d' >"$interfaces_file"
    dbus_parse_methods "$introspect_raw" | sed '/^$/d' >"$methods_file"
    dbus_parse_signals "$introspect_raw" | sed '/^$/d' >"$signals_file"
    dbus_parse_properties "$introspect_raw" | sed '/^$/d' >"$properties_file"
    dbus_parse_children "$introspect_raw" | sed '/^$/d' >"$children_file"

    record_parsed_items "$service" "$object_path" "$interfaces_file" "$INTERFACES_GLOBAL"
    record_parsed_items "$service" "$object_path" "$methods_file" "$METHODS_GLOBAL"
    record_parsed_items "$service" "$object_path" "$signals_file" "$SIGNALS_GLOBAL"
    record_parsed_items "$service" "$object_path" "$properties_file" "$PROPERTIES_GLOBAL"

    props_iface=$(dbus_detect_properties_iface "$introspect_raw" || true)
    objmgr_iface=$(dbus_detect_objectmanager_iface "$introspect_raw" || true)

    if [ -n "$objmgr_iface" ]; then
        managed_raw="$managed_dir/${object_slug}.txt"
        if dbus_getmanagedobjects_raw "$service" "$object_path" "$objmgr_iface" "$managed_raw"; then
            printf '%s|%s\n' "$objmgr_iface" "$managed_raw" >>"$managed_index"
            append_unique_line "$OBJECTMANAGER_GLOBAL" "$service|$object_path|$objmgr_iface"
        fi
    fi

    if [ -n "$props_iface" ] && [ -s "$interfaces_file" ]; then
        while IFS= read -r iface; do
            [ -n "$iface" ] || continue
            if dbus_should_skip_getall_iface "$iface" "$props_iface" "$objmgr_iface"; then
                continue
            fi

            iface_slug=$(safe_name "$iface")
            getall_raw="$properties_dir/${object_slug}__${iface_slug}.txt"
            if dbus_getall_raw "$service" "$object_path" "$props_iface" "$iface" "$getall_raw"; then
                printf '%s|%s\n' "$iface" "$getall_raw" >>"$getall_index"
                append_unique_line "$GETALL_GLOBAL" "$service|$object_path|$iface"
            fi
        done <"$interfaces_file"
    fi

    render_object_md \
        "$object_md" "$service" "$object_path" "$introspect_raw" \
        "$interfaces_file" "$methods_file" "$signals_file" "$properties_file" \
        "$children_file" "$getall_index" "$managed_index"

    if [ -s "$children_file" ]; then
        while IFS= read -r child; do
            [ -n "$child" ] || continue
            walk_object "$service" "$(join_path "$object_path" "$child")"
        done <"$children_file"
    fi
}

SERVICES_RAW="$OUT_DIR/.state/services.raw.txt"
dbus_list_services_raw "$SERVICES_RAW" >/dev/null 2>&1
dbus_parse_services "$SERVICES_RAW" | sed '/^$/d' | sort -u >"$SERVICES_FILE"

if [ ! -s "$SERVICES_FILE" ]; then
    log_error "No services were discovered"
    render_service_index "$OUT_DIR/service-index.md" "$SERVICES_FILE"
    render_summary_md "$OUT_DIR/summary.md" "$DBUS_TOOL" 0 0 0 0 0 0 0 0 1
    echo "No DBus services discovered. See $ERROR_LOG"
    exit 0
fi

while IFS= read -r service; do
    [ -n "$service" ] || continue
    if ! should_collect_service "$service"; then
        continue
    fi

    walk_object "$service" "/"
done <"$SERVICES_FILE"

render_service_index "$OUT_DIR/service-index.md" "$SERVICES_FILE"

for service in $(sort -u "$SERVICE_LIST_FILE" 2>/dev/null); do
    service_slug=$(safe_name "$service")
    service_dir="$OUT_DIR/services/$service_slug"
    tree_txt="$service_dir/tree.txt"
    tree_md="$service_dir/tree.md"

    if [ -f "$tree_txt" ]; then
        sort -u "$tree_txt" -o "$tree_txt"
        render_tree_md "$tree_txt" "$tree_md"
    fi
done

service_count=$(count_lines "$SERVICES_FILE")
object_count=$(count_lines "$VISITED_FILE")
interface_count=$(count_lines "$INTERFACES_GLOBAL")
method_count=$(count_lines "$METHODS_GLOBAL")
signal_count=$(count_lines "$SIGNALS_GLOBAL")
property_count=$(count_lines "$PROPERTIES_GLOBAL")
objectmanager_count=$(count_lines "$OBJECTMANAGER_GLOBAL")
getall_count=$(count_lines "$GETALL_GLOBAL")

if [ -f "$ERROR_LOG" ]; then
    failure_count=$(awk 'END { print NR + 0 }' "$ERROR_LOG")
else
    failure_count=0
fi

render_summary_md \
    "$OUT_DIR/summary.md" \
    "$DBUS_TOOL" \
    "$service_count" \
    "$object_count" \
    "$interface_count" \
    "$method_count" \
    "$signal_count" \
    "$property_count" \
    "$objectmanager_count" \
    "$getall_count" \
    "$failure_count"

echo "DBus dump completed: $OUT_DIR"
