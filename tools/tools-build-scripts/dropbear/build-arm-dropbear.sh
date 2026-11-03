#!/usr/bin/env bash
set -Eeuo pipefail

trap 'rc=$?; printf "\nERROR: command failed at line %s (exit=%s): %s\n" "$LINENO" "$rc" "$BASH_COMMAND" >&2; exit "$rc"' ERR

SDK="/root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot"
TARGET="arm-buildroot-linux-gnueabi"
SOURCE_DIR="$(pwd)"
PACKAGE=""
PREFIX="/usr"
SYSCONFDIR="/etc/dropbear"
HOSTKEY_DIR=""
AUTHORIZED_KEYS="/root/.ssh/authorized_keys"
AUTHORIZED_KEYS_SET="no"
ROOT_HOME="/root"
SFTP_SERVER=""
PIDFILE="/tmp/dropbear.pid"
LISTEN=""
PORT="22"
PASSWORD_AUTH="no"
ROOT_PASSWORD_AUTH="no"
LINKAGE="static"
ZLIB="auto"
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
  ./build-arm-dropbear.sh \
    --source /path/dropbear-2026.92 \
    [--sdk PATH] [--target TRIPLET] [--prefix /usr]
    [--linkage static|dynamic]
    [--sysconfdir /etc/dropbear] [--hostkey-dir PATH]
    [--authorized-keys /root/.ssh/authorized_keys] [--root-home /root]
    [--sftp-server PATH] [--listen IP] [--port 22] [--pidfile PATH]
    [--password-auth yes|no] [--root-password-auth yes|no]
    [--zlib auto|yes|no] [--jobs N] [--clean]
    [--no-strip] [--upx PATH] [--no-upx]

Builds Dropbear multicall ARM binaries:
  dropbear, dbclient, dropbearkey, dropbearconvert and scp.

Notes:
  --package PATH can be used instead of --source PATH to extract a tarball.
  Dropbear SFTP uses an external sftp-server path compiled into localoptions.h.
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
    --package) PACKAGE="$2"; shift 2;;
    --sdk) SDK="$2"; shift 2;;
    --target) TARGET="$2"; shift 2;;
    --prefix) PREFIX="$2"; shift 2;;
    --sysconfdir) SYSCONFDIR="$2"; shift 2;;
    --hostkey-dir) HOSTKEY_DIR="$2"; shift 2;;
    --authorized-keys) AUTHORIZED_KEYS="$2"; AUTHORIZED_KEYS_SET="yes"; shift 2;;
    --root-home) ROOT_HOME="$2"; shift 2;;
    --sftp-server) SFTP_SERVER="$2"; shift 2;;
    --listen) LISTEN="$2"; shift 2;;
    --port) PORT="$2"; shift 2;;
    --pidfile) PIDFILE="$2"; shift 2;;
    --password-auth) PASSWORD_AUTH="$(normalize_yes_no "$2")"; shift 2;;
    --root-password-auth) ROOT_PASSWORD_AUTH="$(normalize_yes_no "$2")"; shift 2;;
    --zlib) ZLIB="$2"; shift 2;;
    --jobs) JOBS="$2"; shift 2;;
    --link|--linkage) LINKAGE="$2"; shift 2;;
    --clean) CLEAN="yes"; shift;;
    --no-strip) STRIP_BIN="no"; shift;;
    --upx) UPX_BIN="$2"; shift 2;;
    --no-upx) UPX_COMPRESS="no"; shift;;
    -h|--help) usage; exit 0;;
    *) die "unknown option: $1";;
  esac
done

[[ "$PREFIX" == /* ]] || die "--prefix must be absolute"
[[ "$SYSCONFDIR" == /* ]] || die "--sysconfdir must be absolute"
[[ -z "$HOSTKEY_DIR" || "$HOSTKEY_DIR" == /* ]] || die "--hostkey-dir must be absolute"
[[ "$AUTHORIZED_KEYS" == /* ]] || die "--authorized-keys must be absolute"
[[ "$ROOT_HOME" == /* ]] || die "--root-home must be absolute"
[[ -z "$SFTP_SERVER" || "$SFTP_SERVER" == /* ]] || die "--sftp-server must be absolute"
[[ "$PIDFILE" == /* ]] || die "--pidfile must be absolute"
[[ "$PORT" =~ ^[0-9]+$ ]] || die "--port must be numeric"
[[ "$JOBS" =~ ^[1-9][0-9]*$ ]] || die "--jobs must be a positive integer"
[[ "$LINKAGE" == static || "$LINKAGE" == dynamic ]] || die "--linkage must be static or dynamic"
[[ "$ZLIB" == auto || "$ZLIB" == yes || "$ZLIB" == no ]] || die "--zlib must be auto, yes or no"
TARGET_ID="${TARGET//[^A-Za-z0-9_.-]/-}"

HOSTKEY_DIR="${HOSTKEY_DIR:-$SYSCONFDIR}"
if [[ "$AUTHORIZED_KEYS_SET" == no ]]; then
  AUTHORIZED_KEYS="$ROOT_HOME/.ssh/authorized_keys"
fi
SFTP_SERVER="${SFTP_SERVER:-$PREFIX/libexec/sftp-server}"

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

if [[ "$UPX_COMPRESS" == yes ]]; then
  need_cmd "$UPX_BIN"
fi

SYSROOT="$("$CC" -print-sysroot)"
[[ -d "$SYSROOT" ]] || die "bad sysroot: $SYSROOT"

if [[ "$LINKAGE" == static ]]; then
  find "$SYSROOT/lib" "$SYSROOT/usr/lib" -name libc.a -type f -print -quit 2>/dev/null |
    grep -q . || die "missing static runtime library: libc.a"
fi

if [[ -n "$PACKAGE" ]]; then
  [[ -f "$PACKAGE" ]] || die "package not found: $PACKAGE"
else
  SOURCE_DIR="$(cd "$SOURCE_DIR" && pwd)"
  [[ -x "$SOURCE_DIR/configure" ]] || die "Dropbear configure not found: $SOURCE_DIR/configure"
fi

if [[ -n "$PACKAGE" ]]; then
  source_name="$(basename "$PACKAGE")"
  version="${source_name#dropbear-}"
  version="${version%.tar.bz2}"
  version="${version%.tar.gz}"
  version="${version%.tgz}"
  version="${version%.tar.xz}"
  work_base="$(cd "$(dirname "$PACKAGE")" && pwd)"
  dist_base="$work_base"
else
  version="$(basename "$SOURCE_DIR" | sed 's/^dropbear-//')"
  work_base="$(cd "$(dirname "$SOURCE_DIR")" && pwd)"
  dist_base="$SOURCE_DIR"
fi

WORK_ROOT="$work_base/.${TARGET_ID}-dropbear-$LINKAGE"
SBUILD="$WORK_ROOT/source"
STAGE="$WORK_ROOT/stage"
DIST="$dist_base/dist-${TARGET_ID}-dropbear"

[[ "$CLEAN" == yes ]] && rm -rf "$WORK_ROOT"
rm -rf "$SBUILD" "$STAGE"
mkdir -p "$SBUILD" "$STAGE" "$DIST"

if [[ -n "$PACKAGE" ]]; then
  log "Extract Dropbear package"
  tar -xf "$PACKAGE" -C "$WORK_ROOT"
  extracted="$(find "$WORK_ROOT" -maxdepth 1 -mindepth 1 -type d -name 'dropbear-*' | sort -V | tail -n 1)"
  [[ -n "$extracted" ]] || die "cannot find extracted dropbear source"
  rm -rf "$SBUILD"
  mv "$extracted" "$SBUILD"
else
  cp -a "$SOURCE_DIR/." "$SBUILD/"
fi

chmod +x "$SBUILD/configure" "$SBUILD/src/config.guess" "$SBUILD/src/config.sub" 2>/dev/null || true

BUILD_TRIPLET="$(sh "$SBUILD/src/config.guess" 2>/dev/null || gcc -dumpmachine)"

CFLAGS_COMMON="-Os -ffunction-sections -fdata-sections"
if [[ "$LINKAGE" == static ]]; then
  LDFLAGS_LINK="-static -static-libgcc -Wl,--gc-sections"
else
  LDFLAGS_LINK="-Wl,--gc-sections"
fi

zlib_opts=()
if [[ "$ZLIB" == no ]]; then
  zlib_opts=(--disable-zlib)
else
  if [[ -f "$SYSROOT/usr/include/zlib.h" ]] &&
     find "$SYSROOT/usr/lib" "$SYSROOT/lib" -maxdepth 1 -name 'libz.*' -print -quit 2>/dev/null | grep -q .; then
    zlib_opts=(--with-zlib="$SYSROOT/usr")
  elif [[ "$ZLIB" == yes ]]; then
    die "--zlib yes requested but target zlib was not found in sysroot"
  else
    zlib_opts=(--disable-zlib)
  fi
fi

cat >"$SBUILD/localoptions.h" <<EOF
#ifndef LOCALOPTIONS_H
#define LOCALOPTIONS_H

#undef SFTPSERVER_PATH
#define SFTPSERVER_PATH "$SFTP_SERVER"

#undef DROPBEAR_PATH_SSH_PROGRAM
#define DROPBEAR_PATH_SSH_PROGRAM "$PREFIX/bin/dbclient"

#endif
EOF

configure_opts=(
  "--build=$BUILD_TRIPLET"
  "--host=$TARGET"
  "--prefix=$PREFIX"
  "--sysconfdir=$SYSCONFDIR"
  --enable-bundled-libtom
  --disable-pam
  --disable-lastlog
  --disable-utmp
  --disable-utmpx
  --disable-wtmp
  --disable-wtmpx
  --disable-loginfunc
  --disable-pututline
  --disable-pututxline
  "${zlib_opts[@]}"
)

if [[ "$LINKAGE" == static ]]; then
  append_supported_option "$SBUILD/configure" --enable-static configure_opts
  append_supported_option "$SBUILD/configure" --disable-shared configure_opts
else
  append_supported_option "$SBUILD/configure" --disable-static configure_opts
  append_supported_option "$SBUILD/configure" --enable-shared configure_opts
fi

validate_static(){
  local f="$1"
  file "$f"
  if "$READELF" -l "$f" | grep -qi interpreter; then
    die "$f has PT_INTERP"
  fi
  if "$READELF" -d "$f" 2>/dev/null | grep -q NEEDED; then
    "$READELF" -d "$f" 2>/dev/null | grep NEEDED || true
    die "$f has DT_NEEDED"
  fi
  echo "Static validation OK: $(basename "$f")"
}

validate_dynamic(){
  local f="$1"
  file "$f"
  if ! "$READELF" -d "$f" 2>/dev/null | grep -q NEEDED; then
    die "$f has no DT_NEEDED in dynamic mode"
  fi
  "$READELF" -d "$f" 2>/dev/null | grep NEEDED || true
  echo "Dynamic validation OK: $(basename "$f")"
}

validate_linkage(){
  if [[ "$LINKAGE" == static ]]; then
    validate_static "$1"
  else
    validate_dynamic "$1"
  fi
}

log "Build configuration"
cat <<EOF
Source:          $SBUILD
SDK:             $SDK
Toolchain:       $("$CC" -dumpmachine)
Sysroot:         $SYSROOT
Linkage:         $LINKAGE
Prefix:          $PREFIX
Sysconfdir:      $SYSCONFDIR
Hostkey dir:     $HOSTKEY_DIR
Authorized keys: $AUTHORIZED_KEYS
SFTP server:     $SFTP_SERVER
Password auth:   $PASSWORD_AUTH
Root pass auth:  $ROOT_PASSWORD_AUTH
EOF

log "Configure Dropbear"
(
  cd "$SBUILD"
  env \
    PATH="$TOOLBIN:$PATH" \
    CC="$CC" \
    AR="$AR" \
    RANLIB="$RANLIB" \
    STRIP="$STRIP" \
    CFLAGS="$CFLAGS_COMMON" \
    LDFLAGS="$LDFLAGS_LINK" \
    ./configure "${configure_opts[@]}"

  make -j"$JOBS" \
    PROGRAMS="dropbear dbclient dropbearkey dropbearconvert scp" \
    MULTI=1 \
    SCPPROGRESS=1
)

BIN="$STAGE$PREFIX/bin"
SBIN="$STAGE$PREFIX/sbin"
ETC="$STAGE$SYSCONFDIR"
mkdir -p "$BIN" "$SBIN" "$ETC"

install -m 0755 "$SBUILD/dropbearmulti" "$BIN/dropbearmulti"
for program in dbclient dropbearkey dropbearconvert scp; do
  ln -sf dropbearmulti "$BIN/$program"
done
ln -sf ../bin/dropbearmulti "$SBIN/dropbear"

cat >"$ETC/dropbear.conf" <<EOF
# Defaults used by $PREFIX/start-dropbear.sh
DROPBEAR_HOSTKEY_DIR="$HOSTKEY_DIR"
DROPBEAR_AUTHORIZED_KEYS="$AUTHORIZED_KEYS"
DROPBEAR_ROOT_HOME="$ROOT_HOME"
DROPBEAR_SFTP_SERVER="$SFTP_SERVER"
DROPBEAR_PIDFILE="$PIDFILE"
DROPBEAR_LISTEN="$LISTEN"
DROPBEAR_PORT="$PORT"
DROPBEAR_PASSWORD_AUTH="$PASSWORD_AUTH"
DROPBEAR_ROOT_PASSWORD_AUTH="$ROOT_PASSWORD_AUTH"
EOF

cat >"$STAGE$PREFIX/generate-host-keys.sh" <<EOF
#!/bin/sh
set -eu
hostkey_dir="\${1:-$HOSTKEY_DIR}"
mkdir -p "\$hostkey_dir"
chmod 700 "\$hostkey_dir"
[ -s "\$hostkey_dir/dropbear_ed25519_host_key" ] ||
  "$PREFIX/bin/dropbearkey" -t ed25519 -f "\$hostkey_dir/dropbear_ed25519_host_key"
[ -s "\$hostkey_dir/dropbear_rsa_host_key" ] ||
  "$PREFIX/bin/dropbearkey" -t rsa -s 3072 -f "\$hostkey_dir/dropbear_rsa_host_key"
EOF
chmod 755 "$STAGE$PREFIX/generate-host-keys.sh"

cat >"$STAGE$PREFIX/start-dropbear.sh" <<EOF
#!/bin/sh
set -eu

die(){ echo "ERROR: \$*" >&2; exit 1; }

usage(){
cat <<'USAGE'
Usage:
  start-dropbear.sh [options] [-- DROPBEAR_ARGS...]

Options:
  --listen IP
  --port PORT
  --hostkey-dir PATH
  --authorized-keys PATH
  --root-home PATH
  --sftp-server PATH
  --pidfile PATH
  --password-auth yes|no
  --root-password-auth yes|no

Examples:
  start-dropbear.sh
  start-dropbear.sh --listen 192.168.1.1 --port 2224
  start-dropbear.sh --sftp-server /usr/libexec/sftp-server
USAGE
}

config_file="$SYSCONFDIR/dropbear.conf"
if [ -r "\$config_file" ]; then
  # shellcheck disable=SC1090
  . "\$config_file"
fi

hostkey_dir="\${DROPBEAR_HOSTKEY_DIR:-$HOSTKEY_DIR}"
authorized_keys="\${DROPBEAR_AUTHORIZED_KEYS:-$AUTHORIZED_KEYS}"
root_home="\${DROPBEAR_ROOT_HOME:-$ROOT_HOME}"
sftp_server="\${DROPBEAR_SFTP_SERVER:-$SFTP_SERVER}"
compiled_sftp_server="$SFTP_SERVER"
pidfile="\${DROPBEAR_PIDFILE:-$PIDFILE}"
listen="\${DROPBEAR_LISTEN:-$LISTEN}"
port="\${DROPBEAR_PORT:-$PORT}"
password_auth="\${DROPBEAR_PASSWORD_AUTH:-$PASSWORD_AUTH}"
root_password_auth="\${DROPBEAR_ROOT_PASSWORD_AUTH:-$ROOT_PASSWORD_AUTH}"

while [ "\$#" -gt 0 ]; do
  case "\$1" in
    --listen) [ "\$#" -ge 2 ] || die "--listen requires an argument"; listen="\$2"; shift 2 ;;
    --port)
      [ "\$#" -ge 2 ] || die "--port requires an argument"
      port="\$2"
      case "\$port" in ''|*[!0-9]*) die "--port must be numeric" ;; esac
      shift 2
      ;;
    --hostkey-dir) [ "\$#" -ge 2 ] || die "--hostkey-dir requires an argument"; hostkey_dir="\$2"; shift 2 ;;
    --authorized-keys) [ "\$#" -ge 2 ] || die "--authorized-keys requires an argument"; authorized_keys="\$2"; shift 2 ;;
    --root-home) [ "\$#" -ge 2 ] || die "--root-home requires an argument"; root_home="\$2"; shift 2 ;;
    --sftp-server) [ "\$#" -ge 2 ] || die "--sftp-server requires an argument"; sftp_server="\$2"; shift 2 ;;
    --pidfile) [ "\$#" -ge 2 ] || die "--pidfile requires an argument"; pidfile="\$2"; shift 2 ;;
    --password-auth) [ "\$#" -ge 2 ] || die "--password-auth requires yes or no"; password_auth="\$2"; shift 2 ;;
    --root-password-auth) [ "\$#" -ge 2 ] || die "--root-password-auth requires yes or no"; root_password_auth="\$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    *) die "unknown option: \$1" ;;
  esac
done

case "\$password_auth" in yes|no) ;; *) die "--password-auth must be yes or no" ;; esac
case "\$root_password_auth" in yes|no) ;; *) die "--root-password-auth must be yes or no" ;; esac

export PATH="$PREFIX/bin:$PREFIX/sbin:\${PATH:-/sbin:/bin:/usr/sbin:/usr/bin}"

"$PREFIX/generate-host-keys.sh" "\$hostkey_dir"

mkdir -p "\$root_home/.ssh"
chmod 700 "\$root_home/.ssh"

authorized_keys_dir="\$root_home/.ssh"
if [ -n "\$authorized_keys" ]; then
  case "\$authorized_keys" in
    /*) authorized_keys_dir="\${authorized_keys%/*}" ;;
    *) die "--authorized-keys must be an absolute file path" ;;
  esac
  [ -n "\$authorized_keys_dir" ] || authorized_keys_dir="/"
  authorized_keys_name="\${authorized_keys##*/}"
  mkdir -p "\$authorized_keys_dir"
  if [ "\$authorized_keys_name" != "authorized_keys" ]; then
    if [ -e "\$authorized_keys" ]; then
      ln -sf "\$authorized_keys" "\$authorized_keys_dir/authorized_keys"
    fi
  fi
fi
[ -e "\$authorized_keys_dir/authorized_keys" ] && chmod 600 "\$authorized_keys_dir/authorized_keys"

if [ -n "\$sftp_server" ] && [ "\$sftp_server" != "\$compiled_sftp_server" ]; then
  mkdir -p "\${compiled_sftp_server%/*}"
  ln -sf "\$sftp_server" "\$compiled_sftp_server"
fi

set -- -F -E -P "\$pidfile" \\
  -D "\$authorized_keys_dir" \\
  -r "\$hostkey_dir/dropbear_ed25519_host_key" \\
  -r "\$hostkey_dir/dropbear_rsa_host_key" "\$@"

if [ -n "\$listen" ]; then
  set -- "\$@" -p "\$listen:\$port"
else
  set -- "\$@" -p "\$port"
fi

[ "\$password_auth" = no ] && set -- "\$@" -s
[ "\$root_password_auth" = no ] && set -- "\$@" -g

exec "$PREFIX/sbin/dropbear" "\$@"
EOF
chmod 755 "$STAGE$PREFIX/start-dropbear.sh"

log "Validate packaged binary"
validate_linkage "$BIN/dropbearmulti"

if [[ "$STRIP_BIN" == yes ]]; then
  "$STRIP" --strip-unneeded "$BIN/dropbearmulti"
fi

if [[ "$UPX_COMPRESS" == yes ]]; then
  "$UPX_BIN" --best --lzma "$BIN/dropbearmulti"
  validate_linkage "$BIN/dropbearmulti"
fi

archive="$DIST/dropbear-${version}-${TARGET_ID}-${LINKAGE}.tar.gz"
tar --numeric-owner -C "$STAGE" -czf "$archive" ".${PREFIX}" ".${SYSCONFDIR}"
sha256sum "$archive" >"$archive.sha256"

log "Done"
echo "Archive:  $archive"
echo "Checksum: $archive.sha256"
echo "Deploy:"
echo "  tar -xzf /tmp/$(basename "$archive") -C /"
echo "  $PREFIX/generate-host-keys.sh"
echo "  $PREFIX/start-dropbear.sh --listen 192.168.1.1 --port 2224"
echo "SFTP server path compiled into Dropbear:"
echo "  $SFTP_SERVER"
