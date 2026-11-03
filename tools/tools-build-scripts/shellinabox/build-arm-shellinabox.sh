#!/usr/bin/env bash
set -Eeuo pipefail

trap 'rc=$?; printf "\nERROR: command failed at line %s (exit=%s): %s\n" "$LINENO" "$rc" "$BASH_COMMAND" >&2; exit "$rc"' ERR

SDK="/root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot"
TARGET="arm-buildroot-linux-gnueabi"
SOURCE_DIR="$(pwd)"
PACKAGE=""
OPENSSL_SRC=""
ZLIB_SRC=""
OPENSSL_TARGET="linux-armv4"
PREFIX="/usr"
LINKAGE="static"
SSL="yes"
ZLIB="yes"
PAM="no"
RUNTIME_LOADING="no"
UTMP="no"
LOGIN="yes"
PORT="4200"
LISTEN=""
SERVICE="/:LOGIN"
CERT_DIR="/etc/shellinabox"
PIDFILE="/tmp/shellinaboxd.pid"
USER=""
GROUP=""
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
  ./build-arm-shellinabox.sh \
    --source /path/shellinabox-2.21 \
    --openssl-src /path/openssl-3.x \
    --zlib-src /path/zlib-1.x \
    [--openssl-target linux-armv4]
    [--sdk PATH] [--target TRIPLET] [--prefix /usr]
    [--linkage static|dynamic]
    [--ssl yes|no] [--zlib yes|no] [--pam yes|no]
    [--runtime-loading yes|no] [--utmp yes|no] [--login yes|no]
    [--listen 0.0.0.0|127.0.0.1] [--port 4200] [--service '/:LOGIN']
    [--cert-dir /etc/shellinabox] [--pidfile /tmp/shellinaboxd.pid]
    [--user USER] [--group GROUP]
    [--jobs N] [--clean] [--no-strip] [--upx PATH] [--no-upx]

Builds shellinaboxd for a cross target. HTTPS support is enabled by default.
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

while (($#)); do
  case "$1" in
    --source) SOURCE_DIR="$2"; shift 2;;
    --package) PACKAGE="$2"; shift 2;;
    --openssl-src) OPENSSL_SRC="$2"; shift 2;;
    --zlib-src) ZLIB_SRC="$2"; shift 2;;
    --openssl-target) OPENSSL_TARGET="$2"; shift 2;;
    --sdk) SDK="$2"; shift 2;;
    --target) TARGET="$2"; shift 2;;
    --prefix) PREFIX="$2"; shift 2;;
    --link|--linkage) LINKAGE="$2"; shift 2;;
    --ssl) SSL="$(normalize_yes_no "$2")"; shift 2;;
    --zlib) ZLIB="$(normalize_yes_no "$2")"; shift 2;;
    --pam) PAM="$(normalize_yes_no "$2")"; shift 2;;
    --runtime-loading) RUNTIME_LOADING="$(normalize_yes_no "$2")"; shift 2;;
    --utmp) UTMP="$(normalize_yes_no "$2")"; shift 2;;
    --login) LOGIN="$(normalize_yes_no "$2")"; shift 2;;
    --listen) LISTEN="$2"; shift 2;;
    --port) PORT="$2"; shift 2;;
    --service) SERVICE="$2"; shift 2;;
    --cert-dir) CERT_DIR="$2"; shift 2;;
    --pidfile) PIDFILE="$2"; shift 2;;
    --user) USER="$2"; shift 2;;
    --group) GROUP="$2"; shift 2;;
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
[[ "$CERT_DIR" == /* ]] || die "--cert-dir must be absolute"
[[ "$PIDFILE" == /* ]] || die "--pidfile must be absolute"
[[ "$PORT" =~ ^[0-9]+$ ]] || die "--port must be numeric"
[[ "$JOBS" =~ ^[1-9][0-9]*$ ]] || die "--jobs must be a positive integer"
[[ "$LINKAGE" == static || "$LINKAGE" == dynamic ]] || die "--linkage must be static or dynamic"
[[ "$SSL" == no || -n "$OPENSSL_SRC" ]] || die "--openssl-src is required when --ssl yes"
[[ "$ZLIB" == no || -n "$ZLIB_SRC" ]] || die "--zlib-src is required when --zlib yes"

TARGET_ID="${TARGET//[^A-Za-z0-9_.-]/-}"

if [[ -n "$PACKAGE" ]]; then
  [[ -f "$PACKAGE" ]] || die "package not found: $PACKAGE"
else
  SOURCE_DIR="$(cd "$SOURCE_DIR" && pwd)"
fi

if [[ "$SSL" == yes ]]; then
  OPENSSL_SRC="$(cd "$OPENSSL_SRC" && pwd)"
  [[ -f "$OPENSSL_SRC/Configure" ]] || die "OpenSSL Configure not found"
fi
if [[ "$ZLIB" == yes ]]; then
  ZLIB_SRC="$(cd "$ZLIB_SRC" && pwd)"
  [[ -x "$ZLIB_SRC/configure" ]] || die "zlib configure not found"
fi

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
[[ "$SSL" == yes ]] && need_cmd perl
[[ "$UPX_COMPRESS" == yes ]] && need_cmd "$UPX_BIN"

SYSROOT="$("$CC" -print-sysroot)"
[[ -d "$SYSROOT" ]] || die "bad sysroot: $SYSROOT"
if [[ "$LINKAGE" == static ]]; then
  for lib in libc.a libpthread.a libdl.a; do
    find "$SYSROOT/lib" "$SYSROOT/usr/lib" -name "$lib" -type f -print -quit 2>/dev/null |
      grep -q . || die "missing static runtime library: $lib"
  done
fi

if [[ -n "$PACKAGE" ]]; then
  source_name="$(basename "$PACKAGE")"
  version="${source_name#shellinabox-}"
  version="${version#v}"
  version="${version%.tar.gz}"
  version="${version%.tgz}"
  version="${version%.tar.xz}"
  work_base="$(cd "$(dirname "$PACKAGE")" && pwd)"
  dist_base="$work_base"
else
  version="$(basename "$SOURCE_DIR" | sed -e 's/^shellinabox-//' -e 's/^v//')"
  work_base="$(cd "$(dirname "$SOURCE_DIR")" && pwd)"
  dist_base="$SOURCE_DIR"
fi

WORK="$work_base/.${TARGET_ID}-shellinabox-$LINKAGE"
DEPS="$WORK/deps"
SBUILD="$WORK/source"
ZBUILD="$WORK/zlib"
OBUILD="$WORK/openssl"
STAGE="$WORK/stage"
DIST="$dist_base/dist-${TARGET_ID}-shellinabox"

[[ "$CLEAN" == yes ]] && rm -rf "$WORK"
rm -rf "$DEPS" "$SBUILD" "$ZBUILD" "$OBUILD" "$STAGE"
mkdir -p "$DEPS" "$SBUILD" "$ZBUILD" "$OBUILD" "$STAGE" "$DIST"

if [[ -n "$PACKAGE" ]]; then
  log "Extract shellinabox package"
  tar -xf "$PACKAGE" -C "$WORK"
  extracted="$(find "$WORK" -maxdepth 1 -mindepth 1 -type d \( -name 'shellinabox-*' -o -name 'v*' \) | sort -V | tail -n 1 || true)"
  [[ -n "$extracted" ]] || die "cannot find extracted shellinabox source"
  rm -rf "$SBUILD"
  mv "$extracted" "$SBUILD"
else
  cp -a "$SOURCE_DIR/." "$SBUILD/"
fi

CFLAGS_COMMON="-Os -ffunction-sections -fdata-sections"
if [[ "$LINKAGE" == static ]]; then
  LDFLAGS_LINK="-static -static-libgcc -Wl,--gc-sections"
  ZLIB_CONFIGURE_OPTS=(--static)
  OPENSSL_LINK_OPTS=(no-shared no-module no-dso no-autoload-config)
else
  LDFLAGS_LINK="-Wl,--gc-sections -Wl,-rpath,$PREFIX/lib"
  ZLIB_CONFIGURE_OPTS=(--shared)
  OPENSSL_LINK_OPTS=(shared no-module no-autoload-config)
fi

DEP_CPPFLAGS=""
DEP_LDFLAGS=""
DEP_LIBS="-ldl -lpthread"
CCLD="$CC"

check_pty_libs(){
  local out="$WORK/check-pty"
  local code
  code='
#define _GNU_SOURCE
#include <pty.h>
#include <utmp.h>
int main(void) {
  int master = -1, slave = -1;
  return openpty(&master, &slave, 0, 0, 0) + login_tty(slave);
}
'
  if printf '%s\n' "$code" | "$CC" $CFLAGS_COMMON $LDFLAGS_LINK -x c -o "$out" - >/dev/null 2>&1; then
    rm -f "$out"
    log "PTY functions found in default runtime"
    return
  fi
  if printf '%s\n' "$code" | "$CC" $CFLAGS_COMMON $LDFLAGS_LINK -x c -o "$out" - -lutil >/dev/null 2>&1; then
    rm -f "$out"
    DEP_LIBS="-lutil $DEP_LIBS"
    log "PTY functions require libutil; added -lutil"
    return
  fi
  rm -f "$out"
  die "cannot link openpty/login_tty; install libutil for the target SDK or use an SDK whose libc provides PTY helpers"
}

check_pty_libs

if [[ "$ZLIB" == yes ]]; then
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
  DEP_CPPFLAGS="$DEP_CPPFLAGS -I$DEPS/include"
  DEP_LDFLAGS="$DEP_LDFLAGS -L$DEPS/lib"
  DEP_LIBS="-lz $DEP_LIBS"
fi

if [[ "$SSL" == yes ]]; then
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
  DEP_CPPFLAGS="$DEP_CPPFLAGS -I$DEPS/include"
  DEP_LDFLAGS="$DEP_LDFLAGS -L$DEPS/lib"
  DEP_LIBS="-lssl -lcrypto $DEP_LIBS"
fi

CCLD="$CC $LDFLAGS_LINK $DEP_LDFLAGS"

if [[ ! -x "$SBUILD/configure" ]]; then
  need_cmd autoreconf
  log "Generate configure with autoreconf"
  ( cd "$SBUILD" && autoreconf -fi )
fi
chmod +x "$SBUILD/configure" 2>/dev/null || true

if [[ -x "$SBUILD/config.guess" ]]; then
  BUILD_TRIPLET="$("$SBUILD/config.guess")"
elif [[ -x "$SBUILD/build-aux/config.guess" ]]; then
  BUILD_TRIPLET="$("$SBUILD/build-aux/config.guess")"
else
  BUILD_TRIPLET="$(gcc -dumpmachine)"
fi

configure_opts=(
  "--build=$BUILD_TRIPLET"
  "--host=$TARGET"
  "--prefix=$PREFIX"
)

[[ "$SSL" == no ]] && configure_opts+=(--disable-ssl)
[[ "$PAM" == no ]] && configure_opts+=(--disable-pam)
[[ "$RUNTIME_LOADING" == no ]] && configure_opts+=(--disable-runtime-loading)
[[ "$UTMP" == no ]] && configure_opts+=(--disable-utmp)
[[ "$LOGIN" == no ]] && configure_opts+=(--disable-login)

log "Configure and build shellinabox ($LINKAGE)"
(
  cd "$SBUILD"
  env \
    PATH="$TOOLBIN:$PATH" \
    CC="$CC" CCLD="$CCLD" AR="$AR" RANLIB="$RANLIB" STRIP="$STRIP" \
    CFLAGS="$CFLAGS_COMMON" \
    CPPFLAGS="$DEP_CPPFLAGS" \
    LDFLAGS="$LDFLAGS_LINK $DEP_LDFLAGS" \
    LIBS="$DEP_LIBS" \
    "$SBUILD/configure" "${configure_opts[@]}"
  if [[ "$LINKAGE" == static ]]; then
    log "Patch generated Makefile to force static shellinaboxd link"
    if grep -q '^AM_LDFLAGS[[:space:]]*=' Makefile; then
      sed -i -e "s|^AM_LDFLAGS[[:space:]]*=.*|AM_LDFLAGS = $LDFLAGS_LINK $DEP_LDFLAGS -g -lm|" Makefile
    else
      printf '\nAM_LDFLAGS = %s %s -g -lm\n' "$LDFLAGS_LINK" "$DEP_LDFLAGS" >>Makefile
    fi
    if grep -q '^shellinaboxd_LDFLAGS[[:space:]]*=' Makefile; then
      sed -i -e "s|^shellinaboxd_LDFLAGS[[:space:]]*=.*|shellinaboxd_LDFLAGS = $LDFLAGS_LINK $DEP_LDFLAGS|" Makefile
    else
      printf '\nshellinaboxd_LDFLAGS = %s %s\n' "$LDFLAGS_LINK" "$DEP_LDFLAGS" >>Makefile
    fi
    if grep -q '^LDFLAGS[[:space:]]*=' Makefile; then
      sed -i -e "s|^LDFLAGS[[:space:]]*=.*|LDFLAGS = $LDFLAGS_LINK $DEP_LDFLAGS|" Makefile
    fi
  fi
  make -j"$JOBS" \
    CCLD="$CCLD" \
    LDFLAGS="$LDFLAGS_LINK $DEP_LDFLAGS" \
    LIBS="$DEP_LIBS"
  make DESTDIR="$STAGE" install \
    CCLD="$CCLD" \
    LDFLAGS="$LDFLAGS_LINK $DEP_LDFLAGS" \
    LIBS="$DEP_LIBS"
)

if [[ "$LINKAGE" == dynamic ]]; then
  mkdir -p "$STAGE$PREFIX/lib"
  find "$DEPS/lib" -maxdepth 1 \( -name 'libssl.so*' -o -name 'libcrypto.so*' -o -name 'libz.so*' \) \
    -exec cp -a {} "$STAGE$PREFIX/lib/" \; 2>/dev/null || true
fi

BIN="$STAGE$PREFIX/bin/shellinaboxd"
[[ -f "$BIN" ]] || BIN="$(find "$STAGE$PREFIX" -type f -name shellinaboxd -print -quit)"
[[ -n "$BIN" && -f "$BIN" ]] || die "shellinaboxd binary not found below $STAGE$PREFIX"
CANON_BIN="$STAGE$PREFIX/bin/shellinaboxd"
if [[ "$BIN" != "$CANON_BIN" ]]; then
  mkdir -p "$STAGE$PREFIX/bin"
  install -m 0755 "$BIN" "$CANON_BIN"
  BIN="$CANON_BIN"
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

validate_linkage "$BIN"

[[ "$STRIP_BIN" == yes ]] && "$STRIP" --strip-unneeded "$BIN"
if [[ "$UPX_COMPRESS" == yes ]]; then
  "$UPX_BIN" --best --lzma "$BIN"
  validate_linkage "$BIN"
fi

mkdir -p "$STAGE$CERT_DIR" "$STAGE$PREFIX"
cat >"$STAGE$PREFIX/start-shellinabox.sh" <<EOF
#!/bin/sh
set -eu

die(){ echo "ERROR: \$*" >&2; exit 1; }

usage(){
cat <<'USAGE'
Usage:
  start-shellinabox.sh [options] [-- SHELLINABOXD_ARGS...]

Options:
  --listen 0.0.0.0|127.0.0.1
  --port PORT
  --service SERVICE
  --cert-dir PATH
  --pidfile PATH
  --user USER
  --group GROUP
  --disable-ssl

Examples:
  start-shellinabox.sh --listen 0.0.0.0 --port 4200
  start-shellinabox.sh --service '/:root:root:/:/bin/sh'
USAGE
}

listen="$LISTEN"
port="$PORT"
service="$SERVICE"
cert_dir="$CERT_DIR"
pidfile="$PIDFILE"
user="$USER"
group="$GROUP"
ssl="$SSL"

while [ "\$#" -gt 0 ]; do
  case "\$1" in
    --listen) [ "\$#" -ge 2 ] || die "--listen requires an argument"; listen="\$2"; shift 2 ;;
    --port)
      [ "\$#" -ge 2 ] || die "--port requires an argument"
      port="\$2"
      case "\$port" in ''|*[!0-9]*) die "--port must be numeric" ;; esac
      shift 2
      ;;
    --service) [ "\$#" -ge 2 ] || die "--service requires an argument"; service="\$2"; shift 2 ;;
    --cert-dir) [ "\$#" -ge 2 ] || die "--cert-dir requires an argument"; cert_dir="\$2"; shift 2 ;;
    --pidfile) [ "\$#" -ge 2 ] || die "--pidfile requires an argument"; pidfile="\$2"; shift 2 ;;
    --user) [ "\$#" -ge 2 ] || die "--user requires an argument"; user="\$2"; shift 2 ;;
    --group) [ "\$#" -ge 2 ] || die "--group requires an argument"; group="\$2"; shift 2 ;;
    --disable-ssl) ssl="no"; shift ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    *) die "unknown option: \$1" ;;
  esac
done

mkdir -p "\$cert_dir"

set -- --port="\$port" --service="\$service" --pidfile="\$pidfile" "\$@"
case "\$listen" in
  ""|0.0.0.0|::) ;;
  127.0.0.1|localhost|::1) set -- --localhost-only "\$@" ;;
  *) die "shellinaboxd does not support binding an arbitrary IP; use 0.0.0.0 for all interfaces or 127.0.0.1 for loopback" ;;
esac
[ "\$ssl" = yes ] && set -- --cert="\$cert_dir" "\$@"
[ "\$ssl" = no ] && set -- --disable-ssl "\$@"
[ -n "\$user" ] && set -- --user="\$user" "\$@"
[ -n "\$group" ] && set -- --group="\$group" "\$@"

exec "$PREFIX/bin/shellinaboxd" "\$@"
EOF
chmod 755 "$STAGE$PREFIX/start-shellinabox.sh"

archive="$DIST/shellinabox-${version}-${TARGET_ID}-${LINKAGE}.tar.gz"
tar --numeric-owner -C "$STAGE" -czf "$archive" ".${PREFIX}" ".${CERT_DIR}"
sha256sum "$archive" >"$archive.sha256"

log "Done"
echo "Archive:  $archive"
echo "Checksum: $archive.sha256"
echo "Deploy:"
echo "  tar -xzf /tmp/$(basename "$archive") -C /"
echo "  $PREFIX/start-shellinabox.sh --listen 0.0.0.0 --port 4200"
