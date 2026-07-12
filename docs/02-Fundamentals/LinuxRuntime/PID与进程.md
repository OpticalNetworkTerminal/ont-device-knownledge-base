# PID与进程

## 简介

本文说明进程、PID 和 `ps` 输出背后的含义，以及为什么 Linux 会把系统组织成一棵进程树。

## 背景

很多人会用 `ps`，但不一定知道 PID、PPID、TTY、STAT、CMD 这些列和内核任务模型之间的关系。

## 基本概念

进程是资源和执行上下文的基本组织单位；PID 是进程标识符；PPID 是父进程 ID；PID 1 是用户态根进程。

## 工作原理

`ps` 主要通过读取 `/proc` 中的进程信息，把内核里的任务视图格式化给用户。

## 设计目的

为程序提供独立地址空间、文件描述符表、信号状态和父子关系。

## 优缺点

优点：隔离明确、生命周期清楚。

缺点：服务过多时需要额外管理。

## 典型应用

- shell 启动子进程
- init 拉起 daemon
- Web、CLI、网络服务并行运行

## 在 Buildroot 中的位置

Buildroot Rootfs 启动后最终都表现为一组进程：PID 1、shell、网络进程、日志进程、Web 服务等。

## 在 OpenWrt 中的位置

OpenWrt 同样以进程模型组织服务，只是由 `procd` 负责更多生命周期管理。

## 在光猫中的体现

看光猫运行时时，`ps` 往往是最重要的入口：可以快速判断有哪些管理服务、网络服务和 IPC 服务常驻运行。

## 实际案例

为什么 `ps` 看到的是进程树？因为用户态服务不是平铺出现的，而是由父进程通过 fork/exec 一层层拉起来的。

## 实践操作

```bash
ps
ps -ef
pstree
cat /proc/1/status
cat /proc/self/status
```

怎么看：`ps -ef` 看 PID、PPID、TTY、CMD，`pstree` 看父子关系，`/proc/<pid>/status` 看更底层状态。

## 前置知识

- Linux启动流程

## 后续知识

- 线程
- Daemon
- Session与TTY

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
