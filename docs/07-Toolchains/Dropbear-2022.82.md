可以。我们编译成一个适合 G7615 的 **动态链接 `dropbearmulti`**：

* ARM32 Cortex-A53、EABI softfp
* glibc 2.26
* bundled libtomcrypt/libtommath
* 不依赖 zlib
* `libgcc` 静态并入
* 保留密码认证能力，但实际启动建议 `-s` 强制只用公钥
* 包含 `dropbear`、`dropbearkey`、`dbclient`、`dropbearconvert`、`scp`

Dropbear 官方支持通过 `MULTI=1` 把服务器、客户端和密钥工具合并成单一多调用二进制，使用方式与 BusyBox 类似。([GitHub][1])

> 版本上，2022.83 修复了多项 2022.82 回归，包括未认证连接限制、`setsid()`、压缩边界和部分构建问题，并默认关闭 DSS。当前可以先编译 2022.82验证，但长期运行建议稍后切换到 2022.83。([GitHub][2])

# 一、配置交叉编译环境

```bash
cd /root/builduser/arm/dropbear/dropbear-2022.82

SDK="/root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot"
TARGET="arm-buildroot-linux-gnueabi"

export PATH="$SDK/bin:$PATH"

export CC="${TARGET}-gcc"
export AR="${TARGET}-ar"
export RANLIB="${TARGET}-ranlib"
export STRIP="${TARGET}-strip"
export READELF="${TARGET}-readelf"
export OBJDUMP="${TARGET}-objdump"

"$CC" -dumpmachine
"$CC" --version
"$CC" -print-sysroot
```

预期：

```text
arm-buildroot-linux-gnueabi
gcc 5.5.0
.../arm-buildroot-linux-gnueabi/sysroot
```

检查目标 sysroot 里的关键库：

```bash
SYSROOT="$("$CC" -print-sysroot)"

find "$SYSROOT" -maxdepth 3 \
  \( -name 'libcrypt.so*' -o -name 'libutil.so*' -o -name 'libc.so*' \) \
  -ls
```

其中：

* `libcrypt` 用于密码认证；
* `libutil` 通常用于 `openpty()`；
* `libc` 是 glibc 2.26。

# 二、创建 G7615 定制选项

Dropbear 2022.82 默认仍开启 DSS、FIDO/SK key 和外部 SFTP 路径。设备上通常没有 `/usr/libexec/sftp-server`，所以先关闭这些不需要的功能。

```bash
cat > localoptions.h <<'EOF'
#ifndef DROPBEAR_LOCALOPTIONS_H_
#define DROPBEAR_LOCALOPTIONS_H_

/*
 * G7615 ARM32 embedded build.
 */

/* DSS 只有 1024 位并依赖 SHA-1，不用于新部署。 */
#define DROPBEAR_DSS 0

/* 当前设备不使用 FIDO/U2F 安全密钥认证。 */
#define DROPBEAR_SK_ECDSA 1
#define DROPBEAR_SK_ED25519 1

/* 设备没有 OpenSSH 的外部 sftp-server。 */
#define DROPBEAR_SFTPSERVER 0

/* 不使用 X11 和 SSH Agent 转发。 */
#define DROPBEAR_X11FWD 0
#define DROPBEAR_SVR_AGENTFWD 0
#define DROPBEAR_CLI_AGENTFWD 0

/* 避免输出厂商系统 MOTD。 */
#define DO_MOTD 0

/* 降低未认证连接占用。 */
#define MAX_UNAUTH_PER_IP 3
#define MAX_UNAUTH_CLIENTS 10
#define MAX_AUTH_TRIES 5

#endif
EOF
```

这里仍保留：

```text
RSA
ECDSA
ED25519
Curve25519
ChaCha20-Poly1305
AES-CTR
公钥认证
密码认证
TCP 转发
```

Dropbear 2022.82 默认启用公钥和密码认证、RSA/ECDSA/Ed25519、Curve25519、ChaCha20-Poly1305；DSS 在该版本仍默认开启，因此我们显式关闭。([GitHub][3])

# 三、配置交叉编译

先清理旧构建：

```bash
make distclean 2>/dev/null || true
rm -f config.cache
```

注意：`make distclean` 可能删除构建目录中的 `localoptions.h`。确认一下：

```bash
test -f localoptions.h || {
    echo "localoptions.h 被删除，需要重新创建"
    exit 1
}
```

如果确实被删了，就把上面的 `localoptions.h` 再创建一次。

配置：

```bash
# 动态link
BUILD_TRIPLET="$(./config.guess)"

CFLAGS="-Os -ffunction-sections -fdata-sections" \
LDFLAGS="-Wl,--gc-sections -static-libgcc" \
./configure \
  --build="$BUILD_TRIPLET" \
  --host="$TARGET" \
  --prefix=/usr \
  --sysconfdir=/etc/dropbear \
  --enable-bundled-libtom \
  --disable-zlib \
  --disable-pam \
  --disable-lastlog \
  --disable-utmp \
  --disable-utmpx \
  --disable-wtmp \
  --disable-wtmpx \
  --disable-loginfunc \
  --disable-pututline \
  --disable-pututxline
```

``` bash 
# 静态link
BUILD_TRIPLET="$(./config.guess)"

CFLAGS="-Os -ffunction-sections -fdata-sections" \
LDFLAGS="-static -Wl,--gc-sections" \
./configure \
  --build="$BUILD_TRIPLET" \
  --host="$TARGET" \
  --prefix=/usr \
  --sysconfdir=/etc/dropbear \
  --enable-static \
  --enable-bundled-libtom \
  --disable-zlib \
  --disable-pam \
  --disable-lastlog \
  --disable-utmp \
  --disable-utmpx \
  --disable-wtmp \
  --disable-wtmpx \
  --disable-loginfunc \
  --disable-pututline \
  --disable-pututxline
```


这里不使用：

```text
--enable-static
```

因为我们仍然需要动态链接目标机的 glibc 2.26。

显式使用：

```text
--enable-bundled-libtom
```

可以避免错误链接构建机或 sysroot 中不匹配的 libtomcrypt/libtommath。Dropbear 2022.82 支持强制使用源码内置的两套库；其版本检查要求系统库至少为 libtommath 1.2.0 和 libtomcrypt 1.18.0。([GitHub][4])

禁用 zlib 是因为当前 SDK 主要是工具链 SDK，不一定包含目标 zlib。Dropbear 官方构建系统支持 `--disable-zlib`。([GitHub][1])

## 检查 configure 结果

```bash
grep -E \
  '^(CC|AR|RANLIB|STRIP|CFLAGS|LDFLAGS|LIBS|CRYPTLIB|BUNDLED_LIBTOM)' \
  Makefile
```

重点应看到类似：

```text
CC = arm-buildroot-linux-gnueabi-gcc
AR = arm-buildroot-linux-gnueabi-ar
RANLIB = arm-buildroot-linux-gnueabi-ranlib
STRIP = arm-buildroot-linux-gnueabi-strip
BUNDLED_LIBTOM = 1
```

查看密码库检查：

```bash
grep -E \
  'checking for crypt|checking for crypt in -lcrypt' \
  config.log
```

一般应为：

```text
checking for crypt... no
checking for crypt in -lcrypt... yes
```

确认禁用了 zlib：

```bash
grep -E 'DISABLE_ZLIB|HAVE_LIBZ' config.h
```

应该有：

```c
#define DISABLE_ZLIB 1
```

# 四、编译 dropbearmulti

程序列表：

```bash
PROGRAMS="dropbear dropbearkey dbclient dropbearconvert scp"
```

必须先清理：

```bash
make clean
```

开始编译：

```bash
make \
  -j"$(nproc)" \
  PROGRAMS="$PROGRAMS" \
  MULTI=1
```

官方特别提醒：修改 `PROGRAMS` 列表之后必须执行 `make clean`，否则共享对象文件可能产生错误结果。([GitHub][1])

编译完成：

```bash
ls -lh dropbearmulti
file dropbearmulti
```

保存未裁剪版本：

```bash
cp -f dropbearmulti dropbearmulti.unstripped
```

裁剪发布版本：

```bash
"$STRIP" --strip-unneeded dropbearmulti
```

比较：

```bash
ls -lh \
  dropbearmulti \
  dropbearmulti.unstripped
```

# 五、检查 ARM ABI

## ELF 和动态加载器

```bash
file dropbearmulti

"$READELF" -h dropbearmulti |
  grep -E 'Class|Data|Machine|Flags'

"$READELF" -l dropbearmulti |
  grep -i interpreter
```

应为：

```text
ELF 32-bit LSB executable, ARM, EABI5
[Requesting program interpreter: /lib/ld-linux.so.3]
```

## ARM 属性

```bash
"$READELF" -A dropbearmulti
```

预期：

```text
Tag_CPU_name: "Cortex-A53"
Tag_CPU_arch: v8
Tag_FP_arch: FP for ARMv8
```

不应出现：

```text
Tag_ABI_VFP_args: VFP registers
```

否则代表编成了 hard-float ABI。

## 动态依赖

```bash
"$READELF" -d dropbearmulti |
  grep NEEDED
```

可能看到：

```text
Shared library: [libcrypt.so.1]
Shared library: [libutil.so.1]
Shared library: [libc.so.6]
```

不应该看到：

```text
libz.so
libtomcrypt.so
libtommath.so
libgcc_s.so.1
```

原因：

* zlib 已关闭；
* libtom 使用 bundled；
* `-static-libgcc` 把需要的 GCC 辅助代码并入二进制。

## glibc 符号版本

```bash
"$READELF" --version-info dropbearmulti |
  grep -o 'GLIBC_[0-9.]*' |
  sort -Vu
```

不能出现高于：

```text
GLIBC_2.26
```

# 六、制作测试目录

```bash
DIST="$PWD/dist-g7615"

rm -rf "$DIST"
mkdir -p "$DIST/bin" "$DIST/config"
```

复制二进制：

```bash
cp -f dropbearmulti \
  "$DIST/bin/dropbearmulti"

cp -f dropbearmulti.unstripped \
  "$DIST/bin/dropbearmulti.unstripped"

cp -f localoptions.h config.h \
  "$DIST/config/"
```

创建多调用软链接：

```bash
cd "$DIST/bin"

for app in \
  dropbear \
  dropbearkey \
  dbclient \
  dropbearconvert \
  scp
do
    ln -s dropbearmulti "$app"
done
```

查看：

```bash
ls -lh
```

应类似：

```text
dropbear -> dropbearmulti
dropbearkey -> dropbearmulti
dbclient -> dropbearmulti
dropbearconvert -> dropbearmulti
scp -> dropbearmulti
```

生成校验：

```bash
sha256sum dropbearmulti \
  > SHA256SUMS
```

打包：

```bash
cd "$DIST"

tar -cJf \
  ../dropbear-2022.82-g7615-arm32.tar.xz \
  bin config
```

# 七、传到 G7615

构建机执行：

```bash
scp \
  "$DIST/../dropbear-2022.82-g7615-arm32.tar.xz" \
  root@G7615_IP:/tmp/
```

设备执行：

```sh
cd /tmp

rm -rf /tmp/dropbear-test
mkdir -p /tmp/dropbear-test

tar -xJf \
  /tmp/dropbear-2022.82-g7615-arm32.tar.xz \
  -C /tmp/dropbear-test
```

如果目标机 BusyBox 的 `tar` 不支持 `-J`，构建机直接传目录，或者改用 gzip：

```bash
cd "$DIST"

tar -czf \
  ../dropbear-2022.82-g7615-arm32.tar.gz \
  bin config
```

设备检查：

```sh
cd /tmp/dropbear-test/bin

chmod 755 dropbearmulti

/lib/ld-linux.so.3 \
  --list \
  ./dropbearmulti
```

查看版本：

```sh
./dropbear -V
./dropbearkey -V 2>/dev/null || true
./dbclient -V
```

# 八、生成临时主机密钥

优先使用 Ed25519：

```sh
cd /tmp/dropbear-test/bin

./dropbearkey \
  -t ed25519 \
  -f /tmp/dropbear-test/dropbear_ed25519_host_key
```

查看公钥和指纹：

```sh
./dropbearkey \
  -y \
  -f /tmp/dropbear-test/dropbear_ed25519_host_key
```

权限：

```sh
chmod 600 \
  /tmp/dropbear-test/dropbear_ed25519_host_key
```

# 九、配置公钥登录

在你的电脑查看 SSH 公钥：

```bash
cat ~/.ssh/id_ed25519.pub
```

G7615 上：

```sh
mkdir -p /root/.ssh
chmod 700 /root/.ssh

cat >> /root/.ssh/authorized_keys <<'EOF'
ssh-ed25519 AAAA...你的完整公钥... builduser
EOF

chmod 600 /root/.ssh/authorized_keys
```

检查根用户 shell：

```sh
grep '^root:' /etc/passwd
```

应类似：

```text
root:x:0:0:root:/root:/bin/sh
```

检查 PTY：

```sh
mount | grep devpts
ls -ld /dev/pts
```

# 十、临时启动 Dropbear

先确定只监听 LAN 的地址：

```sh
ip addr 2>/dev/null || ifconfig
```

假设 LAN 地址是：

```text
192.168.1.1
```

前台启动，监听 `2222`：

```sh
cd /tmp/dropbear-test/bin

./dropbear \
  -F \
  -E \
  -p 192.168.1.1:2222 \
  -r /tmp/dropbear-test/dropbear_ed25519_host_key \
  -P /tmp/dropbear-test/dropbear.pid \
  -s \
  -j \
  -k
```

参数含义：

| 参数   | 含义            |
| ---- | ------------- |
| `-F` | 前台运行，方便观察     |
| `-E` | 日志输出到标准错误     |
| `-p` | 指定监听地址和端口     |
| `-r` | 指定临时 host key |
| `-P` | 指定 PID 文件     |
| `-s` | 禁止密码认证，只允许公钥  |
| `-j` | 禁止本地端口转发      |
| `-k` | 禁止远程端口转发      |

不要先监听：

```text
0.0.0.0:22
```

也不要覆盖厂商已有服务。

# 十一、客户端连接

电脑执行：

```bash
ssh \
  -p 2222 \
  root@192.168.1.1
```

首次连接确认 Ed25519 指纹。

测试：

```sh
uname -a
id
echo "$SHELL"
echo "$PATH"
```

另开终端检查进程：

```sh
ps | grep '[d]ropbear'
```

停止测试：

```sh
kill "$(cat /tmp/dropbear-test/dropbear.pid)"
```

如果前台运行，直接按：

```text
Ctrl+C
```

# 十二、关于 SCP 和 SFTP

我们关闭了：

```c
#define DROPBEAR_SFTPSERVER 0
```

因为 Dropbear 本身不提供 SFTP server，只能调用外部 OpenSSH `sftp-server`。([GitHub][3])

现代 OpenSSH 的 `scp` 默认使用 SFTP，因此当前需要显式使用旧 SCP 协议：

```bash
scp -O \
  -P 2222 \
  test.txt \
  root@192.168.1.1:/tmp/
```

并且设备端的 `scp` 必须位于 Dropbear 登录后的 `PATH` 中。临时测试可以建立：

```sh
ln -sf \
  /tmp/dropbear-test/bin/scp \
  /tmp/scp
```

但因为默认 root PATH 不一定包含 `/tmp`，更稳妥的是先只测试 SSH shell；正式安装时再部署到 `/opt/dropbear/bin`，并处理 PATH。

# 推荐构建结果

最终应满足：

```text
dropbearmulti
├── ARM32 EABI5
├── Cortex-A53 / ARMv8
├── softfp
├── glibc 2.26 动态链接
├── libgcc 静态并入
├── bundled libtomcrypt/libtommath
├── 无 zlib 依赖
├── Ed25519 / ECDSA / RSA
├── 公钥和密码认证均已编译
└── 运行时默认使用 -s 关闭密码认证
```

先执行到：

```bash
make -j"$(nproc)" PROGRAMS="$PROGRAMS" MULTI=1
```

编译完成后，重点贴出这三组结果：

```bash
file dropbearmulti

arm-buildroot-linux-gnueabi-readelf -l dropbearmulti |
  grep interpreter

arm-buildroot-linux-gnueabi-readelf -d dropbearmulti |
  grep NEEDED
```

[1]: https://raw.githubusercontent.com/mkj/dropbear/DROPBEAR_2022.82/INSTALL "raw.githubusercontent.com"
[2]: https://raw.githubusercontent.com/mkj/dropbear/DROPBEAR_2022.83/CHANGES "raw.githubusercontent.com"
[3]: https://raw.githubusercontent.com/mkj/dropbear/DROPBEAR_2022.82/default_options.h "raw.githubusercontent.com"
[4]: https://raw.githubusercontent.com/mkj/dropbear/DROPBEAR_2022.82/configure.ac "raw.githubusercontent.com"

