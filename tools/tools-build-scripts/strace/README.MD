# strace 最小版编译脚本

`build-arm-strace.sh` 用于交叉编译 ARM Buildroot GNU EABI 环境可用的 strace。默认目标为 `arm-buildroot-linux-gnueabi`，支持通过 `--sdk` 和 `--target` 切换工具链；支持静态链接和动态链接，默认静态链接，并在打包前默认执行 `upx --best --lzma`。

默认构建最小 syscall 跟踪版本：关闭 stacktrace、mpers、SELinux、安装测试等可选能力，尽量只依赖目标 libc，方便在小系统里直接使用。

## 快速调用

默认静态编译：

```bash
# https://strace.io/
# https://github.com/strace/strace/releases

mkdir -p /tmp/tools-build-scripts/strace
cd /tmp/tools-build-scripts/strace
wget https://github.com/strace/strace/releases/download/v7.1/strace-7.1.tar.xz
tar -xvf strace-7.1.tar.xz

cd /tmp/tools-build-scripts/strace

./build-arm-strace.sh \
  --source /tmp/tools-build-scripts/strace/strace-7.1 \
  --sdk /root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot \
  --target arm-buildroot-linux-gnueabi \
  --prefix /usr \
  --linkage static \
  --clean \
  2>&1 | tee build-arm-strace.log
```

动态编译：

```bash
./build-arm-strace.sh \
  --source /tmp/tools-build-scripts/strace/strace-7.1 \
  --sdk /root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot \
  --target arm-buildroot-linux-gnueabi \
  --prefix /usr \
  --linkage dynamic \
  --clean
```

保留上游 bundled kernel headers 自动探测，并显式关闭额外功能：

```bash
./build-arm-strace.sh \
  --source /tmp/tools-build-scripts/strace/strace-7.1 \
  --bundled check \
  --stacktrace no \
  --mpers no \
  --install-tests no \
  --clean
```

## 参数说明

| 参数 | 是否必填 | 默认值 | 说明 |
| --- | --- | --- | --- |
| `--source PATH` | 否 | 当前工作目录 | strace 源码目录，目录内需要存在 `configure`。 |
| `--sdk PATH` | 否 | `/root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot` | Buildroot SDK 根目录。脚本会在 `$sdk/bin` 或 `$sdk/host/bin` 查找 `${target}-gcc`。 |
| `--target TRIPLET` | 否 | `arm-buildroot-linux-gnueabi` | 交叉编译工具链 triplet，例如 `aarch64-buildroot-linux-gnu`、`mips-linux-gnu`。 |
| `--prefix PATH` | 否 | `/usr` | 目标安装前缀，必须是绝对路径。 |
| `--linkage static\|dynamic` | 否 | `static` | 链接模式。 |
| `--link static\|dynamic` | 否 | `static` | `--linkage` 的兼容别名。 |
| `--bundled yes\|no\|check` | 否 | `check` | 对应 strace `--enable-bundled=VALUE`，控制是否使用上游自带的 Linux kernel headers。`check` 表示自动判断。 |
| `--arm-oabi yes\|no` | 否 | `no` | 是否启用 ARM OABI 支持。现代 ARM EABI 工具链通常不需要。 |
| `--stacktrace yes\|no\|check` | 否 | `no` | 是否启用调用栈解析。启用后可能需要 libunwind、libdw 或 libiberty，最小版默认关闭。 |
| `--mpers yes\|no\|check\|m32\|mx32` | 否 | `no` | 是否启用 multi-personality 支持。交叉编译时容易增加复杂度，最小版默认关闭。 |
| `--install-tests yes\|no` | 否 | `no` | 是否安装 strace tests。最小版默认关闭。 |
| `--jobs N` | 否 | `nproc` 结果，失败时为 `1` | `make -j` 并行任务数。 |
| `--clean` | 否 | 不启用 | 编译前删除当前目标和链接模式的工作目录。 |
| `--no-strip` | 否 | 不启用 | 跳过 `${TARGET}-strip --strip-unneeded`。 |
| `--upx PATH` | 否 | `upx` | 指定 UPX 命令路径或命令名。 |
| `--no-upx` | 否 | 不启用 | 跳过 UPX 压缩。 |
| `-h`, `--help` | 否 | 不适用 | 输出脚本内置帮助。 |

## 依赖说明

strace 最小版主要依赖：

```text
strace
└── libc
```

静态模式至少需要 SDK sysroot 中存在：

```text
libc.a
```

默认关闭的可选依赖：

```text
libunwind
libdw / elfutils
libiberty
libselinux
```

如果需要 `--stacktrace yes`，通常需要在 SDK/sysroot 里准备对应库和头文件，并可能还要调整链接参数。小型 ONT/路由器环境建议保持默认最小配置。

如果静态模式下最终产物仍出现 `PT_INTERP` 或 `DT_NEEDED`，脚本会输出 `WARN`，但不再中断打包。此时产物可继续测试运行，但实际依赖目标系统中的动态链接器和对应 `.so`。

## 输出内容

构建完成后，产物会放在 strace 源码目录下：

```text
dist-<target>-strace/
├── strace-7.1-<target>-static.tar.gz
├── strace-7.1-<target>-static.tar.gz.sha256
├── strace-7.1-<target>-dynamic.tar.gz
└── strace-7.1-<target>-dynamic.tar.gz.sha256
```

压缩包内主要包含：

```text
<prefix>/bin/strace
<prefix>/environment-setup.sh
```

## 部署和验证

```sh
tar -xzf /tmp/strace-7.1-arm-buildroot-linux-gnueabi-static.tar.gz -C /
. /usr/environment-setup.sh
strace -V
```

跟踪命令：

```sh
strace -f -o /tmp/trace.log /bin/ls /
```

跟踪已运行进程：

```sh
strace -p <pid>
```

只看网络相关 syscall：

```sh
strace -f -e trace=network -o /tmp/net.log /path/to/program
```

显示耗时统计：

```sh
strace -f -c /path/to/program
```

strace 依赖 Linux `ptrace` 能力。目标系统通常需要 root 权限；如果系统限制 ptrace，可能还需要调整内核配置、安全策略或 `/proc/sys/kernel/yama/ptrace_scope`。

## 编译环境要求

- Buildroot SDK，默认目标前缀为 `arm-buildroot-linux-gnueabi`，可用 `--target` 覆盖
- 本机需要可执行命令：`make`、`file`、`tar`、`sha256sum`
- 默认启用 UPX 时还需要 `upx`
