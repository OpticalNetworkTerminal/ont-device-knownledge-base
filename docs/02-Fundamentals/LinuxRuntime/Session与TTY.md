# Session与TTY

## 简介

本文说明 session、控制终端、TTY 的含义，以及为什么 `ps` 输出里会出现 `TTY` 一列。

## 背景

很多人知道 shell 和终端，但不一定知道为什么某些后台服务显示 `?`，某些交互进程显示 `pts/0` 或 `ttyS0`。

## 基本概念

- TTY：终端抽象
- session：一组相关进程的会话
- 控制终端：与某个 session 关联的终端

## 工作原理

交互式 shell 一般拥有控制终端，并以此启动前台和后台作业。daemon 常常会脱离终端，因此 `ps` 中的 TTY 往往为空或 `?`。

## 设计目的

支持登录会话、作业控制、终端信号传播和串口/伪终端交互。

## 优缺点

优点：

- 交互模型清晰
- shell 与串口行为可控

缺点：

- 概念偏传统，初学者不直观

## 典型应用

- 控制台登录
- 串口 shell
- SSH shell
- daemon 脱离终端

## 在 Buildroot 中的位置

Buildroot 设备常依赖串口 console 和 `/dev/console` 提供早期交互。

## 在 OpenWrt 中的位置

OpenWrt 同样依赖 console、串口和登录 shell；`procd` 启动服务时通常不依赖交互终端。

## 在光猫中的体现

光猫常见的 UART 调试、串口控制台和维护 shell，全都建立在 TTY 模型上。

## 实际案例

为什么 `ps` 里有的进程 TTY 是 `ttyS0`、有的是 `pts/0`、有的是 `?`？因为它们和控制终端的关系不同。

## 实践操作

```bash
ps -ef
tty
ls -l /dev/tty* 2>/dev/null | head
```

怎么看：

- `ps`：看 TTY 列
- `tty`：看当前 shell 绑定的终端

## 前置知识

- PID与进程
- Devtmpfs

## 后续知识

- Shell
- Daemon

## 知识等级

★★★★ 建议掌握

## 参考资料

- 官方文档：ps(1) `https://man7.org/linux/man-pages/man1/ps.1.html`
- 官方源码：Linux kernel `https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git`
- 标准：Linux man-pages `https://man7.org/linux/man-pages/`
- GPL源码：后续结合 console 与登录进程验证
- 论坛：恩山无线论坛 `https://www.right.com.cn/forum/`、ChinaDSL `https://www.chinadsl.net/`、吾爱破解 `https://www.52pojie.cn/`
- 博客：LWN `https://lwn.net/`

## 最后验证时间

更新时间：2026-07-12

适用版本：Linux TTY 与 session 通用知识

验证环境：man7 与运行时实践整理

作者：Codex
