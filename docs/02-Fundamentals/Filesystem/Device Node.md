# Device Node

## 简介

本文说明设备节点为什么会出现在 `/dev` 中，以及它们为何不是普通数据文件。

## 背景

嵌入式现场经常直接操作 `/dev/mtdX`、`/dev/ttyS0`、`/dev/loop0`。如果不理解设备节点，容易误以为这些路径里存的是普通文件内容。

## 基本概念

- 设备节点：指向内核设备接口的特殊文件
- 字符设备与块设备使用主设备号 / 次设备号标识
- 创建方式可能来自 `devtmpfs`、`mdev`、`udev` 或镜像构建表

## 工作原理

设备节点是 VFS 中的特殊对象。访问它们时，真正处理 I/O 的是内核设备驱动，而不是普通文件系统读写路径。

## 设计目的

- 提供统一的设备访问入口
- 让用户态可以用路径和文件描述符模型操作硬件或虚拟设备

## 优缺点

优点：

- 与普通文件接口形式统一
- 便于脚本和工具链集成

缺点：

- 内容不等于磁盘数据
- 权限和主次设备号配置错误会直接影响系统功能

## 典型应用

- `/dev/mtd0`、`/dev/mtdblock0`
- `/dev/ttyS0`
- `/dev/loop0`

## 在 Buildroot 中的位置

Buildroot 可通过静态设备表或 `devtmpfs` 管理 `/dev`；最终镜像中的节点策略会影响系统能否正确访问存储和串口。

## 在 OpenWrt 中的位置

OpenWrt 常依赖现代 `/dev` 管理与 hotplug 逻辑组合，保持设备节点与硬件状态同步。

## 在光猫中的体现

光猫调试最常见的设备节点是串口、MTD 分区、网络相关伪设备和 loop 设备。

## 实际案例

为什么 `cat /dev/mtd0` 不是在读一个普通文件？因为 `/dev/mtd0` 本质是内核 MTD 驱动暴露给用户态的设备接口。

## 实践操作

```bash
ls -l /dev | head -n 30
stat /dev/null /dev/tty 2>/dev/null
cat /proc/devices | head -n 50
```

怎么看：

- `ls -l`：看设备节点类型字符 `c` 或块 `b`
- `stat`：看主设备号和次设备号
- `/proc/devices`：看内核登记的设备类别

## 前置知识

- [LinuxRuntime/Devtmpfs](../LinuxRuntime/Devtmpfs.md)
- [VFS虚拟文件系统](./VFS虚拟文件系统.md)

## 后续知识

- [BlockDevice与CharacterDevice](./BlockDevice与CharacterDevice.md)
- [MTD](./MTD.md)
- [LoopDevice](./LoopDevice.md)

## 知识等级

★★★★★ 必须掌握

## 参考资料

- 官方文档：Linux allocated devices `https://docs.kernel.org/admin-guide/devices.html`
- 官方文档：mknod(2) / stat(2) via man7 `https://man7.org/linux/man-pages/`

## 最后验证时间

更新时间：2026-07-12

适用版本：Linux 设备节点通用知识

验证环境：Kernel / Buildroot / OpenWrt / MTD 文档整理

作者：Codex
