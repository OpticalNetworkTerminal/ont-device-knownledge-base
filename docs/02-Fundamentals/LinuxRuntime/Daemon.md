# Daemon

## 简介

本文说明 daemon 的含义，以及为什么 Linux 系统启动后会长期保留大量后台进程。

## 背景

嵌入式 Linux 不是执行完一个脚本就结束的系统。网络、日志、管理、Web、IPC 都需要长期在线，所以 daemon 是运行时基本构件。

## 基本概念

daemon 指长期驻留后台、通常不直接绑定交互终端、负责某种持续功能的进程。

## 工作原理

daemon 一般由 init 或服务管理器拉起，之后长期等待连接、消息、定时器或设备事件。

## 设计目的

把系统功能拆成长期驻留的服务，便于独立启停、监控和重启。

## 优缺点

优点：结构清晰，易独立管理。

缺点：服务多时资源开销增加。

## 典型应用

- Web 服务
- `dbus-daemon`
- 网络管理服务
- 远程运维服务

## 在 Buildroot 中的位置

Buildroot 常通过 init 脚本、overlay 和服务配置把 daemon 纳入 Rootfs。

## 在 OpenWrt 中的位置

OpenWrt 借助 `procd` 更系统地管理 daemon 生命周期。

## 在光猫中的体现

光猫的 Web、CLI、TR-069、IPC、日志和网络控制能力，几乎都依赖 daemon 常驻运行。

## 实际案例

为什么设备没人登录时仍然能被 Web 页面访问、能收到远程管理请求？因为后台一直有对应 daemon 在监听。

## 实践操作

```bash
ps -ef | head -n 30
ss -lntup
```

怎么看：`ps` 找长期驻留进程，`ss` 看哪些 daemon 正在监听。

## 前置知识

- PID与进程
- Init系统

## 后续知识

- Socket
- 日志系统

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
