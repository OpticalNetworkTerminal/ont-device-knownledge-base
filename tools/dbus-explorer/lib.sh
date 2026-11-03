#!/bin/sh

# Shared helpers for DBus Explorer.

DBUS_EXPLORER_NAME="dbus-explorer"
DBUS_EXPLORER_VERSION="0.1.0"

case "$0" in
    */*) _dbus_explorer_script_path=${0%/*} ;;
    *) _dbus_explorer_script_path=. ;;
esac
SCRIPT_DIR=$(CDPATH= cd -- "$_dbus_explorer_script_path" 2>/dev/null && pwd)
unset _dbus_explorer_script_path

OUT_DIR="${OUT_DIR:-}"
BUS_TYPE="${BUS_TYPE:-system}"
DBUS_TOOL=""
TIMEOUT_BIN=""
CMD_TIMEOUT="${CMD_TIMEOUT:-5}"
PROGRESS="${PROGRESS:-1}"
START_EPOCH=0

LOG_DIR=""
RUN_LOG=""
ERROR_LOG=""
DEBUG_LOG=""

STATE_DIR=""
RAW_DIR=""
JSON_DIR=""
MARKDOWN_DIR=""

SERVICES_FILE=""
VISITED_FILE=""
FAILURES_FILE=""
OBJECTS_TSV=""
INTERFACES_TSV=""
METHODS_TSV=""
SIGNALS_TSV=""
PROPERTIES_TSV=""
PROPERTIES_VALUES_TSV=""
GETALL_TSV=""
MANAGED_TSV=""
TREE_TSV=""

timestamp_utc() {
    date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date
}

timestamp_compact() {
    date +"%Y%m%d-%H%M%S" 2>/dev/null || echo "unknown-time"
}

epoch_now() {
    date +%s 2>/dev/null || echo 0
}

has_cmd() {
    command -v "$1" >/dev/null 2>&1
}

ensure_dir() {
    [ -n "$1" ] || return 0
    [ -d "$1" ] || mkdir -p "$1"
}

path_dirname() {
    case "$1" in
        */*) printf "%s\n" "${1%/*}" ;;
        *) printf ".\n" ;;
    esac
}

safe_name() {
    printf "%s" "$1" | sed 's#[/[:space:]]#_#g; s#[^A-Za-z0-9_.-]#_#g; s#^_*##; s#_*$##'
}

safe_name_keep_root() {
    value=$(safe_name "$1")
    [ -n "$value" ] || value="root"
    printf "%s\n" "$value"
}

append_unique_line() {
    file=$1
    line=$2
    [ -n "$line" ] || return 0
    if ! grep -Fqx "$line" "$file" 2>/dev/null; then
        printf "%s\n" "$line" >> "$file"
    fi
}

count_lines() {
    if [ -f "$1" ]; then
        awk 'END { print NR + 0 }' "$1"
    else
        printf "0\n"
    fi
}

log_run() {
    [ -n "$RUN_LOG" ] || return 0
    printf "%s %s\n" "$(timestamp_utc)" "$*" >> "$RUN_LOG"
}

log_error() {
    [ -n "$ERROR_LOG" ] || return 0
    printf "%s %s\n" "$(timestamp_utc)" "$*" >> "$ERROR_LOG"
}

log_debug() {
    [ -n "$DEBUG_LOG" ] || return 0
    printf "%s %s\n" "$(timestamp_utc)" "$*" >> "$DEBUG_LOG"
}

progress() {
    [ "${PROGRESS:-1}" = "1" ] || return 0
    printf "[%s] %s\n" "$(timestamp_utc)" "$*" >&2
}

json_escape() {
    printf "%s" "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/	/\\t/g'
}

json_string() {
    printf "\"%s\"" "$(json_escape "$1")"
}

bus_arg_gdbus() {
    case "$BUS_TYPE" in
        session) printf "%s\n" "--session" ;;
        *) printf "%s\n" "--system" ;;
    esac
}

bus_arg_dbus_send() {
    case "$BUS_TYPE" in
        session) printf "%s\n" "--session" ;;
        *) printf "%s\n" "--system" ;;
    esac
}

detect_tools() {
    if has_cmd gdbus; then
        DBUS_TOOL="gdbus"
    elif has_cmd dbus-send; then
        DBUS_TOOL="dbus-send"
    else
        DBUS_TOOL=""
    fi

    if has_cmd timeout; then
        TIMEOUT_BIN="timeout"
    else
        TIMEOUT_BIN=""
    fi

    [ -n "$DBUS_TOOL" ]
}

run_cmd() {
    label=$1
    out_file=$2
    err_file=$3
    shift 3

    ensure_dir "$(path_dirname "$out_file")"
    ensure_dir "$(path_dirname "$err_file")"

    start=$(epoch_now)
    log_debug "CMD label=$label argv=$*"

    if [ -n "$TIMEOUT_BIN" ]; then
        "$TIMEOUT_BIN" "$CMD_TIMEOUT" "$@" > "$out_file" 2> "$err_file"
        rc=$?
    else
        "$@" > "$out_file" 2> "$err_file"
        rc=$?
    fi

    end=$(epoch_now)
    elapsed=$((end - start))
    printf "%s label=%s rc=%s elapsed=%s cmd=%s\n" \
        "$(timestamp_utc)" "$label" "$rc" "$elapsed" "$*" >> "$RUN_LOG"

    if [ "$rc" -ne 0 ]; then
        printf "%s label=%s rc=%s elapsed=%s cmd=%s\n" \
            "$(timestamp_utc)" "$label" "$rc" "$elapsed" "$*" >> "$ERROR_LOG"
    fi

    return "$rc"
}

init_output_tree() {
    if [ -z "$OUT_DIR" ]; then
        OUT_DIR="${SCRIPT_DIR}/output/run-$(timestamp_compact)"
    fi

    LOG_DIR="${OUT_DIR}/logs"
    STATE_DIR="${OUT_DIR}/.state"
    RAW_DIR="${OUT_DIR}/raw"
    JSON_DIR="${OUT_DIR}/json"
    MARKDOWN_DIR="${OUT_DIR}/markdown"

    RUN_LOG="${LOG_DIR}/run.log"
    ERROR_LOG="${LOG_DIR}/error.log"
    DEBUG_LOG="${LOG_DIR}/debug.log"

    SERVICES_FILE="${OUT_DIR}/services.txt"
    VISITED_FILE="${STATE_DIR}/visited.txt"
    FAILURES_FILE="${STATE_DIR}/failures.txt"
    OBJECTS_TSV="${STATE_DIR}/objects.tsv"
    INTERFACES_TSV="${STATE_DIR}/interfaces.tsv"
    METHODS_TSV="${STATE_DIR}/methods.tsv"
    SIGNALS_TSV="${STATE_DIR}/signals.tsv"
    PROPERTIES_TSV="${STATE_DIR}/properties.tsv"
    PROPERTIES_VALUES_TSV="${STATE_DIR}/properties-values.tsv"
    GETALL_TSV="${STATE_DIR}/getall.tsv"
    MANAGED_TSV="${STATE_DIR}/managed-objects.tsv"
    TREE_TSV="${STATE_DIR}/tree.tsv"

    ensure_dir "$OUT_DIR"
    ensure_dir "$LOG_DIR"
    ensure_dir "$STATE_DIR"
    ensure_dir "$RAW_DIR/services"
    ensure_dir "$RAW_DIR/objects"
    ensure_dir "$RAW_DIR/properties"
    ensure_dir "$RAW_DIR/managed-objects"
    ensure_dir "$JSON_DIR"
    ensure_dir "$MARKDOWN_DIR/services"
    ensure_dir "$MARKDOWN_DIR/objects"
    ensure_dir "$MARKDOWN_DIR/properties"

    : > "$RUN_LOG"
    : > "$ERROR_LOG"
    : > "$DEBUG_LOG"
    : > "$SERVICES_FILE"
    : > "$VISITED_FILE"
    : > "$FAILURES_FILE"
    : > "$OBJECTS_TSV"
    : > "$INTERFACES_TSV"
    : > "$METHODS_TSV"
    : > "$SIGNALS_TSV"
    : > "$PROPERTIES_TSV"
    : > "$PROPERTIES_VALUES_TSV"
    : > "$GETALL_TSV"
    : > "$MANAGED_TSV"
    : > "$TREE_TSV"

    START_EPOCH=$(epoch_now)
    {
        printf "name=%s\n" "$DBUS_EXPLORER_NAME"
        printf "version=%s\n" "$DBUS_EXPLORER_VERSION"
        printf "started_at=%s\n" "$(timestamp_utc)"
        printf "bus=%s\n" "$BUS_TYPE"
        printf "timeout=%s\n" "$CMD_TIMEOUT"
    } > "${OUT_DIR}/run.info"
}

record_failure() {
    service=$1
    object_path=$2
    operation=$3
    reason=$4
    printf "%s\t%s\t%s\t%s\n" "$service" "$object_path" "$operation" "$reason" >> "$FAILURES_FILE"
    log_error "service=$service object=$object_path operation=$operation reason=$reason"
    progress "FAIL service=$service object=$object_path operation=$operation reason=$reason"
}

join_object_path() {
    parent=$1
    child=$2

    case "$child" in
        /*) printf "%s\n" "$child" ;;
        *)
            case "$parent" in
                /) printf "/%s\n" "$child" ;;
                *) printf "%s/%s\n" "$parent" "$child" ;;
            esac
            ;;
    esac
}

object_markdown_path() {
    service=$1
    object_path=$2
    service_dir="${MARKDOWN_DIR}/$(safe_name_keep_root "$service")"

    if [ "$object_path" = "/" ]; then
        printf "%s/README.md\n" "$service_dir"
        return 0
    fi

    rel=$(printf "%s" "$object_path" | sed 's#^/##; s#[^A-Za-z0-9_./-]#_#g')
    dir=$(path_dirname "$rel")
    base=${rel##*/}
    if [ "$dir" = "." ]; then
        printf "%s/%s.md\n" "$service_dir" "$base"
    else
        printf "%s/%s/%s.md\n" "$service_dir" "$dir" "$base"
    fi
}

load_plugins() {
    plugin_dir="${SCRIPT_DIR}/plugins"
    [ -d "$plugin_dir" ] || return 0

    for plugin in "$plugin_dir"/*.sh; do
        [ -f "$plugin" ] || continue
        # shellcheck source=/dev/null
        . "$plugin"
        log_debug "loaded plugin=$plugin"
    done
}

plugin_after_object() {
    service=$1
    object_path=$2
    introspect_file=$3

    if has_cmd dbus_explorer_plugin_after_object; then
        dbus_explorer_plugin_after_object "$service" "$object_path" "$introspect_file" || :
    fi
}

trap_interrupt() {
    log_error "interrupted"
    printf "Interrupted. Partial output is available at %s\n" "$OUT_DIR" >&2
    exit 130
}
