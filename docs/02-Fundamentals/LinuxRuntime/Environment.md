# Environment

## 简介

本文说明环境变量在 Linux 运行时中的位置，以及为什么它们会影响 shell、daemon、动态链接和程序行为。

## 背景

环境变量看起来像简单键值对，但它们是进程启动上下文的一部分，会影响程序如何找命令、找库、判断运行模式。

## 基本概念

environment 是进程启动时继承的一组字符串键值对。

## 工作原理

父进程在创建子进程时，可以把自己的环境传下去或进行修改。子进程启动后，会在自身地址空间里持有这组环境。

## 设计目的

提供轻量上下文传递方式，让程序行为可按运行时场景调整。

## 优缺点

优点：简单、通用。

缺点：容易隐式影响程序行为。

## 典型应用

- `PATH`
- `HOME`
- `TERM`

## 在 Buildroot 中的位置

Buildroot 设备虽然环境更简，但 shell、脚本和维护工具仍会依赖环境变量。

## 在 OpenWrt 中的位置

OpenWrt 中环境变量常用于 shell 脚本、服务启动上下文和调试。

## 在光猫中的体现

光猫里的 shell、维护脚本和 CLI 启动方式，也会受环境影响，只是通常比桌面系统更克制。

## 实际案例

为什么同一个命令在交互 shell 能跑，在 daemon 里却找不到？因为 daemon 启动时环境变量，特别是 `PATH`，可能完全不同。

## 实践操作

```bash
env | head -n 50
cat /proc/self/environ | tr "\0" "\n" | head -n 50
echo $PATH
```

怎么看：看当前环境、进程真实环境和命令搜索路径。

## 前置知识

- Shell
- PID与进程

## 后续知识

- 动态链接
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
