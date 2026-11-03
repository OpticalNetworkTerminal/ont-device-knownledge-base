# curl HTTPS 最小版编译脚本

`build-arm-curl.sh` 用于交叉编译 HTTPS 可用的最小版 curl。脚本默认目标为 `arm-buildroot-linux-gnueabi`，也可以通过 `--target` 指定其他交叉编译 triplet；支持静态链接和动态链接，默认静态链接，并在打包前默认执行 `upx --best --lzma`。

## 快速调用

静态编译：

```bash
# https://curl.se/download.html
# https://openssl-library.org/source/
# https://zlib.net/

mkdir -p /tmp/tools-build-scripts/curl
cd /tmp/tools-build-scripts/curl
wget https://curl.se/download/curl-8.21.0.tar.gz
tar -xzvf curl-8.21.0.tar.gz

mkdir -p /tmp/tools-build-scripts/openssl
cd /tmp/tools-build-scripts/openssl
wget https://www.openssl.org/source/openssl-3.5.7.tar.gz
tar -xzvf openssl-3.5.7.tar.gz

mkdir -p /tmp/tools-build-scripts/zlib
cd /tmp/tools-build-scripts/zlib
wget https://zlib.net/zlib-1.3.2.tar.gz
tar -xzvf zlib-1.3.2.tar.gz

cd /tmp/tools-build-scripts/curl

./build-arm-curl.sh \
  --source /tmp/tools-build-scripts/curl/curl-8.21.0 \
  --openssl-src /tmp/tools-build-scripts/openssl/openssl-3.5.7 \
  --zlib-src /tmp/tools-build-scripts/zlib/zlib-1.3.2 \
  --openssl-target linux-armv4 \
  --sdk /root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot \
  --target arm-buildroot-linux-gnueabi \
  --prefix /usr \
  --linkage static \
  --clean \
  2>&1 | tee build-arm-curl.log
```

动态编译：

```bash
./build-arm-curl.sh \
  --source /tmp/tools-build-scripts/curl/curl-8.21.0 \
  --openssl-src /tmp/tools-build-scripts/openssl/openssl-3.5.7 \
  --zlib-src /tmp/tools-build-scripts/zlib/zlib-1.3.2 \
  --openssl-target linux-armv4 \
  --sdk /root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot \
  --target arm-buildroot-linux-gnueabi \
  --prefix /usr \
  --linkage dynamic \
  --clean
```

## 参数说明

| 参数 | 是否必填 | 默认值 | 说明 |
| --- | --- | --- | --- |
| `--source PATH` | 否 | 当前工作目录 | curl 源码目录，目录内需要存在 `configure`。 |
| `--openssl-src PATH` | 是 | 无 | OpenSSL 源码目录。 |
| `--zlib-src PATH` | 是 | 无 | zlib 源码目录。 |
| `--openssl-target NAME` | 否 | `linux-armv4` | OpenSSL `Configure` platform。换架构时需要同步调整，例如 AArch64 常用 `linux-aarch64`。 |
| `--sdk PATH` | 否 | `/root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot` | Buildroot 交叉编译 SDK 根目录。 |
| `--target TRIPLET` | 否 | `arm-buildroot-linux-gnueabi` | 交叉编译工具链 triplet，例如 `mips-linux-gnu`、`aarch64-buildroot-linux-gnu`。脚本会查找 `${target}-gcc`。 |
| `--prefix PATH` | 否 | `/usr` | 目标安装前缀，必须是绝对路径。 |
| \`--linkage static | dynamic\` | 否 | `static` |
| `--ca-bundle PATH` | 否 | `/etc/ssl/certs/ca-certificates.crt` | 编译进 curl 的 CA bundle 默认路径。 |
| `--ca-path PATH` | 否 | `/etc/ssl/certs` | 编译进 curl 的 CA directory 默认路径。 |
| `--jobs N` | 否 | `nproc` 结果，失败时为 `1` | `make -j` 并行任务数。 |
| `--clean` | 否 | 不启用 | 编译前删除当前模式工作目录。 |
| `--no-strip` | 否 | 不启用 | 跳过 strip。 |
| `--upx PATH` | 否 | `upx` | 指定 UPX 命令路径或命令名。 |
| `--no-upx` | 否 | 不启用 | 跳过 UPX 压缩。 |

## 最小 HTTPS 依赖

curl 最小 HTTPS 版依赖：

```text
curl
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
```

脚本会禁用 IDN、PSL、HTTP/2、HTTP/3、brotli、zstd、libssh2、LDAP、RTSP、SMB 等额外功能，只保留 HTTP/HTTPS 下载和诊断所需能力。

如果静态模式下最终产物仍出现 `PT_INTERP` 或 `DT_NEEDED`，脚本会输出 `WARN`，但不再中断打包。此时产物可继续测试运行，但实际依赖目标系统中的动态链接器和对应 `.so`。

## 输出内容

```text
dist-<target>-curl/
├── curl-<version>-<target>-static.tar.gz
├── curl-<version>-<target>-static.tar.gz.sha256
├── curl-<version>-<target>-dynamic.tar.gz
└── curl-<version>-<target>-dynamic.tar.gz.sha256
```

动态模式会额外打包：

```text
<prefix>/lib/libssl.so*
<prefix>/lib/libcrypto.so*
<prefix>/lib/libz.so*
```

## 部署示例

```sh
tar -xzf /tmp/curl-<version>-arm-buildroot-linux-gnueabi-static.tar.gz -C /
/usr/bin/curl --version
/usr/bin/curl -I https://example.com/
```
