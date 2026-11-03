#!/usr/bin/env bash
set -Eeuo pipefail

trap 'rc=$?; printf "\nERROR: command failed at line %s (exit=%s): %s\n" "$LINENO" "$rc" "$BASH_COMMAND" >&2; exit "$rc"' ERR

SDK="/root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot"
TARGET="arm-buildroot-linux-gnueabi"
OPENSSH_SRC="$(pwd)"
OPENSSL_SRC=""
ZLIB_SRC=""
OPENSSL_TARGET="linux-armv4"
PREFIX="/opt/openssh"
PREFIX="/usr"
JOBS="$(nproc 2>/dev/null || echo 1)"
LISTEN=""
PORT=""
SANDBOX="no"
PRIVSEP_USER="nobody"
PRIVSEP_PATH="/var/empty"
CLEAN="no"
STRIP_BIN="yes"
UPX_COMPRESS="yes"
UPX_BIN="upx"
LINKAGE="static"

die(){ echo "ERROR: $*" >&2; exit 1; }
log(){ echo; echo "[$(date '+%F %T')] $*"; }

usage(){
cat <<'EOF'
Usage:
  ./build-arm-openssh-full.sh \
    --source /path/openssh-10.4p1 \
    --openssl-src /path/openssl-3.5.7 \
    --zlib-src /path/zlib-1.3.2 \
    [--openssl-target linux-armv4]
    [--sdk PATH] [--target TRIPLET] [--prefix /opt/openssh]
    [--listen IP] [--port PORT]
    [--sandbox yes|no] [--privsep-user USER] [--privsep-path PATH]
    [--jobs N] [--linkage static|dynamic] [--clean]
    [--no-strip] [--upx PATH] [--no-upx]

Builds ARM OpenSSH binaries:
  ssh, sshd, sshd-session, sshd-auth, scp, sftp, sftp-server,
  ssh-keygen, ssh-keyscan, ssh-agent, ssh-add, ssh-keysign,
  ssh-pkcs11-helper and ssh-sk-helper when available.

Optional integrations disabled:
  PAM, Kerberos, SELinux, libedit, LDNS, audit, FIDO/security-key,
  PKCS#11 provider loading, lastlog/utmp/wtmp.
EOF
}

while (($#)); do
  case "$1" in
    --source) OPENSSH_SRC="$2"; shift 2;;
    --openssl-src) OPENSSL_SRC="$2"; shift 2;;
    --zlib-src) ZLIB_SRC="$2"; shift 2;;
    --openssl-target) OPENSSL_TARGET="$2"; shift 2;;
    --sdk) SDK="$2"; shift 2;;
    --target) TARGET="$2"; shift 2;;
    --prefix) PREFIX="$2"; shift 2;;
    --listen) LISTEN="$2"; shift 2;;
    --port) PORT="$2"; shift 2;;
    --sandbox) SANDBOX="$2"; shift 2;;
    --privsep-user) PRIVSEP_USER="$2"; shift 2;;
    --privsep-path) PRIVSEP_PATH="$2"; shift 2;;
    --jobs) JOBS="$2"; shift 2;;
    --linkage) LINKAGE="$2"; shift 2;;
    --clean) CLEAN="yes"; shift;;
    --no-strip) STRIP_BIN="no"; shift;;
    --upx) UPX_BIN="$2"; shift 2;;
    --no-upx) UPX_COMPRESS="no"; shift;;
    -h|--help) usage; exit 0;;
    *) die "unknown option: $1";;
  esac
done

[[ "$PREFIX" == /* ]] || die "--prefix must be absolute"
[[ "$PRIVSEP_PATH" == /* ]] || die "--privsep-path must be absolute"
[[ -z "$PORT" || "$PORT" =~ ^[0-9]+$ ]] || die "--port must be numeric"
[[ "$SANDBOX" == yes || "$SANDBOX" == no ]] || die "--sandbox must be yes or no"
[[ "$LINKAGE" == static || "$LINKAGE" == dynamic ]] || die "--linkage must be static or dynamic"
[[ -n "$OPENSSL_SRC" ]] || die "--openssl-src is required"
[[ -n "$ZLIB_SRC" ]] || die "--zlib-src is required"
TARGET_ID="${TARGET//[^A-Za-z0-9_.-]/-}"

OPENSSH_SRC="$(cd "$OPENSSH_SRC" && pwd)"
OPENSSL_SRC="$(cd "$OPENSSL_SRC" && pwd)"
ZLIB_SRC="$(cd "$ZLIB_SRC" && pwd)"

[[ -x "$OPENSSH_SRC/configure" ]] || die "OpenSSH configure not found"
[[ -f "$OPENSSL_SRC/Configure" ]] || die "OpenSSL Configure not found"
[[ -x "$ZLIB_SRC/configure" ]] || die "zlib configure not found"

if [[ -x "$SDK/bin/${TARGET}-gcc" ]]; then
  TOOLBIN="$SDK/bin"
elif [[ -x "$SDK/host/bin/${TARGET}-gcc" ]]; then
  TOOLBIN="$SDK/host/bin"
else
  die "cannot find ${TARGET}-gcc below $SDK"
fi

export PATH="$TOOLBIN:$PATH"
CC="${TARGET}-gcc"
AR="${TARGET}-ar"
RANLIB="${TARGET}-ranlib"
STRIP="${TARGET}-strip"
READELF="${TARGET}-readelf"

for x in "$CC" "$AR" "$RANLIB" "$STRIP" "$READELF" make perl file tar sha256sum; do
  command -v "$x" >/dev/null || die "missing command: $x"
done

if [[ "$UPX_COMPRESS" == yes ]]; then
  command -v "$UPX_BIN" >/dev/null || die "missing command: $UPX_BIN"
fi

SYSROOT="$("$CC" -print-sysroot)"
[[ -d "$SYSROOT" ]] || die "bad sysroot: $SYSROOT"

if [[ "$LINKAGE" == static ]]; then
  for lib in libc.a libpthread.a libdl.a libcrypt.a; do
    find "$SYSROOT/lib" "$SYSROOT/usr/lib" -name "$lib" -type f -print -quit 2>/dev/null |
      grep -q . || die "missing static runtime library: $lib"
  done
fi

BUILD_TRIPLET="$("$OPENSSH_SRC/config.guess" 2>/dev/null ||
  "$OPENSSH_SRC/build-aux/config.guess" 2>/dev/null ||
  gcc -dumpmachine)"

WORK="$OPENSSH_SRC/.${TARGET_ID}-openssh-$LINKAGE"
DEPS="$WORK/deps"
ZBUILD="$WORK/zlib"
OBUILD="$WORK/openssl"
SBUILD="$WORK/openssh"
STAGE="$WORK/stage"
DIST="$OPENSSH_SRC/dist-${TARGET_ID}-openssh"

[[ "$CLEAN" == yes ]] && rm -rf "$WORK"
rm -rf "$DEPS" "$ZBUILD" "$OBUILD" "$SBUILD" "$STAGE"
mkdir -p "$DEPS" "$ZBUILD" "$OBUILD" "$SBUILD" "$STAGE" "$DIST"

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

validate_static(){
  local f="$1"

  file "$f"

  if "$READELF" -l "$f" | grep -qi interpreter; then
    "$READELF" -l "$f" | grep -i interpreter || true
    die "$f has PT_INTERP"
  fi

  if "$READELF" -d "$f" 2>/dev/null | grep -q NEEDED; then
    "$READELF" -d "$f" 2>/dev/null | grep NEEDED || true
    die "$f has DT_NEEDED"
  fi

  echo "Static validation OK: $(basename "$f")"
  return 0
}

validate_dynamic(){
  local f="$1"

  file "$f"

  if ! "$READELF" -d "$f" 2>/dev/null | grep -q NEEDED; then
    die "$f has no DT_NEEDED in dynamic mode"
  fi

  "$READELF" -d "$f" 2>/dev/null | grep NEEDED || true
  echo "Dynamic validation OK: $(basename "$f")"
  return 0
}

validate_linkage(){
  if [[ "$LINKAGE" == static ]]; then
    validate_static "$1"
  else
    validate_dynamic "$1"
  fi
}

log "Toolchain $LINKAGE link test"
cat >"$WORK/test.c" <<'EOF'
int main(void){return 0;}
EOF
"$CC" $CFLAGS_COMMON $LDFLAGS_LINK "$WORK/test.c" -o "$WORK/test"
validate_linkage "$WORK/test"

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
if [[ "$LINKAGE" == static ]]; then
  [[ -f "$DEPS/lib/libz.a" ]] || die "libz.a not built"
else
  find "$DEPS/lib" -maxdepth 1 -name 'libz.so*' -print -quit | grep -q . ||
    die "libz.so not built"
fi

log "Build $LINKAGE OpenSSL"
(
  cd "$OBUILD"

  # OpenSSL prefixes its compiler/tool names when
  # --cross-compile-prefix is supplied. Do not also pass a prefixed CC or
  # CROSS_COMPILE, otherwise it produces names such as:
  # arm-buildroot-linux-gnueabi-arm-buildroot-linux-gnueabi-gcc
  unset CROSS_COMPILE CC CXX AR AS LD NM RANLIB STRIP

  perl "$OPENSSL_SRC/Configure" "$OPENSSL_TARGET" \
      "--cross-compile-prefix=${TARGET}-" \
      "--prefix=$DEPS" \
      "--openssldir=$PREFIX/etc/ssl" \
      "${OPENSSL_LINK_OPTS[@]}" \
      no-tests no-docs no-async no-engine no-comp \
      no-ssl3 no-weak-ssl-ciphers \
      $CFLAGS_COMMON

  # OpenSSH only needs libcrypto and its headers. Avoid building OpenSSL apps.
  make -j"$JOBS" build_libs
  make install_dev
)

if [[ "$LINKAGE" == static ]]; then
  [[ -f "$DEPS/lib/libcrypto.a" ]] || die "libcrypto.a not built"
else
  find "$DEPS/lib" -maxdepth 1 -name 'libcrypto.so*' -print -quit | grep -q . ||
    die "libcrypto.so not built"
fi

log "$LINKAGE libcrypto link test"
cat >"$WORK/crypto-test.c" <<'EOF'
#include <openssl/evp.h>
int main(void){return EVP_sha256() == 0;}
EOF

EXTRA_LIBS=""
if ! "$CC" $CFLAGS_COMMON -I"$DEPS/include" "$WORK/crypto-test.c" \
    $LDFLAGS_LINK -L"$DEPS/lib" -lcrypto -ldl -lpthread \
    -o "$WORK/crypto-test"; then
  EXTRA_LIBS="-latomic"
  "$CC" $CFLAGS_COMMON -I"$DEPS/include" "$WORK/crypto-test.c" \
    $LDFLAGS_LINK -L"$DEPS/lib" -lcrypto -ldl -lpthread -latomic \
    -o "$WORK/crypto-test" ||
    die "$LINKAGE libcrypto link failed"
fi
validate_linkage "$WORK/crypto-test"

help="$("$OPENSSH_SRC/configure" --help 2>/dev/null || true)"
opts=(
  "--build=$BUILD_TRIPLET"
  "--host=$TARGET"
  "--prefix=$PREFIX"
  "--bindir=$PREFIX/bin"
  "--sbindir=$PREFIX/sbin"
  "--libexecdir=$PREFIX/libexec"
  "--sysconfdir=$PREFIX/etc/ssh"
  "--with-ssl-dir=$DEPS"
  "--with-zlib=$DEPS"
  "--with-privsep-user=$PRIVSEP_USER"
  "--with-privsep-path=$PRIVSEP_PATH"
  "--with-default-path=$PREFIX/bin:/usr/bin:/bin:/usr/sbin:/sbin"
)

addopt(){
  local option="$1"

  if grep -Fq -- "$option" <<<"$help"; then
    opts+=("$option")
  fi

  # An unsupported optional configure flag is not an error.
  return 0
}

for o in \
  --without-pie --without-pam --without-libedit --without-kerberos5 \
  --without-selinux --without-ldns --without-wtmpdb --disable-strip \
  --disable-pkcs11 --disable-lastlog \
  --disable-utmp --disable-utmpx --disable-wtmp --disable-wtmpx \
  --without-stackprotect --without-hardening; do
  addopt "$o"
done

if grep -Fq -- "--without-audit" <<<"$help"; then
  opts+=(--without-audit)
elif grep -Fq -- "--with-audit" <<<"$help"; then
  opts+=(--with-audit=no)
fi

if [[ "$SANDBOX" == no ]]; then
  if grep -Fq -- "--without-sandbox" <<<"$help"; then
    opts+=(--without-sandbox)
  elif grep -Fq -- "--with-sandbox" <<<"$help"; then
    opts+=(--with-sandbox=no)
  fi
fi

log "Configure and build complete OpenSSH suite ($LINKAGE)"
(
  cd "$SBUILD"
  CC="$CC" LD="$CC" AR="$AR" RANLIB="$RANLIB" STRIP="$STRIP" \
  CFLAGS="$CFLAGS_COMMON -pthread" \
  CPPFLAGS="-I$DEPS/include" \
  LDFLAGS="$LDFLAGS_LINK -pthread -L$DEPS/lib" \
  LIBS="-ldl -lpthread $EXTRA_LIBS" \
  PKG_CONFIG_PATH="$DEPS/lib/pkgconfig" \
  PKG_CONFIG_LIBDIR="$DEPS/lib/pkgconfig" \
    "$OPENSSH_SRC/configure" "${opts[@]}"
  make -j"$JOBS"
)

BIN="$STAGE$PREFIX/bin"
SBIN="$STAGE$PREFIX/sbin"
LIBEXEC="$STAGE$PREFIX/libexec"
ETC="$STAGE$PREFIX/etc/ssh"
mkdir -p "$BIN" "$SBIN" "$LIBEXEC" "$ETC"

if [[ "$LINKAGE" == dynamic ]]; then
  LIBDIR="$STAGE$PREFIX/lib"
  mkdir -p "$LIBDIR"
  find "$DEPS/lib" -maxdepth 1 \( -name 'libcrypto.so*' -o -name 'libz.so*' \) \
    -exec cp -a {} "$LIBDIR/" \;

  if [[ "$EXTRA_LIBS" == *-latomic* ]]; then
    find "$SYSROOT/lib" "$SYSROOT/usr/lib" -name 'libatomic.so*' \
      -exec cp -a {} "$LIBDIR/" \; 2>/dev/null || true
  fi
fi

for f in ssh scp sftp ssh-add ssh-agent ssh-keygen ssh-keyscan; do
  [[ -f "$SBUILD/$f" ]] || die "missing $f"
  install -m 0755 "$SBUILD/$f" "$BIN/$f"
done

install -m 0755 "$SBUILD/sshd" "$SBIN/sshd"

for f in sshd-session sshd-auth sftp-server; do
  [[ -f "$SBUILD/$f" ]] || die "missing $f"
  install -m 0755 "$SBUILD/$f" "$LIBEXEC/$f"
done

for f in ssh-keysign ssh-pkcs11-helper ssh-sk-helper; do
  if [[ -f "$SBUILD/$f" ]]; then
    install -m 0755 "$SBUILD/$f" "$LIBEXEC/$f"
  else
    echo "Optional helper not produced: $f"
  fi
done

cat >"$ETC/ssh_config" <<EOF
Host *
    ServerAliveInterval 30
    ServerAliveCountMax 3
    StrictHostKeyChecking ask
EOF

{
  [[ -n "$PORT" ]] && printf 'Port %s\n' "$PORT"
  [[ -n "$LISTEN" ]] && printf 'ListenAddress %s\n' "$LISTEN"
  cat <<EOF
HostKey $PREFIX/etc/ssh/ssh_host_ed25519_key
HostKey $PREFIX/etc/ssh/ssh_host_rsa_key
PidFile /tmp/openssh-sshd.pid
AuthorizedKeysFile .ssh/authorized_keys
PermitRootLogin prohibit-password
PubkeyAuthentication yes
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitEmptyPasswords no
UsePAM no
AllowAgentForwarding no
AllowTcpForwarding no
X11Forwarding no
PermitTunnel no
UseDNS no
PrintMotd no
Subsystem sftp $PREFIX/libexec/sftp-server
EOF
} >"$ETC/sshd_config"

cat >"$STAGE$PREFIX/generate-host-keys.sh" <<EOF
#!/bin/sh
set -eu
mkdir -p "$PREFIX/etc/ssh"
chmod 700 "$PREFIX/etc/ssh"
[ -s "$PREFIX/etc/ssh/ssh_host_ed25519_key" ] ||
  "$PREFIX/bin/ssh-keygen" -q -t ed25519 -N '' \
    -f "$PREFIX/etc/ssh/ssh_host_ed25519_key"
[ -s "$PREFIX/etc/ssh/ssh_host_rsa_key" ] ||
  "$PREFIX/bin/ssh-keygen" -q -t rsa -b 3072 -N '' \
    -f "$PREFIX/etc/ssh/ssh_host_rsa_key"
EOF
chmod 755 "$STAGE$PREFIX/generate-host-keys.sh"

cat >"$STAGE$PREFIX/start-sshd.sh" <<EOF
#!/bin/sh
set -eu

die(){ echo "ERROR: \$*" >&2; exit 1; }

usage(){
cat <<'USAGE'
Usage:
  start-sshd.sh [--listen IP] [--port PORT] [-- SSHD_ARGS...]

Examples:
  start-sshd.sh
  start-sshd.sh --listen 192.168.1.1 --port 2224
  start-sshd.sh -- -ddd
USAGE
}

listen=""
port=""

while [ "\$#" -gt 0 ]; do
  case "\$1" in
    --listen|-l)
      [ "\$#" -ge 2 ] || die "--listen requires an argument"
      listen="\$2"
      shift 2
      ;;
    --port|-p)
      [ "\$#" -ge 2 ] || die "--port requires an argument"
      port="\$2"
      case "\$port" in
        ''|*[!0-9]*) die "--port must be numeric" ;;
      esac
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    *)
      die "unknown option: \$1"
      ;;
  esac
done

mkdir -p "$PRIVSEP_PATH"
chown 0:0 "$PRIVSEP_PATH"
chmod 755 "$PRIVSEP_PATH"

set -- -D -e -f "$PREFIX/etc/ssh/sshd_config" "\$@"
[ -n "\$port" ] && set -- "\$@" -p "\$port"
[ -n "\$listen" ] && set -- "\$@" -o "ListenAddress=\$listen"

exec "$PREFIX/sbin/sshd" "\$@"
EOF
chmod 755 "$STAGE$PREFIX/start-sshd.sh"

log "Validate packaged binaries"
while IFS= read -r -d '' f; do
  validate_linkage "$f"

  if [[ "$STRIP_BIN" == yes ]]; then
    "$STRIP" --strip-unneeded "$f"
  fi

  if [[ "$UPX_COMPRESS" == yes ]]; then
    "$UPX_BIN" --best --lzma "$f"
    validate_linkage "$f"
  fi
done < <(find "$BIN" "$SBIN" "$LIBEXEC" -maxdepth 1 -type f -print0)

version="$(basename "$OPENSSH_SRC" | sed 's/^openssh-//')"
archive="$DIST/openssh-${version}-${TARGET_ID}-${LINKAGE}.tar.gz"
tar --numeric-owner -C "$STAGE" -czf "$archive" ".${PREFIX}"
sha256sum "$archive" >"$archive.sha256"

log "Done"
echo "Archive:  $archive"
echo "Checksum: $archive.sha256"
echo "Deploy:"
echo "  tar -xzf /tmp/$(basename "$archive") -C /"
echo "  $PREFIX/generate-host-keys.sh"
echo "  $PREFIX/start-sshd.sh"
echo "  $PREFIX/start-sshd.sh --listen 192.168.1.1 --port 2224"
echo "Dropbear SFTP path:"
echo "  $PREFIX/libexec/sftp-server"
