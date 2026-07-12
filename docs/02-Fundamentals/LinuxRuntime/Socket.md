# Socket

## 简介

本文说明 socket 的本质，以及为什么 Linux 会把通信端点做成一种类似文件的对象。

## 背景

很多开发者把 socket 等同于网络 API。从 Linux 运行时视角看，socket 更像是内核提供的一类统一 I/O 对象。

## 基本概念

socket 是通信端点，可用于：

- 网络通信
- 本机进程间通信

## 工作原理

用户态通过 `socket()` 创建 socket 对象，再用 `bind`、`listen`、`connect`、`send`、`recv` 等系统调用与内核通信。

## 设计目的

提供统一通信抽象，让网络和本地 IPC 都复用类似编程模型。

## 优缺点

优点：

- 接口统一
- 易组合多种通信模式

缺点：

- 抽象较强，初学者容易忽略其文件描述符本质

## 典型应用

- TCP
- UDP
- Unix domain socket

## 在 Buildroot 中的位置

Buildroot 产出的绝大多数网络服务和 IPC 服务都会使用 socket。

## 在 OpenWrt 中的位置

OpenWrt 的 Web、RPC、`ubus`、DNS、DHCP 等都依赖 socket。

## 在光猫中的体现

光猫中的 Web 管理、CLI、DBus、TR-069、网络守护进程都大量依赖 socket。

## 实际案例

为什么 socket 也像文件？因为 Linux 把 socket 表示成文件描述符；而 Unix socket 甚至还能映射到文件系统路径。

## 实践操作

```bash
ss -lntup
find / -type s 2>/dev/null | head -n 30
lsof -i 2>/dev/null | head -n 30
```

怎么看：

- `ss`：看监听 socket
- `find -type s`：看 Unix socket 文件
- `lsof`：看进程和 socket 的对应关系

## 前置知识

- VFS
- SystemCall

## 后续知识

- UnixDomainSocket
- DBus

## 知识等级

★★★★★ 必须掌握

## 参考资料

- 官方文档：Linux man-pages `https://man7.org/linux/man-pages/`
- 官方源码：Linux kernel `https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git`
- 标准：socket 相关 man pages
- GPL源码：后续结合监听端口与本地 socket 验证
- 论坛：恩山无线论坛 `https://www.right.com.cn/forum/`、ChinaDSL `https://www.chinadsl.net/`、吾爱破解 `https://www.52pojie.cn/`
- 博客：LWN `https://lwn.net/`

## 最后验证时间

更新时间：2026-07-12

适用版本：Linux socket 通用知识

验证环境：运行时 socket 实践整理

作者：Codex
