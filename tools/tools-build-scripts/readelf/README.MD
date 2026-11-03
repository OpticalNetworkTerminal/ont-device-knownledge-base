# readelf 最小版编译脚本

`build-arm-readelf.sh` 从 GNU binutils 源码交叉编译 binutils，但最终只打包 `readelf`。适合在目标设备上检查 ELF 文件头、动态依赖、解释器、段表等信息。

默认关闭 gdb、gas、ld、gold、gprofng、sim、NLS、zlib/zstd 等能力，支持静态/动态链接，默认打包前执行 `upx --best --lzma`。

## 快速调用

```bash
# https://www.gnu.org/software/binutils/
# https://ftp.gnu.org/gnu/binutils/

mkdir -p /tmp/tools-build-scripts/readelf
cd /tmp/tools-build-scripts/readelf
wget https://ftp.gnu.org/gnu/binutils/binutils-2.45.1.tar.xz
tar -xvf binutils-2.45.1.tar.xz

./build-arm-readelf.sh \
  --source /tmp/tools-build-scripts/readelf/binutils-2.45.1 \
  --sdk /root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot \
  --target arm-buildroot-linux-gnueabi \
  --prefix /usr \
  --linkage static \
  --clean \
  2>&1 | tee build-arm-readelf.log
```

动态编译：

```bash
./build-arm-readelf.sh \
  --source /tmp/tools-build-scripts/readelf/binutils-2.45.1 \
  --linkage dynamic \
  --clean
```

## 参数说明

| 参数 | 默认值 | 说明 |
| --- | --- | --- |
| `--source PATH` | 当前目录 | binutils 源码目录。 |
| `--sdk PATH` | `/root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot` | Buildroot SDK 根目录。 |
| `--target TRIPLET` | `arm-buildroot-linux-gnueabi` | 交叉工具链 triplet。 |
| `--prefix PATH` | `/usr` | 目标安装前缀。 |
| `--linkage static\|dynamic` | `static` | 链接模式。 |
| `--jobs N` | CPU 数 | `make -j` 并行数。 |
| `--clean` | 否 | 构建前删除工作目录。 |
| `--no-strip` | 否 | 跳过 strip。 |
| `--upx PATH` | `upx` | 指定 UPX 命令。 |
| `--no-upx` | 否 | 跳过 UPX 压缩。 |

## 依赖

最小版主要依赖 libc。脚本使用 `make all-binutils` 和 `make install-binutils`，然后删除除 `readelf` 以外的 binutils 工具。

## 部署验证

```sh
tar -xzf readelf-2.45.1-arm-buildroot-linux-gnueabi-static.tar.gz -C /
. /usr/environment-setup.sh
readelf -h /bin/sh
readelf -l /bin/sh | grep interpreter
readelf -d /bin/sh | grep NEEDED
```
