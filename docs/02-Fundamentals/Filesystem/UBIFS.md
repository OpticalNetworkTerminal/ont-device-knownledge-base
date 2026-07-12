# UBIFS

## 简介

本文说明 `UBIFS` 为什么必须运行在 `UBI` 之上，以及它为何比 `JFFS2` 更适合大容量 NAND 场景。

## 背景

用户常会问：既然有 `UBIFS`，为什么不直接挂到硬盘或 loop 文件上？原因在于它依赖的并不是普通块设备模型，而是 `UBI` 提供的 raw flash 抽象。

## 基本概念

- `UBIFS`：运行在 `UBI` volume 之上的文件系统
- 与 `JFFS2` 相比，它更适合大容量 NAND 和更快挂载

## 工作原理

Kernel 文档明确指出 `UBIFS` 工作在 `UBI` 之上，而 `UBI` 再工作在 `MTD` 之上；它在介质上维护索引，因此不需要像 `JFFS2` 那样每次挂载都全盘扫描。

## 设计目的

- 为 raw NAND 场景提供更可扩展的可写文件系统
- 降低大容量 flash 场景下的挂载成本

## 优缺点

优点：

- 挂载更快
- 更适合大规模 NAND
- 支持压缩与断电恢复

缺点：

- 不能脱离 `UBI` 单独存在
- 不适用于普通块设备或硬盘直接挂载

## 典型应用

- NAND 路由器 Rootfs 或 data 分区
- 需要高可靠可写层的嵌入式设备

## 在 Buildroot 中的位置

Buildroot 可输出 `ubifs` 镜像，并配合 `ubinize` 形成适合 NAND 部署的产物。

## 在 OpenWrt 中的位置

OpenWrt 在 NAND 机型上经常使用 `UBIFS` 作为可写层或系统层的一部分。

## 在光猫中的体现

光猫和高容量网关若采用 NAND Flash，`UBIFS` 常是比 `JFFS2` 更现实的选择。

## 实际案例

为什么 `UBIFS` 不能直接挂在硬盘分区上？因为它期待下层提供的是 `UBI` 语义，而不是普通块设备语义。

## 实践操作

```bash
cat /proc/filesystems | grep ubifs
ubinfo -a 2>/dev/null | head -n 50
mount | grep ubifs 2>/dev/null
```

怎么看：

- `/proc/filesystems`：确认内核支持
- `ubinfo`：确认其依附的 UBI 设备和 volume
- `mount`：观察现场是否以 `ubifs` 挂载

## 前置知识

- [UBI](./UBI.md)
- [MTD](./MTD.md)
- [Flash存储特点](./Flash存储特点.md)

## 后续知识

- [FactoryFirmware](./FactoryFirmware.md)
- [UpgradeFirmware](./UpgradeFirmware.md)

## 知识等级

★★★★★ 必须掌握

## 参考资料

- 官方文档：UBIFS kernel docs `https://docs.kernel.org/filesystems/ubifs.html`
- 官方文档：UBIFS MTD docs `https://www.linux-mtd.infradead.org/doc/ubifs.html`

## 最后验证时间

更新时间：2026-07-12

适用版本：UBIFS 通用知识

验证环境：Kernel / Buildroot / OpenWrt / MTD 文档整理

作者：Codex
