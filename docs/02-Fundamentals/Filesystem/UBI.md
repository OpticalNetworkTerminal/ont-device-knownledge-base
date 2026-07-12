# UBI

## 简介

本文说明 `UBI` 为什么不是文件系统，而是位于 raw flash 与 `UBIFS` 之间的卷管理和 wear leveling 层。

## 背景

很多人第一次看到 `UBI` 会误以为它等于某种文件系统。实际上它更像 raw flash 世界里的卷管理层，解决的是磨损均衡、坏块和逻辑卷抽象。

## 基本概念

- `UBI`：Unsorted Block Images
- 工作在 MTD 之上，向上提供 UBI volume
- 核心职责是 wear leveling、坏块处理、逻辑擦除块抽象

## 工作原理

MTD 官方资料和 Kernel 文档都指出，`UBI` 提供全局 wear leveling、擦除计数管理和透明的数据移动能力；上层看到的是逻辑卷，而不是直接的物理擦除块。

## 设计目的

- 把 raw flash 的磨损和坏块复杂性从上层剥离
- 为 `UBIFS` 等上层提供更稳定抽象

## 优缺点

优点：

- 能做全局 wear leveling
- 让上层文件系统不必直接面对坏块管理

缺点：

- 本身不是最终文件系统
- 额外占用一定空间和复杂度

## 典型应用

- NAND 上的 `UBIFS`
- 多 volume 分区设计
- 升级与配置分卷

## 在 Buildroot 中的位置

Buildroot 在 NAND 场景里如果输出 `ubifs`，往往也需要考虑 `ubinize`、`ubi` volume 相关封装。

## 在 OpenWrt 中的位置

OpenWrt 在部分 NAND 设备上会使用 `UBI` / `UBIFS` 组合来承载可写系统层。

## 在光猫中的体现

光猫和高容量 NAND 路由器常用 `UBI` 把 raw flash 先卷管理化，再让上层挂 `UBIFS`。

## 实际案例

为什么 `UBI` 要做 wear leveling？因为 raw flash 擦除次数有限，若总写同一批块，会比桌面磁盘更快老化失效。

## 实践操作

```bash
cat /proc/mtd 2>/dev/null
ubinfo -a 2>/dev/null | head -n 50
ubiattach --help 2>/dev/null
```

怎么看：

- `/proc/mtd`：看底层 raw flash 分区
- `ubinfo`：看 UBI 设备和 volume 信息
- `ubiattach`：说明 UBI 先附着在 MTD 之上，再暴露更高层对象

## 前置知识

- [Flash存储特点](./Flash存储特点.md)
- [MTD](./MTD.md)

## 后续知识

- [UBIFS](./UBIFS.md)
- [FactoryFirmware](./FactoryFirmware.md)

## 知识等级

★★★★★ 必须掌握

## 参考资料

- 官方文档：UBI `https://www.linux-mtd.infradead.org/doc/ubi.html`
- 官方文档：UBI FAQ `https://www.linux-mtd.infradead.org/faq/ubi.html`
- 官方文档：UBIFS kernel docs `https://docs.kernel.org/filesystems/ubifs.html`

## 最后验证时间

更新时间：2026-07-12

适用版本：UBI 通用知识

验证环境：Kernel / Buildroot / OpenWrt / MTD 文档整理

作者：Codex
