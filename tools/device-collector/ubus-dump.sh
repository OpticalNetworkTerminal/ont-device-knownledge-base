#!/bin/sh

set -u

case "$0" in
    */*) _script_path=${0%/*} ;;
    *) _script_path=. ;;
esac
SCRIPT_DIR=$(CDPATH= cd -- "$_script_path" 2>/dev/null && pwd)
unset _script_path

. "$SCRIPT_DIR/lib/common.sh"

OUT_DIR="ubus"
UBUS_BIN="${UBUS_BIN:-ubus}"

RUN_LOG=""
ERROR_LOG=""
OBJECTS_FILE=""
SUMMARY_FILE=""
README_FILE=""
OBJECTS_DIR=""
STATE_DIR=""

METHODS_TOTAL=0
OBJECTS_TOTAL=0
CALL_SUCCESS=0
CALL_FAILURE=0
OBJECT_SUCCESS=0
OBJECT_FAILURE=0

SAFE_METHOD_DENYLIST='set|add|del|delete|remove|write|save|commit|apply|reload|restart|stop|start|enable|disable|reboot|restore|reset|factory|upgrade|flash|format'

usage() {
    cat <<EOF
Usage: sh ./ubus-dump.sh [-o output_dir]

Options:
  -o DIR     Output directory. Default: ubus
  -h         Show this help
EOF
}

while getopts "o:h" opt; do
    case "$opt" in
        o) OUT_DIR="$OPTARG" ;;
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

ensure_layout() {
    RUN_LOG="$OUT_DIR/logs/run.log"
    ERROR_LOG="$OUT_DIR/logs/error.log"
    OBJECTS_FILE="$OUT_DIR/objects.txt"
    SUMMARY_FILE="$OUT_DIR/summary.md"
    README_FILE="$OUT_DIR/README.md"
    OBJECTS_DIR="$OUT_DIR/objects"
    STATE_DIR="$OUT_DIR/.state"

    ensure_dir "$OUT_DIR"
    ensure_dir "$OUT_DIR/logs"
    ensure_dir "$OBJECTS_DIR"
    ensure_dir "$STATE_DIR"

    : >"$RUN_LOG"
    : >"$ERROR_LOG"
}

render_readme() {
    cat >"$README_FILE" <<EOF
# UBus Dump

该目录由 \`ubus-dump.sh\` 自动生成。

## 内容说明

- \`objects.txt\`：\`ubus list\` 对象列表
- \`objects/\`：每个 object 的 Markdown 结果
- \`summary.md\`：采集统计摘要
- \`logs/run.log\`：执行日志
- \`logs/error.log\`：错误日志

## 安全策略

- 仅自动调用无参数方法
- 带参数方法只记录签名，不自动执行
- 命中危险关键字的方法即使无参数也不会调用
EOF
}

run_capture_no_timeout() {
    out_file=$1
    shift

    ensure_dir "$(path_dirname "$out_file")" || return 1
    log_run "RUN $*"

    {
        printf '# command:'
        for arg in "$@"; do
            printf ' %s' "$arg"
        done
        printf '\n'
        printf '# started: %s\n\n' "$(now_ts)"
    } >"$out_file"

    "$@" >>"$out_file" 2>&1
    rc=$?

    printf '\n# finished: %s\n# exit_code: %s\n' "$(now_ts)" "$rc" >>"$out_file"

    if [ "$rc" -ne 0 ]; then
        log_error "FAIL($rc) $*"
    fi

    return "$rc"
}

method_is_safe() {
    method_name=$1
    echo "$method_name" | grep -Eqi "$SAFE_METHOD_DENYLIST"
    if [ $? -eq 0 ]; then
        return 1
    fi
    return 0
}

render_missing_tool() {
    reason=$1
    render_readme
    cat >"$SUMMARY_FILE" <<EOF
# UBus 采集摘要

- UBus 可用性：\`missing\`
- 原因：$reason
- Object 数量：\`0\`
- Method 数量：\`0\`
- 成功采集数量：\`0\`
- 失败数量：\`1\`
EOF
}

collect_objects() {
    run_capture_no_timeout "$STATE_DIR/objects.raw.txt" "$UBUS_BIN" list
    rc=$?
    sed -n '/^[^#]/p' "$STATE_DIR/objects.raw.txt" | sed '/^$/d' >"$OBJECTS_FILE"
    return "$rc"
}

extract_methods_tsv() {
    in_file=$1
    awk '
        /^[[:space:]]*"[^"]+"[[:space:]]*:/ {
            line=$0
            method=line
            sub(/^[[:space:]]*"/, "", method)
            sub(/".*$/, "", method)

            args=line
            sub(/^[^:]*:[[:space:]]*/, "", args)
            sub(/[[:space:]]*$/, "", args)
            if (args == "") {
                args="{}"
            }

            noargs=0
            if (args == "{}") {
                noargs=1
            }

            printf "%s\t%s\t%s\n", method, args, noargs
        }
    ' "$in_file"
}

render_object_md() {
    object_name=$1
    object_md=$2
    methods_file=$3
    call_index=$4
    raw_file=$5

    {
        echo "# UBus Object"
        echo
        echo "- Object: \`$object_name\`"
        echo
        echo "## Methods"
        echo
        if [ -s "$methods_file" ]; then
            echo "| Method | Signature | Auto Call |"
            echo "| --- | --- | --- |"
            while IFS='	' read -r method sig noargs; do
                [ -n "$method" ] || continue
                auto="no"
                if [ "$noargs" = "1" ] && method_is_safe "$method"; then
                    auto="yes"
                fi
                printf "| \`%s\` | \`%s\` | \`%s\` |\n" "$method" "$sig" "$auto"
            done <"$methods_file"
        else
            echo "No methods parsed."
        fi
        echo
        echo "## Auto Call Results"
        echo
        if [ -s "$call_index" ]; then
            while IFS='|' read -r method status file; do
                [ -n "$method" ] || continue
                echo "### \`$method\`"
                echo
                echo "- Status: \`$status\`"
                echo
                echo '```text'
                cat "$file" 2>/dev/null
                echo '```'
                echo
            done <"$call_index"
        else
            echo "No safe no-argument methods were executed."
            echo
        fi
        echo "## Raw Metadata"
        echo
        echo '```text'
        cat "$raw_file" 2>/dev/null
        echo '```'
    } >"$object_md"
}

collect_object() {
    object_name=$1
    object_slug=$(safe_name "$object_name")
    raw_file="$STATE_DIR/${object_slug}.raw.txt"
    methods_file="$STATE_DIR/${object_slug}.methods.tsv"
    call_index="$STATE_DIR/${object_slug}.calls.txt"
    object_md="$OBJECTS_DIR/${object_slug}.md"
    object_dir="$STATE_DIR/${object_slug}"

    : >"$methods_file"
    : >"$call_index"
    ensure_dir "$object_dir"

    run_capture_no_timeout "$raw_file" "$UBUS_BIN" -v list "$object_name"
    rc=$?
    if [ "$rc" -ne 0 ]; then
        OBJECT_FAILURE=$((OBJECT_FAILURE + 1))
        render_object_md "$object_name" "$object_md" "$methods_file" "$call_index" "$raw_file"
        return 0
    fi

    OBJECT_SUCCESS=$((OBJECT_SUCCESS + 1))
    extract_methods_tsv "$raw_file" >"$methods_file"

    while IFS='	' read -r method sig noargs; do
        [ -n "$method" ] || continue
        METHODS_TOTAL=$((METHODS_TOTAL + 1))

        if [ "$noargs" != "1" ]; then
            continue
        fi

        if ! method_is_safe "$method"; then
            log_run "SKIP unsafe no-arg method object=$object_name method=$method"
            continue
        fi

        call_file="$object_dir/$(safe_name "$method").call.txt"
        run_capture_no_timeout "$call_file" "$UBUS_BIN" call "$object_name" "$method" "{}"
        if [ $? -eq 0 ]; then
            CALL_SUCCESS=$((CALL_SUCCESS + 1))
            printf '%s|success|%s\n' "$method" "$call_file" >>"$call_index"
        else
            CALL_FAILURE=$((CALL_FAILURE + 1))
            printf '%s|failure|%s\n' "$method" "$call_file" >>"$call_index"
        fi
    done <"$methods_file"

    render_object_md "$object_name" "$object_md" "$methods_file" "$call_index" "$raw_file"
}

render_summary() {
    cat >"$SUMMARY_FILE" <<EOF
# UBus 采集摘要

- UBus 可用性：\`available\`
- Object 数量：\`$OBJECTS_TOTAL\`
- Method 数量：\`$METHODS_TOTAL\`
- 成功采集数量：\`$OBJECT_SUCCESS\`
- 自动调用成功数量：\`$CALL_SUCCESS\`
- 自动调用失败数量：\`$CALL_FAILURE\`
- 失败数量：\`$OBJECT_FAILURE\`
EOF
}

main() {
    ensure_layout
    render_readme

    if ! has_cmd "$UBUS_BIN"; then
        log_error "ubus command not found"
        render_missing_tool "ubus command not found"
        exit 0
    fi

    if ! collect_objects; then
        log_error "failed to enumerate ubus objects"
    fi

    if [ ! -s "$OBJECTS_FILE" ]; then
        render_summary
        exit 0
    fi

    while IFS= read -r object_name; do
        [ -n "$object_name" ] || continue
        OBJECTS_TOTAL=$((OBJECTS_TOTAL + 1))
        collect_object "$object_name"
    done <"$OBJECTS_FILE"

    render_summary
}

main "$@"
