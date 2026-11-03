#!/bin/sh

collect_lxc_core() {
    ensure_dir "${COLLECT_BASE}/lxc/runtime"
    run_cmd "lxc/runtime" "ps" "ps"
    run_cmd "lxc/runtime" "mount" "mount"
    record_file "lxc/runtime" "mounts" "/proc/mounts"
    record_file "lxc/runtime" "cgroup" "/proc/1/cgroup"
}

collect_lxc_procd() {
    ensure_dir "${COLLECT_BASE}/lxc/procd"
    run_cmd "lxc/procd" "procd-process" "ps | grep '[p]rocd'"
    if has_cmd ubus; then
        run_cmd "lxc/procd" "ubus-service-list" "ubus list 2>/dev/null | grep -E 'service|system|network'"
    fi
}

collect_lxc_ubus_rpcd() {
    ensure_dir "${COLLECT_BASE}/lxc/ubus"
    if has_cmd ubus; then
        run_cmd "lxc/ubus" "ubus-list" "ubus list"
        run_cmd "lxc/ubus" "ubus-system-board" "ubus call system board"
        run_cmd "lxc/ubus" "ubus-network-interface" "ubus call network.interface dump"
    fi
    run_cmd "lxc/ubus" "rpcd-process" "ps | grep '[r]pcd'"
}

collect_lxc_uci() {
    ensure_dir "${COLLECT_BASE}/lxc/uci"
    if has_cmd uci; then
        run_cmd "lxc/uci" "uci-show" "uci show"
        run_cmd "lxc/uci" "uci-export-network" "uci export network"
        run_cmd "lxc/uci" "uci-export-wireless" "uci export wireless"
        run_cmd "lxc/uci" "uci-export-system" "uci export system"
    fi
}

collect_lxc_network() {
    ensure_dir "${COLLECT_BASE}/lxc/network"
    if has_cmd ip; then
        run_cmd "lxc/network" "ip-address" "ip address"
        run_cmd "lxc/network" "ip-route" "ip route"
        run_cmd "lxc/network" "ip-link" "ip link"
    fi
    if has_cmd ifconfig; then
        run_cmd "lxc/network" "ifconfig-a" "ifconfig -a"
    fi
    if has_cmd ubus; then
        run_cmd "lxc/network" "ubus-network-dump" "ubus call network.interface dump"
    fi
    record_file "lxc/network" "resolv.conf" "/etc/resolv.conf"
}

collect_lxc_wireless() {
    ensure_dir "${COLLECT_BASE}/lxc/wireless"
    if has_cmd ubus; then
        run_cmd "lxc/wireless" "ubus-wireless-status" "ubus call network.wireless status"
    fi
    if has_cmd uci; then
        run_cmd "lxc/wireless" "uci-wireless" "uci export wireless"
    fi
}

collect_lxc_packages() {
    ensure_dir "${COLLECT_BASE}/lxc/packages"
    if has_cmd opkg; then
        run_cmd "lxc/packages" "opkg-list-installed" "opkg list-installed"
    fi
}

collect_lxc_filesystem() {
    ensure_dir "${COLLECT_BASE}/lxc/filesystem"
    run_cmd "lxc/filesystem" "overlay" "mount | grep -i overlay"
    run_cmd "lxc/filesystem" "rootfs" "mount | grep -i rootfs"
    run_cmd "lxc/filesystem" "mount" "mount"
    record_file "lxc/filesystem" "filesystems" "/proc/filesystems"
}

collect_lxc_process() {
    ensure_dir "${COLLECT_BASE}/lxc/process"
    run_cmd "lxc/process" "ps" "ps"
    if has_cmd top; then
        run_cmd "lxc/process" "top" "top -b -n 1"
    fi
}

collect_lxc_dbus_socket() {
    ensure_dir "${COLLECT_BASE}/lxc/dbus"
    run_cmd "lxc/dbus" "dbus-socket" "find /var/run /run -maxdepth 3 -type s 2>/dev/null | grep -Ei 'dbus|ubus|rpcd'"
    run_cmd "lxc/dbus" "socket-list" "find /var/run /run -maxdepth 3 -type s 2>/dev/null | sort"
}

collect_lxc_all() {
    collect_lxc_core
    collect_lxc_procd
    collect_lxc_ubus_rpcd
    collect_lxc_uci
    collect_lxc_network
    collect_lxc_wireless
    collect_lxc_packages
    collect_lxc_filesystem
    collect_lxc_process
    collect_lxc_dbus_socket
}
