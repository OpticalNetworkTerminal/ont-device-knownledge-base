# file/libmagic 最小版编译脚本

`build-arm-file.sh` 用于交叉编译 `file` 命令和 `libmagic`。脚本会先 native 构建一个 host `file` 辅助程序，再用它为目标系统生成 `magic.mgc`，避免交叉编译时误执行 ARM 目标程序。

默认启用 ELF 识别，关闭压缩库和 seccomp，支持静态/动态链接，默认打包前执行 `upx --best --lzma`。

## 快速调用

```bash
# https://www.darwinsys.com/file/
# https://astron.com/pub/file/

mkdir -p /tmp/tools-build-scripts/file
cd /tmp/tools-build-scripts/file
wget https://astron.com/pub/file/file-5.48.tar.gz
tar -xzf file-5.48.tar.gz

./build-arm-file.sh \
  --source /tmp/tools-build-scripts/file/file-5.48 \
  --sdk /root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot \
  --target arm-buildroot-linux-gnueabi \
  --prefix /usr \
  --linkage static \
  --clean \
  2>&1 | tee build-arm-file.log
```

动态编译：

```bash
./build-arm-file.sh \
  --source /tmp/tools-build-scripts/file/file-5.48 \
  --linkage dynamic \
  --clean
```

## 参数说明

| 参数 | 默认值 | 说明 |
| --- | --- | --- |
| `--source PATH` | 当前目录 | file 源码目录。 |
| `--sdk PATH` | `/root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot` | Buildroot SDK 根目录。 |
| `--target TRIPLET` | `arm-buildroot-linux-gnueabi` | 交叉工具链 triplet。 |
| `--prefix PATH` | `/usr` | 目标安装前缀。 |
| `--linkage static\|dynamic` | `static` | 链接模式。动态模式会安装 `libmagic.so*`。 |
| `--elf yes\|no` | `yes` | 是否启用内置 ELF 识别。 |
| `--compress yes\|no` | `no` | 是否启用 zlib/bzip2/xz/zstd/lzip/lrzip 等压缩识别库。 |
| `--seccomp yes\|no` | `no` | 是否启用 libseccomp 沙箱。 |
| `--jobs N` | CPU 数 | `make -j` 并行数。 |
| `--clean` | 否 | 构建前删除工作目录。 |
| `--no-strip` | 否 | 跳过 strip。 |
| `--upx PATH` | `upx` | 指定 UPX 命令。 |
| `--no-upx` | 否 | 跳过 UPX 压缩。 |

## 依赖

最小版主要依赖 libc。压缩库默认关闭；如果开启 `--compress yes`，需要 SDK/sysroot 中存在对应头文件和库。

压缩包内包含：

```text
/usr/bin/file
/usr/share/misc/magic.mgc
/usr/environment-setup.sh
```

## 部署验证

```sh
tar -xzf file-5.48-arm-buildroot-linux-gnueabi-static.tar.gz -C /
. /usr/environment-setup.sh
file /bin/sh
file -L /proc/1/exe
```
