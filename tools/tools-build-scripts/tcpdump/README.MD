# tcpdump 最小版编译脚本

`build-arm-tcpdump.sh` 用于交叉编译 ARM Buildroot GNU EABI 环境可用的 tcpdump。脚本会先交叉编译 libpcap，再编译 tcpdump；默认目标为 `arm-buildroot-linux-gnueabi`，支持通过 `--sdk` 和 `--target` 切换工具链；支持静态链接和动态链接，默认静态链接，并在打包前默认执行 `upx --best --lzma`。

默认构建最小抓包版本：libpcap 使用 Linux pcap 后端，关闭 remote、libnl、USB、Bluetooth、D-Bus、RDMA、netmap 等可选能力；tcpdump 默认关闭 libsmi、crypto、SMB printer。

## 快速调用

默认静态编译：

```bash
# https://www.tcpdump.org/
# https://www.tcpdump.org/release/

mkdir -p /tmp/tools-build-scripts/tcpdump
cd /tmp/tools-build-scripts/tcpdump
wget https://www.tcpdump.org/release/tcpdump-4.99.5.tar.xz
tar -xvf tcpdump-4.99.5.tar.xz

mkdir -p /tmp/tools-build-scripts/libpcap
cd /tmp/tools-build-scripts/libpcap
wget https://www.tcpdump.org/release/libpcap-1.10.5.tar.xz
tar -xvf libpcap-1.10.5.tar.xz

cd /tmp/tools-build-scripts/tcpdump

./build-arm-tcpdump.sh \
  --source /tmp/tools-build-scripts/tcpdump/tcpdump-4.99.5 \
  --libpcap-src /tmp/tools-build-scripts/libpcap/libpcap-1.10.5 \
  --sdk /root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot \
  --target arm-buildroot-linux-gnueabi \
  --prefix /usr \
  --linkage static \
  --clean \
  2>&1 | tee build-arm-tcpdump.log
```

动态编译：

```bash
./build-arm-tcpdump.sh \
  --source /tmp/tools-build-scripts/tcpdump/tcpdump-4.99.5 \
  --libpcap-src /tmp/tools-build-scripts/libpcap/libpcap-1.10.5 \
  --sdk /root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot \
  --target arm-buildroot-linux-gnueabi \
  --prefix /usr \
  --linkage dynamic \
  --clean
```

开启 IPv6、指定抓包后降权用户：

```bash
./build-arm-tcpdump.sh \
  --source /tmp/tools-build-scripts/tcpdump/tcpdump-4.99.5 \
  --libpcap-src /tmp/tools-build-scripts/libpcap/libpcap-1.10.5 \
  --ipv6 yes \
  --user nobody \
  --clean
```

## 参数说明

| 参数 | 是否必填 | 默认值 | 说明 |
| --- | --- | --- | --- |
| `--source PATH` | 否 | 当前工作目录 | tcpdump 源码目录，目录内需要存在 `configure`。 |
| `--libpcap-src PATH` | 否 | 自动查找 tcpdump 源码同级 `libpcap-*` | libpcap 源码目录，目录内需要存在 `configure`。 |
| `--sdk PATH` | 否 | `/root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot` | Buildroot SDK 根目录。脚本会在 `$sdk/bin` 或 `$sdk/host/bin` 查找 `${target}-gcc`。 |
| `--target TRIPLET` | 否 | `arm-buildroot-linux-gnueabi` | 交叉编译工具链 triplet，例如 `aarch64-buildroot-linux-gnu`、`mips-linux-gnu`。 |
| `--prefix PATH` | 否 | `/usr` | 目标安装前缀，必须是绝对路径。 |
| `--linkage static\|dynamic` | 否 | `static` | 链接模式。动态模式会额外打包 `libpcap.so*`。 |
| `--link static\|dynamic` | 否 | `static` | `--linkage` 的兼容别名。 |
| `--pcap-type TYPE` | 否 | `linux` | 传给 libpcap `--with-pcap=TYPE`。Linux/Buildroot 目标通常使用 `linux`。 |
| `--ipv6 yes\|no` | 否 | `yes` | 是否启用 libpcap IPv6 支持。 |
| `--remote yes\|no` | 否 | `no` | 是否启用 libpcap remote packet capture。最小版默认关闭。 |
| `--crypto yes\|no` | 否 | `no` | 是否让 tcpdump 链接 OpenSSL/libressl libcrypto。最小版默认关闭。 |
| `--smi yes\|no` | 否 | `no` | 是否启用 libsmi，用于 SNMP MIB 解析。最小版默认关闭。 |
| `--smb yes\|no` | 否 | `no` | 是否启用 tcpdump 的 SMB printer。上游标注为 possibly-buggy，默认关闭。 |
| `--user USER` | 否 | 无 | 写入 tcpdump 默认降权用户，对应 configure `--with-user=USER`。 |
| `--chroot PATH` | 否 | 无 | 写入 tcpdump 默认 chroot 目录，对应 configure `--with-chroot=PATH`。必须是绝对路径。 |
| `--jobs N` | 否 | `nproc` 结果，失败时为 `1` | `make -j` 并行任务数。 |
| `--clean` | 否 | 不启用 | 编译前删除当前目标和链接模式的工作目录。 |
| `--no-strip` | 否 | 不启用 | 跳过 `${TARGET}-strip --strip-unneeded`。 |
| `--upx PATH` | 否 | `upx` | 指定 UPX 命令路径或命令名。 |
| `--no-upx` | 否 | 不启用 | 跳过 UPX 压缩。 |
| `-h`, `--help` | 否 | 不适用 | 输出脚本内置帮助。 |

## 依赖说明

tcpdump 最小版依赖：

```text
tcpdump
└── libpcap
```

静态模式至少需要 SDK sysroot 中存在：

```text
libc.a
```

脚本会先把 libpcap 安装到内部依赖目录：

```text
.<target>-tcpdump-<linkage>/deps
```

然后用该目录的 `include/`、`lib/`、`pkgconfig/` 来编译 tcpdump。动态模式会把 `libpcap.so*` 一起打进 `<prefix>/lib`。

如果静态模式下最终产物仍出现 `PT_INTERP` 或 `DT_NEEDED`，脚本会输出 `WARN`，但不再中断打包。此时产物可继续测试运行，但实际依赖目标系统中的动态链接器和对应 `.so`。

## 输出内容

构建完成后，产物会放在 tcpdump 源码目录下：

```text
dist-<target>-tcpdump/
├── tcpdump-4.99.5-<target>-static.tar.gz
├── tcpdump-4.99.5-<target>-static.tar.gz.sha256
├── tcpdump-4.99.5-<target>-dynamic.tar.gz
└── tcpdump-4.99.5-<target>-dynamic.tar.gz.sha256
```

压缩包内主要包含：

```text
<prefix>/sbin/tcpdump
<prefix>/environment-setup.sh
```

动态模式还会包含：

```text
<prefix>/lib/libpcap.so*
```

## 部署和验证

```sh
tar -xzf /tmp/tcpdump-4.99.5-arm-buildroot-linux-gnueabi-static.tar.gz -C /
. /usr/environment-setup.sh
tcpdump --version
```

列出接口：

```sh
tcpdump -D
```

抓取指定接口和端口：

```sh
tcpdump -i eth0 -nn port 80
```

保存 pcap 文件：

```sh
tcpdump -i eth0 -s 0 -w /tmp/capture.pcap
```

读取 pcap 文件：

```sh
tcpdump -nn -r /tmp/capture.pcap
```

抓包通常需要 root 权限，或者目标系统给 tcpdump 所需的抓包能力。

## 编译环境要求

- Buildroot SDK，默认目标前缀为 `arm-buildroot-linux-gnueabi`，可用 `--target` 覆盖
- 本机需要可执行命令：`make`、`file`、`tar`、`sha256sum`、`pkg-config`
- 默认启用 UPX 时还需要 `upx`
