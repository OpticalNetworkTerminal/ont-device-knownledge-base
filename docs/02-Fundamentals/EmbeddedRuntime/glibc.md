# glibc

## 简介

本文说明 glibc 在 Linux 嵌入式运行环境中的位置，以及为什么 glibc 程序不能直接与 musl / uClibc 环境混用。

## 背景

glibc 是 GNU C Library，是 GNU/Linux 世界最常见的 libc 实现之一。很多桌面和服务器 Linux 都默认采用 glibc，但嵌入式设备并不总是这样选。

## 基本概念

glibc 提供：

- C 标准库接口
- POSIX 接口的大量实现
- 动态链接运行时支持
- 多线程、locale、NSS 等大量运行时基础设施

## 工作原理

应用程序在编译和链接时，会绑定到 glibc 提供的头文件、启动文件、符号和 ABI 约定。程序运行时还需要匹配 glibc 动态链接器与共享库布局。

## 设计目的

glibc 的目标是提供功能完整、标准兼容度高、面向通用 GNU/Linux 系统的 C 运行时环境。

## 优缺点

优点：

- 兼容性强
- 功能完整
- 桌面和服务器生态成熟

缺点：

- 体积和复杂度通常高于 musl / uClibc-ng
- 对极小 Rootfs 不一定最经济

## 典型应用

- 通用 Linux 发行版
- 资源较充足的嵌入式系统
- 某些厂商 SDK

## 在 Buildroot 中的位置

Buildroot 支持 glibc 作为目标 libc 之一。选择它意味着整套 Rootfs、动态链接器和共享库布局都围绕 glibc 构建。

## 在 OpenWrt 中的位置

OpenWrt 历史上更多采用轻量 libc 路线，但理解 glibc 对比仍非常重要，因为很多外部二进制、SDK 和开发者预期都以 glibc 为基准。

## 在光猫中的体现

某些资源更充足或 SDK 继承历史较深的系统可能采用 glibc，但很多资源受限设备会偏向更轻量的 libc。

## 实际案例

把 glibc 动态程序复制到 musl Rootfs，常见问题包括：

- 动态链接器路径不同
- 所需 glibc 符号版本不存在
- libc 行为差异导致加载或运行失败

## 实践操作

```bash
ldd busybox
readelf -l busybox
strings /lib/libc.so.6 | head
```

怎么看：

- `ldd`：看是否依赖 glibc 风格库
- `readelf -l`：看解释器路径
- `strings libc.so.6`：辅助识别 glibc 版本信息

## 前置知识

- 动态链接
- 动态链接器(ld-linux)
- ABI

## 后续知识

- musl
- uClibc
- Sysroot

## 知识等级

★★★★★ 必须掌握

对理解“为什么不能混用 libc”至关重要。

## 参考资料

- 官方文档：glibc Manual `https://sourceware.org/glibc/manual/`
- 官方源码：glibc `https://sourceware.org/git/?p=glibc.git`
- 标准：ELF gABI `https://refspecs.linuxfoundation.org/elf/gabi4+/contents.html`
- GPL源码：后续结合采用 glibc 的 Rootfs / SDK 验证
- 论坛：恩山无线论坛 `https://www.right.com.cn/forum/`、ChinaDSL `https://www.chinadsl.net/`、吾爱破解 `https://www.52pojie.cn/`
- 博客：Bootlin `https://bootlin.com/`

## 最后验证时间

更新时间：2026-07-12

适用版本：glibc 通用运行时知识

验证环境：glibc 官方文档与通用 Linux 运行环境整理

作者：Codex
