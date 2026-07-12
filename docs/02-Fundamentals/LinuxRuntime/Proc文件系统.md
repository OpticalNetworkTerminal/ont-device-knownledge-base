# Proc文件系统

## 简介

本文说明 `/proc` 的作用，以及为什么它看起来像文件系统，但里面的大多数内容并不来自磁盘上的真实文件。

## 背景

`ps`、`top`、`free`、`uptime` 等大量工具都依赖 `/proc`。如果不理解 procfs，就很难理解 Linux 运行时观察面。

## 基本概念

`/proc` 是伪文件系统，用于把内核中的进程状态和系统状态以文件接口形式暴露给用户态。

## 工作原理

Kernel 文档和 `proc(5)` 都强调，procfs 是内核数据结构的接口。读取 `/proc/<pid>/status` 时，看到的是内核当场生成的内容，而不是从磁盘读到的文本。

## 设计目的

让用户态以统一文件接口读取内核状态，让脚本和工具可以轻量观察系统。

## 优缺点

优点：通用、易脚本化。

缺点：不是普通文件语义。

## 典型应用

- `/proc/<pid>/status`
- `/proc/cpuinfo`
- `/proc/mounts`
- `/proc/sys`

## 在 Buildroot 中的位置

Buildroot 设备启动后通常会尽早挂载 `/proc`，否则大量基础工具和脚本都无法正常工作。

## 在 OpenWrt 中的位置

OpenWrt 同样依赖 `/proc` 提供系统状态、进程和 sysctl 视图。

## 在光猫中的体现

光猫调试时，`/proc` 往往是最重要的观测面：看进程、挂载、CPU、内存、sysctl 参数都会经过它。

## 实际案例

为什么 `ps` 能显示进程树？因为它主要是在遍历 `/proc` 下的 PID 目录并解析其中的状态文件。

## 实践操作

```bash
ls /proc | head -n 30
cat /proc/cpuinfo | head -n 30
cat /proc/mounts | head -n 30
cat /proc/self/maps | head -n 20
```

怎么看：数字目录通常对应 PID，`/proc/mounts` 看挂载状态，`/proc/self/maps` 看当前进程内存映射。

## 前置知识

- VFS
- PID与进程

## 后续知识

- Sysfs
- Mount机制

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
