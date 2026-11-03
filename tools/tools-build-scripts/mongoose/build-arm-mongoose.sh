#!/usr/bin/env bash
set -Eeuo pipefail

trap 'rc=$?; printf "\nERROR: command failed at line %s (exit=%s): %s\n" "$LINENO" "$rc" "$BASH_COMMAND" >&2; exit "$rc"' ERR

SDK="/root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot"
TARGET="arm-buildroot-linux-gnueabi"
SOURCE_DIR="$(pwd)"
PACKAGE=""
PREFIX="/usr"
LINKAGE="static"
TLS="builtin"
OPENSSL_PREFIX=""
MG_ARCH="MG_ARCH_UNIX"
IPV6="no"
POSIX_FS="yes"
LISTEN="http://0.0.0.0:8000"
ROOT_DIR="/tmp/www"
CERT_FILE="/etc/mongoose/certificate.pem"
KEY_FILE="/etc/mongoose/key.pem"
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
  ./build-arm-mongoose.sh \
    --source /path/mongoose \
    [--sdk PATH] [--target TRIPLET] [--prefix /usr]
    [--linkage static|dynamic]
    [--tls none|builtin|openssl] [--openssl-prefix PATH]
    [--mg-arch MG_ARCH_UNIX] [--ipv6 yes|no] [--posix-fs yes|no]
    [--listen http://0.0.0.0:8000] [--root-dir /tmp/www]
    [--cert-file /etc/mongoose/certificate.pem] [--key-file /etc/mongoose/key.pem]
    [--jobs N] [--clean] [--no-strip] [--upx PATH] [--no-upx]

Builds libmongoose plus a small mongoose-httpd test server for a cross target.
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
    --sdk) SDK="$2"; shift 2;;
    --target) TARGET="$2"; shift 2;;
    --prefix) PREFIX="$2"; shift 2;;
    --link|--linkage) LINKAGE="$2"; shift 2;;
    --tls) TLS="$2"; shift 2;;
    --openssl-prefix) OPENSSL_PREFIX="$2"; shift 2;;
    --mg-arch) MG_ARCH="$2"; shift 2;;
    --ipv6) IPV6="$(normalize_yes_no "$2")"; shift 2;;
    --posix-fs) POSIX_FS="$(normalize_yes_no "$2")"; shift 2;;
    --listen) LISTEN="$2"; shift 2;;
    --root-dir) ROOT_DIR="$2"; shift 2;;
    --cert-file) CERT_FILE="$2"; shift 2;;
    --key-file) KEY_FILE="$2"; shift 2;;
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
[[ "$ROOT_DIR" == /* ]] || die "--root-dir must be absolute"
[[ "$CERT_FILE" == /* ]] || die "--cert-file must be absolute"
[[ "$KEY_FILE" == /* ]] || die "--key-file must be absolute"
[[ "$JOBS" =~ ^[1-9][0-9]*$ ]] || die "--jobs must be a positive integer"
[[ "$LINKAGE" == static || "$LINKAGE" == dynamic ]] || die "--linkage must be static or dynamic"
[[ "$TLS" == none || "$TLS" == builtin || "$TLS" == openssl ]] || die "--tls must be none, builtin or openssl"
[[ "$TLS" != openssl || -n "$OPENSSL_PREFIX" ]] || die "--openssl-prefix is required when --tls openssl"
[[ "$POSIX_FS" == yes ]] || die "--posix-fs no is not supported while building the bundled mongoose-httpd test server"

TARGET_ID="${TARGET//[^A-Za-z0-9_.-]/-}"

if [[ -n "$PACKAGE" ]]; then
  [[ -f "$PACKAGE" ]] || die "package not found: $PACKAGE"
  work_base="$(cd "$(dirname "$PACKAGE")" && pwd)"
  dist_base="$work_base"
  source_name="$(basename "$PACKAGE")"
  version="${source_name#mongoose-}"
  version="${version#v}"
  version="${version%.tar.gz}"
  version="${version%.tgz}"
  version="${version%.tar.xz}"
  version="${version%.zip}"
else
  SOURCE_DIR="$(cd "$SOURCE_DIR" && pwd)"
  work_base="$(cd "$(dirname "$SOURCE_DIR")" && pwd)"
  dist_base="$SOURCE_DIR"
  version="$(basename "$SOURCE_DIR" | sed -e 's/^mongoose-//' -e 's/^v//')"
fi

TOOLBIN="$(find_sdk_bin "$SDK")" || die "cannot find ${TARGET}-gcc below $SDK"
export PATH="$TOOLBIN:$PATH"

CC="${TARGET}-gcc"
AR="${TARGET}-ar"
RANLIB="${TARGET}-ranlib"
STRIP="${TARGET}-strip"
READELF="${TARGET}-readelf"

for x in "$CC" "$AR" "$RANLIB" "$STRIP" "$READELF" file tar sha256sum; do
  need_cmd "$x"
done
[[ "$UPX_COMPRESS" == yes ]] && need_cmd "$UPX_BIN"
if [[ "$PACKAGE" == *.zip ]]; then
  need_cmd unzip
fi

SYSROOT="$("$CC" -print-sysroot)"
[[ -d "$SYSROOT" ]] || die "bad sysroot: $SYSROOT"
if [[ "$LINKAGE" == static ]]; then
  find "$SYSROOT/lib" "$SYSROOT/usr/lib" -name libc.a -type f -print -quit 2>/dev/null |
    grep -q . || die "missing static runtime library: libc.a"
fi

WORK="$work_base/.${TARGET_ID}-mongoose-$LINKAGE"
SBUILD="$WORK/source"
BUILD="$WORK/build"
STAGE="$WORK/stage"
DIST="$dist_base/dist-${TARGET_ID}-mongoose"

[[ "$CLEAN" == yes ]] && rm -rf "$WORK"
rm -rf "$SBUILD" "$BUILD" "$STAGE"
mkdir -p "$SBUILD" "$BUILD" "$STAGE" "$DIST"

if [[ -n "$PACKAGE" ]]; then
  log "Extract mongoose package"
  case "$PACKAGE" in
    *.zip) unzip -q "$PACKAGE" -d "$WORK" ;;
    *) tar -xf "$PACKAGE" -C "$WORK" ;;
  esac
  extracted="$(find "$WORK" -maxdepth 1 -mindepth 1 -type d \( -name 'mongoose-*' -o -name 'v*' \) | sort -V | tail -n 1 || true)"
  [[ -n "$extracted" ]] || die "cannot find extracted mongoose source"
  rm -rf "$SBUILD"
  mv "$extracted" "$SBUILD"
else
  cp -a "$SOURCE_DIR/." "$SBUILD/"
fi

[[ -f "$SBUILD/mongoose.c" ]] || die "mongoose.c not found below $SBUILD"
[[ -f "$SBUILD/mongoose.h" ]] || die "mongoose.h not found below $SBUILD"
header_version="$(sed -n 's/^#define MG_VERSION "\([^"]*\)".*/\1/p' "$SBUILD/mongoose.h" | head -n 1)"
if [[ -n "$header_version" ]]; then
  case "$version" in
    mongoose|master|main|source|src) version="$header_version" ;;
  esac
fi

cat >"$BUILD/mongoose-httpd.c" <<'EOF'
#include "mongoose.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static const char *s_listen = "http://0.0.0.0:8000";
static const char *s_root = "/tmp/www";
static const char *s_cert = NULL;
static const char *s_key = NULL;
static int s_poll_ms = 1000;

#if MG_TLS != MG_TLS_NONE
static struct mg_str s_cert_data = {0, 0};
static struct mg_str s_key_data = {0, 0};
#endif

static void usage(const char *prog) {
  fprintf(stderr,
          "Usage: %s [--listen URL] [--root DIR] [--cert FILE --key FILE] [--poll-ms N]\n"
          "Examples:\n"
          "  %s --listen http://0.0.0.0:8000 --root /tmp/www\n"
          "  %s --listen https://0.0.0.0:8443 --cert /etc/mongoose/certificate.pem --key /etc/mongoose/key.pem\n",
          prog, prog, prog);
}

static int starts_with(const char *s, const char *prefix) {
  return strncmp(s, prefix, strlen(prefix)) == 0;
}

static void fn(struct mg_connection *c, int ev, void *ev_data) {
  if (ev == MG_EV_ACCEPT) {
#if MG_TLS != MG_TLS_NONE
    if (c->is_tls) {
      struct mg_tls_opts opts;
      memset(&opts, 0, sizeof(opts));
      opts.cert = s_cert_data;
      opts.key = s_key_data;
      mg_tls_init(c, &opts);
    }
#endif
  } else if (ev == MG_EV_HTTP_MSG) {
    struct mg_http_message *hm = (struct mg_http_message *) ev_data;
    struct mg_http_serve_opts opts;
    memset(&opts, 0, sizeof(opts));
    opts.root_dir = s_root;
    mg_http_serve_dir(c, hm, &opts);
  }
}

int main(int argc, char **argv) {
  struct mg_mgr mgr;
  struct mg_connection *listener;
  int i;

  for (i = 1; i < argc; i++) {
    if (strcmp(argv[i], "--listen") == 0 && i + 1 < argc) {
      s_listen = argv[++i];
    } else if (strcmp(argv[i], "--root") == 0 && i + 1 < argc) {
      s_root = argv[++i];
    } else if (strcmp(argv[i], "--cert") == 0 && i + 1 < argc) {
      s_cert = argv[++i];
    } else if (strcmp(argv[i], "--key") == 0 && i + 1 < argc) {
      s_key = argv[++i];
    } else if (strcmp(argv[i], "--poll-ms") == 0 && i + 1 < argc) {
      s_poll_ms = atoi(argv[++i]);
      if (s_poll_ms <= 0) s_poll_ms = 1000;
    } else if (strcmp(argv[i], "-h") == 0 || strcmp(argv[i], "--help") == 0) {
      usage(argv[0]);
      return 0;
    } else {
      usage(argv[0]);
      return 2;
    }
  }

  if (starts_with(s_listen, "https://")) {
#if MG_TLS == MG_TLS_NONE
    fprintf(stderr, "ERROR: this binary was built without TLS support\n");
    return 2;
#else
    if (s_cert == NULL || s_key == NULL) {
      fprintf(stderr, "ERROR: https listener requires --cert and --key\n");
      return 2;
    }
    s_cert_data = mg_file_read(&mg_fs_posix, s_cert);
    s_key_data = mg_file_read(&mg_fs_posix, s_key);
    if (s_cert_data.buf == NULL || s_key_data.buf == NULL) {
      fprintf(stderr, "ERROR: cannot read certificate or key\n");
      return 2;
    }
#endif
  }

  mg_mgr_init(&mgr);
  listener = mg_http_listen(&mgr, s_listen, fn, NULL);
  if (listener == NULL) {
    fprintf(stderr, "ERROR: cannot listen on %s\n", s_listen);
    return 1;
  }
  printf("mongoose-httpd listening on %s, root=%s\n", s_listen, s_root);
  for (;;) mg_mgr_poll(&mgr, s_poll_ms);

#if MG_TLS != MG_TLS_NONE
  mg_free((void *) s_cert_data.buf);
  mg_free((void *) s_key_data.buf);
#endif
  mg_mgr_free(&mgr);
  return 0;
}
EOF

CFLAGS_COMMON=(-Os -std=gnu99 -ffunction-sections -fdata-sections -Wall -Wextra -I"$SBUILD")
CPPFLAGS_COMMON=(-D_GNU_SOURCE -D_DEFAULT_SOURCE -D_BSD_SOURCE -D_POSIX_C_SOURCE=200809L)
LDFLAGS_COMMON=(-Wl,--gc-sections)
LIBS=()

case "$TLS" in
  none) CPPFLAGS_COMMON+=("-DMG_TLS=MG_TLS_NONE") ;;
  builtin) CPPFLAGS_COMMON+=("-DMG_TLS=MG_TLS_BUILTIN") ;;
  openssl)
    OPENSSL_PREFIX="$(cd "$OPENSSL_PREFIX" && pwd)"
    [[ -d "$OPENSSL_PREFIX/include" ]] || die "OpenSSL include directory not found: $OPENSSL_PREFIX/include"
    [[ -d "$OPENSSL_PREFIX/lib" ]] || die "OpenSSL lib directory not found: $OPENSSL_PREFIX/lib"
    CPPFLAGS_COMMON+=("-DMG_TLS=MG_TLS_OPENSSL" "-I$OPENSSL_PREFIX/include")
    LDFLAGS_COMMON+=("-L$OPENSSL_PREFIX/lib")
    LIBS+=("-lssl" "-lcrypto" "-ldl")
    ;;
esac

[[ -n "$MG_ARCH" ]] && CPPFLAGS_COMMON+=("-DMG_ARCH=$MG_ARCH")
[[ "$IPV6" == yes ]] && CPPFLAGS_COMMON+=("-DMG_ENABLE_IPV6=1") || CPPFLAGS_COMMON+=("-DMG_ENABLE_IPV6=0")
[[ "$POSIX_FS" == yes ]] && CPPFLAGS_COMMON+=("-DMG_ENABLE_POSIX_FS=1") || CPPFLAGS_COMMON+=("-DMG_ENABLE_POSIX_FS=0")

if [[ "$LINKAGE" == static ]]; then
  LDFLAGS_BIN=(-static -static-libgcc "${LDFLAGS_COMMON[@]}")
else
  CFLAGS_COMMON+=(-fPIC)
  LDFLAGS_BIN=("-Wl,-rpath,$PREFIX/lib" "${LDFLAGS_COMMON[@]}")
fi

check_clock_libs(){
  local out="$BUILD/check-clock"
  local code
  code='
#include <time.h>
int main(void) {
  struct timespec ts;
  return clock_gettime(CLOCK_REALTIME, &ts);
}
'
  if printf '%s\n' "$code" | "$CC" "${CFLAGS_COMMON[@]}" "${CPPFLAGS_COMMON[@]}" -x c -o "$out" - "${LDFLAGS_BIN[@]}" "${LIBS[@]}" >/dev/null 2>&1; then
    rm -f "$out"
    return
  fi
  if printf '%s\n' "$code" | "$CC" "${CFLAGS_COMMON[@]}" "${CPPFLAGS_COMMON[@]}" -x c -o "$out" - "${LDFLAGS_BIN[@]}" "${LIBS[@]}" -lrt >/dev/null 2>&1; then
    rm -f "$out"
    LIBS+=("-lrt")
    log "clock_gettime requires librt; added -lrt"
    return
  fi
  rm -f "$out"
  die "cannot link clock_gettime; target SDK may be missing librt or time runtime support"
}

check_clock_libs

log "Compile mongoose library and test server ($LINKAGE, tls=$TLS)"
"$CC" "${CFLAGS_COMMON[@]}" "${CPPFLAGS_COMMON[@]}" -c "$SBUILD/mongoose.c" -o "$BUILD/mongoose.o"
"$AR" rcs "$BUILD/libmongoose.a" "$BUILD/mongoose.o"
"$RANLIB" "$BUILD/libmongoose.a"

if [[ "$LINKAGE" == dynamic ]]; then
  "$CC" -shared -Wl,-soname,libmongoose.so -o "$BUILD/libmongoose.so" "$BUILD/mongoose.o" "${LIBS[@]}"
  "$CC" "${CFLAGS_COMMON[@]}" "${CPPFLAGS_COMMON[@]}" "$BUILD/mongoose-httpd.c" \
    -L"$BUILD" -lmongoose "${LDFLAGS_BIN[@]}" "${LIBS[@]}" -o "$BUILD/mongoose-httpd"
else
  "$CC" "${CFLAGS_COMMON[@]}" "${CPPFLAGS_COMMON[@]}" "$BUILD/mongoose-httpd.c" \
    "$BUILD/libmongoose.a" "${LDFLAGS_BIN[@]}" "${LIBS[@]}" -o "$BUILD/mongoose-httpd"
fi

mkdir -p "$STAGE$PREFIX/include" "$STAGE$PREFIX/lib" "$STAGE$PREFIX/bin" "$STAGE$ROOT_DIR" "$STAGE$(dirname "$CERT_FILE")" "$STAGE$(dirname "$KEY_FILE")"
install -m 0644 "$SBUILD/mongoose.h" "$STAGE$PREFIX/include/mongoose.h"
install -m 0644 "$SBUILD/mongoose.c" "$STAGE$PREFIX/include/mongoose.c"
install -m 0644 "$BUILD/libmongoose.a" "$STAGE$PREFIX/lib/libmongoose.a"
if [[ "$LINKAGE" == dynamic ]]; then
  install -m 0755 "$BUILD/libmongoose.so" "$STAGE$PREFIX/lib/libmongoose.so"
fi
install -m 0755 "$BUILD/mongoose-httpd" "$STAGE$PREFIX/bin/mongoose-httpd"

cat >"$STAGE$ROOT_DIR/index.html" <<EOF
<!doctype html>
<html><head><meta charset="utf-8"><title>Mongoose</title></head>
<body><h1>Mongoose OK</h1><p>Built for $TARGET, linkage=$LINKAGE, tls=$TLS.</p></body></html>
EOF

cat >"$STAGE$PREFIX/start-mongoose-httpd.sh" <<EOF
#!/bin/sh
set -eu

listen="$LISTEN"
root_dir="$ROOT_DIR"
cert_file="$CERT_FILE"
key_file="$KEY_FILE"

usage(){
cat <<'USAGE'
Usage:
  start-mongoose-httpd.sh [--listen URL] [--root DIR] [--cert FILE --key FILE] [-- MONGOOSE_HTTPD_ARGS...]

Examples:
  start-mongoose-httpd.sh --listen http://0.0.0.0:8000 --root /tmp/www
  start-mongoose-httpd.sh --listen https://0.0.0.0:8443 --cert /etc/mongoose/certificate.pem --key /etc/mongoose/key.pem
USAGE
}

while [ "\$#" -gt 0 ]; do
  case "\$1" in
    --listen) [ "\$#" -ge 2 ] || { echo "ERROR: --listen requires an argument" >&2; exit 1; }; listen="\$2"; shift 2 ;;
    --root) [ "\$#" -ge 2 ] || { echo "ERROR: --root requires an argument" >&2; exit 1; }; root_dir="\$2"; shift 2 ;;
    --cert) [ "\$#" -ge 2 ] || { echo "ERROR: --cert requires an argument" >&2; exit 1; }; cert_file="\$2"; shift 2 ;;
    --key) [ "\$#" -ge 2 ] || { echo "ERROR: --key requires an argument" >&2; exit 1; }; key_file="\$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    *) echo "ERROR: unknown option: \$1" >&2; usage; exit 1 ;;
  esac
done

mkdir -p "\$root_dir"
case "\$listen" in
  https://*) exec "$PREFIX/bin/mongoose-httpd" --listen "\$listen" --root "\$root_dir" --cert "\$cert_file" --key "\$key_file" "\$@" ;;
  *) exec "$PREFIX/bin/mongoose-httpd" --listen "\$listen" --root "\$root_dir" "\$@" ;;
esac
EOF
chmod 755 "$STAGE$PREFIX/start-mongoose-httpd.sh"

BIN="$STAGE$PREFIX/bin/mongoose-httpd"

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

[[ "$LINKAGE" == static ]] && validate_static "$BIN" || validate_dynamic "$BIN"

[[ "$STRIP_BIN" == yes ]] && "$STRIP" --strip-unneeded "$BIN"
if [[ "$LINKAGE" == dynamic && "$STRIP_BIN" == yes ]]; then
  "$STRIP" --strip-unneeded "$STAGE$PREFIX/lib/libmongoose.so"
fi
if [[ "$UPX_COMPRESS" == yes ]]; then
  "$UPX_BIN" --best --lzma "$BIN"
  [[ "$LINKAGE" == static ]] && validate_static "$BIN" || validate_dynamic "$BIN"
fi

archive="$DIST/mongoose-${version}-${TARGET_ID}-${LINKAGE}-tls-${TLS}.tar.gz"
tar --numeric-owner -C "$STAGE" -czf "$archive" ".${PREFIX}" ".${ROOT_DIR}" ".$(dirname "$CERT_FILE")" ".$(dirname "$KEY_FILE")"
sha256sum "$archive" >"$archive.sha256"

log "Done"
echo "Archive:  $archive"
echo "Checksum: $archive.sha256"
echo "Deploy:"
echo "  tar -xzf /tmp/$(basename "$archive") -C /"
echo "  $PREFIX/start-mongoose-httpd.sh --listen $LISTEN --root $ROOT_DIR"
