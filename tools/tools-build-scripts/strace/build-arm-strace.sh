#!/usr/bin/env bash
set -Eeuo pipefail

trap 'rc=$?; printf "\nERROR: command failed at line %s (exit=%s): %s\n" "$LINENO" "$rc" "$BASH_COMMAND" >&2; exit "$rc"' ERR

SDK="/root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot"
TARGET="arm-buildroot-linux-gnueabi"
SOURCE_DIR="$(pwd)"
PREFIX="/usr"
LINKAGE="static"
BUNDLED="check"
ARM_OABI="no"
STACKTRACE="no"
MPERS="no"
INSTALL_TESTS="no"
JOBS="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)"
CLEAN="no"
STRIP_BIN="yes"
UPX_COMPRESS="yes"
UPX_BIN="upx"

die(){ echo "ERROR: $*" >&2; exit 1; }
log(){ echo; echo "[$(date '+%F %T')] $*"; }
need_cmd(){ command -v "$1" >/dev/null 2>&1 || die "missing command: $1"; }

usage(){
cat <<'EOF'
Usage:
  ./build-arm-strace.sh \
    --source /path/strace-7.1 \
    [--sdk PATH] [--target TRIPLET] [--prefix /usr]
    [--linkage static|dynamic]
    [--bundled yes|no|check] [--arm-oabi yes|no]
    [--stacktrace yes|no|check] [--mpers yes|no|check|m32|mx32]
    [--install-tests yes|no]
    [--jobs N] [--clean] [--no-strip] [--upx PATH] [--no-upx]

Builds a small strace for a cross target.
EOF
}

normalize_yes_no(){
  case "$1" in
    yes|no) printf '%s' "$1" ;;
    *) die "expected yes or no, got: $1" ;;
  esac
}

normalize_yes_no_check(){
  case "$1" in
    yes|no|check) printf '%s' "$1" ;;
    *) die "expected yes, no, or check, got: $1" ;;
  esac
}

normalize_mpers(){
  case "$1" in
    yes|no|check|m32|mx32) printf '%s' "$1" ;;
    *) die "expected yes, no, check, m32, or mx32, got: $1" ;;
  esac
}

find_sdk_bin(){
  local sdk="$1"
  if [[ -x "$sdk/bin/${TARGET}-gcc" ]]; then
    printf '%s/bin' "$sdk"
  elif [[ -x "$sdk/host/bin/${TARGET}-gcc" ]]; then
    printf '%s/host/bin' "$sdk"
  else
    return 1
  fi
}

configure_has(){
  local configure="$1"
  local option="$2"
  "$configure" --help 2>/dev/null | grep -Fq -- "$option"
}

configure_supports_option(){
  local configure="$1"
  local option="$2"
  local probe="${option%%=*}"
  local alternate=""

  configure_has "$configure" "$option" && return 0
  configure_has "$configure" "$probe" && return 0

  case "$probe" in
    --disable-*) alternate="--enable-${probe#--disable-}" ;;
    --without-*) alternate="--with-${probe#--without-}" ;;
  esac

  [[ -n "$alternate" ]] && configure_has "$configure" "$alternate"
}

append_supported_option(){
  local configure="$1"
  local option="$2"
  local -n destination="$3"
  if configure_supports_option "$configure" "$option"; then
    destination+=("$option")
  fi
}

while (($#)); do
  case "$1" in
    --source) SOURCE_DIR="$2"; shift 2;;
    --sdk) SDK="$2"; shift 2;;
    --target) TARGET="$2"; shift 2;;
    --prefix) PREFIX="$2"; shift 2;;
    --link|--linkage) LINKAGE="$2"; shift 2;;
    --bundled) BUNDLED="$(normalize_yes_no_check "$2")"; shift 2;;
    --arm-oabi) ARM_OABI="$(normalize_yes_no "$2")"; shift 2;;
    --stacktrace) STACKTRACE="$(normalize_yes_no_check "$2")"; shift 2;;
    --mpers) MPERS="$(normalize_mpers "$2")"; shift 2;;
    --install-tests) INSTALL_TESTS="$(normalize_yes_no "$2")"; shift 2;;
    --jobs) JOBS="$2"; shift 2;;
    --clean) CLEAN="yes"; shift;;
    --no-strip) STRIP_BIN="no"; shift;;
    --upx) UPX_BIN="$2"; shift 2;;
    --no-upx) UPX_COMPRESS="no"; shift;;
    -h|--help) usage; exit 0;;
    *) die "unknown option: $1";;
  esac
done

[[ "$PREFIX" == /* ]] || die "--prefix must be absolute"
[[ "$LINKAGE" == static || "$LINKAGE" == dynamic ]] || die "--linkage must be static or dynamic"
[[ "$JOBS" =~ ^[1-9][0-9]*$ ]] || die "--jobs must be a positive integer"

TARGET_ID="${TARGET//[^A-Za-z0-9_.-]/-}"

SOURCE_DIR="$(cd "$SOURCE_DIR" && pwd)"
[[ -x "$SOURCE_DIR/configure" ]] || die "strace configure not found: $SOURCE_DIR/configure"

TOOLBIN="$(find_sdk_bin "$SDK")" || die "cannot find ${TARGET}-gcc below $SDK"
export PATH="$TOOLBIN:$PATH"

CC="${TARGET}-gcc"
AR="${TARGET}-ar"
RANLIB="${TARGET}-ranlib"
STRIP="${TARGET}-strip"
READELF="${TARGET}-readelf"

for x in "$CC" "$AR" "$RANLIB" "$STRIP" "$READELF" make file tar sha256sum; do
  need_cmd "$x"
done
[[ "$UPX_COMPRESS" == yes ]] && need_cmd "$UPX_BIN"

SYSROOT="$("$CC" -print-sysroot)"
[[ -d "$SYSROOT" ]] || die "bad sysroot: $SYSROOT"
if [[ "$LINKAGE" == static ]]; then
  find "$SYSROOT/lib" "$SYSROOT/usr/lib" -name libc.a -type f -print -quit 2>/dev/null |
    grep -q . || die "missing static runtime library: libc.a"
fi

version="$(basename "$SOURCE_DIR" | sed 's/^strace-//')"
work_base="$(cd "$(dirname "$SOURCE_DIR")" && pwd)"
dist_base="$SOURCE_DIR"
WORK="$work_base/.${TARGET_ID}-strace-$LINKAGE"
BUILD="$WORK/build"
STAGE="$WORK/stage"
DIST="$dist_base/dist-${TARGET_ID}-strace"

[[ "$CLEAN" == yes ]] && rm -rf "$WORK"
rm -rf "$BUILD" "$STAGE"
mkdir -p "$BUILD" "$STAGE" "$DIST"

COMMON_CFLAGS="-Os -ffunction-sections -fdata-sections"
COMMON_CPPFLAGS="-D_GNU_SOURCE -D_DEFAULT_SOURCE -D_BSD_SOURCE"
if [[ "$LINKAGE" == static ]]; then
  LDFLAGS_LINK="-static -static-libgcc -Wl,--gc-sections"
  LINK_OPTS=(--enable-static --disable-shared)
else
  LDFLAGS_LINK="-Wl,--gc-sections -Wl,-rpath,$PREFIX/lib"
  LINK_OPTS=(--disable-static --enable-shared)
fi

BUILD_TRIPLET="$("$SOURCE_DIR/config.guess" 2>/dev/null ||
  "$SOURCE_DIR/build-aux/config.guess" 2>/dev/null ||
  gcc -dumpmachine)"

configure_opts=(
  "--build=$BUILD_TRIPLET"
  "--host=$TARGET"
  "--prefix=$PREFIX"
  "--bindir=$PREFIX/bin"
  "${LINK_OPTS[@]}"
)

append_supported_option "$SOURCE_DIR/configure" "--enable-bundled=$BUNDLED" configure_opts
append_supported_option "$SOURCE_DIR/configure" "--enable-stacktrace=$STACKTRACE" configure_opts
append_supported_option "$SOURCE_DIR/configure" "--enable-mpers=$MPERS" configure_opts
append_supported_option "$SOURCE_DIR/configure" "--enable-install-tests=$INSTALL_TESTS" configure_opts
if [[ "$ARM_OABI" == yes ]]; then
  append_supported_option "$SOURCE_DIR/configure" --enable-arm-oabi configure_opts
else
  append_supported_option "$SOURCE_DIR/configure" --disable-arm-oabi configure_opts
fi

if [[ "$STACKTRACE" == no ]]; then
  append_supported_option "$SOURCE_DIR/configure" --without-libdw configure_opts
  append_supported_option "$SOURCE_DIR/configure" --without-libunwind configure_opts
  append_supported_option "$SOURCE_DIR/configure" --without-libiberty configure_opts
fi
append_supported_option "$SOURCE_DIR/configure" --without-libselinux configure_opts

log "Build $LINKAGE strace $version"
(
  cd "$BUILD"
  env \
    PATH="$TOOLBIN:$PATH" \
    CC="$CC" AR="$AR" RANLIB="$RANLIB" STRIP="$STRIP" \
    CFLAGS="$COMMON_CFLAGS" \
    CPPFLAGS="$COMMON_CPPFLAGS" \
    LDFLAGS="$LDFLAGS_LINK" \
    "$SOURCE_DIR/configure" "${configure_opts[@]}"
  make -j"$JOBS" LDFLAGS="$LDFLAGS_LINK"
  make DESTDIR="$STAGE" install LDFLAGS="$LDFLAGS_LINK"
)

STRACE_BIN="$STAGE$PREFIX/bin/strace"
[[ -f "$STRACE_BIN" ]] || STRACE_BIN="$(find "$STAGE$PREFIX" -type f -name strace -print -quit)"
[[ -n "$STRACE_BIN" && -f "$STRACE_BIN" ]] || die "strace binary not found below $STAGE$PREFIX"

validate_static(){
  local f="$1"
  local ok="yes"
  file "$f"
  if "$READELF" -l "$f" | grep -qi interpreter; then
    echo "WARN: $f has PT_INTERP; binary is dynamically linked even though --linkage static was requested" >&2
    "$READELF" -l "$f" | grep -i interpreter || true
    ok="no"
  fi
  if "$READELF" -d "$f" 2>/dev/null | grep -q NEEDED; then
    echo "WARN: $f has DT_NEEDED; binary depends on shared libraries" >&2
    "$READELF" -d "$f" 2>/dev/null | grep NEEDED || true
    ok="no"
  fi
  [[ "$ok" == yes ]] && echo "Static validation OK: $(basename "$f")" || echo "WARN: static validation relaxed for $(basename "$f")" >&2
}

validate_dynamic(){
  local f="$1"
  file "$f"
  "$READELF" -l "$f" | grep -i interpreter || true
  "$READELF" -d "$f" 2>/dev/null | grep NEEDED || die "$f has no DT_NEEDED in dynamic mode"
  echo "Dynamic validation OK: $(basename "$f")"
}

validate_linkage(){
  [[ "$LINKAGE" == static ]] && validate_static "$1" || validate_dynamic "$1"
}

validate_linkage "$STRACE_BIN"

[[ "$STRIP_BIN" == yes ]] && "$STRIP" --strip-unneeded "$STRACE_BIN"
if [[ "$UPX_COMPRESS" == yes ]]; then
  "$UPX_BIN" --best --lzma "$STRACE_BIN"
  validate_linkage "$STRACE_BIN"
fi

cat >"$STAGE$PREFIX/environment-setup.sh" <<EOF
#!/bin/sh
STRACE_ROOT="$PREFIX"
export PATH="\$STRACE_ROOT/bin:\$PATH"
if [ "$LINKAGE" = "dynamic" ]; then
  export LD_LIBRARY_PATH="\$STRACE_ROOT/lib\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
fi
EOF
chmod 755 "$STAGE$PREFIX/environment-setup.sh"

archive="$DIST/strace-${version}-${TARGET_ID}-${LINKAGE}.tar.gz"
tar --numeric-owner -C "$STAGE" -czf "$archive" ".${PREFIX}"
sha256sum "$archive" >"$archive.sha256"

log "Done"
echo "Archive:  $archive"
echo "Checksum: $archive.sha256"
echo "Deploy:"
echo "  tar -xzf /tmp/$(basename "$archive") -C /"
echo "  . $PREFIX/environment-setup.sh"
echo "  strace -V"
