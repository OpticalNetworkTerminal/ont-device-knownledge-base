# Flash存储特点

## 简介

本文说明 raw flash 与硬盘/SSD 在写入模型上的根本差异，以及为什么这些差异会决定文件系统与升级设计。

## 背景

要理解为什么需要 `SquashFS`、Overlay、`UBI`、`JFFS2`、`UBIFS`，首先要理解 flash 不是“更小的硬盘”。

## 基本概念

- 擦除前不能重写整块
- 擦除块大于页大小
- 擦写寿命有限
- NAND 可能出现坏块
- raw flash 与 managed flash 是两类世界

## 工作原理

raw flash 写入通常受擦除块粒度、坏块和磨损影响；而 eMMC/SSD 这类 managed flash 把这些复杂性隐藏在 FTL 之后，对上层更像块设备。

## 设计目的

- 解释文件系统选择背后的物理原因
- 说明 wear leveling、只读 Rootfs、Overlay 的根本动机

## 优缺点

优点：

- 能把很多“为什么”讲通
- 是理解 raw flash 软件栈的基石

缺点：

- 偏底层
- 需要和 MTD / UBI / UBIFS 一起看

## 典型应用

- 解释为什么 Flash 不能像硬盘那样原地改写
- 判断设备更接近 raw flash 还是块设备

## 在 Buildroot 中的位置

Buildroot 输出镜像格式时，首先要考虑目标板到底接的是 NOR/NAND 还是 eMMC/SD。

## 在 OpenWrt 中的位置

OpenWrt 的 Flash Layout 和 Overlay 设计，很大程度上就是对 Flash 特性做工程化折中。

## 在光猫中的体现

光猫、路由器和 IoT 设备之所以偏爱只读系统层，背后就是为了降低 Flash 写入风险和寿命消耗。

## 实际案例

为什么修改一个很小的配置，也不应该直接频繁写只读系统分区？因为底层可能需要整块擦除，写入代价远大于表面看到的字节数。

## 实践操作

```bash
cat /proc/mtd 2>/dev/null
dmesg | grep -i -E "mtd|ubi|nand|nor" | head -n 30
lsblk 2>/dev/null
```

怎么看：

- `/proc/mtd`：说明系统是否直接暴露 raw flash
- `dmesg`：常能看到 NAND/NOR/UBI 初始化线索
- `lsblk`：若主要看到块设备，则更接近 managed flash 世界

## 前置知识

- [Linux文件系统概述](./Linux文件系统概述.md)

## 后续知识

- [MTD](./MTD.md)
- [UBI](./UBI.md)
- [UBIFS](./UBIFS.md)

## 知识等级

★★★★★ 必须掌握

## 参考资料

- 官方文档：UBIFS kernel docs `https://docs.kernel.org/filesystems/ubifs.html`
- 官方文档：General MTD documentation `https://www.linux-mtd.infradead.org/doc/general.html`

## 最后验证时间

更新时间：2026-07-12

适用版本：Flash 存储特点通用知识

验证环境：Kernel / Buildroot / OpenWrt / MTD 文档整理

作者：Codex
