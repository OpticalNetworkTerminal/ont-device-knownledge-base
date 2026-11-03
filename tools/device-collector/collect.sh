#!/bin/sh

set -u

case "$0" in
    */*) _script_path=${0%/*} ;;
    *) _script_path=. ;;
esac
SCRIPT_DIR=$(CDPATH= cd -- "$_script_path" 2>/dev/null && pwd)
unset _script_path
COLLECT_BASE=""
EXTRA_ELF_DIRS=""
SKIP_ELF=0

. "${SCRIPT_DIR}/lib.sh"
. "${SCRIPT_DIR}/collect-host.sh"
. "${SCRIPT_DIR}/collect-lxc.sh"
. "${SCRIPT_DIR}/collect-elf.sh"
. "${SCRIPT_DIR}/collect-firmware.sh"

usage() {
    cat <<EOF
Usage:
  sh ./collect.sh [options]

Options:
  -o, --output DIR      Set output directory
  --elf-dir DIR         Add extra ELF scan directory
  --skip-elf            Skip ELF analysis
  -h, --help            Show this help
EOF
}

append_extra_elf_dir() {
    if [ -z "${EXTRA_ELF_DIRS}" ]; then
        EXTRA_ELF_DIRS=$1
    else
        EXTRA_ELF_DIRS="${EXTRA_ELF_DIRS} $1"
    fi
}

parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            -o|--output)
                shift
                [ $# -gt 0 ] || {
                    echo "missing argument for --output" >&2
                    exit 1
                }
                COLLECT_BASE=$1
                ;;
            --elf-dir)
                shift
                [ $# -gt 0 ] || {
                    echo "missing argument for --elf-dir" >&2
                    exit 1
                }
                append_extra_elf_dir "$1"
                ;;
            --skip-elf)
                SKIP_ELF=1
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                echo "unknown option: $1" >&2
                usage >&2
                exit 1
                ;;
        esac
        shift
    done
}

default_output_dir() {
    host_name=$(hostname 2>/dev/null || echo unknown)
    printf "%s/output/collect-%s-%s" "$SCRIPT_DIR" "$(safe_name "$host_name")" "$(timestamp_compact)"
}

run_plugins() {
    plugin_dir="${SCRIPT_DIR}/plugins"
    plugin_count=0

    if [ ! -d "$plugin_dir" ]; then
        return 0
    fi

    for plugin in "${plugin_dir}"/*.sh; do
        [ -f "$plugin" ] || continue
        plugin_name=$(path_basename "$plugin")
        case "$plugin_name" in
            example-*|README*)
                continue
                ;;
        esac
        plugin_count=$((plugin_count + 1))
        run_exec "plugins" "$plugin_name" sh "$plugin" "$COLLECT_BASE" "$ENV_FILE"
    done

    write_text "${COLLECT_BASE}/logs/plugins.txt" "plugin_count=${plugin_count}"
}

main() {
    parse_args "$@"

    if [ -z "${COLLECT_BASE}" ]; then
        COLLECT_BASE=$(default_output_dir)
    fi

    init_output_tree
    detect_environment
    detect_supported_tools

    collect_host_all

    if [ "$(get_env_value IS_OPENWRT)" = "1" ] || [ "$(get_env_value IS_LXC)" = "1" ]; then
        collect_lxc_all
    else
        write_text "${COLLECT_BASE}/lxc/README.txt" \
            "LXC/OpenWrt collector was not activated." \
            "Reason: environment detection did not identify OpenWrt or LXC."
    fi

    if [ "$SKIP_ELF" -eq 0 ]; then
        collect_elf_all
    else
        write_text "${COLLECT_BASE}/elf/README.txt" "ELF collection skipped by --skip-elf."
    fi

    collect_firmware_all
    run_exec "modules" "ubus-dump" sh "${SCRIPT_DIR}/ubus-dump.sh" -o "${COLLECT_BASE}/ubus"
    run_exec "modules" "sendcmd-dump" sh "${SCRIPT_DIR}/sendcmd-dump.sh" -o "${COLLECT_BASE}/sendcmd"
    run_exec "modules" "filesystem-dump" sh "${SCRIPT_DIR}/filesystem-dump.sh" -o "${COLLECT_BASE}/filesystem"
    run_plugins
    generate_summary

    printf "%s\n" "$COLLECT_BASE"
}

main "$@"
