#!/usr/bin/env bash
set -Eeuo pipefail

trap 'rc=$?; printf "\nERROR: command failed at line %s (exit=%s): %s\n" "$LINENO" "$rc" "$BASH_COMMAND" >&2; exit "$rc"' ERR

SDK="/root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot"
TARGET="arm-buildroot-linux-gnueabi"
SOURCE_DIR="$(pwd)"
OPENSSL_SRC=""
ZLIB_SRC=""
OPENSSL_TARGET="linux-armv4"
PREFIX="/usr"
LINKAGE="static"
CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt"
CA_PATH="/etc/ssl/certs"
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
  ./build-arm-curl.sh \
    --source /path/curl-8.x \
    --openssl-src /path/openssl-3.x \
    --zlib-src /path/zlib-1.x \
    [--openssl-target linux-armv4]
    [--sdk PATH] [--target TRIPLET] [--prefix /usr]
    [--linkage static|dynamic] [--ca-bundle PATH] [--ca-path PATH]
    [--jobs N] [--clean] [--no-strip] [--upx PATH] [--no-upx]

Builds a minimal HTTPS-capable curl:
  HTTP/HTTPS + OpenSSL + zlib, with most optional protocols/features disabled.
EOF
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

append_supported_option(){
  local configure="$1"
  local option="$2"
  local -n destination="$3"
  if configure_has "$configure" "$option"; then
    destination+=("$option")
  fi
}

while (($#)); do
  case "$1" in
    --source) SOURCE_DIR="$2"; shift 2;;
    --openssl-src) OPENSSL_SRC="$2"; shift 2;;
    --zlib-src) ZLIB_SRC="$2"; shift 2;;
    --openssl-target) OPENSSL_TARGET="$2"; shift 2;;
    --sdk) SDK="$2"; shift 2;;
    --target) TARGET="$2"; shift 2;;
    --prefix) PREFIX="$2"; shift 2;;
    --link|--linkage) LINKAGE="$2"; shift 2;;
    --ca-bundle) CA_BUNDLE="$2"; shift 2;;
    --ca-path) CA_PATH="$2"; shift 2;;
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
[[ "$CA_BUNDLE" == /* ]] || die "--ca-bundle must be absolute"
[[ "$CA_PATH" == /* ]] || die "--ca-path must be absolute"
[[ "$LINKAGE" == static || "$LINKAGE" == dynamic ]] || die "--linkage must be static or dynamic"
[[ "$JOBS" =~ ^[1-9][0-9]*$ ]] || die "--jobs must be a positive integer"
[[ -n "$OPENSSL_SRC" ]] || die "--openssl-src is required"
[[ -n "$ZLIB_SRC" ]] || die "--zlib-src is required"
TARGET_ID="${TARGET//[^A-Za-z0-9_.-]/-}"

SOURCE_DIR="$(cd "$SOURCE_DIR" && pwd)"
OPENSSL_SRC="$(cd "$OPENSSL_SRC" && pwd)"
ZLIB_SRC="$(cd "$ZLIB_SRC" && pwd)"
[[ -x "$SOURCE_DIR/configure" ]] || die "curl configure not found: $SOURCE_DIR/configure"
[[ -f "$OPENSSL_SRC/Configure" ]] || die "OpenSSL Configure not found"
[[ -x "$ZLIB_SRC/configure" ]] || die "zlib configure not found"

TOOLBIN="$(find_sdk_bin "$SDK")" || die "cannot find ${TARGET}-gcc below $SDK"
export PATH="$TOOLBIN:$PATH"

CC="${TARGET}-gcc"
AR="${TARGET}-ar"
RANLIB="${TARGET}-ranlib"
STRIP="${TARGET}-strip"
READELF="${TARGET}-readelf"

for x in "$CC" "$AR" "$RANLIB" "$STRIP" "$READELF" make perl file tar sha256sum; do
  need_cmd "$x"
done
[[ "$UPX_COMPRESS" == yes ]] && need_cmd "$UPX_BIN"

SYSROOT="$("$CC" -print-sysroot)"
[[ -d "$SYSROOT" ]] || die "bad sysroot: $SYSROOT"
if [[ "$LINKAGE" == static ]]; then
  for lib in libc.a libpthread.a libdl.a; do
    find "$SYSROOT/lib" "$SYSROOT/usr/lib" -name "$lib" -type f -print -quit 2>/dev/null |
      grep -q . || die "missing static runtime library: $lib"
  done
fi

version="$(basename "$SOURCE_DIR" | sed 's/^curl-//')"
WORK="$SOURCE_DIR/.${TARGET_ID}-curl-$LINKAGE"
DEPS="$WORK/deps"
ZBUILD="$WORK/zlib"
OBUILD="$WORK/openssl"
CBUILD="$WORK/curl"
STAGE="$WORK/stage"
DIST="$SOURCE_DIR/dist-${TARGET_ID}-curl"

[[ "$CLEAN" == yes ]] && rm -rf "$WORK"
rm -rf "$DEPS" "$ZBUILD" "$OBUILD" "$CBUILD" "$STAGE"
mkdir -p "$DEPS" "$ZBUILD" "$OBUILD" "$CBUILD" "$STAGE" "$DIST"

CFLAGS_COMMON="-Os -ffunction-sections -fdata-sections"
if [[ "$LINKAGE" == static ]]; then
  LDFLAGS_LINK="-static -static-libgcc -Wl,--gc-sections"
  CURL_CONFIGURE_LINK_OPTS=(--disable-shared --enable-static)
  ZLIB_CONFIGURE_OPTS=(--static)
  OPENSSL_LINK_OPTS=(no-shared no-module no-dso no-autoload-config)
else
  LDFLAGS_LINK="-Wl,--gc-sections -Wl,-rpath,$PREFIX/lib"
  CURL_CONFIGURE_LINK_OPTS=(--enable-shared --disable-static)
  ZLIB_CONFIGURE_OPTS=(--shared)
  OPENSSL_LINK_OPTS=(shared no-module no-autoload-config)
fi

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

BUILD_TRIPLET="$("$SOURCE_DIR/config.guess" 2>/dev/null || gcc -dumpmachine)"

log "Build $LINKAGE zlib"
cp -a "$ZLIB_SRC/." "$ZBUILD/"
(
  cd "$ZBUILD"
  make distclean >/dev/null 2>&1 || true
  CHOST="$TARGET" CC="$CC" AR="$AR" RANLIB="$RANLIB" \
    CFLAGS="$CFLAGS_COMMON" \
    ./configure "${ZLIB_CONFIGURE_OPTS[@]}" --prefix="$DEPS"
  make -j"$JOBS"
  make install
)

log "Build $LINKAGE OpenSSL"
(
  cd "$OBUILD"
  unset CROSS_COMPILE CC CXX AR AS LD NM RANLIB STRIP
  perl "$OPENSSL_SRC/Configure" "$OPENSSL_TARGET" \
    "--cross-compile-prefix=${TARGET}-" \
    "--prefix=$DEPS" \
    "--openssldir=$PREFIX/etc/ssl" \
    "${OPENSSL_LINK_OPTS[@]}" \
    no-tests no-docs no-async no-engine no-comp \
    no-ssl3 no-weak-ssl-ciphers \
    $CFLAGS_COMMON
  make -j"$JOBS" build_libs
  make install_dev
)

curl_opts=(
  "--build=$BUILD_TRIPLET"
  "--host=$TARGET"
  "--prefix=$PREFIX"
  "--with-openssl=$DEPS"
  "--with-zlib=$DEPS"
  "--with-ca-bundle=$CA_BUNDLE"
  "--with-ca-path=$CA_PATH"
  "${CURL_CONFIGURE_LINK_OPTS[@]}"
)

for o in \
  --disable-ftp --disable-file --disable-ldap --disable-ldaps \
  --disable-rtsp --disable-dict --disable-telnet --disable-tftp \
  --disable-pop3 --disable-imap --disable-smb --disable-smtp \
  --disable-gopher --disable-mqtt --disable-manual --disable-libcurl-option \
  --without-libidn2 --without-libpsl --without-nghttp2 --without-ngtcp2 \
  --without-nghttp3 --without-brotli --without-zstd --without-libssh2 \
  --without-librtmp --without-gssapi --without-ca-fallback; do
  append_supported_option "$SOURCE_DIR/configure" "$o" curl_opts
done

log "Configure and build curl ($LINKAGE)"
(
  cd "$CBUILD"
  env \
    PATH="$TOOLBIN:$PATH" \
    CC="$CC" AR="$AR" RANLIB="$RANLIB" STRIP="$STRIP" \
    CFLAGS="$CFLAGS_COMMON" \
    CPPFLAGS="-I$DEPS/include" \
    LDFLAGS="$LDFLAGS_LINK -L$DEPS/lib" \
    LIBS="-lssl -lcrypto -lz -ldl -lpthread" \
    PKG_CONFIG_PATH="$DEPS/lib/pkgconfig" \
    PKG_CONFIG_LIBDIR="$DEPS/lib/pkgconfig" \
    "$SOURCE_DIR/configure" "${curl_opts[@]}"
  make -j"$JOBS" \
    LDFLAGS="$LDFLAGS_LINK -L$DEPS/lib" \
    LIBS="-lssl -lcrypto -lz -ldl -lpthread"
  make DESTDIR="$STAGE" install \
    LDFLAGS="$LDFLAGS_LINK -L$DEPS/lib" \
    LIBS="-lssl -lcrypto -lz -ldl -lpthread"
)

if [[ "$LINKAGE" == dynamic ]]; then
  mkdir -p "$STAGE$PREFIX/lib"
  find "$DEPS/lib" -maxdepth 1 \( -name 'libssl.so*' -o -name 'libcrypto.so*' -o -name 'libz.so*' \) \
    -exec cp -a {} "$STAGE$PREFIX/lib/" \;
fi

CURL_BIN="$STAGE$PREFIX/bin/curl"
[[ -f "$CURL_BIN" ]] || die "curl binary not found: $CURL_BIN"
validate_linkage "$CURL_BIN"

[[ "$STRIP_BIN" == yes ]] && "$STRIP" --strip-unneeded "$CURL_BIN"
if [[ "$UPX_COMPRESS" == yes ]]; then
  "$UPX_BIN" --best --lzma "$CURL_BIN"
  validate_linkage "$CURL_BIN"
fi

archive="$DIST/curl-${version}-${TARGET_ID}-${LINKAGE}.tar.gz"
tar --numeric-owner -C "$STAGE" -czf "$archive" ".${PREFIX}"
sha256sum "$archive" >"$archive.sha256"

log "Done"
echo "Archive:  $archive"
echo "Checksum: $archive.sha256"
echo "Deploy:"
echo "  tar -xzf /tmp/$(basename "$archive") -C /"
echo "  $PREFIX/bin/curl --version"
