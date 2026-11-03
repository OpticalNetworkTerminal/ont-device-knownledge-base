#!/usr/bin/env bash
set -Eeuo pipefail

trap 'rc=$?; printf "\nERROR: command failed at line %s (exit=%s): %s\n" "$LINENO" "$rc" "$BASH_COMMAND" >&2; exit "$rc"' ERR

SDK="/root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot"
TARGET="arm-buildroot-linux-gnueabi"
SOURCE_DIR="$(pwd)"
PREFIX="/usr"
LINKAGE="static"
IPV6="yes"
OPENSSL="no"
OPENSSL_DIR=""
READLINE="no"
LIBWRAP="no"
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
  ./build-arm-socat.sh \
    --source /path/socat-1.8.1.3 \
    [--sdk PATH] [--target TRIPLET] [--prefix /usr]
    [--linkage static|dynamic]
    [--ipv6 yes|no] [--openssl yes|no] [--openssl-dir PATH]
    [--readline yes|no] [--libwrap yes|no]
    [--jobs N] [--clean] [--no-strip] [--upx PATH] [--no-upx]

Builds socat for a cross target. Minimal defaults disable OpenSSL,
readline, and tcp-wrappers.
EOF
}

yn(){ case "$1" in yes|no) printf '%s' "$1";; *) die "expected yes or no, got: $1";; esac; }
find_sdk_bin(){
  [[ -x "$1/bin/${TARGET}-gcc" ]] && { printf '%s/bin' "$1"; return 0; }
  [[ -x "$1/host/bin/${TARGET}-gcc" ]] && { printf '%s/host/bin' "$1"; return 0; }
  return 1
}
configure_has(){ "$1" --help 2>/dev/null | grep -Fq -- "$2"; }
append_opt(){ local c="$1" o="$2"; local -n a="$3"; configure_has "$c" "${o%%=*}" && a+=("$o"); }

while (($#)); do
  case "$1" in
    --source) SOURCE_DIR="$2"; shift 2;;
    --sdk) SDK="$2"; shift 2;;
    --target) TARGET="$2"; shift 2;;
    --prefix) PREFIX="$2"; shift 2;;
    --link|--linkage) LINKAGE="$2"; shift 2;;
    --ipv6) IPV6="$(yn "$2")"; shift 2;;
    --openssl) OPENSSL="$(yn "$2")"; shift 2;;
    --openssl-dir) OPENSSL_DIR="$2"; shift 2;;
    --readline) READLINE="$(yn "$2")"; shift 2;;
    --libwrap) LIBWRAP="$(yn "$2")"; shift 2;;
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
[[ -z "$OPENSSL_DIR" || "$OPENSSL_DIR" == /* ]] || die "--openssl-dir must be absolute"
[[ "$OPENSSL" == yes && -z "$OPENSSL_DIR" ]] && die "--openssl yes requires --openssl-dir PATH"

TARGET_ID="${TARGET//[^A-Za-z0-9_.-]/-}"
SOURCE_DIR="$(cd "$SOURCE_DIR" && pwd)"
[[ -x "$SOURCE_DIR/configure" ]] || die "socat configure not found: $SOURCE_DIR/configure"

TOOLBIN="$(find_sdk_bin "$SDK")" || die "cannot find ${TARGET}-gcc below $SDK"
export PATH="$TOOLBIN:$PATH"

CC="${TARGET}-gcc"; AR="${TARGET}-ar"; RANLIB="${TARGET}-ranlib"; STRIP="${TARGET}-strip"; READELF="${TARGET}-readelf"
for x in "$CC" "$AR" "$RANLIB" "$STRIP" "$READELF" make file tar sha256sum; do need_cmd "$x"; done
[[ "$UPX_COMPRESS" == yes ]] && need_cmd "$UPX_BIN"

SYSROOT="$("$CC" -print-sysroot)"
[[ -d "$SYSROOT" ]] || die "bad sysroot: $SYSROOT"
if [[ "$LINKAGE" == static ]]; then
  find "$SYSROOT/lib" "$SYSROOT/usr/lib" -name libc.a -type f -print -quit 2>/dev/null | grep -q . ||
    die "missing static runtime library: libc.a"
fi

version="$(basename "$SOURCE_DIR" | sed 's/^socat-//')"
work_base="$(cd "$(dirname "$SOURCE_DIR")" && pwd)"
WORK="$work_base/.${TARGET_ID}-socat-$LINKAGE"
BUILD="$WORK/build"
STAGE="$WORK/stage"
DIST="$SOURCE_DIR/dist-${TARGET_ID}-socat"

[[ "$CLEAN" == yes ]] && rm -rf "$WORK"
rm -rf "$BUILD" "$STAGE"
mkdir -p "$BUILD" "$STAGE" "$DIST"

CFLAGS_COMMON="-Os -ffunction-sections -fdata-sections"
CPPFLAGS_COMMON="-D_GNU_SOURCE -D_DEFAULT_SOURCE -D_BSD_SOURCE"
LIBS_EXTRA=""
if [[ "$LINKAGE" == static ]]; then
  LDFLAGS_LINK="-static -static-libgcc -Wl,--gc-sections"
else
  LDFLAGS_LINK="-Wl,--gc-sections -Wl,-rpath,$PREFIX/lib"
fi
if [[ "$OPENSSL" == yes ]]; then
  CPPFLAGS_COMMON="$CPPFLAGS_COMMON -I$OPENSSL_DIR/include"
  LDFLAGS_LINK="$LDFLAGS_LINK -L$OPENSSL_DIR/lib"
  LIBS_EXTRA="-lssl -lcrypto -lz -ldl -lpthread"
fi

BUILD_TRIPLET="$("$SOURCE_DIR/config.guess" 2>/dev/null || gcc -dumpmachine)"
opts=("--build=$BUILD_TRIPLET" "--host=$TARGET" "--prefix=$PREFIX" "--bindir=$PREFIX/bin")
[[ "$IPV6" == no ]] && append_opt "$SOURCE_DIR/configure" --disable-ip6 opts
[[ "$OPENSSL" == yes ]] && append_opt "$SOURCE_DIR/configure" "--enable-openssl-base=$OPENSSL_DIR" opts || append_opt "$SOURCE_DIR/configure" --disable-openssl opts
[[ "$READLINE" == yes ]] || append_opt "$SOURCE_DIR/configure" --disable-readline opts
[[ "$LIBWRAP" == yes ]] || append_opt "$SOURCE_DIR/configure" --disable-libwrap opts

log "Build $LINKAGE socat $version"
(
  cd "$BUILD"
  env PATH="$TOOLBIN:$PATH" CC="$CC" AR="$AR" RANLIB="$RANLIB" STRIP="$STRIP" \
    CFLAGS="$CFLAGS_COMMON" CPPFLAGS="$CPPFLAGS_COMMON" LDFLAGS="$LDFLAGS_LINK" LIBS="$LIBS_EXTRA" \
    "$SOURCE_DIR/configure" "${opts[@]}"
  make -j"$JOBS" LDFLAGS="$LDFLAGS_LINK" LIBS="$LIBS_EXTRA"
  make DESTDIR="$STAGE" install LDFLAGS="$LDFLAGS_LINK" LIBS="$LIBS_EXTRA"
)

BIN="$STAGE$PREFIX/bin/socat"
[[ -f "$BIN" ]] || BIN="$(find "$STAGE$PREFIX" -type f -name socat -print -quit)"
[[ -n "$BIN" && -f "$BIN" ]] || die "socat binary not found below $STAGE$PREFIX"

validate(){
  file "$1"
  if [[ "$LINKAGE" == static ]]; then
    "$READELF" -l "$1" | grep -i interpreter && echo "WARN: $1 has PT_INTERP" >&2 || true
    "$READELF" -d "$1" 2>/dev/null | grep NEEDED && echo "WARN: $1 has DT_NEEDED" >&2 || true
  else
    "$READELF" -d "$1" 2>/dev/null | grep NEEDED || die "$1 has no DT_NEEDED in dynamic mode"
  fi
}
validate "$BIN"
[[ "$STRIP_BIN" == yes ]] && "$STRIP" --strip-unneeded "$BIN"
if [[ "$UPX_COMPRESS" == yes ]]; then "$UPX_BIN" --best --lzma "$BIN"; validate "$BIN"; fi

cat >"$STAGE$PREFIX/environment-setup.sh" <<EOF
#!/bin/sh
SOCAT_ROOT="$PREFIX"
export PATH="\$SOCAT_ROOT/bin:\$PATH"
EOF
chmod 755 "$STAGE$PREFIX/environment-setup.sh"

archive="$DIST/socat-${version}-${TARGET_ID}-${LINKAGE}.tar.gz"
tar --numeric-owner -C "$STAGE" -czf "$archive" ".${PREFIX}"
sha256sum "$archive" >"$archive.sha256"

log "Done"
echo "Archive:  $archive"
echo "Checksum: $archive.sha256"
