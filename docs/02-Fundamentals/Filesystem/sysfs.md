# sysfs

## 简介

本文从文件系统章节视角说明 `sysfs` 为什么常出现在存储和设备分析中，以及它与真实持久化文件系统的区别。

## 背景

分析块设备、MTD、分区、总线和驱动时，经常要读 `/sys/class`、`/sys/block`、`/sys/devices`。这些路径很像目录树，但本质是内核设备模型接口。

## 基本概念

- `sysfs`：导出内核对象模型与属性的伪文件系统
- 重点不是持久化数据，而是设备、驱动、属性和层级关系

## 工作原理

`sysfs` 的文件内容通常来自内核对象属性回调，因此读写它是在和内核设备模型交互，而不是改磁盘文件。

## 设计目的

- 给用户态提供设备与驱动的结构化视图
- 让文件系统、块设备和 MTD 相关状态可被脚本化读取

## 优缺点

优点：

- 结构化程度高
- 对排查设备和挂载来源很有帮助

缺点：

- 误写可能改变系统状态
- 不适合当持久化配置存储

## 典型应用

- 查看块设备拓扑
- 查看分区与设备属性
- 查看模块和总线状态

## 在 Buildroot 中的位置

Buildroot 设备只要使用 Linux 标准设备模型，`sysfs` 就会成为理解存储设备与驱动关系的重要入口。

## 在 OpenWrt 中的位置

OpenWrt 热插拔、块设备识别和部分存储逻辑也大量依赖 `sysfs`。

## 在光猫中的体现

光猫、NAS 和 IoT 设备中，块设备、MTD、LED、按键、网口等对象往往都能在 `sysfs` 找到对应入口。

## 实际案例

为什么 `lsblk` 能识别那么多设备关系？因为它背后通常会综合读取 `/sys` 中的块设备和分区信息。

## 实践操作

```bash
ls /sys/block 2>/dev/null | head -n 30
find /sys/class/mtd -maxdepth 2 2>/dev/null | head -n 30
find /sys/block -maxdepth 2 2>/dev/null | head -n 30
```

怎么看：

- `/sys/block`：看块设备和分区层次
- `/sys/class/mtd`：看 raw flash 分区对象
- 这些路径反映的是内核对象关系，不是持久目录

## 前置知识

- [LinuxRuntime/Sysfs](../LinuxRuntime/Sysfs.md)
- [VFS虚拟文件系统](./VFS虚拟文件系统.md)

## 后续知识

- [MTD](./MTD.md)
- [BlockDevice与CharacterDevice](./BlockDevice与CharacterDevice.md)

## 知识等级

★★★★ 建议掌握

## 参考资料

- 官方文档：sysfs docs `https://docs.kernel.org/filesystems/sysfs.html`
- 官方文档：sysfs rules `https://docs.kernel.org/admin-guide/sysfs-rules.html`

## 最后验证时间

更新时间：2026-07-12

适用版本：sysfs 的文件系统分析视角

验证环境：Kernel / Buildroot / OpenWrt / MTD 文档整理

作者：Codex
