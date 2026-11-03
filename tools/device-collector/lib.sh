#!/bin/sh

# Common helpers for ONT Device Collector.

case "$0" in
    */*) _script_path=${0%/*} ;;
    *) _script_path=. ;;
esac
SCRIPT_DIR=$(CDPATH= cd -- "$_script_path" 2>/dev/null && pwd)
unset _script_path

COLLECTOR_NAME="ont-device-collector"
COLLECTOR_VERSION="0.1.0"

if [ -z "${COLLECT_BASE:-}" ]; then
    COLLECT_BASE="${SCRIPT_DIR}/output/collect-unknown"
fi

LOG_DIR=""
RUN_LOG=""
FAIL_LOG=""
ENV_FILE=""
TOOL_FILE=""

timestamp_utc() {
    date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date
}

timestamp_compact() {
    date +"%Y%m%d-%H%M%S" 2>/dev/null || echo "unknown-time"
}

safe_name() {
    printf "%s" "$1" | sed 's#[/[:space:]]#_#g; s#[^A-Za-z0-9_.-]#_#g'
}

log_line() {
    if [ -n "${LOG_DIR}" ]; then
        printf "%s %s\n" "$(timestamp_utc)" "$1" >> "${LOG_DIR}/collector.log"
    fi
}

ensure_dir() {
    if [ -n "$1" ] && [ ! -d "$1" ]; then
        mkdir -p "$1"
    fi
}

has_cmd() {
    command -v "$1" >/dev/null 2>&1
}

path_dirname() {
    case "$1" in
        */*) printf "%s\n" "${1%/*}" ;;
        *) printf ".\n" ;;
    esac
}

path_basename() {
    case "$1" in
        */) path_basename "${1%/}" ;;
        */*) printf "%s\n" "${1##*/}" ;;
        *) printf "%s\n" "$1" ;;
    esac
}

first_line() {
    if [ -f "$1" ]; then
        sed -n '1p' "$1"
    fi
}

last_matching_env_value() {
    key=$1
    file=$2
    awk -F= -v want="$key" '$1 == want { value=substr($0, index($0, "=") + 1) } END { if (value != "") print value }' "$file" 2>/dev/null
}

write_text() {
    out_file=$1
    shift
    ensure_dir "$(path_dirname "$out_file")"
    {
        for line in "$@"; do
            printf "%s\n" "$line"
        done
    } > "$out_file"
}

append_env() {
    key=$1
    value=$2
    if [ -n "${ENV_FILE}" ]; then
        printf "%s=%s\n" "$key" "$value" >> "$ENV_FILE"
    fi
}

get_env_value() {
    key=$1
    if [ -f "${ENV_FILE}" ]; then
        last_matching_env_value "$key" "${ENV_FILE}"
    fi
}

copy_file() {
    src=$1
    out_file=$2
    if [ -r "$src" ]; then
        ensure_dir "$(path_dirname "$out_file")"
        cat "$src" > "$out_file" 2>/dev/null
        return 0
    fi
    return 1
}

record_file() {
    section=$1
    label=$2
    src=$3
    out_dir="${COLLECT_BASE}/${section}"
    ensure_dir "$out_dir"
    out_file="${out_dir}/$(safe_name "$label").txt"
    if copy_file "$src" "$out_file"; then
        log_line "FILE OK section=${section} label=${label} src=${src} dst=${out_file}"
        return 0
    fi
    printf "%s section=%s label=%s src=%s\n" "$(timestamp_utc)" "$section" "$label" "$src" >> "$FAIL_LOG"
    log_line "FILE FAIL section=${section} label=${label} src=${src}"
    return 1
}

init_output_tree() {
    ensure_dir "$COLLECT_BASE"
    LOG_DIR="${COLLECT_BASE}/logs"
    RUN_LOG="${LOG_DIR}/commands.log"
    FAIL_LOG="${LOG_DIR}/failures.log"
    ENV_FILE="${COLLECT_BASE}/environment.txt"
    TOOL_FILE="${COLLECT_BASE}/supported-tools.txt"

    ensure_dir "${COLLECT_BASE}/host"
    ensure_dir "${COLLECT_BASE}/lxc"
    ensure_dir "${COLLECT_BASE}/elf"
    ensure_dir "${COLLECT_BASE}/firmware"
    ensure_dir "${LOG_DIR}"

    : > "${LOG_DIR}/collector.log"
    : > "${RUN_LOG}"
    : > "${FAIL_LOG}"
    : > "${ENV_FILE}"
    : > "${TOOL_FILE}"
}

_run_begin() {
    RUN_SECTION=$1
    RUN_NAME=$2
    RUN_DIR="${LOG_DIR}/$(safe_name "$RUN_SECTION")"
    RUN_BASE="$(safe_name "$RUN_NAME")"
    RUN_SECTION_DIR="${COLLECT_BASE}/${RUN_SECTION}"
    RUN_STDOUT="${RUN_DIR}/${RUN_BASE}.stdout"
    RUN_STDERR="${RUN_DIR}/${RUN_BASE}.stderr"
    RUN_META="${RUN_DIR}/${RUN_BASE}.meta"
    RUN_SECTION_STDOUT="${RUN_SECTION_DIR}/${RUN_BASE}.stdout"
    RUN_SECTION_STDERR="${RUN_SECTION_DIR}/${RUN_BASE}.stderr"
    RUN_SECTION_META="${RUN_SECTION_DIR}/${RUN_BASE}.meta"
    RUN_START_TS=$(date +%s 2>/dev/null || echo 0)

    ensure_dir "$RUN_DIR"
    ensure_dir "$RUN_SECTION_DIR"

    {
        printf "section=%s\n" "$RUN_SECTION"
        printf "name=%s\n" "$RUN_NAME"
        printf "started_at=%s\n" "$(timestamp_utc)"
    } > "$RUN_META"
}

_run_end() {
    run_rc=$1
    run_kind=$2
    run_detail=$3
    RUN_END_TS=$(date +%s 2>/dev/null || echo "$RUN_START_TS")
    RUN_ELAPSED=$((RUN_END_TS - RUN_START_TS))

    {
        printf "kind=%s\n" "$run_kind"
        printf "detail=%s\n" "$run_detail"
        printf "exit_code=%s\n" "$run_rc"
        printf "elapsed_seconds=%s\n" "$RUN_ELAPSED"
        printf "stdout=%s\n" "$RUN_STDOUT"
        printf "stderr=%s\n" "$RUN_STDERR"
    } >> "$RUN_META"

    cat "$RUN_STDOUT" > "$RUN_SECTION_STDOUT" 2>/dev/null || :
    cat "$RUN_STDERR" > "$RUN_SECTION_STDERR" 2>/dev/null || :
    cat "$RUN_META" > "$RUN_SECTION_META" 2>/dev/null || :

    printf "%s section=%s name=%s rc=%s elapsed=%s kind=%s detail=%s\n" \
        "$(timestamp_utc)" "$RUN_SECTION" "$RUN_NAME" "$run_rc" "$RUN_ELAPSED" "$run_kind" "$run_detail" >> "$RUN_LOG"

    if [ "$run_rc" -ne 0 ]; then
        printf "%s section=%s name=%s rc=%s kind=%s detail=%s\n" \
            "$(timestamp_utc)" "$RUN_SECTION" "$RUN_NAME" "$run_rc" "$run_kind" "$run_detail" >> "$FAIL_LOG"
        log_line "RUN FAIL section=${RUN_SECTION} name=${RUN_NAME} rc=${run_rc}"
    else
        log_line "RUN OK section=${RUN_SECTION} name=${RUN_NAME} rc=${run_rc}"
    fi

    return "$run_rc"
}

run_cmd() {
    section=$1
    name=$2
    cmd=$3

    _run_begin "$section" "$name"
    sh -c "$cmd" > "$RUN_STDOUT" 2> "$RUN_STDERR"
    rc=$?
    _run_end "$rc" "shell" "$cmd"
    return "$rc"
}

run_exec() {
    section=$1
    name=$2
    shift 2

    _run_begin "$section" "$name"
    "$@" > "$RUN_STDOUT" 2> "$RUN_STDERR"
    rc=$?
    _run_end "$rc" "exec" "$*"
    return "$rc"
}

detect_environment() {
    host_name=$(hostname 2>/dev/null || uname -n 2>/dev/null || echo unknown)
    kernel=$(uname -s 2>/dev/null || echo unknown)
    kernel_release=$(uname -r 2>/dev/null || echo unknown)
    arch=$(uname -m 2>/dev/null || echo unknown)

    is_busybox=0
    is_openwrt=0
    is_buildroot=0
    is_lxc=0
    libc_hint=unknown

    if has_cmd busybox || [ -x /bin/busybox ] || [ -x /sbin/busybox ]; then
        is_busybox=1
    fi

    if [ -f /etc/openwrt_release ] || [ -d /etc/config ] || [ -f /rom/etc/openwrt_release ]; then
        is_openwrt=1
    fi

    if [ -f /etc/os-release ] && grep -qi "buildroot" /etc/os-release 2>/dev/null; then
        is_buildroot=1
    elif [ -f /etc/issue ] && grep -qi "buildroot" /etc/issue 2>/dev/null; then
        is_buildroot=1
    fi

    if [ -f /proc/1/environ ] && tr '\0' '\n' < /proc/1/environ 2>/dev/null | grep -qi '^container=lxc$'; then
        is_lxc=1
    elif [ -f /proc/1/cgroup ] && grep -qi "lxc" /proc/1/cgroup 2>/dev/null; then
        is_lxc=1
    elif [ -d /dev/lxc ] || [ -f /.dockerenv ]; then
        is_lxc=1
    fi

    if [ -e /lib/ld-musl-"$arch".so.1 ] || ls /lib/libc.musl-* >/dev/null 2>&1 || ls /usr/lib/libc.musl-* >/dev/null 2>&1; then
        libc_hint=musl
    elif ls /lib/libuClibc-* >/dev/null 2>&1 || ls /lib/libuClibc.so* >/dev/null 2>&1; then
        libc_hint=uclibc
    elif ls /lib/libc.so.6 >/dev/null 2>&1 || ls /usr/lib/libc.so.6 >/dev/null 2>&1; then
        libc_hint=glibc
    fi

    append_env "COLLECTOR_NAME" "$COLLECTOR_NAME"
    append_env "COLLECTOR_VERSION" "$COLLECTOR_VERSION"
    append_env "HOSTNAME" "$host_name"
    append_env "KERNEL" "$kernel"
    append_env "KERNEL_RELEASE" "$kernel_release"
    append_env "ARCH" "$arch"
    append_env "IS_BUSYBOX" "$is_busybox"
    append_env "IS_OPENWRT" "$is_openwrt"
    append_env "IS_BUILDROOT" "$is_buildroot"
    append_env "IS_LXC" "$is_lxc"
    append_env "LIBC_HINT" "$libc_hint"

    {
        printf "collector=%s\n" "$COLLECTOR_NAME"
        printf "version=%s\n" "$COLLECTOR_VERSION"
        printf "hostname=%s\n" "$host_name"
        printf "kernel=%s\n" "$kernel"
        printf "kernel_release=%s\n" "$kernel_release"
        printf "arch=%s\n" "$arch"
        printf "busybox=%s\n" "$is_busybox"
        printf "openwrt=%s\n" "$is_openwrt"
        printf "buildroot=%s\n" "$is_buildroot"
        printf "lxc=%s\n" "$is_lxc"
        printf "libc=%s\n" "$libc_hint"
    } > "${COLLECT_BASE}/environment.detected.txt"
}

detect_supported_tools() {
    tools="sendcmd sidbg dbus-send gdbus ubus uci opkg iptables nft fw_printenv fw_setenv ip ifconfig route brctl busybox file readelf objdump strings lscpu ubinfo top ps mount"
    : > "$TOOL_FILE"
    for tool in $tools; do
        if has_cmd "$tool"; then
            printf "%s\tavailable\t%s\n" "$tool" "$(command -v "$tool" 2>/dev/null)" >> "$TOOL_FILE"
        else
            printf "%s\tmissing\t-\n" "$tool" >> "$TOOL_FILE"
        fi
    done
}

json_escape() {
    printf "%s" "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

first_line_of() {
    file=$1
    first_line "$file"
}

generate_summary() {
    summary_md="${COLLECT_BASE}/summary.md"
    summary_json="${COLLECT_BASE}/summary.json"

    cpu_model=$(sed -n 's/^model name[[:space:]]*:[[:space:]]*//p' "${COLLECT_BASE}/host/cpu/cpuinfo.txt" 2>/dev/null | sed -n '1p')
    if [ -z "$cpu_model" ]; then
        cpu_model=$(sed -n 's/^Hardware[[:space:]]*:[[:space:]]*//p' "${COLLECT_BASE}/host/cpu/cpuinfo.txt" 2>/dev/null | sed -n '1p')
    fi
    [ -n "$cpu_model" ] || cpu_model="unknown"

    mem_total=$(sed -n 's/^MemTotal:[[:space:]]*//p' "${COLLECT_BASE}/host/memory/meminfo.txt" 2>/dev/null | sed -n '1p')
    [ -n "$mem_total" ] || mem_total="unknown"

    kernel=$(get_env_value KERNEL_RELEASE)
    [ -n "$kernel" ] || kernel="unknown"
    arch=$(get_env_value ARCH)
    [ -n "$arch" ] || arch="unknown"
    busybox=$(get_env_value IS_BUSYBOX)
    buildroot=$(get_env_value IS_BUILDROOT)
    openwrt=$(get_env_value IS_OPENWRT)
    lxc=$(get_env_value IS_LXC)
    libc=$(get_env_value LIBC_HINT)

    dbus_state="absent"
    if grep -Eq '^(dbus-send|gdbus)[[:space:]]+available' "$TOOL_FILE" 2>/dev/null; then
        dbus_state="available"
    fi

    ubus_state="absent"
    if grep -Eq '^ubus[[:space:]]+available' "$TOOL_FILE" 2>/dev/null; then
        ubus_state="available"
    fi

    sendcmd_state="absent"
    if grep -Eq '^sendcmd[[:space:]]+available' "$TOOL_FILE" 2>/dev/null; then
        sendcmd_state="available"
    fi

    sidbg_state="absent"
    if grep -Eq '^sidbg[[:space:]]+available' "$TOOL_FILE" 2>/dev/null; then
        sidbg_state="available"
    fi

    overlay_hint="unknown"
    if grep -qi "overlay" "${COLLECT_BASE}/host/mount/filesystems.txt" 2>/dev/null || grep -qi "overlay" "${COLLECT_BASE}/host/filesystem/overlay.txt" 2>/dev/null; then
        overlay_hint="present"
    fi

    rootfs_hint="unknown"
    if grep -qi "rootfs" "${COLLECT_BASE}/host/mount/mount.txt" 2>/dev/null || grep -qi "rootfs" "${COLLECT_BASE}/lxc/filesystem/rootfs.txt" 2>/dev/null; then
        rootfs_hint="present"
    fi

    flash_hint="unknown"
    if [ -f "${COLLECT_BASE}/host/flash/proc_mtd.txt" ] || [ -f "${COLLECT_BASE}/host/flash/ubi_devices.txt" ]; then
        flash_hint="present"
    fi

    {
        printf "# Collection Summary\n\n"
        printf "| Item | Value |\n"
        printf "| --- | --- |\n"
        printf "| CPU | %s |\n" "$cpu_model"
        printf "| Kernel | %s |\n" "$kernel"
        printf "| Buildroot | %s |\n" "$buildroot"
        printf "| OpenWrt | %s |\n" "$openwrt"
        printf "| BusyBox | %s |\n" "$busybox"
        printf "| Architecture | %s |\n" "$arch"
        printf "| libc | %s |\n" "$libc"
        printf "| Flash | %s |\n" "$flash_hint"
        printf "| Memory | %s |\n" "$mem_total"
        printf "| DBus | %s |\n" "$dbus_state"
        printf "| ubus | %s |\n" "$ubus_state"
        printf "| sendcmd | %s |\n" "$sendcmd_state"
        printf "| sidbg | %s |\n" "$sidbg_state"
        printf "| LXC | %s |\n" "$lxc"
        printf "| Overlay | %s |\n" "$overlay_hint"
        printf "| Rootfs | %s |\n" "$rootfs_hint"
    } > "$summary_md"

    {
        printf "{\n"
        printf "  \"collector\": \"%s\",\n" "$(json_escape "$COLLECTOR_NAME")"
        printf "  \"version\": \"%s\",\n" "$(json_escape "$COLLECTOR_VERSION")"
        printf "  \"cpu\": \"%s\",\n" "$(json_escape "$cpu_model")"
        printf "  \"kernel\": \"%s\",\n" "$(json_escape "$kernel")"
        printf "  \"buildroot\": \"%s\",\n" "$(json_escape "$buildroot")"
        printf "  \"openwrt\": \"%s\",\n" "$(json_escape "$openwrt")"
        printf "  \"busybox\": \"%s\",\n" "$(json_escape "$busybox")"
        printf "  \"architecture\": \"%s\",\n" "$(json_escape "$arch")"
        printf "  \"libc\": \"%s\",\n" "$(json_escape "$libc")"
        printf "  \"flash\": \"%s\",\n" "$(json_escape "$flash_hint")"
        printf "  \"memory\": \"%s\",\n" "$(json_escape "$mem_total")"
        printf "  \"dbus\": \"%s\",\n" "$(json_escape "$dbus_state")"
        printf "  \"ubus\": \"%s\",\n" "$(json_escape "$ubus_state")"
        printf "  \"sendcmd\": \"%s\",\n" "$(json_escape "$sendcmd_state")"
        printf "  \"sidbg\": \"%s\",\n" "$(json_escape "$sidbg_state")"
        printf "  \"lxc\": \"%s\",\n" "$(json_escape "$lxc")"
        printf "  \"overlay\": \"%s\",\n" "$(json_escape "$overlay_hint")"
        printf "  \"rootfs\": \"%s\"\n" "$(json_escape "$rootfs_hint")"
        printf "}\n"
    } > "$summary_json"
}
