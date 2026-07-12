# LoopDevice

## 简介

本文说明 loop device 为什么能把一个普通文件映射成块设备，以及它在镜像分析中的价值。

## 背景

固件分析时，经常需要把一个文件当作“磁盘镜像”处理。loop device 就是 Linux 提供的桥梁。

## 基本概念

- loop device：把普通文件或块设备映射成块设备接口
- 适合对磁盘镜像做 mount、fsck、blkid 等操作

## 工作原理

man7 说明 loop 设备把普通文件的数据块映射成块设备视角，因此用户态可以像对待真实块盘那样处理某些镜像文件。

## 设计目的

- 让镜像文件复用块设备工具链
- 为离线 Rootfs 和固件分析提供便利

## 优缺点

优点：

- 调试和分析方便
- 能直接挂载 `ext4` 等块设备镜像

缺点：

- 不适用于 raw flash 文件系统如 `JFFS2`
- 容易让人误以为所有镜像都能 loop 挂载

## 典型应用

- 挂载 `ext4` 镜像
- 离线检查分区镜像

## 在 Buildroot 中的位置

Buildroot 输出的 `ext4` 镜像、某些分区镜像可以直接借助 loop 做离线分析。

## 在 OpenWrt 中的位置

OpenWrt 扩展根、块设备镜像和调试场景中也可能接触 loop 设备。

## 在光猫中的体现

在光猫和路由器固件分析中，loop 最常用于处理块设备型镜像，而不是 raw flash 镜像。

## 实际案例

为什么 `rootfs.ext4` 常能直接 mount，而 `rootfs.jffs2` 不行？因为前者适配块设备语义，后者不是。

## 实践操作

```bash
losetup -a 2>/dev/null
losetup --help 2>/dev/null
mount -o loop image.ext4 /mnt/test 2>/dev/null
```

怎么看：

- `losetup`：看系统已有 loop 映射
- `mount -o loop`：把块设备镜像当盘挂载
- 失败时先判断镜像格式是否真是块设备文件系统

## 前置知识

- [BlockDevice与CharacterDevice](./BlockDevice与CharacterDevice.md)
- [Ext2_Ext3_Ext4](./Ext2_Ext3_Ext4.md)

## 后续知识

- [Firmware文件结构](./Firmware文件结构.md)
- [FactoryFirmware](./FactoryFirmware.md)

## 知识等级

★★★★ 建议掌握

## 参考资料

- 官方文档：loop(4) `https://man7.org/linux/man-pages/man4/loop.4.html`
- 官方文档：losetup(8) `https://man7.org/linux/man-pages/man8/losetup.8.html`

## 最后验证时间

更新时间：2026-07-12

适用版本：loop device 通用知识

验证环境：Kernel / Buildroot / OpenWrt / MTD 文档整理

作者：Codex
