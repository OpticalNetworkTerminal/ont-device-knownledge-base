# AArch32与AArch64

## 简介

本文说明 AArch32 和 AArch64 的区别，以及为什么 64 位 ARM 程序不能直接在 32 位 ARM 用户态中运行。

## 背景

很多人把“ARM”当成单一平台，但现代 ARM 实际上至少要区分 32 位执行状态和 64 位执行状态。它们不是简单的“高低版本”，而是不同的用户态执行模型。

## 基本概念

- AArch32：ARM 32 位执行状态
- AArch64：ARM 64 位执行状态
- ARMv7：典型 32 位平台
- ARMv8-A：通常支持 64 位，也可兼容部分 32 位执行模式

## 工作原理

AArch64 程序的 ELF 头、寄存器使用方式、系统调用接口、调用约定、动态链接器路径都和 AArch32 不同。因此 64 位程序不能直接由 32 位用户态装载。

## 设计目的

AArch64 的设计目的包括：

- 扩展寄存器宽度
- 改进指令集
- 提供更大的地址空间
- 改善现代系统软件的实现基础

## 优缺点

优点：

- 更大的地址空间
- 更多寄存器
- 更现代的 ABI 与性能优化空间

缺点：

- 与旧 32 位用户态不二进制兼容
- 迁移时需要完整工具链、libc、Rootfs 支持

## 典型应用

- AArch32：旧路由器、旧光猫、资源较紧设备
- AArch64：新一代家庭网关、性能更高的嵌入式平台

## 在 Buildroot 中的位置

Buildroot 会分别提供 `arm` 与 `aarch64` 等架构目标，输出不同工具链和 Rootfs。

## 在 OpenWrt 中的位置

OpenWrt 也分别维护 32 位 ARM 与 64 位 ARM 目标平台，软件包需按 target 分开构建。

## 在光猫中的体现

同一产品线升级 SoC 后，常见变化之一就是从 32 位 ARM 迁移到 64 位 ARM，这会连带影响：

- libc
- 动态链接器
- 内核模块
- 整个用户态 Rootfs

## 实际案例

把 `ELF 64-bit LSB` 的 AArch64 程序复制到 ARMv7 光猫上，即使文件完整，也通常不会运行。根因不是文件损坏，而是装载环境只支持 32 位 ARM ABI。

## 实践操作

```bash
file /bin/busybox
readelf -h /bin/busybox
uname -m
```

怎么看：

- `file` 中的 `ELF 32-bit` 与 `ELF 64-bit` 是第一眼判断
- `readelf -h` 中 `Class` 和 `Machine` 更准确
- `uname -m` 看当前运行环境是不是 `aarch64`

## 前置知识

- CPU架构
- ARM架构

## 后续知识

- ABI
- ELF文件格式
- 动态链接器(ld-linux)

## 知识等级

★★★★★ 必须掌握

对光猫分析与 Linux 嵌入式运行时兼容性判断非常重要。

## 参考资料

- 官方文档：Linux Kernel ARM64 文档 `https://docs.kernel.org/arch/arm64/index.html`
- 官方源码：Linux kernel `https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git`
- 标准：ELF gABI `https://refspecs.linuxfoundation.org/elf/gabi4+/contents.html`
- GPL源码：后续结合 32/64 位平台 GPL 工具链与 Rootfs 验证
- 论坛：恩山无线论坛 `https://www.right.com.cn/forum/`、ChinaDSL `https://www.chinadsl.net/`、吾爱破解 `https://www.52pojie.cn/`
- 博客：Bootlin `https://bootlin.com/`

## 最后验证时间

更新时间：2026-07-12

适用版本：ARM 32/64 位用户态通用知识

验证环境：Kernel 文档与 ELF 标准整理

作者：Codex
