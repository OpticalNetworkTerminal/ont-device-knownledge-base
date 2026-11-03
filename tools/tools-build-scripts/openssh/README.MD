# ARM OpenSSH 编译脚本

`build-arm-openssh-full.sh` 用于交叉编译 ARM Buildroot GNU EABI 环境可用的 OpenSSH 二进制。脚本支持静态链接和动态链接，默认使用静态链接，并在打包前默认执行 `upx --best --lzma` 压缩。

## 快速调用

默认静态编译：

```bash
# https://www.openssh.com/portable.html
# https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/
# https://openssl-library.org/source/
# https://zlib.net/

mkdir -p /tmp/tools-build-scripts/openssh
cd /tmp/tools-build-scripts/openssh
wget https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-10.4p1.tar.gz
tar -xzvf openssh-10.4p1.tar.gz

mkdir -p /tmp/tools-build-scripts/openssl
cd /tmp/tools-build-scripts/openssl
wget https://www.openssl.org/source/openssl-3.5.7.tar.gz
tar -xzvf openssl-3.5.7.tar.gz

mkdir -p /tmp/tools-build-scripts/zlib
cd /tmp/tools-build-scripts/zlib
wget https://zlib.net/zlib-1.3.2.tar.gz
tar -xzvf zlib-1.3.2.tar.gz

cd /tmp/tools-build-scripts/openssh

./build-arm-openssh-full.sh \
  --source /tmp/tools-build-scripts/openssh/openssh-10.4p1 \
  --openssl-src /tmp/tools-build-scripts/openssl/openssl-3.5.7 \
  --zlib-src /tmp/tools-build-scripts/zlib/zlib-1.3.2 \
  --openssl-target linux-armv4 \
  --sdk /root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot \
  --target arm-buildroot-linux-gnueabi \
  --prefix /usr \
  --sandbox no \
  --privsep-user nobody \
  --privsep-path /var/empty \
  --clean \
  2>&1 | tee build-arm-openssh.log
```

动态编译：

```bash
./build-arm-openssh-full.sh \
  --source /tmp/tools-build-scripts/openssh/openssh-10.4p1 \
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
| `--source PATH` | 否 | 当前工作目录 | OpenSSH 源码目录，目录内需要存在可执行的 `configure`。 |
| `--openssl-src PATH` | 是 | 无 | OpenSSL 源码目录，目录内需要存在 `Configure`。 |
| `--zlib-src PATH` | 是 | 无 | zlib 源码目录，目录内需要存在可执行的 `configure`。 |
| `--openssl-target NAME` | 否 | `linux-armv4` | OpenSSL `Configure` platform。换架构时需要同步调整，例如 AArch64 常用 `linux-aarch64`。 |
| `--sdk PATH` | 否 | `/root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot` | Buildroot 交叉编译 SDK 根目录。脚本会在 `bin/` 或 `host/bin/` 下查找 `arm-buildroot-linux-gnueabi-gcc`。 |
| `--target TRIPLET` | 否 | `arm-buildroot-linux-gnueabi` | 交叉编译工具链 triplet。脚本会查找 `${target}-gcc`，并把产物输出到 `dist-<target>-openssh/`。 |
| `--prefix PATH` | 否 | `/usr` | 安装前缀，必须是绝对路径。最终压缩包会包含 `.${prefix}` 目录。 |
| `--linkage static|dynamic` | 否 | `static` | 链接模式。`static` 生成静态链接二进制；`dynamic` 生成动态链接二进制，并把本次构建的 `libcrypto.so*`、`libz.so*` 放入 `<prefix>/lib`。 |
| `--listen IP` | 否 | 不写入配置 | 写入 `sshd_config` 的 `ListenAddress`。不传时使用 sshd 默认监听地址。 |
| `--port PORT` | 否 | 不写入配置 | 写入 `sshd_config` 的 `Port`，必须是数字。不传时使用 sshd 默认端口。 |
| `--sandbox yes|no` | 否 | `no` | 控制 OpenSSH sandbox 配置。传 `no` 时脚本会尽量追加 `--without-sandbox` 或 `--with-sandbox=no`。 |
| `--privsep-user USER` | 否 | `nobody` | 写入 OpenSSH configure 的 privilege separation 用户。 |
| `--privsep-path PATH` | 否 | `/var/empty` | privilege separation 目录，必须是绝对路径。启动脚本会创建并设置权限。 |
| `--jobs N` | 否 | `nproc` 结果，失败时为 `1` | `make -j` 并行任务数。 |
| `--clean` | 否 | 不启用 | 编译前删除 OpenSSH 源码目录下的 `.<target>-openssh-static` 或 `.<target>-openssh-dynamic` 工作目录。 |
| `--no-strip` | 否 | 不启用 | 跳过 `${TARGET}-strip --strip-unneeded`。默认会 strip。 |
| `--upx PATH` | 否 | `upx` | 指定 UPX 命令路径或命令名。默认在打包前对所有安装进 staging 的二进制执行 `upx --best --lzma`。 |
| `--no-upx` | 否 | 不启用 | 跳过 UPX 压缩，适合调试 UPX 兼容性或需要保留未压缩二进制时使用。 |
| `-h`, `--help` | 否 | 不适用 | 输出脚本内置帮助。 |

## 参数取值说明

### `--target`

`--target` 是交叉编译工具链 triplet，脚本会用它拼出工具名：

```text
<target>-gcc
<target>-ar
<target>-ranlib
<target>-strip
<target>-readelf
```

默认值：

```text
arm-buildroot-linux-gnueabi
```

常见示例：

| 目标 | `--target` 示例 |
| --- | --- |
| ARM 32-bit GNU EABI | `arm-buildroot-linux-gnueabi` |
| ARM 32-bit hard-float | `arm-linux-gnueabihf` |
| AArch64 | `aarch64-buildroot-linux-gnu` |
| MIPS little-endian | `mipsel-linux-gnu` |
| MIPS big-endian | `mips-linux-gnu` |
| MIPS64 little-endian | `mips64el-linux-gnuabi64` |

实际值必须和 SDK 里的工具名前缀一致。比如 SDK 里是 `arm-buildroot-linux-gnueabi-gcc`，就传：

```bash
--target arm-buildroot-linux-gnueabi
```

### `--openssl-target`

`--openssl-target` 是 OpenSSL 自己的 `Configure` platform，不是 GNU triplet。它用于告诉 OpenSSL 选择哪套平台构建规则。

默认值：

```text
linux-armv4
```

这里容易看错：是 `linux-armv4`，不是 `linux-arm4`。OpenSSL 的 `linux-armv4` 通常用于 ARM 32-bit Linux，包括很多 ARMv5/ARMv6/ARMv7/ARMv8 AArch32 交叉编译场景。具体 CPU 指令、ABI、软浮点/硬浮点仍主要由你的 SDK 编译器默认参数决定。

常见示例：

| 目标 | `--target` 示例 | `--openssl-target` 示例 |
| --- | --- | --- |
| ARM 32-bit GNU EABI | `arm-buildroot-linux-gnueabi` | `linux-armv4` |
| ARM 32-bit hard-float | `arm-linux-gnueabihf` | `linux-armv4` |
| AArch64 | `aarch64-buildroot-linux-gnu` | `linux-aarch64` |
| MIPS 32-bit | `mips-linux-gnu` / `mipsel-linux-gnu` | `linux-mips32` |
| MIPS64 | `mips64-linux-gnuabi64` / `mips64el-linux-gnuabi64` | `linux64-mips64` |
| x86_64 Linux | `x86_64-linux-gnu` | `linux-x86_64` |
| i386 Linux | `i686-linux-gnu` | `linux-x86` |

以你当前 ARM32 SDK 为例，一般保持：

```bash
--target arm-buildroot-linux-gnueabi \
--openssl-target linux-armv4
```

如果换成 AArch64 SDK，一般改成：

```bash
--target aarch64-buildroot-linux-gnu \
--openssl-target linux-aarch64
```

要查看当前 OpenSSL 源码支持的完整 platform 列表：

```bash
cd /path/openssl-3.x
perl Configure LIST
```

### `--linkage`

允许值只有：

```text
static
dynamic
```

`static` 会构建静态 zlib、静态 OpenSSL，并要求最终 OpenSSH 二进制没有 `PT_INTERP` 和 `DT_NEEDED`。

`dynamic` 会构建动态 zlib、动态 OpenSSL，并把 `libcrypto.so*`、`libz.so*` 打包进 `<prefix>/lib`。

### `--sandbox`

允许值只有：

```text
yes
no
```

默认是 `no`。嵌入式设备上缺少 seccomp、pledge 或 privilege separation 相关环境时，`no` 更容易启动成功。传 `yes` 时脚本不会额外添加禁用 sandbox 的 configure 参数，是否启用取决于 OpenSSH 源码和目标系统支持情况。

### `--listen` 与 `--port`

`--listen` 写入 `sshd_config` 的 `ListenAddress`。不传时不写该行，让 sshd 使用默认监听行为。

`--port` 写入 `sshd_config` 的 `Port`，必须是数字。不传时不写该行，让 sshd 使用默认端口。

启动时也可以通过 `start-sshd.sh` 临时覆盖：

```sh
/usr/start-sshd.sh --listen 192.168.1.1 --port 2224
```

### 路径类参数

这些参数必须是绝对路径：

```text
--prefix
--privsep-path
```

这些参数必须指向对应源码目录：

```text
--source        OpenSSH 源码目录，需有 configure
--openssl-src   OpenSSL 源码目录，需有 Configure
--zlib-src      zlib 源码目录，需有 configure
--sdk           SDK 根目录，下面需有 bin/ 或 host/bin/
```

### 开关类参数

这些是不带值的开关：

```text
--clean      编译前删除当前 target/linkage 工作目录
--no-strip   不执行 strip
--no-upx     不执行 upx --best --lzma
```

`--upx PATH` 可以指定 UPX 命令路径，例如：

```bash
--upx /usr/local/bin/upx
```

## 静态与动态模式

静态模式：

- zlib 使用 `./configure --static`
- OpenSSL 使用 `no-shared`
- OpenSSH 使用 `-static -static-libgcc`
- 打包前校验二进制不能包含 `PT_INTERP` 和 `DT_NEEDED`
- 设备上不需要额外准备 `libcrypto.so`、`libz.so`

动态模式：

- zlib 使用 `./configure --shared`
- OpenSSL 使用 `shared`
- OpenSSH 不使用 `-static`
- 链接时写入 rpath：`<prefix>/lib`
- 压缩包内会包含本次构建出的 `libcrypto.so*`、`libz.so*`
- 打包前会输出每个二进制的 `DT_NEEDED` 依赖，方便确认设备运行时还需要哪些系统库

## 输出内容

构建完成后，产物会放在 OpenSSH 源码目录下：

```text
dist-<target>-openssh/
├── openssh-<version>-<target>-static.tar.gz
├── openssh-<version>-<target>-static.tar.gz.sha256
├── openssh-<version>-<target>-dynamic.tar.gz
└── openssh-<version>-<target>-dynamic.tar.gz.sha256
```

压缩包内会包含：

```text
<prefix>/bin/ssh
<prefix>/bin/scp
<prefix>/bin/sftp
<prefix>/bin/ssh-add
<prefix>/bin/ssh-agent
<prefix>/bin/ssh-keygen
<prefix>/bin/ssh-keyscan
<prefix>/sbin/sshd
<prefix>/libexec/sshd-session
<prefix>/libexec/sshd-auth
<prefix>/libexec/sftp-server
<prefix>/etc/ssh/ssh_config
<prefix>/etc/ssh/sshd_config
<prefix>/generate-host-keys.sh
<prefix>/start-sshd.sh
```

动态模式还会包含：

```text
<prefix>/lib/libcrypto.so*
<prefix>/lib/libz.so*
```

`ssh-keysign`、`ssh-pkcs11-helper`、`ssh-sk-helper` 如果当前 OpenSSH 版本实际生成，也会一起放入 `<prefix>/libexec/`。

## 启动参数

`start-sshd.sh` 支持启动时传入监听参数：

```sh
<prefix>/start-sshd.sh --listen 192.168.1.1 --port 2224
```

不传 `--listen` 和 `--port` 时，脚本不会额外覆盖 `sshd_config`，由 sshd 使用默认监听行为。

## 部署示例

把压缩包复制到设备后执行：

```sh
tar -xzf /tmp/openssh-<version>-arm-buildroot-linux-gnueabi-static.tar.gz -C /
<prefix>/generate-host-keys.sh
<prefix>/start-sshd.sh
```

如果 `--prefix /usr`，实际命令就是：

```sh
tar -xzf /tmp/openssh-<version>-arm-buildroot-linux-gnueabi-static.tar.gz -C /
/usr/generate-host-keys.sh
/usr/start-sshd.sh
```

需要临时绑定到指定地址和端口时：

```sh
/usr/start-sshd.sh --listen 192.168.1.1 --port 2224
```

## 编译环境要求

- Buildroot SDK，默认目标前缀为 `arm-buildroot-linux-gnueabi`，可用 `--target` 覆盖
- 本机需要可执行命令：`make`、`perl`、`file`、`tar`、`sha256sum`
- 默认启用 UPX 时还需要 `upx`
- 静态模式要求 SDK sysroot 内存在 `libc.a`、`libpthread.a`、`libdl.a`、`libcrypt.a`
