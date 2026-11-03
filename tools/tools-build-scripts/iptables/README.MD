# ARM iptables 编译脚本

`build-arm-iptables.sh` 用于交叉编译 ARM Buildroot GNU EABI 环境可用的 iptables 1.8.13。脚本支持静态链接和动态链接，默认构建 legacy 与 nft compatibility frontends，并在打包前默认执行 `upx --best --lzma` 压缩可执行文件。

## 快速调用

默认静态编译 legacy + nft：

```bash
# https://www.netfilter.org/projects/iptables/downloads.html
# https://www.netfilter.org/projects/libnftnl/downloads.html
# https://www.netfilter.org/projects/libmnl/downloads.html

mkdir -p /tmp/tools-build-scripts/iptables
cd /tmp/tools-build-scripts/iptables
wget https://www.netfilter.org/projects/iptables/files/iptables-1.8.13.tar.xz
tar -xvf iptables-1.8.13.tar.xz

mkdir -p /tmp/tools-build-scripts/libmnl
cd /tmp/tools-build-scripts/libmnl
wget https://netfilter.org/projects/libmnl/files/libmnl-1.0.5.tar.bz2
tar -xjf libmnl-1.0.5.tar.bz2

mkdir -p /tmp/tools-build-scripts/libnftnl
cd /tmp/tools-build-scripts/libnftnl
wget https://www.netfilter.org/projects/libnftnl/files/libnftnl-1.3.1.tar.xz
tar -xvf libnftnl-1.3.1.tar.xz

cd /tmp/tools-build-scripts/iptables

./build-arm-iptables.sh \
  --source /tmp/tools-build-scripts/iptables/iptables-1.8.13 \
  --libmnl-src /tmp/tools-build-scripts/libmnl/libmnl-1.0.5 \
  --libnftnl-src /tmp/tools-build-scripts/libnftnl/libnftnl-1.3.1 \
  --sdk /root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot \
  --target arm-buildroot-linux-gnueabi \
  --prefix /usr \
  --linkage static \
  --nft yes \
  --clean \
  2>&1 | tee build-arm-iptables.log
```

动态编译 legacy + nft：

```bash
./build-arm-iptables.sh \
  --source /tmp/tools-build-scripts/iptables/iptables-1.8.13 \
  --libmnl-src /tmp/tools-build-scripts/libmnl/libmnl-1.0.5 \
  --libnftnl-src /tmp/tools-build-scripts/libnftnl/libnftnl-1.3.1 \
  --sdk /root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot \
  --target arm-buildroot-linux-gnueabi \
  --prefix /usr \
  --linkage dynamic \
  --nft yes \
  --clean
```

只构建 legacy：

```bash
./build-arm-iptables.sh \
  --source /tmp/tools-build-scripts/iptables/iptables-1.8.13 \
  --sdk /root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot \
  --target arm-buildroot-linux-gnueabi \
  --prefix /usr \
  --linkage static \
  --nft no \
  --clean
```

## 参数说明

| 参数 | 是否必填 | 默认值 | 说明 |
| --- | --- | --- | --- |
| `--source PATH` | 否 | 脚本所在目录 | iptables 源码目录，目录内需要存在可执行的 `configure`。 |
| `--sdk PATH` | 否 | `/root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot` | Buildroot 交叉编译 SDK 根目录。脚本会在 `bin/` 或 `host/bin/` 下查找 `arm-buildroot-linux-gnueabi-gcc`。 |
| `--target TRIPLET` | 否 | `arm-buildroot-linux-gnueabi` | 交叉编译工具链 triplet。脚本会查找 `${target}-gcc`，并把产物输出到 `dist-<target>-iptables/`。 |
| `--prefix PATH` | 否 | `/opt/iptables-1.8.13` | 安装前缀，必须是绝对路径。最终压缩包会包含 `.${prefix}` 目录。 |
| \`--linkage static | dynamic\` | 否 | `static` |
| \`--link static | dynamic\` | 否 | `static` |
| \`--nft yes | no\` | 否 | `yes` |
| `--libmnl-src PATH` | `--nft yes` 时需要 | 自动查找 `../libmnl-*` | libmnl 源码目录。 |
| `--libnftnl-src PATH` | `--nft yes` 时需要 | 自动查找 `../libnftnl-*` | libnftnl 源码目录。 |
| \`--pcap-tools yes | no\` | 否 | `no` |
| `--pcap-prefix PATH` | `--pcap-tools yes` 时需要 | 无 | 目标 libpcap 安装前缀，需包含 `lib/pkgconfig/libpcap.pc` 和目标库。 |
| `--jobs N` | 否 | `nproc` 结果，失败时为 `1` | `make -j` 并行任务数。 |
| `--clean` | 否 | 不启用 | 编译前删除当前模式对应的 build、stage、deps 和 pkg-config wrapper。 |
| `--no-strip` | 否 | 不启用 | 跳过 `${TARGET}-strip --strip-unneeded`。默认会 strip。 |
| `--upx PATH` | 否 | `upx` | 指定 UPX 命令路径或命令名。默认在打包前对可执行 ARM ELF 执行 `upx --best --lzma`。 |
| `--no-upx` | 否 | 不启用 | 跳过 UPX 压缩，适合调试 UPX 兼容性或需要保留未压缩二进制时使用。 |
| `-h`, `--help` | 否 | 不适用 | 输出脚本内置帮助。 |

## 静态与动态模式

静态模式：

- 依赖库使用 `--enable-static --disable-shared`
- iptables configure 尽量启用 `--enable-static --disable-shared`
- 链接使用 `-static -static-libgcc` 和 libtool 的 `-all-static`
- 打包前会检查核心二进制是否包含 ELF interpreter 和 `DT_NEEDED`；如果仍是动态 ELF，会输出 `WARN` 但不再中断打包
- 设备上不需要额外准备 `libmnl.so`、`libnftnl.so`

动态模式：

- 依赖库使用 `--disable-static --enable-shared`
- iptables configure 尽量启用 `--disable-static --enable-shared`
- 链接时写入 rpath：`<prefix>/lib`
- nft 模式会把本次构建出的 `libmnl.so*`、`libnftnl.so*` 放入 `<prefix>/lib`
- 运行时脚本 `environment-setup.sh` 会设置 `LD_LIBRARY_PATH=<prefix>/lib`
- 打包前会输出核心二进制的 `DT_NEEDED` 依赖

## 输出内容

构建完成后，产物会放在 iptables 源码目录下：

```text
dist-<target>-iptables/
├── iptables-1.8.13-<target>-static-legacy.tar.gz
├── iptables-1.8.13-<target>-static-legacy.tar.gz.sha256
├── iptables-1.8.13-<target>-static-legacy-nft.tar.gz
├── iptables-1.8.13-<target>-static-legacy-nft.tar.gz.sha256
├── iptables-1.8.13-<target>-dynamic-legacy.tar.gz
├── iptables-1.8.13-<target>-dynamic-legacy.tar.gz.sha256
├── iptables-1.8.13-<target>-dynamic-legacy-nft.tar.gz
└── iptables-1.8.13-<target>-dynamic-legacy-nft.tar.gz.sha256
```

压缩包内主要包含：

```text
<prefix>/sbin/iptables*
<prefix>/sbin/ip6tables*
<prefix>/sbin/arptables*
<prefix>/sbin/ebtables*
<prefix>/lib/xtables/*
<prefix>/environment-setup.sh
```

动态 nft 模式还会包含：

```text
<prefix>/lib/libmnl.so*
<prefix>/lib/libnftnl.so*
```

## nft configure 说明

不同 iptables 版本的 configure 开关不完全一致。`--nft yes` 时，脚本会先构建并安装 `libmnl`、`libnftnl`，再通过 pkg-config 提供给 iptables：

```text
PKG_CONFIG_PATH=<deps>/lib/pkgconfig
PKG_CONFIG_LIBDIR=<deps>/lib/pkgconfig
```

如果当前 iptables 源码支持 `--enable-nftables`，脚本会传入该选项；如果 configure 里没有这个选项，例如你遇到的 1.8.13 情况，脚本会输出提示并依赖 libmnl/libnftnl 自动探测继续构建。最终仍会检查 `xtables-nft-multi` 是否生成；没有生成才报错。

## 部署示例

把压缩包复制到设备后执行：

```sh
tar -xzf /tmp/iptables-1.8.13-arm-buildroot-linux-gnueabi-static-legacy-nft.tar.gz -C /
. /usr/environment-setup.sh
iptables-legacy --version
iptables-nft --version
```

只构建 legacy 时：

```sh
tar -xzf /tmp/iptables-1.8.13-arm-buildroot-linux-gnueabi-static-legacy.tar.gz -C /
. /usr/environment-setup.sh
iptables-legacy --version
```

先做只读验证，确认设备内核支持 legacy/nft backend 和需要的 extensions 后，再考虑替换系统已有的 iptables 命令。

## 编译环境要求

- Buildroot SDK，默认目标前缀为 `arm-buildroot-linux-gnueabi`，可用 `--target` 覆盖
- 本机需要可执行命令：`make`、`file`、`grep`、`find`、`tar`、`sha256sum`、`pkg-config`
- 默认启用 UPX 时还需要 `upx`
- 静态模式要求 SDK sysroot 内存在 `libc.a`
