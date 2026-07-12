# SquashFS

## 简介

本文说明 `SquashFS` 为什么会成为大量路由器、光猫和 IoT 设备的默认只读 Rootfs 选择。

## 背景

嵌入式设备往往希望系统本体小、稳定、可批量分发、升级后比特级一致。`SquashFS` 正好满足“压缩 + 只读镜像”的需求。

## 基本概念

- `SquashFS`：压缩只读文件系统
- 支持多种压缩算法
- 常作为基础 Rootfs lower 层

## 工作原理

Kernel 文档说明 `SquashFS` 是压缩只读文件系统，会压缩文件、inode 和目录元数据，因此非常适合把稳定系统基线打成一个不可变镜像。

## 设计目的

- 提供高压缩比的只读系统镜像
- 减少 Flash 占用
- 为 Overlay 设计提供稳定 lower 层

## 优缺点

优点：

- 空间利用率高
- 只读语义天然适合系统基线

缺点：

- 不能直接承载在线修改
- 修改需求必须借助 Overlay 或重刷镜像

## 典型应用

- 路由器和光猫 Rootfs
- 工厂固件中的只读系统分区

## 在 Buildroot 中的位置

Buildroot 可直接输出 `squashfs` Rootfs 镜像，是构建只读系统的常见选项。

## 在 OpenWrt 中的位置

OpenWrt 默认思路之一就是 `SquashFS` + Overlay；这也是为什么恢复出厂往往只清可写层。

## 在光猫中的体现

光猫和 Mesh 设备大量使用 `SquashFS` 承载基础系统，因为它既节省空间，也让运营商升级基线更可控。

## 实际案例

为什么修改配置不会真的改写 `SquashFS`？因为它本来就是只读的，现场修改必须落到 upper 层。

## 实践操作

```bash
cat /proc/filesystems | grep squashfs
unsquashfs -s firmware.squashfs 2>/dev/null
binwalk firmware.bin 2>/dev/null | head -n 20
```

怎么看：

- `/proc/filesystems`：确认内核是否支持 `squashfs`
- `unsquashfs -s`：看镜像元信息和压缩方式
- `binwalk`：固件解包时快速定位 `SquashFS` 签名

## 前置知识

- [Rootfs](./Rootfs.md)
- [Overlay机制](./Overlay机制.md)
- [Buildroot/Filesystem生成](../Buildroot/Filesystem生成.md)

## 后续知识

- [FactoryFirmware](./FactoryFirmware.md)
- [UpgradeFirmware](./UpgradeFirmware.md)

## 知识等级

★★★★★ 必须掌握

## 参考资料

- 官方文档：Squashfs 4.0 Filesystem `https://docs.kernel.org/filesystems/squashfs.html`
- 官方文档：Buildroot Manual `https://nightly.buildroot.org/manual.html`

## 最后验证时间

更新时间：2026-07-12

适用版本：SquashFS 通用知识

验证环境：Kernel / Buildroot / OpenWrt / MTD 文档整理

作者：Codex
