# Ext2_Ext3_Ext4

## 简介

本文说明 `ext2/ext3/ext4` 在嵌入式中的定位，以及为什么它们更像块设备世界的根文件系统选择。

## 背景

很多软件开发者对 Linux 文件系统的直觉来自 `ext4`，但这套直觉并不能直接迁移到 raw flash 设备。

## 基本概念

- `ext2/ext3/ext4`：工作在块设备之上的经典 Linux 文件系统家族
- `ext4` 是最常见现实选择

## 工作原理

它们依赖的是块设备接口与页缓存模型，适合 eMMC、SSD、SATA、NVMe 这类设备；并不直接处理 raw flash 的坏块与擦除管理。

## 设计目的

- 说明经典块设备文件系统在嵌入式中的边界
- 帮助区分“能用 ext4”和“必须用 UBI/UBIFS”的场景

## 优缺点

优点：

- 生态成熟
- 工具链和恢复手段丰富

缺点：

- 直接用于 raw flash 通常不合适
- 对只读压缩交付不如 `SquashFS` 高效

## 典型应用

- eMMC Rootfs
- 开发调试镜像
- NAS 数据分区

## 在 Buildroot 中的位置

Buildroot 可直接输出 `ext2/3/4` 镜像，是开发板、eMMC 设备和调试环境的常见选项。

## 在 OpenWrt 中的位置

OpenWrt 在块设备扩展存储、USB Rootfs 或特定平台中也会接触 `ext4`，但默认系统基线并不总以其为核心。

## 在光猫中的体现

NAS、部分高端网关和带 eMMC 的设备比纯 Flash 路由器更可能直接使用 `ext4`。

## 实际案例

为什么 `ext4` 在 NAS 和 eMMC 设备中常见，在 raw NAND 路由器里却没那么常见？因为下层介质抽象完全不同。

## 实践操作

```bash
cat /proc/filesystems | grep ext
lsblk 2>/dev/null
blkid 2>/dev/null
```

怎么看：

- `/proc/filesystems`：看内核支持
- `lsblk` / `blkid`：看现场块设备是否已格式化为 `ext*`

## 前置知识

- [Linux文件系统概述](./Linux文件系统概述.md)
- [BlockDevice与CharacterDevice](./BlockDevice与CharacterDevice.md)

## 后续知识

- [F2FS](./F2FS.md)
- [Firmware文件结构](./Firmware文件结构.md)

## 知识等级

★★★★ 建议掌握

## 参考资料

- 官方文档：ext4 docs `https://docs.kernel.org/filesystems/ext4/`
- 官方文档：Buildroot Manual `https://nightly.buildroot.org/manual.html`

## 最后验证时间

更新时间：2026-07-12

适用版本：ext2/ext3/ext4 通用知识

验证环境：Kernel / Buildroot / OpenWrt / MTD 文档整理

作者：Codex
