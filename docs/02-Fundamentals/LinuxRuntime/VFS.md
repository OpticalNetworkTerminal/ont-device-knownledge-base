# VFS

## 简介

本文说明 VFS 的作用，以及为什么 Linux 能把磁盘文件系统、`/proc`、`/sys`、socket、设备节点都统一放进文件语义里。

## 背景

如果没有 VFS，应用就必须分别学习磁盘文件、设备、内核状态、socket 等不同接口。VFS 的存在，是为了给这些对象提供统一访问模型。

## 基本概念

VFS 即虚拟文件系统层，是内核中统一抽象不同文件系统和文件对象的接口层。

## 工作原理

用户态执行 `open/read/write/stat` 时，并不直接关心底层是 ext4、squashfs、tmpfs、procfs 还是 sysfs。内核通过 VFS 把请求路由到具体实现。

## 设计目的

提供统一文件接口，解耦用户态与具体文件系统实现，让“万物皆文件”在工程上成立。

## 优缺点

优点：接口统一，便于扩展特殊对象。

缺点：统一语义不代表底层行为完全一致。

## 典型应用

- ext4、squashfs
- procfs、sysfs、tmpfs、devtmpfs
- Unix socket 节点
- 设备节点

## 在 Buildroot 中的位置

Buildroot 产出的运行时环境之所以能同时容纳真实文件系统、伪文件系统和设备节点，背后依赖的就是 Linux VFS。

## 在 OpenWrt 中的位置

OpenWrt 的 overlay、`/proc`、`/sys`、socket 和配置目录也都建立在同一 VFS 统一视图中。

## 在光猫中的体现

理解 VFS 才能明白：为什么 `/proc` 没有真实文件，为什么 `/sys` 可写，为什么 `socket` 也能出现在路径里。

## 实际案例

为什么 DBus 常用 Unix socket，而这个 socket 又会出现在文件路径里？因为 Linux 把 socket 也纳入了统一文件对象语义的一部分。

## 实践操作

```bash
ls -l /proc /sys /dev 2>/dev/null
find / -type s 2>/dev/null | head
cat /proc/mounts | head -n 30
```

怎么看：比较真实文件系统和伪文件系统挂载类型，观察 `s` 类型 socket 文件。

## 前置知识

- Mount机制
- SystemCall

## 后续知识

- Socket
- UnixDomainSocket
- Proc文件系统

## 知识等级

★★★★★ 必须掌握

## 参考资料

- 官方文档：Linux Kernel Docs `https://docs.kernel.org/`、Buildroot Manual `https://buildroot.org/manual.html`、OpenWrt Docs `https://openwrt.org/docs/start`
- 官方源码：Linux kernel `https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git`、OpenWrt `https://github.com/openwrt/openwrt`
- 标准：Linux man-pages `https://man7.org/linux/man-pages/`
- GPL源码：后续结合 Rootfs、init 脚本、socket、容器配置和运行时目录验证
- 论坛：恩山无线论坛 `https://www.right.com.cn/forum/`、ChinaDSL `https://www.chinadsl.net/`、吾爱破解 `https://www.52pojie.cn/`
- 博客：Bootlin `https://bootlin.com/`、LWN `https://lwn.net/`


## 最后验证时间

更新时间：2026-07-12

适用版本：Linux 系统运行机制通用知识

验证环境：Kernel 文档、man7、Buildroot / OpenWrt 文档整理

作者：Codex
