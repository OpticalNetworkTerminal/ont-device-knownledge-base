# F2FS

## 简介

本文说明 `F2FS` 为什么被称为 Flash-Friendly File System，以及它与 `ext4`、raw flash 文件系统的关系。

## 背景

“适合 flash”不只意味着能运行在闪存设备上，还意味着设计时考虑了 NAND / eMMC / SSD 的内部行为。`F2FS` 就是典型例子。

## 基本概念

- `F2FS`：Flash-Friendly File System
- 面向基于 NAND 的块设备存储，如 eMMC、SD、SSD

## 工作原理

Kernel 文档说明 `F2FS` 基于 log-structured 思路，目标是适应 NAND flash 设备和其 FTL 特性；它仍属于块设备文件系统，而不是 raw flash 文件系统。

## 设计目的

- 为 managed flash 块设备提供更友好的写入模式
- 帮助区分“flash-friendly”与“直接跑在 raw flash 上”不是一回事

## 优缺点

优点：

- 对 eMMC/SSD 等场景更友好
- 专门针对 flash 块设备优化

缺点：

- 不等于 raw NAND 解决方案
- 生态与通用度通常不如 `ext4`

## 典型应用

- 手机/嵌入式 eMMC
- 需要频繁写入的小型块设备系统

## 在 Buildroot 中的位置

Buildroot 可在块设备场景下输出或使用 `f2fs` 相关工具链，但是否采用取决于目标介质。

## 在 OpenWrt 中的位置

OpenWrt 若运行在 eMMC 或 SD 等 managed flash 上，也可能选择 `f2fs` 作为可写分区方案。

## 在光猫中的体现

光猫不一定常见 `f2fs`，但带 eMMC 的网关、NAS、IoT 设备比 raw flash 设备更可能采用它。

## 实际案例

为什么 `F2FS` 虽然名字里有 flash，却不能替代 `UBIFS`？因为它面向的是带 FTL 的块设备，而不是 raw flash。

## 实践操作

```bash
cat /proc/filesystems | grep f2fs
blkid 2>/dev/null | grep f2fs
fsck.f2fs -V 2>/dev/null
```

怎么看：

- `/proc/filesystems`：确认支持
- `blkid`：看现场块设备是否已格式化为 `f2fs`
- 工具存在与否也能反映系统定位

## 前置知识

- [Ext2_Ext3_Ext4](./Ext2_Ext3_Ext4.md)
- [Flash存储特点](./Flash存储特点.md)

## 后续知识

- [Firmware文件结构](./Firmware文件结构.md)

## 知识等级

★★★ 了解即可

## 参考资料

- 官方文档：F2FS `https://docs.kernel.org/filesystems/f2fs.html`

## 最后验证时间

更新时间：2026-07-12

适用版本：F2FS 通用知识

验证环境：Kernel / Buildroot / OpenWrt / MTD 文档整理

作者：Codex
