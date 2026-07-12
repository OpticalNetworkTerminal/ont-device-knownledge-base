# JFFS2

## 简介

本文说明 `JFFS2` 为什么适合直接运行在 raw flash 上，以及它与 `SquashFS`、`UBIFS` 的定位差异。

## 背景

raw flash 不能像硬盘那样直接交给传统块设备文件系统。`JFFS2` 的重要意义在于它直接面对 flash 擦写特性，而不是先模拟成普通块设备。

## 基本概念

- `JFFS2`：直接运行在 MTD 设备上的日志型 flash 文件系统
- 适合 raw flash，尤其是较小规模场景

## 工作原理

MTD 官方资料明确指出 `JFFS2` 直接工作在 flash 之上，而不是先模拟块设备；它需要考虑擦除块、cleanmarker、扫描挂载等 flash 特性。

## 设计目的

- 让 raw flash 可以直接承载可写文件系统
- 适配擦除块与断电恢复语义

## 优缺点

优点：

- 直接面向 flash 特性
- 适合历史上大量 NOR / 小型 NAND 场景

缺点：

- 挂载时全盘扫描，容量增大后成本明显
- 在大 NAND 场景下通常不如 `UBIFS`

## 典型应用

- OpenWrt 早期或 NOR 场景可写层
- 小型 raw flash 分区

## 在 Buildroot 中的位置

Buildroot 能输出 `jffs2` 镜像，但是否合适要看设备的 flash 类型和容量。

## 在 OpenWrt 中的位置

OpenWrt 在 raw NOR 场景里长期将 `JFFS2` 作为可写层的重要选项之一。

## 在光猫中的体现

不少运营商设备和老路由器的可写配置层、恢复逻辑都带有明显 `JFFS2` 痕迹。

## 实际案例

为什么 `JFFS2` 镜像不能像 `ext4` 一样直接 loop mount？因为它不是为块设备接口设计的。

## 实践操作

```bash
cat /proc/filesystems | grep jffs2
cat /proc/mtd 2>/dev/null
find / -name "*.jffs2" 2>/dev/null | head
```

怎么看：

- `/proc/filesystems`：看内核是否支持 `jffs2`
- `/proc/mtd`：确认它依附的 raw flash 分区
- 现场更多是通过 MTD 分区和升级逻辑间接识别

## 前置知识

- [Flash存储特点](./Flash存储特点.md)
- [MTD](./MTD.md)

## 后续知识

- [UBI](./UBI.md)
- [UBIFS](./UBIFS.md)
- [常见问题](./常见问题.md)

## 知识等级

★★★★★ 必须掌握

## 参考资料

- 官方文档：JFFS2 `https://www.linux-mtd.infradead.org/doc/jffs2.html`
- 官方文档：JFFS2 FAQ `https://www.linux-mtd.infradead.org/faq/jffs2.html`

## 最后验证时间

更新时间：2026-07-12

适用版本：JFFS2 通用知识

验证环境：Kernel / Buildroot / OpenWrt / MTD 文档整理

作者：Codex
