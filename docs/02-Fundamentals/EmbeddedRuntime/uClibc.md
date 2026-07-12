# uClibc

## 简介

本文说明 uClibc / uClibc-ng 在嵌入式 Linux 中的定位，以及它为什么曾长期出现在 Buildroot、OpenWrt 和网络设备生态中。

## 背景

在 musl 普及之前，uClibc 是很多嵌入式 Linux 发行版和 SDK 的常见选择之一。即使今天新项目不一定继续优先采用它，历史固件和 GPL 发布包中仍然经常能见到。

## 基本概念

uClibc-ng 官方将其定义为适合嵌入式 Linux 的小型 C 库，体积明显小于 GNU C Library，并支持共享库和线程。

## 工作原理

与 glibc、musl 一样，uClibc 是完整 libc 运行环境的一部分。程序如果针对 uClibc 构建，其动态链接器、共享库、符号和 ABI 契约都与该运行时紧密绑定。

## 设计目的

uClibc 的目标主要是：

- 面向嵌入式 Linux
- 提供更小体积
- 在功能与资源之间做折中

## 优缺点

优点：

- 体积较小
- 历史上嵌入式生态应用广

缺点：

- 与 glibc / musl 不二进制兼容
- 现代新项目中的主流程度相对下降

## 典型应用

- 历史 Buildroot 工程
- 历史 OpenWrt 平台
- 老一代网络设备 SDK

## 在 Buildroot 中的位置

Buildroot 长期支持 uClibc-ng 作为目标 libc 之一，许多历史项目围绕它构建。

## 在 OpenWrt 中的位置

OpenWrt 早期长期与 uClibc 生态关系很深，因此很多历史包和老设备固件分析都会遇到它。

## 在光猫中的体现

许多历史光猫、路由器、AP 固件里常见：

- uClibc 风格解释器
- 与 uClibc 绑定的共享库布局
- 历史 SDK 与 GPL 代码包

## 实际案例

把 uClibc 编译的二进制复制到 musl 或 glibc Rootfs，最常见的问题不是源码逻辑，而是运行时契约不同，导致动态装载失败。

## 实践操作

```bash
readelf -l busybox
ldd busybox
strings libc.so* 2>/dev/null | head
```

怎么看：

- `readelf -l`：先看解释器
- `ldd`：看共享库依赖
- `strings`：辅助识别 libc 身份

## 前置知识

- glibc
- musl
- 动态链接器(ld-linux)

## 后续知识

- Sysroot
- Toolchain
- 常见问题

## 知识等级

★★★★ 建议掌握

对历史光猫和历史 OpenWrt / Buildroot 固件分析非常重要。

## 参考资料

- 官方文档：uClibc-ng `https://uclibc-ng.org/`
- 官方源码：uClibc-ng `https://cgit.uclibc-ng.org/cgi/cgit/uclibc-ng.git/`
- 标准：ELF gABI `https://refspecs.linuxfoundation.org/elf/gabi4+/contents.html`
- GPL源码：后续结合历史 GPL Rootfs 与 SDK 验证
- 论坛：恩山无线论坛 `https://www.right.com.cn/forum/`、ChinaDSL `https://www.chinadsl.net/`、吾爱破解 `https://www.52pojie.cn/`
- 博客：Bootlin `https://bootlin.com/`

## 最后验证时间

更新时间：2026-07-12

适用版本：uClibc / uClibc-ng 通用运行时知识

验证环境：uClibc-ng 官方资料与历史嵌入式生态整理

作者：Codex
