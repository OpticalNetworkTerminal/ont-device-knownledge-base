# 前置准备

> 前置：
>
> 1. cpu 架构（arm32/arm64/aarch64/mips/x86_64）
> 2. 用户态 ELF 32bit/ELF 64 bit
> 3. 动态加载器
>    1. /lib/ld-linux.so.3
>    2. /lib/ld-linux-armhf.so.3
> 4. FPU
> 5. C library

知道CPU架构和rootfs原本elf的情况才能进一步选择编译

> 可以用arm-buildroot-linux-gnueabi-readelf"   -A /tmp/g7615-hello 读取信息

```
# 用toolchain自编译的 hello
root@# "$SDK/bin/arm-buildroot-linux-gnueabi-readelf" -A /tmp/g7615-hello 
Attribute Section: aeabi 
File Attributes 
	Tag_CPU_name: "Cortex-A53" 
	Tag_CPU_arch: v8 
	Tag_CPU_arch_profile: Application 
	Tag_ARM_ISA_use: Yes 
	Tag_THUMB_ISA_use: Thumb-2 
	Tag_FP_arch: FP for ARMv8 
	Tag_ABI_PCS_wchar_t: 4 
	Tag_ABI_FP_rounding: Needed 
	Tag_ABI_FP_denormal: Needed 
	Tag_ABI_FP_exceptions: Needed 
	Tag_ABI_FP_number_model: IEEE 754 
	Tag_ABI_align_needed: 8-byte 
	Tag_ABI_align_preserved: 8-byte, except leaf SP 
	Tag_ABI_enum_size: int 
	Tag_CPU_unaligned_access: v6
  Tag_MPextension_use: Allowed 
  Tag_Virtualization_use: TrustZone and Virtualization Extensions 
  
# zte g7615 提取 busybox  
root@# "$SDK/bin/arm-buildroot-linux-gnueabi-readelf" -A /tmp/busybox 
Attribute Section: aeabi 
File Attributes 
Tag_CPU_name: "Cortex-A53" 
Tag_CPU_arch: v8 
Tag_CPU_arch_profile: Application 
Tag_ARM_ISA_use: Yes 
Tag_THUMB_ISA_use: Thumb-2 Tag_ABI_PCS_wchar_t: 4 
Tag_ABI_FP_rounding: Needed 
Tag_ABI_FP_denormal: Needed 
Tag_ABI_FP_exceptions: Needed 
Tag_ABI_FP_number_model: IEEE 754 
Tag_ABI_align_needed: 8-byte 
Tag_ABI_align_preserved: 8-byte, except leaf SP 
Tag_ABI_enum_size: int 
Tag_CPU_unaligned_access: v6 
Tag_MPextension_use: Allowed 
Tag_Virtualization_use: TrustZone and Virtualization Extensions
```

# 环境准备

## Docker环境

> 也可以实体机编译，可以忽略这步骤

```
docker run --rm -it \
  -v "$PWD:/work" \
  -w /work \
  ubuntu:20.04 bash
```

## 依赖安装

```
apt-get update

DEBIAN_FRONTEND=noninteractive apt-get install -y \
  build-essential \
  git \
  wget \
  curl \
  rsync \
  cpio \
  unzip \
  bzip2 \
  xz-utils \
  bc \
  file \
  python3 \
  libncurses5-dev \
  patch \
  perl
```

## 下载buildroot

```
wget https://buildroot.org/downloads/buildroot-2017.11.2.tar.gz
tar -xzf buildroot-2017.11.2.tar.gz
cd buildroot-2017.11.2
```

## 建立config文件

> vim configs/g7615_toolchain_defconfig

```
BR2_arm=y
BR2_cortex_a53=y
BR2_ARM_EABI=y
BR2_TOOLCHAIN_BUILDROOT_GLIBC=y
BR2_KERNEL_HEADERS_4_9=y
BR2_BINUTILS_VERSION_2_27_X=y
BR2_GCC_VERSION_5_X=y
BR2_TOOLCHAIN_BUILDROOT_CXX=y
```

## 加载编译配置

```
make O="$PWD/output-g7615" g7615_toolchain_defconfig
```

## 检查配置

```
make O="$PWD/output-g7615" menuconfig
```

## 核对配置

```
Target options
  Target Architecture                    ARM (little endian)
  Target Architecture Variant            cortex-A53
  Target ABI                             EABI
  Floating point strategy                FP-ARMv8
  ARM instruction set                    ARM

Toolchain
  Toolchain type                         Buildroot toolchain
  C library                              glibc
  Kernel Headers                         Linux 4.9.x
  Binutils Version                       2.27
  GCC compiler Version                   gcc 5.x
  Enable C++ support                     yes
```

## 编译Toolchain

```
make O="$PWD/output-g7615" toolchain

输出：
output-g7615/host/bin/arm-buildroot-linux-gnueabi-gcc
output-g7615/host/bin/arm-buildroot-linux-gnueabi-g++
output-g7615/host/bin/arm-buildroot-linux-gnueabi-ld
output-g7615/host/bin/arm-buildroot-linux-gnueabi-strip
output-g7615/host/bin/arm-buildroot-linux-gnueabi-readelf

检查：
output-g7615/host/bin/arm-buildroot-linux-gnueabi-gcc -v
```



## 编译SDK

```
make O="$PWD/output-g7615" sdk
```

## 打包

```
tar -C output-g7615 \
  -cJf g7615-arm-glibc-2.26-sdk.tar.xz \
  host
```

## 其他机器使用Toolchain

```
解压后
./host/relocate-sdk.sh
```



# helloword

## hello.c

```
#include <stdio.h>
#include <stdint.h>
#include <gnu/libc-version.h>

int main(void)
{
    printf("hello g7615\n");
    printf("pointer bits: %zu\n", sizeof(void *) * 8);
    printf("glibc build version: %s\n", gnu_get_libc_version());
    return 0;
}
```

## 编译

```
TC="$PWD/output-g7615/host/bin/arm-buildroot-linux-gnueabi"

"${TC}-gcc" \
  -O2 \
  -pipe \
  hello.c \
  -o hello-g7615
  
  
  ## Buildroot 的编译器 wrapper 应当已经注入：
  -mcpu=cortex-a53
	-mabi=aapcs-linux
	-mfloat-abi=softfp
	-mfpu=fp-armv8
	-marm
```

## 检查

```
file hello-g7615

"${TC}-readelf" -h hello-g7615
"${TC}-readelf" -A hello-g7615
"${TC}-readelf" -l hello-g7615 | grep interpreter
"${TC}-readelf" --version-info hello-g7615 | grep GLIBC_

预期应看到：
ELF 32-bit LSB pie executable, ARM, EABI5

动态加载器应当是：
[Requesting program interpreter: /lib/ld-linux.so.3]

并且不能出现：
Tag_ABI_VFP_args: VFP registers

```

## 验证

```
先传到 /tmp，不要直接写系统目录：

chmod 755 /tmp/hello-g7615

查看依赖：

/lib/ld-linux.so.3 --list /tmp/hello-g7615

执行：

/tmp/hello-g7615

如果报：

not found

但文件明明存在，通常是以下原因：

动态加载器路径不对；
生成了 hard-float 程序；
生成了 AArch64 程序；
ELF interpreter 不存在。

如果报：

version `GLIBC_2.xx' not found

说明程序依赖了比设备 glibc 2.26 更高的符号版本。
```


# 无法下载依赖源码
```
buildroot 编译下载放到./dl 依赖包
https://mirrors.vcea.wsu.edu/ubuntu/pool/main/f/fakeroot/
https://mirrors.mit.edu/macports/distfiles/fakeroot/
https://mirrors.sdu.edu.cn/kali/pool/main/f/fakeroot/
https://buildroot.org/downloads/
```

