# ARM BusyBox 编译脚本

`build-arm-busybox.sh` 用于交叉编译 ARM Buildroot GNU EABI 环境可用的 BusyBox。脚本支持静态链接和动态链接，默认静态链接，默认安装 applet symlink，并在打包前默认执行 `upx --best --lzma` 压缩 `busybox` 主程序。

## 快速调用

默认静态编译：

```bash
# https://busybox.net/downloads/

mkdir -p /tmp/tools-build-scripts/busybox
cd /tmp/tools-build-scripts/busybox
wget https://busybox.net/downloads/busybox-1.38.0.tar.bz2
tar -xjf busybox-1.38.0.tar.bz2

./build-arm-busybox.sh \
  --source /tmp/tools-build-scripts/busybox/busybox-1.38.0 \
  --sdk /root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot \
  --target arm-buildroot-linux-gnueabi \
  --arch arm \
  --prefix /opt/busybox \
  --linkage static \
  --clean \
  2>&1 | tee build-arm-busybox.log
```

动态编译：

```bash
./build-arm-busybox.sh \
  --source /tmp/tools-build-scripts/busybox/busybox-1.38.0 \
  --sdk /root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot \
  --target arm-buildroot-linux-gnueabi \
  --arch arm \
  --prefix /opt/busybox \
  --linkage dynamic \
  --clean
```

使用已有 `.config`：

```bash
./build-arm-busybox.sh \
  --source /tmp/tools-build-scripts/busybox/busybox-1.38.0 \
  --config /tmp/tools-build-scripts/busybox/busybox.config \
  --sdk /root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot \
  --target arm-buildroot-linux-gnueabi \
  --arch arm \
  --prefix /opt/busybox \
  --linkage static \
  --clean
```

## 参数说明

| 参数 | 是否必填 | 默认值 | 说明 |
| --- | --- | --- | --- |
| `--source PATH` | 否 | 当前工作目录 | BusyBox 源码目录，目录内需要存在 `Makefile`。 |
| `--sdk PATH` | 否 | `/root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot` | Buildroot 交叉编译 SDK 根目录。 |
| `--target TRIPLET` | 否 | `arm-buildroot-linux-gnueabi` | 交叉编译工具链 triplet。脚本会查找 `${target}-gcc`，并设置 `CROSS_COMPILE=${target}-`。 |
| `--arch KBUILD_ARCH` | 否 | 从 `--target` 推断 | BusyBox/Kbuild 的 `ARCH` 值，例如 `arm`、`arm64`、`mips`。无法推断时需要显式传入。 |
| `--prefix PATH` | 否 | `/opt/busybox` | 目标安装前缀，必须是绝对路径。建议先放到 `/opt/busybox` 或 `/tmp` 测试，不要直接覆盖系统 `/bin/busybox`。 |
| \`--linkage static | dynamic\` | 否 | `static` |
| \`--link static | dynamic\` | 否 | `static` |
| `--config PATH` | 否 | 无 | 使用已有 BusyBox `.config`。脚本仍会覆盖交叉编译前缀、静态/动态、PIE 和 applet 安装方式。 |
| `--defconfig NAME` | 否 | `defconfig` | 未传 `--config` 时使用的 make 配置目标，例如 `defconfig`、`allnoconfig`。 |
| \`--install-applets symlink | none\` | 否 | `symlink` |
| `--jobs N` | 否 | `nproc` 结果，失败时为 `1` | `make -j` 并行任务数。 |
| `--clean` | 否 | 不启用 | 编译前删除 `.<target>-busybox-static` 或 `.<target>-busybox-dynamic` 工作目录。 |
| `--no-strip` | 否 | 不启用 | 跳过 `${TARGET}-strip --strip-unneeded`。 |
| `--upx PATH` | 否 | `upx` | 指定 UPX 命令路径或命令名。 |
| `--no-upx` | 否 | 不启用 | 跳过 UPX 压缩。 |
| `-h`, `--help` | 否 | 不适用 | 输出脚本内置帮助。 |

## 静态与动态模式

静态模式：

- 启用 `CONFIG_STATIC`
- 启用 `CONFIG_STATIC_LIBGCC`
- 禁用 `CONFIG_PIE`
- 打包前校验 `busybox` 不能包含 ELF interpreter 和 `DT_NEEDED`

动态模式：

- 禁用 `CONFIG_STATIC`
- 禁用 `CONFIG_STATIC_LIBGCC`
- 禁用 `CONFIG_PIE`
- 打包前输出 ELF interpreter 和 `DT_NEEDED` 依赖

两种模式都会设置：

- 使用 `olddefconfig` 自动接受新增配置项默认值
- 如果当前 BusyBox 没有 `olddefconfig` 目标，则 fallback 到 `oldconfig` 并自动输入默认答案

```text
CONFIG_CROSS_COMPILER_PREFIX="<target>-"
```

## 输出内容

构建完成后，产物会放在 BusyBox 源码目录下：

```text
dist-<target>-busybox/
├── busybox-<version>-<target>-static.tar.gz
├── busybox-<version>-<target>-static.tar.gz.sha256
├── busybox-<version>-<target>-dynamic.tar.gz
└── busybox-<version>-<target>-dynamic.tar.gz.sha256
```

压缩包内会包含：

```text
<prefix>/bin/busybox
<prefix>/busybox.config
```

如果 `--install-applets symlink`，还会包含 BusyBox install 生成的 applet symlink。

## 部署示例

```sh
tar -xzf /tmp/busybox-<version>-arm-buildroot-linux-gnueabi-static.tar.gz -C /
/opt/busybox/bin/busybox --help
/opt/busybox/bin/busybox ash
```

先在独立前缀测试，确认 applet 和 ABI 正常后，再考虑是否替换系统 BusyBox。

## 编译环境要求

- Buildroot SDK，默认目标前缀为 `arm-buildroot-linux-gnueabi`，可用 `--target` 覆盖
- 本机需要可执行命令：`make`、`file`、`tar`、`sha256sum`
- 默认启用 UPX 时还需要 `upx`
- 静态模式要求 SDK sysroot 内存在 `libc.a`
