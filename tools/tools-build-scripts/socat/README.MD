# socat 最小版编译脚本

`build-arm-socat.sh` 用于交叉编译 ARM Buildroot GNU EABI 环境可用的 socat。默认目标为 `arm-buildroot-linux-gnueabi`，支持指定 SDK、target、静态/动态链接，默认打包前执行 `upx --best --lzma`。

默认最小配置关闭 OpenSSL、readline、tcp-wrappers，保留常用的 file、pipe、UNIX socket、IPv4/IPv6、TCP/UDP、listen、exec、pty、TUN/TAP 等能力。

## 快速调用

```bash
# http://www.dest-unreach.org/socat/
# http://www.dest-unreach.org/socat/download/

mkdir -p /tmp/tools-build-scripts/socat
cd /tmp/tools-build-scripts/socat
wget http://www.dest-unreach.org/socat/download/socat-1.8.1.3.tar.bz2
tar -xjf socat-1.8.1.3.tar.bz2

./build-arm-socat.sh \
  --source /tmp/tools-build-scripts/socat/socat-1.8.1.3 \
  --sdk /root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot \
  --target arm-buildroot-linux-gnueabi \
  --prefix /usr \
  --linkage static \
  --clean \
  2>&1 | tee build-arm-socat.log
```

动态编译：

```bash
./build-arm-socat.sh \
  --source /tmp/tools-build-scripts/socat/socat-1.8.1.3 \
  --linkage dynamic \
  --clean
```

启用 OpenSSL：

```bash
./build-arm-socat.sh \
  --source /tmp/tools-build-scripts/socat/socat-1.8.1.3 \
  --openssl yes \
  --openssl-dir /tmp/tools-build-scripts/openssl/openssl-3.5.7/.arm-buildroot-linux-gnueabi-openssl-static/install/usr \
  --clean
```

## 参数说明

| 参数 | 默认值 | 说明 |
| --- | --- | --- |
| `--source PATH` | 当前目录 | socat 源码目录。 |
| `--sdk PATH` | `/root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot` | Buildroot SDK 根目录。 |
| `--target TRIPLET` | `arm-buildroot-linux-gnueabi` | 交叉工具链 triplet。 |
| `--prefix PATH` | `/usr` | 目标安装前缀。 |
| `--linkage static\|dynamic` | `static` | 链接模式。 |
| `--ipv6 yes\|no` | `yes` | 是否保留 IPv6。 |
| `--openssl yes\|no` | `no` | 是否启用 SSL 地址类型。 |
| `--openssl-dir PATH` | 空 | OpenSSL 安装前缀，目录下需要有 `include/` 和 `lib/`。 |
| `--readline yes\|no` | `no` | 是否启用 readline。 |
| `--libwrap yes\|no` | `no` | 是否启用 tcp-wrappers/libwrap。 |
| `--jobs N` | CPU 数 | `make -j` 并行数。 |
| `--clean` | 否 | 构建前删除工作目录。 |
| `--no-strip` | 否 | 跳过 strip。 |
| `--upx PATH` | `upx` | 指定 UPX 命令。 |
| `--no-upx` | 否 | 跳过 UPX 压缩。 |

## 依赖

最小版主要依赖 libc。启用 OpenSSL 后依赖 `libssl`、`libcrypto`，静态链接时通常还需要 `zlib`、`dl`、`pthread`。

## 部署验证

```sh
tar -xzf socat-1.8.1.3-arm-buildroot-linux-gnueabi-static.tar.gz -C /
. /usr/environment-setup.sh
socat -V
socat - TCP:127.0.0.1:80
```
