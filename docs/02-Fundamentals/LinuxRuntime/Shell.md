# Shell

## 简介

本文说明 shell 在 Linux 运行时中的角色，以及为什么 shell 不只是“命令解释器”，还是脚本编排和系统 glue 的重要入口。

## 背景

在嵌入式 Linux 中，shell 既是调试入口，也是启动脚本、维护脚本和故障恢复脚本的执行环境。

## 基本概念

shell 负责：

- 读取命令
- 启动子进程
- 管理重定向、管道和环境继承
- 执行脚本

## 工作原理

shell 通过 fork/exec 启动子进程，并管理前台后台作业、标准输入输出和环境变量。

## 设计目的

给用户态提供统一交互和脚本入口。

## 优缺点

优点：

- 灵活
- 适合快速编排和调试

缺点：

- 复杂逻辑写成 shell 后可维护性一般

## 典型应用

- `/bin/sh`
- BusyBox `ash`
- init 脚本
- 运维脚本

## 在 Buildroot 中的位置

Buildroot 设备默认常见 BusyBox shell，它承担启动脚本和维护脚本执行角色。

## 在 OpenWrt 中的位置

OpenWrt 中 shell 广泛用于 init 脚本、热插拔脚本和现场维护。

## 在光猫中的体现

光猫里的 CLI、恢复模式、工程模式和很多 glue 逻辑，都依赖轻量 shell。

## 实际案例

为什么某些系统二进制很少，但行为很复杂？因为不少控制逻辑并不在单个 C 程序里，而是散落在 shell 脚本中。

## 实践操作

```bash
echo $SHELL
ps -ef | grep '[s]h'
cat /proc/$$/cmdline | tr '\0' ' '
env | head
```

怎么看：

- `$SHELL`：看当前默认 shell
- `ps`：看 shell 进程
- `/proc/$$/cmdline`：看当前 shell 实际启动方式

## 前置知识

- PID与进程
- Session与TTY

## 后续知识

- Environment
- SystemCall

## 知识等级

★★★★ 建议掌握

## 参考资料

- 官方文档：Linux man-pages `https://man7.org/linux/man-pages/`
- 官方源码：BusyBox `https://git.busybox.net/busybox/`
- 标准：POSIX shell 相关资料
- GPL源码：后续结合 init 脚本与维护脚本验证
- 论坛：恩山无线论坛 `https://www.right.com.cn/forum/`、ChinaDSL `https://www.chinadsl.net/`、吾爱破解 `https://www.52pojie.cn/`
- 博客：Bootlin `https://bootlin.com/`

## 最后验证时间

更新时间：2026-07-12

适用版本：Linux shell 运行时通用知识

验证环境：BusyBox / 运行时实践整理

作者：Codex
