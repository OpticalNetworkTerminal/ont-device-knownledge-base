# vim 最小版编译脚本

`build-arm-vim.sh` 用于交叉编译控制台 Vim。默认构建 tiny 特性集，关闭 GUI/X、脚本解释器、NLS、GPM、SELinux、NetBeans、channel 等能力，目标是得到一个小体积可用的 `vim`/`vi` 编辑器。

Vim 需要终端库，默认使用 `ncurses`。如果 SDK sysroot 里没有 ncurses，请先交叉编译 ncurses，然后通过 `--ncurses-prefix` 指定安装前缀。

## 快速调用

```bash
# https://www.vim.org/download.php
# https://github.com/vim/vim/tags

mkdir -p /tmp/tools-build-scripts/vim
cd /tmp/tools-build-scripts/vim
wget https://github.com/vim/vim/archive/v9.2.0782/vim-9.2.0782.tar.gz
tar -xzf vim-9.2.0782.tar.gz

./build-arm-vim.sh \
  --source /tmp/tools-build-scripts/vim/vim-9.2.0782 \
  --sdk /root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot \
  --target arm-buildroot-linux-gnueabi \
  --prefix /usr \
  --linkage static \
  --features tiny \
  --termlib ncurses \
  --clean \
  2>&1 | tee build-arm-vim.log
```

指定 ncurses：

```bash
./build-arm-vim.sh \
  --source /tmp/tools-build-scripts/vim/vim-9.2.0782 \
  --ncurses-prefix /tmp/tools-build-scripts/ncurses/install-arm/usr \
  --linkage static \
  --clean
```

保留 Vim runtime：

```bash
./build-arm-vim.sh \
  --source /tmp/tools-build-scripts/vim/vim-9.2.0782 \
  --runtime yes \
  --features small \
  --clean
```

## 参数说明

| 参数 | 默认值 | 说明 |
| --- | --- | --- |
| `--source PATH` | 当前目录 | Vim 源码目录，目录内需要有 `src/configure`。 |
| `--sdk PATH` | `/root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot` | Buildroot SDK 根目录。 |
| `--target TRIPLET` | `arm-buildroot-linux-gnueabi` | 交叉工具链 triplet。 |
| `--prefix PATH` | `/usr` | 目标安装前缀。 |
| `--linkage static\|dynamic` | `static` | 链接模式。动态模式会尝试打包 `--ncurses-prefix` 下的 `libncurses*.so*` 和 `libtinfo*.so*`。 |
| `--features tiny\|small\|normal\|huge` | `tiny` | Vim 特性集。越大功能越多，体积也越大。 |
| `--multibyte yes\|no` | `yes` | 是否启用多字节/UTF-8 支持。 |
| `--termlib ncurses\|tinfo\|termcap` | `ncurses` | 传给 Vim `--with-tlib`。 |
| `--ncurses-prefix PATH` | 空 | ncurses/terminfo 安装前缀。 |
| `--runtime yes\|no` | `no` | 是否保留 `/usr/share/vim` runtime。最小版默认删除 runtime、man、图标等。 |
| `--jobs N` | CPU 数 | `make -j` 并行数。 |
| `--clean` | 否 | 构建前删除工作目录。 |
| `--no-strip` | 否 | 跳过 strip。 |
| `--upx PATH` | `upx` | 指定 UPX 命令。 |
| `--no-upx` | 否 | 跳过 UPX 压缩。 |

## 依赖

最小版依赖 libc 和一个终端库：

```text
vim
├── libc
└── ncurses / tinfo / termcap
```

静态编译时需要对应 `.a` 静态库；动态编译时目标系统需要有对应 `.so`，或者用 `--ncurses-prefix` 让脚本一起打包动态库。

## 部署验证

```sh
tar -xzf vim-9.2.0782-arm-buildroot-linux-gnueabi-static.tar.gz -C /
. /usr/environment-setup.sh
vim --version
vi /tmp/test.txt
```
