#!/bin/sh

# Common helpers for device-collector scripts.

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

now_ts() {
    date '+%Y-%m-%d %H:%M:%S %z'
}

ensure_dir() {
    [ -n "$1" ] || return 1
    mkdir -p "$1" 2>/dev/null
}

safe_name() {
    echo "$1" | sed 's#[/[:space:]]#_#g; s#[^A-Za-z0-9._:-]#_#g; s#_\\{2,\\}#_#g; s#^_##; s#_$##'
}

quote_md() {
    # Keeps multiline content safe inside fenced blocks.
    cat "$1" 2>/dev/null
}

log_run() {
    msg="$*"
    if [ -n "${RUN_LOG:-}" ]; then
        printf '[%s] %s\n' "$(now_ts)" "$msg" >>"$RUN_LOG"
    fi
}

log_error() {
    msg="$*"
    if [ -n "${ERROR_LOG:-}" ]; then
        printf '[%s] %s\n' "$(now_ts)" "$msg" >>"$ERROR_LOG"
    fi
}

run_capture() {
    out_file="$1"
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

    if [ -n "${TIMEOUT_CMD:-}" ]; then
        "$TIMEOUT_CMD" "${DBUS_DUMP_TIMEOUT:-3}" "$@" >>"$out_file" 2>&1
        rc=$?
    else
        "$@" >>"$out_file" 2>&1
        rc=$?
    fi

    printf '\n# finished: %s\n# exit_code: %s\n' "$(now_ts)" "$rc" >>"$out_file"

    if [ "$rc" -ne 0 ]; then
        log_error "FAIL($rc) $*"
    fi

    return "$rc"
}

append_unique_line() {
    file="$1"
    line="$2"

    ensure_dir "$(path_dirname "$file")" || return 1
    [ -f "$file" ] || : >"$file"

    if ! grep -Fqx "$line" "$file" 2>/dev/null; then
        printf '%s\n' "$line" >>"$file"
    fi
}

count_lines() {
    if [ -f "$1" ]; then
        wc -l <"$1" | tr -d ' '
    else
        echo 0
    fi
}
