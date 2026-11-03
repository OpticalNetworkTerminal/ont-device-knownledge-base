#!/bin/sh

set -u

case "$0" in
    */*) _script_path=${0%/*} ;;
    *) _script_path=. ;;
esac
SCRIPT_DIR=$(CDPATH= cd -- "$_script_path" 2>/dev/null && pwd)
unset _script_path

. "$SCRIPT_DIR/lib/common.sh"

OUT_DIR="sendcmd"
SENDCMD_BIN="${SENDCMD_BIN:-sendcmd}"
PLUGIN_DIR="$SCRIPT_DIR/plugins/sendcmd"

RUN_LOG=""
ERROR_LOG=""
TABLES_FILE=""
SUMMARY_FILE=""
README_FILE=""
TABLES_DIR=""
STATE_DIR=""

TABLE_TOTAL=0
SUCCESS_TOTAL=0
FAIL_TOTAL=0

READONLY_DENYLIST='(^|[[:space:]])(set|add|del|delete|remove|write|save|commit|apply|reboot|restore|upgrade|factory|format|flash|erase|passwd|password|enable|disable)([[:space:]]|$)'

usage() {
    cat <<EOF
Usage: sh ./sendcmd-dump.sh [-o output_dir]

Options:
  -o DIR     Output directory. Default: sendcmd
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

init_layout() {
    RUN_LOG="$OUT_DIR/logs/run.log"
    ERROR_LOG="$OUT_DIR/logs/error.log"
    TABLES_FILE="$OUT_DIR/tables.txt"
    SUMMARY_FILE="$OUT_DIR/summary.md"
    README_FILE="$OUT_DIR/README.md"
    TABLES_DIR="$OUT_DIR/tables"
    STATE_DIR="$OUT_DIR/.state"

    ensure_dir "$OUT_DIR"
    ensure_dir "$OUT_DIR/logs"
    ensure_dir "$TABLES_DIR"
    ensure_dir "$STATE_DIR"
    : >"$RUN_LOG"
    : >"$ERROR_LOG"
    : >"$TABLES_FILE"
}

render_readme() {
    cat >"$README_FILE" <<EOF
# Sendcmd Dump

该目录由 \`sendcmd-dump.sh\` 自动生成。

## 内容说明

- \`tables.txt\`：自动发现的表或主题列表
- \`tables/\`：每个表的 Markdown 结果
- \`summary.md\`：采集统计摘要
- \`logs/run.log\`：执行日志
- \`logs/error.log\`：错误日志

## 安全策略

- 默认只读
- 只执行插件声明的只读候选命令
- 命中危险关键字的命令一律跳过
- 不执行 \`set\`、\`delete\`、\`write\`、\`save\`、\`reboot\`、\`restore\`、\`upgrade\`、\`factory\`、\`commit\` 等命令
EOF
}

command_is_safe() {
    command_line=$1
    echo "$command_line" | grep -Eqi "$READONLY_DENYLIST"
    if [ $? -eq 0 ]; then
        return 1
    fi
    return 0
}

render_missing_tool() {
    reason=$1
    cat >"$SUMMARY_FILE" <<EOF
# Sendcmd 采集摘要

- Sendcmd 可用性：\`missing\`
- 原因：$reason
- Table 数量：\`0\`
- 成功数量：\`0\`
- 失败数量：\`1\`
EOF
}

discover_plugins() {
    find "$PLUGIN_DIR" -maxdepth 1 -type f -name '*.sh' 2>/dev/null | sort
}

parse_candidate_tokens() {
    in_file=$1
    awk '
        /^[#[:space:]-]*$/ { next }
        /^#/ { next }
        {
            line=$0
            gsub(/\r/, "", line)
            gsub(/[,:;{}()[\]<>]/, " ", line)
            n=split(line, arr, /[[:space:]]+/)
            for (i=1; i<=n; i++) {
                token=arr[i]
                if (token ~ /^[A-Za-z][A-Za-z0-9_.-]{2,}$/) {
                    low=tolower(token)
                    if (low !~ /^(help|show|list|dump|exit|quit|usage|table|tables|command|commands|sendcmd|db|all|name|value)$/) {
                        print token
                    }
                }
            }
        }
    ' "$in_file" | sort -u
}

append_table_candidates() {
    source_file=$1
    if [ -s "$source_file" ]; then
        parse_candidate_tokens "$source_file" >>"$STATE_DIR/tables.candidates.txt"
    fi
}

run_plugin_probes() {
    : >"$STATE_DIR/tables.candidates.txt"
    : >"$STATE_DIR/probe-index.txt"

    plugins=$(discover_plugins)
    if [ -z "$plugins" ]; then
        log_error "no sendcmd plugins found in $PLUGIN_DIR"
        return 0
    fi

    for plugin in $plugins; do
        plugin_name=$(path_basename "$plugin")
        plugin_name=${plugin_name%.sh}
        probe_list="$STATE_DIR/${plugin_name}.probes.txt"
        sh "$plugin" probe >"$probe_list" 2>>"$ERROR_LOG"
        while IFS= read -r command_line; do
            [ -n "$command_line" ] || continue
            if ! command_is_safe "$command_line"; then
                log_run "SKIP unsafe probe plugin=$plugin_name cmd=$command_line"
                continue
            fi
            raw_file="$STATE_DIR/${plugin_name}.$(safe_name "$command_line").probe.txt"
            sh -c "$command_line" >"$raw_file" 2>&1
            rc=$?
            printf '%s|%s|%s|%s\n' "$plugin_name" "$command_line" "$rc" "$raw_file" >>"$STATE_DIR/probe-index.txt"
            if [ "$rc" -eq 0 ]; then
                append_table_candidates "$raw_file"
            else
                log_error "probe failed plugin=$plugin_name rc=$rc cmd=$command_line"
            fi
        done <"$probe_list"
    done

    if [ -f "$STATE_DIR/tables.candidates.txt" ]; then
        sort -u "$STATE_DIR/tables.candidates.txt" >"$TABLES_FILE"
    fi
}

render_table_md() {
    table_name=$1
    table_md=$2
    cmd_index=$3

    {
        echo "# Sendcmd Table"
        echo
        echo "- Table: \`$table_name\`"
        echo
        echo "## Commands"
        echo
        if [ -s "$cmd_index" ]; then
            while IFS='|' read -r command_line rc raw_file; do
                [ -n "$command_line" ] || continue
                echo "### \`$command_line\`"
                echo
                echo "- Exit Code: \`$rc\`"
                echo
                echo '```text'
                cat "$raw_file" 2>/dev/null
                echo '```'
                echo
            done <"$cmd_index"
        else
            echo "No successful readonly command candidates."
        fi
    } >"$table_md"
}

collect_table() {
    table_name=$1
    table_slug=$(safe_name "$table_name")
    table_md="$TABLES_DIR/${table_slug}.md"
    cmd_index="$STATE_DIR/${table_slug}.commands.txt"
    : >"$cmd_index"

    plugins=$(discover_plugins)
    for plugin in $plugins; do
        plugin_name=$(path_basename "$plugin")
        plugin_name=${plugin_name%.sh}
        cmd_file="$STATE_DIR/${table_slug}.${plugin_name}.cmds.txt"
        sh "$plugin" table "$table_name" >"$cmd_file" 2>>"$ERROR_LOG"
        while IFS= read -r command_line; do
            [ -n "$command_line" ] || continue
            if ! command_is_safe "$command_line"; then
                log_run "SKIP unsafe table command table=$table_name cmd=$command_line"
                continue
            fi
            raw_file="$STATE_DIR/${table_slug}.$(safe_name "$command_line").txt"
            sh -c "$command_line" >"$raw_file" 2>&1
            rc=$?
            printf '%s|%s|%s\n' "$command_line" "$rc" "$raw_file" >>"$cmd_index"
            if [ "$rc" -eq 0 ]; then
                SUCCESS_TOTAL=$((SUCCESS_TOTAL + 1))
            else
                FAIL_TOTAL=$((FAIL_TOTAL + 1))
                log_error "table collection failed table=$table_name rc=$rc cmd=$command_line"
            fi
        done <"$cmd_file"
    done

    render_table_md "$table_name" "$table_md" "$cmd_index"
}

render_summary() {
    cat >"$SUMMARY_FILE" <<EOF
# Sendcmd 采集摘要

- Sendcmd 可用性：\`available\`
- Table 数量：\`$TABLE_TOTAL\`
- 成功数量：\`$SUCCESS_TOTAL\`
- 失败数量：\`$FAIL_TOTAL\`
EOF
}

main() {
    init_layout
    render_readme

    if ! has_cmd "$SENDCMD_BIN"; then
        log_error "sendcmd command not found"
        render_missing_tool "sendcmd command not found"
        exit 0
    fi

    run_plugin_probes

    if [ ! -s "$TABLES_FILE" ]; then
        render_summary
        exit 0
    fi

    while IFS= read -r table_name; do
        [ -n "$table_name" ] || continue
        TABLE_TOTAL=$((TABLE_TOTAL + 1))
        collect_table "$table_name"
    done <"$TABLES_FILE"

    render_summary
}

main "$@"
