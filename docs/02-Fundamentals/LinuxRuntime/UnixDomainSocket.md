# UnixDomainSocket

## 简介

本文说明 Unix Domain Socket 的作用，以及为什么 DBus、`procd` 和本地守护进程常使用它。

## 背景

并不是所有进程间通信都需要走 TCP/IP。对于同一台设备上的本地进程，Unix Domain Socket 往往更轻、更自然。

## 基本概念

Unix Domain Socket 是一种本地 IPC socket，常以路径名出现在文件系统中，例如 `/var/run/...`。

## 工作原理

一个进程在本地路径上创建 socket 节点后，其他进程可通过该路径连接；数据不经过外部网络接口。

## 设计目的

为本地 IPC 提供高效统一接口，并能结合文件路径和权限做访问控制。

## 优缺点

优点：轻量、本地通信开销低。

缺点：不适用于跨主机通信。

## 典型应用

- DBus
- `procd`
- 本地管理服务

## 在 Buildroot 中的位置

Buildroot 系统中的本地管理服务和 IPC 总线常常使用 Unix Domain Socket。

## 在 OpenWrt 中的位置

OpenWrt 的 `ubus`、`procd` 等本地控制面高度依赖 Unix socket。

## 在光猫中的体现

光猫里的本地配置服务、管理面、DBus 或私有总线类组件，经常通过 `/var/run` 或 `/tmp` 下的 Unix socket 互联。

## 实际案例

为什么 DBus 使用 Unix Socket？因为它主要解决本地进程间通信，Unix socket 足够轻量，还能借助文件路径和权限模型做控制。

## 实践操作

```bash
find / -type s 2>/dev/null | head -n 50
ss -xl
ls -l /var/run 2>/dev/null | head -n 30
```

怎么看：找路径型 Unix socket，并结合 `ss -xl` 看本地套接字列表。

## 前置知识

- Socket
- VFS

## 后续知识

- DBus
- IPC
- 权限模型

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
