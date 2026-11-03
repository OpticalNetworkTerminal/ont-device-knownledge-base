# shellinabox HTTPS 最小版编译脚本

`build-arm-shellinabox.sh` 用于交叉编译 shellinaboxd，也就是通过浏览器访问的 Web Terminal 服务。脚本默认目标为 `arm-buildroot-linux-gnueabi`，支持通过 `--sdk` 和 `--target` 切换工具链；支持静态链接和动态链接，默认静态链接，并在打包前默认执行 `upx --best --lzma`。

脚本默认启用 SSL/TLS 和 zlib，默认关闭 PAM、utmp 和运行时动态加载，尽量减少目标系统依赖。

## 快速调用

从源码目录构建：

```bash
# https://github.com/shellinabox/shellinabox/releases
# https://openssl-library.org/source/
# https://zlib.net/

mkdir -p /tmp/tools-build-scripts/shellinabox
cd /tmp/tools-build-scripts/shellinabox
wget https://github.com/shellinabox/shellinabox/archive/refs/tags/v2.21.tar.gz -O shellinabox-2.21.tar.gz
tar -xzvf shellinabox-2.21.tar.gz

mkdir -p /tmp/tools-build-scripts/openssl
cd /tmp/tools-build-scripts/openssl
wget https://www.openssl.org/source/openssl-3.5.7.tar.gz
tar -xzvf openssl-3.5.7.tar.gz

mkdir -p /tmp/tools-build-scripts/zlib
cd /tmp/tools-build-scripts/zlib
wget https://zlib.net/zlib-1.3.2.tar.gz
tar -xzvf zlib-1.3.2.tar.gz

cd /tmp/tools-build-scripts/shellinabox

./build-arm-shellinabox.sh \
  --source /tmp/tools-build-scripts/shellinabox/shellinabox-2.21 \
  --openssl-src /tmp/tools-build-scripts/openssl/openssl-3.5.7 \
  --zlib-src /tmp/tools-build-scripts/zlib/zlib-1.3.2 \
  --openssl-target linux-armv4 \
  --sdk /root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot \
  --target arm-buildroot-linux-gnueabi \
  --prefix /usr \
  --linkage static \
  --clean \
  2>&1 | tee build-arm-shellinabox.log
```

从 release 压缩包构建：

```bash
./build-arm-shellinabox.sh \
  --package /tmp/tools-build-scripts/shellinabox/shellinabox-2.21.tar.gz \
  --openssl-src /tmp/tools-build-scripts/openssl/openssl-3.5.7 \
  --zlib-src /tmp/tools-build-scripts/zlib/zlib-1.3.2 \
  --sdk /root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot \
  --target arm-buildroot-linux-gnueabi \
  --clean
```

动态编译：

```bash
./build-arm-shellinabox.sh \
  --source /tmp/tools-build-scripts/shellinabox/shellinabox-2.21 \
  --openssl-src /tmp/tools-build-scripts/openssl/openssl-3.5.7 \
  --zlib-src /tmp/tools-build-scripts/zlib/zlib-1.3.2 \
  --linkage dynamic \
  --clean
```

不启用 HTTPS，仅编译 HTTP 版本：

```bash
./build-arm-shellinabox.sh \
  --source /tmp/tools-build-scripts/shellinabox/shellinabox-2.21 \
  --zlib-src /tmp/tools-build-scripts/zlib/zlib-1.3.2 \
  --ssl no \
  --clean
```

## 参数说明

| 参数 | 是否必填 | 默认值 | 说明 |
| --- | --- | --- | --- |
| `--source PATH` | 否 | 当前工作目录 | shellinabox 源码目录，可替代 `--package`。如果目录内没有 `configure`，脚本会执行 `autoreconf -fi`。 |
| `--package PATH` | 否 | 无 | shellinabox release tarball，可替代 `--source`。 |
| `--openssl-src PATH` | SSL 启用时必填 | 无 | OpenSSL 源码目录，目录内需要存在 `Configure`。 |
| `--zlib-src PATH` | zlib 启用时必填 | 无 | zlib 源码目录，目录内需要存在 `configure`。 |
| `--openssl-target NAME` | 否 | `linux-armv4` | OpenSSL `Configure` platform。ARM32 Buildroot GNU EABI 常用 `linux-armv4`；AArch64 常用 `linux-aarch64`。 |
| `--sdk PATH` | 否 | `/root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot` | Buildroot SDK 根目录。脚本会在 `$sdk/bin` 或 `$sdk/host/bin` 查找 `${target}-gcc`。 |
| `--target TRIPLET` | 否 | `arm-buildroot-linux-gnueabi` | 交叉编译工具链 triplet，例如 `aarch64-buildroot-linux-gnu`、`mips-linux-gnu`。 |
| `--prefix PATH` | 否 | `/usr` | 目标安装前缀，必须是绝对路径。 |
| `--linkage static|dynamic` | 否 | `static` | 链接模式。 |
| `--link static|dynamic` | 否 | `static` | `--linkage` 的兼容别名。 |
| `--ssl yes|no` | 否 | `yes` | 是否编译 SSL/TLS 支持。`yes` 时需要 `--openssl-src`。 |
| `--zlib yes|no` | 否 | `yes` | 是否编译 zlib 压缩支持。`yes` 时需要 `--zlib-src`。 |
| `--pam yes|no` | 否 | `no` | 是否启用 PAM。多数轻量固件没有 PAM，默认关闭。 |
| `--runtime-loading yes|no` | 否 | `no` | 是否启用 shellinabox 对 OpenSSL/PAM 的运行时加载。静态最小版建议保持 `no`。 |
| `--utmp yes|no` | 否 | `no` | 是否启用登录记录。musl 或精简系统建议关闭。 |
| `--login yes|no` | 否 | `yes` | 是否启用 `LOGIN` service，即调用 `/bin/login`。 |
| `--listen IP` | 否 | 空 | 写入 `start-shellinabox.sh` 的默认监听策略。空、`0.0.0.0`、`::` 表示全接口；`127.0.0.1`、`localhost`、`::1` 表示仅本机。shellinaboxd 不支持任意指定某一个非回环 IP。 |
| `--port PORT` | 否 | `4200` | 写入 `start-shellinabox.sh` 的默认端口。 |
| `--service SERVICE` | 否 | `/:LOGIN` | 写入启动脚本的默认 service。常用值有 `/:LOGIN`、`/:SSH`、`/:SSH:192.168.1.1`、`/:root:root:/:/bin/sh`。 |
| `--cert-dir PATH` | 否 | `/etc/shellinabox` | SSL 证书目录。运行时可放 `certificate.pem`，或让 shellinaboxd 尝试生成自签证书。 |
| `--pidfile PATH` | 否 | `/tmp/shellinaboxd.pid` | PID 文件路径。 |
| `--user USER` | 否 | 空 | shellinaboxd 启动后降权到指定用户。 |
| `--group GROUP` | 否 | 空 | shellinaboxd 启动后降权到指定用户组。 |
| `--jobs N` | 否 | `nproc` 结果，失败时为 `1` | `make -j` 并行任务数。 |
| `--clean` | 否 | 不启用 | 编译前删除当前目标和链接模式的工作目录。 |
| `--no-strip` | 否 | 不启用 | 跳过 `${TARGET}-strip --strip-unneeded`。 |
| `--upx PATH` | 否 | `upx` | 指定 UPX 命令路径或命令名。 |
| `--no-upx` | 否 | 不启用 | 跳过 UPX 压缩。 |
| `-h`, `--help` | 否 | 不适用 | 输出脚本内置帮助。 |

## 最小 HTTPS 依赖

shellinaboxd 最小 HTTPS 版依赖：

```text
shellinaboxd
├── OpenSSL
│   ├── libssl
│   └── libcrypto
└── zlib
```

静态模式还需要 SDK sysroot 中存在：

```text
libc.a
libpthread.a
libdl.a
libutil.a（glibc 工具链常见；脚本会自动探测是否需要 `-lutil`）
```

PAM 不是最小版必需项，默认关闭。如果要用 PAM 认证，目标系统需要有对应 PAM 库和配置，并传入 `--pam yes`。

shellinabox 会调用 `openpty()` / `login_tty()` 创建伪终端。glibc 交叉工具链里这两个符号通常来自 `libutil`，脚本会先尝试 libc，再尝试 `-lutil`。如果两者都失败，说明当前 SDK 缺少 PTY 相关运行库。

如果静态模式下最终校验提示 `has PT_INTERP` 或 `has DT_NEEDED`，说明最终产物实际仍依赖动态链接器或共享库。脚本会输出 `WARN`，但不再中断打包；同时仍会在 configure、make、install 三个阶段显式传入 `CCLD="${target}-gcc -static ..."`，尽量推动 shellinabox 的 Makefile 使用静态链接参数。

## 输出内容

构建完成后，产物会放在 shellinabox 源码目录或 package 所在目录下：

```text
dist-<target>-shellinabox/
├── shellinabox-<version>-<target>-static.tar.gz
├── shellinabox-<version>-<target>-static.tar.gz.sha256
├── shellinabox-<version>-<target>-dynamic.tar.gz
└── shellinabox-<version>-<target>-dynamic.tar.gz.sha256
```

压缩包内包含：

```text
<prefix>/bin/shellinaboxd
<prefix>/start-shellinabox.sh
<cert-dir>/
```

动态模式会额外打包：

```text
<prefix>/lib/libssl.so*
<prefix>/lib/libcrypto.so*
<prefix>/lib/libz.so*
```

## 部署和启动

```sh
tar -xzf /tmp/shellinabox-<version>-arm-buildroot-linux-gnueabi-static.tar.gz -C /
/usr/start-shellinabox.sh --listen 0.0.0.0 --port 4200
```

仅本机监听，适合反向代理：

```sh
/usr/start-shellinabox.sh --listen 127.0.0.1 --port 4200
```

HTTP 明文模式：

```sh
/usr/start-shellinabox.sh --disable-ssl --listen 0.0.0.0 --port 4200
```

指定 SSH service：

```sh
/usr/start-shellinabox.sh --service '/:SSH:192.168.1.1'
```

指定直接执行 `/bin/sh`：

```sh
/usr/start-shellinabox.sh --service '/:root:root:/:/bin/sh'
```

## 证书说明

启用 SSL 时，shellinaboxd 会从 `--cert-dir` 指定目录读取证书。通用证书文件名是：

```text
/etc/shellinabox/certificate.pem
```

如果目录可写且目标系统有 `/usr/bin/openssl`，shellinaboxd 可能会自动生成自签证书。更稳妥的方式是在设备上提前放入 `certificate.pem`。

## 编译环境要求

- Buildroot SDK，默认目标前缀为 `arm-buildroot-linux-gnueabi`，可用 `--target` 覆盖
- 本机需要可执行命令：`make`、`file`、`tar`、`sha256sum`
- 源码没有 `configure` 时需要 `autoreconf`、`automake`、`autoconf`、`libtoolize`
- 默认启用 SSL 时需要本机 `perl` 来构建 OpenSSL
- 默认启用 UPX 时还需要 `upx`
