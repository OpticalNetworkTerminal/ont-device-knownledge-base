#!/bin/sh

SENDCMD_BIN="${SENDCMD_BIN:-sendcmd}"

mode=${1:-}
table_name=${2:-}

probe() {
    cat <<EOF
$SENDCMD_BIN
$SENDCMD_BIN help
$SENDCMD_BIN show
$SENDCMD_BIN list
$SENDCMD_BIN dump
$SENDCMD_BIN 1 DB
$SENDCMD_BIN 1 DB help
$SENDCMD_BIN 1 DB show
$SENDCMD_BIN 1 DB list
$SENDCMD_BIN 1 DB dump
EOF
}

table() {
    [ -n "$table_name" ] || return 0
    cat <<EOF
$SENDCMD_BIN 1 DB show $table_name
$SENDCMD_BIN 1 DB list $table_name
$SENDCMD_BIN 1 DB dump $table_name
$SENDCMD_BIN 1 DB get $table_name
$SENDCMD_BIN show $table_name
$SENDCMD_BIN list $table_name
$SENDCMD_BIN dump $table_name
EOF
}

case "$mode" in
    probe) probe ;;
    table) table ;;
    *)
        exit 1
        ;;
esac
