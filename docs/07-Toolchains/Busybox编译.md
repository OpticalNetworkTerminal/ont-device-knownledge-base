可以。现在编译 **BusyBox 1.36.1 动态链接版本**，继续使用已经验证通过的 ARM32、Cortex-A53、EABI softfp、glibc 2.26 SDK。

先不要替换设备原有 `/bin/busybox`。编译完成后，只把新二进制放到设备 `/tmp` 测试。设备宿主是 ARM32 EABI5、glibc 2.26、加载器 `/lib/ld-linux.so.3`，与你的工具链完全对应。

BusyBox 官方推荐以 `make defconfig` 生成通用配置，再通过 `make menuconfig` 调整功能。BusyBox 1.36.1 是 1.36 系列的稳定修复版本。([busybox.net](https://busybox.net/?utm_source=chatgpt.com))

# 一、配置工具链环境

直接执行：

```bash
cd /root/builduser/arm/busybox/busybox-1.36.1_g7615/busybox-1.36.1

SDK="/root/builduser/toolchains/buildroot-2017.11.2/output-g7615/host"

export PATH="$SDK/bin:$PATH"
export ARCH="arm"
export CROSS_COMPILE="arm-buildroot-linux-gnueabi-"

command -v "${CROSS_COMPILE}gcc"
"${CROSS_COMPILE}gcc" -dumpmachine
"${CROSS_COMPILE}gcc" --version
"${CROSS_COMPILE}gcc" -print-sysroot
```

预期看到：

```text
arm-buildroot-linux-gnueabi
gcc 5.5.0
.../output-g7615/host/arm-buildroot-linux-gnueabi/sysroot
```

再确认工具链默认参数：

```bash
"${CROSS_COMPILE}gcc" -v 2>&1 |
  grep -E 'mcpu|march|mfloat-abi|mfpu'
```

------

# 二、清理并生成 BusyBox 默认配置

如果这个源码目录以前没有保存的重要配置，直接彻底清理：

```bash
make distclean
```

生成通用配置：

```bash
make \
  ARCH="$ARCH" \
  CROSS_COMPILE="$CROSS_COMPILE" \
  defconfig
```

检查几个关键选项：

```bash
grep -E \
  '^(CONFIG_STATIC|CONFIG_PIE|CONFIG_CROSS_COMPILER_PREFIX|CONFIG_SYSROOT)|^# CONFIG_(STATIC|PIE)' \
  .config
```

## 动态编译

```text
动态链接
非 PIE
ARM32 EABI softfp
glibc 2.26
不额外覆盖 SDK 自带编译参数
```

执行下面这段，确保配置明确：

```bash
set_kconfig_string()
{
    key="$1"
    value="$2"

    sed -i \
      -e "/^${key}=/d" \
      -e "/^# ${key} is not set$/d" \
      .config

    printf '%s="%s"\n' "$key" "$value" >> .config
}

disable_kconfig()
{
    key="$1"

    sed -i \
      -e "/^${key}=/d" \
      -e "/^# ${key} is not set$/d" \
      .config

    printf '# %s is not set\n' "$key" >> .config
}

set_kconfig_string \
  CONFIG_CROSS_COMPILER_PREFIX \
  "arm-buildroot-linux-gnueabi-"

disable_kconfig CONFIG_STATIC
disable_kconfig CONFIG_PIE

yes "" |
  make \
    ARCH="$ARCH" \
    CROSS_COMPILE="$CROSS_COMPILE" \
    oldconfig
```

再次确认：

```bash
grep -E \
  '^(CONFIG_CROSS_COMPILER_PREFIX|CONFIG_STATIC|CONFIG_PIE)|^# CONFIG_(STATIC|PIE)' \
  .config
```

预期：

```text
CONFIG_CROSS_COMPILER_PREFIX="arm-buildroot-linux-gnueabi-"
# CONFIG_STATIC is not set
# CONFIG_PIE is not set
```

## 为什么第一版不编静态 BusyBox

动态链接版本会直接复用设备上的：

```text
/lib/ld-linux.so.3
/lib/libc.so.6
```

这样可以完整验证你刚构建的 glibc 2.26 SDK，并且二进制明显更小。

先不要启用：

```text
CONFIG_STATIC
```

静态 glibc BusyBox 涉及 NSS、DNS、用户解析等行为差异，后面可以单独再编一个静态救援版。

------

## 静态编译
```bash
1. 进入源码并加载 SDK
cd /root/builduser/arm/busybox/busybox-1.36.1_g7615/busybox-1.36.1

SDK="/root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot"
TARGET="arm-buildroot-linux-gnueabi"


考虑到 SDK 解压结构可能有两种，自动判断工具目录：
if [ -x "$SDK/bin/${TARGET}-gcc" ]; then
    TOOLBIN="$SDK/bin"
elif [ -x "$SDK/host/bin/${TARGET}-gcc" ]; then
    TOOLBIN="$SDK/host/bin"
else
    echo "找不到交叉编译器：${TARGET}-gcc"
    exit 1
fi

export PATH="$TOOLBIN:$PATH"
export ARCH=arm
export CROSS_COMPILE="${TARGET}-"

检查：

command -v "${CROSS_COMPILE}gcc"
"${CROSS_COMPILE}gcc" -dumpmachine
"${CROSS_COMPILE}gcc" --version
"${CROSS_COMPILE}gcc" -print-sysroot


预期：

arm-buildroot-linux-gnueabi
gcc 5.5.0

2. 如果 SDK 移动过，先重定位

检查重定位脚本：

find "$SDK" -maxdepth 2 -name relocate-sdk.sh -type f

cd "$SDK"
./relocate-sdk.sh


然后返回 BusyBox 源码：

cd /root/builduser/arm/busybox/busybox-1.36.1_g7615/busybox-1.36.1

确认 sysroot 已指向当前路径：

"${CROSS_COMPILE}gcc" -print-sysroot

3. 检查 glibc 静态库
SYSROOT="$("${CROSS_COMPILE}gcc" -print-sysroot)"

echo "$SYSROOT"

find "$SYSROOT" -type f \
  \( -name libc.a \
     -o -name libm.a \
     -o -name libresolv.a \
     -o -name libpthread.a \
     -o -name libcrypt.a \) \
  -print

至少必须存在：

libc.a
libm.a
libresolv.a
libpthread.a

重点检查：

test -f "$SYSROOT/usr/lib/libc.a" ||
test -f "$SYSROOT/lib/libc.a" || {
    echo "SDK 中缺少 libc.a，无法使用 glibc 全静态链接"
    exit 1
}
4. 备份原来的动态配置
mkdir -p ../configs

if [ -f .config ]; then
    cp -f .config \
      ../configs/busybox-1.36.1-g7615-dynamic.config
fi

然后清理：

make distclean
5. 生成默认配置
make \
  ARCH="$ARCH" \
  CROSS_COMPILE="$CROSS_COMPILE" \
  defconfig


cd /root/builduser/arm/busybox/busybox-1.36.1_g7615/busybox-1.36.1

SDK="/root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot"
TARGET="arm-buildroot-linux-gnueabi"

export PATH="$SDK/bin:$PATH"
export ARCH=arm
export CROSS_COMPILE="${TARGET}-"

make distclean
make defconfig

定义两个辅助函数：

config_enable() {
    key="$1"

    sed -i \
      -e "/^${key}=/d" \
      -e "/^# ${key} is not set$/d" \
      .config

    echo "${key}=y" >> .config
}

config_disable() {
    key="$1"

    sed -i \
      -e "/^${key}=/d" \
      -e "/^# ${key} is not set$/d" \
      .config

    echo "# ${key} is not set" >> .config
}

config_string() {
    key="$1"
    value="$2"

    sed -i \
      -e "/^${key}=/d" \
      -e "/^# ${key} is not set$/d" \
      .config

    printf '%s="%s"\n' "$key" "$value" >> .config
}

设置全静态配置：

config_enable CONFIG_STATIC
config_enable CONFIG_STATIC_LIBGCC
config_disable CONFIG_PIE

config_enable CONFIG_INSTALL_APPLET_SYMLINKS
config_disable CONFIG_INSTALL_APPLET_HARDLINKS
config_disable CONFIG_INSTALL_APPLET_SCRIPT_WRAPPERS

config_string \
  CONFIG_CROSS_COMPILER_PREFIX \
  "arm-buildroot-linux-gnueabi-"

让 BusyBox 重新整理配置依赖：

yes "" | make oldconfig

检查：

grep -E \
  '^(CONFIG_STATIC|CONFIG_STATIC_LIBGCC|CONFIG_CROSS_COMPILER_PREFIX|CONFIG_INSTALL_APPLET_SYMLINKS)|^# CONFIG_PIE' \
  .config

应看到：

CONFIG_STATIC=y
CONFIG_STATIC_LIBGCC=y
# CONFIG_PIE is not set
CONFIG_CROSS_COMPILER_PREFIX="arm-buildroot-linux-gnueabi-"
CONFIG_INSTALL_APPLET_SYMLINKS=y

然后编译：

make -j"$(nproc)"
验证是否全静态
file busybox

应包含：

ELF 32-bit LSB executable, ARM, EABI5, statically linked

检查没有动态加载器：

arm-buildroot-linux-gnueabi-readelf -l busybox |
  grep -i interpreter || echo "OK: no ELF interpreter"

检查没有动态库依赖：

arm-buildroot-linux-gnueabi-readelf -d busybox |
  grep NEEDED || echo "OK: no dynamic dependencies"

检查 ARM ABI：

arm-buildroot-linux-gnueabi-readelf -A busybox

应该继续是：

Tag_CPU_name: "Cortex-A53"
Tag_CPU_arch: v8

并且不应出现：

Tag_ABI_VFP_args: VFP registers



```

# 三、可选地检查 menuconfig

执行：

```bash
make \
  ARCH="$ARCH" \
  CROSS_COMPILE="$CROSS_COMPILE" \
  menuconfig
```

重点确认：

```text
Settings
  Build Options
    Build static binary (no shared libs)              关闭
    Build position independent executable             关闭
    Cross compiler prefix                              arm-buildroot-linux-gnueabi-
    Path to sysroot                                    留空
    Additional CFLAGS                                  留空
    Additional LDFLAGS                                 留空
```

`Path to sysroot` 留空是正确的，因为 Buildroot GCC wrapper 已经自动指向：

```text
output-g7615/host/arm-buildroot-linux-gnueabi/sysroot
```

不需要重复填写。

默认 `defconfig` 会启用较多通用 applet，适合先构建一个功能完整的测试版本。后面确认运行正常后，再根据设备需求裁剪 telnetd、httpd、ftpd 等不需要的网络服务 applet。

------

# 四、开始编译

先运行普通并行编译：

```bash
make \
  ARCH="$ARCH" \
  CROSS_COMPILE="$CROSS_COMPILE" \
  -j"$(nproc)"
```

需要查看完整编译命令时使用：

```bash
make \
  ARCH="$ARCH" \
  CROSS_COMPILE="$CROSS_COMPILE" \
  V=1 \
  -j"$(nproc)"
```

编译成功后应当生成：

```text
busybox
busybox_unstripped
```

查看：

```bash
ls -lh busybox busybox_unstripped 2>/dev/null || true
file busybox
```

------

# 五、离线检查 BusyBox ABI

定义工具：

```bash
READELF="${CROSS_COMPILE}readelf"
```

## 检查 ELF 类型

```bash
file busybox

"$READELF" -h busybox |
  grep -E 'Class|Data|Machine|Flags'
```

应看到类似：

```text
ELF 32-bit LSB executable, ARM, EABI5
Class: ELF32
Data: little endian
Machine: ARM
Flags: Version5 EABI
```

## 检查动态加载器

```bash
"$READELF" -l busybox |
  grep -i interpreter
```

必须是：

```text
[Requesting program interpreter: /lib/ld-linux.so.3]
```

不能是：

```text
/lib/ld-linux-armhf.so.3
/lib/ld-linux-aarch64.so.1
```

## 检查 ARM 属性

```bash
"$READELF" -A busybox
```

期望包括：

```text
Tag_CPU_name: "Cortex-A53"
Tag_CPU_arch: v8
Tag_FP_arch: FP for ARMv8
```

并且不应出现：

```text
Tag_ABI_VFP_args: VFP registers
```

没有 `Tag_ABI_VFP_args` 表示仍然是与原厂 BusyBox 一致的非 hard-float 参数传递 ABI。

## 检查动态库依赖

```bash
"$READELF" -d busybox |
  grep NEEDED
```

可能看到：

```text
libm.so.6
libresolv.so.2
libc.so.6
```

具体依赖取决于启用的 applet。

## 检查 glibc 符号版本

```bash
"$READELF" --version-info busybox |
  grep -o 'GLIBC_[0-9.]*' |
  sort -Vu
```

由于它链接的是 SDK 中的 glibc 2.26，不能产生高于：

```text
GLIBC_2.26
```

的依赖。

------

# 六、保存编译配置

建议立即保存：

```bash
mkdir -p ../configs

cp -f .config \
  ../configs/busybox-1.36.1-g7615.config

sha256sum \
  ../configs/busybox-1.36.1-g7615.config
```

以后重新编译：

```bash
make distclean

cp \
  ../configs/busybox-1.36.1-g7615.config \
  .config

yes "" |
  make \
    ARCH=arm \
    CROSS_COMPILE=arm-buildroot-linux-gnueabi- \
    oldconfig

make \
  ARCH=arm \
  CROSS_COMPILE=arm-buildroot-linux-gnueabi- \
  -j"$(nproc)"
```

------

# 七、生成 applet 安装目录

这一步不会修改构建机器系统，只安装到当前源码目录的 `_install`：

```bash
rm -rf _install

make \
  ARCH="$ARCH" \
  CROSS_COMPILE="$CROSS_COMPILE" \
  CONFIG_PREFIX="$PWD/_install" \
  install
```

查看目录：

```bash
find _install -maxdepth 3 -type f -o -type l |
  sort |
  head -100
```

通常结构类似：

```text
_install/bin/busybox
_install/bin/ash -> busybox
_install/bin/cat -> busybox
_install/bin/cp -> busybox
_install/bin/ls -> busybox
_install/sbin/ifconfig -> ../bin/busybox
_install/usr/bin/awk -> ../../bin/busybox
```

统计 applet 数量：

```bash
find _install -type l |
  wc -l
```

不要把整个 `_install` 直接覆盖到光猫根文件系统。它目前只用于检查和后续打包。

------

# 八、生成测试包

创建发布目录：

```bash
DIST="$PWD/dist-g7615"

rm -rf "$DIST"
mkdir -p "$DIST"
```

复制 BusyBox 和配置：

```bash
cp -f busybox \
  "$DIST/busybox-1.36.1-g7615"

cp -f .config \
  "$DIST/busybox-1.36.1-g7615.config"
```

如果存在未裁剪版本，也保留一份用于调试：

```bash
if [ -f busybox_unstripped ]; then
    cp -f busybox_unstripped \
      "$DIST/busybox-1.36.1-g7615.unstripped"
fi
```

生成校验：

```bash
cd "$DIST"

sha256sum \
  busybox-1.36.1-g7615 \
  busybox-1.36.1-g7615.config \
  > SHA256SUMS

ls -lh
cat SHA256SUMS
```

------

# 九、传到 G7615 测试

传输：

```bash
scp \
  "$DIST/busybox-1.36.1-g7615" \
  root@G7615_IP:/tmp/
```

设备上：

```bash
cd /tmp

chmod 755 busybox-1.36.1-g7615
```

先检查动态库：

```bash
/lib/ld-linux.so.3 \
  --list \
  /tmp/busybox-1.36.1-g7615
```

然后查看版本：

```bash
/tmp/busybox-1.36.1-g7615
```

预期第一行：

```text
BusyBox v1.36.1 (...) multi-call binary.
```

列出 applet：

```bash
/tmp/busybox-1.36.1-g7615 --list |
  head -50

/tmp/busybox-1.36.1-g7615 --list |
  wc -l
```

测试几个无副作用命令：

```bash
/tmp/busybox-1.36.1-g7615 echo "busybox 1.36.1 works"

/tmp/busybox-1.36.1-g7615 uname -a

/tmp/busybox-1.36.1-g7615 id

/tmp/busybox-1.36.1-g7615 ls -la /tmp

/tmp/busybox-1.36.1-g7615 cat /proc/cpuinfo |
  head
```

测试新 shell：

```bash
/tmp/busybox-1.36.1-g7615 ash
```

进入后：

```sh
echo "$0"
busybox
exit
```

注意，因为 BusyBox 是多调用二进制，安全测试时使用：

```bash
/tmp/busybox-1.36.1-g7615 ls
/tmp/busybox-1.36.1-g7615 ps
/tmp/busybox-1.36.1-g7615 ash
```

不要立即创建或覆盖：

```text
/bin/sh
/bin/ash
/bin/busybox
```

------

# 十、完整的一键编译命令

上面的流程压缩后，核心命令是：

```bash
cd /root/builduser/arm/busybox/busybox-1.36.1_g7615/busybox-1.36.1

SDK="/root/builduser/toolchains/buildroot-2017.11.2/output-g7615/host"

export PATH="$SDK/bin:$PATH"
export ARCH=arm
export CROSS_COMPILE=arm-buildroot-linux-gnueabi-

make distclean

make \
  ARCH="$ARCH" \
  CROSS_COMPILE="$CROSS_COMPILE" \
  defconfig

sed -i \
  -e '/^CONFIG_STATIC=/d' \
  -e '/^# CONFIG_STATIC is not set$/d' \
  -e '/^CONFIG_PIE=/d' \
  -e '/^# CONFIG_PIE is not set$/d' \
  -e '/^CONFIG_CROSS_COMPILER_PREFIX=/d' \
  .config

cat >> .config <<'EOF'
# CONFIG_STATIC is not set
# CONFIG_PIE is not set
CONFIG_CROSS_COMPILER_PREFIX="arm-buildroot-linux-gnueabi-"
EOF

yes "" |
  make \
    ARCH="$ARCH" \
    CROSS_COMPILE="$CROSS_COMPILE" \
    oldconfig

make \
  ARCH="$ARCH" \
  CROSS_COMPILE="$CROSS_COMPILE" \
  -j"$(nproc)"

file busybox

"${CROSS_COMPILE}readelf" -l busybox |
  grep interpreter

"${CROSS_COMPILE}readelf" -A busybox

"${CROSS_COMPILE}readelf" -d busybox |
  grep NEEDED
```

编译结果满足以下条件，就可以传设备：

```text
ELF 32-bit LSB ARM EABI5
interpreter /lib/ld-linux.so.3
Cortex-A53
ARM architecture v8
没有 Tag_ABI_VFP_args: VFP registers
GLIBC 依赖不高于 2.26
```
