建议编译 **iptables 1.6.2 的 legacy 全量版**，不要直接上 1.8.x 的 nft 后端。

原因是：

* 你要的可执行文件名正是 `xtables-multi`；
* iptables 1.8.x 已拆成 `xtables-legacy-multi` 和 `xtables-nft-multi`；
* G7615 是 Linux 4.19.136 厂商内核，现有环境明确有传统 `/bin/iptables`，但没有证据表明 nftables 用户态和内核模块完整；
* 1.6.2 与原厂 Buildroot 2017 年代更接近，部署风险更低。设备基础情况见分析报告。

iptables 当前官方最新版本已经是 1.8.13，但官方仍保留 1.6.2 源码发布记录；这里选择 1.6.2 是兼容性决策，不是因为它更新。([Netfilter][1])

---

# 一、准备源码

建议目录：

```text
/root/builduser/arm/iptables/iptables-1.6.2
```

没有源码就下载：

```bash
cd /root/builduser/arm

mkdir -p iptables
cd iptables

curl -fL \
  -o iptables-1.6.2.tar.bz2 \
  https://www.netfilter.org/projects/iptables/files/iptables-1.6.2.tar.bz2

sha1sum iptables-1.6.2.tar.bz2
```

官方页面给出的 SHA-1 是：

```text
6279effbf8f2c7ff53d19ae167f8f4c86a38efc47
```

以你实际下载文件和官方页面再次核对为准。([Netfilter][1])

解压：

```bash
tar -xjf iptables-1.6.2.tar.bz2
cd iptables-1.6.2
```

---

# 二、配置交叉工具链

```bash
cd /root/builduser/arm/iptables/iptables-1.6.2

SDK="/root/builduser/toolchains/arm-buildroot-linux-gnueabi_sdk-buildroot"
TARGET="arm-buildroot-linux-gnueabi"

export PATH="$SDK/bin:$PATH"

export CC="${TARGET}-gcc"
export CXX="${TARGET}-g++"
export AR="${TARGET}-ar"
export AS="${TARGET}-as"
export LD="${TARGET}-ld"
export NM="${TARGET}-nm"
export RANLIB="${TARGET}-ranlib"
export STRIP="${TARGET}-strip"
export READELF="${TARGET}-readelf"

"$CC" -dumpmachine
"$CC" --version
"$CC" -print-sysroot
```

应输出：

```text
arm-buildroot-linux-gnueabi
gcc 5.5.0
.../arm-buildroot-linux-gnueabi/sysroot
```

---

# 三、清理旧构建

```bash
make distclean 2>/dev/null || true

rm -f config.cache
rm -rf build-g7615 stage-g7615 dist-g7615
```

建议使用独立构建目录：

```bash
mkdir -p build-g7615
cd build-g7615
```

---

# 四、配置全量 legacy 版本

执行：

```bash
BUILD_TRIPLET="$("../config.guess")"

CFLAGS="-Os -ffunction-sections -fdata-sections" \
LDFLAGS="-Wl,--gc-sections -static-libgcc" \
PKG_CONFIG_LIBDIR= \
PKG_CONFIG_PATH= \
../configure \
  --build="$BUILD_TRIPLET" \
  --host="$TARGET" \
  --prefix=/usr \
  --sbindir=/usr/sbin \
  --libexecdir=/usr/libexec \
  --sysconfdir=/etc \
  --libdir=/usr/lib \
  --with-xtlibdir=/usr/lib/xtables \
  --enable-static \
  --enable-shared \
  --enable-ipv4 \
  --enable-ipv6 \
  --enable-largefile \
  --enable-devel \
  --enable-libipq \
  --disable-nftables
```

## 参数说明

| 参数                      | 作用                                    |
| ----------------------- | ------------------------------------- |
| `--enable-static`       | 构建供 `xtables-multi` 使用的静态扩展集合         |
| `--enable-shared`       | 同时生成 `/usr/lib/xtables/libxt_*.so` 插件 |
| `--enable-ipv4`         | 编译 iptables                           |
| `--enable-ipv6`         | 编译 ip6tables                          |
| `--enable-libipq`       | 编译旧版 libipq 兼容库                       |
| `--enable-bpf-compiler` | 启用 BPF 表达式编译支持                        |
| `--disable-nftables`    | 只构建传统 xtables/legacy 后端               |
| `-static-libgcc`        | 不依赖目标机 `libgcc_s.so.1`                |
| `--gc-sections`         | 清理未使用的代码段                             |

如果这个版本的 `configure` 不认识某一个参数，会直接报：

```text
configure: error: unrecognized option
```

先看支持项：

```bash
../configure --help | grep -E \
  'ipv4|ipv6|nft|libipq|bpf|xtlib|static|shared'
```

常见情况下，可能没有：

```text
--enable-ipv4
--enable-ipv6
```

因为 IPv4/IPv6 默认都会编译。若报不认识，就只删除这两个参数，其他配置保持不变。

---

# 五、检查 configure 结果

```bash
grep -E \
  '^(CC|AR|RANLIB|STRIP|CFLAGS|LDFLAGS|prefix|sbindir|libdir|libexecdir)' \
  Makefile
```

检查 nftables 是否关闭：

```bash
grep -E \
  'ENABLE_NFTABLES|HAVE_LIBNFTNL|HAVE_LIBMNL' \
  config.h 2>/dev/null || true
```

不应该依赖：

```text
libmnl
libnftnl
```

检查目标编译器是否正确：

```bash
grep -n 'arm-buildroot-linux-gnueabi-gcc' config.log |
  head
```

---

# 六、开始编译

```bash
make -j"$(nproc)"
```

需要完整日志时：

```bash
make V=1 -j"$(nproc)"
```

编译完成后查找：

```bash
find . -maxdepth 3 -type f \
  \( -name 'xtables-multi' \
     -o -name 'iptables' \
     -o -name 'ip6tables' \
     -o -name 'iptables-save' \
     -o -name 'iptables-restore' \
     -o -name 'ip6tables-save' \
     -o -name 'ip6tables-restore' \) \
  -ls
```

核心文件通常是：

```text
iptables/xtables-multi
```

确认：

```bash
file iptables/xtables-multi
```

---

# 七、安装到临时 staging 目录

不要直接 `make install` 到构建机根目录。

```bash
STAGE="/root/builduser/arm/iptables/iptables-1.6.2/stage-g7615"

rm -rf "$STAGE"

make DESTDIR="$STAGE" install
```

查看：

```bash
find "$STAGE" -maxdepth 5 \
  \( -type f -o -type l \) |
  sort
```

预期包括：

```text
stage-g7615/usr/sbin/xtables-multi
stage-g7615/usr/sbin/iptables
stage-g7615/usr/sbin/iptables-save
stage-g7615/usr/sbin/iptables-restore
stage-g7615/usr/sbin/ip6tables
stage-g7615/usr/sbin/ip6tables-save
stage-g7615/usr/sbin/ip6tables-restore
stage-g7615/usr/lib/xtables/libxt_*.so
stage-g7615/usr/lib/xtables/libipt_*.so
stage-g7615/usr/lib/xtables/libip6t_*.so
stage-g7615/usr/lib/libxtables.so*
stage-g7615/usr/lib/libip4tc.so*
stage-g7615/usr/lib/libip6tc.so*
```

---

# 八、确认是不是多调用软链接

```bash
ls -l "$STAGE/usr/sbin"
```

理想结构类似：

```text
iptables -> xtables-multi
iptables-save -> xtables-multi
iptables-restore -> xtables-multi
ip6tables -> xtables-multi
ip6tables-save -> xtables-multi
ip6tables-restore -> xtables-multi
```

如果 `make install` 没自动创建，可以手工建立：

```bash
cd "$STAGE/usr/sbin"

for app in \
  iptables \
  iptables-save \
  iptables-restore \
  ip6tables \
  ip6tables-save \
  ip6tables-restore
do
    rm -f "$app"
    ln -s xtables-multi "$app"
done
```

---

# 九、检查完整扩展数量

查看共享扩展：

```bash
find "$STAGE/usr/lib/xtables" \
  -maxdepth 1 \
  -type f \
  -name '*.so' |
  sort
```

统计：

```bash
find "$STAGE/usr/lib/xtables" \
  -maxdepth 1 \
  -type f \
  -name '*.so' |
  wc -l
```

常见扩展类型包括：

```text
libxt_conntrack.so
libxt_comment.so
libxt_limit.so
libxt_multiport.so
libxt_owner.so
libxt_state.so
libxt_tcp.so
libxt_udp.so
libxt_mark.so
libxt_LOG.so
libxt_NFLOG.so
libxt_NFQUEUE.so
libxt_CT.so
libxt_NOTRACK.so
libipt_MASQUERADE.so
libipt_DNAT.so
libipt_SNAT.so
libipt_REDIRECT.so
libip6t_HL.so
libip6t_REJECT.so
```

注意，文件编译出来只表示**用户态解析器存在**。真正能不能用，还取决于 G7615 内核是否编译了对应的：

```text
xt_match
xt_target
nf_conntrack
nf_nat
iptable_filter
iptable_nat
ip6table_filter
```

全量用户态不会自动增加内核模块。

---

# 十、检查 ABI 和依赖

定义：

```bash
MULTI="$STAGE/usr/sbin/xtables-multi"
```

检查 ELF：

```bash
file "$MULTI"

"$READELF" -h "$MULTI" |
  grep -E 'Class|Data|Machine|Flags'
```

应为：

```text
ELF 32-bit LSB
ARM
EABI5
```

检查动态加载器：

```bash
"$READELF" -l "$MULTI" |
  grep -i interpreter
```

必须是：

```text
/lib/ld-linux.so.3
```

检查 ARM 属性：

```bash
"$READELF" -A "$MULTI"
```

应有：

```text
Tag_CPU_name: "Cortex-A53"
Tag_CPU_arch: v8
```

不应有：

```text
Tag_ABI_VFP_args: VFP registers
```

检查动态库：

```bash
"$READELF" -d "$MULTI" |
  grep NEEDED
```

理想情况下依赖类似：

```text
libc.so.6
libdl.so.2
```

视构建方式也可能包括：

```text
libxtables.so.*
libip4tc.so.*
libip6tc.so.*
```

不能看到：

```text
libnftnl.so
libmnl.so
```

因为我们禁用了 nft 后端。

检查 glibc：

```bash
"$READELF" --version-info "$MULTI" |
  grep -o 'GLIBC_[0-9.]*' |
  sort -Vu
```

不能高于：

```text
GLIBC_2.26
```

---

# 十一、strip 发布文件

先保留未裁剪版本：

```bash
cp -a "$STAGE" "${STAGE}.unstripped"
```

裁剪 ARM ELF：

```bash
find "$STAGE" -type f -exec sh -c '
  for file do
    if file "$file" | grep -q "ELF 32-bit.*ARM"; then
      arm-buildroot-linux-gnueabi-strip \
        --strip-unneeded "$file" 2>/dev/null || true
    fi
  done
' sh {} +
```

查看体积：

```bash
du -sh "$STAGE"
du -sh "${STAGE}.unstripped"

ls -lh "$STAGE/usr/sbin/xtables-multi"
```

---

# 十二、打包

```bash
DIST="/root/builduser/arm/iptables/dist-g7615"

rm -rf "$DIST"
mkdir -p "$DIST"

tar \
  --numeric-owner \
  -C "$STAGE" \
  -czf "$DIST/iptables-1.6.2-g7615-full.tar.gz" \
  usr
```

生成校验：

```bash
cd "$DIST"

sha256sum \
  iptables-1.6.2-g7615-full.tar.gz \
  > iptables-1.6.2-g7615-full.tar.gz.sha256
```

保存构建信息：

```bash
cat > BUILD-INFO.txt <<'EOF'
Package: iptables
Version: 1.6.2
Target: arm-buildroot-linux-gnueabi
CPU: Cortex-A53
ISA: ARMv8 AArch32
ABI: EABI5 softfp
libc: glibc 2.26
Kernel headers: Linux 4.9
Runtime kernel: Linux 4.19.136
Backend: legacy xtables
IPv4: enabled
IPv6: enabled
Shared extensions: enabled
Static extension archive: enabled
nftables backend: disabled
EOF
```

---

# 十三、先在 G7615 的 `/tmp` 测试

不要覆盖系统原有 `/bin/iptables`。

上传：

```bash
scp \
  "$DIST/iptables-1.6.2-g7615-full.tar.gz" \
  g7615:/tmp/
```

设备上：

```sh
rm -rf /tmp/iptables-test
mkdir -p /tmp/iptables-test

tar -xzf \
  /tmp/iptables-1.6.2-g7615-full.tar.gz \
  -C /tmp/iptables-test
```

配置路径：

```sh
export IPT_ROOT=/tmp/iptables-test/usr
export XTABLES_LIBDIR="$IPT_ROOT/lib/xtables"
export LD_LIBRARY_PATH="$IPT_ROOT/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export PATH="$IPT_ROOT/sbin:$PATH"
```

确认：

```sh
which iptables
iptables --version
ip6tables --version
```

应看到：

```text
iptables v1.6.2
ip6tables v1.6.2
```

先只做**只读测试**：

```sh
iptables -L -n -v
iptables -t nat -L -n -v
iptables -t mangle -L -n -v
iptables -t raw -L -n -v

ip6tables -L -n -v
ip6tables -t mangle -L -n -v
ip6tables -t raw -L -n -v
```

测试扩展解析，不实际添加规则：

```sh
iptables -m conntrack --help >/dev/null
iptables -m comment --help >/dev/null
iptables -m limit --help >/dev/null
iptables -m multiport --help >/dev/null
iptables -j LOG --help >/dev/null
iptables -j DNAT --help >/dev/null
```

---

# 十四、不要马上替换系统 iptables

先备份设备原版：

```sh
mkdir -p /tmp/iptables-original

cp -a /bin/iptables* /tmp/iptables-original/ 2>/dev/null || true
cp -a /sbin/iptables* /tmp/iptables-original/ 2>/dev/null || true
cp -a /usr/sbin/iptables* /tmp/iptables-original/ 2>/dev/null || true
cp -a /lib/xtables /tmp/iptables-original/ 2>/dev/null || true
cp -a /usr/lib/xtables /tmp/iptables-original/ 2>/dev/null || true
```

检查原版版本：

```sh
/bin/iptables --version 2>/dev/null ||
/sbin/iptables --version 2>/dev/null ||
/usr/sbin/iptables --version 2>/dev/null
```

正式部署时，建议安装到独立路径：

```text
/opt/iptables/usr/sbin
/opt/iptables/usr/lib
/opt/iptables/usr/lib/xtables
```

然后通过环境变量调用，不覆盖厂商文件：

```sh
export PATH=/opt/iptables/usr/sbin:$PATH
export LD_LIBRARY_PATH=/opt/iptables/usr/lib
export XTABLES_LIBDIR=/opt/iptables/usr/lib/xtables
```

## 核心编译命令

若你的源码已经准备好，核心就是：

```bash
cd /root/builduser/arm/iptables/iptables-1.6.2

SDK="/root/builduser/toolchains/buildroot-2017.11.2/output-g7615/host"
export PATH="$SDK/bin:$PATH"

mkdir -p build-g7615
cd build-g7615

CFLAGS="-Os -ffunction-sections -fdata-sections" \
LDFLAGS="-Wl,--gc-sections -static-libgcc" \
../configure \
  --build="$("../config.guess")" \
  --host=arm-buildroot-linux-gnueabi \
  --prefix=/usr \
  --sbindir=/usr/sbin \
  --libdir=/usr/lib \
  --with-xtlibdir=/usr/lib/xtables \
  --enable-static \
  --enable-shared \
  --enable-libipq \
  --enable-bpf-compiler \
  --disable-nftables

make -j"$(nproc)"
make DESTDIR="$PWD/../stage-g7615" install
```

这样得到的是：

```text
xtables-multi
iptables / ip6tables 多调用链接
iptables-save / restore
IPv4 + IPv6
完整共享 xtables 扩展
legacy 内核接口
glibc 2.26 ARM32 EABI5
```

不会引入 nftables、libmnl、libnftnl 这一整套额外依赖。

[1]: https://www.netfilter.org/projects/iptables/downloads.html "netfilter/iptables project homepage
      \-
    Releases of the iptables project"
