#!/bin/sh

set -u

case "$0" in
    */*) _script_path=${0%/*} ;;
    *) _script_path=. ;;
esac
SCRIPT_DIR=$(CDPATH= cd -- "$_script_path" 2>/dev/null && pwd)
unset _script_path

# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"
# shellcheck source=modules/service.sh
. "$SCRIPT_DIR/modules/service.sh"
# shellcheck source=modules/property.sh
. "$SCRIPT_DIR/modules/property.sh"
# shellcheck source=modules/object.sh
. "$SCRIPT_DIR/modules/object.sh"
# shellcheck source=modules/markdown.sh
. "$SCRIPT_DIR/modules/markdown.sh"
# shellcheck source=modules/json.sh
. "$SCRIPT_DIR/modules/json.sh"

SERVICE_FILTER=""

usage() {
    cat <<EOF
Usage:
  sh ./dbus-explorer.sh collect [options]
  sh ./dbus-explorer.sh search TERM [options]
  sh ./dbus-explorer.sh --grep TERM [options]
  sh ./dbus-explorer.sh compare OLD_DIR NEW_DIR

Commands:
  collect              Discover and export DBus. Default command.
  search TERM          Search a previous output directory.
  --grep TERM          Search objects, methods, properties, and values.
  compare OLD NEW      Compare two DBus Explorer output directories.

Options:
  -o DIR               Output directory. Default: output/run-YYYYmmdd-HHMMSS
  -s SERVICES          Comma-separated service filter for collect.
  -b system|session    Bus type. Default: system.
  -t SECONDS           Command timeout. Default: 5.
  -q                   Quiet collect progress output.
  -h                   Show this help.

Environment:
  CMD_TIMEOUT          Default command timeout when -t is not used.
  BUS_TYPE             system or session.
  PROGRESS             1 to show collect progress, 0 to hide it.
EOF
}

service_allowed() {
    service=$1
    [ -n "$SERVICE_FILTER" ] || return 0
    printf ",%s," "$SERVICE_FILTER" | grep -F ",$service," >/dev/null 2>&1
}

render_outputs() {
    render_service_index_markdown
    render_properties_markdown
    render_sensitive_markdown
    render_writable_markdown
    render_web_management_markdown
    render_tree_text
    render_summary_markdown
    render_all_json
}

collect_main() {
    init_output_tree
    trap trap_interrupt INT TERM
    load_plugins

    progress "DBus Explorer started"
    progress "Output directory: $OUT_DIR"
    progress "Logs: $LOG_DIR"
    progress "Detecting DBus clients and timeout support"

    if ! detect_tools; then
        log_error "Neither gdbus nor dbus-send was found"
        printf "DBus Explorer cannot run: neither gdbus nor dbus-send was found.\n" >&2
        printf "Install one DBus client or copy this tool to a device that has DBus CLI support.\n" >&2
        render_outputs
        return 1
    fi

    log_run "started name=$DBUS_EXPLORER_NAME version=$DBUS_EXPLORER_VERSION bus=$BUS_TYPE tool=$DBUS_TOOL timeout=$CMD_TIMEOUT"
    progress "Using DBus client: $DBUS_TOOL"
    progress "Bus: $BUS_TYPE"
    if [ -n "$TIMEOUT_BIN" ]; then
        log_run "timeout detected: $TIMEOUT_BIN"
        progress "Command timeout: ${CMD_TIMEOUT}s via $TIMEOUT_BIN"
    else
        log_run "timeout not found; commands run without timeout wrapper"
        progress "Command timeout: timeout command not found; running without wrapper"
    fi

    progress "Discovering services with org.freedesktop.DBus.ListNames"
    if ! discover_services; then
        render_outputs
        printf "No DBus services discovered. See %s\n" "$ERROR_LOG" >&2
        return 1
    fi

    service_total=$(count_lines "$SERVICES_FILE")
    service_index=0
    progress "Discovered services: $service_total"

    while IFS= read -r service; do
        [ -n "$service" ] || continue
        if service_allowed "$service"; then
            service_index=$((service_index + 1))
            log_run "walk service=$service"
            progress "Service $service_index/$service_total: $service"
            walk_service_objects "$service"
            service_objects=$(awk -F '\t' -v s="$service" '$1 == s { c++ } END { print c + 0 }' "$OBJECTS_TSV")
            progress "Service done: $service objects=$service_objects"
        fi
    done < "$SERVICES_FILE"

    progress "Rendering Markdown and JSON output"
    render_outputs
    printf "%s\n" "$OUT_DIR" > "${SCRIPT_DIR}/output/latest-path.txt" 2>/dev/null || :
    log_run "finished output=$OUT_DIR"
    progress "Done. summary=$OUT_DIR/summary.md json=$OUT_DIR/json/summary.json"
    printf "DBus Explorer output: %s\n" "$OUT_DIR"
}

search_main() {
    term=$1
    [ -n "$OUT_DIR" ] || OUT_DIR="${SCRIPT_DIR}/output/latest"

    if [ ! -d "$OUT_DIR" ] && [ -f "${SCRIPT_DIR}/output/latest-path.txt" ]; then
        OUT_DIR=$(sed -n '1p' "${SCRIPT_DIR}/output/latest-path.txt")
    fi

    if [ ! -d "$OUT_DIR" ]; then
        printf "Output directory not found: %s\n" "$OUT_DIR" >&2
        return 1
    fi

    printf "# Search: %s\n\n" "$term"

    if [ -f "$OUT_DIR/.state/objects.tsv" ]; then
        printf "## Objects\n\n"
        grep -i "$term" "$OUT_DIR/.state/objects.tsv" 2>/dev/null | awk -F '\t' '{ print "- `" $1 "` `" $2 "` status=" $3 }'
        printf "\n"
    fi

    if [ -f "$OUT_DIR/.state/properties.tsv" ]; then
        printf "## Properties\n\n"
        grep -i "$term" "$OUT_DIR/.state/properties.tsv" 2>/dev/null | awk -F '\t' '{ print "- `" $1 "` `" $2 "` `" $3 "." $4 "` type=" $5 " perm=" $6 }'
        printf "\n"
    fi

    if [ -f "$OUT_DIR/.state/methods.tsv" ]; then
        printf "## Methods\n\n"
        grep -i "$term" "$OUT_DIR/.state/methods.tsv" 2>/dev/null | awk -F '\t' '{ print "- `" $1 "` `" $2 "` `" $3 "." $4 "`" }'
        printf "\n"
    fi

    if [ -f "$OUT_DIR/.state/properties-values.tsv" ]; then
        printf "## Values\n\n"
        grep -i "$term" "$OUT_DIR/.state/properties-values.tsv" 2>/dev/null | awk -F '\t' '{ print "- `" $1 "` `" $2 "` `" $3 "." $4 "` access=" $6 " status=" $8 " value=`" $9 "`" }'
        printf "\n"
    fi
}

compare_file() {
    title=$1
    old_file=$2
    new_file=$3

    printf "## %s\n\n" "$title"
    printf "### Added\n\n"
    if [ -f "$new_file" ]; then
        if [ -f "$old_file" ]; then
            awk 'NR==FNR { seen[$0]=1; next } !($0 in seen)' "$old_file" "$new_file"
        else
            sort -u "$new_file"
        fi | sed 's/^/- `/' | sed 's/$/`/'
    fi
    printf "\n### Removed\n\n"
    if [ -f "$old_file" ]; then
        if [ -f "$new_file" ]; then
            awk 'NR==FNR { seen[$0]=1; next } !($0 in seen)' "$new_file" "$old_file"
        else
            sort -u "$old_file"
        fi | sed 's/^/- `/' | sed 's/$/`/'
    fi
    printf "\n"
}

compare_main() {
    old_dir=$1
    new_dir=$2

    if [ ! -d "$old_dir" ] || [ ! -d "$new_dir" ]; then
        printf "Both compare arguments must be DBus Explorer output directories.\n" >&2
        return 1
    fi

    old_tmp="${TMPDIR:-/tmp}/dbus-explorer-old-$$"
    new_tmp="${TMPDIR:-/tmp}/dbus-explorer-new-$$"
    ensure_dir "$old_tmp"
    ensure_dir "$new_tmp"

    awk -F '\t' '{ print $1 "|" $2 }' "$old_dir/.state/objects.tsv" 2>/dev/null | sort -u > "$old_tmp/objects"
    awk -F '\t' '{ print $1 "|" $2 }' "$new_dir/.state/objects.tsv" 2>/dev/null | sort -u > "$new_tmp/objects"
    awk -F '\t' '{ print $1 "|" $2 "|" $3 }' "$old_dir/.state/interfaces.tsv" 2>/dev/null | sort -u > "$old_tmp/interfaces"
    awk -F '\t' '{ print $1 "|" $2 "|" $3 }' "$new_dir/.state/interfaces.tsv" 2>/dev/null | sort -u > "$new_tmp/interfaces"
    awk -F '\t' '{ print $1 "|" $2 "|" $3 "|" $4 }' "$old_dir/.state/methods.tsv" 2>/dev/null | sort -u > "$old_tmp/methods"
    awk -F '\t' '{ print $1 "|" $2 "|" $3 "|" $4 }' "$new_dir/.state/methods.tsv" 2>/dev/null | sort -u > "$new_tmp/methods"
    awk -F '\t' '{ print $1 "|" $2 "|" $3 "|" $4 }' "$old_dir/.state/properties.tsv" 2>/dev/null | sort -u > "$old_tmp/properties"
    awk -F '\t' '{ print $1 "|" $2 "|" $3 "|" $4 }' "$new_dir/.state/properties.tsv" 2>/dev/null | sort -u > "$new_tmp/properties"

    printf "# DBus Explorer Compare\n\n"
    printf "| Item | Value |\n"
    printf "| --- | --- |\n"
    printf '| Old | `%s` |\n' "$old_dir"
    printf '| New | `%s` |\n\n' "$new_dir"

    compare_file "Objects" "$old_tmp/objects" "$new_tmp/objects"
    compare_file "Interfaces" "$old_tmp/interfaces" "$new_tmp/interfaces"
    compare_file "Methods" "$old_tmp/methods" "$new_tmp/methods"
    compare_file "Properties" "$old_tmp/properties" "$new_tmp/properties"

    log_run "compare temporary indexes left at $old_tmp and $new_tmp"
}

COMMAND="collect"
if [ $# -gt 0 ]; then
    case "$1" in
        collect|search|compare)
            COMMAND=$1
            shift
            ;;
        --grep)
            COMMAND=search
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
    esac
fi

if [ "$COMMAND" = "search" ]; then
    if [ $# -lt 1 ]; then
        usage >&2
        exit 1
    fi
    SEARCH_TERM=$1
    shift
fi

if [ "$COMMAND" = "compare" ]; then
    if [ $# -ne 2 ]; then
        usage >&2
        exit 1
    fi
    compare_main "$1" "$2"
    exit $?
fi

while getopts "o:s:b:t:qh" opt; do
    case "$opt" in
        o) OUT_DIR=$OPTARG ;;
        s) SERVICE_FILTER=$OPTARG ;;
        b) BUS_TYPE=$OPTARG ;;
        t) CMD_TIMEOUT=$OPTARG ;;
        q) PROGRESS=0 ;;
        h)
            usage
            exit 0
            ;;
        *)
            usage >&2
            exit 1
            ;;
    esac
done

case "$BUS_TYPE" in
    system|session) ;;
    *)
        printf "Invalid bus type: %s\n" "$BUS_TYPE" >&2
        exit 1
        ;;
esac

case "$COMMAND" in
    collect)
        collect_main
        ;;
    search)
        search_main "$SEARCH_TERM"
        ;;
    *)
        usage >&2
        exit 1
        ;;
esac
