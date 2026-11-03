#!/bin/sh

collect_host_system() {
    ensure_dir "${COLLECT_BASE}/host/system"
    run_cmd "host/system" "uname" "uname -a"
    record_file "host/system" "os-release" "/etc/os-release"
    record_file "host/system" "openwrt-release" "/etc/openwrt_release"
    record_file "host/system" "version-proc" "/proc/version"
    run_cmd "host/system" "hostname" "hostname"
    run_cmd "host/system" "uptime" "uptime"
}

collect_host_cpu() {
    ensure_dir "${COLLECT_BASE}/host/cpu"
    record_file "host/cpu" "cpuinfo" "/proc/cpuinfo"
    if has_cmd lscpu; then
        run_cmd "host/cpu" "lscpu" "lscpu"
    fi
}

collect_host_memory() {
    ensure_dir "${COLLECT_BASE}/host/memory"
    record_file "host/memory" "meminfo" "/proc/meminfo"
}

collect_host_flash() {
    ensure_dir "${COLLECT_BASE}/host/flash"
    record_file "host/flash" "proc_mtd" "/proc/mtd"
    record_file "host/flash" "ubi_devices" "/sys/class/ubi/version"
    if has_cmd ubinfo; then
        run_cmd "host/flash" "ubinfo-a" "ubinfo -a"
    fi
    if [ -d /sys/class/ubi ]; then
        run_cmd "host/flash" "sysfs-ubi" "find /sys/class/ubi -maxdepth 3 -type f 2>/dev/null | sort | while IFS= read -r f; do printf '>>> %s\n' \"\$f\"; sed -n '1,5p' \"\$f\" 2>/dev/null; done"
    fi
}

collect_host_mount() {
    ensure_dir "${COLLECT_BASE}/host/mount"
    run_cmd "host/mount" "mount" "mount"
    record_file "host/mount" "filesystems" "/proc/filesystems"
    record_file "host/mount" "mounts" "/proc/mounts"
}

collect_host_process() {
    ensure_dir "${COLLECT_BASE}/host/process"
    run_cmd "host/process" "ps" "ps"
    if has_cmd top; then
        run_cmd "host/process" "top" "top -b -n 1"
    fi
}

collect_host_network() {
    ensure_dir "${COLLECT_BASE}/host/network"
    if has_cmd ip; then
        run_cmd "host/network" "ip-address" "ip address"
        run_cmd "host/network" "ip-link" "ip link"
        run_cmd "host/network" "ip-route" "ip route"
        run_cmd "host/network" "ip-neigh" "ip neigh"
        run_cmd "host/network" "ip-ipv6-route" "ip -6 route"
    fi
    if has_cmd ifconfig; then
        run_cmd "host/network" "ifconfig-a" "ifconfig -a"
    fi
    if has_cmd brctl; then
        run_cmd "host/network" "brctl-show" "brctl show"
    fi
    if has_cmd route; then
        run_cmd "host/network" "route-n" "route -n"
    fi
    record_file "host/network" "arp" "/proc/net/arp"
    record_file "host/network" "ipv6_route" "/proc/net/ipv6_route"
    record_file "host/network" "dev" "/proc/net/dev"
}

collect_host_filesystem() {
    ensure_dir "${COLLECT_BASE}/host/filesystem"
    run_cmd "host/filesystem" "root-list" "ls -la /"
    run_cmd "host/filesystem" "etc-list" "ls -la /etc"
    run_cmd "host/filesystem" "var-list" "ls -la /var"
    run_cmd "host/filesystem" "tmp-list" "ls -la /tmp"
    run_cmd "host/filesystem" "overlay" "mount | grep -i overlay"
    run_cmd "host/filesystem" "rootfs" "mount | grep -i rootfs"
    run_cmd "host/filesystem" "jffs2" "mount | grep -i jffs2"
    run_cmd "host/filesystem" "ubifs" "mount | grep -i ubifs"
}

collect_host_dbus() {
    ensure_dir "${COLLECT_BASE}/host/dbus"
    if has_cmd dbus-send; then
        run_cmd "host/dbus" "dbus-send-help" "dbus-send --help"
    fi
    if has_cmd gdbus; then
        run_cmd "host/dbus" "gdbus-help" "gdbus help"
    fi
    run_cmd "host/dbus" "dbus-sockets" "find /var/run /run -maxdepth 3 -type s 2>/dev/null | grep -i dbus"
    run_cmd "host/dbus" "dbus-files" "find /etc /usr/share -maxdepth 3 \\( -name '*dbus*' -o -name '*DBus*' \\) 2>/dev/null | sort"
}

collect_host_ubus() {
    ensure_dir "${COLLECT_BASE}/host/ubus"
    if has_cmd ubus; then
        run_cmd "host/ubus" "ubus-list" "ubus list"
    fi
}

collect_host_vendor_tools() {
    ensure_dir "${COLLECT_BASE}/host/vendor-tools"
    if has_cmd sendcmd; then
        run_cmd "host/vendor-tools" "sendcmd-help" "sendcmd 2>&1"
    fi
    if has_cmd sidbg; then
        run_cmd "host/vendor-tools" "sidbg-help" "sidbg 2>&1"
    fi
}

collect_host_tool_inventory() {
    ensure_dir "${COLLECT_BASE}/host/tools"
    run_cmd "host/tools" "tool-paths" 'for t in sendcmd sidbg dbus-send gdbus ubus uci opkg iptables nft fw_printenv fw_setenv ip ifconfig route brctl busybox file readelf objdump strings; do p=$(command -v "$t" 2>/dev/null); if [ -n "$p" ]; then printf "%s\t%s\n" "$t" "$p"; fi; done'
}

collect_host_environment() {
    ensure_dir "${COLLECT_BASE}/host/environment"
    run_cmd "host/environment" "env" "env | sort"
}

collect_host_modules() {
    ensure_dir "${COLLECT_BASE}/host/kernel"
    record_file "host/kernel" "modules" "/proc/modules"
    record_file "host/kernel" "cmdline" "/proc/cmdline"
}

collect_host_versions() {
    ensure_dir "${COLLECT_BASE}/host/versions"
    if has_cmd busybox; then
        run_cmd "host/versions" "busybox" "busybox"
    fi
    if has_cmd opkg; then
        run_cmd "host/versions" "opkg-version" "opkg --version"
    fi
    if has_cmd uci; then
        run_cmd "host/versions" "uci-version" "uci -V"
    fi
    if has_cmd ubus; then
        run_cmd "host/versions" "ubus-help" "ubus -v"
    fi
}

collect_host_all() {
    collect_host_system
    collect_host_cpu
    collect_host_memory
    collect_host_flash
    collect_host_mount
    collect_host_process
    collect_host_network
    collect_host_filesystem
    collect_host_dbus
    collect_host_ubus
    collect_host_vendor_tools
    collect_host_tool_inventory
    collect_host_environment
    collect_host_modules
    collect_host_versions
}
