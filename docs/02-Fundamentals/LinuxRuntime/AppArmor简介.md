# AppArmor简介

## 简介

本文简要说明 AppArmor 的定位，以及它与 SELinux 在工程取舍上的差异。

## 背景

Linux 强制访问控制并不只有 SELinux。AppArmor 以更偏路径和应用配置的方式提供约束，在某些系统上更易上手。

## 基本概念

AppArmor 是 Linux Security Module 体系中的一种应用约束机制，常以 profile 形式限制程序可访问的路径和能力。

## 工作原理

当进程访问文件、执行程序、使用某些能力时，内核会结合 AppArmor profile 做额外访问判定。

## 设计目的

为应用提供较易理解的强制访问控制，以 profile 模型限制进程行为。

## 优缺点

优点：相对更易上手。

缺点：仍有维护成本，在轻量嵌入式里不是最常见默认选项。

## 典型应用

- 桌面和服务器应用隔离
- 某些容器场景

## 在 Buildroot 中的位置

Buildroot 若服务于更复杂 Linux 产品，也可承载此类机制，但多数轻量网络设备未必默认启用。

## 在 OpenWrt 中的位置

OpenWrt 默认更强调轻量运行时，不常把 AppArmor 作为核心默认能力。

## 在光猫中的体现

光猫系统通常优先考虑轻量和稳定性，AppArmor 不是最常见默认路线，但理解它有助于建立“经典权限之外还有一层”的安全视角。

## 实际案例

为什么某个程序在文件权限上看似允许，运行时仍被拦？如果系统启用了 LSM 强制控制，路径权限只是第一层。

## 实践操作

```bash
aa-status 2>/dev/null
```

怎么看：若系统支持，可查看 profile 状态。

## 前置知识

- 权限模型
- Capability

## 后续知识

- Security
- LXC

## 知识等级

★★★ 了解即可

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
