# Signal

## 简介

本文说明 signal 的作用，以及为什么 Linux 用它来表达终止、重载、挂起和异常通知。

## 背景

系统服务运行时不可能只靠轮询来管理。signal 为进程提供了一种轻量、异步的通知机制。

## 基本概念

signal 是内核向进程或线程传递的一类异步事件通知。

## 工作原理

当用户、内核或其他进程发送 signal 后，目标任务会按默认动作或注册处理器进行响应。

## 设计目的

提供统一异步控制机制，表达终止、挂起、继续、重载、异常等语义。

## 优缺点

优点：轻量、通用。

缺点：异步语义调试较复杂。

## 典型应用

- `SIGTERM`
- `SIGHUP`
- `SIGKILL`

## 在 Buildroot 中的位置

Buildroot 设备上的 daemon、shell 和 init 脚本都常利用 signal 进行停止、重载和回收。

## 在 OpenWrt 中的位置

OpenWrt 的服务管理和脚本也高度依赖 signal 实现启停和重载。

## 在光猫中的体现

光猫里的 Web 服务、DBus 服务和网络守护进程通常都会对特定 signal 做出退出或重载配置响应。

## 实际案例

为什么 `kill -HUP` 常被用来重载配置？因为很多长期运行 daemon 约定在收到 `SIGHUP` 时重新读取配置而不是完全退出。

## 实践操作

```bash
kill -l
cat /proc/self/status | grep Sig
```

怎么看：看 signal 名称、编号，以及当前进程的 signal mask。

## 前置知识

- PID与进程
- 线程

## 后续知识

- Daemon
- Init系统

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
