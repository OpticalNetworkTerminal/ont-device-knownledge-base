# Mongoose 最小版编译脚本

`build-arm-mongoose.sh` 用于交叉编译 [cesanta/mongoose](https://github.com/cesanta/mongoose)。Mongoose 官方主要交付形式是 `mongoose.c` + `mongoose.h`，适合嵌入到自己的程序里；这个脚本会额外编译一个很小的 `mongoose-httpd` 文件服务器，方便把产物放到设备上直接验证 HTTP/HTTPS。

脚本默认目标为 `arm-buildroot-linux-gnueabi`，支持通过 `--sdk` 和 `--target` 切换工具链；支持静态链接和动态链接，默认静态链接，并在打包前默认执行 `upx --best --lzma`。

## 快速调用

默认静态编译，使用 Mongoose 内置 TLS：

```bash
# https://github.com/cesanta/mongoose
# https://github.com/cesanta/mongoose/releases

mkdir -p /tmp/tools-build-scripts/mongoose
cd /tmp/tools-build-scripts/mongoose
wget https://github.com/cesanta/mongoose/archive/refs/tags/7.22.tar.gz -O mongoose-7.22.tar.gz
tar -xzvf mongoose-7.22.tar.gz

./build-arm-mongoose.sh \
  --source /tmp/tools-build-scripts/mongoose/mongoose-7.22 \
  --sdk /root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot \
  --target arm-buildroot-linux-gnueabi \
  --prefix /usr \
  --linkage static \
  --tls builtin \
  --listen http://0.0.0.0:8000 \
  --root-dir /tmp/www \
  --clean \
  2>&1 | tee build-arm-mongoose.log
```

从 GitHub release/source 压缩包构建：

```bash
./build-arm-mongoose.sh \
  --package /tmp/tools-build-scripts/mongoose/mongoose-7.22.tar.gz \
  --sdk /root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot \
  --target arm-buildroot-linux-gnueabi \
  --clean
```

动态编译：

```bash
./build-arm-mongoose.sh \
  --source /tmp/tools-build-scripts/mongoose/mongoose-7.22 \
  --linkage dynamic \
  --tls builtin \
  --clean
```

不启用 TLS，只做 HTTP：

```bash
./build-arm-mongoose.sh \
  --source /tmp/tools-build-scripts/mongoose/mongoose-7.22 \
  --tls none \
  --listen http://0.0.0.0:8000 \
  --clean
```

使用外部 OpenSSL：

```bash
./build-arm-mongoose.sh \
  --source /tmp/tools-build-scripts/mongoose/mongoose-7.22 \
  --tls openssl \
  --openssl-prefix /tmp/tools-build-scripts/openssl/dist-arm-buildroot-linux-gnueabi \
  --clean
```

## 参数说明

| 参数 | 是否必填 | 默认值 | 说明 |
| --- | --- | --- | --- |
| `--source PATH` | 否 | 当前工作目录 | Mongoose 源码目录，目录内需要存在 `mongoose.c` 和 `mongoose.h`。 |
| `--package PATH` | 否 | 无 | 从源码压缩包构建，可替代 `--source`。支持常见 tarball，也支持 zip。 |
| `--sdk PATH` | 否 | `/root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot` | Buildroot SDK 根目录。脚本会在 `$sdk/bin` 或 `$sdk/host/bin` 查找 `${target}-gcc`。 |
| `--target TRIPLET` | 否 | `arm-buildroot-linux-gnueabi` | 交叉编译工具链 triplet，例如 `aarch64-buildroot-linux-gnu`、`mips-linux-gnu`。 |
| `--prefix PATH` | 否 | `/usr` | 目标安装前缀，必须是绝对路径。 |
| `--linkage static\|dynamic` | 否 | `static` | 链接模式。静态模式会生成静态链接的 `mongoose-httpd`；动态模式会额外打包 `libmongoose.so`。 |
| `--link static\|dynamic` | 否 | `static` | `--linkage` 的兼容别名。 |
| `--tls none\|builtin\|openssl` | 否 | `builtin` | TLS 后端。`none` 不支持 HTTPS；`builtin` 使用 Mongoose 内置 TLS，不依赖 OpenSSL；`openssl` 使用外部 OpenSSL。 |
| `--openssl-prefix PATH` | OpenSSL TLS 时必填 | 无 | 外部 OpenSSL 安装前缀，下面需要有 `include/` 和 `lib/`。仅 `--tls openssl` 使用。 |
| `--mg-arch NAME` | 否 | `MG_ARCH_UNIX` | 手动指定 `MG_ARCH`。Linux/Buildroot 使用 `MG_ARCH_UNIX`；如果后续换到裸机、FreeRTOS、Zephyr 等平台，需要按 Mongoose 支持的架构宏调整。 |
| `--ipv6 yes\|no` | 否 | `no` | 是否定义 `MG_ENABLE_IPV6=1`。 |
| `--posix-fs yes\|no` | 否 | `yes` | 是否启用 POSIX 文件系统。脚本内置的 `mongoose-httpd` 需要它，所以当前只能保持 `yes`。 |
| `--listen URL` | 否 | `http://0.0.0.0:8000` | 写入 `start-mongoose-httpd.sh` 的默认监听地址。HTTP 示例用 `http://0.0.0.0:8000`；HTTPS 示例用 `https://0.0.0.0:8443`。 |
| `--root-dir PATH` | 否 | `/tmp/www` | 文件服务器默认根目录。脚本会打包一个测试 `index.html`。 |
| `--cert-file PATH` | 否 | `/etc/mongoose/certificate.pem` | HTTPS 证书文件路径。运行 HTTPS 时需要设备上存在该文件。 |
| `--key-file PATH` | 否 | `/etc/mongoose/key.pem` | HTTPS 私钥文件路径。运行 HTTPS 时需要设备上存在该文件。 |
| `--jobs N` | 否 | `nproc` 结果，失败时为 `1` | 保留参数，方便和其他脚本统一；Mongoose 本身是单文件编译，实际不会并行 make。 |
| `--clean` | 否 | 不启用 | 编译前删除当前目标和链接模式的工作目录。 |
| `--no-strip` | 否 | 不启用 | 跳过 `${TARGET}-strip --strip-unneeded`。 |
| `--upx PATH` | 否 | `upx` | 指定 UPX 命令路径或命令名。 |
| `--no-upx` | 否 | 不启用 | 跳过 UPX 压缩。 |
| `-h`, `--help` | 否 | 不适用 | 输出脚本内置帮助。 |

## TLS 依赖说明

默认 `--tls builtin`：

```text
mongoose-httpd
└── Mongoose built-in TLS
```

这种模式不依赖 OpenSSL，比较适合做最小版设备验证。

`--tls none`：

```text
mongoose-httpd
└── HTTP only
```

这种模式不能监听 `https://`。

`--tls openssl`：

```text
mongoose-httpd
├── libmongoose
└── OpenSSL
    ├── libssl
    └── libcrypto
```

这种模式需要提前准备目标架构可用的 OpenSSL，并通过 `--openssl-prefix` 指向它。脚本不会自动编译 OpenSSL。

静态模式至少需要 SDK sysroot 中存在：

```text
libc.a
```

脚本会使用 `-std=gnu99`，并定义 `_GNU_SOURCE`、`_DEFAULT_SOURCE`、`_BSD_SOURCE`、`_POSIX_C_SOURCE=200809L`，用于打开 glibc/uClibc 中的 `struct ip_mreq`、`struct timespec`、`clock_gettime()`、`strdup()` 等接口。部分老 glibc 工具链中 `clock_gettime()` 需要 `librt`，脚本会自动探测并在需要时追加 `-lrt`。

如果静态模式下最终产物仍出现 `PT_INTERP` 或 `DT_NEEDED`，脚本会输出 `WARN`，但不再中断打包。此时产物可继续测试运行，但实际依赖目标系统中的动态链接器和对应 `.so`。

## 输出内容

构建完成后，产物会放在 Mongoose 源码目录或 package 所在目录下：

```text
dist-<target>-mongoose/
├── mongoose-<version>-<target>-static-tls-builtin.tar.gz
├── mongoose-<version>-<target>-static-tls-builtin.tar.gz.sha256
├── mongoose-<version>-<target>-dynamic-tls-builtin.tar.gz
└── mongoose-<version>-<target>-dynamic-tls-builtin.tar.gz.sha256
```

压缩包内包含：

```text
<prefix>/include/mongoose.h
<prefix>/include/mongoose.c
<prefix>/lib/libmongoose.a
<prefix>/bin/mongoose-httpd
<prefix>/start-mongoose-httpd.sh
<root-dir>/index.html
/etc/mongoose/
```

动态模式会额外包含：

```text
<prefix>/lib/libmongoose.so
```

## 部署和启动

HTTP：

```sh
tar -xzf /tmp/mongoose-<version>-arm-buildroot-linux-gnueabi-static-tls-builtin.tar.gz -C /
/usr/start-mongoose-httpd.sh --listen http://0.0.0.0:8000 --root /tmp/www
```

HTTPS：

```sh
/usr/start-mongoose-httpd.sh \
  --listen https://0.0.0.0:8443 \
  --root /tmp/www \
  --cert /etc/mongoose/certificate.pem \
  --key /etc/mongoose/key.pem
```

快速生成测试证书：

```sh
mkdir -p /etc/mongoose
openssl req -x509 -newkey rsa:2048 -nodes \
  -keyout /etc/mongoose/key.pem \
  -out /etc/mongoose/certificate.pem \
  -days 365 \
  -subj '/CN=mongoose'
```

访问测试：

```sh
curl http://192.168.1.1:8000/
curl -k https://192.168.1.1:8443/
```

## 编译环境要求

- Buildroot SDK，默认目标前缀为 `arm-buildroot-linux-gnueabi`，可用 `--target` 覆盖
- 本机需要可执行命令：`${target}-gcc`、`${target}-ar`、`${target}-ranlib`、`${target}-strip`、`${target}-readelf`、`file`、`tar`、`sha256sum`
- 如果 `--package` 是 zip，还需要 `unzip`
- 默认启用 UPX 时还需要 `upx`
