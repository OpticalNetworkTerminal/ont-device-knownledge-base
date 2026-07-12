# Init系统

## 简介

本文说明 init 系统的角色，以及为什么嵌入式 Linux 常见 BusyBox init，而 OpenWrt 使用 `procd`。

## 背景

Kernel 启动之后必须有一个用户态进程接手系统，把挂载、服务、重启策略和长期运行组织起来，这就是 init 系统。

## 基本概念

init 通常负责：作为 PID 1 运行、挂载关键运行时文件系统、启动 daemon、回收孤儿进程并维持系统可用。

## 工作原理

PID 1 启动后读取配置或脚本，拉起系统服务，并长期维持系统进入可用状态。

## 设计目的

把用户态系统组织从内核中分离出来，让不同系统按复杂度选不同模型。

## 优缺点

BusyBox init 优点：小、简单、适合嵌入式。

`procd` 优点：更贴近 OpenWrt 网络设备场景。

systemd 优点：服务依赖和资源管理更完整。

## 典型应用

- Buildroot：BusyBox init 常见
- OpenWrt：`procd`
- 通用发行版：systemd

## 在 Buildroot 中的位置

Buildroot 官方手册明确建议，大多数嵌入式系统使用 BusyBox init 已经足够。

## 在 OpenWrt 中的位置

OpenWrt 以 `procd` 为核心，配合 init 脚本、`ubus` 和热插拔逻辑管理服务。

## 在光猫中的体现

光猫大量采用轻量 init，本质原因是资源有限、功能固定、启动路径要可控。

## 实际案例

为什么 OpenWrt 不直接只靠 BusyBox init？因为网络设备需要更强的服务重启、配置联动和运行时编排能力。

## 实践操作

```bash
ps -p 1 -f
cat /proc/1/status
ls /etc/init.d 2>/dev/null | head
ls /etc/rc.d 2>/dev/null | head
```

怎么看：先确认 PID 1，再看 `init.d` 和 `rc.d` 组织方式。

## 前置知识

- Linux启动流程

## 后续知识

- Daemon
- 日志系统
- OpenWrt

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
