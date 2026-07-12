# devtmpfs

## 简介

本文从文件系统章节视角说明 `devtmpfs` 在 `/dev` 中扮演的角色，以及为什么它是许多嵌入式系统设备访问的基础。

## 背景

很多人会把 `/dev` 想成普通目录或静态文件集合，但现代系统里它往往是 `devtmpfs` 视图，再叠加 `mdev`/`udev` 策略。

## 基本概念

- `devtmpfs`：由内核维护的设备文件系统
- 负责在设备识别后提供基础设备节点视图

## 工作原理

内核识别设备并注册主次设备号后，`devtmpfs` 可为其提供节点；用户态设备管理器再决定权限、命名和符号链接。

## 设计目的

- 让系统在启动早期就拥有可用 `/dev`
- 减少完全依赖用户态创建设备节点的复杂度

## 优缺点

优点：

- 启动早期可用
- 与设备探测自然联动

缺点：

- 高级命名规则仍需用户态补充
- 容易被误当普通目录

## 典型应用

- 串口 console
- MTD 设备节点
- loop 设备节点

## 在 Buildroot 中的位置

Buildroot 在 `/dev management` 里专门提供 `devtmpfs` 相关选项，这是系统能否顺利启动的重要条件之一。

## 在 OpenWrt 中的位置

OpenWrt 同样依赖现代 `/dev` 管理，让设备节点与 hotplug 行为协调。

## 在光猫中的体现

光猫现场是否能看到 `/dev/mtd*`、`/dev/ttyS*`、`/dev/loop*`，经常直接决定后续分析与维护能力。

## 实际案例

为什么一个极简系统没有手工创建 `/dev/null` 却仍能正常工作？因为 `devtmpfs` 已经在启动时提供了基础节点。

## 实践操作

```bash
mount | grep " /dev "
ls -l /dev | head -n 30
ls -l /dev/mtd* 2>/dev/null | head
```

怎么看：

- `mount`：确认 `/dev` 是否由 `devtmpfs` 挂载
- `ls -l /dev`：看节点类型与链接
- `/dev/mtd*`：可快速判断系统是否暴露 raw flash 入口

## 前置知识

- [LinuxRuntime/Devtmpfs](../LinuxRuntime/Devtmpfs.md)
- [Device Node](./Device Node.md)

## 后续知识

- [MTD](./MTD.md)
- [LoopDevice](./LoopDevice.md)

## 知识等级

★★★★ 建议掌握

## 参考资料

- 官方文档：Kernel filesystems docs `https://docs.kernel.org/filesystems/index.html`
- 官方文档：Buildroot Manual `/dev management` `https://nightly.buildroot.org/manual.html`

## 最后验证时间

更新时间：2026-07-12

适用版本：devtmpfs 的文件系统分析视角

验证环境：Kernel / Buildroot / OpenWrt / MTD 文档整理

作者：Codex
