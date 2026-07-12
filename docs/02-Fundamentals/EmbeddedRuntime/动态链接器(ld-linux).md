# 动态链接器(ld-linux)

## 简介

本文说明动态链接器的作用，以及为什么很多嵌入式设备上最迷惑人的错误其实都和它有关。

## 背景

很多人遇到过这种情况：

- 文件存在
- 权限正确
- 但执行时报 `No such file or directory`

这类问题经常不是程序本身丢了，而是 ELF 指定的动态链接器路径在目标系统不存在。

## 基本概念

动态链接器是运行时负责装入共享库、解析符号并把控制权转给主程序的组件。常见名字如：

- `ld-linux.so.*`
- `ld-linux-armhf.so.3`
- `ld-musl-*.so.1`

## 工作原理

ELF Program Header 中的 `INTERP` 字段会记录解释器路径。内核执行动态程序时，会先装载这里指定的解释器，再由解释器装入其余共享库。

## 设计目的

- 将共享库装载逻辑从内核中分离
- 支持运行时依赖解析
- 支持同一系统上多个程序共享基础库

## 优缺点

优点：

- 支持动态链接生态
- 让共享库复用成为可能

缺点：

- 路径必须精确匹配
- 与 libc 和 ABI 紧密绑定

## 典型应用

- glibc 动态程序
- musl 动态程序
- OpenWrt / Buildroot 的多数动态可执行文件

## 在 Buildroot 中的位置

Buildroot 会把目标 libc 对应的动态链接器放入 Rootfs，并保证程序在该 Rootfs 内可被正确装载。

## 在 OpenWrt 中的位置

OpenWrt Rootfs 也包含目标 libc 的解释器路径；包若来自不同运行环境，即使程序文件拷贝成功也可能无法执行。

## 在光猫中的体现

光猫 Rootfs 中常见的兼容性陷阱就是：

- 解释器路径不同
- glibc / musl / uClibc 动态链接器不同
- 32 位 / 64 位解释器不同

## 实际案例

一个二进制在 A 设备上依赖 `/lib/ld-linux-armhf.so.3`，而 B 设备只有 musl 的 `ld-musl-armhf.so.1`。这时执行错误看起来像“文件不存在”，但真正缺的是解释器。

## 实践操作

```bash
readelf -l busybox
file busybox
ldd busybox
```

怎么看：

- `readelf -l`：最关键，直接看 `interpreter`
- `file`：辅助看架构和动态/静态属性
- `ldd`：确认最终依赖解析

## 前置知识

- ELF文件格式
- 动态链接

## 后续知识

- glibc
- musl
- uClibc

## 知识等级

★★★★★ 必须掌握

对光猫逆向、Rootfs 分析和二进制兼容性排查非常关键。

## 参考资料

- 官方文档：ELF gABI Program Interpreter / Dynamic Linker `https://refspecs.linuxfoundation.org/elf/gabi4+/contents.html`
- 官方源码：glibc `https://sourceware.org/glibc/manual/`、musl `https://musl.libc.org/`
- 标准：ELF Program Header `https://refspecs.linuxfoundation.org/elf/gabi4+/contents.html`
- GPL源码：后续结合 Rootfs `/lib/ld-*` 实例验证
- 论坛：恩山无线论坛 `https://www.right.com.cn/forum/`、ChinaDSL `https://www.chinadsl.net/`、吾爱破解 `https://www.52pojie.cn/`
- 博客：Bootlin `https://bootlin.com/`

## 最后验证时间

更新时间：2026-07-12

适用版本：Linux 动态链接器通用知识

验证环境：ELF 标准与 readelf/ldd 实践整理

作者：Codex
