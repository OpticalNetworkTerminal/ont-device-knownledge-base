#!/bin/sh

is_elf_file() {
    elf_target=$1

    if has_cmd file; then
        file "$elf_target" 2>/dev/null | grep -q "ELF"
        return $?
    fi

    if has_cmd readelf; then
        readelf -h "$elf_target" >/dev/null 2>&1
        return $?
    fi

    return 1
}

elf_extract_with_file() {
    elf_target=$1
    report=$2
    if has_cmd file; then
        printf "file=%s\n" "$(file "$elf_target" 2>/dev/null)" >> "$report"
    fi
}

elf_extract_with_readelf() {
    elf_target=$1
    report=$2

    if ! has_cmd readelf; then
        return 0
    fi

    class=$(readelf -h "$elf_target" 2>/dev/null | sed -n 's/^[[:space:]]*Class:[[:space:]]*//p' | sed -n '1p')
    endian=$(readelf -h "$elf_target" 2>/dev/null | sed -n 's/^[[:space:]]*Data:[[:space:]]*//p' | sed -n '1p')
    machine=$(readelf -h "$elf_target" 2>/dev/null | sed -n 's/^[[:space:]]*Machine:[[:space:]]*//p' | sed -n '1p')
    osabi=$(readelf -h "$elf_target" 2>/dev/null | sed -n 's/^[[:space:]]*OS\\/ABI:[[:space:]]*//p' | sed -n '1p')
    build_id=$(readelf -n "$elf_target" 2>/dev/null | sed -n 's/^[[:space:]]*Build ID:[[:space:]]*//p' | sed -n '1p')
    interp=$(readelf -l "$elf_target" 2>/dev/null | sed -n 's/.*Requesting program interpreter:[[:space:]]*\\(.*\\)]/\\1/p' | sed -n '1p')

    {
        printf "class=%s\n" "${class:-unknown}"
        printf "endian=%s\n" "${endian:-unknown}"
        printf "machine=%s\n" "${machine:-unknown}"
        printf "abi=%s\n" "${osabi:-unknown}"
        printf "interpreter=%s\n" "${interp:-unknown}"
        printf "build_id=%s\n" "${build_id:-unknown}"
        printf "needed=\n"
        readelf -d "$elf_target" 2>/dev/null | sed -n 's/.*Shared library: \\[\\(.*\\)\\]/  - \\1/p'
        printf "rpath=%s\n" "$(readelf -d "$elf_target" 2>/dev/null | sed -n 's/.*Library rpath: \\[\\(.*\\)\\]/\\1/p' | sed -n '1p')"
        printf "runpath=%s\n" "$(readelf -d "$elf_target" 2>/dev/null | sed -n 's/.*Library runpath: \\[\\(.*\\)\\]/\\1/p' | sed -n '1p')"
    } >> "$report"
}

elf_extract_with_objdump() {
    elf_target=$1
    report=$2

    if has_cmd objdump; then
        printf "objdump_private_headers=\n" >> "$report"
        objdump -p "$elf_target" 2>/dev/null | sed 's/^/  /' >> "$report"
    fi
}

elf_extract_compiler_hint() {
    elf_target=$1
    report=$2

    if has_cmd strings; then
        printf "compiler_hints=\n" >> "$report"
        strings "$elf_target" 2>/dev/null | grep -E 'GCC:|clang version|musl|uClibc|glibc' | awk 'NR <= 20 { print }' | sed 's/^/  /' >> "$report"
    fi
}

elf_strip_hint() {
    elf_target=$1
    report=$2

    strip_state="unknown"
    if has_cmd file; then
        if file "$elf_target" 2>/dev/null | grep -qi "not stripped"; then
            strip_state="not stripped"
        elif file "$elf_target" 2>/dev/null | grep -qi "stripped"; then
            strip_state="stripped"
        fi
    fi
    printf "strip=%s\n" "$strip_state" >> "$report"
}

collect_single_elf() {
    elf_target=$1
    index_file=$2
    safe=$(printf "%s" "$elf_target" | sed 's#^/##; s#[/ ]#_#g; s#[^A-Za-z0-9_.-]#_#g')
    report="${COLLECT_BASE}/elf/reports/${safe}.txt"

    ensure_dir "$(path_dirname "$report")"

    {
        printf "path=%s\n" "$elf_target"
        printf "collected_at=%s\n" "$(timestamp_utc)"
    } > "$report"

    elf_extract_with_file "$elf_target" "$report"
    elf_extract_with_readelf "$elf_target" "$report"
    elf_strip_hint "$elf_target" "$report"
    elf_extract_compiler_hint "$elf_target" "$report"
    elf_extract_with_objdump "$elf_target" "$report"

    machine=$(sed -n 's/^machine=//p' "$report" | sed -n '1p')
    class=$(sed -n 's/^class=//p' "$report" | sed -n '1p')
    endian=$(sed -n 's/^endian=//p' "$report" | sed -n '1p')
    abi=$(sed -n 's/^abi=//p' "$report" | sed -n '1p')

    printf "%s\t%s\t%s\t%s\t%s\t%s\n" "$elf_target" "${machine:-unknown}" "${class:-unknown}" "${endian:-unknown}" "${abi:-unknown}" "$report" >> "$index_file"
}

collect_elf_all() {
    ensure_dir "${COLLECT_BASE}/elf"
    ensure_dir "${COLLECT_BASE}/elf/reports"

    if ! has_cmd file && ! has_cmd readelf; then
        write_text "${COLLECT_BASE}/elf/README.txt" \
            "ELF collection skipped." \
            "Reason: neither 'file' nor 'readelf' is available."
        return 0
    fi

    index_file="${COLLECT_BASE}/elf/index.tsv"
    scan_file="${COLLECT_BASE}/elf/scanned-paths.txt"
    : > "$index_file"
    : > "$scan_file"

    printf "path\tmachine\tclass\tendian\tabi\treport\n" >> "$index_file"

    scan_roots="/bin /sbin /usr/bin /usr/sbin"
    if [ -n "${EXTRA_ELF_DIRS:-}" ]; then
        scan_roots="${scan_roots} ${EXTRA_ELF_DIRS}"
    fi

    for root in $scan_roots; do
        if [ -d "$root" ]; then
            printf "%s\n" "$root" >> "$scan_file"
            find "$root" -type f 2>/dev/null | while IFS= read -r elf_target; do
                if is_elf_file "$elf_target"; then
                    collect_single_elf "$elf_target" "$index_file"
                fi
            done
        fi
    done
}
