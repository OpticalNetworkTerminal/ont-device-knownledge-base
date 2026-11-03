#!/usr/bin/env bash
set -Eeuo pipefail

trap 'rc=$?; printf "\nERROR: command failed at line %s (exit=%s): %s\n" "$LINENO" "$rc" "$BASH_COMMAND" >&2; exit "$rc"' ERR

SDK="/root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot"
TARGET="arm-buildroot-linux-gnueabi"
SOURCE_DIR="$(pwd)"
PREFIX="/usr"
LINKAGE="static"
FEATURES="tiny"
MULTIBYTE="yes"
TERMLIB="ncurses"
NCURSES_PREFIX=""
RUNTIME="no"
JOBS="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)"
CLEAN="no"
STRIP_BIN="yes"
UPX_COMPRESS="yes"
UPX_BIN="upx"

die(){ echo "ERROR: $*" >&2; exit 1; }
log(){ echo; echo "[$(date '+%F %T')] $*"; }
need_cmd(){ command -v "$1" >/dev/null 2>&1 || die "missing command: $1"; }
yn(){ case "$1" in yes|no) printf '%s' "$1";; *) die "expected yes or no, got: $1";; esac; }

usage(){
cat <<'EOF'
Usage:
  ./build-arm-vim.sh \
    --source /path/vim-9.2.0782 \
    [--sdk PATH] [--target TRIPLET] [--prefix /usr]
    [--linkage static|dynamic]
    [--features tiny|small|normal|huge] [--multibyte yes|no]
    [--termlib ncurses|tinfo|termcap] [--ncurses-prefix PATH]
    [--runtime yes|no]
    [--jobs N] [--clean] [--no-strip] [--upx PATH] [--no-upx]

Builds a console Vim for a cross target. Minimal defaults are tiny,
no GUI/X/interpreters/NLS, and no runtime packaging.
EOF
}

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
    --features) FEATURES="$2"; shift 2;;
    --multibyte) MULTIBYTE="$(yn "$2")"; shift 2;;
    --termlib) TERMLIB="$2"; shift 2;;
    --ncurses-prefix) NCURSES_PREFIX="$2"; shift 2;;
    --runtime) RUNTIME="$(yn "$2")"; shift 2;;
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
case "$FEATURES" in tiny|small|normal|huge) ;; *) die "--features must be tiny, small, normal, or huge";; esac
case "$TERMLIB" in ncurses|tinfo|termcap) ;; *) die "--termlib must be ncurses, tinfo, or termcap";; esac
[[ "$JOBS" =~ ^[1-9][0-9]*$ ]] || die "--jobs must be a positive integer"
[[ -z "$NCURSES_PREFIX" || "$NCURSES_PREFIX" == /* ]] || die "--ncurses-prefix must be absolute"

TARGET_ID="${TARGET//[^A-Za-z0-9_.-]/-}"
SOURCE_DIR="$(cd "$SOURCE_DIR" && pwd)"
[[ -x "$SOURCE_DIR/src/configure" ]] || die "vim configure not found: $SOURCE_DIR/src/configure"

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

version="$(basename "$SOURCE_DIR" | sed -E 's/^(vim-|v)//')"
work_base="$(cd "$(dirname "$SOURCE_DIR")" && pwd)"
WORK="$work_base/.${TARGET_ID}-vim-$LINKAGE"
SBUILD="$WORK/source"
STAGE="$WORK/stage"
DIST="$SOURCE_DIR/dist-${TARGET_ID}-vim"

[[ "$CLEAN" == yes ]] && rm -rf "$WORK"
rm -rf "$SBUILD" "$STAGE"
mkdir -p "$SBUILD" "$STAGE" "$DIST"
cp -a "$SOURCE_DIR/." "$SBUILD/"

CFLAGS_COMMON="-Os -ffunction-sections -fdata-sections"
CPPFLAGS_COMMON="-D_GNU_SOURCE -D_DEFAULT_SOURCE -D_BSD_SOURCE"
LIBS_EXTRA=""
if [[ -n "$NCURSES_PREFIX" ]]; then
  CPPFLAGS_COMMON="$CPPFLAGS_COMMON -I$NCURSES_PREFIX/include -I$NCURSES_PREFIX/include/ncurses"
  LIBS_EXTRA="-L$NCURSES_PREFIX/lib"
fi
if [[ "$LINKAGE" == static ]]; then
  LDFLAGS_LINK="-static -static-libgcc -Wl,--gc-sections $LIBS_EXTRA"
else
  LDFLAGS_LINK="-Wl,--gc-sections -Wl,-rpath,$PREFIX/lib $LIBS_EXTRA"
fi

BUILD_TRIPLET="$(gcc -dumpmachine)"
opts=(
  "--build=$BUILD_TRIPLET" "--host=$TARGET" "--prefix=$PREFIX" "--bindir=$PREFIX/bin"
  "--with-features=$FEATURES" "--with-tlib=$TERMLIB" "--enable-gui=no" --without-x
  --disable-nls --disable-acl --disable-gpm --disable-selinux --disable-smack
  --disable-canberra --disable-libsodium --disable-netbeans --disable-channel
  --enable-luainterp=no --enable-perlinterp=no --enable-pythoninterp=no
  --enable-python3interp=no --enable-rubyinterp=no --enable-tclinterp=no
)
[[ "$MULTIBYTE" == yes ]] && append_opt "$SBUILD/src/configure" --enable-multibyte opts
[[ "$MULTIBYTE" == no ]] && append_opt "$SBUILD/src/configure" --disable-multibyte opts

log "Build $LINKAGE vim $version"
(
  cd "$SBUILD/src"
  env PATH="$TOOLBIN:$PATH" CC="$CC" AR="$AR" RANLIB="$RANLIB" STRIP="$STRIP" \
    CFLAGS="$CFLAGS_COMMON" CPPFLAGS="$CPPFLAGS_COMMON" LDFLAGS="$LDFLAGS_LINK" \
    ./configure "${opts[@]}"
  make -j"$JOBS" LDFLAGS="$LDFLAGS_LINK"
  make DESTDIR="$STAGE" install LDFLAGS="$LDFLAGS_LINK"
)

BIN="$STAGE$PREFIX/bin/vim"
[[ -f "$BIN" ]] || BIN="$(find "$STAGE$PREFIX/bin" -type f -name vim -print -quit)"
[[ -n "$BIN" && -f "$BIN" ]] || die "vim binary not found below $STAGE$PREFIX/bin"

if [[ "$RUNTIME" == no ]]; then
  rm -rf "$STAGE$PREFIX/share/vim" "$STAGE$PREFIX/share/man" "$STAGE$PREFIX/share/applications" "$STAGE$PREFIX/share/icons"
fi
if [[ "$LINKAGE" == dynamic && -n "$NCURSES_PREFIX" ]]; then
  mkdir -p "$STAGE$PREFIX/lib"
  find "$NCURSES_PREFIX/lib" -maxdepth 1 \( -name 'libncurses*.so*' -o -name 'libtinfo*.so*' \) -exec cp -a {} "$STAGE$PREFIX/lib/" \; 2>/dev/null || true
fi

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
VIM_ROOT="$PREFIX"
export PATH="\$VIM_ROOT/bin:\$PATH"
if [ "$RUNTIME" = "yes" ]; then
  export VIM="\$VIM_ROOT/share/vim"
fi
if [ "$LINKAGE" = "dynamic" ]; then
  export LD_LIBRARY_PATH="\$VIM_ROOT/lib\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
fi
EOF
chmod 755 "$STAGE$PREFIX/environment-setup.sh"

archive="$DIST/vim-${version}-${TARGET_ID}-${LINKAGE}.tar.gz"
tar --numeric-owner -C "$STAGE" -czf "$archive" ".${PREFIX}"
sha256sum "$archive" >"$archive.sha256"

log "Done"
echo "Archive:  $archive"
echo "Checksum: $archive.sha256"
