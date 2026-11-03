#!/bin/sh

set -u

case "$0" in
    */*) _script_path=${0%/*} ;;
    *) _script_path=. ;;
esac
SCRIPT_DIR=$(CDPATH= cd -- "$_script_path" 2>/dev/null && pwd)
unset _script_path

. "$SCRIPT_DIR/lib/common.sh"

OUT_DIR="filesystem"
TREE_DEPTH="${TREE_DEPTH:-3}"
SOCKET_DEPTH="${SOCKET_DEPTH:-5}"
CONFIG_MAX_SIZE_KB="${CONFIG_MAX_SIZE_KB:-512}"

RUN_LOG=""
ERROR_LOG=""
SUMMARY_FILE=""

DIR_COUNT=0
CONFIG_COUNT=0
EXEC_COUNT=0
SOCKET_COUNT=0
OVERLAY_HINT="unknown"
FLASH_HINT="unknown"

usage() {
    cat <<EOF
Usage: sh ./filesystem-dump.sh [-o output_dir] [-d tree_depth]

Options:
  -o DIR     Output directory. Default: filesystem
  -d NUM     Directory tree max depth. Default: 3
  -h         Show this help
EOF
}

while getopts "o:d:h" opt; do
    case "$opt" in
        o) OUT_DIR="$OPTARG" ;;
        d) TREE_DEPTH="$OPTARG" ;;
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

run_capture_plain() {
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

init_layout() {
    RUN_LOG="$OUT_DIR/logs/run.log"
    ERROR_LOG="$OUT_DIR/logs/error.log"
    SUMMARY_FILE="$OUT_DIR/summary.md"

    ensure_dir "$OUT_DIR"
    ensure_dir "$OUT_DIR/logs"
    ensure_dir "$OUT_DIR/tree"
    ensure_dir "$OUT_DIR/configs"
    ensure_dir "$OUT_DIR/executables"
    ensure_dir "$OUT_DIR/state"

    : >"$RUN_LOG"
    : >"$ERROR_LOG"
}

render_readme() {
    cat >"$OUT_DIR/README.md" <<EOF
# Filesystem Dump

该目录由 \`filesystem-dump.sh\` 自动生成。

## 内容说明

- \`tree/\`：受控深度的目录树
- \`configs/\`：配置文件索引
- \`executables/\`：可执行文件索引
- \`overlay.md\`：Overlay / Union / RootFS 线索
- \`summary.md\`：采集统计摘要
- \`logs/\`：运行日志

## 设计约束

- BusyBox 优先兼容
- 仅做浅层目录结构采集
- 避免扫描整个文件系统造成过长运行时间
- 仅建立索引，不读取超大配置文件
EOF
}

collect_system_files() {
    run_capture_plain "$OUT_DIR/mount.txt" mount
    if [ -r /proc/mounts ]; then
        cat /proc/mounts >"$OUT_DIR/proc_mounts.txt" 2>/dev/null
    fi
    if [ -r /proc/filesystems ]; then
        cat /proc/filesystems >"$OUT_DIR/proc_filesystems.txt" 2>/dev/null
    fi
    if has_cmd df; then
        run_capture_plain "$OUT_DIR/df.txt" df
    fi
}

collect_flash_info() {
    if [ -r /proc/mtd ]; then
        cat /proc/mtd >"$OUT_DIR/proc_mtd.txt" 2>/dev/null
        FLASH_HINT="present"
    fi
    if [ -d /sys/class/ubi ]; then
        FLASH_HINT="present"
        find /sys/class/ubi -maxdepth 3 -type f 2>/dev/null | sort >"$OUT_DIR/ubi-files.txt"
    fi
    if has_cmd ubinfo; then
        run_capture_plain "$OUT_DIR/ubinfo.txt" ubinfo -a
        FLASH_HINT="present"
    fi
}

tree_dir() {
    target=$1
    label=$2
    out_file="$OUT_DIR/tree/${label}.txt"
    if [ -d "$target" ]; then
        find "$target" -maxdepth "$TREE_DEPTH" \( -type d -o -type f -o -type l \) 2>/dev/null | sort >"$out_file"
        count=$(find "$target" -maxdepth "$TREE_DEPTH" -type d 2>/dev/null | wc -l | tr -d ' ')
        DIR_COUNT=$((DIR_COUNT + count))
    else
        printf 'missing: %s\n' "$target" >"$out_file"
    fi
}

collect_trees() {
    tree_dir / root
    tree_dir /etc etc
    tree_dir /bin bin
    tree_dir /sbin sbin
    tree_dir /usr usr
    tree_dir /opt opt
    tree_dir /tmp tmp
    tree_dir /var var
    tree_dir /mnt mnt
    tree_dir /map map
    tree_dir /root root-home
    tree_dir /dev dev
    tree_dir /proc proc
    tree_dir /sys sys
}

collect_overlay() {
    {
        echo "# Overlay Analysis"
        echo
        echo "## Mount Hints"
        echo
        echo '```text'
        mount 2>/dev/null | grep -Ei 'overlay|union|jffs2|ubifs|rootfs'
        echo '```'
        echo
        echo "## upperdir/lowerdir/workdir"
        echo
        echo '```text'
        mount 2>/dev/null | grep -E 'upperdir=|lowerdir=|workdir='
        echo '```'
    } >"$OUT_DIR/overlay.md"

    if grep -Eiq 'overlay|union|jffs2|ubifs|upperdir=|lowerdir=|workdir=' "$OUT_DIR/overlay.md" 2>/dev/null; then
        OVERLAY_HINT="present"
    fi
}

collect_config_index() {
    config_index="$OUT_DIR/configs/index.tsv"
    config_list="$OUT_DIR/state/config-files.txt"
    : >"$config_index"
    : >"$config_list"
    printf "path\tsize_bytes\tmode\tmtime\n" >>"$config_index"

    for base in /etc /usr /opt /var /mnt /map /root; do
        [ -d "$base" ] || continue
        find "$base" -maxdepth "$TREE_DEPTH" -type f \
            \( -name '*.xml' -o -name '*.conf' -o -name '*.cfg' -o -name '*.ini' -o -name '*.json' -o -name '*.yaml' -o -name '*.yml' -o -name '*.db' \) \
            -size -"${CONFIG_MAX_SIZE_KB}"k 2>/dev/null | sort >>"$config_list"
    done

    if [ -f "$config_list" ]; then
        sort -u "$config_list" -o "$config_list"
        while IFS= read -r file; do
            [ -n "$file" ] || continue
            size=$(wc -c "$file" 2>/dev/null | awk '{print $1}')
            mode=$(ls -ld "$file" 2>/dev/null | awk '{print $1}')
            mtime=$(ls -ld "$file" 2>/dev/null | awk '{print $6" "$7" "$8}')
            printf "%s\t%s\t%s\t%s\n" "$file" "${size:-0}" "${mode:-unknown}" "${mtime:-unknown}" >>"$config_index"
            CONFIG_COUNT=$((CONFIG_COUNT + 1))
        done <"$config_list"
    fi
}

collect_executable_index() {
    exec_index="$OUT_DIR/executables/index.tsv"
    exec_list="$OUT_DIR/state/executable-files.txt"
    : >"$exec_index"
    : >"$exec_list"
    printf "path\tmode\tsize_bytes\n" >>"$exec_index"

    for base in /bin /sbin /usr/bin /usr/sbin /opt; do
        [ -d "$base" ] || continue
        find "$base" -maxdepth 2 -type f -perm -111 2>/dev/null | sort >>"$exec_list"
    done

    if [ -f "$exec_list" ]; then
        sort -u "$exec_list" -o "$exec_list"
        while IFS= read -r file; do
            [ -n "$file" ] || continue
            size=$(wc -c "$file" 2>/dev/null | awk '{print $1}')
            mode=$(ls -ld "$file" 2>/dev/null | awk '{print $1}')
            printf "%s\t%s\t%s\n" "$file" "${mode:-unknown}" "${size:-0}" >>"$exec_index"
            EXEC_COUNT=$((EXEC_COUNT + 1))
        done <"$exec_list"
    fi
}

collect_sockets() {
    socket_file="$OUT_DIR/sockets.txt"
    if [ -d /run ] || [ -d /var/run ]; then
        find /run /var/run -maxdepth "$SOCKET_DEPTH" -type s 2>/dev/null | sort >"$socket_file"
    else
        find /tmp -maxdepth "$SOCKET_DEPTH" -type s 2>/dev/null | sort >"$socket_file"
    fi

    if [ -f "$socket_file" ]; then
        SOCKET_COUNT=$(wc -l <"$socket_file" | tr -d ' ')
    fi
}

render_summary() {
    cat >"$SUMMARY_FILE" <<EOF
# Filesystem 采集摘要

- 目录数量：\`$DIR_COUNT\`
- 配置文件数量：\`$CONFIG_COUNT\`
- 可执行文件数量：\`$EXEC_COUNT\`
- Socket 数量：\`$SOCKET_COUNT\`
- Overlay 信息：\`$OVERLAY_HINT\`
- Flash 信息：\`$FLASH_HINT\`
EOF
}

main() {
    init_layout
    render_readme
    collect_system_files
    collect_flash_info
    collect_trees
    collect_overlay
    collect_config_index
    collect_executable_index
    collect_sockets
    render_summary
}

main "$@"
