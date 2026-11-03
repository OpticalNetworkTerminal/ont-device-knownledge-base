# ARM Dropbear 编译脚本

`build-arm-dropbear.sh` 用于交叉编译 ARM Buildroot GNU EABI 环境可用的 Dropbear multicall 二进制。脚本支持静态链接和动态链接，默认静态链接，并在打包前默认执行 `upx --best --lzma` 压缩。

## 快速调用

默认静态编译：

```bash
# https://matt.ucc.asn.au/dropbear/
# https://matt.ucc.asn.au/dropbear/releases/

mkdir -p /tmp/tools-build-scripts/dropbear
cd /tmp/tools-build-scripts/dropbear
wget https://matt.ucc.asn.au/dropbear/releases/dropbear-2026.92.tar.bz2
tar -xjf dropbear-2026.92.tar.bz2

./build-arm-dropbear.sh \
  --source /tmp/tools-build-scripts/dropbear/dropbear-2026.92 \
  --sdk /root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot \
  --target arm-buildroot-linux-gnueabi \
  --prefix /usr \
  --sysconfdir /etc/dropbear \
  --sftp-server /usr/libexec/sftp-server \
  --authorized-keys /root/.ssh/authorized_keys \
  --clean \
  2>&1 | tee build-arm-dropbear.log
```

动态编译：

```bash
./build-arm-dropbear.sh \
  --source /tmp/tools-build-scripts/dropbear/dropbear-2026.92 \
  --sdk /root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot \
  --target arm-buildroot-linux-gnueabi \
  --prefix /usr \
  --linkage dynamic \
  --clean
```

也可以直接从源码压缩包构建：

```bash
./build-arm-dropbear.sh \
  --package /tmp/tools-build-scripts/dropbear/dropbear-2026.92.tar.bz2 \
  --sdk /root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot \
  --target arm-buildroot-linux-gnueabi \
  --prefix /usr \
  --clean
```

## 参数说明

| 参数 | 是否必填 | 默认值 | 说明 |
| --- | --- | --- | --- |
| `--source PATH` | 否 | 当前工作目录 | Dropbear 源码目录，目录内需要存在 `configure`。 |
| `--package PATH` | 否 | 无 | 从 Dropbear tarball 解压后构建，可替代 `--source`。 |
| `--sdk PATH` | 否 | `/root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot` | Buildroot 交叉编译 SDK 根目录。 |
| `--target TRIPLET` | 否 | `arm-buildroot-linux-gnueabi` | 交叉编译工具链 triplet。脚本会查找 `${target}-gcc`，并把产物输出到 `dist-<target>-dropbear/`。 |
| `--prefix PATH` | 否 | `/usr` | 安装前缀，必须是绝对路径。 |
| \`--linkage static | dynamic\` | 否 | `static` |
| \`--link static | dynamic\` | 否 | `static` |
| `--sysconfdir PATH` | 否 | `/etc/dropbear` | Dropbear 配置目录，也是默认 host key 目录。 |
| `--hostkey-dir PATH` | 否 | `--sysconfdir` | `generate-host-keys.sh` 和 `start-dropbear.sh` 默认使用的 host key 目录。 |
| `--authorized-keys PATH` | 否 | `<root-home>/.ssh/authorized_keys` | 启动脚本默认使用的 root authorized_keys 文件路径。Dropbear 实际接收的是该文件所在目录，即启动参数 `-D <dir>`。 |
| `--root-home PATH` | 否 | `/root` | 启动脚本用于准备 `.ssh/authorized_keys` 的 root home。需和设备 `/etc/passwd` 中 root home 一致。 |
| `--sftp-server PATH` | 否 | `<prefix>/libexec/sftp-server` | 写入 `localoptions.h` 的外部 SFTP server 路径。Dropbear 自身不提供 SFTP server。 |
| `--listen IP` | 否 | 不绑定固定 IP | 写入 `start-dropbear.sh` 默认值。启动时也可覆盖。 |
| `--port PORT` | 否 | `22` | 写入 `start-dropbear.sh` 默认值。 |
| `--pidfile PATH` | 否 | `/tmp/dropbear.pid` | Dropbear PID 文件路径。 |
| \`--password-auth yes | no\` | 否 | `no` |
| \`--root-password-auth yes | no\` | 否 | `no` |
| \`--zlib auto | yes | no\` | 否 |
| `--jobs N` | 否 | `nproc` 结果，失败时为 `1` | `make -j` 并行任务数。 |
| `--clean` | 否 | 不启用 | 编译前删除 `.<target>-dropbear-static` 或 `.<target>-dropbear-dynamic` 工作目录。 |
| `--no-strip` | 否 | 不启用 | 跳过 `${TARGET}-strip --strip-unneeded`。 |
| `--upx PATH` | 否 | `upx` | 指定 UPX 命令路径或命令名。 |
| `--no-upx` | 否 | 不启用 | 跳过 UPX 压缩。 |
| `-h`, `--help` | 否 | 不适用 | 输出脚本内置帮助。 |

## SFTP 与认证

Dropbear 不内置 SFTP server，只能调用外部 `sftp-server`。脚本会生成 `localoptions.h` 并把 `SFTPSERVER_PATH` 设置为 `--sftp-server` 指定的路径，默认是：

```text
<prefix>/libexec/sftp-server
```

如果设备上的实际路径不同，启动时可以用：

```sh
/usr/start-dropbear.sh --sftp-server /usr/libexec/sftp-server
```

启动脚本会把编译期路径软链到实际路径。前提是目标文件系统允许创建该软链。

注意：`--sftp-server` 只指定 Dropbear 调用外部 SFTP server 的路径，不会自动编译或打包 `sftp-server`。如果客户端使用 SFTP 协议，例如 OpenSSH 9.0 之后默认的 `scp`，目标设备上必须真实存在：

```text
<prefix>/libexec/sftp-server
```

可以从 OpenSSH 构建产物里复制 `sftp-server` 到该路径。否则有两种选择：

```sh
# 方式 1：使用 OpenSSH 客户端强制老 scp 协议
scp -O localfile root@192.168.1.1:/tmp/

# 方式 2：在目标设备上确认 Dropbear 打包的 scp 可被 shell 找到
which scp
```

`start-dropbear.sh` 会在启动 Dropbear 前把 `<prefix>/bin` 和 `<prefix>/sbin` 加到 `PATH`，所以使用 `--prefix /usr/sbin/apps` 时，远端 shell 通常能找到：

```text
/usr/sbin/apps/bin/scp
```

如果设备登录 shell 会重置 PATH，可以额外创建软链：

```sh
ln -sf /usr/sbin/apps/bin/scp /usr/bin/scp
```

如果不传 `--authorized-keys`，脚本默认按 Dropbear/OpenSSH 常见行为使用：

```text
/root/.ssh/authorized_keys
```

如果同时传了 `--root-home PATH` 但没有传 `--authorized-keys`，默认路径会变成：

```text
<root-home>/.ssh/authorized_keys
```

Dropbear 2026.92 服务端支持 `-D DIR` 参数，含义是 authorized_keys 所在目录。脚本会把 `--authorized-keys /path/to/authorized_keys` 转成：

```sh
dropbear ... -D /path/to
```

也就是说你传：

```sh
--authorized-keys /usr/sbin/apps/etc/ssh/authorized_keys
```

启动脚本会让 Dropbear 读取：

```text
/usr/sbin/apps/etc/ssh/authorized_keys
```

注意文件名仍然必须是 `authorized_keys`。如果传入的文件名不是 `authorized_keys`，启动脚本会尝试在同目录创建一个 `authorized_keys` 软链。

打包出的配置文件也会写入该路径：

```text
<sysconfdir>/dropbear.conf
```

`start-dropbear.sh` 启动时会读取该配置文件，启动命令行参数优先级最高。

## 输出内容

构建完成后，产物会放在 Dropbear 源码目录下：

```text
dist-<target>-dropbear/
├── dropbear-<version>-<target>-static.tar.gz
├── dropbear-<version>-<target>-static.tar.gz.sha256
├── dropbear-<version>-<target>-dynamic.tar.gz
└── dropbear-<version>-<target>-dynamic.tar.gz.sha256
```

压缩包内会包含：

```text
<prefix>/bin/dropbearmulti
<prefix>/bin/dbclient
<prefix>/bin/dropbearkey
<prefix>/bin/dropbearconvert
<prefix>/bin/scp
<prefix>/sbin/dropbear
<prefix>/generate-host-keys.sh
<prefix>/start-dropbear.sh
<sysconfdir>/dropbear.conf
```

## 部署示例

```sh
tar -xzf /tmp/dropbear-<version>-arm-buildroot-linux-gnueabi-static.tar.gz -C /
/usr/generate-host-keys.sh
/usr/start-dropbear.sh --listen 192.168.1.1 --port 2224
```

只使用默认端口：

```sh
/usr/start-dropbear.sh
```

## 编译环境要求

- Buildroot SDK，默认目标前缀为 `arm-buildroot-linux-gnueabi`，可用 `--target` 覆盖
- 本机需要可执行命令：`make`、`file`、`tar`、`sha256sum`
- 默认启用 UPX 时还需要 `upx`
- 静态模式要求 SDK sysroot 内存在 `libc.a`
