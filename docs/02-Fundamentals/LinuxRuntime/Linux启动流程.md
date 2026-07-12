# Linux启动流程

## 简介

本文说明内核启动完成后，系统如何一路进入可登录、可联网、可管理的用户态运行阶段。

## 背景

对嵌入式设备来说，真正重要的不是“内核起来了”，而是谁挂载了 `/proc`、`/sys`、`/dev`，谁启动了网络服务和管理服务。

## 基本概念

关键阶段通常包括：内核初始化、挂载根文件系统、启动 PID 1、挂载运行时文件系统、启动 daemon。

## 工作原理

```mermaid
flowchart TD
    A[Bootloader] --> B[Kernel]
    B --> C[Rootfs]
    C --> D[PID 1]
    D --> E[/proc /sys /dev 挂载]
    E --> F[服务启动]
    F --> G[Web CLI IPC 网络就绪]
```

## 设计目的

把硬件初始化、内核初始化和用户态组织解耦，便于移植、裁剪和维护。

## 优缺点

优点：分层清晰。

缺点：排错需要同时看 Bootloader、Kernel、Rootfs、init。

## 典型应用

- Buildroot 固件启动
- OpenWrt 启动
- 路由器和光猫启动

## 在 Buildroot 中的位置

Buildroot 负责把 Rootfs、init、脚本和镜像组装成完整启动链。

## 在 OpenWrt 中的位置

OpenWrt 在用户态启动阶段更多依赖 `procd` 编排服务。

## 在光猫中的体现

光猫启动后常见的链路是：轻量 init 拉起基础挂载，再启动管理、网络和远程运维服务。

## 实际案例

系统能看到内核日志但没有 shell 或 Web，常见根因不是 Kernel 崩了，而是 PID 1、`/dev/console` 或早期挂载失败。

## 实践操作

```bash
dmesg | head -n 40
ps -p 1 -f
mount
cat /proc/1/cmdline | tr "\0" " "
```

怎么看：`dmesg` 看内核早期阶段，`ps -p 1` 看 PID 1 是谁，`mount` 看关键挂载是否完成。

## 前置知识

- Embedded Runtime

## 后续知识

- Init系统
- Proc文件系统
- Devtmpfs

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
