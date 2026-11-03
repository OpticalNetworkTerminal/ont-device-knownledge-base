#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
    cat <<'EOF'
ARM iptables 1.8.13 cross-build script

Usage:
  ./build-arm-iptables.sh [options]

Core options:
  --linkage static|dynamic    Link mode. Default: static
  --link static|dynamic       Compatibility alias for --linkage
  --nft yes|no               Build nft compatibility frontend in addition to legacy.
                             Default: yes
  --sdk PATH                 Buildroot SDK root.
                             Default:
                             /root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot
  --target TRIPLET           Cross toolchain target triplet.
                             Default: arm-buildroot-linux-gnueabi
  --source PATH              iptables source root. Default: script directory
  --prefix PATH              Target install prefix. Default: /opt/iptables-1.8.13
  --jobs N                   Parallel jobs. Default: nproc
  --clean                    Remove selected build/stage/dependency output first
  --no-strip                 Do not strip target ELF files
  --upx PATH                 UPX command path/name. Default: upx
  --no-upx                   Do not run UPX compression before packaging

nft dependency options:
  --libmnl-src PATH          libmnl source directory
  --libnftnl-src PATH        libnftnl source directory

  When --nft=yes, the script auto-detects sibling directories:
    ../libmnl-*
    ../libnftnl-*

Optional libpcap-based helper tools:
  --pcap-tools yes|no        Enable nfbpf_compile/nfsynproxy when supported.
                             Default: no
  --pcap-prefix PATH         Target libpcap installation prefix containing
                             lib/pkgconfig/libpcap.pc and target libraries

Examples:
  # Static legacy + nft compatibility frontends
  ./build-arm-iptables.sh \
    --linkage static \
    --nft yes \
    --libmnl-src ../libmnl-1.0.5 \
    --libnftnl-src ../libnftnl-1.2.9

  # Static legacy only
  ./build-arm-iptables.sh --linkage static --nft no

  # Dynamic legacy + nft build
  ./build-arm-iptables.sh \
    --linkage dynamic \
    --nft yes \
    --libmnl-src ../libmnl-1.0.5 \
    --libnftnl-src ../libnftnl-1.2.9

Notes:
  - --nft=yes builds iptables-nft compatibility commands, not the standalone nft CLI.
  - The target kernel must support the selected backend and requested extensions.
  - libpcap helper tools are disabled by default; xt_bpf itself remains available
    when supported by the iptables source build.
EOF
}

die() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

log() {
    printf '\n[%s] %s\n' "$(date '+%F %T')" "$*"
}

need_cmd() {
    command -v "$1" >/dev/null 2>&1 || die "missing host command: $1"
}

normalize_yes_no() {
    case "$1" in
        yes|no) printf '%s' "$1" ;;
        *) die "expected yes or no, got: $1" ;;
    esac
}

find_sdk_bin() {
    local sdk="$1"
    if [[ -x "$sdk/bin/${TARGET}-gcc" ]]; then
        printf '%s/bin' "$sdk"
    elif [[ -x "$sdk/host/bin/${TARGET}-gcc" ]]; then
        printf '%s/host/bin' "$sdk"
    else
        return 1
    fi
}

find_sibling_source() {
    local parent="$1"
    local pattern="$2"
    local candidate

    while IFS= read -r candidate; do
        [[ -x "$candidate/configure" ]] || continue
        printf '%s' "$candidate"
        return 0
    done < <(find "$parent" -maxdepth 1 -mindepth 1 -type d -name "$pattern" | sort -V -r)

    return 1
}

configure_has() {
    local configure="$1"
    local option="$2"
    "$configure" --help 2>/dev/null | grep -Fq -- "$option"
}

append_supported_option() {
    local configure="$1"
    local option="$2"
    local -n destination="$3"

    if configure_has "$configure" "$option"; then
        destination+=("$option")
    fi
}

build_dependency() {
    local name="$1"
    local src="$2"
    local build_dir="$3"
    shift 3
    local extra_opts=("$@")
    local link_opts=()

    [[ -x "$src/configure" ]] || die "$name configure not found: $src/configure"

    if [[ "$LINK_MODE" == "static" ]]; then
        link_opts+=(--enable-static --disable-shared)
    else
        link_opts+=(--disable-static --enable-shared)
    fi

    rm -rf "$build_dir"
    mkdir -p "$build_dir"

    log "Configuring $name"
    (
        cd "$build_dir"
        env \
            PATH="$TOOLBIN:$PATH" \
            CC="$CC" \
            AR="$AR" \
            RANLIB="$RANLIB" \
            STRIP="$STRIP" \
            CFLAGS="$COMMON_CFLAGS" \
            CPPFLAGS="$DEPENDENCY_CPPFLAGS" \
            LDFLAGS="$DEPENDENCY_LDFLAGS" \
            PKG_CONFIG="$PKG_CONFIG_WRAPPER" \
            PKG_CONFIG_PATH="$PKG_CONFIG_PATH_VALUE" \
            PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR_VALUE" \
            "$src/configure" \
                --build="$BUILD_TRIPLET" \
                --host="$TARGET" \
                --prefix="$DEPS_PREFIX" \
                --libdir="$DEPS_PREFIX/lib" \
                "${link_opts[@]}" \
                "${extra_opts[@]}"

        make -j"$JOBS"
        make install
    )
}

copy_dynamic_nft_libraries() {
    local target_lib="$STAGE_DIR$PREFIX/lib"
    mkdir -p "$target_lib"

    shopt -s nullglob
    local libs=(
        "$DEPS_PREFIX/lib/libmnl.so"*
        "$DEPS_PREFIX/lib/libnftnl.so"*
    )
    ((${#libs[@]} > 0)) || die "dynamic nft libraries were not produced"
    cp -a "${libs[@]}" "$target_lib/"
    shopt -u nullglob
}

strip_stage() {
    [[ "$DO_STRIP" == "yes" ]] || return 0

    log "Stripping target ELF files"
    while IFS= read -r -d '' file_path; do
        if file "$file_path" | grep -qE 'ELF 32-bit.*ARM'; then
            "$STRIP" --strip-unneeded "$file_path" 2>/dev/null || true
        fi
    done < <(find "$STAGE_DIR" -type f -print0)
}

upx_stage() {
    [[ "$UPX_COMPRESS" == "yes" ]] || return 0

    log "Compressing target executable ELF files with UPX"
    while IFS= read -r -d '' file_path; do
        if file "$file_path" | grep -qE 'ELF 32-bit.*ARM'; then
            if [[ -x "$file_path" ]] && ! [[ "$file_path" == *.so* ]]; then
                "$UPX_BIN" --best --lzma "$file_path"
            fi
        fi
    done < <(find "$STAGE_DIR" -type f -print0)
}

validate_binary() {
    local binary="$1"
    local label="$2"

    [[ -f "$binary" ]] || die "missing $label binary: $binary"

    log "Validating $label: $binary"
    file "$binary"

    "$READELF" -h "$binary" |
        grep -E 'Class:|Data:|Machine:|Flags:' || true

    "$READELF" -A "$binary" |
        grep -E 'Tag_CPU_name|Tag_CPU_arch|Tag_FP_arch|Tag_ABI_VFP_args' || true

    if [[ "$LINK_MODE" == "static" ]]; then
        local ok="yes"
        if "$READELF" -l "$binary" | grep -qi interpreter; then
            printf 'WARN: %s has an ELF interpreter but static mode was requested\n' "$label" >&2
            "$READELF" -l "$binary" | grep -i interpreter || true
            ok="no"
        fi
        if "$READELF" -d "$binary" 2>/dev/null | grep -q NEEDED; then
            printf 'WARN: %s has DT_NEEDED entries but static mode was requested\n' "$label" >&2
            "$READELF" -d "$binary" 2>/dev/null | grep NEEDED || true
            ok="no"
        fi
        if [[ "$ok" == "yes" ]]; then
            echo "Static validation: no PT_INTERP and no DT_NEEDED"
        else
            printf 'WARN: static validation relaxed for %s\n' "$label" >&2
        fi
    else
        "$READELF" -l "$binary" | grep -i interpreter || true
        "$READELF" -d "$binary" 2>/dev/null | grep NEEDED || true
    fi
}

LINK_MODE="static"
NFT_ENABLED="yes"
SDK="/root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot"
SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
PREFIX="/opt/iptables-1.8.13"
JOBS="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)"
CLEAN="no"
DO_STRIP="yes"
UPX_COMPRESS="yes"
UPX_BIN="upx"
PCAP_TOOLS="no"
PCAP_PREFIX=""
LIBMNL_SRC=""
LIBNFTNL_SRC=""
TARGET="arm-buildroot-linux-gnueabi"

while (($#)); do
    case "$1" in
        --link|--linkage)
            (($# >= 2)) || die "$1 requires a value"
            LINK_MODE="$2"
            shift 2
            ;;
        --nft)
            (($# >= 2)) || die "--nft requires a value"
            NFT_ENABLED="$(normalize_yes_no "$2")"
            shift 2
            ;;
        --sdk)
            (($# >= 2)) || die "--sdk requires a path"
            SDK="$2"
            shift 2
            ;;
        --target)
            (($# >= 2)) || die "--target requires a value"
            TARGET="$2"
            shift 2
            ;;
        --source)
            (($# >= 2)) || die "--source requires a path"
            SOURCE_DIR="$2"
            shift 2
            ;;
        --prefix)
            (($# >= 2)) || die "--prefix requires a path"
            PREFIX="$2"
            shift 2
            ;;
        --jobs)
            (($# >= 2)) || die "--jobs requires a value"
            JOBS="$2"
            shift 2
            ;;
        --libmnl-src)
            (($# >= 2)) || die "--libmnl-src requires a path"
            LIBMNL_SRC="$2"
            shift 2
            ;;
        --libnftnl-src)
            (($# >= 2)) || die "--libnftnl-src requires a path"
            LIBNFTNL_SRC="$2"
            shift 2
            ;;
        --pcap-tools)
            (($# >= 2)) || die "--pcap-tools requires yes or no"
            PCAP_TOOLS="$(normalize_yes_no "$2")"
            shift 2
            ;;
        --pcap-prefix)
            (($# >= 2)) || die "--pcap-prefix requires a path"
            PCAP_PREFIX="$2"
            shift 2
            ;;
        --clean)
            CLEAN="yes"
            shift
            ;;
        --no-strip)
            DO_STRIP="no"
            shift
            ;;
        --upx)
            (($# >= 2)) || die "--upx requires a path"
            UPX_BIN="$2"
            shift 2
            ;;
        --no-upx)
            UPX_COMPRESS="no"
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            die "unknown option: $1"
            ;;
    esac
done

case "$LINK_MODE" in
    static|dynamic) ;;
    *) die "--linkage must be static or dynamic" ;;
esac
TARGET_ID="${TARGET//[^A-Za-z0-9_.-]/-}"

[[ "$PREFIX" == /* ]] || die "--prefix must be an absolute target path"
[[ "$JOBS" =~ ^[1-9][0-9]*$ ]] || die "--jobs must be a positive integer"

SOURCE_DIR="$(cd "$SOURCE_DIR" && pwd)"
[[ -x "$SOURCE_DIR/configure" ]] || die "iptables configure not found: $SOURCE_DIR/configure"

need_cmd make
need_cmd file
need_cmd grep
need_cmd find
need_cmd tar
need_cmd pkg-config
need_cmd sha256sum

if [[ "$UPX_COMPRESS" == "yes" ]]; then
    need_cmd "$UPX_BIN"
fi

TOOLBIN="$(find_sdk_bin "$SDK")" ||
    die "cannot find ${TARGET}-gcc under $SDK/bin or $SDK/host/bin"

export PATH="$TOOLBIN:$PATH"

CC="${TARGET}-gcc"
AR="${TARGET}-ar"
RANLIB="${TARGET}-ranlib"
STRIP="${TARGET}-strip"
READELF="${TARGET}-readelf"

for tool in "$CC" "$AR" "$RANLIB" "$STRIP" "$READELF"; do
    need_cmd "$tool"
done

SYSROOT="$("$CC" -print-sysroot)"
[[ -d "$SYSROOT" ]] || die "invalid SDK sysroot: $SYSROOT"

if [[ "$LINK_MODE" == "static" ]]; then
    if [[ ! -f "$SYSROOT/usr/lib/libc.a" && ! -f "$SYSROOT/lib/libc.a" ]]; then
        die "SDK does not contain libc.a; fully static linking is unavailable"
    fi
fi

if [[ -x "$SOURCE_DIR/config.guess" ]]; then
    BUILD_TRIPLET="$("$SOURCE_DIR/config.guess")"
else
    BUILD_TRIPLET="$(gcc -dumpmachine)"
fi

VARIANT="${LINK_MODE}-nft-${NFT_ENABLED}"
WORK_ROOT="$SOURCE_DIR/.${TARGET_ID}-iptables-build"
BUILD_DIR="$WORK_ROOT/iptables-$VARIANT"
STAGE_DIR="$WORK_ROOT/stage-$VARIANT"
DEPS_PREFIX="$WORK_ROOT/deps-$VARIANT"
DIST_DIR="$SOURCE_DIR/dist-${TARGET_ID}-iptables"
PKG_CONFIG_WRAPPER="$WORK_ROOT/pkg-config-$VARIANT"

COMMON_CFLAGS="-Os -ffunction-sections -fdata-sections"
DEPENDENCY_CPPFLAGS=""
DEPENDENCY_LDFLAGS=""

if [[ "$LINK_MODE" == "static" ]]; then
    # configure invokes GCC directly. Use GCC's -static so the driver also
    # selects static libgcc, and state -static-libgcc explicitly for this
    # older Buildroot GCC toolchain.
    CONFIGURE_LDFLAGS="-static -static-libgcc -Wl,--gc-sections"

    # GNU libtool must receive -all-static when linking standalone programs.
    # Keep ordinary linker flags separate from libtool's own option.
    MAKE_LDFLAGS="-static-libgcc -Wl,--gc-sections"
    REGULAR_LDFLAGS="-all-static -static-libgcc -Wl,--gc-sections"
else
    CONFIGURE_LDFLAGS="-Wl,--gc-sections -Wl,-rpath,$PREFIX/lib"
    MAKE_LDFLAGS="-Wl,--gc-sections -Wl,-rpath,$PREFIX/lib"
    REGULAR_LDFLAGS="-Wl,--gc-sections -Wl,-rpath,$PREFIX/lib"
fi

if [[ "$CLEAN" == "yes" ]]; then
    log "Cleaning selected output"
    rm -rf "$BUILD_DIR" "$STAGE_DIR" "$DEPS_PREFIX" "$PKG_CONFIG_WRAPPER"
fi

mkdir -p "$WORK_ROOT" "$DIST_DIR"

if [[ "$NFT_ENABLED" == "yes" ]]; then
    PARENT_DIR="$(dirname "$SOURCE_DIR")"

    if [[ -z "$LIBMNL_SRC" ]]; then
        LIBMNL_SRC="$(find_sibling_source "$PARENT_DIR" 'libmnl-*' || true)"
    fi
    if [[ -z "$LIBNFTNL_SRC" ]]; then
        LIBNFTNL_SRC="$(find_sibling_source "$PARENT_DIR" 'libnftnl-*' || true)"
    fi

    [[ -n "$LIBMNL_SRC" ]] ||
        die "nft enabled but libmnl source was not found; use --libmnl-src PATH"
    [[ -n "$LIBNFTNL_SRC" ]] ||
        die "nft enabled but libnftnl source was not found; use --libnftnl-src PATH"

    LIBMNL_SRC="$(cd "$LIBMNL_SRC" && pwd)"
    LIBNFTNL_SRC="$(cd "$LIBNFTNL_SRC" && pwd)"

    mkdir -p "$DEPS_PREFIX"

    PKG_CONFIG_PATH_VALUE="$DEPS_PREFIX/lib/pkgconfig:$DEPS_PREFIX/share/pkgconfig"
    PKG_CONFIG_LIBDIR_VALUE="$PKG_CONFIG_PATH_VALUE"

    cat > "$PKG_CONFIG_WRAPPER" <<EOF
#!/usr/bin/env bash
set -e
if [[ "$LINK_MODE" == "static" ]]; then
    exec pkg-config --static "\$@"
else
    exec pkg-config "\$@"
fi
EOF
    chmod 755 "$PKG_CONFIG_WRAPPER"

    build_dependency \
        libmnl \
        "$LIBMNL_SRC" \
        "$WORK_ROOT/build-libmnl-$VARIANT"

    DEPENDENCY_CPPFLAGS="-I$DEPS_PREFIX/include"
    DEPENDENCY_LDFLAGS="-L$DEPS_PREFIX/lib"

    build_dependency \
        libnftnl \
        "$LIBNFTNL_SRC" \
        "$WORK_ROOT/build-libnftnl-$VARIANT"
else
    PKG_CONFIG_PATH_VALUE=""
    PKG_CONFIG_LIBDIR_VALUE=""
    cat > "$PKG_CONFIG_WRAPPER" <<'EOF'
#!/usr/bin/env bash
exec pkg-config "$@"
EOF
    chmod 755 "$PKG_CONFIG_WRAPPER"
fi

if [[ "$PCAP_TOOLS" == "yes" ]]; then
    [[ -n "$PCAP_PREFIX" ]] ||
        die "--pcap-tools=yes requires --pcap-prefix PATH"
    [[ -d "$PCAP_PREFIX" ]] ||
        die "pcap prefix not found: $PCAP_PREFIX"

    DEPENDENCY_CPPFLAGS="$DEPENDENCY_CPPFLAGS -I$PCAP_PREFIX/include"
    DEPENDENCY_LDFLAGS="$DEPENDENCY_LDFLAGS -L$PCAP_PREFIX/lib"
    PKG_CONFIG_PATH_VALUE="$PCAP_PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH_VALUE"
    PKG_CONFIG_LIBDIR_VALUE="$PCAP_PREFIX/lib/pkgconfig:$PKG_CONFIG_LIBDIR_VALUE"
fi

rm -rf "$BUILD_DIR" "$STAGE_DIR"
mkdir -p "$BUILD_DIR" "$STAGE_DIR"

CONFIGURE_OPTIONS=(
    "--build=$BUILD_TRIPLET"
    "--host=$TARGET"
    "--prefix=$PREFIX"
    "--sbindir=$PREFIX/sbin"
    "--libdir=$PREFIX/lib"
)

if configure_has "$SOURCE_DIR/configure" "--with-xtlibdir"; then
    CONFIGURE_OPTIONS+=("--with-xtlibdir=$PREFIX/lib/xtables")
fi

if [[ "$LINK_MODE" == "static" ]]; then
    append_supported_option "$SOURCE_DIR/configure" \
        "--enable-static" CONFIGURE_OPTIONS
    append_supported_option "$SOURCE_DIR/configure" \
        "--disable-shared" CONFIGURE_OPTIONS
else
    append_supported_option "$SOURCE_DIR/configure" \
        "--disable-static" CONFIGURE_OPTIONS
    append_supported_option "$SOURCE_DIR/configure" \
        "--enable-shared" CONFIGURE_OPTIONS
fi

if [[ "$NFT_ENABLED" == "yes" ]]; then
    if configure_has "$SOURCE_DIR/configure" "--enable-nftables"; then
        CONFIGURE_OPTIONS+=(--enable-nftables)
    else
        log "iptables configure has no --enable-nftables option; relying on libmnl/libnftnl pkg-config auto-detection"
    fi
else
    append_supported_option "$SOURCE_DIR/configure" \
        "--disable-nftables" CONFIGURE_OPTIONS
fi

if [[ "$PCAP_TOOLS" == "yes" ]]; then
    append_supported_option "$SOURCE_DIR/configure" \
        "--enable-bpf-compiler" CONFIGURE_OPTIONS
    append_supported_option "$SOURCE_DIR/configure" \
        "--enable-nfsynproxy" CONFIGURE_OPTIONS
else
    append_supported_option "$SOURCE_DIR/configure" \
        "--disable-bpf-compiler" CONFIGURE_OPTIONS
    append_supported_option "$SOURCE_DIR/configure" \
        "--disable-nfsynproxy" CONFIGURE_OPTIONS
fi

log "Build configuration"
cat <<EOF
Source:        $SOURCE_DIR
SDK:           $SDK
Toolchain:     $("$CC" -dumpmachine)
Sysroot:       $SYSROOT
Link mode:     $LINK_MODE
NFT frontend:  $NFT_ENABLED
Target prefix: $PREFIX
Build dir:     $BUILD_DIR
Stage dir:     $STAGE_DIR
Dependencies:  $DEPS_PREFIX
Jobs:          $JOBS
EOF

log "Configuring iptables"
(
    cd "$BUILD_DIR"

    env \
        PATH="$TOOLBIN:$PATH" \
        CC="$CC" \
        AR="$AR" \
        RANLIB="$RANLIB" \
        STRIP="$STRIP" \
        CFLAGS="$COMMON_CFLAGS" \
        CPPFLAGS="$DEPENDENCY_CPPFLAGS" \
        LDFLAGS="$CONFIGURE_LDFLAGS $DEPENDENCY_LDFLAGS" \
        PKG_CONFIG="$PKG_CONFIG_WRAPPER" \
        PKG_CONFIG_PATH="$PKG_CONFIG_PATH_VALUE" \
        PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR_VALUE" \
        "$SOURCE_DIR/configure" \
            "${CONFIGURE_OPTIONS[@]}"

    make -j"$JOBS" \
        LDFLAGS="$MAKE_LDFLAGS $DEPENDENCY_LDFLAGS" \
        regular_LDFLAGS="$REGULAR_LDFLAGS $DEPENDENCY_LDFLAGS"

    make DESTDIR="$STAGE_DIR" install \
        LDFLAGS="$MAKE_LDFLAGS $DEPENDENCY_LDFLAGS" \
        regular_LDFLAGS="$REGULAR_LDFLAGS $DEPENDENCY_LDFLAGS"
)

if [[ "$NFT_ENABLED" == "yes" && "$LINK_MODE" == "dynamic" ]]; then
    copy_dynamic_nft_libraries
fi

INSTALL_ROOT="$STAGE_DIR$PREFIX"
[[ -d "$INSTALL_ROOT" ]] || die "install root missing: $INSTALL_ROOT"

LEGACY_MULTI="$(find "$INSTALL_ROOT" -type f -name 'xtables-legacy-multi' | head -n 1)"
if [[ -z "$LEGACY_MULTI" ]]; then
    LEGACY_MULTI="$(find "$INSTALL_ROOT" -type f -name 'xtables-multi' | head -n 1)"
fi
[[ -n "$LEGACY_MULTI" ]] || die "legacy multi binary was not produced"

validate_binary "$LEGACY_MULTI" "legacy"

if [[ "$NFT_ENABLED" == "yes" ]]; then
    NFT_MULTI="$(find "$INSTALL_ROOT" -type f -name 'xtables-nft-multi' | head -n 1)"
    [[ -n "$NFT_MULTI" ]] || die "nft multi binary was not produced"
    validate_binary "$NFT_MULTI" "nft"
fi

strip_stage
upx_stage

validate_binary "$LEGACY_MULTI" "legacy"

if [[ "$NFT_ENABLED" == "yes" ]]; then
    validate_binary "$NFT_MULTI" "nft"
fi

mkdir -p "$INSTALL_ROOT"
cat > "$INSTALL_ROOT/environment-setup.sh" <<EOF
#!/bin/sh
IPTABLES_ROOT="$PREFIX"
export PATH="\$IPTABLES_ROOT/sbin:\$PATH"
export XTABLES_LIBDIR="\$IPTABLES_ROOT/lib/xtables"
if [ "$LINK_MODE" = "dynamic" ]; then
    export LD_LIBRARY_PATH="\$IPTABLES_ROOT/lib\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
fi
EOF
chmod 755 "$INSTALL_ROOT/environment-setup.sh"

BACKEND_NAME="legacy"
if [[ "$NFT_ENABLED" == "yes" ]]; then
    BACKEND_NAME="legacy+nft"
fi

SAFE_BACKEND="${BACKEND_NAME//+/-}"
ARCHIVE_NAME="iptables-1.8.13-${TARGET_ID}-${LINK_MODE}-${SAFE_BACKEND}.tar.gz"
ARCHIVE_PATH="$DIST_DIR/$ARCHIVE_NAME"

cat > "$DIST_DIR/BUILD-INFO-${LINK_MODE}-${SAFE_BACKEND}.txt" <<EOF
Package: iptables
Version: 1.8.13
Target: $TARGET
CPU/ABI: ARM GNU EABI
SDK sysroot: $SYSROOT
Link mode: $LINK_MODE
Legacy backend: yes
NFT compatibility frontend: $NFT_ENABLED
Target install prefix: $PREFIX
libpcap helper tools: $PCAP_TOOLS
Build date: $(date -u '+%F %T UTC')
EOF

log "Creating package"
tar \
    --numeric-owner \
    -C "$STAGE_DIR" \
    -czf "$ARCHIVE_PATH" \
    ".${PREFIX}"

sha256sum "$ARCHIVE_PATH" > "$ARCHIVE_PATH.sha256"

log "Produced command links/files"
find "$INSTALL_ROOT/sbin" -maxdepth 1 \( -type f -o -type l \) -printf '%f -> %l\n' |
    sort || true

log "Build complete"
printf 'Archive:  %s\n' "$ARCHIVE_PATH"
printf 'Checksum: %s\n' "$ARCHIVE_PATH.sha256"
printf 'Stage:    %s\n' "$STAGE_DIR"
printf '\nTarget deployment example:\n'
cat <<EOF
  tar -xzf /tmp/$ARCHIVE_NAME -C /
  . $PREFIX/environment-setup.sh
  iptables-legacy --version
EOF

if [[ "$NFT_ENABLED" == "yes" ]]; then
    cat <<EOF
  iptables-nft --version
EOF
fi

cat <<'EOF'

Run read-only tests first. Do not replace the vendor iptables command until
legacy/nft kernel support and required extensions have been verified.
EOF
