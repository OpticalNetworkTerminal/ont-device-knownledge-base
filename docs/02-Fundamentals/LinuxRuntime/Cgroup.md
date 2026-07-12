# Cgroup

## 简介

本文说明 cgroup 的作用，以及为什么容器和服务管理系统能限制 CPU、内存和进程数量。

## 背景

namespace 解决看见什么的问题，cgroup 更偏向解决能用多少的问题。没有资源控制，容器和复杂服务治理很难稳定运行。

## 基本概念

cgroup 用于对一组进程进行资源分组和限制，例如 CPU、内存、I/O、进程数。

## 工作原理

内核把进程挂入某个 cgroup 层级后，会按对应控制器规则统计和限制资源使用。

## 设计目的

控制资源分配，做服务和容器资源治理。

## 优缺点

优点：粒度清晰，与容器协作良好。

缺点：模型较复杂。

## 典型应用

- systemd 服务资源控制
- 容器 CPU/内存限制

## 在 Buildroot 中的位置

Buildroot 可构建带 cgroup 支持的内核和用户态工具，但是否启用取决于设备复杂度。

## 在 OpenWrt 中的位置

OpenWrt 若引入容器或更复杂服务编排，也会利用 cgroup。

## 在光猫中的体现

高复杂度网关若引入容器或多业务隔离，cgroup 往往成为资源治理基础。

## 实际案例

为什么容器里看起来像独立系统，但 CPU 和内存仍能被宿主精确卡住？因为 namespace 提供视图隔离，cgroup 提供资源控制。

## 实践操作

```bash
mount | grep cgroup
cat /proc/self/cgroup
ls /sys/fs/cgroup 2>/dev/null | head -n 30
```

怎么看：看当前进程属于哪些 cgroup，以及系统暴露了哪些控制器。

## 前置知识

- Namespace
- Sysfs

## 后续知识

- LXC
- 权限模型

## 知识等级

★★★★ 建议掌握

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
