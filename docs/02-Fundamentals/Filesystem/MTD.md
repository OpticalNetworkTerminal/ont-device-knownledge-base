# MTD

## 简介

本文说明 `MTD` 子系统是什么，以及它为什么是 raw flash 世界的基础接口层。

## 背景

如果没有 `MTD`，用户态和上层文件系统就必须分别适配每种 raw flash 芯片。`MTD` 的存在，就是为了给 raw flash 提供统一访问抽象。

## 基本概念

- `MTD`：Memory Technology Device 子系统
- 为 raw flash 提供统一接口
- 其上可叠加 `JFFS2`、`UBI`、`UBIFS` 等层

## 工作原理

`MTD` 面向的是 raw flash 特征：擦除块、坏块、OOB、读写/擦除操作等。上层可以直接基于 MTD 做文件系统，或先接入 UBI。

## 设计目的

- 把 raw flash 抽象成统一接口
- 为上层文件系统、工具和分区管理提供基础

## 优缺点

优点：

- 是 raw flash 软件栈的根
- 大量工具和内核接口都围绕它展开

缺点：

- 概念容易和块设备混淆
- 不同 MTD 节点含义需仔细区分

## 典型应用

- `/dev/mtdX`
- `/proc/mtd`
- `mtdblock` 与 UBI 上层栈

## 在 Buildroot 中的位置

Buildroot 若面向 NOR/NAND 设备，最终镜像与用户态工具通常都会接触 `MTD` 相关能力。

## 在 OpenWrt 中的位置

OpenWrt 的 raw flash 分区、`firstboot`、升级与 Overlay 逻辑，大量基于 `MTD` 分区信息展开。

## 在光猫中的体现

光猫分析时，看到 `/proc/mtd` 往往就意味着你拿到的是更底层、更接近芯片视角的存储入口。

## 实际案例

为什么某些系统既有 `/dev/mtd0` 又有 `/dev/mtdblock0`？因为前者更接近 raw flash 接口，后者是内核为部分场景提供的块式兼容入口。

## 实践操作

```bash
cat /proc/mtd 2>/dev/null
ls -l /dev/mtd* 2>/dev/null | head -n 20
dmesg | grep -i mtd | head -n 30
```

怎么看：

- `/proc/mtd`：看分区名、大小、擦除块大小
- `/dev/mtd*`：看用户态可操作节点
- `dmesg`：看初始化和探测信息

## 前置知识

- [Flash存储特点](./Flash存储特点.md)
- [Device Node](./Device Node.md)

## 后续知识

- [JFFS2](./JFFS2.md)
- [UBI](./UBI.md)
- [Firmware文件结构](./Firmware文件结构.md)

## 知识等级

★★★★★ 必须掌握

## 参考资料

- 官方文档：General MTD documentation `https://www.linux-mtd.infradead.org/doc/general.html`
- 官方文档：NAND docs `https://www.linux-mtd.infradead.org/doc/nand.html`

## 最后验证时间

更新时间：2026-07-12

适用版本：MTD 通用知识

验证环境：Kernel / Buildroot / OpenWrt / MTD 文档整理

作者：Codex
