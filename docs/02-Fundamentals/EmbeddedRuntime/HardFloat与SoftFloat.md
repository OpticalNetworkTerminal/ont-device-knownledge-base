# HardFloat与SoftFloat

## 简介

本文说明 hard-float 与 soft-float 的区别，以及为什么二者不能混用。

## 背景

很多 ARM 嵌入式系统的问题，不是“是不是 ARM”，而是“是不是同一种浮点 ABI”。这也是很多程序明明是 ARM ELF，却仍然运行失败的根因之一。

## 基本概念

- soft-float：浮点参数与返回值按软件浮点 ABI 约定处理
- hard-float：浮点参数与返回值可以通过硬件浮点寄存器按约定传递

注意：这不仅是“有没有 FPU”，还涉及 ABI 约定。

## 工作原理

如果函数调用一方按 hard-float 约定把浮点参数放入某组寄存器，而被调用方按 soft-float 约定去栈上或通用寄存器找参数，结果一定错误。这就是 ABI 不兼容。

## 设计目的

- soft-float：兼容没有硬件浮点单元的平台
- hard-float：在支持 FPU 的平台上提升效率并统一二进制约定

## 优缺点

hard-float 优点：

- 浮点调用效率更高
- 现代平台更常见

soft-float 优点：

- 更适合没有 FPU 的平台

缺点：

- 两者二进制不兼容
- Rootfs、libc、工具链和应用必须统一

## 典型应用

- 老 ARM 平台可能更常见 soft-float
- 新 ARM 平台常用 hard-float

## 在 Buildroot 中的位置

Buildroot 工具链配置会决定浮点策略，这会影响整个目标系统。

## 在 OpenWrt 中的位置

OpenWrt 目标工具链和软件包也会固定浮点 ABI，不能把另一种 ABI 的包直接混入。

## 在光猫中的体现

光猫常见现象是：从另一台 ARM 设备拷一个程序过来，`file` 看起来都像 ARM，但仍然不能运行。排查到最后，常常就是 hard-float / soft-float 不一致。

## 实际案例

`gnueabi` 与 `gnueabihf` 的差异，往往正对应软浮点与硬浮点 ABI 的差别。程序和共享库只要一边不一致，就不能可靠运行。

## 实践操作

```bash
file busybox
readelf -A busybox 2>/dev/null
readelf -l busybox
```

怎么看：

- `readelf -A`：某些 ARM 平台可以观察 ABI 属性
- `readelf -l`：看解释器路径，常能间接看出 `armhf`

## 前置知识

- ARM架构
- ABI
- EABI

## 后续知识

- Toolchain
- 动态链接器(ld-linux)
- glibc

## 知识等级

★★★★★ 必须掌握

对 ARM 光猫、Buildroot、OpenWrt 的兼容性判断非常关键。

## 参考资料

- 官方文档：GCC 文档 `https://gcc.gnu.org/onlinedocs/`
- 官方源码：Buildroot `https://gitlab.com/buildroot.org/buildroot`、OpenWrt `https://github.com/openwrt/openwrt`
- 标准：ELF gABI `https://refspecs.linuxfoundation.org/elf/gabi4+/contents.html`
- GPL源码：后续结合 ARM 设备 GPL 工具链三元组验证
- 论坛：恩山无线论坛 `https://www.right.com.cn/forum/`、ChinaDSL `https://www.chinadsl.net/`、吾爱破解 `https://www.52pojie.cn/`
- 博客：Bootlin `https://bootlin.com/`

## 最后验证时间

更新时间：2026-07-12

适用版本：ARM 浮点 ABI 通用知识

验证环境：工具链命名与嵌入式工程实践整理

作者：Codex
