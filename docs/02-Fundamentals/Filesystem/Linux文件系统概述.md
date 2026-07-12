# Linux文件系统概述

## 简介

本文从嵌入式视角概览 Linux 文件系统家族，解释为什么同样叫“文件系统”，块设备文件系统、raw flash 文件系统、只读压缩文件系统和伪文件系统的设计目标完全不同。

## 背景

桌面 Linux 讨论文件系统时常聚焦 `ext4` 或 `xfs`，但嵌入式世界同时要面对 NOR/NAND Flash、只读 Rootfs、升级包封装和运行时伪文件系统，因此必须先做分类。

## 基本概念

- 块设备文件系统：运行在磁盘、eMMC、SSD 之上的 `ext4`、`f2fs`
- raw flash 文件系统：运行在 `MTD` / `UBI` 之上的 `JFFS2`、`UBIFS`
- 只读镜像文件系统：如 `SquashFS`
- 伪文件系统：如 `procfs`、`sysfs`、`devtmpfs`、`tmpfs`
- 组织层概念：`Rootfs`、Overlay、firmware image

## 工作原理

嵌入式系统通常把“存储介质特性”“升级模式”“是否可写”“是否需要压缩”一起考虑，再决定根文件系统和可写层的组合，而不是只看 POSIX 语义。

## 设计目的

- 用统一分类方法理解后续所有具体文件系统
- 避免把 raw flash 和块设备混成一类
- 为 Overlay、固件解包和分区分析建立前提

## 优缺点

优点：

- 层次清晰，便于后续映射到 Buildroot / OpenWrt / 设备现场
- 能快速解释很多“为什么不能直接 mount”的问题

缺点：

- 只是总览，细节仍需进入各专题文档
- 不同项目命名和分区布局会让同一概念表现不同

## 典型应用

- 判断 Rootfs 应该选 `SquashFS` 还是 `ext4`
- 理解为什么 `UBIFS` 必须搭配 `UBI`
- 区分 `/proc` 和持久化文件系统

## 在 Buildroot 中的位置

Buildroot 本质上是在同一份目标文件树基础上输出多种文件系统镜像，因此本概览是理解 `Filesystem images` 菜单的入口。

## 在 OpenWrt 中的位置

OpenWrt 把 `SquashFS`、`JFFS2`/`UBIFS`、Overlay 和运行时伪文件系统同时组合使用，是嵌入式文件系统分层设计的经典样本。

## 在光猫中的体现

光猫、路由器、Mesh 设备常见的稳定性策略就是把系统本体保持只读，把配置和状态写入单独区域，以降低断电和写损坏风险。

## 实际案例

为什么桌面 Linux 常见 `ext4`，而路由器固件里经常看到 `SquashFS`？因为后者更看重只读压缩和升级安全，而不是长期在线随机写。

## 实践操作

```bash
cat /proc/filesystems
lsblk 2>/dev/null
blkid 2>/dev/null
mount | head -n 30
```

怎么看：

- `/proc/filesystems`：看内核识别的文件系统家族
- `lsblk` / `blkid`：看块设备世界的文件系统
- `mount`：同时观察块设备文件系统、伪文件系统和 Overlay 的共存

## 前置知识

- [README](./README.md)
- [LinuxRuntime/VFS](../LinuxRuntime/VFS.md)
- [Buildroot/Filesystem生成](../Buildroot/Filesystem生成.md)

## 后续知识

- [Rootfs](./Rootfs.md)
- [Flash存储特点](./Flash存储特点.md)
- [Firmware文件结构](./Firmware文件结构.md)

## 知识等级

★★★★★ 必须掌握

## 参考资料

- 官方文档：Linux Kernel Filesystems Docs `https://docs.kernel.org/filesystems/index.html`
- 官方文档：Buildroot Manual `https://nightly.buildroot.org/manual.html`
- 标准：mount / proc 相关 man pages `https://man7.org/linux/man-pages/`
- 博客：Bootlin `https://bootlin.com/`

## 最后验证时间

更新时间：2026-07-12

适用版本：Linux 文件系统分类通用知识

验证环境：Kernel / Buildroot / OpenWrt / MTD 文档整理

作者：Codex
