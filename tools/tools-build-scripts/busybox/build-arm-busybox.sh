#!/usr/bin/env bash
set -Eeuo pipefail

trap 'rc=$?; printf "\nERROR: command failed at line %s (exit=%s): %s\n" "$LINENO" "$rc" "$BASH_COMMAND" >&2; exit "$rc"' ERR

SDK="/root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot"
TARGET="arm-buildroot-linux-gnueabi"
KARCH=""
SOURCE_DIR="$(pwd)"
PREFIX="/opt/busybox"
LINKAGE="static"
CONFIG_FILE=""
DEFCONFIG="defconfig"
INSTALL_APPLETS="symlink"
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
  ./build-arm-busybox.sh \
    --source /path/busybox-1.36.1 \
    [--sdk PATH] [--target TRIPLET] [--arch KBUILD_ARCH]
    [--prefix /opt/busybox]
    [--linkage static|dynamic] [--config PATH]
    [--defconfig defconfig|allnoconfig] [--install-applets symlink|none]
    [--jobs N] [--clean] [--no-strip] [--upx PATH] [--no-upx]

Builds and packages ARM BusyBox.
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

config_delete(){
  local file="$1"
  local key="$2"
  sed -i \
    -e "/^${key}=/d" \
    -e "/^# ${key} is not set$/d" \
    "$file"
}

config_enable(){
  local file="$1"
  local key="$2"
  config_delete "$file" "$key"
  printf '%s=y\n' "$key" >>"$file"
}

config_disable(){
  local file="$1"
  local key="$2"
  config_delete "$file" "$key"
  printf '# %s is not set\n' "$key" >>"$file"
}

config_string(){
  local file="$1"
  local key="$2"
  local value="$3"
  config_delete "$file" "$key"
  printf '%s="%s"\n' "$key" "$value" >>"$file"
}

refresh_busybox_config(){
  log "Refresh BusyBox config with defaults for new options"
  if make -C "$SOURCE_DIR" O="$BUILD" ARCH="$KARCH" CROSS_COMPILE="$CROSS_COMPILE" olddefconfig; then
    return 0
  fi

  log "olddefconfig is unavailable; falling back to oldconfig with default answers"
  set +o pipefail
  yes "" | make -C "$SOURCE_DIR" O="$BUILD" ARCH="$KARCH" CROSS_COMPILE="$CROSS_COMPILE" oldconfig
  local rc=$?
  set -o pipefail
  return "$rc"
}

while (($#)); do
  case "$1" in
    --source) SOURCE_DIR="$2"; shift 2;;
    --sdk) SDK="$2"; shift 2;;
    --target) TARGET="$2"; shift 2;;
    --arch) KARCH="$2"; shift 2;;
    --prefix) PREFIX="$2"; shift 2;;
    --link|--linkage) LINKAGE="$2"; shift 2;;
    --config) CONFIG_FILE="$2"; shift 2;;
    --defconfig) DEFCONFIG="$2"; shift 2;;
    --install-applets) INSTALL_APPLETS="$2"; shift 2;;
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
[[ "$INSTALL_APPLETS" == symlink || "$INSTALL_APPLETS" == none ]] || die "--install-applets must be symlink or none"
[[ "$JOBS" =~ ^[1-9][0-9]*$ ]] || die "--jobs must be a positive integer"

if [[ -z "$KARCH" ]]; then
  case "$TARGET" in
    arm*|*-arm*) KARCH="arm" ;;
    aarch64*) KARCH="arm64" ;;
    mips*|mipsel*) KARCH="mips" ;;
    riscv64*) KARCH="riscv" ;;
    x86_64*) KARCH="x86_64" ;;
    i?86*) KARCH="x86" ;;
    *) die "cannot infer BusyBox --arch from --target=$TARGET; pass --arch explicitly" ;;
  esac
fi
TARGET_ID="${TARGET//[^A-Za-z0-9_.-]/-}"

SOURCE_DIR="$(cd "$SOURCE_DIR" && pwd)"
[[ -f "$SOURCE_DIR/Makefile" ]] || die "BusyBox Makefile not found: $SOURCE_DIR/Makefile"

if [[ -n "$CONFIG_FILE" ]]; then
  CONFIG_FILE="$(cd "$(dirname "$CONFIG_FILE")" && pwd)/$(basename "$CONFIG_FILE")"
  [[ -f "$CONFIG_FILE" ]] || die "config file not found: $CONFIG_FILE"
fi

TOOLBIN="$(find_sdk_bin "$SDK")" || die "cannot find ${TARGET}-gcc below $SDK"
export PATH="$TOOLBIN:$PATH"

CC="${TARGET}-gcc"
STRIP="${TARGET}-strip"
READELF="${TARGET}-readelf"
CROSS_COMPILE="${TARGET}-"

for x in "$CC" "$STRIP" "$READELF" make file tar sha256sum; do
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

version="$(basename "$SOURCE_DIR" | sed 's/^busybox-//')"
WORK="$SOURCE_DIR/.${TARGET_ID}-busybox-$LINKAGE"
BUILD="$WORK/build"
STAGE="$WORK/stage"
DIST="$SOURCE_DIR/dist-${TARGET_ID}-busybox"

[[ "$CLEAN" == yes ]] && rm -rf "$WORK"
rm -rf "$BUILD" "$STAGE"
mkdir -p "$BUILD" "$STAGE" "$DIST"

log "Build configuration"
cat <<EOF
Source:          $SOURCE_DIR
SDK:             $SDK
Toolchain:       $("$CC" -dumpmachine)
Sysroot:         $SYSROOT
Linkage:         $LINKAGE
Prefix:          $PREFIX
Config:          ${CONFIG_FILE:-$DEFCONFIG}
Kbuild ARCH:     $KARCH
Install applets: $INSTALL_APPLETS
EOF

if [[ -n "$CONFIG_FILE" ]]; then
  log "Use BusyBox config: $CONFIG_FILE"
  cp -f "$CONFIG_FILE" "$BUILD/.config"
else
  log "Generate BusyBox config: $DEFCONFIG"
  make -C "$SOURCE_DIR" O="$BUILD" ARCH="$KARCH" CROSS_COMPILE="$CROSS_COMPILE" "$DEFCONFIG"
fi

CONFIG="$BUILD/.config"
[[ -f "$CONFIG" ]] || die "BusyBox config was not generated"

config_string "$CONFIG" CONFIG_CROSS_COMPILER_PREFIX "$CROSS_COMPILE"
config_disable "$CONFIG" CONFIG_PIE

if [[ "$LINKAGE" == static ]]; then
  config_enable "$CONFIG" CONFIG_STATIC
  config_enable "$CONFIG" CONFIG_STATIC_LIBGCC
else
  config_disable "$CONFIG" CONFIG_STATIC
  config_disable "$CONFIG" CONFIG_STATIC_LIBGCC
fi

if [[ "$INSTALL_APPLETS" == symlink ]]; then
  config_enable "$CONFIG" CONFIG_INSTALL_APPLET_SYMLINKS
  config_disable "$CONFIG" CONFIG_INSTALL_APPLET_HARDLINKS
  config_disable "$CONFIG" CONFIG_INSTALL_APPLET_SCRIPT_WRAPPERS
else
  config_disable "$CONFIG" CONFIG_INSTALL_APPLET_SYMLINKS
  config_disable "$CONFIG" CONFIG_INSTALL_APPLET_HARDLINKS
  config_disable "$CONFIG" CONFIG_INSTALL_APPLET_SCRIPT_WRAPPERS
fi

refresh_busybox_config

log "Build BusyBox"
make -C "$SOURCE_DIR" O="$BUILD" ARCH="$KARCH" CROSS_COMPILE="$CROSS_COMPILE" -j"$JOBS"

log "Install BusyBox into stage"
make -C "$SOURCE_DIR" O="$BUILD" ARCH="$KARCH" CROSS_COMPILE="$CROSS_COMPILE" \
  CONFIG_PREFIX="$STAGE$PREFIX" install

BUSYBOX_BIN="$STAGE$PREFIX/bin/busybox"
if [[ ! -f "$BUSYBOX_BIN" ]]; then
  BUSYBOX_BIN="$(find "$STAGE$PREFIX" -type f -name busybox -print -quit)"
fi
[[ -n "$BUSYBOX_BIN" && -f "$BUSYBOX_BIN" ]] || die "busybox binary not found below $STAGE$PREFIX"

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
  "$READELF" -l "$f" | grep -i interpreter || true
  "$READELF" -d "$f" 2>/dev/null | grep NEEDED || true
  echo "Dynamic validation OK: $(basename "$f")"
}

if [[ "$LINKAGE" == static ]]; then
  validate_static "$BUSYBOX_BIN"
else
  validate_dynamic "$BUSYBOX_BIN"
fi

if [[ "$STRIP_BIN" == yes ]]; then
  "$STRIP" --strip-unneeded "$BUSYBOX_BIN"
fi

if [[ "$UPX_COMPRESS" == yes ]]; then
  "$UPX_BIN" --best --lzma "$BUSYBOX_BIN"
  if [[ "$LINKAGE" == static ]]; then
    validate_static "$BUSYBOX_BIN"
  else
    validate_dynamic "$BUSYBOX_BIN"
  fi
fi

cp -f "$CONFIG" "$STAGE$PREFIX/busybox.config"

archive="$DIST/busybox-${version}-${TARGET_ID}-${LINKAGE}.tar.gz"
tar --numeric-owner -C "$STAGE" -czf "$archive" ".${PREFIX}"
sha256sum "$archive" >"$archive.sha256"

log "Done"
echo "Archive:  $archive"
echo "Checksum: $archive.sha256"
echo "Deploy:"
echo "  tar -xzf /tmp/$(basename "$archive") -C /"
echo "  $PREFIX/bin/busybox --help"
