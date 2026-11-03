#!/usr/bin/env bash
set -Eeuo pipefail

trap 'rc=$?; printf "\nERROR: command failed at line %s (exit=%s): %s\n" "$LINENO" "$rc" "$BASH_COMMAND" >&2; exit "$rc"' ERR

SDK="/root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot"
TARGET="arm-buildroot-linux-gnueabi"
SOURCE_DIR="$(pwd)"
LIBPCAP_SRC=""
PREFIX="/usr"
LINKAGE="static"
PCAP_TYPE="linux"
IPV6="yes"
REMOTE="no"
CRYPTO="no"
SMI="no"
SMB="no"
USER_DROP=""
CHROOT_DIR=""
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
  ./build-arm-tcpdump.sh \
    --source /path/tcpdump-4.99.5 \
    --libpcap-src /path/libpcap-1.10.5 \
    [--sdk PATH] [--target TRIPLET] [--prefix /usr]
    [--linkage static|dynamic]
    [--pcap-type linux] [--ipv6 yes|no] [--remote yes|no]
    [--crypto yes|no] [--smi yes|no] [--smb yes|no]
    [--user USER] [--chroot PATH]
    [--jobs N] [--clean] [--no-strip] [--upx PATH] [--no-upx]

Builds tcpdump plus libpcap for a cross target.
EOF
}

normalize_yes_no(){
  case "$1" in
    yes|no) printf '%s' "$1" ;;
    *) die "expected yes or no, got: $1" ;;
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

find_sibling_source(){
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

configure_has(){
  local configure="$1"
  local option="$2"
  "$configure" --help 2>/dev/null | grep -Fq -- "$option"
}

configure_supports_option(){
  local configure="$1"
  local option="$2"
  local alternate=""

  configure_has "$configure" "$option" && return 0

  case "$option" in
    --disable-*) alternate="--enable-${option#--disable-}" ;;
    --without-*) alternate="--with-${option#--without-}" ;;
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
    --libpcap-src) LIBPCAP_SRC="$2"; shift 2;;
    --sdk) SDK="$2"; shift 2;;
    --target) TARGET="$2"; shift 2;;
    --prefix) PREFIX="$2"; shift 2;;
    --link|--linkage) LINKAGE="$2"; shift 2;;
    --pcap-type) PCAP_TYPE="$2"; shift 2;;
    --ipv6) IPV6="$(normalize_yes_no "$2")"; shift 2;;
    --remote) REMOTE="$(normalize_yes_no "$2")"; shift 2;;
    --crypto) CRYPTO="$(normalize_yes_no "$2")"; shift 2;;
    --smi) SMI="$(normalize_yes_no "$2")"; shift 2;;
    --smb) SMB="$(normalize_yes_no "$2")"; shift 2;;
    --user) USER_DROP="$2"; shift 2;;
    --chroot) CHROOT_DIR="$2"; shift 2;;
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
[[ -z "$CHROOT_DIR" || "$CHROOT_DIR" == /* ]] || die "--chroot must be absolute"

TARGET_ID="${TARGET//[^A-Za-z0-9_.-]/-}"

SOURCE_DIR="$(cd "$SOURCE_DIR" && pwd)"
[[ -x "$SOURCE_DIR/configure" ]] || die "tcpdump configure not found: $SOURCE_DIR/configure"

if [[ -z "$LIBPCAP_SRC" ]]; then
  LIBPCAP_SRC="$(find_sibling_source "$(dirname "$SOURCE_DIR")" 'libpcap-*' || true)"
fi
[[ -n "$LIBPCAP_SRC" ]] || die "libpcap source not found; use --libpcap-src PATH"
LIBPCAP_SRC="$(cd "$LIBPCAP_SRC" && pwd)"
[[ -x "$LIBPCAP_SRC/configure" ]] || die "libpcap configure not found: $LIBPCAP_SRC/configure"

TOOLBIN="$(find_sdk_bin "$SDK")" || die "cannot find ${TARGET}-gcc below $SDK"
export PATH="$TOOLBIN:$PATH"

CC="${TARGET}-gcc"
AR="${TARGET}-ar"
RANLIB="${TARGET}-ranlib"
STRIP="${TARGET}-strip"
READELF="${TARGET}-readelf"

for x in "$CC" "$AR" "$RANLIB" "$STRIP" "$READELF" make file tar sha256sum pkg-config; do
  need_cmd "$x"
done
[[ "$UPX_COMPRESS" == yes ]] && need_cmd "$UPX_BIN"

SYSROOT="$("$CC" -print-sysroot)"
[[ -d "$SYSROOT" ]] || die "bad sysroot: $SYSROOT"
if [[ "$LINKAGE" == static ]]; then
  find "$SYSROOT/lib" "$SYSROOT/usr/lib" -name libc.a -type f -print -quit 2>/dev/null |
    grep -q . || die "missing static runtime library: libc.a"
fi

version="$(basename "$SOURCE_DIR" | sed 's/^tcpdump-//')"
libpcap_version="$(basename "$LIBPCAP_SRC" | sed 's/^libpcap-//')"
work_base="$(cd "$(dirname "$SOURCE_DIR")" && pwd)"
dist_base="$SOURCE_DIR"
WORK="$work_base/.${TARGET_ID}-tcpdump-$LINKAGE"
DEPS="$WORK/deps"
PCAP_BUILD="$WORK/libpcap"
TCPDUMP_BUILD="$WORK/tcpdump"
STAGE="$WORK/stage"
DIST="$dist_base/dist-${TARGET_ID}-tcpdump"
PKG_CONFIG_WRAPPER="$WORK/pkg-config"

[[ "$CLEAN" == yes ]] && rm -rf "$WORK"
rm -rf "$DEPS" "$PCAP_BUILD" "$TCPDUMP_BUILD" "$STAGE"
mkdir -p "$DEPS" "$PCAP_BUILD" "$TCPDUMP_BUILD" "$STAGE" "$DIST"

COMMON_CFLAGS="-Os -ffunction-sections -fdata-sections"
COMMON_CPPFLAGS="-D_GNU_SOURCE -D_DEFAULT_SOURCE -D_BSD_SOURCE -I$DEPS/include"
if [[ "$LINKAGE" == static ]]; then
  LDFLAGS_LINK="-static -static-libgcc -Wl,--gc-sections"
  LINK_OPTS=(--enable-static --disable-shared)
else
  LDFLAGS_LINK="-Wl,--gc-sections -Wl,-rpath,$PREFIX/lib"
  LINK_OPTS=(--disable-static --enable-shared)
fi

PKG_CONFIG_PATH_VALUE="$DEPS/lib/pkgconfig:$DEPS/share/pkgconfig"
cat >"$PKG_CONFIG_WRAPPER" <<EOF
#!/usr/bin/env bash
set -e
if [[ "$LINKAGE" == "static" ]]; then
  exec pkg-config --static "\$@"
else
  exec pkg-config "\$@"
fi
EOF
chmod 755 "$PKG_CONFIG_WRAPPER"

BUILD_TRIPLET="$("$SOURCE_DIR/config.guess" 2>/dev/null ||
  "$SOURCE_DIR/build-aux/config.guess" 2>/dev/null ||
  gcc -dumpmachine)"

pcap_opts=(
  "--build=$BUILD_TRIPLET"
  "--host=$TARGET"
  "--prefix=$DEPS"
  "--libdir=$DEPS/lib"
  "${LINK_OPTS[@]}"
)

if configure_has "$LIBPCAP_SRC/configure" "--with-pcap"; then
  pcap_opts+=("--with-pcap=$PCAP_TYPE")
fi
if [[ "$IPV6" == yes ]]; then
  append_supported_option "$LIBPCAP_SRC/configure" --enable-ipv6 pcap_opts
else
  append_supported_option "$LIBPCAP_SRC/configure" --disable-ipv6 pcap_opts
fi
if [[ "$REMOTE" == yes ]]; then
  append_supported_option "$LIBPCAP_SRC/configure" --enable-remote pcap_opts
else
  append_supported_option "$LIBPCAP_SRC/configure" --disable-remote pcap_opts
fi
append_supported_option "$LIBPCAP_SRC/configure" --without-libnl pcap_opts
append_supported_option "$LIBPCAP_SRC/configure" --disable-usb pcap_opts
append_supported_option "$LIBPCAP_SRC/configure" --disable-bluetooth pcap_opts
append_supported_option "$LIBPCAP_SRC/configure" --disable-dbus pcap_opts
append_supported_option "$LIBPCAP_SRC/configure" --disable-rdma pcap_opts
append_supported_option "$LIBPCAP_SRC/configure" --disable-netmap pcap_opts

log "Build $LINKAGE libpcap $libpcap_version"
(
  cd "$PCAP_BUILD"
  env \
    PATH="$TOOLBIN:$PATH" \
    CC="$CC" AR="$AR" RANLIB="$RANLIB" STRIP="$STRIP" \
    CFLAGS="$COMMON_CFLAGS" \
    CPPFLAGS="$COMMON_CPPFLAGS" \
    LDFLAGS="$LDFLAGS_LINK" \
    "$LIBPCAP_SRC/configure" "${pcap_opts[@]}"
  make -j"$JOBS"
  make install
)

tcpdump_opts=(
  "--build=$BUILD_TRIPLET"
  "--host=$TARGET"
  "--prefix=$PREFIX"
  "--sbindir=$PREFIX/sbin"
  "${LINK_OPTS[@]}"
)

append_supported_option "$SOURCE_DIR/configure" --disable-local-libpcap tcpdump_opts
[[ "$SMB" == yes ]] && append_supported_option "$SOURCE_DIR/configure" --enable-smb tcpdump_opts
[[ "$SMB" == no ]] && append_supported_option "$SOURCE_DIR/configure" --disable-smb tcpdump_opts
[[ "$SMI" == yes ]] && append_supported_option "$SOURCE_DIR/configure" --with-smi tcpdump_opts
[[ "$SMI" == no ]] && append_supported_option "$SOURCE_DIR/configure" --without-smi tcpdump_opts
[[ "$CRYPTO" == yes ]] && append_supported_option "$SOURCE_DIR/configure" --with-crypto tcpdump_opts
[[ "$CRYPTO" == no ]] && append_supported_option "$SOURCE_DIR/configure" --without-crypto tcpdump_opts
[[ -n "$USER_DROP" ]] && tcpdump_opts+=("--with-user=$USER_DROP")
[[ -n "$CHROOT_DIR" ]] && tcpdump_opts+=("--with-chroot=$CHROOT_DIR")

log "Build $LINKAGE tcpdump $version"
(
  cd "$TCPDUMP_BUILD"
  env \
    PATH="$TOOLBIN:$PATH" \
    CC="$CC" AR="$AR" RANLIB="$RANLIB" STRIP="$STRIP" \
    CFLAGS="$COMMON_CFLAGS" \
    CPPFLAGS="$COMMON_CPPFLAGS" \
    LDFLAGS="$LDFLAGS_LINK -L$DEPS/lib" \
    LIBS="-lpcap" \
    PKG_CONFIG="$PKG_CONFIG_WRAPPER" \
    PKG_CONFIG_PATH="$PKG_CONFIG_PATH_VALUE" \
    PKG_CONFIG_LIBDIR="$PKG_CONFIG_PATH_VALUE" \
    "$SOURCE_DIR/configure" "${tcpdump_opts[@]}"
  make -j"$JOBS" \
    LDFLAGS="$LDFLAGS_LINK -L$DEPS/lib" \
    LIBS="-lpcap"
  make DESTDIR="$STAGE" install \
    LDFLAGS="$LDFLAGS_LINK -L$DEPS/lib" \
    LIBS="-lpcap"
)

if [[ "$LINKAGE" == dynamic ]]; then
  mkdir -p "$STAGE$PREFIX/lib"
  find "$DEPS/lib" -maxdepth 1 -name 'libpcap.so*' -exec cp -a {} "$STAGE$PREFIX/lib/" \; 2>/dev/null || true
fi

TCPDUMP_BIN="$STAGE$PREFIX/sbin/tcpdump"
[[ -f "$TCPDUMP_BIN" ]] || TCPDUMP_BIN="$(find "$STAGE$PREFIX" -type f -name tcpdump -print -quit)"
[[ -n "$TCPDUMP_BIN" && -f "$TCPDUMP_BIN" ]] || die "tcpdump binary not found below $STAGE$PREFIX"

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

validate_linkage "$TCPDUMP_BIN"

[[ "$STRIP_BIN" == yes ]] && "$STRIP" --strip-unneeded "$TCPDUMP_BIN"
if [[ "$UPX_COMPRESS" == yes ]]; then
  "$UPX_BIN" --best --lzma "$TCPDUMP_BIN"
  validate_linkage "$TCPDUMP_BIN"
fi

cat >"$STAGE$PREFIX/environment-setup.sh" <<EOF
#!/bin/sh
TCPDUMP_ROOT="$PREFIX"
export PATH="\$TCPDUMP_ROOT/sbin:\$PATH"
if [ "$LINKAGE" = "dynamic" ]; then
  export LD_LIBRARY_PATH="\$TCPDUMP_ROOT/lib\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
fi
EOF
chmod 755 "$STAGE$PREFIX/environment-setup.sh"

archive="$DIST/tcpdump-${version}-${TARGET_ID}-${LINKAGE}.tar.gz"
tar --numeric-owner -C "$STAGE" -czf "$archive" ".${PREFIX}"
sha256sum "$archive" >"$archive.sha256"

log "Done"
echo "Archive:  $archive"
echo "Checksum: $archive.sha256"
echo "Deploy:"
echo "  tar -xzf /tmp/$(basename "$archive") -C /"
echo "  . $PREFIX/environment-setup.sh"
echo "  tcpdump --version"
