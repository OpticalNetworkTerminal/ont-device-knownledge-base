# BlockDevice与CharacterDevice

## 简介

本文说明块设备和字符设备的区别，以及为什么文件系统大多挂在块设备上，而 `MTD`、串口等常以字符设备形式暴露。

## 背景

很多排错都卡在这里：看到 `/dev/xxx` 就直接拿去 mount，结果失败。先区分块设备和字符设备，很多问题会立刻变简单。

## 基本概念

- 块设备：按块寻址，适合文件系统和缓存
- 字符设备：按流或专用接口访问，不以块随机寻址为核心

## 工作原理

块设备通常支持缓冲、随机块访问和分区语义，因此更适合作为 `ext4`、`f2fs` 之类文件系统的下层；字符设备则更常直接面向驱动接口或特殊控制路径。

## 设计目的

- 建立“设备类型决定上层用法”的判断方式
- 避免误把字符设备当成普通块盘使用

## 优缺点

优点：

- 排错效率高
- 便于理解 `/dev/mtd0` 与 `/dev/mtdblock0` 差异

缺点：

- 现实中存在桥接层和兼容层，初学时容易混淆
- 某些名字相近的节点用途完全不同

## 典型应用

- 硬盘/分区是块设备
- 串口、原始 MTD 往往是字符设备

## 在 Buildroot 中的位置

Buildroot 产出的系统若要挂载 `ext4` 或 loop 镜像，关注点通常是块设备；若处理 raw flash 和串口，则更多接触字符设备。

## 在 OpenWrt 中的位置

OpenWrt 的升级、分区和 raw flash 操作里，这个区分非常重要。

## 在光猫中的体现

光猫固件现场常能同时看到块设备和字符设备节点；误用会直接导致 mount 失败或读写方式错误。

## 实际案例

为什么 `/dev/mtd0` 不能像 `/dev/mmcblk0p1` 那样直接按普通块文件系统使用？因为二者的设备语义本就不同。

## 实践操作

```bash
ls -l /dev | head -n 40
lsblk 2>/dev/null
cat /proc/devices | head -n 60
```

怎么看：

- `ls -l`：字符设备显示 `c`，块设备显示 `b`
- `lsblk`：只关注块设备树，不会列出普通字符设备
- `/proc/devices`：核对类别和驱动登记

## 前置知识

- [Device Node](./Device Node.md)
- [MTD](./MTD.md)

## 后续知识

- [LoopDevice](./LoopDevice.md)
- [Ext2_Ext3_Ext4](./Ext2_Ext3_Ext4.md)

## 知识等级

★★★★★ 必须掌握

## 参考资料

- 官方文档：Linux allocated devices `https://docs.kernel.org/admin-guide/devices.html`
- 标准：loop(4) `https://man7.org/linux/man-pages/man4/loop.4.html`

## 最后验证时间

更新时间：2026-07-12

适用版本：块设备与字符设备通用知识

验证环境：Kernel / Buildroot / OpenWrt / MTD 文档整理

作者：Codex
